local PANEL = {}
local atlas = Material("nebularp/ui/f4shop.vmt")

local gwens = {}

for k = 0, 3 do 
    gwens[k + 1] = GWEN.CreateTextureNormal(k * 256, 0, 256, 360, atlas)
end

local tabs = {
    [1] = {
        Name = "Miscellaneous",
        Color = Color(255, 175, 50),
        Atlas = gwens[1],
        Sub = "Useful Equipment",
        Content = function()
            return DarkRPEntities
        end,
        Get = function(item)
            RunConsoleCommand("darkrp", item.cmd)
        end,
        Check = function(item)
            local ply = LocalPlayer()
            if istable(item.allowed) and not table.HasValue(item.allowed, ply:Team()) then return false end
            if item.customCheck and not item.customCheck(ply) then return false end
            local cost = price or item.getPrice and item.getPrice(ply, item.price) or item.price

            return ply:canAfford(cost)
        end
    },
    [2] = {
        Name = "Weapons",
        Color = Color(255, 50, 118),
        Atlas = gwens[4],
        Sub = "Acquire 'Protection'",
        Get = function(item)
            RunConsoleCommand("darkrp", "buy", item.name)
        end,
        Content = function()
            return CustomShipments
        end,
        Check = function(ship)
            local ply = LocalPlayer()
            if not (ship.separate or ship.noship) then return false end
            local cost = ship.pricesep
            if GAMEMODE.Config.restrictbuypistol and not table.HasValue(ship.allowed, ply:Team()) then return false end
            if ship.customCheck and not ship.customCheck(ply) then return false end

            return ply:canAfford(cost)
        end,
    },
    [3] = {
        Name = "Ammo",
        Color = Color(150, 218, 61),
        Atlas = gwens[3],
        Sub = "Ammo for your weapons",
        Content = function()
            return GAMEMODE.AmmoTypes
        end,
        Check = function(item)
            local ply = LocalPlayer()
            if item.customCheck and not item.customCheck(ply) then return false end
            local canbuy, suppress, message, price = hook.Call("canBuyAmmo", nil, ply, item)
            local cost = price or item.getPrice and item.getPrice(ply, item.price) or item.price

            if canbuy == false then return false end

            return ply:canAfford(cost)
        end,
        Get = function(item, amount)
            net.Start("NebulaRP.F4:Purchase")
            net.WriteUInt(item.id, 8)
            net.WriteUInt(amount, 12)
            net.SendToServer()
        end,
        IsAmmo = true
    },
    [4] = {
        Name = "Shipments",
        Color = Color(50, 156, 255),
        Atlas = gwens[2],
        Sub = "Manage your supplies",
        Get = function(item)
            RunConsoleCommand("darkrp", "buyshipment", item.name)
        end,
        Content = function()
            return CustomShipments
        end,
        Check = function(ship)
            local ply = LocalPlayer()
            if ship.noship then return false end
            if ship.allowed and not table.HasValue(ship.allowed, ply:Team()) then return false end
            if ship.customCheck and not ship.customCheck(ply) then return false end
            local canbuy, suppress, message, price = hook.Call("canBuyShipment", nil, ply, ship)
            local cost = price or ship.getPrice and ship.getPrice(ply, ship.price) or ship.price

            if canbuy == false then return false end

            return ply:canAfford(cost)
        end
    },
}

function PANEL:Init()
    self:Dock(FILL)
    self.CardHolder = vgui.Create("nebula.grid", self)
    self.CardHolder:Dock(FILL)
    self.CardHolder:SetGrid(4, 1)
    self.Pages = {}
    for k = 1, 4 do
        local btn = self:CreateButton(k, tabs[k])
        btn:SetPosGrid(k - 1, 0, k, 1)
    end
end

local idealWide = math.Clamp(ScrW() / 6, 200, (ScrW() / 1980) * 400)
function PANEL:PerformLayout(w, h)
    local mx = w * .03
    local maxWide = w - mx * 2
    local itemWide = maxWide / 4
    local itemMargin = (itemWide - idealWide) / 2

    for k, v in pairs(self.Pages) do
        //v:SetSize(idealWide, h * .8)
        //v:SetPos(mx + itemMargin * k * 1.5 + (idealWide * (k - 1)), h / 2 - v:GetTall() / 2 - 16)
    end
end

local lightWhite = Color(255, 255, 255, 25)
local darkpurple = Color(16, 0, 24, 240)
function PANEL:CreateButton(i, tab)
    local panel = vgui.Create("DButton", self.CardHolder)
    panel:SetText(tab.Name)
    panel:SetFont(NebulaUI:Font(28))
    panel:SetTextColor(color_white)
    panel:SetContentAlignment(8)

    panel.Content = vgui.Create("DPanel", panel)
    panel.Content:Dock(FILL)
    panel.Content:DockMargin(4, 34, 4, 24)
    panel.Content:SetMouseInputEnabled(false)
    panel.Content.Alpha = 0
    panel.Content.Paint = function(s, w, h)
        local hovered = panel.hovered
        draw.RoundedBox(8, 0, 0, w, h, lightWhite)
        draw.RoundedBox(8, 1, 1, w - 2, h - 2, darkpurple)

        s.Alpha = Lerp(FrameTime() * 4, s.Alpha or 0, hovered and 200 or 25)

        local sx = math.Clamp(w * .9, 300, 172)
        local sy = sx * 1.4
        tab.Atlas(w / 2 - sx / 2, h * .15 - h * .1 * (s.Alpha / 255), sx, sy, ColorAlpha(color_white, s.Alpha))

        draw.SimpleText("History:", NebulaUI:Font(24), w / 2, h * .1 + sy, ColorAlpha(color_white, s.Alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    panel.Paint = function(s, w, h)
        s.hovered = s:IsHovered() or s:IsChildHovered()
        draw.RoundedBox(8, 0, 0, w, h, lightWhite)
        draw.RoundedBox(8, 1, 1, w - 2, h - 2, ColorAlpha(tab.Color, s.hovered and 200 or 100))

        draw.SimpleText(tab.Sub, NebulaUI:Font(18), w / 2, h - 14, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    panel.Data = tab
    panel.DoClick = function(s)
        s:AlphaTo(0, 0.2, 0)
        self.ActiveStore = s.Data
        self:DoTransition(s)
    end
    table.insert(self.Pages, panel)

    return panel
end

PANEL.IsCompact = false
function PANEL:PerformLayout(w, h)
    if (w < ScrW() / 2 and not self.IsCompact) then
        self.IsCompact = true
        self.CardHolder:SetGrid(2, 2)
        self.Pages[1]:SetPosGrid(0, 0, 1, 1)
        self.Pages[2]:SetPosGrid(1, 0, 2, 1)
        self.Pages[3]:SetPosGrid(0, 1, 1, 2)
        self.Pages[4]:SetPosGrid(1, 1, 2, 2)
    elseif w >= ScrW() / 2 and self.IsCompact then
        self.IsCompact = false
        self.CardHolder:SetGrid(4, 1)
        self.Pages[1]:SetPosGrid(0, 0, 1, 1)
        self.Pages[2]:SetPosGrid(1, 0, 2, 1)
        self.Pages[3]:SetPosGrid(2, 0, 3, 1)
        self.Pages[4]:SetPosGrid(3, 0, 4, 1)
    end
end

function PANEL:DoTransition(panel)
    local tab = self.ActiveStore
    local sw, sh = self:GetSize()
    local x, y = panel:GetPos()
    local w, h = panel:GetSize()

    if IsValid(self.Store) then
        self.Store:Remove()
    end
    local pnl = vgui.Create("DPanel", self)
    pnl:SetSize(w, h)
    pnl:SetPos(x, y)
    pnl:MoveTo(0, 0, .2, 0, .5)
    pnl:SizeTo(sw, sh, .2, 0, .5, function(s)
        if not IsValid(pnl.Store) then return end
        pnl.Store:Initialize(tab, panel:GetText())
    end)
    pnl.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, lightWhite)
        draw.RoundedBox(8, 1, 1, w - 2, h - 2, tab.Color)

        draw.RoundedBox(8, 4, 34, w - 8, h - 24 - 34, lightWhite)
        draw.RoundedBox(8, 5, 35, w - 10, h - 24 - 35, darkpurple)
    end

    pnl.btnClose = vgui.Create("DButton", pnl)
    pnl.btnClose:Dock(TOP)
    pnl.btnClose:SetTall(32)
    pnl.btnClose:SetText("< " .. tab.Name)
    pnl.btnClose:SetTextColor(color_white)
    pnl.btnClose:SetFont(NebulaUI:Font(28))
    pnl.btnClose:SetTextInset(8, 2)
    pnl.btnClose:SetContentAlignment(7)

    pnl.Disposed = false
    pnl.btnClose.DoClick = function()
        if pnl.Disposed then return end
        pnl:SizeTo(w, h, .2, 0, .5)
        pnl:AlphaTo(0, .2, 0)
        panel:AlphaTo(255, .2, 0)
        pnl:MoveTo(x, y, .2, 0, .5, function()
            pnl:Remove()
        end)
    end
    pnl.btnClose.Paint = nil

    pnl.Search = vgui.Create("nebula.textentry", pnl.btnClose)
    pnl.Search:Dock(RIGHT)
    pnl.Search:SetWide(256)

    pnl.Search:DockMargin(2, 2, 4, 0)
    pnl.Search:SetPlaceholderText("Search...")
    pnl.Search.OnValueChange = function(s, val)
        pnl.Store:FillContent(val)
    end
    
    pnl.Store = vgui.Create("nebula.f4.shop:store", pnl)
    pnl.Store:Dock(FILL)
    pnl.Store.CategoryName = panel:GetText()
    pnl.Store:SetColor(tab.Color)
end

function PANEL:Paint(w, h)
end

vgui.Register("nebula.f4.shop", PANEL, "DPanel")

local STORE = {}
AccessorFunc(STORE, "m_cHeader", "Color")

function STORE:Init()
    self:DockMargin(8, 8, 8, 28)
    self.Categories = {}
    self.Items = {}
end

function STORE:FillContent(filter)
    for k, v in pairs(self.Categories) do
        v:Remove()
    end

    self.Categories = {}
    self.Items = {}

    for category, data in pairs(self.tempCategory) do
        local cat = vgui.Create("nebula.f4.category", self)
        cat:SetTitle(category)
        cat:SetColumns(3)
        cat:Dock(TOP)
        cat:DockMargin(0, 0, 0, 8)
        cat:SetAlpha(filter and 255 or 0)
        cat:SetHeaderColor(ColorAlpha(self:GetColor(), 100))

        for _, v in pairs(data) do
            if (filter and filter != "" and not string.find(string.lower(v.name), string.lower(filter))) then continue end
            if (v.allowed and not table.HasValue(v.allowed, LocalPlayer():Team())) then continue end
            if (v.vip and not LocalPlayer():isVIP()) then continue end
            local item = vgui.Create("nebula.f4.shop:item", cat)
            item:SetData(v, self.CategoryName)
            item.Buy.DoClick = function(s)
                if (self.check(v)) then
                    surface.PlaySound("buttons/button14.wav")
                    self.get(v, item.BulletsAmount)
                else
                    surface.PlaySound("player/suit_denydevice.wav")
                end
            end
            table.insert(self.Items, item)
        end

        if (#self.Items == 0) then
            cat:Remove()
            continue
        end

        table.insert(self.Categories, cat)
    end

    for k, v in pairs(self.Categories) do
        v:AlphaTo(255, .2, 0)
        v:UpdateLayout(v.IsToggled)
    end
end

function STORE:Initialize(tab, catName)
    self.tempCategory = {}
    for k, v in pairs(tab.Content()) do
        if (false and v.allowed and not table.HasValue(v.allowed, LocalPlayer():Team())) then
            continue
        end
        if not self.tempCategory[v.category] then
            self.tempCategory[v.category] = {}
        end

        table.insert(self.tempCategory[v.category], v)
    end

    self:FillContent()
    self.check = tab.Check
    self.get = tab.Get
    self.IsLoaded = true
end

function STORE:Paint(w, h)
    if (self.IsLoaded and #self.Categories == 0) then
        draw.SimpleText("We have no items for you at the moment.", NebulaUI:Font(32), w / 2, h / 2 - 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

vgui.Register("nebula.f4.shop:store", STORE, "nebula.scroll")

local ITEM = {}

function ITEM:Init()
    self:SetTall(96)
end

function ITEM:SetData(v, category)
    self.Title = Label(v.name, self)
    self.Title:Dock(FILL)
    self.Title:SetText(v.name)
    self.Title:SetContentAlignment(7)
    self.Title:SetTextInset(52, 0)
    self.Title:SetTextColor(color_white)
    self.Title:SetFont(NebulaUI:Font(ScrH() > 720 and 28 or 22))
    if (v.model) then
        self.Icon = vgui.Create("SpawnIcon", self)
        self.Icon:SetModel(v.model)
        self.Icon:SetMouseInputEnabled(false)
    end

    self.Buy = vgui.Create("nebula.button", self)

    if (category == "Ammo") then
        self.Amount = vgui.Create("nebula.textentry", self)
        self.Amount.textentry:SetNumeric(true)
        self.Amount.textentry:SetDrawLanguageID(false)
        self.Amount.textentry:SetText(v.amountGiven)
        self.Amount.OnValueChange = function(s, val)
            local num = tonumber(val)
            if not num or num < 1 or num > 2048 then
                s:SetText(v.amountGiven)
                self.Price = v.price
                return
            end

            self.Price = math.ceil(v.price * (num / v.amountGiven))
            self.BulletsAmount = num
        end
        self.BulletsAmount = v.amountGiven
    end
    self.Price = v.price
end

function ITEM:PerformLayout(w, h)
    if not IsValid(self.Icon) then return end
    self.Title:SetTextInset(h, 4)
    self.Icon:SetPos(8, 8)
    self.Icon:SetSize(h - 16, h - 16)

    self.Buy:SetSize(w - h - 4, 28)
    self.Buy:SetPos(h, h - 32)
    self.Buy:SetText("Purchase")

    if IsValid(self.Amount) then
        self.Amount:SetSize(64, 28)
        self.Amount:SetPos(w - 68, 4)
    end
end

function ITEM:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, lightWhite)
    draw.RoundedBox(8, 1, 1, w - 2, h - 2, darkpurple)

    draw.RoundedBox(8, 4, 4, h - 8, h - 8, lightWhite)
    draw.RoundedBox(8, 5, 5, h - 10, h - 10, darkpurple)

    surface.SetDrawColor(lightWhite)
    surface.DrawRect(h, 36, w - h - 4, 1)

    draw.SimpleText(DarkRP.formatMoney(self.Price), NebulaUI:Font(24), h, 38, LocalPlayer():canAfford(self.Price) and Color(137, 247, 101) or Color(255, 100, 0))
end


vgui.Register("nebula.f4.shop:item", ITEM, "DPanel")

if IsValid(NebulaF4.Panel) then
    NebulaF4.Panel:Remove()
end

//vgui.Create("nebula.f4")

