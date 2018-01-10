local BasePlugin = require "kong.plugins.base_plugin"

local AuthProviderReflector = BasePlugin:extend()

function AuthProviderReflector:new()
  AuthProviderReflector.super.new(self, "auth-providers-reflector")
end

function AuthProviderReflector:access(conf)
  AuthProviderReflector.super.access(self)
  if ngx.ctx.get_method() == "GET" then
    local uri = ngx.var.uri
    local from, _ = string_match(uri, "/oauth2/authorize[%s/]*$", nil, true)
    if from then
      return responses.send(200, ngx.ctx.auth_providers)
    end
  end
end

AuthProviderReflector.PRIORITY = 1000
AuthProviderReflector.VERSION = "0.1.0"

return AuthProviderReflector
