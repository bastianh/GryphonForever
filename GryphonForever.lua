-- GryphonForever: a standalone, movable backdrop made from Blizzard's modern action bar art
-- (gryphon / wyvern caps, frame border, slot backgrounds, dividers).
-- It draws only art. Place any buttons (Dominos, Bartender, ...) on top of it.
-- The frame GryphonForeverFrame covers exactly the button area, so other addons can anchor to it.

local ADDON = ...

local DEFAULTS = {
	slots = 24,         -- number of button slots
	rows = 1,
	size = 45,          -- slot size in px (45 = Blizzard native)
	spacing = 2,
	scale = 1,
	point = "BOTTOM", relPoint = "BOTTOM", x = 0, y = 7, -- y = 7: bottom of the border sits exactly on the screen edge
	tint = { 1, 0.78, 0.5 }, -- multiplies the grey border/dividers towards bronze; false = no tint
	enabled = true,
	caps = true,
	border = true,
	slotart = true,
	dividers = true,
	faction = "auto",   -- auto | alliance | horde
	strata = "LOW",
	capStrata = "LOW", -- caps live in their own frame so they can sit above e.g. the XP bar
}

local BASE = 45 -- Blizzard's native slot size; caps/border/dividers scale with size / BASE

local db
local art, capFrame, border, leftCap, rightCap, mover
local slotTex, dividers = {}, {}

local function Print(msg)
	print("|cff33ff99GryphonForever|r: " .. msg)
end

local function IsHorde()
	if db.faction == "horde" then return true end
	if db.faction == "alliance" then return false end
	return UnitFactionGroup("player") == "Horde"
end

local function Create()
	art = CreateFrame("Frame", "GryphonForeverFrame", UIParent)
	art:SetClampedToScreen(true)
	art:SetMovable(true)
	art:RegisterForDrag("LeftButton")
	art:SetScript("OnDragStart", art.StartMoving)
	art:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, _, relPoint, x, y = self:GetPoint()
		db.point, db.relPoint, db.x, db.y = point, relPoint, x, y
	end)

	border = CreateFrame("Frame", nil, art, "GryphonForeverBorderTemplate")
	border:SetFrameLevel(art:GetFrameLevel() + 2)
	capFrame = CreateFrame("Frame", nil, art)
	capFrame:SetAllPoints(art)
	leftCap = capFrame:CreateTexture(nil, "OVERLAY")
	rightCap = capFrame:CreateTexture(nil, "OVERLAY")

	mover = art:CreateTexture(nil, "OVERLAY", nil, 7)
	mover:SetAllPoints()
	mover:SetColorTexture(0.2, 1, 0.6, 0.35)
	mover:Hide()
end

-- tint every texture of a NineSlice frame
local function Tint(f)
	local c = db.tint
	local r, g, b = 1, 1, 1
	if c then r, g, b = c[1], c[2], c[3] end
	for _, region in ipairs({ f:GetRegions() }) do
		if region.SetVertexColor then region:SetVertexColor(r, g, b) end
	end
end

local function GetSlot(i)
	local t = slotTex[i]
	if not t then
		t = art:CreateTexture(nil, "BACKGROUND", nil, -2)
		t:SetAtlas("ui-hud-actionbar-iconframe-slot")
		slotTex[i] = t
	end
	return t
end

local function GetDivider(i)
	local d = dividers[i]
	if not d then
		d = CreateFrame("Frame", nil, art, "GryphonForeverDividerTemplate")
		d:SetFrameLevel(art:GetFrameLevel() + 1)
		dividers[i] = d
	end
	return d
end

local function Refresh()
	if not art then return end
	if not db.enabled then
		art:Hide()
		return
	end

	local size, spacing = db.size, db.spacing
	local s = size / BASE
	local rows = math.max(1, db.rows)
	local cols = math.ceil(db.slots / rows)

	art:SetFrameStrata(db.strata)
	capFrame:SetFrameStrata(db.capStrata)
	capFrame:SetFrameLevel(100)
	art:SetScale(db.scale)
	art:ClearAllPoints()
	art:SetPoint(db.point, UIParent, db.relPoint, db.x, db.y)
	art:SetSize(cols * size + (cols - 1) * spacing, rows * size + (rows - 1) * spacing)
	art:Show()

	-- border
	if db.border then
		border:ClearAllPoints()
		border:SetPoint("TOPLEFT", art, "TOPLEFT", -4 * s, 4 * s)
		border:SetPoint("BOTTOMRIGHT", art, "BOTTOMRIGHT", 7 * s, -7 * s)
		Tint(border)
		border:Show()
	else
		border:Hide()
	end

	-- caps
	if db.caps then
		local prefix = IsHorde() and "ui-hud-actionbar-wyvern-" or "ui-hud-actionbar-gryphon-"
		leftCap:SetAtlas(prefix .. "left", false, "LINEAR", true)
		rightCap:SetAtlas(prefix .. "right", false, "LINEAR", true)
		leftCap:SetSize(154 * s, 95 * s)
		rightCap:SetSize(154 * s, 95 * s)
		leftCap:ClearAllPoints()
		leftCap:SetPoint("BOTTOMRIGHT", art, "BOTTOMLEFT", 32 * s, -9 * s)
		rightCap:ClearAllPoints()
		rightCap:SetPoint("BOTTOMLEFT", art, "BOTTOMRIGHT", -28 * s, -9 * s)
		leftCap:Show()
		rightCap:Show()
		capFrame:Show()
	else
		capFrame:Hide()
	end

	-- slots and dividers
	local nDiv = 0
	for i = 1, db.slots do
		local col = (i - 1) % cols
		local row = math.floor((i - 1) / cols)
		local t = GetSlot(i)
		t:ClearAllPoints()
		t:SetSize(size, size)
		t:SetPoint("TOPLEFT", art, "TOPLEFT", col * (size + spacing), -row * (size + spacing))
		t:SetShown(db.slotart)

		if db.dividers and col < cols - 1 and i < db.slots then
			nDiv = nDiv + 1
			local d = GetDivider(nDiv)
			d:ClearAllPoints()
			d:SetWidth(12 * s)
			d:SetPoint("LEFT", t, "RIGHT", -5 * s, 0)
			d:SetPoint("TOP", t, "TOP")
			d:SetPoint("BOTTOM", t, "BOTTOM")
			Tint(d)
			d:Show()
		end
	end
	for i = db.slots + 1, #slotTex do slotTex[i]:Hide() end
	for i = nDiv + 1, #dividers do dividers[i]:Hide() end
end

local function SetLocked(locked)
	art:EnableMouse(not locked)
	mover:SetShown(not locked)
	Print(locked and "locked (position saved)" or "unlocked: drag the green area, then /gb lock")
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT")
frame:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" and arg1 == ADDON then
		if not GryphonForeverDB and GryphonBarDB then -- settings from the earlier "GryphonBar" name
			GryphonForeverDB = GryphonBarDB
		end
		GryphonForeverDB = GryphonForeverDB or {}
		db = GryphonForeverDB
		for k, v in pairs(DEFAULTS) do
			if db[k] == nil then db[k] = v end
		end
		if not db.v2 then -- 1.0 defaulted to y = 40, which left a gap at the screen bottom
			db.v2 = true
			if db.y == 40 then db.y = DEFAULTS.y end
		end
	elseif event == "PLAYER_LOGIN" then
		Create()
		Refresh()
		for _, name in ipairs({ "ui-hud-actionbar-gryphon-left", "ui-hud-actionbar-iconframe-slot" }) do
			if C_Texture and C_Texture.GetAtlasInfo and not C_Texture.GetAtlasInfo(name) then
				Print("atlas '" .. name .. "' not found in this client")
			end
		end
	elseif event == "NEUTRAL_FACTION_SELECT_RESULT" then
		Refresh()
	end
end)

local NUMBERS = { slots = { 1, 120 }, rows = { 1, 12 }, size = { 8, 128 }, spacing = { 0, 40 }, scale = { 0.2, 5 } }
local FLAGS = { caps = true, border = true, slotart = true, dividers = true }

SLASH_GRYPHONFOREVER1 = "/gb"
SLASH_GRYPHONFOREVER2 = "/gryphonforever"
SlashCmdList["GRYPHONFOREVER"] = function(msg)
	if not art then return end
	local cmd, arg = msg:match("^(%S*)%s*(.-)$")
	cmd, arg = cmd:lower(), arg:lower()

	if NUMBERS[cmd] and tonumber(arg) then
		local lo, hi = unpack(NUMBERS[cmd])
		db[cmd] = Clamp(tonumber(arg), lo, hi)
		Print(cmd .. " = " .. db[cmd])
		Refresh()
	elseif FLAGS[cmd] then
		if arg == "on" then db[cmd] = true elseif arg == "off" then db[cmd] = false else db[cmd] = not db[cmd] end
		Print(cmd .. " = " .. tostring(db[cmd]))
		Refresh()
	elseif cmd == "on" or cmd == "off" then
		db.enabled = (cmd == "on")
		Refresh()
	elseif cmd == "capstrata" then
		local v = arg:upper()
		if v == "BACKGROUND" or v == "LOW" or v == "MEDIUM" or v == "HIGH" or v == "DIALOG" then
			db.capStrata = v
			Refresh()
		end
		Print("capstrata = " .. db.capStrata .. " (background|low|medium|high|dialog)")
	elseif cmd == "unlock" then
		SetLocked(false)
	elseif cmd == "lock" then
		SetLocked(true)
	elseif cmd == "pos" then
		local x, y = arg:match("^(-?[%d.]+)%s+(-?[%d.]+)$")
		if x then
			db.x, db.y = tonumber(x), tonumber(y)
			Refresh()
		else
			Print("/gb pos <x> <y>  (offset from the anchor point)")
		end
	elseif cmd == "flush" then
		db.point, db.relPoint = "BOTTOM", "BOTTOM"
		db.y = 7 * db.size / BASE
		Refresh()
		Print("flush with the bottom of the screen")
	elseif cmd == "tint" then
		if arg == "off" then
			db.tint = false
		elseif arg == "reset" then
			db.tint = DEFAULTS.tint
		else
			local r, g, b = arg:match("^([%d.]+)%s+([%d.]+)%s+([%d.]+)$")
			if r then
				db.tint = { Clamp(tonumber(r), 0, 1), Clamp(tonumber(g), 0, 1), Clamp(tonumber(b), 0, 1) }
			else
				Print("/gb tint <r> <g> <b> (0-1) | off | reset   current: " .. (db.tint and table.concat(db.tint, " ") or "off"))
			end
		end
		Refresh()
	elseif cmd == "faction" and (arg == "auto" or arg == "alliance" or arg == "horde") then
		db.faction = arg
		Refresh()
	elseif cmd == "strata" and (arg == "background" or arg == "low" or arg == "medium") then
		db.strata = arg:upper()
		Refresh()
	elseif cmd == "reset" then
		for k, v in pairs(DEFAULTS) do db[k] = v end
		Refresh()
		Print("reset to defaults")
	else
		Print("/gb slots <n> | rows <n> | size <px> | spacing <px> | scale <n>")
		Print("/gb caps|border|slotart|dividers [on|off] | faction auto|alliance|horde | strata background|low|medium")
		Print("/gb unlock | lock | pos <x> <y> | flush | tint <r g b>|off|reset | on | off | reset")
	end
end
