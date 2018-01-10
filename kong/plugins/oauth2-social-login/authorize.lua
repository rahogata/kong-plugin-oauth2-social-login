local utils = require "kong.tools.utils"
local responses = require "kong.tools.responses"
local singletons = require "kong.singletons"
local public_utils = require "kong.tools.public"

local string_gmatch = string.gmatch
local req_get_headers = ngx.req.get_headers
local ngx_set_header = ngx.req.set_header

local _M = {}

local RESPONSE_TYPE = "response_type"
local STATE = "state"
local CODE = "code"
local SCOPE = "scope"
local CLIENT_ID = "client_id"
local CLIENT_SECRET = "client_secret"
local REDIRECT_URI = "redirect_uri"
local ERROR = "error"

local function load_oauth2_credential_by_client_id_into_memory(client_id)
  local credentials, err = singletons.dao.oauth2_credentials:find_all {client_id = client_id}
  if err then
    return nil, err
  end
  return credentials[1]
end

local function get_redirect_uri(client_id)
  local client, err
  if client_id then
    local credential_cache_key = singletons.dao.oauth2_credentials:cache_key(client_id)
    client, err = singletons.cache:get(credential_cache_key, nil,
                                       load_oauth2_credential_by_client_id_into_memory,
                                       client_id)
    if err then
      return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
    end
  end
  return client and client.redirect_uri or nil, client
end

local function retrieve_parameters()
  ngx.req.read_body()

  -- OAuth2 parameters could be in both the querystring or body
  return utils.table_merge(ngx.req.get_uri_args(), public_utils.get_body_args())
end

local function retrieve_scopes(parameters, conf)
  local scope = parameters[SCOPE]
  local scopes = {}
  if conf.scopes and scope then
    for v in scope:gmatch("%S+") do
      if not utils.table_contains(conf.scopes, v) then
        return false, {[ERROR] = "invalid_scope", error_description = "\"" .. v .. "\" is an invalid " .. SCOPE}
      else
        table.insert(scopes, v)
      end
    end
  end

  return true, scopes
end

local function load_provider_by_name(provider_name)
   local providers, err = singletons.dao.social_oauth2_providers:find_all({ name = provider_name })
   if err then
      return nil, err
    end
    return providers[1]
end

function _M.execute(conf)

  local response_params = {}
  local uri = ngx.var.uri
  local provider_names = string_gmatch(uri, "/oauth2/authorize/(%w+)")
  local provider_name
  for name in provider_names do
    provider_name = name
    break
  end
  local provider_cache_key = singletons.dao.social_oauth2_providers:cache_key(provider_name)
  local provider, err = singletons.cache:get(provider_cache_key, nil,
                                              load_provider_by_name,
                                              provider_name)
  if err then
    return responses.send_HTTP_BAD_REQUEST("No provider found.")
  end

  local parameters = retrieve_parameters()
  local response_type = parameters[RESPONSE_TYPE]
  if not response_type == CODE then
    response_params = {[ERROR] = "unsupported_response_type", error_description = "Invalid " .. RESPONSE_TYPE}
  end

-- Check client_id and redirect_uri
  allowed_redirect_uris, client = get_redirect_uri(parameters[CLIENT_ID])

  if not allowed_redirect_uris then
    response_params = {[ERROR] = "invalid_client", error_description = "Invalid client authentication" }
  else
    redirect_uri = parameters[REDIRECT_URI] and parameters[REDIRECT_URI] or allowed_redirect_uris[1]

    if not utils.table_contains(allowed_redirect_uris, redirect_uri) then
      response_params = {[ERROR] = "invalid_request", error_description = "Invalid " .. REDIRECT_URI .. " that does not match with any redirect_uri created with the application" }
    end
  end

  -- Check scopes
  local ok, scopes = retrieve_scopes(parameters, conf)
  if not ok then
    response_params = scopes -- If it's not ok, then this is the error message
  end

  if not response_params[ERROR] then
    local state = parameters[STATE] and parameters[STATE] .. "|" .. client_id or client_id
    local authorization_url = provider.authorization_uri .. "?response_type=code&client_id=" .. provider.client_id .. "&redirect_uri=" .. provider.callback_uri .. "&scope=" .. table.concat(provider.scopes, " ") .. "&state=" .. state
    return ngx.redirect(authorization_url)
  end

    -- Sending response in JSON format
  return responses.send(response_params[ERROR] and 400 or 200, response_params, {
    ["cache-control"] = "no-store",
    ["pragma"] = "no-cache"
  })
end


return _M
