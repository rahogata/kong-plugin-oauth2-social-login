local crud = require "kong.api.crud_helpers"

return {
  ["/social_providers/"] = {
    GET = function(self, dao_factory)
      crud.paginated_set(self, dao_factory.social_oauth2_providers)
    end,

    PUT = function(self, dao_factory)
      crud.put(self.params, dao_factory.social_oauth2_providers)
    end,

    POST = function(self, dao_factory)
      crud.post(self.params, dao_factory.social_oauth2_providers)
    end
  },

  ["/social_providers/:name"] = {
    before = function(self, dao_factory, helpers)
      local providers, err = crud.find_by_id_or_field(
        dao_factory.social_oauth2_providers,
        nil,
        self.params.name,
        "name")

      if err then
        return helpers.yield_error(err)
      elseif next(providers) == nil then
        return helpers.responses.send_HTTP_NOT_FOUND()
      end
      self.provider = providers[1]
    end,
    
    GET = function(self, dao_factory, helpers)
      return helpers.responses.send_HTTP_OK(self.provider)
    end,
    
    DELETE = function(self, dao_factory)
      crud.delete(self.provider, dao_factory.social_oauth2_providers)
    end
  }
}
