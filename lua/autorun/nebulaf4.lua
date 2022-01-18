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

if CLIENT then return end
util.AddNetworkString("NebulaRP.F4Purchase")

net.Receive("NebulaRP.F4Purchase", function(l, ply)
    local ammoID = net.ReadUInt(8)
    local amount = net.ReadUInt(12)

    local ammo = GAMEMODE.AmmoTypes[ammoID]

    if (amount <= 0) then MsgN(amount) return end

    if (ammo && ply:canAfford(ammo.price * (amount / ammo.amountGiven))) then
        ply:addMoney(-math.ceil(ammo.price * (amount / ammo.amountGiven)))
        ply:SetAmmo(ply:GetAmmoCount(ammo.ammoType) + amount, ammo.ammoType)
        ply:EmitSound("items/ammo_pickup.wav")
    end
end)

timer.Create("cacheMaxMoney", 120, 0, function()
    local total = 0
    for k, v in pairs(player.GetAll()) do
        total = total + v:getDarkRPVar("money")
    end
    SetGlobalInt("GameTotalMoney", total)
end)