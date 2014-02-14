meru_lua
========

A (now abandoned) api for managing mail accounts with nginx embedded lua. The
mail setup is postfix + dovecot with mysql backing. This code hardcodes a lot of
stuff that shouldn't be hardcoded and I have no plans to improve it.

Honestly, this repository should be ignored.

Abandoned?
---------

I ended up just doing it in ruby instead since I'm more familiar with it.

Why is this here?
-----------------

I put this here as an example of a simple api using lua (installed via openresty
in my case. Check out
[openresty-playbook](https://github.com/euank/openresty-playbook) if you want to
install it fairly painlessly). Perhaps someone can benefit from it... though it
also might be beneficial as a counterexample for the right way since I don't
know lua best practices due to using it rarely.

Known issues
------------

Doesn't properly validate the format of usernames. Has code repetition that could be
avoided by initializing it in ngx.ctx in a previous phase where all locations
reference this e.g. 'init.lua' file.
