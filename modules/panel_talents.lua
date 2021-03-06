local IQ = InQuiro
local tal, _, name = IQ:CreateTabDialog(TALENTS, "Talents")
tal:SetBackdrop({})


--[[ ##################
	Layout
#################### ]]
local talentSpecInfoCache = {}
tal.inspect = true
tal.talentGroup = 1
TalentFrame_Load(tal)
local font = tal:CreateFontString(name.."TalentPointsText", nil, "GameFontNormal")
_G[name.."TalentPointsText"] = font
font:Hide()
CreateFrame("Button", name.."ScrollFrameScrollBarScrollDownButton")

local bgTL = tal:CreateTexture(name.."BackgroundTopLeft", "BACKGROUND")
bgTL:SetPoint("TOPLEFT")
bgTL:SetWidth(267)
bgTL:SetHeight(270)
local bgTR = tal:CreateTexture(name.."BackgroundTopRight", "BACKGROUND")
bgTR:SetPoint("LEFT", bgTL, "RIGHT")
bgTR:SetWidth(74)
bgTR:SetHeight(270)
local bgBL = tal:CreateTexture(name.."BackgroundBottomLeft", "BACKGROUND")
bgBL:SetPoint("TOP", bgTL, "BOTTOM")
bgBL:SetWidth(267)
bgBL:SetHeight(141)
local bgBR = tal:CreateTexture(name.."BackgroundBottomRight", "BACKGROUND")
bgBR:SetPoint("LEFT", bgBL, "RIGHT")
bgBR:SetWidth(74)
bgBR:SetHeight(141)

local function Tab_OnClick(self)
	PanelTemplates_SetTab(tal, self.id)
	tal.currentSelectedTab = self.id
	tal.pointsSpent = select(3, GetTalentTabInfo(self.id, true))
	tal.previewPointsSpent = 0
	TalentFrame_Update(tal)
end

local prev
for i = 1, MAX_TALENT_TABS do
	local tab = CreateFrame("Button", name.."Tab"..i, tal, "TabButtonTemplate")
	tab:Hide()
	tab.id = i
	tab:SetScript("OnClick", Tab_OnClick)
	if(i == 2) then
		tab:SetPoint("BOTTOM", 0, 0)
		prev:SetPoint("RIGHT", tab, "LEFT")
	elseif(i > 2) then
		tab:SetPoint("LEFT", prev, "RIGHT")
	end
	tal['Tab'..i] = tab
	prev = tab
end
PanelTemplates_SetNumTabs(tal, 3)
PanelTemplates_UpdateTabs(tal)

local sChild = CreateFrame("ScrollFrame", name.."ScrollChild", tal, "UIPanelScrollFrameTemplate")
sChild:SetPoint("TOPLEFT");
sChild:SetPoint("BOTTOMRIGHT", -25, 25)

local childFrame = CreateFrame("Frame", name.."ScrollChildFrame")
childFrame:SetWidth(320)
childFrame:SetHeight(1)
sChild:SetScrollChild(childFrame)

for i = 1, MAX_NUM_TALENTS do
	local button = CreateFrame("Button", name.."Talent"..i, childFrame, "TalentButtonTemplate")
	button.id = i
	button:SetScript("OnEvent", nil)
	button:SetScript("OnClick", nil)
	button:SetScript("OnEnter", function(self,motion)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetTalent(tal.selectedTab, self.id, 1)
	end)
end
local arr = CreateFrame("Frame", name.."ArrowFrame", childFrame)
arr:SetAllPoints()
for i = 1, 30 do
	childFrame:CreateTexture(name.."Branch"..i, "BACKGROUND", "TalentBranchTemplate")
	arr:CreateTexture(name.."Arrow"..i, "OVERLAY", "TalentArrowTemplate")
end

-- Info on item frame
IQ.TalentsInfo = IQ.ItemButtons:CreateFontString(nil, "OVERLAY")
IQ.TalentsInfo:SetFont([[Fonts\FRIZQT__.TTF]], 14, "THINOUTLINE")
IQ.TalentsInfo:SetPoint("TOP", IQ.Model, "TOP", 0, -2)
IQ.TalentsInfo:SetTextColor(1, .5, 0)


--[[ ##################
	Functions
#################### ]]
local function UpdateTabs()
	local numTabs = GetNumTalentTabs(true)
	local text
	for i = 1, MAX_TALENT_TABS do
		local tab = tal['Tab'..i]
		if (i <= numTabs) then
			local tabName, _, pointsSpent = GetTalentTabInfo(i,true);
			if(i == tal.selectedTab) then
				tal.pointsSpent = pointsSpent
			end
			tab:SetText(tabName.." |cff00ff00"..pointsSpent)
			tab:Show()
			PanelTemplates_TabResize(tab,-18)
			if(not text) then
				text = pointsSpent
			else
				text = text.." | "..pointsSpent
			end
		else
			tab:Hide()
		end
	end
	IQ.TalentsInfo:SetText(text)
end

tal.updateFunction = UpdateTabs
Tab_OnClick(tal.Tab1)

function tal:OnInspect()
	IQ.TalentsInfo:SetText()
end

tal:RegisterEvent("INSPECT_TALENT_READY", TalentFrame_Update)