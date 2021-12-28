local PANEL = {}

function PANEL:Init()
    self:SetGrid(20, 10)
end

function PANEL:Paint(w, h)
end

vgui.Register("nebula.f4.jobs", PANEL, "nebula.grid")