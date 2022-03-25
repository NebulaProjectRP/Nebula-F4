local PANEL = {}
NebulaF4.LastTime = 0
function PANEL:Init()
    NebulaF4.Panel = self
    self:SetSize(ScrW() * .8, ScrH() * .8)
    //self:SetSize(ScrW(), ScrH())
    self:MakePopup()
    self:SetTitle("")
    self:Center()

    self:DockPadding(0, 0, 0, 0)

    self.Tabs = vgui.Create("nebula.tab", self)
    self.Tabs.OnTabSelected = function(s, tab, content)
        cookie.Set("nebula_f4_tab", tab:GetText())
    end
    self.Tabs:Dock(TOP)
    self.Tabs:SetTall(48)
    self.Tabs:DockMargin(16, 16, 16, 8)

    local mx, my = 16, 16//self:GetWide() * .1, self:GetTall() * .1
    self.Body = vgui.Create("Panel", self)
    self.Body:Dock(FILL)
    self.Body:DockMargin(mx, my / 2, mx, my)
    self.Tabs:SetContent(self.Body)

    self.Tabs:AddTab("Inventory", "nebula.f4.inventory", true):SetIcon(NebulaUI.Derma.F4[1]):SetColor(Color(0, 153, 255))
    self.Tabs:AddTab("Jobs", "nebula.f4.jobs", true):SetIcon(NebulaUI.Derma.F4[2]):SetColor(Color(57, 165, 36))
    self.Tabs:AddTab("Shop", "nebula.f4.shop", true):SetIcon(NebulaUI.Derma.F4[3]):SetColor(Color(253, 255, 108))
    self.Tabs:AddTab("Mining", "DPanel", true):SetIcon(NebulaUI.Derma.F4[4]):SetColor(Color(173, 63, 29))

    hook.Run("OnF4MenuCreated", self)
    
    self.Tabs:SelectTab(cookie.GetString("nebula_f4_tab", "Inventory"))

    self:SetAlpha(0)
    self:AlphaTo(255, .2, 0)

    if (IsValid(NebulaF4.Music)) then
        NebulaF4.LastTime = NebulaF4.Music:GetTime()
        NebulaF4.Music:Stop()
    end

    sound.PlayFile( "sound/nebularp/f4arcade.mp3", "noblock", function( station, errCode, errStr )
        if ( IsValid( station ) ) then
            station:Play()
            station:SetVolume(0)
            station:SetTime(NebulaF4.LastTime)
            station:EnableLooping(true)
            NebulaF4.Music = station
        else
            print( "Error playing sound!", errCode, errStr )
        end
    end )

    surface.PlaySound("nebularp/selectoption.mp3")
end

function PANEL:OnKeyCodePressed(btn)
    if (btn == KEY_F4) then
        surface.PlaySound("nebularp/selectoption.mp3")
        DarkRP.closeF4Menu()
    end
end

function PANEL:OnRemove()
    if (IsValid(NebulaF4.Music)) then
        hook.Add("Think", NebulaF4.Music, function(music)
            music:SetVolume(music:GetVolume() - FrameTime() * 2)
            if (music:GetVolume() <= 0.01) then
                NebulaF4.LastTime = music:GetTime()
                music:Stop()
                NebulaF4.Music = nil
            end
        end)
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, self.Dragging and 100 or 25))
    draw.RoundedBox(8, 1, 1, w - 2, h - 2, Color(16, 0, 24, 250))
    if (IsValid(NebulaF4.Music) and NebulaF4.Music:GetVolume() < .2) then
        NebulaF4.Music:SetVolume(NebulaF4.Music:GetVolume() + FrameTime() / 2)
    end
end

vgui.Register("nebula.f4", PANEL, "nebula.frame")

