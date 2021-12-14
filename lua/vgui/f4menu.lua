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

    self.Body = vgui.Create("DPanel", self)
    self.Body:Dock(FILL)
    self.Body:DockMargin(32, 16, 32, 32)
    self.Tabs:SetContent(self.Body)

    self.Tabs:AddTab("Jobs", "DPanel")
    self.Tabs:AddTab("Inventory", "DPanel")
    self.Tabs:AddTab("Shop", "DPanel")
    self.Tabs:AddTab("Mining", "DPanel")

end

vgui.Register("nebula.f4", PANEL, "DFrame")

if IsValid(NebulaF4.Panel) then
    NebulaF4.Panel:Remove()
end

//vgui.Create("nebula.f4")
