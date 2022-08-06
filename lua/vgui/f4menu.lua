local PANEL = {}
NebulaF4.LastTime = 0

local music = CreateClientConVar("nebula_f4music", "1", true, false)

function PANEL:Init()
    NebulaF4.Panel = self
    self:SetSize(math.max(ScrW() * .85, 1200), ScrH() * .85)
    //self:SetSize(ScrW(), ScrH())
    self:MakePopup()
    self:SetTitle("")
    self:Center()

    self:DockPadding(0, 0, 0, 0)

    self.Tabs = vgui.Create("nebula.tab", self)

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
    self.Tabs:AddTab("Supplies", "nebula.f4.shop", true):SetIcon(NebulaUI.Derma.F4[6]):SetColor(Color(226, 108, 255))
    self.Tabs:AddTab("Mining", "nebula.f4.mining", true):SetIcon(NebulaUI.Derma.F4[4]):SetColor(Color(173, 63, 29))

    hook.Run("OnF4MenuCreated", self)
    
    self.Tabs:SelectTab(cookie.GetString("nebula_f4_tab", "Inventory"))

    self.Tabs.OnTabSelected = function(s, tab, content)
        cookie.Set("nebula_f4_tab", tab:GetText())
    end

    self:SetAlpha(0)
    self:AlphaTo(255, .2, 0)

    if (IsValid(NebulaF4.Music)) then
        NebulaF4.LastTime = NebulaF4.Music:GetTime()
        NebulaF4.Music:Stop()
    end

    if (music:GetBool()) then
        self:SpawnMusic()
    end

    self.musicOption = vgui.Create("DButton", self)
    self.musicOption:SetText("")
    self.musicOption:SetSize(28, 28)
    self.musicOption:SetZPos(999)
    self.musicOption.DoClick = function()
        music:SetBool(!music:GetBool())

        if (music:GetBool()) then
            self:SpawnMusic()
        else
            if (IsValid(NebulaF4.Music)) then
                NebulaF4.Music:Stop()
            end
        end
    end

    self.musicOption.Paint = function(s, w, h)
        local size = h * (s:IsHovered() and .9 or .8)
        NebulaUI.Derma.InventorySub[music:GetBool() and 5 or 6](w / 2 - size / 2, h / 2 - size / 2 + 2, size, size, Color(255, 255, 255, s:IsHovered() and 255 or 150))
    end
    surface.PlaySound("nebularp/selectoption.mp3")
end

function PANEL:SpawnMusic()
    sound.PlayFile( "sound/nebularp/f4arcade.mp3", "noblock", function( station, errCode, errStr )
        if ( IsValid( station ) ) then
            station:Play()
            station:SetVolume(0)
            station:SetTime(NebulaF4.LastTime)
            station:EnableLooping(true)
            NebulaF4.Music = station
        end
    end )
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

function PANEL:PerformLayout(w, h)
    self.lblTitle:SetSize(w - 32, 28)
    self.lblTitle:SetPos(8, 2)

    self.btnClose:SetSize(28, 28)
    self.btnClose:SetPos(w - 32, 2)
    self.btnClose:SetZPos(999)

    if (IsValid(self.musicOption)) then
        self.musicOption:SetPos(w - 32 - 28, 2)
    end
end

vgui.Register("nebula.f4", PANEL, "nebula.frame")

