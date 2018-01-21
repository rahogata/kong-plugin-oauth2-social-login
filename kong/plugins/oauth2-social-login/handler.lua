local BasePlugin = require "kong.plugins.base_plugin"
local authorize = require "kong.plugins.oauth2-social-login.authorize"
local singletons = require "kong.singletons"
local utils = require "kong.tools.utils"
local callback = require "kong.plugins.oauth2-social-login.callback"

local SocialLoginHandler = BasePlugin:extend()

local string_match = string.match

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

  if ngx.req.get_method() == "GET" then
    local uri = ngx.var.uri
    local from, _ = string_match(uri, "/oauth2/authorize/" .. conf.provider_type .. "/%w+", nil, true)
    if from then
      authorize.execute(conf)
    else
      from, _ = string_match(uri, "/oauth2/" .. conf.provider_type .. "/callback")
      if from then
        callback.execute(conf)
      end
    end
  end
end

SocialLoginHandler.PRIORITY = 1006
SocialLoginHandler.VERSION = "0.1.0"

return SocialLoginHandler
