local PANEL = {}
AccessorFunc(PANEL, "m_cHeaderColor", "HeaderColor")
AccessorFunc(PANEL, "m_iColumns", "Columns", FORCE_NUMBER)
AccessorFunc(PANEL, "m_sCookie", "Cookie", FORCE_STRING)

function PANEL:Init()

    self.Items = {}
    self:SetColumns(2)
    self:SetHeaderColor(Color(185, 22, 85))
    self:SetCookie("")

    self.Header = vgui.Create("DButton", self)
    self.Header:Dock(TOP)
    self.Header:SetText("")
    self.Header:SetTall(24)
    self.Header:SetFont(NebulaUI:Font(20))
    self.Header:SetTextColor(color_white)
    self.Header:SetContentAlignment(4)
    self.Header:SetTextInset(8, 0)

    self.Header.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 50))
        draw.RoundedBox(4, 1, 1, w - 2, h - 2, self:GetHeaderColor())

        draw.SimpleText(self.IsToggled and "[ - ]" or "[ + ]", NebulaUI:Font(20), w - 4, 10, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    self.Header.DoClick = function()
        self:UpdateLayout()
    end
end

function PANEL:OnChildRemoved(child)
    table.RemoveByValue(self.Items, child)
    self:InvalidateLayout(true)
end

function PANEL:SetCookie(id)
    self.m_sCookie = id
    local shouldBeOff = cookie.GetNumber("category." .. id, 0) == 0
    if (shouldBeOff) then
        self:UpdateLayout(false)
    end
end

function PANEL:OnChildAdded(pnl)
    table.insert(self.Items, pnl)
    self:SetVisible(self.IsToggled)
    
end

function PANEL:PerformLayout(w, h)
    if (self.norelayout) then return end
    if (#self.Items == 0) then return end
    local column = 0
    local counter = -1
    local lineHeight = 0
    local itemWide = (w - 16) / self:GetColumns()
    for k = 1, #self.Items do
        counter = counter + 1
        local item = self.Items[k]
        if (counter >= self:GetColumns()) then
            column = column + 1
            counter = 0
            lineHeight = lineHeight + item:GetTall() + 4
        end
        item:SetPos(counter * (itemWide + 6) + 6, 28 + lineHeight)
        item:SetWide(itemWide)
    end

    self.TotalHeight = lineHeight + 32 + self.Items[1]:GetTall()
    //MsgN("Performing layout for ", self.Header:GetText(), " result: ", self.TotalHeight)
end

function PANEL:UpdateLayout(b)
    self.IsToggled = (b != nil) and b or not self.IsToggled
    for k, v in pairs(self.Items) do
        v:SetVisible(self.IsToggled)
    end

    if not self.TotalHeight then
        self:InvalidateLayout(true)
    end
    self.norelayout = true
    self:SetTall(self.IsToggled and self.TotalHeight or 32)
    self:InvalidateParent(true)
    self.norelayout = false

    if (self:GetCookie() != "") then
        cookie.Set("category." .. self:GetCookie(), self.IsToggled and 1 or 0)
    end

end

function PANEL:SetText(text)
    self.Header:SetText(text)
end

PANEL.SetTitle = PANEL.SetText

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 25))
    draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(42, 36, 42, 200))

    DisableClipping(true)
    draw.SimpleText(tostring(self.IsToggled) ,NebulaUI:Font(16), -8, h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    DisableClipping(false)
end

vgui.Register("nebula.f4.category", PANEL, "DPanel")

if IsValid(NebulaF4.Panel) then
    NebulaF4.Panel:Remove()
end

vgui.Create("nebula.f4")

