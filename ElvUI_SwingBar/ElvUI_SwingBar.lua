local E, L, V, P, G = unpack(ElvUI)
local SB = E:NewModule("SwingBar")
local UF = E:GetModule("UnitFrames")
local EP = LibStub("LibElvUIPlugin-1.0")
local addonName = "ElvUI_SwingBar"

P.unitframe.units.player.swingbar = {
	enable = true,
	width = 270,
	height = 18,
	color = {r = 0.31, g = 0.31, b = 0.31},
	text = {
		enable = true,
		position = "CENTER",
		xOffset = 0,
		yOffset = 0,
		font = "Homespun",
		fontSize = 10,
		fontOutline = "MONOCHROMEOUTLINE"
	}
}

local positionValues = {
	TOPLEFT = "TOPLEFT",
	LEFT = "LEFT",
	BOTTOMLEFT = "BOTTOMLEFT",
	RIGHT = "RIGHT",
	TOPRIGHT = "TOPRIGHT",
	BOTTOMRIGHT = "BOTTOMRIGHT",
	CENTER = "CENTER",
	TOP = "TOP",
	BOTTOM = "BOTTOM"
}

local function getOptions()
	E.Options.args.unitframe.args.player.args.swing = {
		order = 2000,
		type = "group",
		name = L["Swing Bar"],
		get = function(info) return E.db.unitframe.units.player.swingbar[info[#info]] end,
		set = function(info, value) E.db.unitframe.units.player.swingbar[info[#info]] = value UF:CreateAndUpdateUF("player") end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["Swing Bar"]
			},
			enable = {
				order = 2,
				type = "toggle",
				name = L["Enable"]
			},
			spacer = {
				order = 3,
				type = "description",
				name = " "
			},
			width = {
				order = 4,
				type = "range",
				name = L["Width"],
				min = 50, max = 600, step = 1,
				disabled = function() return not E.db.unitframe.units.player.swingbar.enable end
			},
			height = {
				order = 5,
				type = "range",
				name = L["Height"],
				min = 10, max = 85, step = 1,
				disabled = function() return not E.db.unitframe.units.player.swingbar.enable end
			},
			color = {
				order = 6,
				type = "color",
				name = COLOR,
				get = function(info)
					local t = E.db.unitframe.units.player.swingbar[info[#info]]
					local d = P.unitframe.units.player.swingbar[info[#info]]
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b
				end,
				set = function(info, r, g, b)
					local t = E.db.unitframe.units.player.swingbar[info[#info]]
					t.r, t.g, t.b = r, g, b
					UF:CreateAndUpdateUF("player")
				end,
				disabled = function() return not E.db.unitframe.units.player.swingbar.enable end
			},
			textGroup = {
				order = 7,
				type = "group",
				name = L["Text"],
				guiInline = true,
				get = function(info) return E.db.unitframe.units.player.swingbar.text[info[#info]] end,
				set = function(info, value) E.db.unitframe.units.player.swingbar.text[info[#info]] = value UF:CreateAndUpdateUF("player") end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						disabled = function() return not E.db.unitframe.units.player.swingbar.enable end
					},
					spacer = {
						order = 2,
						type = "description",
						name = " "
					},
					position = {
						order = 3,
						type = "select",
						name = L["Text Position"],
						values = positionValues,
						disabled = function() return not E.db.unitframe.units.player.swingbar.text.enable or not E.db.unitframe.units.player.swingbar.enable end
					},
					xOffset = {
						order = 4,
						type = "range",
						name = L["Text xOffset"],
						desc = L["Offset position for text."],
						min = -300, max = 300, step = 1,
						disabled = function() return not E.db.unitframe.units.player.swingbar.text.enable or not E.db.unitframe.units.player.swingbar.enable end
					},
					yOffset = {
						order = 5,
						type = "range",
						name = L["Text yOffset"],
						desc = L["Offset position for text."],
						min = -300, max = 300, step = 1,
						disabled = function() return not E.db.unitframe.units.player.swingbar.text.enable or not E.db.unitframe.units.player.swingbar.enable end
					},
					font = {
						order = 6,
						type = "select", dialogControl = "LSM30_Font",
						name = L["Font"],
						values = AceGUIWidgetLSMlists.font,
						disabled = function() return not E.db.unitframe.units.player.swingbar.text.enable or not E.db.unitframe.units.player.swingbar.enable end
					},
					fontSize = {
						order = 7,
						type = "range",
						name = FONT_SIZE,
						min = 6, max = 32, step = 1,
						disabled = function() return not E.db.unitframe.units.player.swingbar.text.enable or not E.db.unitframe.units.player.swingbar.enable end
					},
					fontOutline = {
						order = 8,
						type = "select",
						name = L["Font Outline"],
						desc = L["Set the font outline."],
						values = {
							["NONE"] = NONE,
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE"
						},
						disabled = function() return not E.db.unitframe.units.player.swingbar.text.enable or not E.db.unitframe.units.player.swingbar.enable end
					}
				}
			}
		}
	}
end

function UF:Construct_Swingbar(frame)
	local swingbar = CreateFrame("Frame", frame:GetName().."SwingBar", frame)
	swingbar:SetClampedToScreen(true)

	swingbar.Twohand = CreateFrame("StatusBar", frame:GetName().."SwingBar_Twohand", swingbar)
	UF["statusbars"][swingbar.Twohand] = true
	swingbar.Twohand:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
	swingbar.Twohand:Point("TOPLEFT", swingbar, "TOPLEFT", 0, 0)
	swingbar.Twohand:Point("BOTTOMRIGHT", swingbar, "BOTTOMRIGHT", 0, 0)
	swingbar.Twohand:Hide()

	swingbar.Mainhand = CreateFrame("StatusBar", frame:GetName().."SwingBar_Mainhand", swingbar)
	self["statusbars"][swingbar.Mainhand] = true
	swingbar.Mainhand:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
	swingbar.Mainhand:Point("TOPLEFT", swingbar, "TOPLEFT", 0, 0)
	swingbar.Mainhand:Point("BOTTOMRIGHT", swingbar, "RIGHT", 0, E.Border)
	swingbar.Mainhand:Hide()

	swingbar.Offhand = CreateFrame("StatusBar", frame:GetName().."SwingBar_Offhand", swingbar)
	self["statusbars"][swingbar.Offhand] = true
	swingbar.Offhand:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
	swingbar.Offhand:Point("TOPLEFT", swingbar, "LEFT", 0, 0)
	swingbar.Offhand:Point("BOTTOMRIGHT", swingbar, "BOTTOMRIGHT", 0, 0)
	swingbar.Offhand:Hide()

	swingbar.Text = swingbar:CreateFontString(nil, "OVERLAY")
	swingbar.TextMH = swingbar:CreateFontString(nil, "OVERLAY")
	swingbar.TextOH = swingbar:CreateFontString(nil, "OVERLAY")

	local holder = CreateFrame("Frame", nil, swingbar)
	swingbar.Holder = holder
	swingbar.Holder:Point("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -36)
	swingbar:Point("BOTTOMRIGHT", swingbar.Holder, "BOTTOMRIGHT", -E.Border, E.Border)

	E:CreateMover(holder, frame:GetName().."SwingBarMover", L["Player SwingBar"], nil, -6, nil, "ALL,SOLO")

	return swingbar
end

function UF:Configure_Swingbar(frame)
	local swingbar = frame.Swing
	local db = frame.db

	swingbar:Width(db.swingbar.width - (E.Border * 2))
	swingbar:Height(db.swingbar.height)

	swingbar.Holder:Width(db.swingbar.width)
	swingbar.Holder:Height(db.swingbar.height + (E.PixelMode and 2 or (E.Border * 2)))

	if swingbar.Holder:GetScript("OnSizeChanged") then
		swingbar.Holder:GetScript("OnSizeChanged")(swingbar.Holder)
	end

	swingbar.Twohand:SetStatusBarColor(db.swingbar.color.r, db.swingbar.color.g, db.swingbar.color.b)
	swingbar.Mainhand:SetStatusBarColor(db.swingbar.color.r, db.swingbar.color.g, db.swingbar.color.b)
	swingbar.Offhand:SetStatusBarColor(db.swingbar.color.r, db.swingbar.color.g, db.swingbar.color.b)

	local color = E.db.unitframe.colors.borderColor
	swingbar.Twohand.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
	swingbar.Mainhand.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
	swingbar.Offhand.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)

	if swingbar.Text then
		if db.swingbar.text.enable then
			swingbar.Text:Show()
			swingbar.Text:FontTemplate(UF.LSM:Fetch("font", db.swingbar.text.font), db.swingbar.text.fontSize, db.swingbar.text.fontOutline)
			local x, y = self:GetPositionOffset(db.swingbar.text.position)
			swingbar.Text:ClearAllPoints()
			swingbar.Text:Point(db.swingbar.text.position, swingbar, db.swingbar.text.position, x + db.swingbar.text.xOffset, y + db.swingbar.text.yOffset)
		else
			swingbar.Text:Hide()
		end
	end

	if swingbar.TextMH then
		if db.swingbar.text.enable then
			swingbar.TextMH:Show()
			swingbar.TextMH:FontTemplate(UF.LSM:Fetch("font", db.swingbar.text.font), db.swingbar.text.fontSize, db.swingbar.text.fontOutline)
			local x, y = self:GetPositionOffset(db.swingbar.text.position)
			swingbar.TextMH:ClearAllPoints()
			swingbar.TextMH:Point(db.swingbar.text.position, swingbar.Mainhand, db.swingbar.text.position, x + db.swingbar.text.xOffset, y + db.swingbar.text.yOffset)
		else
			swingbar.TextMH:Hide()
		end
	end

	if swingbar.TextOH then
		if db.swingbar.text.enable then
			swingbar.TextOH:Show()
			swingbar.TextOH:FontTemplate(UF.LSM:Fetch("font", db.swingbar.text.font), db.swingbar.text.fontSize, db.swingbar.text.fontOutline)
			local x, y = self:GetPositionOffset(db.swingbar.text.position)
			swingbar.TextOH:ClearAllPoints()
			swingbar.TextOH:Point(db.swingbar.text.position, swingbar.Offhand, db.swingbar.text.position, x + db.swingbar.text.xOffset, y + db.swingbar.text.yOffset)
		else
			swingbar.TextOH:Hide()
		end
	end

	if db.swingbar.enable then
		frame:EnableElement("Swing")
		swingbar:Show()
	elseif not db.swingbar.enable then
		frame:DisableElement("Swing")
		swingbar:Hide()
	end
end

function SB:Initialize()
	EP:RegisterPlugin(addonName, getOptions)

	ElvUF_Player.Swing = UF:Construct_Swingbar(ElvUF_Player)
	hooksecurefunc(UF, "Update_PlayerFrame", function(self, frame, db)
		UF:Configure_Swingbar(frame)
	end)
end

local function InitializeCallback()
	SB:Initialize()
end

E:RegisterModule(SB:GetName(), InitializeCallback)