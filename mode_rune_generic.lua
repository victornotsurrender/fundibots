if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local utils = require( "bots/util");
local role = require( "bots/RoleUtility");
local Role = require( "bots/jmz_role")
local uItem = require( "bots/ItemUtility" );
local mUtils = require( "bots/MyUtility" );
local hero_roles = role["hero_roles"];
local bot = GetBot();
local minute = 0;
local sec = 0;
local closestRune  = -1;
local runeStatus = -1;
local ProxDist = 1600;
local teamPlayers = nil;
local PingTimeGap = 10;
local bottle = nil;
local enemyPids = nil
local neutralItemCheck = -90;
local dropNeutralItemCheck = -90;
local swapNeutralItemCheck = -90;
local neutralItem = nil;
local droppedNeutralItems = {};

local ListRune = {
	RUNE_BOUNTY_1,
	RUNE_BOUNTY_2,
	RUNE_BOUNTY_3,
	RUNE_BOUNTY_4,
	RUNE_POWERUP_1,
	RUNE_POWERUP_2
}

local lastPing = -90;
bot.RuneType = RUNE_INVALID;

local PowerRuneLoc1 = Vector(-1640.0, 1112.0, 48.0)
local PowerRuneLoc2 = Vector(1180.0, -1216.0, 64.0)

-- local ceta = false;

local nAttactRange = bot:GetAttackRange() +90


function GetDesire()
	--print(bot:GetUnitName()..bot:GetAssignedLane())
	--[[if bot.lastPlayerChat ~= nil and string.find(bot.lastPlayerChat.text, "rune") then
		bot:ActionImmediate_Chat("Catch this in mode_rune_generic", false);
		bot.lastPlayerChat = nil;
	end]]--
	-- if DotaTime() > lastPing + 3.0 then
		-- bot:ActionImmediate_Ping( GetRuneSpawnLocation(RUNE_POWERUP_1).x,  GetRuneSpawnLocation(RUNE_POWERUP_1).y, true)
		-- lastPing = DotaTime()
	-- end
	
	if bot:GetActiveMode() == BOT_MODE_WARD 
		-- or bot:GetActiveMode() == BOT_MODE_RUNE 
		then
	return BOT_MODE_DESIRE_NONE,0;
	end
	
	if nAttactRange > 1400 then nAttactRange = 1400 end
	
	if GetGameMode() == GAMEMODE_1V1MID then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if GetGameMode() == GAMEMODE_MO and DotaTime() <= 0 then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if teamPlayers == nil then teamPlayers = GetTeamPlayers(GetTeam()) end
	
	if bot:IsIllusion() 
	or bot:IsInvulnerable()
	or not bot:IsHero() 
	or bot:HasModifier("modifier_arc_warden_tempest_double") 
	or bot:IsUsingAbility()
	or bot:IsChanneling() 
	or bot:GetCurrentActionType() == BOT_ACTION_TYPE_IDLE 
	then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if DotaTime() > dropNeutralItemCheck + 0.30 then
		local canDrop, hItem = uItem.CanDropNeutralItem(bot);
		if canDrop == true then
			bot:Action_DropItem(hItem, bot:GetLocation() + RandomVector(100));
			return;
		end
		canDrop, hItem = uItem.CanDropExcessNeutralItem(bot);
		if canDrop == true then
			bot:Action_DropItem(hItem, bot:GetLocation() + RandomVector(100));
			return;
		end
		dropNeutralItemCheck = DotaTime();
	end
	
	if DotaTime() > swapNeutralItemCheck + 0.25 then
		local canSwap, hItem1, hItem2 = uItem.CanSwapNeutralItem(bot);
		if canSwap == true then
			bot:ActionImmediate_SwapItems(hItem1, hItem2);
			return;
		end
		swapNeutralItemCheck = DotaTime();
	end
	
	-- if DotaTime() > 0 
		-- and IsUnitAroundLocation(bot:GetLocation(), 2800) 
	-- then
		-- ProxDist = 900
	-- else 
		-- ProxDist = 1600
	-- end
	
	if IsUnitAroundLocation(GetAncient(GetTeam()):GetLocation(), 2800) 
	then
	 return BOT_MODE_DESIRE_NONE;	
	end

	if GetUnitToUnitDistance(bot, GetAncient(GetTeam())) < 3500 or  GetUnitToUnitDistance(bot, GetAncient(GetOpposingTeam())) < 3500 then
		return BOT_MODE_DESIRE_NONE;
	end

	minute = math.floor(DotaTime() / 60)
	sec = DotaTime() % 60
	
	if not IsSuitableToPick() then
		return BOT_MODE_DESIRE_NONE;
	end	
	
	if DotaTime() < 0 and not bot:WasRecentlyDamagedByAnyHero(5.0) then 
		return BOT_MODE_DESIRE_HIGH;
	end	
	
	if neutralItem ~= nil then
		return CountDesire(BOT_MODE_DESIRE_MODERATE, GetUnitToLocationDistance(bot, neutralItem.location), 2000);
	end
	
	closestRune, closestDist = GetBotClosestRune();
	if closestRune ~= -1 and IsEnemyCloserToRuneLoc(closestRune, closestDist) == false  
	
	then
		if closestRune == RUNE_BOUNTY_1 
		or closestRune == RUNE_BOUNTY_2 
		or closestRune == RUNE_BOUNTY_3 
		or closestRune == RUNE_BOUNTY_4
		or closestRune ==RUNE_POWERUP_1
		or closestRune ==RUNE_POWERUP_2	
		then
			runeStatus = GetRuneStatus( closestRune );
			
			if runeStatus == RUNE_STATUS_AVAILABLE then
				-- ceta = true;
				return CountDesire(BOT_MODE_DESIRE_MODERATE, closestDist, 3000),true;
				
			elseif runeStatus == RUNE_STATUS_UNKNOWN and closestDist <= ProxDist then
				-- ceta = true;
				return CountDesire(BOT_MODE_DESIRE_MODERATE, closestDist, ProxDist);
				
			elseif runeStatus == RUNE_STATUS_MISSING and DotaTime() > 60 and ( minute % 4 == 0 and sec > 52 ) and closestDist <= ProxDist then
				-- ceta = true;
				return CountDesire(BOT_MODE_DESIRE_MODERATE, closestDist, ProxDist);
				
			elseif IsTeamMustSaveRune(closestRune) and runeStatus == RUNE_STATUS_UNKNOWN then
				
				return CountDesire(BOT_MODE_DESIRE_MODERATE, closestDist, 5000),true;
			end
		else
			if DotaTime() > 1 * 60 + 50 then
				runeStatus = GetRuneStatus( closestRune );
				if runeStatus == RUNE_STATUS_AVAILABLE then
					-- ceta = false;
					return CountDesire(BOT_MODE_DESIRE_MODERATE, closestDist, 5000),true;
					
				elseif runeStatus == RUNE_STATUS_UNKNOWN and closestDist <= ProxDist then
					-- ceta = false;
					return CountDesire(BOT_MODE_DESIRE_MODERATE, closestDist, ProxDist);
					
				elseif runeStatus == RUNE_STATUS_MISSING and DotaTime() > 60 and ( minute % 2 == 1 and sec > 52 ) and closestDist <= ProxDist then
					-- ceta = false;
					return CountDesire(BOT_MODE_DESIRE_MODERATE, closestDist, ProxDist);
					
				elseif IsTeamMustSaveRune(closestRune) and runeStatus == RUNE_STATUS_UNKNOWN then
					-- ceta = false;
					return CountDesire(BOT_MODE_DESIRE_MODERATE, closestDist, 5000);
						
				end
			end	
		end
		
		
		
	end
	-- print(bot:GetUnitName())
	-- for i=0,25 do
		-- if bot:GetItemSlotType(i) == ITEM_SLOT_TYPE_MAIN then
			-- print(tostring(i)..'Main')
		-- elseif bot:GetItemSlotType(i) == ITEM_SLOT_TYPE_BACKPACK then
			-- print(tostring(i)..'Back')
		-- elseif bot:GetItemSlotType(i) == ITEM_SLOT_TYPE_STASH then
			-- print(tostring(i)..'Stash')
		-- else
			-- print(tostring(i)..'NA')
		-- end
	-- end
	if DotaTime() >= neutralItemCheck + 0.5 and neutralItem == nil and uItem.IsMeepoClone(bot) == false then
		if uItem.GetEmptySlotAmount(bot, ITEM_SLOT_TYPE_BACKPACK) > 1 or uItem.IsNeutralItemSlotEmpty(bot) then
			local dropped = GetDroppedItemList();
			for _,drop in pairs(dropped) do
				if uItem.GetNeutralItemTier(drop.item:GetName()) > 0 
					and uItem.IsRecipeNeutralItem(drop.item:GetName()) == false 
					and utils.GetDistance(drop.location, mUtils.GetTeamFountain()) > 500
					and CanPickupNeutralItem(drop.location) == true 
				then
					print(bot:GetUnitName().." taking item:"..tostring(drop))
					neutralItem = drop;
					break;
				end
			end
		end	
		neutralItemCheck = DotaTime();
	end
	
	
	
	
	
	return BOT_MODE_DESIRE_NONE;
end

function OnStart()
	local bottle_slot = bot:FindItemSlot('item_bottle');
	if bot:GetItemSlotType(bottle_slot) == ITEM_SLOT_TYPE_MAIN then
		bottle = bot:GetItemInSlot(bottle_slot);
	end	
end

function OnEnd()
	bottle = nil;
	neutralItem = nil;
end



local RetreatLoc = mUtils.GetTeamFountain()

function Think()


	if bot:IsChanneling() 
		or bot:NumQueuedActions() > 0
		or bot:IsCastingAbility()
		or bot:IsUsingAbility()
		or bot:GetCurrentActionType() == BOT_ACTION_TYPE_PICK_UP_RUNE
	then 
		return
	end
	
	
	if neutralItem ~= nil then
		if GetUnitToLocationDistance(bot, neutralItem.location) > 300 then 
			bot:Action_MoveToLocation(neutralItem.location);
			return
		else
			bot:Action_PickUpItem(neutralItem.item);
			return
		end
	end
	
	if DotaTime() < 0 then 
		if GetTeam() == TEAM_RADIANT then
			if bot:GetAssignedLane() == LANE_BOT then 
				-- print(bot:GetUnitName().." Moving to location Rune:"..tostring(GetRuneSpawnLocation(RUNE_POWERUP_1)))
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_POWERUP_2));
				
				
				return
			else
				-- print(bot:GetUnitName().." Moving to location Rune:"..tostring(GetRuneSpawnLocation(RUNE_BOUNTY_1)))
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_1));
				
				return
			end
		elseif GetTeam() == TEAM_DIRE then
			if bot:GetAssignedLane() == LANE_TOP then 
			-- print(bot:GetUnitName().." Moving to location Rune:"..tostring(GetRuneSpawnLocation(RUNE_BOUNTY_2)))
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_POWERUP_1));
				
				return
			else
				-- print(bot:GetUnitName().." Moving to location Rune:"..tostring(GetRuneSpawnLocation(RUNE_POWERUP_2)))
				bot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_2));
				
				return
			end
		end
	end	
	
	-- if DotaTime() > lastPing + 3.0 then
		-- bot:ActionImmediate_Ping( GetRuneSpawnLocation(RUNE_POWERUP_2).x,  GetRuneSpawnLocation(RUNE_POWERUP_2).y, true)
		-- print(bot:GetUnitName().." Moving to location Rune:"..tostring(GetRuneSpawnLocation(RUNE_POWERUP_2)))
		-- lastPing = DotaTime()
	-- end
	
	-- if runeStatus == RUNE_STATUS_AVAILABLE then
		-- if bottle ~= nil and closestDist < 1200 then 
			-- local bottle_charge = bottle:GetCurrentCharges() 
			-- if bottle:IsFullyCastable() 
			-- and bottle_charge > 0 
			-- and ( bot:GetHealth() < bot:GetMaxHealth() or bot:GetMana() < bot:GetMaxMana() ) 
			-- then
				-- bot:Action_UseAbility( bottle );
				-- return;
			-- end
		-- end
		
		-- if closestDist > 118 then
			-- bot:Action_MoveToLocation(GetRuneSpawnLocation(closestRune));
			-- return
		-- else
			-- bot.RuneType = GetRuneType(closestRune);
			-- bot:Action_PickUpRune(closestRune);
			-- return
		-- end
	-- else 
		-- bot:Action_MoveToLocation(GetRuneSpawnLocation(closestRune));
		-- return
	-- end
	
	
	local nEnemys = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE)
	local nCreeps = bot:GetNearbyCreeps(1600 ,true)
	local enemyTowers = bot:GetNearbyTowers(1600, true);
	if IsTargetedByCreepOrTower(bot, nCreeps, enemyTowers,nEnemys) or bot:WasRecentlyDamagedByTower(3.5) or bot:WasRecentlyDamagedByCreep(3.0)  or bot: WasRecentlyDamagedByAnyHero(3.0) 
		then
		-- bot:Action_ClearActions(true);
		bot:Action_MoveToLocation(RetreatLoc);
		return
	end
	
	
	if runeStatus == RUNE_STATUS_AVAILABLE 
	then
		
		if bottle ~= nil and closestDist < 1200 
		then 
			local bottle_charge = bottle:GetCurrentCharges() 
			if bottle:IsFullyCastable() 
				and bottle_charge > 0 
				and ( bot:GetHealth() < bot:GetMaxHealth() or bot:GetMana() < bot:GetMaxMana() ) 
			then
				bot:Action_UseAbility( bottle )
				return
			end
		end
		
		if closestDist > 200 then  -- 128 to pick rune
		   -- if ceta then
		   
			local nEnemys = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE)
			local nCreeps = bot:GetNearbyCreeps(1600 ,true)
			local target = GetWeakestUnit(bot,nEnemys,nCreeps);
			local enemyTowers = bot:GetNearbyTowers(1600, true);
			if target ~= nil  then
				bot:Action_AttackUnit(target, true)
				return
			-- elseif IsTargetedByCreepOrTower(bot, nCreeps, enemyTowers,nEnemys) or bot:WasRecentlyDamagedByTower(1.5) or bot:WasRecentlyDamagedByCreep(1.0)  or bot: WasRecentlyDamagedByAnyHero(1.0) 
				-- then
					-- -- bot:Action_ClearActions(true);
					-- bot:Action_MoveToLocation(RetreatLoc);
				-- return
			end
			
			
			if CouldBlink(bot,GetRuneSpawnLocation(closestRune)) then return end
			
					if DotaTime() > lastPing + 7.0 
						and runeStatus == RUNE_STATUS_AVAILABLE
						-- and not runeStatus == RUNE_STATUS_MISSING
						-- and not runeStatus == RUNE_STATUS_UNKNOWN
					then
						
						bot:ActionImmediate_Ping( GetRuneSpawnLocation(closestRune).x,  GetRuneSpawnLocation(closestRune).y, IsRadiusVisible( GetRuneSpawnLocation(closestRune), 0 ))
						bot:ActionImmediate_Chat("Aquí puede haber una runa", false)
						print(bot:GetUnitName().." Moving to rune location :"..tostring(GetRuneSpawnLocation(closestRune)))
						lastPing = DotaTime()
					end
					-- end
					if runeStatus == RUNE_STATUS_AVAILABLE and closestDist < 1600    then
						bot:Action_ClearActions(true);
						bot:Action_MoveToLocation(GetRuneSpawnLocation(closestRune) + RandomVector(20))
						return
					else
						bot:Action_ClearActions(false);
						bot.RuneType = GetRuneType(closestRune);
						bot:Action_PickUpRune(closestRune);
						
						return
					end
				-- bot:Action_ClearActions(true);
				bot:Action_MoveToLocation(GetRuneSpawnLocation(closestRune) + RandomVector(20))
				return
			else
			-- bot:Action_ClearActions(true);
			-- bot:ActionImmediate_Chat("PickUpRune...", true)
			bot.RuneType = GetRuneType(closestRune);
			bot:Action_PickUpRune(closestRune);	
			end
		else	
		
	
			local nEnemys = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE)
			local nCreeps = bot:GetNearbyCreeps(1600 ,true)
			local enemyTowers = bot:GetNearbyTowers(1600, true);
			local target = GetWeakestUnit(bot,nEnemys,nCreeps);
			
			if target ~= nil 
			then
				bot:Action_AttackUnit(target, true)
				return
			-- elseif IsTargetedByCreepOrTower(bot, nCreeps, enemyTowers,nEnemys) or bot:WasRecentlyDamagedByTower(1.5) or bot:WasRecentlyDamagedByCreep(1.0)  or bot: WasRecentlyDamagedByAnyHero(1.0) 
				-- then
				-- -- bot:Action_ClearActions(true);
				-- bot:Action_MoveToLocation(RetreatLoc);
				-- return
			end
			
			if runeStatus == RUNE_STATUS_AVAILABLE and closestDist < 1600 then
			bot:Action_ClearActions(true);
				bot:Action_MoveToLocation(GetRuneSpawnLocation(closestRune));					
				return
			else	
				
				bot:Action_ClearActions(false);
				bot.RuneType = GetRuneType(closestRune);
				bot:Action_PickUpRune(closestRune);						
				return
			end
			
		-- bot:Action_ClearActions(true);	
		bot:Action_MoveToLocation(GetRuneSpawnLocation(closestRune))
		return
	
	-- end
	end
	-- end
	-- end --- end ceta
	
end
	


function CountDesire(base_desire, dist, maxDist)
	 return base_desire + RemapValClamped( dist, maxDist, 0, 0, 1-base_desire );
end	


function GetBotClosestRune()
	local cDist = 100000;	
	local cRune = -1;	
	for _,r in pairs(ListRune)
	do
		local rLoc = GetRuneSpawnLocation(r);
		if not IsHumanPlayerNearby(rLoc) 
		and not IsPingedByHumanPlayer(rLoc) 
		and not IsThereMidlaner(rLoc) 
		and IsTheClosestOne(rLoc)
		
		and not IsThereCarry(rLoc) 
		    and not IsMissing(r)
			and not IsKnown(r)
		then
			local dist = GetUnitToLocationDistance(bot, rLoc);
			if dist < cDist then
				cDist = dist;
				cRune = r;
			end	
		end
	end
	return cRune, cDist;
end

function GetDistance(s, t)
    return math.sqrt((s[1]-t[1])*(s[1]-t[1]) + (s[2]-t[2])*(s[2]-t[2]));
end

function IsTeamMustSaveRune(rune)
	if GetTeam() == TEAM_DIRE then
		return rune == RUNE_BOUNTY_2 
		-- or rune == RUNE_BOUNTY_4 
		or rune == RUNE_POWERUP_1 
		or rune == RUNE_POWERUP_2
	else
		return rune == RUNE_BOUNTY_1 
		-- or rune == RUNE_BOUNTY_3 
		or rune == RUNE_POWERUP_1 
		or rune == RUNE_POWERUP_2
	end
end

function IsHumanPlayerNearby(runeLoc)
	for k,v in pairs(teamPlayers)
	do
		local member = GetTeamMember(k);
		if member ~= nil and not member:IsIllusion() and not IsPlayerBot(v) and member:IsAlive() then
			local dist1 = GetUnitToLocationDistance(member, runeLoc);
			local dist2 = GetUnitToLocationDistance(bot, runeLoc);
			if dist2 < 1200 and dist1 < 1200 then
				return true;
			end
		end
	end
	return false;
end

function IsPingedByHumanPlayer(runeLoc)
	local listPings = {};
	local dist2 = GetUnitToLocationDistance(bot, runeLoc);
	for k,v in pairs(teamPlayers)
	do
		local member = GetTeamMember(k);
		if member ~= nil and not member:IsIllusion() and not IsPlayerBot(v) and member:IsAlive() then
			local ping = member:GetMostRecentPing();
			table.insert(listPings, ping);
		end
	end
	for _,p in pairs(listPings)
	do
		if p ~= nil and not p.normal_ping and GetDistance(p.location, runeLoc) < 1200 and dist2 < 1200 and GameTime() - p.time < PingTimeGap then
			return true;
		end
	end
	return false;
end

function IsTheClosestOne(r)
	local minDist = GetUnitToLocationDistance(bot, r);
	local closest = bot;
	for k,v in pairs(teamPlayers)
	do	
		local member = GetTeamMember(k);
		if  member ~= nil and not member:IsIllusion() and member:IsAlive() then
			local dist = GetUnitToLocationDistance(member, r);
			if dist < minDist then
				minDist = dist;
				closest = member;
			end
		end
	end
	return closest == bot;
end

function CanPickupNeutralItem(r)
	local minDist = GetUnitToLocationDistance(bot, r);
	local closest = bot;
	for k,v in pairs(teamPlayers)
	do	
		local member = GetTeamMember(k);
		if  member ~= nil and not member:IsIllusion() and member:IsAlive() 
			and ( uItem.GetEmptySlotAmount(member, ITEM_SLOT_TYPE_BACKPACK) >= 2 or uItem.IsNeutralItemSlotEmpty(member) )
		then
			local dist = GetUnitToLocationDistance(member, r);
			if dist < minDist then
				minDist = dist;
				closest = member;
			end
		end
	end
	return closest == bot;
end

function IsThereMidlaner(runeLoc)
	for k,v in pairs(teamPlayers)
	do
		local member = GetTeamMember(k);
		if member ~= nil and not member:IsIllusion() and member:IsAlive() and member:GetAssignedLane() == LANE_MID then
			local dist1 = GetUnitToLocationDistance(member, runeLoc);
			local dist2 = GetUnitToLocationDistance(bot, runeLoc);
			if dist2 < 1200 and dist1 < 1200 and bot:GetUnitName() ~= member:GetUnitName() then
			-- if dist2 < 1200 and dist1 < 600 and bot:GetUnitName() ~= member:GetUnitName() then
				return true;
			end
		end
	end
	return false;
end

-- function IsThereCarry(runeLoc)
	-- for k,v in pairs(teamPlayers)
	-- do
		-- local member = GetTeamMember(k);
		-- if member ~= nil and not member:IsIllusion() and member:IsAlive() and role.CanBeSafeLaneCarry(member:GetUnitName()) 
		   -- and ( (GetTeam()==TEAM_DIRE and member:GetAssignedLane()==LANE_TOP) or (GetTeam()==TEAM_RADIANT and member:GetAssignedLane()==LANE_BOT)  )	
		-- then
			-- local dist1 = GetUnitToLocationDistance(member, runeLoc);
			-- local dist2 = GetUnitToLocationDistance(bot, runeLoc);
			-- -- if dist2 < 1200 and dist1 < 1200 and bot:GetUnitName() ~= member:GetUnitName() then
			-- if dist2 < 1200 and dist1 < 600 and bot:GetUnitName() ~= member:GetUnitName() then
				-- return true;
			-- end
		-- end
	-- end
	-- return false;
-- end

function IsSuitableToPick()
	local mode = bot:GetActiveMode();
	local Enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
	if ( mode == BOT_MODE_RETREAT and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE )
		or mode == BOT_MODE_ATTACK
		or mode == BOT_MODE_DEFEND_ALLY
		or mode == BOT_MODE_DEFEND_TOWER_TOP
		or mode == BOT_MODE_DEFEND_TOWER_MID
		or mode == BOT_MODE_DEFEND_TOWER_BOT
		or ( #Enemies >= 1 and IsIBecameTheTarget(Enemies) )
		or bot:WasRecentlyDamagedByAnyHero(5.0)
	then
		return false;
	end
	return true;
end

function IsIBecameTheTarget(units)
	for _,u in pairs(units) do
		if u:GetAttackTarget() == bot then
			return true;
		end
	end
	return false;
end

function IsEnemyCloserToRuneLoc(iRune, botDist)
	if enemyPids == nil then
		enemyPids = GetTeamPlayers(GetOpposingTeam())
	end	
	for i = 1, #enemyPids do
		local info = GetHeroLastSeenInfo(enemyPids[i])
		if info ~= nil then
			local dInfo = info[1]; 
			if dInfo ~= nil and dInfo.time_since_seen < 2.0  and utils.GetDistance(dInfo.location, GetRuneSpawnLocation(iRune)) <  botDist
			then	
				return true;
			end
		end	
	end
	return false;
end

function CouldBlink(bot,nLocation)
	
	local blinkSlot = bot:FindItemSlot("item_blink") 
					  or bot:FindItemSlot("item_overwhelming_blink")
					  or bot:FindItemSlot("item_swift_blink")
					  or bot:FindItemSlot("item_arcane_blink")
	
	if bot:GetItemSlotType(blinkSlot) == ITEM_SLOT_TYPE_MAIN 
	   or bot:GetUnitName() == "npc_dota_hero_antimage"
	then
		local blink = bot:GetItemInSlot(blinkSlot)	
		if bot:GetUnitName() == "npc_dota_hero_antimage"
		then
			blink = bot:GetAbilityByName( "antimage_blink" )
		end
	
		if blink ~= nil 
		   and blink:IsFullyCastable() 
		then
			local bDist = GetUnitToLocationDistance(bot,nLocation)
			local maxBlinkLoc = GetXUnitsTowardsLocationRune(bot, nLocation, 1199 )
			if bDist <= 500
			then
				return false
			elseif bDist < 1200
				then
					bot:Action_UseAbilityOnLocation(blink, nLocation)
					return true
			elseif IsLocationPassable(maxBlinkLoc)
				then
					bot:Action_UseAbilityOnLocation(blink, maxBlinkLoc)
					return true
			end
		end
	end
	
	
	if bot:GetItemSlotType(blinkSlot) == ITEM_SLOT_TYPE_MAIN 
	   or bot:GetUnitName() == "npc_dota_hero_sand_king"
	then
		local blink = bot:GetItemInSlot(blinkSlot)	
		if bot:GetUnitName() == "npc_dota_hero_sand_king"
		then
			blink = bot:GetAbilityByName( "sandking_burrowstrike" )
		end
	
		if blink ~= nil 
		   and blink:IsFullyCastable() 
		then
			local bDist = GetUnitToLocationDistance(bot,nLocation)
			local maxBlinkLoc = GetXUnitsTowardsLocationRune(bot, nLocation, 1199 )
			if bDist <= 500
			then
				return false
			elseif bDist < 1200
				then
					bot:Action_UseAbilityOnLocation(blink, nLocation)
					return true
			elseif IsLocationPassable(maxBlinkLoc)
				then
					bot:Action_UseAbilityOnLocation(blink, maxBlinkLoc)
					return true
			end
		end
	end
	
	
	if bot:GetItemSlotType(blinkSlot) == ITEM_SLOT_TYPE_MAIN 
	   or bot:GetUnitName() == "npc_dota_hero_faceless_void"
	then
		local blink = bot:GetItemInSlot(blinkSlot)	
		if bot:GetUnitName() == "npc_dota_hero_faceless_void"
		then
			blink = bot:GetAbilityByName( "faceless_void_time_walk" )
		end
	
		if blink ~= nil 
		   and blink:IsFullyCastable() 
		then
			local bDist = GetUnitToLocationDistance(bot,nLocation)
			local maxBlinkLoc = GetXUnitsTowardsLocationRune(bot, nLocation, 1199 )
			if bDist <= 500
			then
				return false
			elseif bDist < 1200
				then
					bot:Action_UseAbilityOnLocation(blink, nLocation)
					return true
			elseif IsLocationPassable(maxBlinkLoc)
				then
					bot:Action_UseAbilityOnLocation(blink, maxBlinkLoc)
					return true
			end
		end
	end
	
	
	
	if bot:GetItemSlotType(blinkSlot) == ITEM_SLOT_TYPE_MAIN 
	   or bot:GetUnitName() == "npc_dota_hero_pangolier"
	then
		local blink = bot:GetItemInSlot(blinkSlot)	
		if bot:GetUnitName() == "npc_dota_hero_pangolier"
		then
			blink = bot:GetAbilityByName( "pangolier_swashbuckle" )
		end
	
		if blink ~= nil 
		   and blink:IsFullyCastable() 
		then
			local bDist = GetUnitToLocationDistance(bot,nLocation)
			local maxBlinkLoc = GetXUnitsTowardsLocationRune(bot, nLocation, 1199 )
			if bDist <= 500
			then
				return false
			elseif bDist < 1200
				then
					bot:Action_UseAbilityOnLocation(blink, nLocation)
					return true
			elseif IsLocationPassable(maxBlinkLoc)
				then
					bot:Action_UseAbilityOnLocation(blink, maxBlinkLoc)
					return true
			end
		end
	end
	
	
	
	if bot:GetItemSlotType(blinkSlot) == ITEM_SLOT_TYPE_MAIN 
	   or bot:GetUnitName() == "npc_dota_hero_queenofpain"
	then
		local blink = bot:GetItemInSlot(blinkSlot)	
		if bot:GetUnitName() == "npc_dota_hero_queenofpain"
		then
			blink = bot:GetAbilityByName( "queenofpain_blink" )
		end
	
		if blink ~= nil 
		   and blink:IsFullyCastable() 
		then
			local bDist = GetUnitToLocationDistance(bot,nLocation)
			local maxBlinkLoc = GetXUnitsTowardsLocationRune(bot, nLocation, 1199 )
			if bDist <= 500
			then
				return false
			elseif bDist < 1200
				then
					bot:Action_UseAbilityOnLocation(blink, nLocation)
					return true
			elseif IsLocationPassable(maxBlinkLoc)
				then
					bot:Action_UseAbilityOnLocation(blink, maxBlinkLoc)
					return true
			end
		end
	end
	
	
	
	if bot:GetItemSlotType(blinkSlot) == ITEM_SLOT_TYPE_MAIN 
	   or bot:GetUnitName() == "npc_dota_hero_magnataur"
	then
		local blink = bot:GetItemInSlot(blinkSlot)	
		if bot:GetUnitName() == "npc_dota_hero_magnataur"
		then
			blink = bot:GetAbilityByName( "magnataur_skewer" )
		end
	
		if blink ~= nil 
			and blink:IsFullyCastable()
			and bot:IsFacingLocation(nLocation, 5 )
		    
		then
			local bDist = GetUnitToLocationDistance(bot,nLocation)
			local maxBlinkLoc = GetXUnitsTowardsLocationRune(bot, nLocation, 1199 )
			if bDist <= 500
			then
				return false
			elseif bDist < 1200
				then
					bot:Action_UseAbilityOnLocation(blink, nLocation)
					return true
			elseif IsLocationPassable(maxBlinkLoc)
				then
					bot:Action_UseAbilityOnLocation(blink, maxBlinkLoc)
					return true
			end
		end
	end
	
	
	
	if bot:GetItemSlotType(blinkSlot) == ITEM_SLOT_TYPE_MAIN 
	   or bot:GetUnitName() == "npc_dota_hero_morphling"
	then
		local blink = bot:GetItemInSlot(blinkSlot)	
		if bot:GetUnitName() == "npc_dota_hero_morphling"
		then
			blink = bot:GetAbilityByName( "morphling_waveform" )
		end
	
		if blink ~= nil 
		   and blink:IsFullyCastable() 
		then
			local bDist = GetUnitToLocationDistance(bot,nLocation)
			local maxBlinkLoc = GetXUnitsTowardsLocationRune(bot, nLocation, 1199 )
			if bDist <= 500
			then
				return false
			elseif bDist < 1200
				then
					bot:Action_UseAbilityOnLocation(blink, nLocation)
					return true
			elseif IsLocationPassable(maxBlinkLoc)
				then
					bot:Action_UseAbilityOnLocation(blink, maxBlinkLoc)
					return true
			end
		end
	end
	
	if bot:GetItemSlotType(blinkSlot) == ITEM_SLOT_TYPE_MAIN 
	   or bot:GetUnitName() == "npc_dota_hero_void_spirit"
	then
		local blink = bot:GetItemInSlot(blinkSlot)	
		if bot:GetUnitName() == "npc_dota_hero_void_spirit"
		then
			blink = bot:GetAbilityByName( "void_spirit_astral_step" )
		end
	
		if blink ~= nil 
		   and blink:IsFullyCastable() 
		then
			local bDist = GetUnitToLocationDistance(bot,nLocation)
			local maxBlinkLoc = GetXUnitsTowardsLocationRune(bot, nLocation, 1199 )
			if bDist <= 500
			then
				return false
			elseif bDist < 1200
				then
					bot:Action_UseAbilityOnLocation(blink, nLocation)
					return true
			elseif IsLocationPassable(maxBlinkLoc)
				then
					bot:Action_UseAbilityOnLocation(blink, maxBlinkLoc)
					return true
			end
		end
	end
	
	
	
	
	
	if bot:GetItemSlotType(blinkSlot) == ITEM_SLOT_TYPE_MAIN 
	   or bot:GetUnitName() == "npc_dota_hero_storm_spirit"
	then
		local blink = bot:GetItemInSlot(blinkSlot)	
		if bot:GetUnitName() == "npc_dota_hero_storm_spirit"
		then
			blink = bot:GetAbilityByName( "storm_spirit_ball_lightning" )
		end
	
		if blink ~= nil 
		   and blink:IsFullyCastable() 
		then
			local bDist = GetUnitToLocationDistance(bot,nLocation)
			local maxBlinkLoc = GetXUnitsTowardsLocationRune(bot, nLocation, 1199 )
			if bDist <= 500
			then
				return false
			elseif bDist < 1200
				then
					bot:Action_UseAbilityOnLocation(blink, nLocation)
					return true
			elseif IsLocationPassable(maxBlinkLoc)
				then
					bot:Action_UseAbilityOnLocation(blink, maxBlinkLoc)
					return true
			end
		end
	end
	
	return false
end



function GetXUnitsTowardsLocationRune( hUnit, vLocation, nDistance)
    local direction = (vLocation - hUnit:GetLocation()):Normalized()
    return hUnit:GetLocation() + direction * nDistance
end





function IsUnitAroundLocation(vLoc, nRadius)
	for i,id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id)
			if info ~= nil then
				local dInfo = info[1]
				if dInfo ~= nil and GetDistance(vLoc, dInfo.location) <= nRadius and dInfo.time_since_seen < 1.0 then
					return true
				end
			end
		end
	end
	return false
end



function FarmGetVulnerableRandomUnit2(bHero, bEnemy, nRadius, bot)
	local units = {};
	local weakest = nil;
	local weakestHP = 10000;
	if bHero then
		units = bot:GetNearbyHeroes(nRadius, bEnemy, BOT_MODE_NONE);
	else
		units = bot:GetNearbyCreeps(nRadius, bEnemy);
	end
	for _,u in pairs(units) do
		if u:GetHealth() > weakestHP and mUtils.CanCastOnNonMagicImmune(u) then
			weakest = u;
			weakestHP = u:GetHealth();
		end
	end
	return weakest;
end



function GetWeakestUnit(bot,heros,creeps)
	-- local lowestHP = 10000;
	-- local lowestUnit = nil;
	-- -- for _,unit in pairs(units)
	-- -- do
		-- -- local hp = unit:GetHealth();
		-- -- if hp < lowestHP then
			-- -- lowestHP = hp;
			-- -- lowestUnit = unit;	
		-- -- end
	-- -- end
	-- for _,unit in pairs(units)
	-- do
	-- for i=1, #units do
	-- local hp = unit[i]:GetHealth();
		-- if hp < lowestHP then
			-- lowestHP = hp;
			-- lowestUnit = unit[i];	
		-- end
	-- end
		-- return lowestUnit;
	-- end
	-- return nil;
	local tgt = GetTargetHit(bot,heros, creeps)
	if tgt == nil then
		tgt = GetTargetHit (bot,heros, creeps)
		end
	return tgt;
end


function GetTargetHit(bot, heros,creeps)
	for i=1, #creeps do
		if CanHitCreep(bot, creeps[i]) == true 
		then
			return creeps[i];
		end
	end
	
	for i=1, #creeps do
		if CanHitCreep2(bot, creeps[i]) == true 
		then
			return creeps[i];
		end
	end
	
	
	for i=1, #heros do
		if CanHitHero(bot, heros[i]) == true 
		then
			return heros[i];
		end
	end
	
	
	return nil;
end


function CanHitCreep(bot, creep)
	return creep:GetActualIncomingDamage(1.05*bot:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL) >= creep:GetHealth()
	and creep:IsAlive() and creep:CanBeSeen() and not creep:IsNull() and not creep:IsBuilding()
	and GetUnitToUnitDistance (bot,creep) < nAttactRange
end


function CanHitCreep2(bot, creep)
	return creep:GetHealth() > 2*bot:GetAttackDamage()
	and creep:IsAlive() and creep:CanBeSeen() and not creep:IsNull() and not creep:IsBuilding()
	and GetUnitToUnitDistance (bot,creep) < nAttactRange
end



function CanHitHero(bot,hero)	
	-- local hero = nil;
	-- if hero == nil then hero = bot:GetTarget() end
	
	return hero ~= bot:GetTarget() and hero:IsAlive() and hero:IsHero() and not hero:IsNull() 
	and GetUnitToUnitDistance (bot,hero) < nAttactRange 
	and 1.6 * bot:GetEstimatedDamageToTarget(true, bot, 4.0, DAMAGE_TYPE_ALL) > hero:GetEstimatedDamageToTarget(true, bot, 4.0, DAMAGE_TYPE_ALL)
	and bot:GetHealth() > 500 ; 
end


function IsTargetedByCreepOrTower(bot, ecreeps, etowers,heros)
	for i=1, #ecreeps do
		if ecreeps[i]:GetAttackTarget() == bot then
			return true;
		end
	end
	for i=1, #etowers do
		if etowers[i]:GetAttackTarget() == bot then
			return true;
		end
	end
	
	for i=1, #heros do
		if heros[i]:GetAttackTarget() == bot then
			return true;
		end
	end
	
	return false
end



function IsThereCarry(runeLoc)
		
	if IsNotPowerRune(runeLoc) then return false end

	for k,v in pairs(teamPlayers)
	do
		local member = GetTeamMember(k)
		if member ~= nil 
			and member:IsAlive() and role.CanBeSafeLaneCarry(member:GetUnitName()) 
		   and ( (GetTeam()==TEAM_DIRE and member:GetAssignedLane()==LANE_TOP) or (GetTeam()==TEAM_RADIANT and member:GetAssignedLane()==LANE_BOT)  )	
		then
			local dist1 = GetUnitToLocationDistance(member, runeLoc)
			local dist2 = GetUnitToLocationDistance(bot, runeLoc)
			if dist2 < 1200 and dist1 < 1200 and bot:GetUnitName() ~= member:GetUnitName() then
			-- if dist2 < 1200 and dist1 < 600 and bot:GetUnitName() ~= member:GetUnitName() then
				return true
			end
		end
	end
	
	return false
end



function IsNotPowerRune(runeLoc)
	
	local rLocOne = GetRuneSpawnLocation(RUNE_POWERUP_1)
	local rLocTwo = GetRuneSpawnLocation(RUNE_POWERUP_2)
	
	if utils.GetDistance(rLocOne, runeLoc) >= 600 and utils.GetDistance(rLocTwo, runeLoc) >= 600
	then
		return true
	end
	
	return false
end


function IsMissing(r)

	local sec = DotaTime() % 60
	local runeStatus = GetRuneStatus( r )
	
	if sec < 52 -- here has a bug
		and runeStatus ==  RUNE_STATUS_MISSING
		and not runeStatus == RUNE_STATUS_UNKNOWN
	then
		return true
	end
	
    return false
end


function IsKnown(r)
	
	if DotaTime() < 6 * 60
		or DotaTime() > 39 * 60 + 50 then return false end  
	
	if r == RUNE_POWERUP_1 
		or r == RUNE_POWERUP_2
		or r == RUNE_BOUNTY_1
		or r == RUNE_BOUNTY_2
	then
		local runeStatus = GetRuneStatus( r )
		
		if ( minute % 2 == 0 or sec < 52 )
			and runeStatus == RUNE_STATUS_UNKNOWN
			and Role.IsPowerRuneKnown()
		then
			return true
		end
	
	end

	return false
end