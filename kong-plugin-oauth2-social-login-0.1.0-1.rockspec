package = "kong-plugin-oauth2-social-login"
version = "0.1.0-1"
-- The version '0.1.0' is the source code version, the trailing '1' is the version of this rockspec.
-- whenever the source version changes, the rockspec should be reset to 1. The rockspec version is only
-- updated (incremented) when this file changes, but the source remains the same.

-- Here we extract it from the package name.
local pluginName = package:match("^kong%-plugin%-(.+)$")  -- "oauth2-social-login"

supported_platforms = {"linux", "macosx"}
source = {
  -- these are initially not required to make it work
  url = "git://github.com/shiva2991/kong-plugin-oauth2-social-login",
  tag = "v0.0"
}

description = {
  summary = "A plugin to use 3rd party IdP as authorization server for in built oauth2 plugin.",
  homepage = "http://rahogata.co.in",
  license = "MIT"
}

dependencies = {
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..pluginName..".api"] = "kong/plugins/"..pluginName.."/api.lua",
    ["kong.plugins."..pluginName..".authorize"] = "kong/plugins/"..pluginName.."/authorize.lua",
    ["kong.plugins."..pluginName..".callback"] = "kong/plugins/"..pluginName.."/callback.lua",
    ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
    ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua"
  }
}
