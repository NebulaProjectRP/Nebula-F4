NebulaF4 = {}

AddCSLuaFile("f4/meta.lua")
include("f4/meta.lua")

for k, v in pairs(file.Find("f4/pages/*.lua", "LUA")) do
    if CLIENT then
        include("f4/pages/" .. v)
    else
        AddCSLuaFile("f4/pages/" .. v)
    end
end

MsgC(Color(0, 255, 0), "[F4Menu]", color_white, " Loaded!\n")

if SERVER then

timer.Create("cacheMaxMoney", 120, 0, function()
    local total = 0
    for k, v in pairs(player.GetAll()) do
        total = total + v:getDarkRPVar("money")
    end
    SetGlobalInt("GameTotalMoney", total)
end)

end