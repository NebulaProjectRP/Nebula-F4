if SERVER then
    
util.AddNetworkString("F4.Magic")

net.Receive("F4.Magic", function(l, ply)
    local b = net.ReadBool()
    ply:SetNWBool("IsDoingMagic", b)
end)

net.Receive("NebulaRP.F4:RemoveEntity", function(l, ply)
    local id = net.ReadString()
    for k, v in pairs(ents.FindByClass(id)) do
        if (v.Getowning_ent && v:Getowning_ent() == ply) then
            v:Remove()
            break
        end
    end
end)

return

end
timer.Simple(0, function()
    function DarkRP.openF4Menu()
        if (isClosing) then return end
        if IsValid(NebulaF4.Panel) then
            NebulaF4.Panel:Remove()
            NebulaF4.Panel = nil
        end

        local disallow = hook.Run("F4MenuOpen")
        if (disallow == false) then return end
        NebulaF4.Panel = vgui.Create("nebula.f4")
        gui.InternalMousePressed(MOUSE_LEFT)
        net.Start("F4.Magic")
        net.WriteBool(true)
        net.SendToServer()
        hook.Add("CreateMove", NebulaF4.Panel, function(s, cmd) end) --            cmd:ClearMovement()
    end

    local isClosing = false
    function DarkRP.closeF4Menu()
        if IsValid(NebulaF4.Panel) and not isClosing then
            isClosing = true
            NebulaF4.Panel:AlphaTo(0, .1, 0, function()
                isClosing = false
                NebulaF4.Panel:Remove()
                NebulaF4.Panel = nil
            end)
            net.Start("F4.Magic")
            net.WriteBool(false)
            net.SendToServer()
        end
    end

    function DarkRP.toggleF4Menu()

        net.Start("F4.Magic")
        net.WriteBool(not IsValid(NebulaF4.Panel))
        net.SendToServer()

        if !IsValid(NebulaF4.Panel) then
            DarkRP.openF4Menu()
        else
            DarkRP.closeF4Menu()
        end
    end

    GAMEMODE.ShowSpare2 = DarkRP.toggleF4Menu
end)

if CLIENT then
    local text = surface.GetTextureID("nebularp/ui/f4holo")

    hook.Add("PostPlayerDraw", "MagicView", function(ply)
        if (ply:InArena()) then return end

        if (ply:Alive() and ply:GetNWBool("IsDoingMagic", false)) then
            local att = ply:LookupAttachment("eyes") ~= -1 and ply:GetAttachment(ply:LookupAttachment("eyes")) or {
                Pos = ply:GetPos() + Vector(0, 0, 60),
                Ang = ply:GetAngles()
            }

            local pos = att.Pos + att.Ang:Forward() * 22 - att.Ang:Right() * 0 + att.Ang:Up() * 4
            local ang = att.Ang
            ang:RotateAroundAxis(ang:Forward(), 90)
            ang:RotateAroundAxis(ang:Right(), 90)
            render.SetMaterial(Material("trails/physbeam"))
            render.DrawBeam(att.Pos + Vector(0, 0, 0), pos + ang:Forward() * 19 + ang:Right() * .5, 1 + (math.tan(RealTime() * 4) * 2) % 2, RealTime() % 1, RealTime() % 1 - 1, Color(255, 255, 255, 35))
            render.DrawBeam(att.Pos + Vector(0, 0, 0), pos - ang:Forward() * 19 + ang:Right() * .5, 1 + (math.tan(RealTime() * 4) * 2) % 2, RealTime() % 1, RealTime() % 1 - 1, Color(255, 255, 255, 35))
            render.DrawBeam(att.Pos + Vector(0, 0, 0), pos + ang:Forward() * 19 + ang:Right() * 19, 1 + (math.tan(RealTime() * 4) * 2) % 2, RealTime() % 1, RealTime() % 1 - 1, Color(255, 255, 255, 35))
            render.DrawBeam(att.Pos + Vector(0, 0, 0), pos - ang:Forward() * 19 + ang:Right() * 19, 1 + (math.tan(RealTime() * 4) * 2) % 2, RealTime() % 1, RealTime() % 1 - 1, Color(255, 255, 255, 35))
            surface.SetDrawColor(Color(255, 255, 255, 255 + math.tan(RealTime() * 16)))
            surface.SetTexture(text)
            cam.Start3D2D(pos, ang, 0.075)
            surface.DrawTexturedRectUV(-256, 0, 512, 256, -0, -0, 1, .492)
            cam.End3D2D()
            ang:RotateAroundAxis(ang:Right(), 180)
            cam.Start3D2D(pos, ang, 0.075)
            surface.DrawTexturedRectUV(-256, 0, 512, 256, 0, .506, 1, 1)
            cam.End3D2D()
        end
    end)

    hook.Add("CalcMainActivity", "MagicAnimation", function(ply, vel)
        if (ply:InArena()) then return end
        if (ply:GetNWBool("IsDoingMagic", false)) then return ACT_HL2MP_RUN_MAGIC, -1 end
    end)
end
