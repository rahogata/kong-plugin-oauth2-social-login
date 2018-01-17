local BasePlugin = require "kong.plugins.base_plugin"
local responses = require "kong.tools.responses"

local string_match = string.match

local MESSAGE = "message"

local AuthProviderReflector = BasePlugin:extend()

function AuthProviderReflector:new()
  AuthProviderReflector.super.new(self, "auth-providers-repo")
end

function AuthProviderReflector:access(conf)
  AuthProviderReflector.super.access(self)
  if ngx.req.get_method() == "GET" then
    local uri = ngx.var.uri
    local from, _ = string_match(uri, "/oauth2/authorize[%s/]*$", nil, true)
    if from then
      return responses.send(next(ngx.ctx.auth_providers) ~= nil and 200 or 404,
      					next(ngx.ctx.auth_providers) ~= nil and ngx.ctx.auth_providers or { [MESSAGE] = "Providers not found." })
    end
  end
end

AuthProviderReflector.PRIORITY = 1005
AuthProviderReflector.VERSION = "0.1.0"

return AuthProviderReflector
