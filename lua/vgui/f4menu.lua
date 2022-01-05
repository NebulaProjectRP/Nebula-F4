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
    self.Tabs:Dock(TOP)
    self.Tabs:SetTall(48)
    self.Tabs:DockMargin(16, 16, 16, 16)

    local mx, my = 16, 16//self:GetWide() * .1, self:GetTall() * .1
    self.Body = vgui.Create("Panel", self)
    self.Body:Dock(FILL)
    self.Body:DockMargin(mx, my / 2, mx, my)
    self.Tabs:SetContent(self.Body)

    self.Tabs:AddTab("Inventory", "nebula.f4.inventory")
    self.Tabs:AddTab("Jobs", "nebula.f4.jobs")
    self.Tabs:AddTab("Shop", "DPanel")
    self.Tabs:AddTab("Mining", "DPanel")

    self:SetAlpha(0)
    self:AlphaTo(255, .5, 0)

    hook.Add("HUDShouldDraw", self, function()
        return false
    end)
end
/*
function PANEL:Paint(w, h)
    //draw.RoundedBox(8, 0, 0, w, h, Color(27, 13, 31, 255))
    //surface.SetDrawColor(0, 0, 0, 240)
    //surface.DrawRect(0, 0, w, h)
    //self:DrawBlur( 3, 5 )
end
*/
vgui.Register("nebula.f4", PANEL, "nebula.frame")
