local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.oauth2-authenticators.access"
local singletons = require "kong.singletons"

local AuthenticationHandler = BasePlugin:extend()

local string_find = string.find

function AuthenticationHandler:new()
  AuthenticationHandler.super.new(self, "oauth2-authenticators")
end

local function add_providers(conf)
  local providers = {}
-- request method, URL, parameters, response type, name, logo
  if #conf.global_providers > 0 then
    local provider_daos = singletons.dao.social_oauth2_providers:find_all({ name = conf.global_providers, is_global = true })
  end
end

function AuthenticationHandler:access(conf)
  AuthenticationHandler.super.access(self)
  -- GET /oauth2/authorize retrieve all the authenticators for the API or global.
  if ngx.ctx.get_method() == "GET" then
    local uri = ngx.var.uri

    local from, _ = string_find(uri, "/oauth2/authorize", nil, true)
    if from then
      local providers = add_providers(conf)
    end
  end

  access.execute(conf)
end

AuthenticationHandler.PRIORITY = 1006
AuthenticationHandler.VERSION = "0.1.0"

return AuthenticationHandler
