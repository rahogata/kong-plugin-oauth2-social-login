local helpers = require "spec.helpers"

describe("Auth-Providers-Reflector-Plugin: auth-providers-reflector (handler)", function()
  local client

  setup(function()
    local api1 = assert(helpers.dao.apis:insert {
        name = "api-1",
        hosts = { "test1.com" },
        upstream_url = "http://mockbin.com",
    })

    assert(helpers.dao.plugins:insert {
      api_id = api1.id,
      name = "auth-providers-reflector",
    })

    -- start kong, while setting the config item `custom_plugins` to make sure our
    -- plugin gets loaded
    assert(helpers.start_kong {custom_plugins = "auth-providers-reflector"})
  end)

  teardown(function()
    helpers.stop_kong()
  end)

  before_each(function()
    client = helpers.proxy_client()
  end)

  after_each(function()
    if client then client:close() end
  end)

  describe("get-providers", function()
    it("retrieve list of providers applied to an api", function()
      local r = assert(client:send{
        method = "GET",
        path = "/oauth2/authorize",
        headers = {
          host = "test1.com"
        }
    })
      assert.response(r).has.status(200)
    end)
  end)
end)
