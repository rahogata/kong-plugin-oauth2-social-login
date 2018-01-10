local utils = require "kong.tools.utils"
local Errors = require "kong.dao.errors"

local function check_user(anonymous)
  if anonymous == "" or utils.is_valid_uuid(anonymous) then
    return true
  end

  return false, "the anonymous user must be empty or a valid uuid"
end

return {
  no_consumer = true,
  fields = {
    scopes = { required = true, type = "array" },
    provision_key = { required = true, unique = true, type = "string" },
    anonymous = { required = false, type = "string", default = "", func = check_user }
  }
}
