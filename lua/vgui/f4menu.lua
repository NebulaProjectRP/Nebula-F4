local PANEL = {}

function PANEL:Init()
    NebulaF4.Panel = self
    self:SetSize(ScrW(), ScrH())
    self:MakePopup()

    self:DockPadding(0, 0, 0, 0)

    self.Tabs = vgui.Create("nebula.tab", self)
    self.Tabs:Dock(TOP)
    self.Tabs:SetTall(48)
    self.Tabs:DockMargin(16, 16, 16, 16)

    self.Body = vgui.Create("Panel", self)
    self.Body:Dock(FILL)
    self.Body:DockMargin(32, 16, 32, 32)
    self.Tabs:SetContent(self.Body)

    self.Tabs:AddTab("Jobs", "nebula.f4.jobs")
    self.Tabs:AddTab("Inventory", "nebula.f4.inventory")
    self.Tabs:AddTab("Shop", "DPanel")
    self.Tabs:AddTab("Mining", "DPanel")

    self:SetAlpha(0)
    self:AlphaTo(255, .5, 0)
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(0, 0, 0, 240)
    surface.DrawRect(0, 0, w, h)
    self:DrawBlur( 3, 5 )
end

vgui.Register("nebula.f4", PANEL, "DFrame")

if IsValid(NebulaF4.Panel) then
    NebulaF4.Panel:Remove()
end

//vgui.Create("nebula.f4")
