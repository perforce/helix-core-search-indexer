local curl = require "cURL.safe"

local initDone = false
local config = {}
 
-- Remove leading and trailing whitespace from a string.
 
function trim( s )
    return ( s:gsub( "^%s*(.-)%s*$", "%1" ) )
end

-- Read the configuration settings the first time.
-- Read the global config first, then the instance config. The latter could
-- override the former if there are duplicate variable names. This is assumed
-- to be a desirable feature.
function init()
    -- Uncomment for debugging
    -- print("Initializing...")
    if initDone == false then
        for k, v in pairs(Helix.Core.Server.GetGlobalConfigData()) do
            if string.len(trim(v)) > 0 then
                config[k] = trim(v)
            end
        end

        for k, v in pairs(Helix.Core.Server.GetInstanceConfigData()) do
            if string.len(trim(v)) > 0 then
                config[k] = trim(v)
            end
        end

        initDone = true
    end
end
 
function get(url)
    -- Uncomment for debugging
    -- print("Going to index: " .. url)

    local xAuthToken = config["auth_token"]
    headers = {
      "Accept: application/json",
      "X-Auth-Token: " .. xAuthToken
      }
    local c = curl.easy{
      url            = url,
      ssl_verifypeer = false,
      ssl_verifyhost = false,
      httpheader     = headers
    }
    local ok, err = c:perform()
    c:close()
    if not ok then
        return "Index request failed. Index url: " .. url
    end
    return "Index request sent. Index url: " .. url
end

function GlobalConfigFields()
    return {}
end

function InstanceConfigFields()
    return {}
end

function InstanceConfigEvents()
    return { ["change-commit"] = "//..." }
end

function ChangeCommit()
    init()
    local change = Helix.Core.Server.GetVar("change")
    local serverport = Helix.Core.Server.GetVar("serverport")
    local serveruser = Helix.Core.Server.GetVar("user")

    p4 = P4.P4:new()
    p4.port = serverport
    p4.user = serveruser

    p4:connect()
    local props = p4:run("property", "-l", "-nP4.P4Search.URL")
    local u = props[1]["value"]

    -- Uncomment for debugging
    -- print( "P4.P4Search.URL: " .. u)
    p4:disconnect()

    local status = get(u .. "/api/v1/index/change/" .. change)

    Helix.Core.Server.SetClientMsg(status)
    return true
end
