local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: CUSTOM_CLASS_COLORS, OrderHallCommandBar, OrderHallMissionFrame, HybridScrollFrame_GetOffset

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.orderhall ~= true then return end

	local classColor = E.myclass == 'PRIEST' and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])

	-- CommandBar
	local OrderHallCommandBar = _G["OrderHallCommandBar"]
	OrderHallCommandBar:StripTextures()
	OrderHallCommandBar:CreateBackdrop("Transparent")
	OrderHallCommandBar.ClassIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
	OrderHallCommandBar.ClassIcon:SetSize(46, 20)
	OrderHallCommandBar.CurrencyIcon:SetAtlas("legionmission-icon-currency", false)
	OrderHallCommandBar.AreaName:SetVertexColor(classColor.r, classColor.g, classColor.b)
	OrderHallCommandBar.WorldMapButton:Hide()

	-- MissionFrame
	OrderHallMissionFrame.ClassHallIcon:Kill()
	OrderHallMissionFrame:StripTextures()
	OrderHallMissionFrame.GarrCorners:Hide()
	OrderHallMissionFrame:CreateBackdrop("Transparent")
	OrderHallMissionFrame.backdrop:SetOutside(OrderHallMissionFrame.BorderFrame)
	S:HandleCloseButton(OrderHallMissionFrame.CloseButton)
	S:HandleCloseButton(_G["OrderHallMissionTutorialFrame"].GlowBox.CloseButton)

	for i = 1, 3 do
		S:HandleTab(_G["OrderHallMissionFrameTab" .. i])
	end

	for _, Button in pairs(OrderHallMissionFrame.MissionTab.MissionList.listScroll.buttons) do
		if not Button.isSkinned then
			Button:StripTextures()
			Button:SetTemplate()
			S:HandleButton(Button)
			Button:SetBackdropBorderColor(0, 0, 0, 0)
			Button.LocBG:Hide()
			Button.isSkinned = true
		end
	end

	-- Followers
	local Follower = _G["OrderHallMissionFrameFollowers"]
	local FollowerList = OrderHallMissionFrame.FollowerList
	local FollowerTab = OrderHallMissionFrame.FollowerTab
	Follower:StripTextures()
	Follower:SetTemplate("Transparent")
	FollowerList:StripTextures()
	FollowerList.MaterialFrame:StripTextures()
	S:HandleEditBox(FollowerList.SearchBox)
	S:HandleScrollBar(OrderHallMissionFrame.FollowerList.listScroll.scrollBar)
	hooksecurefunc(FollowerList, "ShowFollower", function(self)
		S:HandleFollowerPage(self, true, true)
	end)
	FollowerTab:StripTextures()
	FollowerTab.Class:SetSize(50, 43)
	FollowerTab.XPBar:StripTextures()
	FollowerTab.XPBar:SetStatusBarTexture(E["media"].normTex)
	FollowerTab.XPBar:CreateBackdrop()

	hooksecurefunc(OrderHallMissionFrameFollowers, "UpdateData", function(self)
		local followersList = self.followersList
		local scrollFrame = self.listScroll
		local offset = HybridScrollFrame_GetOffset(scrollFrame)
		local buttons = scrollFrame.buttons
		local numFollowers = #followersList
		local numButtons = #buttons

		for i = 1, numButtons do
			local button = buttons[i]
			local index = offset + i -- adjust index

			if button then
				if (index <= numFollowers) and not button.template then
					button:SetTemplate()

					if button.Category then
						button.Category:ClearAllPoints()
						button.Category:SetPoint("TOP", button, "TOP", 0, -4)
					end

					if button.Follower then
						button.Follower.Name:SetWordWrap(false)
						button.Follower.BG:Hide()
						button.Follower.Selection:SetTexture("")
						button.Follower.AbilitiesBG:SetTexture("")
						button.Follower.BusyFrame:SetAllPoints()

						local hl = button.Follower:GetHighlightTexture()
						hl:SetColorTexture(0.9, 0.8, 0.1, 0.3)
						hl:ClearAllPoints()
						hl:SetPoint("TOPLEFT", 1, -1)
						hl:SetPoint("BOTTOMRIGHT", -1, 1)

						if button.Follower.PortraitFrame then
							S:HandleGarrisonPortrait(button.Follower.PortraitFrame)
							button.Follower.PortraitFrame:ClearAllPoints()
							button.Follower.PortraitFrame:SetPoint("TOPLEFT", 3, -3)
						end
					end
				end

				if button.Follower then
					if button.Follower.Selection then
						if button.Follower.Selection:IsShown() then
							button.Follower:SetBackdropColor(0.9, 0.8, 0.1, 0.3)
						else
							button.Follower:SetBackdropColor(0, 0, 0, .25)
						end
					end

					if button.Follower.PortraitFrame and button.Follower.PortraitFrame.quality then
						local color = ITEM_QUALITY_COLORS[button.Follower.PortraitFrame.quality]
						if color and button.Follower.PortraitFrame.backdrop then
							button.Follower.PortraitFrame.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
						end
					end
				end
			end
		end
	end)

	-- Missions
	local MissionTab = OrderHallMissionFrame.MissionTab
	local MissionComplete = OrderHallMissionFrame.MissionComplete
	local MissionList = MissionTab.MissionList
	local MissionPage = MissionTab.MissionPage
	local ZoneSupportMissionPage = MissionTab.ZoneSupportMissionPage
	S:HandleScrollBar(MissionList.listScroll.scrollBar)
	MissionList.CompleteDialog:StripTextures()
	MissionList.CompleteDialog:SetTemplate("Transparent")
	S:HandleButton(MissionList.CompleteDialog.BorderFrame.ViewButton)
	MissionList:StripTextures()
	MissionList.listScroll:StripTextures()
	S:HandleButton(_G["OrderHallMissionFrameMissions"].CombatAllyUI.InProgress.Unassign)
	S:HandleCloseButton(MissionPage.CloseButton)
	S:HandleButton(MissionPage.StartMissionButton)
	S:HandleCloseButton(ZoneSupportMissionPage.CloseButton)
	S:HandleButton(ZoneSupportMissionPage.StartMissionButton)
	S:HandleButton(MissionComplete.NextMissionButton)

	-- TalentFrame
	local TalentFrame = _G["OrderHallTalentFrame"]
	TalentFrame:StripTextures()
	TalentFrame.LeftInset:StripTextures()
	TalentFrame:SetTemplate("Transparent")
	TalentFrame.CurrencyIcon:SetAtlas("legionmission-icon-currency", false)
	S:HandleCloseButton(TalentFrame.CloseButton)

	-- Chromie Frame
	_G["OrderHallTalentFramePortraitFrame"]:Hide()
	_G["OrderHallTalentFramePortrait"]:Hide()
	S:HandleButton(_G["OrderHallTalentFrame"].BackButton)
end

S:AddCallbackForAddon('Blizzard_OrderHallUI', "OrderHall", LoadSkin)