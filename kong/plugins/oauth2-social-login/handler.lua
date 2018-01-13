local BasePlugin = require "kong.plugins.base_plugin"
local authorize = require "kong.plugins.oauth2-social-login.authorize"
local singletons = require "kong.singletons"
local utils = require "kong.tools.utils"
local callback = require "kong.plugins.oauth2-social-login.callback"

local SocialLoginHandler = BasePlugin:extend()

local string_match = string.match

local function list_merge(a, b)
  local temp
  if not a then
    a = {}
  end
  if not b then
    b = {}
  end
  if #a > #b then
    temp = a
    a = b
    b = temp
  end
  for i, v in ipairs(a) do table.insert(b, v) end
  return b
end

local function get_providers()
  local providers = {}
  local provider_entities = singletons.dao.social_oauth2_providers:find_all()
  for i, v in ipairs(provider_entities) do
    table.insert(providers, { name = v.name, logo = v.logo, method = "GET", uri = "/oauth2/authorize/" .. v.name, response_type = "REDIRECT" })
  end
  return providers
end

function SocialLoginHandler:new()
  SocialLoginHandler.super.new(self, "oauth2-social-login")
end

function SocialLoginHandler:access(conf)
  SocialLoginHandler.super.access(self)
  if ngx.ctx.authenticated_credential and conf.anonymous ~= "" then
    -- we're already authenticated, and we're configured for using anonymous,
    -- hence we're in a logical OR between auth methods and we're already done.
    return
  end
  -- GET /oauth2/authorize retrieve all the authenticators for the API.

  if ngx.req.get_method() == "GET" then
    local uri = ngx.var.uri
    local from
    from, _ = string_match(uri, "/oauth2/authorize[%s/]*$", nil, true)
    if from then
      ngx.ctx.auth_providers = list_merge(ngx.ctx.auth_providers, get_providers())
      return
    end

    from, _ = string_match(uri, "/oauth2/authorize/%w+", nil, true)
    if from then
      authorize.execute(conf)
      return
    end

    from, _ = string_match(uri, "/oauth2/social/callback")
    if from then
      callback.execute(conf)
      return
    end
  end
end

SocialLoginHandler.PRIORITY = 1006
SocialLoginHandler.VERSION = "0.1.0"

return SocialLoginHandler
