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
/*
    timer.Simple(3, function()
        DarkRP.openF4Menu()

        timer.Simple(1, function()
            DarkRP.closeF4Menu()
        end)
    end)
    */
end)

if CLIENT then return end
