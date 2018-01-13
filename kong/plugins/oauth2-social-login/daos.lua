local url = require "socket.url"

local function validate_uri(v, t, column)
  local parsed_uri = url.parse(v)
  if not (parsed_uri and parsed_uri.host and parsed_uri.scheme) then
    return false, "cannot parse '" .. uri .. "'"
  end
  if parsed_uri.fragment ~= nil then
    return false, "fragment not allowed in '" .. uri .. "'"
  end
  return true, nil
end

local SOCIAL_OAUTH2_PROVIDERS = {
  primary_key = { "id" },
  table = "social_oauth2_providers",
  cache_key = { "name" },
  fields = {
    id = { type = "id", dao_insert_value = true },
    name = { type = "string", required = true, unique = true },
    client_id = { type = "string", required = true, unique = true },
    client_secret = { type = "string", required = true },
    authorization_uri = { type = "string", required = true, func = validate_uri },
    token_uri = { type = "string", required = true, func = validate_uri },
    profile_uri = { type = "string", required = true, func = validate_uri },
    scopes = { type = "array", required = true },
    logo = { type = "string", required = false },
    created_at = { type = "timestamp", immutable = true, dao_insert_value = true }
  }
}

return {
  social_oauth2_providers = SOCIAL_OAUTH2_PROVIDERS
}
