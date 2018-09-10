-----------------------------------------------------
-- GLOBAL VARIABLES
-----------------------------------------------------
local space = 5 -- Space between each frame
local fontheight = 11 -- Fontsize
local font = "Interface\\AddOns\\InfoStrip\\font.ttf" -- Font
local trackBadges = {
    "War Resources"
} -- Badge names to track

local MAX_ADDONS = 15 -- Maximum addons to display in dropdown list
local MAX_GUILDIES = 25 -- Maximum guild members to display in dropdown list
local MAX_FACTIONS = 25 -- Maximum factions to display in dropdown list
local MAX_LEVEL = 120

function Set(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

local screenWidth = GetScreenWidth() * UIParent:GetEffectiveScale()
local TimeSinceLastUpdate = 0
local money = 0

local C_AzeriteItem_FindActiveAzeriteItem = C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = C_AzeriteItem.GetPowerLevel

local GetPlayerMapPosition = GetPlayerMapPosition

if C_Map then   -- From 8.0
    GetBestMapForUnit = C_Map.GetBestMapForUnit
    GetPlayerMapPosition = C_Map.GetPlayerMapPosition
else
    local GetCursorPosition = GetCursorPosition
end

local xPlayer, yPlayer, xCursor, yCursor;

local CLASS_COLORS = {
    ["HUNTER"] = { 0.67, 0.83, 0.45 },
    ["WARLOCK"] = { 0.58, 0.51, 0.79 },
    ["PRIEST"] = { 1.0, 1.0, 1.0 },
    ["PALADIN"] = { 0.96, 0.55, 0.73 },
    ["MAGE"] = { 0.41, 0.8, 0.94 },
    ["ROGUE"] = { 1.0, 0.96, 0.41 },
    ["DRUID"] = { 1.0, 0.49, 0.04 },
    ["SHAMAN"] = { 0.0, 0.44, 0.87 },
    ["WARRIOR"] = { 0.78, 0.61, 0.43 },
    ["DEATH KNIGHT"] = { 0.77, 0.12, 0.23 },
    ["DEMON HUNTER"] = { 0.64, 0.19, 0.79 },
    ["MONK"] = { 0.00, 1.00, 0.59 }
}

local FACTION_BAR_COLORS = {
    { r = 0.8, g = 0.133, b = 0.133 },
    { r = 1, g = 0, b = 0 },
    { r = 0.933, g = 0.4, b = 0.133 },
    { r = 1, g = 1, b = 0 },
    { r = 0.749, g = 1, b = 0 },
    { r = 0, g = 1, b = 0.533 },
    { r = 0, g = 1, b = 0.8 },
    { r = 0, g = 1, b = 1 }
};

local FACTION_STANDINGS = { "Hated", "Hostile", "Unfriendly", "Neutral", "Friendly", "Honored", "Revered", "Exalted" }

local f = CreateFrame("FRAME", "InfoStrip", UIParent)
f:SetWidth(screenWidth)
f:SetHeight(15)
f:SetPoint("TOPLEFT", 0, 0)
f:SetPoint("TOPRIGHT", 0, 0)

f:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"})
f:SetBackdropColor(0, 0, 0) --Set the background colour to black
f:SetPoint("CENTER") --Put it in the centre of the parent frame (UIParent)

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

--Guildies button
local guildiesbtn = CreateFrame("BUTTON", "InfoStripGuildiesBtn", f)
guildiesbtn:SetWidth(75)
guildiesbtn:SetHeight(10)
local guildiesfs = guildiesbtn:CreateFontString()
guildiesfs:SetFont(font, fontheight)
guildiesbtn:SetFontString(guildiesfs)
guildiesbtn:SetPoint("LEFT", friendbtn, "RIGHT", space, 0)

-- Main text
local fs = f:CreateFontString(nil, "LOW")
fs:SetFont(font, fontheight)
fs:SetPoint("LEFT", guildiesbtn, "RIGHT", space, 0)

--[[RIGHT SIDE]] --

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

if UnitLevel("player") < MAX_LEVEL then
    levelbtn:SetPoint("RIGHT", membtn, "LEFT", -10, 0)
end

--Reputation info
local repbtn = CreateFrame("BUTTON", "InfoStripRepBtn", f)
repbtn:SetWidth(200)
repbtn:SetHeight(10)
local repfs = repbtn:CreateFontString()
repfs:SetFont(font, fontheight)
repbtn:SetFontString(repfs)
if UnitLevel("player") < MAX_LEVEL then
    repbtn:SetPoint("RIGHT", levelbtn, "LEFT", -10, 0)
else
    repbtn:SetPoint("RIGHT", membtn, "LEFT", -10, 0)
end

--Missons button (was Class Hall/Order Hall)
local classhallbtn = CreateFrame("BUTTON", "InfoStripClassHallBtn", f)
classhallbtn:SetWidth(40)
classhallbtn:SetHeight(10)
local classhallfs = classhallbtn:CreateFontString()
classhallfs:SetFont(font, fontheight)
classhallbtn:SetFontString(classhallfs)
classhallbtn:SetText("Missons")
classhallbtn:SetPoint("RIGHT", repbtn, "LEFT", -10, 0)

--World Quests
local wqbtn = CreateFrame("BUTTON", "InfoStripWQBtn", f)
wqbtn:SetWidth(75)
wqbtn:SetHeight(10)
local wqfs = wqbtn:CreateFontString()
wqfs:SetFont(font, fontheight)
wqbtn:SetFontString(wqfs)
wqbtn:SetText("World Quests")
wqbtn:SetPoint("RIGHT", classhallbtn, "LEFT", -10, 0)

--Azerite Info
local azeritebtn = CreateFrame("BUTTON", "InfoStripAzeriteBtn", f)
azeritebtn:SetWidth(50)
azeritebtn:SetHeight(10)
local azeritefs = azeritebtn:CreateFontString()
azeritefs:SetFont(font, fontheight)
azeritebtn:SetFontString(azeritefs)
azeritebtn:SetText("Azerite")
azeritebtn:SetPoint("RIGHT", wqbtn, "LEFT", -10, 0)

--Threat Button
local threatbtn = CreateFrame("BUTTON", "InfoStripThreatBtn", f)
threatbtn:SetWidth(175)
threatbtn:SetHeight(10)
local threatfs = threatbtn:CreateFontString()
threatfs:SetFont(font, fontheight)
threatbtn:SetFontString(threatfs)
threatbtn:SetText("Threat")
threatbtn:SetPoint("RIGHT", azeritebtn, "LEFT", -10, 0)

---------------------------------------------------------
-- Tracking Drop down menu
---------------------------------------------------------
local TrackerDropDownMenu = CreateFrame("Frame", "TrackerDropDownMenu")
TrackerDropDownMenu.displayMode = "MENU"
TrackerDropDownMenu.initialize = function(self, level) end

local tracking_items = {}
TrackerDropDownMenu.initialize = function(self, level)
    if not level then
        return
    end

    wipe(tracking_items)

    if level == 1 then
        tracking_items.disabled = nil
        tracking_items.isTitle = nil
        tracking_items.notCheckable = nil

        local num = GetNumTrackingTypes()

        for i = 1, num do
            local name, texture, active, category = GetTrackingInfo(i)

            tracking_items.text = name
            tracking_items.checked = active
            tracking_items.func = function()
                SetTracking(i, not active)
            end

            UIDropDownMenu_AddButton(tracking_items, level)
        end
    end
end

---------------------------------------------------------
-- Tooltips
---------------------------------------------------------

-- Tooltip Badges
local function tooltipBadges(self)
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -25)
    GameTooltip:SetText("Badges", 1, 1, 1)

    for i = 1, GetCurrencyListSize() do
        local name, _, _, _, _, count, _, _, _ = GetCurrencyListInfo(i)
        local found = FindInSet(trackBadges, name)

        if found then
            GameTooltip:AddDoubleLine(name, comma_value(count), nil, nil, nil, 1, 1, 1)
        end
    end

    GameTooltip:Show()
end

-- Tooltip Guildies
local function tooltipGuildies(self)
    if IsInGuild() then
        local members = {}
        local numGuildMembers, numOnline, numOnlineAndMobile = GetNumGuildMembers()

        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -25)
        GameTooltip:SetText("Guildies", 1, 1, 1)

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
            if v.level == MAX_LEVEL then
                GameTooltip:AddDoubleLine(v.name, v.level, v.colors[1], v.colors[2], v.colors[3], 0, 1, 0)
            else
                GameTooltip:AddDoubleLine(v.name, v.level, v.colors[1], v.colors[2], v.colors[3], 1, 1, 1)
            end
        end

        GameTooltip:Show()
    end
end

-- Format class hall mission rewards to string
local function formatRewards(rewards, numRewards)
    local rtn = ''
    local index = 1

    for id, reward in pairs(rewards) do
        local Reward = {};
        Reward.itemID = nil;
        Reward.currencyID = nil;
        Reward.tooltip = nil;

        if (reward.itemID) then
            local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(reward.itemID)

            if name then
                Reward.tooltip = "Item: " .. name
            else
                Reward.tooltip = "Item"
            end
        else
            Reward.title = reward.title

            if (reward.currencyID and reward.quantity) then
                if (reward.currencyID == 0) then
                    Reward.tooltip = GetMoneyString(reward.quantity);
                else
                    local name, _, _, _, _, _, _ = GetCurrencyInfo(reward.currencyID)
                    Reward.tooltip = reward.quantity .. " " .. name
                end
            else
                Reward.tooltip = reward.tooltip;
            end
        end

        index = index + 1

        if Reward.tooltip ~= nil then
            rtn = rtn .. ' ' .. Reward.tooltip
        end
    end

    return rtn
end

-- Tooltip Class Hall
local function tooltipClassHall(self)
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -25)
    GameTooltip:SetText("Missons", 1, 1, 1)

    local indent = 5
    local missions = { completed = {}, inprogress = {}, available = {} }

    -- Completed/In Progress mission information
    local items = C_Garrison.GetLandingPageItems(LE_GARRISON_TYPE_8_0) or {}

    for i = 1, #items do
        local item = items[i]

        if (item) then
            local key = missions.inprogress

            if item.isBuilding then
                key = missions.building
            else
                if item.isComplete then
                    key = missions.completed
                elseif item.inprogress then
                    key = missions.inprogress
                end
            end

            table.insert(key, item)
        end
    end

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(#missions.completed .. " Completed")
    GameTooltip:AddDoubleLine("Name", "Rewards")

    for k, v in pairs(missions.completed) do
        GameTooltip:AddDoubleLine(v.name, formatRewards(v.rewards, v.numrewards), 1, 1, 1, 1, 1, 1)
    end

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(#missions.inprogress .. " In Progress")
    GameTooltip:AddDoubleLine("Name", "Time Left")

    -- sort by time left
    table.sort(missions.inprogress, function(a, b) return a.timeLeft < b.timeLeft end)

    for k, v in pairs(missions.inprogress) do
        GameTooltip:AddDoubleLine(v.name, v.timeLeft, 1, 1, 1, 1, 1, 1)
    end

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(#missions.available .. " Available")
    GameTooltip:AddDoubleLine("Name (blue=rare)", "Rewards")

    -- sort by level
    table.sort(missions.available, function(a, b) return a.level > b.level end)

    for k, v in pairs(missions.available) do
        local colors = { 1, 1, 1 }

        if v.isRare then
            colors = { 0, 1, 1 }
        end

        GameTooltip:AddDoubleLine("(" .. v.level .. ") " .. v.name .. "\n" .. string.rep(" ", indent) .. v.cost .. " resources, " .. v.numFollowers .. " follower", formatRewards(v.rewards, v.numrewards), colors[1], colors[2], colors[3], 1, 1, 1)
    end

    GameTooltip:Show()
end

-- Tooltip Friends
local function tooltipFriends(self)
    local _, numFriends = GetNumFriends()
    local _, bnFriends = BNGetNumFriends()
    local totalFriends = numFriends + bnFriends
    local friends = {}

    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -25)
    GameTooltip:AddLine(numFriends .. " Friend(s) Online")

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
    GameTooltip:AddLine(bnFriends .. " BattleNet Friend(s) Online")

    friends = {} -- reset friends table

    for j = 1, BNGetNumFriends() do
        local bnetIDAccount  = BNGetFriendInfo(j)
        local _, accountName, _, _, _, bnetIDGameAccount, client, isOnline = BNGetFriendInfoByID(bnetIDAccount)

        if isOnline and client ~= nil and client ~= "App" then
            local _, characterName, _, realmName, realmID, _, _, class, _, _, level  = BNGetGameAccountInfo(bnetIDGameAccount)

            local colors = classColor(string.upper(class))

           table.insert(friends, { name = accountName, toonName = characterName, level = level, realmName = realmName, colors = colors })
        end
    end

    -- sort by name
    table.sort(friends, function(a, b) return a.name < b.name end)

    for k, v in pairs(friends) do
        -- user online but not playing anything
        if v.toonName == nil or v.toonName == "" then
            GameTooltip:AddDoubleLine("" .. v.name, v.level, v.colors[1], v.colors[2], v.colors[3], 1, 1, 1)
        else
            GameTooltip:AddDoubleLine("" .. v.name .. " on " .. v.toonName .. "-" .. v.realmName, v.level, v.colors[1], v.colors[2], v.colors[3], 1, 1, 1)
        end
    end

    GameTooltip:Show()
end


-- Tooltip Mail
local function tooltipMail(self)
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
local function tooltipXP(self)
    if UnitLevel("player") < MAX_LEVEL then
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -10, -25)
        GameTooltip:SetText("Experience", 1, 1, 1)
        GameTooltip:AddDoubleLine("Total: ", comma_value(UnitXP('player')), nil, nil, nil, 1, 1, 1)
        --GameTooltip:AddDoubleLine("XP till next level: ", comma_value(UnitXPMax('player')), nil, nil, nil, 1, 1, 1)
        GameTooltip:AddDoubleLine("Needed Until Next Level: ", comma_value(UnitXPMax('player')-UnitXP('player')), nil, nil, nil, 1, 1, 1)
        if GetXPExhaustion() > 0 then
            GameTooltip:AddDoubleLine("|c0000ff00Rested XP ", comma_value(GetXPExhaustion()) .. "|r", 1, 1, 1, 1, 1, 1)
        end
        GameTooltip:Show()
    end
end

-- Tooltip Rep
local function tooltipReputation(self)
    local totalReps = 0
    local factions = {}
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -10, -25)
    GameTooltip:SetText("Reputation", 1, 1, 1)

    for i = 1, GetNumFactions() do
        local name, _, standingID, barMin, barMax, barValue, _, _, _, _, _, _, _ = GetFactionInfo(i)
        local perc = math.floor(((barValue - barMin) / (barMax - barMin)) * 100)

        -- only show reps that are friendly to revered
        if standingID >= 5 and standingID < 8 and totalReps <= MAX_FACTIONS then
            totalReps = totalReps + 1
            table.insert(factions, { name = name, standingID = standingID, standing = FACTION_STANDINGS[standingID], perc = perc, colors = FACTION_BAR_COLORS[standingID] })
        end
    end

    table.sort(factions, function(a, b) return a.standingID > b.standingID end)

    for k, v in pairs(factions) do
        GameTooltip:AddDoubleLine(v.name, v.standing .. " |r(" .. v.perc .. "%)", 1, 1, 1, v.colors.r, v.colors.g, v.colors.b)
    end

    GameTooltip:Show()
end

-- Tooltip Clock
local function tooltipClock(self)
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
local function tooltipMemoryUsage(self)
    local addons = {}
    local total = 0
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -10, -25)
    GameTooltip:SetText("Memory Usage", 1, 1, 1)
    UpdateAddOnMemoryUsage()

    for i = 1, GetNumAddOns() do
        if IsAddOnLoaded(i) and table.getn(addons) <= MAX_ADDONS then
            memory = GetAddOnMemoryUsage(i)

            if memory > 0 then
                total = total + memory
                table.insert(addons, { GetAddOnInfo(i), memory })
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

-- money tooltip
local function tooltipMoney(self)
    local chars = {}
    local total = 0

    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", 450, -25)
    GameTooltip:SetText("Characters", 1, 1, 1)

    for character, data in pairs(Infostrip) do
        total = total + data.money
        table.insert(chars, { name = character, money = data.money, class = data.class })
    end

    table.sort(chars, function(a, b) return a.money > b.money end)

    for i, data in pairs(chars) do
        local colors = classColor(data.class)

        GameTooltip:AddDoubleLine(format("%s", data.name), format("%s", GetCoinTextureString(data.money)), colors[1], colors[2], colors[3], 1, 1, 1)
    end

    GameTooltip:AddLine("|r", 1, 1, 1)
    GameTooltip:AddDoubleLine("|rTotal: ", format("%s", GetCoinTextureString(total)), 1, 1, 1, 1, 1, 1)
    GameTooltip:Show()
end

--azerite tooltip
function tooltipAzerite(self)
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -10, -25)
    GameTooltip:SetText("Azerite Info", 1, 1, 1)

    local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()

    if azeriteItemLocation then
        local xp, totalLevelXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
        local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)
        local xpToNextLevel = totalLevelXP - xp

        GameTooltip:AddDoubleLine("Current Level", currentLevel, nil, nil, nil, 1, 1, 1)
        GameTooltip:AddDoubleLine("XP to Next Level", (xpToNextLevel - xp), nil, nil, nil, 1, 1, 1)
        GameTooltip:AddDoubleLine("Percent In", format('%s%%', floor(xp / xpToNextLevel * 100)), nil, nil, nil, 1, 1, 1)

        GameTooltip:Show()
    end
end

-- Tooltip World Quests
function tooltipWorldQuests(self)
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -10, -25)
    GameTooltip:SetText("World Quests", 1, 1, 1)

    local MAP_ZONES = {
        [863] = { id = 863, quests = {}, money = {}, item = {}, currency = {}, name = "Nazmir" },  -- Nazmir
        [864] = { id = 864, quests = {}, money = {}, item = {}, currency = {}, name = "Vol'dun" },  -- Vol'dun
        [862] = { id = 862, quests = {}, money = {}, item = {}, currency = {}, name = "Zuldazar" },  -- Zuldazar
        [895] = { id = 895, quests = {}, money = {}, item = {}, currency = {}, name = "Tiragarde" },  -- Tiragarde
        [942] = { id = 942, quests = {}, money = {}, item = {}, currency = {}, name = "Stormsong Valley" },  -- Stormsong Valley
        [896] = { id = 896, quests = {}, money = {}, item = {}, currency = {}, name = "Drustvar" },  -- Drustvar
        [14]  = { id =  14, quests = {}, name = "Arathi" },  -- Arathi
    }

    for mapId in next, MAP_ZONES do
        GameTooltip:AddDoubleLine(MAP_ZONES[mapId].name, "", 1, 1, 1, 1, 1, 1)
        local taskInfo = C_TaskQuest.GetQuestsForPlayerByMapID(mapId)

        if taskInfo then
            for i, info in ipairs(taskInfo) do
                local questID = info.questId
                local tagId, tagName, worldQuestType, isRare, isElite, tradeskillLineIndex = GetQuestTagInfo(questID)

                if worldQuestType ~= nil then
                    local quest = {}

                    quest.questId = questID
                    quest.tagId = tagId
                    quest.tagName = tagName
                    quest.worldQuestType = worldQuestType
                    quest.isRare = isRare
                    quest.isElite = isElite
                    local title, _ = C_TaskQuest.GetQuestInfoByQuestID(questID)
                    quest.title = title
                    quest.reward = ''
                    quest.rewardType = ''

                    -- get rewards
                    if GetQuestLogRewardMoney(questID) > 0 then
                        quest.reward = GetCoinTextureString(GetQuestLogRewardMoney(questID))
                        quest.rewardType = 'money'
                    elseif GetNumQuestLogRewards(questID) > 0 then
                        local _, _, _, quality, _, itemId = GetQuestLogRewardInfo(1, questID)

                        if itemId then
                            local itemName, itemLink, _, itemLevel, _, itemType = GetItemInfo(itemId)

                            if (itemType == ARMOR or itemType == WEAPON) then
                                quest.reward = itemLink
                            elseif IsArtifactRelicItem(itemId) then
                                quest.reward = "Relic";
                            else
                                quest.reward = itemName;
                            end
                        end
                        quest.rewardType = 'item'
                    elseif GetQuestLogRewardHonor(questID) > 0 then
                        quest.reward = "Honor "..GetQuestLogRewardHonor(questID)
                    elseif GetNumQuestLogRewardCurrencies(questID) > 0 then
                        local name, _, numItems, rewardId = GetQuestLogRewardCurrencyInfo(GetNumQuestLogRewardCurrencies(questID), questID)
                        quest.reward = name.." ("..numItems..")"
                        quest.rewardType = 'currency'
                    end


                    -- hide pvp/dungeon/pet battle quests
                    if info.worldQuestType ~= LE_QUEST_TAG_TYPE_PVP
                            and info.worldQuestType ~= LE_QUEST_TAG_TYPE_PET_BATTLE
                            and info.worldQuestType ~= LE_QUEST_TAG_TYPE_DUNGEON
                            and info.worldQuestType ~= LE_QUEST_TAG_TYPE_RAID then

                        table.insert(MAP_ZONES[mapId].quests, quest)

                        if quest.rewardType ~= '' then
                            table.insert(MAP_ZONES[mapId][quest.rewardType], quest)
                        end
                    end
                end
            end

            for i, info in ipairs(MAP_ZONES[mapId].quests) do
                local color = { r = nil, g = nil, b = nil }

                if info.isElite then
                    color = ITEM_QUALITY_COLORS[4]
                end

                -- only show quests that reward items
                if info.rewardType == 'item' or info.isElite == true then
                    GameTooltip:AddDoubleLine(info.title, info.reward, color.r, color.g, color.b, 1, 1, 1)
                end
            end
        end

        GameTooltip:Show()
    end
end

function onMainUpdate(self, elapsed)
    TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed

    if TimeSinceLastUpdate >= 1 then
        GuildRoster()

        if IsInInstance() then
            xPlayer, yPlayer = 0, 0
        else
            local bestMap = GetBestMapForUnit( "player" )
            if bestMap then -- Will be nil for a short moment while hearthing / zen pilgrimage / etc
                xPlayer, yPlayer = GetPlayerMapPosition( bestMap, "player" ):GetXY()
            end
        end
        --local position = C_Map.GetPlayerMapPosition(C_Map.GetBestMapForUnit("player"), "player")
        dateInfo = date("*t")

        memfs:SetFormattedText("%dms %dfps", select(3, GetNetStats()), GetFramerate())
        timefs:SetFormattedText("(%d, %d)     %s:%s %s", (xPlayer * 100), (yPlayer * 100), GetHour(dateInfo.hour), GetMin(dateInfo.min), GetDST(dateInfo.hour))
        TimeSinceLastUpdate = 0
    end
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
f:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
f:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
f:RegisterEvent("FRIENDLIST_UPDATE")
f:RegisterEvent("PLAYER_MONEY")
f:RegisterEvent("UNIT_DAMAGE")
f:RegisterEvent("GUILD_ROSTER_UPDATE")
f:RegisterEvent("PLAYER_GUILD_UPDATE")
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
f:RegisterEvent("GARRISON_FOLLOWER_ADDED")
f:RegisterEvent("GARRISON_FOLLOWER_REMOVED")
f:RegisterEvent("GARRISON_TALENT_UPDATE")
f:RegisterEvent("GARRISON_TALENT_COMPLETE")
f:RegisterEvent("GARRISON_MISSION_FINISHED")
f:RegisterEvent("GARRISON_MISSION_STARTED")
f:RegisterEvent("GARRISON_BUILDING_UPDATE")
f:RegisterEvent("GARRISON_LANDINGPAGE_SHIPMENTS")
f:RegisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED")
f:RegisterEvent("ARTIFACT_UPDATE")
f:RegisterEvent("ARTIFACT_XP_UPDATE")
f:RegisterEvent("UNIT_INVENTORY_CHANGED")
f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("PLAYER_LOGOUT")
f:RegisterEvent("ADDON_LOADED")

-- show infostrip
f:Show()

---------------------------------------------------------
-- Register chat commands
---------------------------------------------------------
SLASH_INFOSTRIP1 = "/infostrip"
SLASH_RELOADUI1 = "/rl"

SlashCmdList["RELOADUI"] = function(msg, editBox)
    ChatFrame1EditBox:SetText("/reload ui")
    ChatEdit_ParseText(ChatFrame1EditBox, 1)
end

SlashCmdList["INFOSTRIP"] = function(msg, editBox)
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
    local _, numFriends = GetNumFriends()
    local _, bnFriends = BNGetNumFriends()
    local durability = GetDurability()
    local name, subName = '', ''
    local canGuildRepair = CanGuildBankRepair()
    local friends = numFriends + bnFriends

    -- global variables
    if event == "PLAYER_XP_UPDATE" or event == "PLAYER_LEVEL_UP" or event == "PLAYER_ENTERING_WORLD" then
        if UnitLevel("player") < MAX_LEVEL then
            levelinfo:SetFormattedText("XP: %d%%", (UnitXP("player") / UnitXPMax("player") * 100))
        end
    elseif event == "MERCHANT_SHOW" then
        SellGreyItems()
        RepairItems()
    end

    -- save/get currenty from all characters
    if event == "PLAYER_MONEY" then
        Infostrip[GetUnitName("player")].money = GetMoney()
    end

    if event == "ADDON_LOADED" and arg1 == "InfoStrip" then
        if Infostrip == nil then
            Infostrip = {}
        end

        if Infostrip[GetUnitName("player")] == nil then
            class, classFileName = UnitClass("player")

            Infostrip[GetUnitName("player")] = { money = GetMoney(), class = classFileName }
        end
    end

    if event == "PLAYER_LOGOUT" then
         Infostrip[GetUnitName("player")].money = GetMoney()
    end

    friendbtn:SetText("Friends: " .. friends)
    btn:SetFormattedText(getTrackingText())

    calculateThreat()

    if IsInGuild() then
        local numGuildMembers, numOnline, numOnlineAndMobile = GetNumGuildMembers()
        guildiesbtn:SetText("Guildies: " .. numOnline)
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

    local factionname, standingID, barMin, barMax, barValue = GetWatchedFactionInfo()
    if factionname ~= nil then
        repfs:SetFormattedText("Rep: %s - " .. FACTION_STANDINGS[standingID] .. " (%d%%)", factionname, math.floor(((barValue - barMin) / (barMax - barMin)) * 100))
    end
end

---------------------------------------------------------
-- Helper Functions
---------------------------------------------------------
function ternary(cond, T, F)
    if cond then return T else return F end
end

function calculateThreat()
    local inCombat = UnitAffectingCombat("player")
    local status = UnitThreatSituation("player")
    local ThreatText = ""
    local Color = {
        ["green"] = "|cff00ff00",
        ["yellow"] = "|cffffff00",
        ["orange"] = "|cffFF4500",
        ["red"] = "|cffff0000"
    }

    if inCombat and status then
        if status == 0 or status == 1 then
            ThreatText = string.format("%sTHREAT", Color.yellow)
        elseif status == 2 then
            ThreatText = string.format("%sWEAK AGGRO", Color.orange)
        elseif status == 3 then
            ThreatText = string.format("%sAGGRO", Color.red)

        end
    end

    threatfs:SetText(ThreatText)
end

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
            if not (GetContainerNumSlots(bag) == nil) then
                itemInfo = GetContainerItemLink(bag, slot)

                if itemInfo ~= nil then
                    local name, _, quality, _, _, _, _, _, _, _, vendorPrice = GetItemInfo(itemInfo)

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
            DEFAULT_CHAT_FRAME:AddMessage("|cff00CCFFRepaired all items for the cost of " .. cost)
        else
            local neededFunds = repairCost - GetMoney()
            DEFAULT_CHAT_FRAME:AddMessage("|cff00CCFFCan't repair items. Need " .. neededFunds)
        end
    end
end

function FormatMemory(usage)
    if usage > 1000 then
        return format('%.2f mb', usage / 1024)
    elseif usage > 0 then
        return format('%.2f kb', usage)
    end
end

function classColor(className)
    if CLASS_COLORS[className] == nil then
        return { 1, 1, 1 }
    else
        return { CLASS_COLORS[className][1], CLASS_COLORS[className][2], CLASS_COLORS[className][3] }
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

    return math.floor((have / most) * 100)
end

function getTrackingText()
    local num = 0

    for i = 1, GetNumTrackingTypes() do
        local name, texture, active, category = GetTrackingInfo(i)

        if active then
            num = num + 1
        end
    end

    return "Tracking: " .. num
end

function InfoStrip_changeTrack(self, button, ...)
    ToggleDropDownMenu(1, nil, TrackerDropDownMenu, self:GetName(), 0, 0)
end

function GetMin(min)
    if min < 10 then
        return "0" .. min
    end
    return min
end

function GetHour(hour)
    if hour > 12 then
        hour = hour - 12
    end
    if hour < 10 then
        return "0" .. hour
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


function tprint(tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            tprint(v, indent + 1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))
        else
            print(formatting .. v)
        end
    end
end

function print_r( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

function comma_value(amount)
    local formatted = amount

    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')

        if (k==0) then
            break
        end
    end

    return formatted
end

---------------------------------------------------------
-- Event Functions
---------------------------------------------------------
btn:SetScript("OnClick", InfoStrip_changeTrack)

badgebtn:SetScript("OnEnter", tooltipBadges)
badgebtn:SetScript("OnLeave", hidetooltip)

clockbtn:SetScript("OnEnter", tooltipClock)
clockbtn:SetScript("OnLeave", hidetooltip)

friendbtn:SetScript("OnEnter", tooltipFriends)
friendbtn:SetScript("OnLeave", hidetooltip)
friendbtn:SetScript("OnClick", function(...) ToggleFriendsFrame(1) end)

guildiesbtn:SetScript("OnEnter", tooltipGuildies)
guildiesbtn:SetScript("OnLeave", hidetooltip)

mailbtn:SetScript("OnEnter", tooltipMail)
mailbtn:SetScript("OnLeave", hidemailtip)

classhallbtn:SetScript("OnEnter", tooltipClassHall)
classhallbtn:SetScript("OnLeave", hidetooltip)

repbtn:SetScript("OnEnter", tooltipReputation)
repbtn:SetScript("OnLeave", hidetooltip)
repbtn:SetScript("OnClick", function(...) ToggleCharacter("ReputationFrame") end)

levelbtn:SetScript("OnEnter", tooltipXP)
levelbtn:SetScript("OnLeave", hidetooltip)
levelbtn:SetScript("OnClick", function(...) RequestTimePlayed() end)

membtn:SetScript("OnEnter", tooltipMemoryUsage)
membtn:SetScript("OnLeave", hidetooltip)

azeritebtn:SetScript("OnEnter", tooltipAzerite)
azeritebtn:SetScript("OnLeave", hidetooltip)

wqbtn:SetScript("OnEnter", tooltipWorldQuests)
wqbtn:SetScript("OnLeave", hidetooltip)

f:SetScript("OnEvent", InfoStrip_eventHandler)
--f:SetScript("OnEnter", tooltipMoney)
--f:SetScript("OnLeave", hidetooltip)

f:SetScript("OnUpdate", onMainUpdate)