local PANEL = {}
AccessorFunc(PANEL, "m_cHeaderColor", "HeaderColor", FORCE_COLOR)
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
    self.Header:SetContentAlignment(4)
    self.Header:SetTextInset(8, 0)

    self.Header.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 50))
        draw.RoundedBox(4, 1, 1, w - 2, h - 2, self:GetHeaderColor())

        draw.SimpleText(self.IsToggled and "[-]" or "[+]", NebulaUI:Font(20), w - 18, h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    self.Header.DoClick = function()
        self:UpdateLayout()
    end
end

function PANEL:OnChildRemoved(child)
    table.RemoveByValue(self.Items, child)
    self:InvalidateLayout(true)
end

function PANEL:OnChildAdded(pnl)
    table.insert(self.Items, pnl)
    self:SetVisible(self.IsToggled)
    self:InvalidateLayout(true)
end

function PANEL:PerformLayout(w, h)
    if (self.norelayout) then return end
    local column = 0
    local counter = 0
    local lineHeight = 0
    local itemWide = (w - 8) / self:GetColumns()
    for k = 1, #self.Items do
        counter = counter + 1
        local item = self.Items[k]
        if (counter >= self:GetColumns()) then
            column = column + 1
            counter = 0
            lineHeight = lineHeight + item:GetTall() + 4
        end
        item:SetPos(counter * itemWide + 4, 28 + lineHeight)
        item:SetWide(itemWide)
    end

    self.TotalHeight = lineHeight + 32
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
    self:SetTall(self.TotalHeight)
    self:InvalidateParent(true)
    self.norelayout = false

    if (self:GetCookie() != "") then
        cookie.Set("category." .. self:GetCookie(), self.IsToggled and 1 or 0)
    end
end

function PANEL:SetText(text)
    self.Header:SetText(text)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 25))
    draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(42, 36, 42, 200))
end

vgui.Register("nebula.f4.category", PANEL, "DPanel")