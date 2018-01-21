local responses = require "kong.tools.responses"
local singletons = require "kong.singletons"
local provider_utils = require "kong.plugins.auth-providers-util.utils"

local string_match = string.match
local string_gmatch = string.gmatch

local STATE = "state"
local CODE = "code"
local OAUTH2 ="oauth2"
local ERROR = "error"
local ACCESS_DENIED = "access_denied"
local SERVER_ERROR = "server_error"

local _M = {}

local function invalidate_session(parameters)
  singletons.cache:invalidate(parameters[STATE])
end

function _M.execute(conf)
  local parameters = provider_utils.retrieve_parameters()
  if parameters[STATE] then
    local state, err = singletons.cache:get(parameters[STATE], nil,
    									provider_utils.load_new_session_state,
    									nil)
    if err then
      return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
    end

    if state then
      local query
      if parameters[CODE] then
        local plugin_cache_key = singletons.dao.plugins:cache_key(OAUTH2)
        local oauth2_plugin, err = singletons.cache:get(plugin_cache_key, nil,
  													provider_utils.load_oauth2_plugin_into_memory,
  													state)
        if err or not oauth2_plugin then
          invalidate_session(parameters)
          return ngx.redirect(state.redirect_url .. "?error=" .. SERVER_ERROR .. (state.client_state and "&state=" .. state.client_state or ""))
        end

        local api_id
        if not oauth2_plugin.config.global_credentials then
          api_id = state.api_id
        end
        local authorization_code, err = singletons.dao.oauth2_authorization_codes:insert({
              api_id = api_id,
              credential_id = state.client_id,
              authenticated_userid = parameters[CODE],
              scope = table.concat(state.scopes, " ")
             }, {ttl = 300})

        if err then
          query = "error=" .. SERVER_ERROR
        else
          query = "code=" .. authorization_code.code
        end
      else
        query = "error=" .. ACCESS_DENIED
      end
      invalidate_session(parameters)
      return ngx.redirect(state.redirect_url .. "?" .. query .. (state.client_state and "&state=" .. state.client_state or ""))
    end
  end
  return responses.send_HTTP_BAD_REQUEST({ [ERROR] = "access_denied" })
end

return _M
