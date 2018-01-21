local utils = require "kong.tools.utils"
local Errors = require "kong.dao.errors"

return {
  no_consumer = true,
  fields = {
    plugin_type = { required = false, type = "string", enum = { "AUTH_PLUGIN" }, default = "AUTH_PLUGIN" },
    provider_type = { required = false, type = "string", enum = { "SOCIAL" }, default = "SOCIAL" },
    callback_url = { type = "string", required = true },
    global_providers = { type = "boolean", required = false, default = false }
  }
}
