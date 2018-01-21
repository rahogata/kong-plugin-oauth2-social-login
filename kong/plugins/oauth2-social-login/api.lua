local crud = require "kong.api.crud_helpers"
local url = require "socket.url"

local SOCIAL = "SOCIAL"

local function validate_uris(v)
  if v then
    if #v == 0 then
      return false, "Invalid request."
    end
    for _, uri in ipairs(v) do
      local parsed_uri = url.parse(uri)
      if not (parsed_uri and parsed_uri.host and parsed_uri.scheme) then
        return false, "cannot parse '" .. uri .. "'"
      end
      if parsed_uri.fragment ~= nil then
        return false, "fragment not allowed in '" .. uri .. "'"
      end
    end
    return true, nil
  end
  return false, "Invalid uri found in the configuration."
end

local function validate_config(conf)
  if not conf then
    return false, "No configuration found."
  end
  if not conf.client_id or not conf.client_secret or next(conf.scopes and conf.scopes or {}) == nil then
     return false, "Invalid request."
  end
  return validate_uris({ conf.authorization_uri, conf.token_uri, conf.profile_uri })
end

return {
  ["/auth_providers/social"] = {
    before = function(self, dao_factory)
      self.params.provider_type = SOCIAL
      self.params.method = "GET"
      self.params.uri = "/oauth2/authorize/" .. SOCIAL .. "/"
      self.params.response_type = "REDIRECT"
    end,

    GET = function(self, dao_factory)
      crud.paginated_set(self, dao_factory.auth_providers)
    end,

    PUT = function(self, dao_factory, helpers)
      local ok, err = validate_config(self.params.config)
      if not ok then
        helpers.responses.send_HTTP_BAD_REQUEST(err)
      end
      crud.put(self.params, dao_factory.auth_providers)
    end,

    POST = function(self, dao_factory, helpers)
      local ok, err = validate_config(self.params.config)
      if not ok then
        helpers.responses.send_HTTP_BAD_REQUEST(err)
      end
      crud.post(self.params, dao_factory.auth_providers)
    end
  },

  ["/auth_providers/social/:name"] = {
    before = function(self, dao_factory, helpers)
      local providers, err = crud.find_by_id_or_field(
        dao_factory.auth_providers,
        nil,
        self.params.name,
        "name")

      if err then
        return helpers.yield_error(err)
      elseif next(providers) == nil or providers[1].type ~= SOCIAL then
        return helpers.responses.send_HTTP_NOT_FOUND()
      end
      self.provider = providers[1]
    end,

    GET = function(self, dao_factory, helpers)
      return helpers.responses.send_HTTP_OK(self.provider)
    end,

    DELETE = function(self, dao_factory)
      crud.delete(self.provider, dao_factory.auth_providers)
    end
  }
}
