local utils = require "kong.tools.utils"
local url = require "socket.url"

local function validate_uris(v, t, column)
  if v then
    if #v < 1 then
      return false, "at least one URI is required"
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
  end
  return true, nil
end

local SOCIAL_OAUTH2_PROVIDERS = {
  primary_key = {"id"},
  table = "social_oauth2_providers",
  fields = {
    id = { type = "id", dao_insert_value = true },
    name = { type = "string", required = true },
    api_id = { type = "id", required = false, foreign = "apis:id" },
    client_id = { type = "string", required = true },
    client_secret = { type = "string", required = true },
    callback_uri = { type = "array", required = true, func = validate_uris },
    authorization_uri = { type = "string", required = true, func = validate_uris },
    token_uri = { type = "string", required = true, func = validate_uris },
    profile_uri = { type = "string", required = true, func = validate_uris },
    scopes = { type = "array", required = true },
    is_global = { type = "boolean", required = true, default = true },
    logo = { type = "string", required = false },
    created_at = { type = "timestamp", immutable = true, dao_insert_value = true }
  }
}

return {
  social_oauth2_providers = SOCIAL_OAUTH2_PROVIDERS
}
