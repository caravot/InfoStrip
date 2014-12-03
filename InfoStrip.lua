local space = 5 										-- Space between each frame
local fontheight = 11									-- Fontsize
local font = "Interface\\AddOns\\InfoStrip\\font.ttf"	-- Font
local trackBadges = { 
	  "Emblem of Frost",
	  "Stone Keeper's Shard",
	  "Emblem of Heroism",
	  "Emblem of Triumph",
	  "Honor Points",
	  "Dalaran Cooking Award",
	  "Darkmoon Prize Ticket",
	  "Epicurean's Award",
	  "Justice Points",
	  "Valor Points"
} 														-- Badge names to track

local MAX_ADDONS = 15									-- Maximum addons to display in dropdown list		
local MAX_GUILDIES = 25									-- Maximum guild members to display in dropdown list
local MAX_FACTIONS = 25									-- Maximum factions to display in dropdown list

-----------------------------------------------------
-- 	GLOBAL VARIABLES
-----------------------------------------------------
function Set(list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

local screenWidth = GetScreenWidth() * UIParent:GetEffectiveScale()
local TimeSinceLastUpdate = 0
local money = 0

local CLASS_COLORS = {
	["HUNTER"] 			= { 0.67, 0.83, 0.45 },
	["WARLOCK"] 		= { 0.58, 0.51, 0.79 },
	["PRIEST"] 			= { 1.0, 1.0, 1.0 },
	["PALADIN"] 		= { 0.96, 0.55, 0.73 },
	["MAGE"] 			= { 0.41, 0.8, 0.94 },
	["ROGUE"] 			= { 1.0, 0.96, 0.41 },
	["DRUID"] 			= { 1.0, 0.49, 0.04 },
	["SHAMAN"] 			= { 0.0, 0.44, 0.87 },
	["WARRIOR"] 		= { 0.78, 0.61, 0.43 },
	["DEATH KNIGHT"] 	= { 0.77, 0.12 , 0.23 }
}

local FACTION_BAR_COLORS = {
    {r = 0.8, g = 0.133, b = 0.133},
    {r = 1, g = 0, b = 0},
    {r = 0.933, g = 0.4, b = 0.133},
    {r = 1, g = 1, b = 0},
    {r = 0.749, g = 1, b = 0},
    {r = 0, g = 1, b = 0.533},
    {r = 0, g = 1, b = 0.8},
    {r = 0, g = 1, b = 1}
};

local FACTION_STANDINGS = { "Hated", "Hostile", "Unfriendly", "Neutral", "Friendly", "Honored", "Revered", "Exalted" }

local f = CreateFrame("FRAME", "InfoStrip", UIParent)
f:SetWidth(screenWidth)
f:SetHeight(15)
f:SetPoint("TOPLEFT", 0, 0)
f:SetPoint("TOPRIGHT", 0, 0)

local background_frame = f:CreateTexture(nil, "ARTWORK")
background_frame:SetTexture(0, 0, 0, .5)
background_frame:SetAllPoints(f)

local border_frame = f:CreateTexture(nil, "BORDER")
border_frame:SetTexture(.4, .4, .4)
border_frame:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, 0)
border_frame:SetPoint("TOPRIGHT", f, "BOTTOMRIGHT", 0, 0)
border_frame:SetWidth(screenWidth)
border_frame:SetHeight(1)

--Tracking button
local btn = CreateFrame("BUTTON", "InfoStripBtn", f)
btn:SetWidth(60)
btn:SetHeight(10)
btn:SetPoint("LEFT", f, "LEFT", space, 0)
local bfs = btn:CreateFontString()
bfs:SetFont(font, fontheight)
btn:SetFontString(bfs)
btn:SetText("Tracking: 0")

--Badges button
local badgebtn = CreateFrame("BUTTON", "InfoStripBadgeBtn", f)
badgebtn:SetWidth(50)
badgebtn:SetHeight(10)
local badgefs = badgebtn:CreateFontString()
badgefs:SetFont(font, fontheight)
badgebtn:SetFontString(badgefs)
badgebtn:SetText("Badges")
badgebtn:SetPoint("LEFT", btn, "RIGHT", space, 0)

--Friends button
local friendbtn = CreateFrame("BUTTON", "InfoStripFriendsBtn", f)
friendbtn:SetWidth(55)
friendbtn:SetHeight(10)
local friendfs = friendbtn:CreateFontString()
friendfs:SetFont(font, fontheight)
friendbtn:SetFontString(friendfs)
friendbtn:SetPoint("LEFT", badgebtn, "RIGHT", space, 0)

--Guildies button (if in guild)
--if IsInGuild() then
	local guildiesbtn = CreateFrame("BUTTON", "InfoStripGuildiesBtn", f)
	guildiesbtn:SetWidth(75)
	guildiesbtn:SetHeight(10)
	local guildiesfs = guildiesbtn:CreateFontString()
	guildiesfs:SetFont(font, fontheight)
	guildiesbtn:SetFontString(guildiesfs)
	guildiesbtn:SetPoint("LEFT", friendbtn, "RIGHT", space, 0)
--end

-- Main text
local fs = f:CreateFontString(nil, "LOW")
fs:SetFont(font, fontheight)
if IsInGuild() then 
	fs:SetPoint("LEFT", guildiesbtn, "RIGHT", space, 0)
else 
	fs:SetPoint("LEFT", friendbtn, "RIGHT", space, 0)
end

--[[RIGHT SIDE]]--

--Time Button
local clockbtn = CreateFrame("BUTTON", "InfoStripClockBtn", f)
clockbtn:SetWidth(90)
clockbtn:SetHeight(10)
local timefs = clockbtn:CreateFontString()
timefs:SetFont(font, fontheight)
clockbtn:SetFontString(timefs)
clockbtn:SetPoint("RIGHT", f, "Right", -10, 0)

--Mail button
local mailbtn = CreateFrame("BUTTON", "InfoStripMailBtn", f)
mailbtn:SetWidth(50)
mailbtn:SetHeight(10)
local mailfs = mailbtn:CreateFontString()
mailfs:SetFont(font, fontheight)
mailbtn:SetFontString(mailfs)
mailbtn:SetPoint("RIGHT", clockbtn, "LEFT", -10, 0)

--Stats button
local membtn = CreateFrame("BUTTON", "InfoStripMemBtn", f)
membtn:SetWidth(50)
membtn:SetHeight(10)
local memfs = membtn:CreateFontString()
memfs:SetFont(font, fontheight)
membtn:SetFontString(memfs)
membtn:SetPoint("RIGHT", mailbtn, "LEFT", -10, 0)

--Leveling info
local levelbtn = CreateFrame("BUTTON", "InfoStripLevelBtn", f)
levelbtn:SetWidth(50)
levelbtn:SetHeight(10)
local levelinfo = levelbtn:CreateFontString()
levelinfo:SetFont(font, fontheight)
levelbtn:SetFontString(levelinfo)
levelbtn:SetPoint("RIGHT", membtn, "LEFT", -10, 0)

--Reputation info
local repbtn = CreateFrame("BUTTON", "InfoStripRepBtn", f)
repbtn:SetWidth(200)
repbtn:SetHeight(10)
local repfs = repbtn:CreateFontString()
repfs:SetFont(font, fontheight)
repbtn:SetFontString(repfs)
repbtn:SetPoint("RIGHT", levelbtn, "LEFT", -10, 0)

-- Tracking Drop down menu
local TrackerDropDownMenu = CreateFrame("Frame", "TrackerDropDownMenu")
TrackerDropDownMenu.displayMode = "MENU"
TrackerDropDownMenu.initialize = function(self, level) end

local tracking_items = {}
TrackerDropDownMenu.initialize = function(self, level)
    if not level then return end
    	wipe(tracking_items)
    if level == 1 then
        tracking_items.disabled     = nil
        tracking_items.isTitle      = nil
        tracking_items.notCheckable = nil

        local num = GetNumTrackingTypes()
		for i = 1, num do
			local name, texture, active, category = GetTrackingInfo(i)
			tracking_items.text = name
			tracking_items.func = function() SetTracking(i) end

			if active then
				tracking_items.checked = true
			else
				tracking_items.checked = false
			end

			UIDropDownMenu_AddButton(tracking_items, level)
		end
    end
end

---------------------------------------------------------
-- Tooltips
---------------------------------------------------------
-- Tooltip Badges
local function badgeTooltip(self)
  	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -25)
	GameTooltip:SetText("Badges", 1, 1, 1)

	for i = 1, GetCurrencyListSize() do
		local name,_,_,_,_,count,_,_,_ = GetCurrencyListInfo(i)
		local found = FindInSet(trackBadges, name)

		if found then
			GameTooltip:AddDoubleLine(name, count, nil, nil, nil, 1, 1, 1)
		end
	end

	GameTooltip:Show()
end

-- Tooltip Guildies
local function guildiesTooltip(self)
	if IsInGuild() then
	    local members = {}
		local numGuildMembers, numOnline, numOnlineAndMobile = GetNumGuildMembers()

		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -25)


		for i = 0, math.min(MAX_GUILDIES, numOnline) do
			local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName = GetGuildRosterInfo(i)

			if online then
				local colors = classColor(string.upper(class))

	    		table.insert(members, { name = name, level = level, colors = colors })
			end
		end

	    -- sort by name
	    table.sort(members, function(a, b) return a.name < b.name end)

	    for k, v in pairs(members) do
	      -- level 100 characters color green
	      if v.level == 100 then
	        GameTooltip:AddDoubleLine(v.name, v.level, v.colors[1], v.colors[2], v.colors[3], 0, 1, 0)
	      else
	        GameTooltip:AddDoubleLine(v.name, v.level, v.colors[1], v.colors[2], v.colors[3], 1, 1, 1)
	      end
	    end

    	GameTooltip:Show()
	end
end

-- Tooltip Friends
local function friendsTooltip(self)
	local _,numFriends = GetNumFriends()
	local _,bnFriends = BNGetNumFriends()
	local totalFriends = numFriends + bnFriends
	local friends = {}

	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -25)
	GameTooltip:AddLine(numFriends.." Friend(s) Online")

	for i = 0, GetNumFriends() do
		local name, level, class, area, connected, status, note = GetFriendInfo(i)

		if connected then
			local colors = classColor(string.upper(class))

			table.insert(friends, { name = name, level = level, colors = colors })
		end
	end

	-- sort by name
    table.sort(friends, function(a, b) return a.name < b.name end)

    for k, v in pairs(friends) do
        GameTooltip:AddDoubleLine(v.name, v.level, v.colors[1], v.colors[2], v.colors[3], 1, 1, 1)
    end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(bnFriends.." BattleNet Friend(s) Online")

	friends = {} -- reset friends table

	for j = 1, BNGetNumFriends() do
		local presenceID, givenName, surname, toonName, toonID, client, isOnline = BNGetFriendInfo(j)
		local unknown, toonName, client, realmName, faction, race, class, unknown, zoneName, level, gameText, broadcastText, broadcastTime = BNGetToonInfo(presenceID)

		if isOnline then
			local colors = classColor(string.upper(class))

			table.insert(friends, { name = givenName, toonName = toonName, level = level, realmName = realmName, colors = colors })
		end
	end

	-- sort by name
    table.sort(friends, function(a, b) return a.name < b.name end)

    for k, v in pairs(friends) do
        GameTooltip:AddDoubleLine(""..v.name.." on "..v.toonName.."-"..v.realmName, v.level, v.colors[1], v.colors[2], v.colors[3], 1, 1, 1)
    end

	GameTooltip:Show()
end


-- Tooltip Mail
local function showmailtip(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -10, -25)
	GameTooltip:AddLine("Unread Mail From:", 1, 1, 1)

	if HasNewMail() then
		sender1, sender2, sender3 = GetLatestThreeSenders()
		if sender1 ~= nil then
			GameTooltip:AddLine(sender1, 1, 1, 1)
		end
		if sender2 ~= nil then
			GameTooltip:AddLine(sender2, 1, 1, 1)
		end
		if sender3 ~= nil then
			GameTooltip:AddLine(sender3, 1, 1, 1)
		end
	else
		GameTooltip:AddLine("No one", 1, 1, 1)
	end

	GameTooltip:Show()
end

-- Tooltip XP
local function xpTooltip(self)
	if UnitLevel("player") < 100 then
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -10, -25)
		GameTooltip:SetText("Experience", 1, 1, 1)
		GameTooltip:AddDoubleLine("Total XP: ", UnitXP('player'), nil, nil, nil, 1, 1, 1)
		GameTooltip:AddDoubleLine("XP till next level: ", UnitXPMax('player'), nil, nil, nil, 1, 1, 1)
		GameTooltip:AddDoubleLine("|c0000ff00Rested XP ", GetXPExhaustion().."|r", 1, 1, 1, 1, 1, 1)
		GameTooltip:Show()
	end
end

-- Tooltip Rep
local function repTooltip(self)
	local totalReps = 0
	local factions = {}
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -10, -25)
	GameTooltip:SetText("Reputation", 1, 1, 1)

	for i = 1, GetNumFactions() do
		local name,_,standingID,barMin,barMax,barValue,_,_,_,_,_,_,_ = GetFactionInfo(i)
		local perc = math.floor(((barValue-barMin)/(barMax-barMin)) * 100)

		-- only show reps that are friendly to revered
		if standingID >= 5 and standingID < 8 and totalReps <= MAX_FACTIONS then
			totalReps = totalReps + 1
			table.insert(factions, { name = name, standingID = standingID, standing = FACTION_STANDINGS[standingID], perc = perc, colors = FACTION_BAR_COLORS[standingID] })
		end
	end

	table.sort(factions, function(a, b) return a.standingID > b.standingID end)

	for k, v in pairs(factions) do
		GameTooltip:AddDoubleLine(v.name, v.standing.." |r("..v.perc.."%)", 1, 1, 1, v.colors.r, v.colors.g, v.colors.b)
	end

	GameTooltip:Show()
end

-- Tooltip Clock
local function clockTooltip(self)
	local realmHour, realmMin = GetGameTime()
	--local localeHour, localeMin = GetLocale()
	local dateInfo = date("*t")
	local localeHour = dateInfo.hour
	local localeMin = dateInfo.min

	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -10, -25)
	GameTooltip:SetText("Time Info", 1, 1, 1)
	GameTooltip:AddDoubleLine("Local Time:", format("%s:%s %s", GetHour(localeHour), GetMin(localeMin), GetDST(localeHour)), nil, nil, nil, 1, 1, 1)
	GameTooltip:AddDoubleLine("Realm Time:", format("%s:%s %s", GetHour(realmHour), GetMin(realmMin), GetDST(realmHour)), nil, nil, nil, 1, 1, 1)
	GameTooltip:Show()
end

--Tooltip Memory
local function memtooltip(self)
	local addons = {}
	local total = 0
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -10, -25)
	GameTooltip:SetText("Memory Usage", 1, 1, 1)
	UpdateAddOnMemoryUsage()

	for i=1, GetNumAddOns() do
		if IsAddOnLoaded(i) and table.getn(addons) <= MAX_ADDONS then
			memory = GetAddOnMemoryUsage(i)

			if memory > 0 then
				total = total + memory
				table.insert(addons, {GetAddOnInfo(i), memory})
			end
		end
	end
	table.sort(addons, function(a, b) return a[2] > b[2] end)

	for k, v in pairs(addons) do
    -- color addons red if using more than 1MB
		if v[2] > 1000 then
			GameTooltip:AddDoubleLine(format("%s", v[1]), FormatMemory(v[2]), 0, 1, 1, 1, .5, .5)
		else
			GameTooltip:AddDoubleLine(format("%s", v[1]), FormatMemory(v[2]), 0, 1, 1, 0, 1, 0)
		end
	end

	GameTooltip:AddLine("|r", 1, 1, 1)
	GameTooltip:AddDoubleLine("|rTotal Memory Usage: ", FormatMemory(total), 1, 1, 1, 1, 1, 1)
	GameTooltip:Show()
end

btn:Show()

f:EnableMouse(true)

---------------------------------------------------------
-- Register Events
---------------------------------------------------------
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("ZONE_CHANGED_INDOORS")
f:RegisterEvent("MINIMAP_UPDATE_TRACKING")
f:RegisterEvent("UNIT_HAPPINESS")
f:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
f:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
f:RegisterEvent("FRIENDLIST_UPDATE")
f:RegisterEvent("PLAYER_MONEY")
f:RegisterEvent("UNIT_DAMAGE")
f:RegisterEvent("GUILD_ROSTER_UPDATE")
f:RegisterEvent("PLAYER_GUILD_UPDATE")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UPDATE_PENDING_MAIL")
f:RegisterEvent("MAIL_CLOSED")
f:RegisterEvent("MAIL_SHOW")
f:RegisterEvent("MAIL_INBOX_UPDATE")
f:RegisterEvent("UPDATE_PENDING_MAIL")
f:RegisterEvent("PLAYER_XP_UPDATE")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("UPDATE_EXHAUSTION")
f:RegisterEvent("MERCHANT_SHOW")
f:RegisterEvent("UPDATE_FACTION")

-- show infostrip
f:Show()

---------------------------------------------------------
-- Register chat commands
---------------------------------------------------------
SLASH_INFOSTRIP1 = "/infostrip"
SLASH_RELOADUI1 = "/rl"

SlashCmdList["RELOADUI"] = function (msg, editBox)
	ChatFrame1EditBox:SetText("/reload ui")
	ChatEdit_ParseText(ChatFrame1EditBox, 1)
end

SlashCmdList["INFOSTRIP"] = function (msg, editBox)
	if msg == "hide" then
		f:Hide()
	elseif msg == "show" then
		f:Show()
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cff00CCFFOptions for /infostrip")
		DEFAULT_CHAT_FRAME:AddMessage("|cff00CCFF   -show : Shows the bar")
		DEFAULT_CHAT_FRAME:AddMessage("|cff00CCFF   -hide : Hides the bar")
	end
end

---------------------------------------------------------
-- Main OnLoad Function
---------------------------------------------------------
function InfoStrip_eventHandler(self, event, arg1, arg2, ...)
	local _,numFriends = GetNumFriends()
	local _,bnFriends = BNGetNumFriends()
  	local durability = GetDurability()
  	local name, subName = '', ''
  	local canGuildRepair = CanGuildBankRepair()
	local friends = numFriends + bnFriends
	local totalTimePlayed = 0
	local totalTimeLevel = 0

	if event == "PLAYER_XP_UPDATE" or event == "PLAYER_LEVEL_UP" or event == "PLAYER_ENTERING_WORLD" then
		if UnitLevel("player") < 100 then
			levelinfo:SetFormattedText("XP: %d%%", (UnitXP("player") / UnitXPMax("player") * 100))
		end 
	elseif event == "MERCHANT_SHOW" then
		SellGreyItems()
		RepairItems()
	end

	friendbtn:SetText("Friends: "..friends)
	btn:SetFormattedText(getTrackingText())

	if IsInGuild() then
    	local numGuildMembers, numOnline, numOnlineAndMobile = GetNumGuildMembers()
		guildiesbtn:SetText("Guildies: "..numOnline)
	end

	if HasNewMail() then
		mailbtn:SetText("New Mail!")
	else
		mailbtn:SetText("No Mail")
	end

	if IsInInstance() then
		name, subName = select(1, GetInstanceInfo()), select(4, GetInstanceInfo())
	else
		name, subName = GetZoneText(), GetSubZoneText()
	end

  	fs:SetFormattedText("%s     %s: %s     Durability: %s%%", GetCoinTextureString(GetMoney()), name or '', subName or '', durability)  

	local factionname,standingID,barMin,barMax,barValue = GetWatchedFactionInfo()
	if factionname ~= nil then
		repfs:SetFormattedText("Rep: %s - "..FACTION_STANDINGS[standingID].." (%d%%)", factionname, math.floor(((barValue-barMin)/(barMax-barMin)) * 100))	
	end
end

---------------------------------------------------------
-- Helper Functions
---------------------------------------------------------
function FindInSet(set, item) 
	for k, v in pairs(set) do
		if v == item then return true end
	end

	return false
end

local function hidetooltip(self)
	GameTooltip:Hide()
end

function SellGreyItems()
  for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			if not(GetContainerNumSlots(bag) == nil) then
				itemInfo = GetContainerItemLink(bag, slot)

				if itemInfo ~= nil then
					local name,_,quality,_,_,_,_,_,_,_,vendorPrice = GetItemInfo(itemInfo)

					if quality == 0 then
						UseContainerItem(bag, slot)

            			DEFAULT_CHAT_FRAME:AddMessage(format("|cff00CCFFSelling inventory item %s for %s", name, vendorPrice))
					end
				end
			end
		end
	end
end

function RepairItems()
  	local canRepair = CanMerchantRepair()
	-- Auto repair items
	if canRepair then
		local repairCost = GetRepairAllCost()
		local cost = GetCoinTextureString(repairCost)

		if GetMoney() > repairCost then
			RepairAllItems(canGuildRepair)
			DEFAULT_CHAT_FRAME:AddMessage("|cff00CCFFRepaired all items for the cost of "..cost)
		else
			local neededFunds = repairCost - GetMoney()
			DEFAULT_CHAT_FRAME:AddMessage("|cff00CCFFCan't repair items. Need "..neededFunds)
		end
	end
end

function FormatMemory(usage)
	if usage > 1000 then
		return format('%.2f mb', usage/1024)
	elseif usage > 0 then
		return format('%.2f kb', usage)
	end
end

function classColor(className)
	if CLASS_COLORS[className] == nil then
		return {1,1,1}
	else
		return {CLASS_COLORS[className][1], CLASS_COLORS[className][2], CLASS_COLORS[className][3]}
	end
end

function GetDurability()
	local have = 0
	local most = 0

	for i = 1, 19 do
		local current, max = GetInventoryItemDurability(i)

		if current ~= nil then
			have = have + current
			most = most + max
		end
	end

	return math.floor((have/most) * 100)
end

function getTrackingText()
	local num = 0

	for i=1, GetNumTrackingTypes() do
		local name, texture, active, category = GetTrackingInfo(i)

		if active then
			num = num + 1
		end
	end

	return "Tracking: "..num
end

function InfoStrip_changeTrack(self, button, ...)
	ToggleDropDownMenu(1, nil, TrackerDropDownMenu, self:GetName(), 0, 0)
end

function GetMin(min)
	if min < 10 then
		return "0"..min
	end
	return min
end

function GetHour(hour)
	if hour > 12 then
		hour = hour - 12
	end
	if hour < 10 then
		return "0"..hour
	end
	return hour
end

function GetDST(hour)
	if hour < 12 then
		return 'AM'
	else
		return 'PM'
	end
end

---------------------------------------------------------
-- Event Functions
---------------------------------------------------------
badgebtn:SetScript("OnEnter", badgeTooltip)
badgebtn:SetScript("OnLeave", hidetooltip)

clockbtn:SetScript("OnEnter", clockTooltip)
clockbtn:SetScript("OnLeave", hidetooltip)

friendbtn:SetScript("OnEnter", friendsTooltip)
friendbtn:SetScript("OnLeave", hidetooltip)
friendbtn:SetScript("OnClick", function(...) ToggleFriendsFrame(1) end)

if IsInGuild() then
	guildiesbtn:SetScript("OnEnter", guildiesTooltip)
	guildiesbtn:SetScript("OnLeave", hidetooltip)
end

mailbtn:SetScript("OnEnter", showmailtip)
mailbtn:SetScript("OnLeave", hidemailtip)

repbtn:SetScript("OnEnter", repTooltip)
repbtn:SetScript("OnLeave", hidetooltip)
repbtn:SetScript("OnClick", function(...) ToggleCharacter("ReputationFrame") end)

levelbtn:SetScript("OnEnter", xpTooltip)
levelbtn:SetScript("OnLeave", hidetooltip)
levelbtn:SetScript("OnClick", function(...) RequestTimePlayed() end)

membtn:SetScript("OnEnter", memtooltip)
membtn:SetScript("OnLeave", hidetooltip)

f:SetScript("OnEvent", InfoStrip_eventHandler)
btn:SetScript("OnClick", InfoStrip_changeTrack)
f:SetScript("OnUpdate", function(self, elapsed)
	TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed
	if TimeSinceLastUpdate >= 1 then
		GuildRoster()
		local hour, min = GetGameTime()
		local unitx, unity = GetPlayerMapPosition("player")

		memfs:SetFormattedText("%dms %dfps", select(3, GetNetStats()), GetFramerate())
		timefs:SetFormattedText("(%d, %d)  %s:%s %s", (unitx * 100), (unity * 100), GetHour(hour), GetMin(min), GetDST(hour))
		TimeSinceLastUpdate = 0
	end
end)
