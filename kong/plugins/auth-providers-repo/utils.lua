local singletons = require "kong.singletons"

local _M = {}

function _M.get_providers(auth_type)
  local providers = {}
  local provider_entities = singletons.dao.auth_providers:find_all({ type = auth_type })
  for i, v in ipairs(provider_entities) do
    table.insert(providers, { name = v.name, method = "GET", uri = "/oauth2/authorize/" .. v.name, response_type = "REDIRECT" })
  end
  return providers
end

function _M.list_merge(a, b)
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

function _M.retrieve_parameters()
  return ngx.req.get_uri_args()
end

function _M.load_oauth2_plugin_into_memory(session)
  local oauth2_plugin, err
  oauth2_plugin, err = singletons.dao.plugins:find_all({ api_id = session.api_id, name = OAUTH2 })[1]
  if not oauth2_plugin then
    oauth2_plugin, err = singletons.dao.plugins:find_all({ name = OAUTH2 })[1]
  end
  return oauth2_plugin
end

function _M.load_new_session_state(session)
  return session
end

function _M.load_provider(provider_name)
   local providers, err = singletons.dao.auth_providers:find_all({ name = provider_name })
   if err then
      return nil, err
    end
    return providers[1]
end

return _M
