local PANEL = {}

local sortModes = {
    ["Name"] = function(a, b)
        return b.name > a.name
    end,
    ["Salary"] = function(a, b)
        return a.salary > b.salary
    end,
    ["Vacancy"] = function(a, b)
        return #team.GetPlayers(b.team) > #team.GetPlayers(a.team)
    end,
}

local jobPanel
local randomSeqs = {
    "seq_baton_swing",
    "seq_cower",
    "seq_meleeattack01",
    "seq_throw",
}
function PANEL:Init()
    self:SetGrid(20, 10)
	self.LastPaint = 0
    self:Dock(FILL)

    jobPanel = self

    self.Footer = vgui.Create("Panel", self)
    self.Footer:Dock(BOTTOM)
    self.Footer:SetTall(48)
    self.Footer:DockMargin(0, 16, 0, 0)
    self.Footer.Paint = function(s, w, h)
        self:DrawFooter(w, h)
    end

    self.Preview = vgui.Create("nebula.modelpanel", self)
    self.Preview:Dock(RIGHT)
    self.Preview:SetWide(256)
    self.Preview:SetCrop(false)
    self.Preview.LayoutEntity = function(s, ent)
        ent:FrameAdvance( ( RealTime() - self.LastPaint ) )
        self:ManipulateModel(ent)
    end
    self.Preview:SetFOV(28)
    self.Preview:DockMargin(16, 0, 0, 0)
    self.Preview.OnMousePressed = function(s, key)
        if key == MOUSE_LEFT then
            local ent = self.Preview:GetEntity()
            local seq = ent:LookupSequence(randomSeqs[math.random(1, #randomSeqs)])
            ent:SetSequence(seq)
            timer.Simple(ent:SequenceDuration(seq), function()
                if IsValid(ent) then
                    ent:ResetSequence(ent:LookupSequence("idle_all_01"))
                end
            end)
        end
    end
    self.Preview.PaintOver = function(s, w, h)
        if (self.mk) then
            self.mk:Draw(8, h - 40, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        end
    end

    self.DoJoin = vgui.Create("nebula.button", self.Preview)
    self.DoJoin:Dock(BOTTOM)
    self.DoJoin:SetText("Join")
    self.DoJoin:SetTall(32)
    self.DoJoin.DoClick = function(s)
        if self.Selected.vote then
            RunConsoleCommand("darkrp", "vote" .. self.Selected.command)
        else
            RunConsoleCommand("darkrp", self.Selected.command)
        end

        s:SetText("Joined!")
    end

    local header = vgui.Create("Panel", self)
    header:Dock(TOP)
    header:SetTall(32)

    self.OrderBy = vgui.Create("nebula.combobox", header)
    self.OrderBy:Dock(LEFT)
    self.OrderBy:SetWide(128)
    self.OrderBy:SetText("Sort by:")
    self.OrderBy:DockMargin(0, 0, 16, 0)
    self.OrderBy.OnSelect = function(s, index, value)
        self:FillJobs()
    end
    for k, v in pairs(sortModes) do
        self.OrderBy:AddChoice(k)
    end

    self.Header = vgui.Create("nebula.textentry", header)
    self.Header:SetPlaceholderText("Search job...")
    self.Header:Dock(FILL)
    self.Header:SetTall(32)
    self.Header.textentry:SetUpdateOnType(true)
    self.Header.OnValueChange = function()
        self:FillJobs()
    end

    self.Content = vgui.Create("nebula.scroll", self)
    self.Content:Dock(FILL)
    self.Content:DockMargin(0, 16, 0, 0)

    self.Categories = {}

    self.NoStarted = true
    self:FillJobs()
end

function PANEL:DrawFooter(w, h)
    draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 10))
    draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(16, 0, 24, 250))

    local padding = 0

    local tx, _ = draw.SimpleText(DarkRP.formatMoney(LocalPlayer():getDarkRPVar("money")), NebulaUI:Font(34, true), 8, h / 2, Color(71, 199, 103), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    local bx, _ = draw.SimpleText(DarkRP.formatMoney(LocalPlayer():getDarkRPVar("salary")), NebulaUI:Font(24), 12 + tx, h - 8, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

    padding = padding + tx + bx + 64 + 8

    local totalMoney = GetGlobalInt("GameTotalMoney", LocalPlayer():getDarkRPVar("money"))
    draw.SimpleText("Money in the city:", NebulaUI:Font(20), padding, 4, Color(136, 136, 136), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    local cx, _ = draw.SimpleText(DarkRP.formatMoney(totalMoney), NebulaUI:Font(24), padding, h / 2 + 6, Color(71, 199, 103), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("(" .. math.Round(math.Clamp(LocalPlayer():getDarkRPVar("money") / totalMoney, 0, 1) * 100, 3) .. "%)", NebulaUI:Font(18), 8 + tx + bx + 64 + cx + 4, h / 2 + 8, Color(201, 201, 201), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    padding = padding + cx + 64 + 42

    local dx, _ = draw.SimpleText("Players online:", NebulaUI:Font(20), w - 8, 4, Color(136, 136, 136), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    draw.SimpleText(player.GetCount() .. "/" .. game.MaxPlayers(), NebulaUI:Font(24), w - 8, h / 2 + 8, Color(201, 201, 201), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

    draw.SimpleText("Job Distribution:", NebulaUI:Font(20), padding, 4, Color(136, 136, 136), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.RoundedBox(4, padding, h / 2 + 2, w - padding - 8 - dx - 16, 16, Color(255, 255, 255, 25))

    local data = {}
    for k, v in pairs(player.GetAll()) do
        data[v:Team()] = (data[v:Team()] or 0) + 1
    end

    local pad = 0
    for k, v in pairs(data) do
        local size = v / player.GetCount() * (w - padding - 8 - dx - 16) - 2
        draw.RoundedBox(4, padding + 1 + pad, h / 2 + 3, size, 14, team.GetColor(k))
        pad = pad + size + 2
    end
    
end

function PANEL:ManipulateModel(ent)
    local my = -.4 + gui.MouseY() / ScrH()
    local mx = -.5 + gui.MouseX() / ScrW()
    ent:SetEyeTarget(Vector(0, 0, 60 - my * 40))

    local boneID = ent:LookupBone("ValveBiped.Bip01_Head1")
    if (boneID) then
        ent:ManipulateBoneAngles(boneID, Angle(0, -20 -my * 20, -25 + mx * 20))
    end
end

function searchJobs(query, categories)
    local found = {}

    for _, cat in pairs(categories) do
        for _, job in pairs(cat.members) do
            if string.find(string.lower(job.name), string.lower(query)) then
                local cc = table.Copy(cat)
                cc.members = { job }
                table.insert(found, cc)
            end
        end
    end

    return found
end

function PANEL:FillJobs()
    local categories = table.Copy(DarkRP:getCategories().jobs)
    local query = self.Header:GetText()
    local orderBy = self.OrderBy:GetSelected()

    if (query ~= "") then
        categories = searchJobs(query, categories)
    end

    if (sortModes[orderBy]) then
        for _, cat in pairs(categories) do
            table.sort(cat.members, sortModes[orderBy])
        end
    end

    for k, v in pairs(self.Categories) do
        v:Remove()
    end

    self.Categories = {}
    
    for _, cat in pairs(categories) do
        local cantSee = table.IsEmpty(cat.members) or isfunction(cat.canSee) and not cat.canSee(LocalPlayer())

        if (cantSee) then continue end

        if not IsValid(self.Categories[cat.name]) then
            local category = vgui.Create("nebula.f4.category", self.Content)
            category:SetTitle(cat.name)
            category:SetColumns(2)
            category:Dock(TOP)
            category:DockMargin(0, 0, 0, 8)
            category:SetHeaderColor(cat.color)
            self.Categories[cat.name] = category
        end
        
        for _, v in pairs(cat.members) do
            local job = vgui.Create("nebula.f4.job.item", self.Categories[cat.name])
            job:SetJob(v)
            job.DoClick = function(s)
                self.Selected = s
                self:PreviewJob(v)
            end

            if (self.NoStarted and v.team == LocalPlayer():Team()) then
                self.NoStarted = nil
                job:DoClick()
            end
        end
    end

    for k, v in pairs(self.Categories) do
        v:UpdateLayout(v.IsToggled)
    end
end

surface.CreateFont("F4.Description", {
    font = "Montserrat Medium",
    size = 20,
    shadow = true
})

function PANEL:PreviewJob(data)
    local mdl = istable(data.model) and DarkRP.getPreferredJobModel(data.team) or data.model
    if istable(mdl) then
        mdl = mdl[1]
    end
    self.Preview:SetModel(mdl)
    self.Selected = data
    self.mk = markup.Parse("<font=F4.Description>" .. data.description .. "<font>", self.Preview:GetWide() - 16)
    self.DoJoin:SetText(data.team == LocalPlayer():Team() and "You're already in this job" or "Join this job")
    local ent = self.Preview:GetEntity()
    local att = ent:LookupAttachment("eyes")
    if (att) then
        local attach = ent:GetAttachment(att)
        if (attach) then
            local ang = attach.Ang
            local targetZ = attach.Pos.z / 1.5
            self.Preview:SetCamPos(attach.Pos + ang:Forward() * 65 + ang:Right() * -24 - Vector(0, 0, targetZ / 2))
            self.Preview:SetLookAt(Vector(attach.Pos.x, attach.Pos.y, targetZ * .8))
        end
    end
end

function PANEL:Paint(w, h)
end

vgui.Register("nebula.f4.jobs", PANEL, "nebula.grid")

local gru = surface.GetTextureID("vgui/gradient-u")
local grl = surface.GetTextureID("vgui/gradient-l")
local grr = surface.GetTextureID("vgui/gradient-r")

local iconsAtlas = Material("nebularp/ui/f4icons.vmt")
local icons = {
    full = GWEN.CreateTextureNormal(0, 0, 32, 64, iconsAtlas),
    empty = GWEN.CreateTextureNormal(32, 0, 32, 64, iconsAtlas),
    coin = GWEN.CreateTextureNormal(64, 0, 32, 64, iconsAtlas),
}

local JOB = {}

function JOB:Init()
    self:SetTall(48)
    self:SetFont(NebulaUI:Font(22))
    self:SetContentAlignment(7)
    self:SetTextInset(52, 0)
    self:SetTextColor(Color(200, 200, 200))
end

function JOB:SetJob(job)
    self.job = job
    self.BarColor = job.color
    self:SetText(job.name)

    self.Icon = vgui.Create("SpawnIcon", self)
    if (isstring(job.model)) then
        self.Icon:SetModel(job.model)
    else
        self.Icon:SetModel(DarkRP.getPreferredJobModel(job.team) or job.model[1])
    end
    self.Icon:DockMargin(4, 4, 4, 4)
    self.Icon:SetMouseInputEnabled(false)
    self.Icon:Dock(LEFT)
    self.Icon:SetWide(42)
end

function JOB:Paint(w, h)
    if (self.Hovered or jobPanel.Selected == self) then
        draw.RoundedBox(4, 0, 0, w, h, Color(16, 0, 24, 200))
    else
        draw.RoundedBox(4, 0, 0, w, h, Color(16, 0, 24, 150))
    end
    
    draw.RoundedBox(4, 2, 2, 44, 44, Color(255, 255, 255, 25))
    draw.RoundedBox(4, 3, 3, 42, 42, Color(34, 18, 44, 187))

    surface.SetDrawColor(self.BarColor)
    surface.SetTexture(grl)
    surface.DrawTexturedRect(52, 22, w - 64, 2)

    local count = #team.GetPlayers(self.job.team)
    
    if (self.job.max == 0) then
        for k = 1, math.min(count, 16) do
            icons.full(52 + 12 * k - 12, h - 22, 10, 20, Color(255, 255, 255))
        end
    else
        local limit = self.job.max < 1 and self.job.max * player.GetCount() or self.job.max
        for k = 1, limit do
            icons[k > count and "empty" or "full"](52 + (k - 1) * 12, h - 20, 10, 16, Color(255, 255, 255))
        end
    end
end

vgui.Register("nebula.f4.job.item", JOB, "DButton")
