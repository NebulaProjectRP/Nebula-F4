local PANEL = {}

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
    self.Tabs:DockMargin(16, 16, 16, 16)

    local mx, my = 16, 16//self:GetWide() * .1, self:GetTall() * .1
    self.Body = vgui.Create("Panel", self)
    self.Body:Dock(FILL)
    self.Body:DockMargin(mx, my / 2, mx, my)
    self.Tabs:SetContent(self.Body)

    self.Tabs:AddTab("Inventory", "nebula.f4.inventory", true)
    self.Tabs:AddTab("Jobs", "nebula.f4.jobs", true)
    self.Tabs:AddTab("Shop", "nebula.f4.shop", true)
    self.Tabs:AddTab("Mining", "DPanel", true)
    
    self.Tabs:SelectTab(cookie.GetString("nebula_f4_tab", "Inventory"))

    self:SetAlpha(0)
    self:AlphaTo(255, .2, 0)

end

function PANEL:OnKeyCodePressed(btn)
    if (btn == KEY_F4) then
        DarkRP.closeF4Menu()
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, self.Dragging and 100 or 25))
    draw.RoundedBox(8, 1, 1, w - 2, h - 2, Color(16, 0, 24, 250))
end

vgui.Register("nebula.f4", PANEL, "nebula.frame")

