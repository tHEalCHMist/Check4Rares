--- Small addon for checking rare spawns automatically on mouseover, nameplate spawn or targeting :)
--------- Debugging ---------
local Debug = function  (flag, str, ...)
	if ... then str = str:format(...) end
	if flag=="r" then 
	print(format("|cffff0000%s|r", str))
else if flag=="g" then
	print(format("|cff00ff00%s|r", str))
else if flag=="b" then
	print(format("|cff00D1FF%s|r", str))
end end end end
--------- Variables ---------
RaresSeenDB = RaresSeenDB or {}
NewRaresDB = NewRaresDB or {}


local rareSeen, red, green, blue, IareA = false, "r", "g", "b", ""
local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = "", "", "", "", "", "", ""
local currentArea, npc_id, version = "nothing yet", "", "V1.e"
local name, iCom, timer = "", false, 0
if UnitName("target") or UnitName("mouseover") ~= nil then name = UnitName("target") or UnitName("mouseover") else name = UnitName("player") end
local TinyTimer, TinyTimer2, loaded, initTime = 0, 0, false, 0
local rTarg = UnitName("player")
local continent,rares, seen, currentZone = GetCurrentMapContinent(), {}, false, ""
local Check4Rares = CreateFrame("Button", "Check4Rares", nil, "SecureActionButtonTemplate, ActionButtonTemplate, SecureHandlerClickTemplate, GlowBorderTemplate")

local holder = CreateFrame("Frame")
holder:RegisterEvent("PLAYER_REGEN_ENABLED")
holder:RegisterEvent("PLAYER_REGEN_DISABLED")
holder:SetScript("OnEvent", function(self, event)
    incombat = (event=="PLAYER_REGEN_ENABLED")
end)

Check4Rares:EnableMouse(true);
Check4Rares:RegisterForClicks("AnyUp")
Check4Rares:SetAttribute("type1", "macro")
Check4Rares:SetAttribute("macrotext", macrotext)
Check4Rares:SetClampedToScreen(true)
---Check4Rares:SetText("Check4Rares")
---Check4Rares.TNameText = Check4Rares:CreateFontString(nil, ARTWORK,"GameFontNormal");
---Check4Rares.TNameText:SetPoint("TOP",self,"TOP",0,-40);
---Check4Rares.TNameText:SetWordWrap(enable)
---Check4Rares.TNameText:SetText(format("|cffff00ff%s|r", "Micro_Rares %s",version ));
Check4Rares:SetSize(76, 76)
Check4Rares:SetPoint("BOTTOMRIGHT", -250,100)
Check4Rares:SetBackdropColor(0,0,0,0)
Check4Rares:SetBackdrop({
    bgFile   = "Interface\\FrameGeneral\\UI-Background-Marble",
	tile = true, tileSize = 16,
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3, },
})

Check4Rares:SetBackdropBorderColor(0, 0, 0)

Check4Rares:SetScript("OnMouseDown", function(self, btn) 
	if btn == "RightButton" then
		if UnitAffectingCombat("player")==false then
			Check4Rares.ModelView:ClearModel()
			Check4Rares.ModelView:Hide()
			Check4Rares:Hide()
			Debug(red, "Micro_Rares Reset"); 
			rareSeen = false; 
			TinyTimer = 0, 
			SetRaidTarget(name,0);
		else
			Debug(red, "Unable to interact when in combat")
			Debug(green, "Try again when no longer in combat")
		end 
	end
end)

Check4Rares:SetScript("OnEnter", function(s,e)

	GameTooltip:SetOwner(Check4Rares, "ANCHOR_CURSOR")
	GameTooltip:SetText("Micro_Rares "..version,.71,1,.92)
	GameTooltip:AddLine("-------------------",.71,1,.92) 
	GameTooltip:AddLine(" ", 1, 1, 1) 
	GameTooltip:AddLine("Rare Found! ",.71,1,.92)
	GameTooltip:AddLine(npc_id.." : "..name, 1, 0, 0)
	GameTooltip:AddLine(" ",0, 0, 1, 1)
	GameTooltip:AddLine("Location:"..round((x*100),1).."/"..round((y*100),1) , 0, 1, 1)
	GameTooltip:AddLine(GetMinimapZoneText(), 0, 0, 0, 1)
	GameTooltip:AddLine(GetZoneText()..":"..currentArea, 0, 1, 0)
	GameTooltip:AddLine(" ", 0, 1, 1) 
	GameTooltip:AddLine("Coded June 2017", 0, 1, 0) 
	GameTooltip:AddLine("by tHE.alCHMist",0 , 1, 0) 
	GameTooltip:AddLine(" ",0, 0, 1, 1)
	GameTooltip:AddLine("Right click to close", 1, 1, 1)
	GameTooltip:AddLine(" ", 0, 1, 1)
	GameTooltip:Show()
	end)
	
Check4Rares:SetScript("OnLeave", function(s,e) GameTooltip:Hide() end)

 
local Background = Check4Rares:GetNormalTexture()
Background:SetDrawLayer("BACKGROUND")
Background:ClearAllPoints()
Background:SetPoint("BOTTOMLEFT", 3, 3)
Background:SetPoint("TOPRIGHT", -3, -3)
Background:SetTexCoord(0, 1, 0, 0.25)
Check4Rares.ModelView = _G.CreateFrame("PlayerModel", "mxpplayermodel", Check4Rares)
Check4Rares.ModelView:SetPoint("BOTTOMLEFT", Check4Rares, "BOTTOMLEFT", 0, 7) 
Check4Rares.ModelView:SetPoint("RIGHT")
Check4Rares.ModelView:SetHeight(70)
Check4Rares.ModelView:SetScale(.95)
Check4Rares:RegisterEvent("PLAYER_ENTERING_WORLD")
Check4Rares:RegisterEvent("ZONE_CHANGED_NEW_AREA")
Check4Rares:RegisterEvent("PLAYER_ALIVE")
Check4Rares:RegisterEvent("ZONE_CHANGED")
Check4Rares:RegisterEvent("LOOT_CLOSED")
Check4Rares:RegisterEvent("NAME_PLATE_UNIT_ADDED")
Check4Rares:RegisterEvent("PLAYER_TARGET_CHANGED")
Check4Rares:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
Check4Rares:RegisterEvent("VIGNETTE_ADDED")
Check4Rares:RegisterEvent("NAME_PLATE_CREATED");
Check4Rares:RegisterEvent("NAME_PLATE_UNIT_ADDED");
Check4Rares:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
Check4Rares:RegisterEvent("PLAYER_TARGET_CHANGED");
Check4Rares:RegisterEvent("PLAYER_REGEN_DISABLED");
Check4Rares:RegisterEvent("PLAYER_REGEN_ENABLED");
Check4Rares:Hide()

SetMapToCurrentZone()
zone=GetZoneText()
  
function spawns()
	SetMapToCurrentZone()
	continent = GetCurrentMapContinent()
	minizone = GetMinimapZoneText()
	if tonumber(continent) == -1 then
		if table.contains(Class_Halls, minizone) then
		rares = Class_Hall_Rares
		currentArea = "Class Hall"
		elseif table.contains(Instances, minizone) then
		rares = Instance_Rares
		currentArea = "Instance"
		IareA = Instance_Check()
		else
		rares = Unknown_Area
		currentArea = "BG or Cosmic"
		end
	elseif tonumber(continent) == 0 then
		rares = Unknown_Area
		currentArea = "Azeroth Main Map"
	elseif tonumber(continent) == 1 then
		rares = Kalimdor_Rares
		currentArea = "Kalimdor"
	elseif tonumber(continent) == 2 then
		rares = Eastern_Kingdoms_Rares
		currentArea = "Eastern Kingdoms"
	elseif tonumber(continent) == 3 then 
		rares = Outland_Rares
		currentArea = "Outland"
	elseif tonumber(continent) == 4 then 
		rares = Northrend_Rares
		currentArea = "Northrend"
	elseif tonumber(continent) == 5 then 
		rares = Maelstrom_Rares
		currentArea = "Cataclysm"
	elseif tonumber(continent) == 6 then 
		rares = Pandaria_Rares
		currentArea = "Pandaria"
	elseif tonumber(continent) == 7 then
		rares = Draenor_Rares
		currentArea = "Draenor"
	elseif tonumber(continent) == 8 then
		rares = Broken_Isles_Rares
		currentArea = "Broken Isles"
	elseif tonumber(continent) == 9 then
		rares = Argus_Rares
		currentArea = "Argus"
	end
	return rares
end

function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))      
    else
      print(formatting .. v)
    end
  end
end

---function Check4Rares:HideButton() 
---if incombat then --- if incombat == nil then
---	Debug(red, "No interaction whilst in combat!")
---	return nil
---	else
---	Check4Rares.ModelView:ClearModel()
---	Check4Rares.ModelView:Hide()
---	Check4Rares:Hide()
--- end end

function Check4Rares:OnLeave()
	GameTooltip:Hide()
end

function table.contains(table, element)
	for _, value in pairs(table) do
		if value == element then
		return true
		end
	end
	return false
end

function table.containsKey(table, element)
	for key, value in pairs(table) do
		if key == element then
		return true
		end
	end
	return false
end

function Instance_Check()
local name, type, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance, mapID, instanceGroupSize = GetInstanceInfo()
	return name
end

--local function setLocation()
--if tonumber(continent) >= 1 and currentZone ~= continent then
--	continent = GetCurrentMapContinent()
--	SetMapToCurrentZone()
--	spawns()
--	currentZone = continent 
--	Debug(green, "Micro_Rares ".. version .." Loaded")
--	Debug(blue, "Currently Tracking Rares in %s ", currentArea) 
--	loaded = true
--	else return "Map Data Not Loaded!"
--	end
--	end

function round(num, dp) ----round(number, decimal places)
if dp == 0 or nil then 
	return tonumber(string.format("%.0f", num))
else if dp == 1 then
	return tonumber(string.format("%.1f", num))
else if dp == 2 then
	return tonumber(string.format("%.2f", num))
end end end end

function iSDead(mob)
	if UnitIsDead(mob) then
		Dtimer(60,mob)
		return true
	end
end

function Dtimer(length,mob)
	if timer == 0 then
		timer = time()
		PlaySoundFile("Sound\\Events\\EbonHold_WomanScream1_02.ogg")
		Debug(blue, "Dead Rare detected: "..UnitName(mob))
		Debug(red, "Damn it somebody got here first!")
	else
		if (timer + length) <= time() then
			timer = 0
		end
	end	
end


Check4Rares:HookScript("OnEvent", function(self, event)

if  not UnitOnTaxi("player") then
	if UnitName("mouseover") ~= nil and table.contains(rares, UnitName("mouseover")) == true and table.containsKey(RaresSeenDB, UnitName("mouseover")) ~= true and rareSeen == false and iSDead("mouseover") ~= true
		then rareSeen = true
			guid, name = UnitGUID("mouseover"), UnitName("mouseover")
			type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
			PlaySoundFile("Sound\\Event Sounds\\Event_wardrum_ogre.ogg");
			PlaySoundFile("Sound\\Creature\\Loathstare\\Loa_Naxx_Aggro02.ogg");
			if not GetCurrentCoords() then x,y=0,0 else x,y=GetCurrentCoords() end
			RaresSeenDB[name] = npc_id..":"..round((x*100),1).."/"..round((y*100),1)..":"..GetMinimapZoneText()..":"..GetZoneText()..":"..currentArea
			Debug(red, "Spawn detected: "..name); 
			Debug(blue, npc_id)
			mView("mouseover");
			local icon=GetRaidTargetIndex("mouseover")
				if icon ~= 8
					then SetRaidTarget("mouseover",8);
					TinyTimer=time()
				end;
	end;
	if UnitName("target") ~= nil and table.contains(rares, UnitName("target")) == true and table.containsKey(RaresSeenDB, UnitName("target")) ~= true and rareSeen == false and iSDead("target") ~= true
		then rareSeen = true
			guid, name = UnitGUID("target"), UnitName("target")
			type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
			PlaySoundFile("Sound\\Event Sounds\\Event_wardrum_ogre.ogg");
			PlaySoundFile("Sound\\Creature\\Loathstare\\Loa_Naxx_Aggro02.ogg"); 
			if not GetCurrentCoords() then x,y=0,0 else x,y=GetCurrentCoords() end
			RaresSeenDB[name] = npc_id..":"..round((x*100),1).."/"..round((y*100),1)..":"..GetMinimapZoneText()..":"..GetZoneText()..":"..currentArea
			Debug(red, "Spawn detected: "..name); 
			Debug(blue, npc_id)
			mView("target");
			local icon=GetRaidTargetIndex("target")
				if icon ~= 8 
					then SetRaidTarget("target",8);
					TinyTimer=time()
				end;
		end;
	if UnitName("focus") ~= nil and table.contains(rares, UnitName("focus")) == true and table.containsKey(RaresSeenDB, UnitName("focus")) ~= true and rareSeen == false and iSDead("focus") ~= true
		then rareSeen = true
			guid, name = UnitGUID("focus"), UnitName("focus")
			type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
			PlaySoundFile("Sound\\Event Sounds\\Event_wardrum_ogre.ogg");
			PlaySoundFile("Sound\\Creature\\Loathstare\\Loa_Naxx_Aggro02.ogg"); 
----		Check4Rares.ModelView:SetDisplayInfo(npc_id)
----		Check4Rares:SetAttribute("macrotext", "/cleartarget\n/targetexact "..name)
			if not GetCurrentCoords() then x,y=0,0 else x,y=GetCurrentCoords() end
			RaresSeenDB[name] = npc_id..":"..round((x*100),1).."/"..round((y*100),1)..":"..GetMinimapZoneText()..":"..GetZoneText()..":"..currentArea
			Debug(red, "Spawn detected: "..name);
			Debug(blue, npc_id)
			mView("focus");
			local icon=GetRaidTargetIndex("focus")
				if icon ~= 8
					then SetRaidTarget("focus",8);
					TinyTimer=time()
				end;	
		end; 
else
	if UnitName("mouseover") ~= nil and table.contains(rares, UnitName("mouseover")) == true and table.containsKey(RaresSeenDB, UnitName("mouseover")) ~= true and rareSeen == false and iSDead("mouseover") ~= true
		then rareSeen = true
			guid, name = UnitGUID("mouseover"), UnitName("mouseover")
			type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
			PlaySoundFile("Sound\\Event Sounds\\Event_wardrum_ogre.ogg");
			PlaySoundFile("Sound\\Creature\\Loathstare\\Loa_Naxx_Aggro02.ogg");
			if not GetCurrentCoords() then x,y=0,0 else x,y=GetCurrentCoords() end
			Debug(red, "Spawn detected: "..name); 
			Debug(blue, npc_id)
			Debug(green, round((x*100),1).."/"..round((y*100),1)..":"..GetMinimapZoneText()..":"..GetZoneText()..":"..currentArea);
			mView("mouseover");
			local icon=GetRaidTargetIndex("mouseover")
				if icon ~= 8
					then SetRaidTarget("mouseover",8);
					TinyTimer=time()
				end;
	end;
	if UnitName("target") ~= nil and table.contains(rares, UnitName("target")) == true and table.containsKey(RaresSeenDB, UnitName("target")) ~= true and rareSeen == false and iSDead("target") ~= true
		then rareSeen = true
			guid, name = UnitGUID("target"), UnitName("target")
			type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
			PlaySoundFile("Sound\\Event Sounds\\Event_wardrum_ogre.ogg");
			PlaySoundFile("Sound\\Creature\\Loathstare\\Loa_Naxx_Aggro02.ogg"); 
			if not GetCurrentCoords() then x,y=0,0 else x,y=GetCurrentCoords() end
			Debug(red, "Spawn detected: "..name); 
			Debug(blue, npc_id)
			Debug(green, round((x*100),1).."/"..round((y*100),1)..":"..GetMinimapZoneText()..":"..GetZoneText()..":"..currentArea);
			mView("target");
			local icon=GetRaidTargetIndex("target")
				if icon ~= 8 
					then SetRaidTarget("target",8);
					TinyTimer=time()
				end;
		end;
	if UnitName("focus") ~= nil and table.contains(rares, UnitName("focus")) == true and table.containsKey(RaresSeenDB, UnitName("focus")) ~= true and rareSeen == false and iSDead("focus") ~= true
		then rareSeen = true
			guid, name = UnitGUID("focus"), UnitName("focus")
			type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
			PlaySoundFile("Sound\\Event Sounds\\Event_wardrum_ogre.ogg");
			PlaySoundFile("Sound\\Creature\\Loathstare\\Loa_Naxx_Aggro02.ogg"); 
			if not GetCurrentCoords() then x,y=0,0 else x,y=GetCurrentCoords() end
			Debug(red, "Spawn detected: "..name);
			Debug(blue, npc_id)
			Debug(green, round((x*100),1).."/"..round((y*100),1)..":"..GetMinimapZoneText()..":"..GetZoneText()..":"..currentArea);
			mView("focus");
			local icon=GetRaidTargetIndex("focus")
				if icon ~= 8
					then SetRaidTarget("focus",8);
					TinyTimer=time()
				end;
	end; end;
if TinyTimer~=0 and (time() - TinyTimer) > 60 then rareSeen = false; TinyTimer = 0; end
end)

local reset=CreateFrame("Frame") 
reset:RegisterEvent("ZONE_CHANGED_NEW_AREA")
reset:RegisterEvent("PLAYER_ENTERING_WORLD")
reset:RegisterEvent("PLAYER_ALIVE")
reset:RegisterEvent("ZONE_CHANGED")
reset:Hide()
reset:SetScript("OnUpdate",function(self)
  self:Hide()
end)
reset:SetScript("OnEvent",function(self)
	spawns()
	if tonumber(continent) >= -1 then
		if currentZone ~= continent and currentArea == "Class Hall" then
			currentZone = GetCurrentMapContinent() 
			Debug(green, "tHE.alCHMist's Micro_Rares ".. version .." Loaded")
			Debug(blue, "No Rares to track in the %s ", currentArea)
			TinyTimer2=time()
			loaded = true
		end
		if currentZone == continent and TinyTimer2 < .01 and loaded == true then --- 1 to .01
			Debug(red,"Zone already set, Continent "..tonumber(continent).." "..currentArea)
			TinyTimer2=time()
		end
	end	
	if tonumber(continent) >= -1 then
		if currentZone ~= continent and currentArea == "Instance" then
			currentZone = GetCurrentMapContinent() 
			Debug(green, "tHE.alCHMist's Micro_Rares ".. version .." Loaded")
			Debug(blue, "Currently Tracking Rares in %s %s",IareA, currentArea)
			TinyTimer2=time()
			loaded = true
		end
		if currentZone == continent and TinyTimer2 < .01 and loaded == true then --- 1 to .01
			Debug(red,"Zone already set, Continent "..tonumber(continent).." "..currentArea)
			TinyTimer2=time()
		end
	end	
	if tonumber(continent) >= 1 then
		if currentZone ~= continent then
			currentZone = GetCurrentMapContinent() 
			Debug(green, "tHE.alCHMist's Micro_Rares ".. version .." Loaded")
			Debug(blue, "Currently Tracking Rares in %s ", currentArea)
			TinyTimer2=time()
			loaded = true
		end
		if currentZone == continent and TinyTimer2 < .01 and loaded == true then --- 1 to .01
			Debug(red,"Zone already set, Continent "..tonumber(continent).." "..currentArea)
			TinyTimer2=time()
		end
	else 
	if TinyTimer2 < .01 then
	Debug(red, "Map Data Not Loaded!")
	if continent== -1 and currentArea ~= "Class Hall" and TinyTimer2 < .01 then 
	Debug(red,"Debuging: Area="..currentArea)
	else
	Debug(red,"Debuging continent "..tonumber(continent))
	end end end
	if TinyTimer2 > 0 and (time() - TinyTimer2) >= 30 then TinyTimer2 = 0; end
end)

function mView(t)
	if UnitAffectingCombat("player")==false
		then
			Check4Rares.ModelView:SetUnit(t)
			Check4Rares:Show();
			Check4Rares.ModelView:Show();
	else
		Debug(red,"IN COMBAT")
	end 
end

--- if tonumber(continent) == 0 and GetMinimapZoneText() == "Darkmoon Boardwalk (Sanctuary)" then
---			currentZone = GetCurrentMapContinent() 
---			Debug(green, "Micro_Rares ".. version .." Loaded")
---			Debug(blue, "Currently Tracking Rares in %s ", currentArea)
---			TinyTimer2=time()
---			loaded = true
---		end