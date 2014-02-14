ngx.req.read_body()
local args = ngx.req.get_post_args()

if not (type(args) == "table" and
     type(args["user"]) == "string" and
     type(args["password"]) == "string" and
     type(args["invite"]) == "string") then
  ngx.say(cjson.encode({error = "Required parameter missing"}))
  return
end

local user = ngx.quote_sql_str(args["user"])
local password = ngx.quote_sql_str(args["password"])
local invite = ngx.quote_sql_str(args["invite"])

if string.len(args["password"]) < 8 then
  ngx.say(cjson.encode({error = "Password too short"}))
  return
end

local mysql = require "resty.mysql"
local db, err = mysql:new()
if not db then
  ngx.say(cjson.encode({error = "failed to instantiate mysql: "..err}))
  return
end
local ok, err, errno, sqlstate = db:connect{
  host = "127.0.0.1",
  port = 3306,
  database = "test_meru",
  user = "testmeru",
  password = "testmeru",
  max_packet_size = 1024 * 1024 }

if not ok then
  ngx.say(cjson.encode({error = "failed to connect: ".. err.. ": ".. errno.. " ".. sqlstate}))
  return
end

-- The user row must be set as unique on the database end
-- Assumptions: the domain_id is already set and cannot be changed or chosen
res, err, errno, sqlstate = db:query("UPDATE virtual_users SET user="..user..", password=ENCRYPT("..password..", CONCAT(\"$6$\", SUBSTRING(SHA(RAND()), -16))),invite_code=NULL WHERE invite_code="..invite.." LIMIT 1")

if res.affected_rows == 1 then
  ngx.say(cjson.encode({ok = 1}))
else
  ngx.say(cjson.encode({error = "Invalid invite code"}))
end
