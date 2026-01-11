-- ESP PRO v3 Loader (Seliware Compatible)

local url = "https://raw.githubusercontent.com/jukree1145/ESP-PRO-V3/main/main.lua"

local req = (syn and syn.request) or http_request or request
if not req then
    warn("Your executor does not support HTTP requests")
    return
end

local response = req({
    Url = url,
    Method = "GET"
})

if not response or not response.Body then
    warn("Failed to load main.lua")
    return
end

loadstring(response.Body)()
