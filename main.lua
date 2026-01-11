local req = syn.request
local r = req({
    Url = "https://raw.githubusercontent.com/jukree1145/ESP-PRO-V3/main/main.lua",
    Method = "GET"
})
loadstring(r.Body)()
