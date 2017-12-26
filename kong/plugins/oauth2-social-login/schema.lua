local utils = require "kong.tools.utils"
local Errors = require "kong.dao.errors"

local function check_user(anonymous)
  if anonymous == "" or utils.is_valid_uuid(anonymous) then
    return true
  end

  return false, "the anonymous user must be empty or a valid uuid"
end

local function check_mandatory_scope(v, t)
  if v and not t.scopes then
    return false, "To set a mandatory scope you also need to create available scopes"
  end
  return true
end

return {
  no_consumer = true,
  fields = {
    provision_key = { required = true, unique = true, type = "string" },
    global_providers = { type = "array", required = false }
  }
}
