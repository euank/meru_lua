local args = ngx.req.get_uri_args()

if not (type(args) == "table" and
     (type(args["id"]) == "string" or type(args["invite"] == "string"))) then
  ngx.say(cjson.encode({error = "Required parameter missing"}))
  return
end

local id = tonumber(args["id"])
local invite = nil

if(type(args["invite"]) == "string") then
  invite = ngx.quote_sql_str(args["invite"])
end

if id == nil and invite == nil then
  ngx.say(cjson.encode({error = "Required parameter missing"}))
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

if id then
  res, err, errno, sqlstate = db:query("SELECT name FROM virtual_domains WHERE id="..id)
elseif invite then
  -- I'll be honest, I'm kinda confused as to why I don't quote invite. Really. hell if I know.
  res, err, errno, sqlstate = db:query("SELECT name FROM virtual_domains INNER JOIN virtual_users ON virtual_domains.id = virtual_users.domain_id WHERE invite_code="..invite.."")
end

if not (res and res[1] and res[1]["name"]) then
  ngx.say(cjson.encode({error = "Error getting domain. Invalid id or invite"}))
  return
end

ngx.say(cjson.encode({ok = 1, name = res[1]["name"]}));
