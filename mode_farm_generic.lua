local role = require( "bots/RoleUtility");
local utils = require( "bots/util")
local campUtils = require( "bots/CampUtility")
local Site = require( "bots/jmz_site" )
local mutil = require("bots/MyUtility")
local Role = require( "bots/jmz_role" )


local bot = GetBot()
local minute = 0;
local sec = 0;
local preferedCamp = nil;
local AvailableCamp = {};
local LaneCreeps = {}; 
-- local LaneCreeps = bot:GetNearbyCreeps(1600, true)
local numCamp = 18;
local farmState = 0;
local teamPlayers = nil;
local lanes = {LANE_TOP, LANE_MID, LANE_BOT};
local cause = "";
local cogsTarget = nil;
local t3Destroyed = false;
local shrineTarget = nil;
local cLoc = nil;
local farmLane = false;

local tPing = 0;
local tChat = 0;

local testTime = 0;

---------------

local bDebugMode = ( 1 == 10 )
local RB = Vector(-7174.000000, -6671.00000, 0.000000)
local DB = Vector(7023.000000, 6450.000000, 0.000000)

local botName = bot:GetUnitName();
-- local minute = 0;
-- local sec = 0;
local preferedCamp2 = nil;
local availableCamp = {};
local hLaneCreepList = {};
-- local hLaneCreepList = bot:GetNearbyCreeps(1600, true)
-- local numCamp = 18;
-- local farmState = 0;
-- local teamPlayers = nil;
local nLaneList = {LANE_TOP, LANE_MID, LANE_BOT};
local nTpSolt = 15
local nNeutralItemSolt = 16

local t3Destroyed = false;


local runTime = 0;
local shouldRunTime = 0
local runMode = false;

local pushTime = 0;
local laningTime = 0;
local assembleTime = 0;
local teamTime = 0;

local countTime = 0;
local countCD = 5.0;
local allyKills = 0;
local enemyKills = 0;

local nLostCount = RandomInt(35,45);
local nWinCount = RandomInt(24,34);

local bInitDone = false;
local beNormalFarmer = false;
local beHighFarmer = false;
local beVeryHighFarmer = false;


local unitName = bot:GetUnitName();
local lastPing = -90;


local nAttackRange = bot:GetAttackRange();
-- local test1 = false
-- local test2 = false
local cLoc2 = nil;



local myTeam = GetTeam();
local teamPlayer = GetTeamPlayers(myTeam)
local enemyTeam = GetOpposingTeam();
local enemyPlayer = GetTeamPlayers(enemyTeam)
local tAncient = GetAncient(myTeam);
local eAncient = GetAncient(enemyTeam);
local state = nil;


bot.farmLaneLocation = nil;
local dfarmLaneLocation = 0;
local lfarmLaneLocation = -1;
local RetreatLoc = mutil.GetTeamFountain()
local attackRange = bot:GetAttackRange();
local AttackDamage = bot:GetAttackDamage()

function GetDesire()	
	
	--campUtils.PrintCamps()

	--[[if DotaTime() > testTime + 20.0 then
		campUtils.PingCamp(1, 3, TEAM_RADIANT, bot);
		testTime = DotaTime();
	end]]--

	-- if bot:GetUnitName() == "npc_dota_hero_faceless_voids" and bot:IsAlive() then
	if bot:IsAlive()  
	-- and DotaTime() < 25*60
	-- and  role.IsCarry(unitName) 
	-- and not bot:GetAssignedLane() == LANE_MID
	then
		cLoc = GetSaveLocToFarmLane();
		if cLoc ~= nil  then
			--bot:ActionImmediate_Ping(cLoc.x, cLoc.y, true);
			--tPing = DotaTime();
			farmLane = true;
			return BOT_MODE_DESIRE_HIGH;
		else
			farmLane = false;
		end
	end
	
	local num_cogs = 0;
	
	if IsUnitAroundLocation(GetAncient(GetTeam()):GetLocation(), 3000) then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if teamPlayers == nil then teamPlayers = GetTeamPlayers(GetTeam()) end
	
	local EnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	
	minute = math.floor(DotaTime() / 60)
	sec = DotaTime() % 60
	
	if #AvailableCamp < numCamp and ( ( DotaTime() > 30 and DotaTime() < 60 and sec > 30 and sec < 31 ) 
	   or ( DotaTime() > 30 and  sec > 0 and sec < 1 ) ) 
	then
		AvailableCamp, numCamp = campUtils.RefreshCamp(bot);
		--print(tostring(GetTeam())..tostring(#AvailableCamp))
	end
	
	if bot:GetUnitName() == "npc_dota_hero_rattletrap" then
		if ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:WasRecentlyDamagedByAnyHero(3.0) ) or #EnemyHeroes == 0 or cause == "cogs" then
			local units = GetUnitList(UNIT_LIST_ALLIED_OTHER);
			local minDist = 10000;
			for _,u in pairs(units)
			do
				if u:GetUnitName() == "npc_dota_rattletrap_cog" then
					num_cogs = num_cogs + 1;
					local cogDist = GetUnitToUnitDistance(u, GetAncient(GetTeam()));
					if cogDist < minDist then
						cogsTarget = u;
						minDist = cogDist;
					end
				end
			end
			if num_cogs == 8 then
				--print("attack cogs while retreat. Num cogs = "..tostring(num_cogs));
				cause = "cogs";
				return BOT_MODE_DESIRE_ABSOLUTE;
			end
		elseif bot:GetActiveMode() == BOT_MODE_ATTACK or cause == "cogs" then
			local npcTarget = bot:GetTarget();
			if npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance(bot, npcTarget) > 300 then
				local units = GetUnitList(UNIT_LIST_ALLIED_OTHER);
				local minDist = 10000;
				for _,u in pairs(units)
				do
					if u:GetUnitName() == "npc_dota_rattletrap_cog" then
						num_cogs = num_cogs + 1;
						local cogDist = GetUnitToUnitDistance(u, npcTarget);
						if cogDist < minDist then
							cogsTarget = u;
							minDist = cogDist;
						end
					end
				end
				if num_cogs == 8 then
					cause = "cogs";
					return BOT_MODE_DESIRE_ABSOLUTE;
				end
			end
		end	
		
	end
	
	if #EnemyHeroes >= 3 then
		return BOT_MODE_DESIRE_NONE;
	end		
	
	if not bot:IsAlive() or bot:IsChanneling() or bot:GetCurrentActionType() == 1 or bot:GetNextItemPurchaseValue() == 0 
	   or bot:WasRecentlyDamagedByAnyHero(3.0) or #EnemyHeroes >= 3 
	   or ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
	   or ( bot:WasRecentlyDamagedByAnyHero(2.5) and bot:GetAttackTarget() == nil )
	   or bot.SecretShop
	   -------
	   -- or bot:GetActiveMode() == BOT_MODE_RUNE
	   -- or bot:GetActiveMode() == BOT_MODE_ITEM
	   -- or bot:GetActiveMode() == BOT_MODE_WARD
	   -- or bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY
	  
	then
		return BOT_MODE_DESIRE_NONE;
	end
	
	-- if t3Destroyed == false then
		-- t3Destroyed = IsThereT3Detroyed();
	-- else
		-- if bot:DistanceFromFountain() > 10000 then
			-- shrineTarget = GetTargetShrine();
			-- local barracks = bot:GetNearbyBarracks(700, true);
			-- if shrineTarget ~= nil and ( barracks == nil or #barracks == 0 ) and IsSuitableToDestroyShrine()  then
				-- cause = "shrine";
				-- return BOT_MODE_DESIRE_VERYHIGH;
			-- end
		-- end
	-- end
	if campUtils.IsStrongJungler(bot) and bot:GetLevel() >= 6 and bot:GetLevel() < 25 and not IsHumanPlayerInTeam() and GetGameMode() ~= GAMEMODE_MO 
	then
		LaneCreeps = bot:GetNearbyLaneCreeps(1600, true);
		if LaneCreeps ~= nil and #LaneCreeps > 0 then
			return BOT_MODE_DESIRE_HIGH;
		else
			if preferedCamp == nil then preferedCamp = campUtils.GetClosestNeutralSpwan(bot, AvailableCamp) end
			if preferedCamp ~= nil then
				if bot:GetHealth() / bot:GetMaxHealth() <= 0.15 then 
					preferedCamp = nil;
					return BOT_MODE_DESIRE_LOW;
				elseif farmState == 1 then 
					return BOT_MODE_DESIRE_ABSOLUTE;
				elseif not campUtils.IsSuitableToFarm(bot) then 
					preferedCamp = nil;
					return BOT_MODE_DESIRE_NONE;
				else
					return BOT_MODE_DESIRE_HIGH;
				end
			end
		end
	end
	
	return 0.0
	
end
	
	-- if ( campUtils.IsStrongJungler1(bot) and bot:GetLevel() >= 3 and bot:GetLevel() <= 25 and GetGameMode() ~= GAMEMODE_AP)
	-- or ( campUtils.IsStrongJungler2(bot) and bot:GetLevel() >= 6 and bot:GetLevel() <= 25 and GetGameMode() ~= GAMEMODE_AP)
	-- or ( campUtils.IsStrongJungler3(bot) and bot:GetLevel() >= 8 and bot:GetLevel() <= 25 and GetGameMode() ~= GAMEMODE_AP)
	-- or ( campUtils.IsStrongJungler1(bot) and bot:GetLevel() >= 3 and bot:GetLevel() <= 25 and GetGameMode() ~= GAMEMODE_MO)		
	-- or ( campUtils.IsStrongJungler2(bot) and bot:GetLevel() >= 6 and bot:GetLevel() <= 25 and GetGameMode() ~= GAMEMODE_MO)
	-- or ( campUtils.IsStrongJungler3(bot) and bot:GetLevel() >= 8 and bot:GetLevel() <= 25 and GetGameMode() ~= GAMEMODE_MO)
	-- -- or ( role.IsSupport(unitName) and bot:GetLevel() <= 25  ) and (DotaTime() > 2*60 and sec > 53 and sec < 56 ) and DotaTime() < 20*60
	if (role.IsCarry(unitName) and bot:GetLevel() >= 6
	-- and DotaTime() < 25*60
	)
	then
		-- test1 = true
		LaneCreeps = bot:GetNearbyCreeps(1600, true);
		if LaneCreeps ~= nil and #LaneCreeps > 0 then
			-- test1 = true
			return BOT_MODE_DESIRE_HIGH;
		else
			if preferedCamp == nil then preferedCamp = campUtils.GetClosestNeutralSpwan(bot, AvailableCamp) end
			if preferedCamp ~= nil then
				-- test1 = true
				if bot:GetHealth() / bot:GetMaxHealth() <= 0.15 then 
					-- test1 = true
					preferedCamp = nil;
					return BOT_MODE_DESIRE_LOW;
				elseif farmState == 1 then 
					-- test1 = true
					return BOT_MODE_DESIRE_ABSOLUTE;
				elseif not campUtils.IsSuitableToFarm(bot) then 
					-- test1 = false
					preferedCamp = nil;
					return BOT_MODE_DESIRE_NONE;
				else
					-- test1 = true
					return BOT_MODE_DESIRE_HIGH;
				end
			end
		end
	end
	
	
	
	
	
	
	
	-- if ( role.IsSupport(unitName) and bot:GetLevel() <= 25  ) and (DotaTime() > 1*60   and DotaTime() < 20*60 )
		-- and cLoc2 ~= nil
	if (bot:IsAlive()   and not role.IsCarry(unitName) ) 
	and (DotaTime() > 1*60  
	-- and DotaTime() < 25*60 
	)
	and (sec > 45 and sec < 54 )
	
	then
		-- test2 = true
		LaneCreeps = bot:GetNearbyCreeps(1600, true);
		if LaneCreeps ~= nil and #LaneCreeps > 0 
		-- and cLoc2 ~= nil 
		then
			-- test2 = true
			return BOT_MODE_DESIRE_HIGH;
		else
			if preferedCamp == nil then preferedCamp = campUtils.GetClosestNeutralSpwan(bot, AvailableCamp) end
			if preferedCamp ~= nil 
			-- and cLoc2 ~= nil
			then
				-- test2 = true
				if bot:GetHealth() / bot:GetMaxHealth() <= 0.15 then 
					-- test2 = true
					preferedCamp = nil;
					return BOT_MODE_DESIRE_LOW;
				elseif farmState == 1
				-- and cLoc2 ~= nil 
				then
					-- test2 = true
					return BOT_MODE_DESIRE_ABSOLUTE;
				elseif not campUtils.IsSuitableToFarm(bot) then 
					-- test2 = false
					preferedCamp = nil;
					
					return BOT_MODE_DESIRE_NONE;
				else
					-- test2 = true
					return BOT_MODE_DESIRE_HIGH;
				end
			end
		end
	end
	
	
	-----------------------------
	
	if not bInitDone
	then
		bInitDone = true
		beNormalFarmer = IsNormalFarmer(bot);
		beHighFarmer = IsHighFarmer(bot);
		beVeryHighFarmer = IsVeryHighFarmer(bot);
	end
	
	if DotaTime() < 50 then return 0.0 end
	
	if bot:IsAlive()  --For sometime to run
	then
		if runTime ~= 0 
			and ((DotaTime() < runTime + shouldRunTime)     )
			-- or (DotaTime() > runTime + shouldRunTime)
		then
			-- runMode = true;
			return BOT_MODE_DESIRE_ABSOLUTE * 1.03;
		else
			runTime = 0;
			runMode = false;
		end
		
		shouldRunTime = ShouldRun(bot);
		if shouldRunTime ~= 0
		then
			if runTime == 0 then 
				runTime = DotaTime(); 
				runMode = true;
				preferedCamp2 = nil;
				bot:Action_ClearActions(false);
			end
			return BOT_MODE_DESIRE_ABSOLUTE * 1.03;
		end
	end
	
	
	
	if not Role.IsCampRefreshDone()
	   and Role.GetAvailableCampCount() < Role.GetCampCount()
	   and ( DotaTime() > 30 and  sec > 0 and sec < 2 )  
	then
		Role['availableCampTable'], Role['campCount'] = Site.RefreshCamp(bot);
		Role['hasRefreshDone'] = true;
	end
	
	if Role.IsCampRefreshDone() and sec > 52
	then
		Role['hasRefreshDone'] = false;
	end
	
	availableCamp = Role['availableCampTable'];
	
	local hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	local hNearbyAttackAllyHeroList  = bot:GetNearbyHeroes(1600, false,BOT_MODE_ATTACK);
	
	
	if #hEnemyHeroList >= 3 or #hNearbyAttackAllyHeroList > 1
	then
		return BOT_MODE_DESIRE_NONE;
	end	

	local nAttackAllys = GetSpecialModeAllies(bot,2600,BOT_MODE_ATTACK);
	if #nAttackAllys > 0 and (not beVeryHighFarmer or bot:GetLevel() >= 18)
	then
		return BOT_MODE_DESIRE_NONE;
	end	
	
	local nRetreatAllyList = bot:GetNearbyHeroes(1600,false,BOT_MODE_RETREAT);
	if mutil.IsValid(nRetreatAllyList[1]) and (not beVeryHighFarmer or bot:GetLevel() >= 22)
	   and nRetreatAllyList[1]:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH
	then
		return BOT_MODE_DESIRE_NONE;
	end
	
	local nTeamFightLocation = GetTeamFightLocation(bot);
	if nTeamFightLocation ~= nil 
	   and (not beVeryHighFarmer or bot:GetLevel() >= 20)
	   and GetUnitToLocationDistance(bot,nTeamFightLocation) < 2800
	then
		return BOT_MODE_DESIRE_NONE;
	end	
	
	
	if bot:GetActiveMode() == BOT_MODE_LANING then laningTime = DotaTime(); end
	if DotaTime() - laningTime < 15.0 and GetHeroDeaths(bot:GetPlayerID()) <= 2 then return BOT_MODE_DESIRE_NONE; end	
	
	if bot:IsAlive() and bot:HasModifier('modifier_arc_warden_tempest_double') 
	   and GetRoshanDesire() > 0.85
	then
		if preferedCamp2 == nil then preferedCamp2 = Site.GetClosestNeutralSpwan(bot, availableCamp) end;
		return 0.99;
	end
	
	local aliveEnemyCount = GetNumOfAliveHeroes(true);
	local aliveAllyCount  = GetNumOfAliveHeroes(false);
	if aliveEnemyCount <= 2
	then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if not Role.IsAllyHaveAegis() and IsHaveAegis(bot) then Role['aegisHero'] = bot end;
	if Role.IsAllyHaveAegis() and aliveAllyCount >= 4
	then
		return BOT_MODE_DESIRE_NONE;
	end
	
	---------------------------------------------------
	
	if (aliveAllyCount >= aliveEnemyCount * 2 ) 
	-- and (DotaTime() > 25 *60)
	and bot:IsAlive()
	then
		bot.farmLaneLocation, dfarmLaneLocation, lfarmLaneLocation = GetClosestSafeLaneToFarm();
		if bot.farmLaneLocation ~= nil then
			local hpPct = bot:GetHealth() / bot:GetMaxHealth();
			return RemapValClamped(hpPct, 0, 0.5, BOT_MODE_DESIRE_NONE, BOT_MODE_DESIRE_ABSOLUTE)
		end
	end
	
	
	--------------------------------------------
	
	if DotaTime() > countTime + countCD
	then
		countTime  = DotaTime();
		allyKills  = GetNumOfTeamTotalKills(false);
		enemyKills = GetNumOfTeamTotalKills(true);

		
		if enemyKills > allyKills + nLostCount and Role.NotSayRate() 
		then
			Role['sayRate'] = true;
			if RandomInt(1,6) < 3 
			then
				bot:ActionImmediate_Chat("!Bien jugado! ",true);
			else
				bot:ActionImmediate_Chat("estimamos que la probabilidad de ganar es menor al 5%.Bien jugado!",true);
			end
		end
		if allyKills > enemyKills + nWinCount and Role.NotSayRate() 
		then
		    Role['sayRate'] = true;
			if RandomInt(1,6) < 3 
			then
				bot:ActionImmediate_Chat("!Bien jugado!",true);
			else
				bot:ActionImmediate_Chat("estimamos que la probabilidad de victoria es mayor al 90%.",true);
			end
		end
	
	end
	if allyKills > enemyKills + 20 and aliveAllyCount >= 4
	then return BOT_MODE_DESIRE_NONE; end
	
	local nAlliesCount = GetAllyCount(bot,1400);
	if nAlliesCount >= 4
	   or (bot:GetLevel() >= 23 and nAlliesCount >= 3)
	   or GetRoshanDesire() > BOT_MODE_DESIRE_VERYHIGH
	then
		local nNeutrals = bot:GetNearbyNeutralCreeps(bot:GetAttackRange() + 110); --sniper will bug
		if #nNeutrals == 0 
		then 
		    teamTime = DotaTime();
		end
	end	
	if GetDefendLaneDesire(LANE_TOP) > 0.85
	   or GetDefendLaneDesire(LANE_MID) > 0.80
	   or GetDefendLaneDesire(LANE_BOT) > 0.85
	then
		local nDefendLane,nDefendDesire = GetMostDefendLaneDesire();
		local nDefendLoc  = GetLaneFrontLocation(GetTeam(),nDefendLane,-600);
		local nDefendAllies = GetAlliesNearLoc(nDefendLoc, 2200);
		
		local nNeutrals = bot:GetNearbyNeutralCreeps(bot:GetAttackRange() + 110); --sniper will bug
		
		if #nNeutrals == 0 and #nDefendAllies >= 2 and (not beVeryHighFarmer or bot:GetLevel() >= 15)
		then 
		    teamTime = DotaTime();
		end
	end
	if teamTime > DotaTime() - 3.0 then return BOT_MODE_DESIRE_NONE; end;
	
	if beNormalFarmer 
	then
		if bot:GetActiveMode() == BOT_MODE_ASSEMBLE then assembleTime = DotaTime(); end
		
		if DotaTime() - assembleTime < 15.0 then return BOT_MODE_DESIRE_NONE; end
		
		if IsTeamActivityCount(bot,3)	then return BOT_MODE_DESIRE_NONE; end
	end
	
	local madas = IsItemAvailable("item_hand_of_midas");
	if madas ~= nil and madas:IsFullyCastable() and IsInAllyArea(bot)
	then
		hLaneCreepList = bot:GetNearbyLaneCreeps(1600, true);
		if preferedCamp2 == nil then preferedCamp2 = Site.GetClosestNeutralSpwan(bot, availableCamp) end;
		return BOT_MODE_DESIRE_HIGH;
	end
	
	if GetGameMode() ~= GAMEMODE_MO 
	-- if GetGameMode() ~= GAMEMODE_MO or GetGameMode() ~= GAMEMODE_AP
	   and ( Site.IsTimeToFarm(bot) or pushTime > DotaTime() - 8.0 )
	   and ( not IsHumanPlayerInTeam() or enemyKills > allyKills + 16 ) 
	   and ( bot:GetNextItemPurchaseValue() > 0 or not bot:HasModifier("modifier_item_moon_shard_consumed") )
	   and ( DotaTime() > 9 * 60 or bot:GetLevel() >= 8 or ( bot:GetAttackRange() < 220 and bot:GetLevel() > 6 ) )	   
	then
		if GetDistanceFromEnemyFountain(bot) > 4000 
		then
			hLaneCreepList = bot:GetNearbyLaneCreeps(1600, true);
			if #hLaneCreepList == 0	
			   and IsInAllyArea( bot )
			   and IsNearLaneFront( bot )
			then
				hLaneCreepList = bot:GetNearbyLaneCreeps(1600, false);
			end
		end;		
		
		if #hLaneCreepList > 0 
		then
			return BOT_MODE_DESIRE_HIGH;
		else
			if preferedCamp2 == nil then preferedCamp2 = Site.GetClosestNeutralSpwan(bot, availableCamp);end
			
			if preferedCamp2 ~= nil then
				if not Site.IsModeSuitableToFarm(bot) 
				then 
					preferedCamp2 = nil;
					return BOT_MODE_DESIRE_NONE;
				elseif bot:GetHealth() <= 200 
					then 
						preferedCamp2 = nil;
						teamTime = DotaTime();
						return BOT_MODE_DESIRE_VERYLOW;
				elseif farmState == 1
				    then 
					    return BOT_MODE_DESIRE_ABSOLUTE *0.89;
				else
					
					if aliveEnemyCount >= 3
					then
						if pushTime > DotaTime() - 8.0
						then
							if preferedCamp2 == nil then preferedCamp2 = Site.GetClosestNeutralSpwan(bot, availableCamp);end
							return BOT_MODE_DESIRE_MODERATE;
						end
						
						if bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT
							or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
							or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP
						then
							local enemyAncient = GetAncient(GetOpposingTeam());
							local allies       = bot:GetNearbyHeroes(1400,false,BOT_MODE_NONE);
							local enemyAncientDistance = GetUnitToUnitDistance(bot,enemyAncient);
							if enemyAncientDistance < 2800
								and enemyAncientDistance > 1600
								and bot:GetActiveModeDesire() < BOT_MODE_DESIRE_HIGH
								and #allies < 2
							then
								pushTime = DotaTime();
								return  BOT_MODE_DESIRE_ABSOLUTE *0.93;
							end
							
							if beHighFarmer or bot:GetAttackRange() < 310
							then
								if  bot:GetActiveModeDesire() <= BOT_MODE_DESIRE_MODERATE 
									and enemyAncientDistance > 1600
									and enemyAncientDistance < 5800
									and #allies < 2
								then
									pushTime = DotaTime();
									return  BOT_MODE_DESIRE_ABSOLUTE *0.98;
								end
							end
						
						end
					end
					
					local farmDistance = GetUnitToLocationDistance(bot,preferedCamp2.cattr.location);
					
					if botName == 'npc_dota_hero_medusa' and farmDistance < 133 then return 0.33 end 
					
					return math.floor((RemapValClamped(farmDistance, 6000, 0, BOT_MODE_DESIRE_MODERATE, BOT_MODE_DESIRE_VERYHIGH))*10)/10;
				end
			end
		end
	end
	
	
	-- return 0.0 ------ end Desire


function OnStart()

end

function OnEnd()
	preferedCamp = nil;
	farmState = 0;
	cogsTarget = nil;
	cogs = "";
	cause = "";
	shrineTarget = nil;
	
	LaneCreeps = {}
	
	-------------
	preferedCamp2 = nil;
	-- farmState = 0;
	hLaneCreepList  = {};
	runMode = false;
	runTime = 0;
	bot:SetTarget(nil);
	
	bot.farmLaneLocation = nil;
	dfarmLaneLocation = 0;
	lfarmLaneLocation = -1;
end

function Think()

	if mutil.CanNotUseAction(bot)
		or bot:GetCurrentActionType() == BOT_ACTION_TYPE_PICK_UP_ITEM
		or bot:GetCurrentActionType() == BOT_ACTION_TYPE_PICK_UP_RUNE
		or bot:GetCurrentActionType() == BOT_ACTION_TYPE_DROP_ITEM
		or bot:NumQueuedActions() > 0
	then 
	  return 
	end



	if bot:IsUsingAbility() or bot:IsChanneling()  or bot:IsCastingAbility() then 
		return
	end
	
	local tp = bot:GetItemInSlot(15);
	if bot.farmLaneLocation ~= nil then
		if tp ~= nil and tp:IsFullyCastable() 
			and GetUnitToLocationDistance(bot, bot.farmLaneLocation) > 4500 
			and GetNEnemyAroundLocation(bot:GetLocation(), 1600, 3.0) == 0
		then
			bot:Action_UseAbilityOnLocation(tp, bot.farmLaneLocation);
			return
		end
	end
	
	
	
	
	
	if farmLane 
	-- and DotaTime() < 25*60
	then
		local laneCreeps = bot:GetNearbyLaneCreeps(1600, true);
		local target = GetWeakestUnit(laneCreeps);
		if target ~= nil then
			local t = 2.0*bot:GetAttackPoint()+((GetUnitToUnitDistance(target, bot))/bot:GetCurrentMovementSpeed());
			-- print(tostring(bot:GetEstimatedDamageToTarget(false, target, t, DAMAGE_TYPE_PHYSICAL ).."><"..tostring(target:GetHealth())))
			if bot:WasRecentlyDamagedByTower(1.0) or bot:WasRecentlyDamagedByCreep(1.0) then
				bot:Action_MoveToLocation(GetAncient(GetTeam()):GetLocation());
				return
			elseif  bot:GetEstimatedDamageToTarget(false, target, t, DAMAGE_TYPE_PHYSICAL) >= target:GetHealth() then
				bot:SetTarget(target);
				bot:Action_AttackUnit(target, true);
				return
			else
				bot:Action_MoveToLocation(target:GetLocation());
				return
			end
		else
			bot:SetTarget(nil);
			bot:Action_MoveToLocation(cLoc+RandomVector(200));
			return
		end
	end
	
	if cause == "cogs" then
		print("Attack Cogs")
		bot:Action_ClearActions(false);
		bot:Action_AttackUnit( cogsTarget, true );
		cause = "";
		return;
	-- elseif cause == "shrine" then
		-- if GetUnitToUnitDistance(bot, shrineTarget) > 500 then
			-- bot:Action_MoveToLocation(shrineTarget:GetLocation())
			-- return
		-- else
			-- bot:Action_AttackUnit(shrineTarget, true)
			-- return
		-- end
	end	
	
	-- if LaneCreeps == nil then LaneCreeps = bot:GetNearbyCreeps(1600, true) return end
	
	-- if LaneCreeps ~= nil and #LaneCreeps > 0 then
	-- local farmTarget = campUtils.FindFarmedTarget(LaneCreeps)
	
		
		-- if farmTarget ~= nil and farmTarget:IsAlive() then
			-- --print("This")
			-- bot:SetTarget(farmTarget);
			-- bot:Action_AttackUnit(farmTarget, true);
			-- return
		-- end
	-- end
	
	
	
	
	if LaneCreeps ~= nil and #LaneCreeps > 0 
	-- and DotaTime() < 25*60 
	then
		local farmTarget = Site.GetFarmLaneTarget2(LaneCreeps);
		local nSearchRange = bot:GetAttackRange() + 180
		if nSearchRange > 1600 then nSearchRange = 1600 end
		local nNeutrals = bot:GetNearbyNeutralCreeps(nSearchRange);
		if farmTarget ~= nil and #nNeutrals == 0 then
						
			if farmTarget:GetTeam() == bot:GetTeam() 
			   and IsInAllyArea(farmTarget)
			then
				bot:Action_MoveToLocation(farmTarget:GetLocation() + RandomVector(300));
				return
			end
			
			if farmTarget:GetTeam() ~= bot:GetTeam()
			then
				--如果小兵正在被友方小兵攻击且生命值略高于自己的击杀线则S自己的出手
				local allyTower = bot:GetNearbyTowers(1000,true)[1];
				if bot:GetAttackTarget() == farmTarget
				   and ( GetAttackEnemysAllyCreepCount(farmTarget, 800) > 0
						   or ( allyTower ~= nil and allyTower:GetAttackTarget() == farmTarget ) )
				then
					local botDamage = bot:GetAttackDamage();
					local nDamageReduce = bot:GetAttackCombatProficiency(farmTarget)
					if bot:FindItemSlot("item_quelling_blade") > 0
						or bot:FindItemSlot("item_bfury") > 0
					then
						botDamage = botDamage + 18;
					end
					
					if not mutil.CanKillTarget(farmTarget, botDamage * nDamageReduce, DAMAGE_TYPE_PHYSICAL)
					   and mutil.CanKillTarget(farmTarget, (botDamage +99) * nDamageReduce, DAMAGE_TYPE_PHYSICAL)
					then
						
						bot:Action_ClearActions( true );
						
					    return
					end
				end
			
				if bot:GetAttackRange() > 310 
				then
					if GetUnitToUnitDistance(bot,farmTarget) > bot:GetAttackRange() + 180
					then
						bot:Action_MoveToLocation(farmTarget:GetLocation());
						return
					else
						bot:SetTarget(farmTarget);
						bot:Action_AttackUnit(farmTarget, true);
						return
					end
				else
					if ( GetUnitToUnitDistance(bot,farmTarget) > bot:GetAttackRange() + 100 )
						or bot:GetAttackDamage() > 200
					then
						bot:SetTarget(LaneCreeps[1]);
						bot:Action_AttackUnit(LaneCreeps[1], true);
						return
					else
						bot:SetTarget(farmTarget);
						bot:Action_AttackUnit(farmTarget, true);
						return
					end
				end
			end
		end
	end
	
	
	
	
	
		
	if preferedCamp ~= nil 
	-- and DotaTime() < 25*60
	-- and test1 
	and  role.IsCarry(unitName) 
	then
		local cDist = GetUnitToLocationDistance(bot, preferedCamp.cattr.location);
		local stackMove = campUtils.GetCampMoveToStack(preferedCamp.idx);
		local stackTime =  campUtils.GetCampStackTime(preferedCamp);
		if ( cDist > 300 or IsLocationVisible(preferedCamp.cattr.location) == false ) and farmState == 0 then
			bot:Action_MoveToLocation(preferedCamp.cattr.location);
			return
		else
			local neutralCreeps = bot:GetNearbyNeutralCreeps(800);
			local farmTarget = campUtils.FindFarmedTarget(neutralCreeps)
			if farmTarget ~= nil   then
				farmState = 1;
				if sec >= stackTime then
					bot:Action_ClearActions( true );
					bot:Action_MoveToLocation(stackMove);
					return
				
				-- elseif bot:WasRecentlyDamagedByCreep(2.0) and role.IsSupport(unitName)
					-- then
						-- bot:Action_MoveToLocation(stackMove)
					-- return	
				else
					bot:SetTarget(farmTarget);
					bot:Action_AttackUnit(farmTarget, true);
					return
				end
			else
				bot:SetTarget(nil);
				farmState = 0;
				AvailableCamp, preferedCamp = campUtils.UpdateAvailableCamp(bot, preferedCamp, AvailableCamp);
			end
		end	
	end
	
	if nAttackRange < 175 then nAttackRange = 450 end 
	
	if preferedCamp ~= nil 
	-- and test2 
	and not role.IsCarry(unitName)
	-- and DotaTime() < 25*60
	then
		local cDist = GetUnitToLocationDistance(bot, preferedCamp.cattr.location);
		local stackMove = campUtils.GetCampMoveToStack(preferedCamp.idx);
		local stackTime =  campUtils.GetCampStackTime(preferedCamp);
		-- cLoc2 = GetSaveLocToFarmRetreat ()
		if ( cDist > 300 or IsLocationVisible(preferedCamp.cattr.location) == false ) and farmState == 0 
			-- and sec <= stackTime and sec >= 40
		then
			-- bot:Action_ClearActions( false );
			bot:Action_MoveToLocation(preferedCamp.cattr.location);
			return
		else
			local neutralCreeps = bot:GetNearbyNeutralCreeps(800);
			local farmTarget = campUtils.FindFarmedTarget(neutralCreeps)
			if farmTarget ~= nil then
				farmState = 1;
				if sec >= stackTime then
					bot:Action_ClearActions( true );
					bot:Action_MoveToLocation(stackMove);
					return
				
				elseif bot:WasRecentlyDamagedByCreep(2.0)
					and not role.IsCarry(unitName)
					-- and cDist < 500
					
					then
						-- bot:Action_ClearActions( false );
						bot:Action_MoveToLocation(stackMove);
						-- bot:Action_MoveToLocation(cLoc2+RandomVector(200))
					return	
				elseif farmTarget ~= nil and not bot:WasRecentlyDamagedByCreep(3.5) 
				and not role.IsCarry(unitName) and cDist > 600
						and (GetUnitToLocationDistance (bot,stackMove) < 250  and GetUnitToUnitDistance (bot,farmTarget)  < nAttackRange   )
						
					then
						-- bot:Action_ClearActions( false );
						bot:SetTarget(farmTarget);
						bot:Action_AttackUnit(farmTarget, true);
					return	
				else
					bot:SetTarget(farmTarget);
					bot:Action_AttackUnit(farmTarget, true);
					return
				end
			else
				bot:SetTarget(nil);
				farmState = 0;
				AvailableCamp, preferedCamp = campUtils.UpdateAvailableCamp(bot, preferedCamp, AvailableCamp);
				-- bot:Action_ClearActions( false );
				-- bot:Action_MoveToLocation(cLoc2+RandomVector(200))
				return
			end
		end	
	end
	-- 
	
	if bot.farmLaneLocation ~= nil
	-- and not preferedCamp ~= nil and not preferedCamp2 ~= nil and not cLoc ~= nil 
	 -- and DotaTime() > 25*60
	then
	-- local enemyCreeps = bot:GetNearbyLaneCreeps(1600, true);
			local enemyCreeps = bot:GetNearbyCreeps(1600, true);
			local allyCreeps = bot:GetNearbyLaneCreeps(1600, false);
			local enemyTowers = bot:GetNearbyTowers(1600, true);
			local enemyHeroes = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
			local target = GetTargetCreepToAttack2(bot, enemyCreeps, allyCreeps, enemyTowers,enemyHeroes);
	-- if bot.farmLaneLocation ~= nil then
		if ( attackRange < 175 and dfarmLaneLocation > 2*attackRange + 200 ) or ( attackRange > 350 and dfarmLaneLocation > attackRange+200 ) then
			-- printState('move to farm location');
			bot:Action_MoveToLocation(bot.farmLaneLocation);
			-- return;
			elseif bot:WasRecentlyDamagedByTower(1.5) or bot:WasRecentlyDamagedByCreep(1.0)  or bot: WasRecentlyDamagedByAnyHero(0.7) 
			or (#allyCreeps == 0  and #enemyTowers >= 1 and enemyTowers ~= nil )
			then
			-- printState('movin away');
				bot:Action_MoveToLocation(RetreatLoc);
				-- return	
			-- return
			while target~=nil do 
			bot:SetTarget(target);
			bot:Action_AttackUnit(target, true);
			
			-- bot:Action_MoveToLocation(target:GetLocation());
			-- return
			end
			elseif bot:WasRecentlyDamagedByTower(1.5) or bot:WasRecentlyDamagedByCreep(1.0)  or bot: WasRecentlyDamagedByAnyHero(0.7) 
			or (#allyCreeps == 0  and #enemyTowers >= 1 and enemyTowers ~= nil )
			then
			-- printState('movin away');
				bot:Action_MoveToLocation(RetreatLoc);
				-- return	
			return
			
		else
			
			if #enemyCreeps == 0 and #enemyTowers >= 0 then
				local target = GetTargetCreepToAttack2(bot, enemyCreeps, allyCreeps, enemyTowers,enemyHeroes);
				if  target~=nil then
					-- printState('deny creep');
					bot:SetTarget(target);
					bot:Action_AttackUnit(target, true);
					return
					
				
				else	
					-- printState('follow our lane creeps');
					bot:Action_MoveToLocation(bot.farmLaneLocation);
					return;
				end
			else
				local target = GetTargetCreepToAttack2(bot, enemyCreeps, allyCreeps, enemyTowers,enemyHeroes);
				if  target~=nil then
					-- printState('last hit/deny creep');
					bot:SetTarget(target);
					bot:Action_AttackUnit(target, true);
					return
				elseif IsTargetedByHeroOrCreepOrTower2(bot,enemyHeroes, enemyCreeps, enemyTowers) then
					if #allyCreeps >= 0 then
						-- printState('attacked by creep or tower move away');
						local loc = GetLaneFrontLocation(myTeam, lfarmLaneLocation, -700)
						bot:Action_MoveToLocation(loc);
						return	
					-- else
						-- print('attacked by tower or creep: attack ally')
						-- bot:Action_AttackUnit(allyCreeps[1], true);
						-- return;
					end	
				else	
					-- printState('waiting for last hit');
					bot:SetTarget(nil);
					bot:Action_MoveToLocation(bot.farmLaneLocation);
					return;
				end	
			end
		end
	end
	-- end
	
	
	
	
	
	
	
	
	-----------------------------------------
	 
	
	if runMode then
		if  not bot:IsInvisible() or (bot:IsInvisible() and bot:GetHealth()/bot:GetMaxHealth() > 0.25 )  
		-- and not mutil.IsRetreating(bot)
		-- and bot:GetLevel() > 14
		then
			local botAttackRange = bot:GetAttackRange();
			if botAttackRange > 1400 then botAttackRange = 1400 end;
			local runModeAllies = bot:GetNearbyHeroes(900,false,BOT_MODE_NONE);
			local runModeEnemyHeroes = bot:GetNearbyHeroes(botAttackRange +50,true,BOT_MODE_NONE);
			local runModeTowers  = bot:GetNearbyTowers(240,true);
			local runModeBarracks  = bot:GetNearbyBarracks(botAttackRange +150,true);
			-- local target = mutil.GetVulnerableWeakestUnit2(true, true, botAttackRange+50, bot);
			-- if mutil.IsValid(target)
				-- and #runModeAllies >= 2
				-- and not target:IsAttackImmune()
				-- and botName ~= "npc_dota_hero_bristleback"
				-- and GetDistanceFromEnemyFountain(bot) > 2200
			-- then
			if mutil.IsValid(runModeEnemyHeroes[1])
				and #runModeAllies >= 2
				and not runModeEnemyHeroes[1]:IsAttackImmune()
				-- and botName ~= "npc_dota_hero_bristleback"
				and GetDistanceFromEnemyFountain(bot) > 2200
			then
				-- local cpos = utils.GetVector(target);
				-- local cpos = mutil.GetCenterOfUnits(runModeEnemyHeroes);
				
				-- bot:ActionImmediate_Ping( cpos.x, cpos.y, true)
				bot:SetTarget(runModeEnemyHeroes[1]);
				bot:Action_AttackUnit(runModeEnemyHeroes[1], true);
				return;
			end
				-- if mutil.IsValid(runModeEnemyHeroes[1])
				-- and #runModeAllies >= 2
				-- and not runModeEnemyHeroes[1]:IsAttackImmune()
				-- -- and botName ~= "npc_dota_hero_bristleback"
				-- and GetDistanceFromEnemyFountain(bot) > 2200 and DotaTime() > lastPing + 3.0 
					-- then
					-- bot:ActionImmediate_Ping( etargetX.x,  etargetX.y, true)
					-- lastPing = DotaTime()
				-- end
			
			if mutil.IsValidBuilding(runModeBarracks[1])
				and not bot:WasRecentlyDamagedByAnyHero(1.0)
				and not runModeBarracks[1]:IsAttackImmune()
				and not runModeBarracks[1]:IsInvulnerable()
				and not runModeBarracks[1]:HasModifier("modifier_fountain_glyph")
				and not runModeBarracks[1]:HasModifier("modifier_invulnerable")
				and not runModeBarracks[1]:HasModifier("modifier_backdoor_protection_active")
			then
				bot:Action_AttackUnit(runModeBarracks[1], true);
				return;
			end			
		end
	
		if IsInAllyArea(bot)
		then	
			if bot:GetTeam() == TEAM_RADIANT
			then
				bot:Action_MoveToLocation(RB);
				return;
			else
				bot:Action_MoveToLocation(DB);
				return;
			end
		else
			if bot:GetTeam() == TEAM_RADIANT
			then
			    local mLoc = GetLocationTowardDistanceLocation(bot,DB,-700);
				bot:Action_MoveToLocation(mLoc);
				return;
			else
			    local mLoc = GetLocationTowardDistanceLocation(bot,RB,-700);
				bot:Action_MoveToLocation(mLoc);
				return;
			end		
		end
	end
	
	
	
	
	
	if hLaneCreepList ~= nil and #hLaneCreepList > 0  
	-- and DotaTime() < 25*60
		then
		local farmTarget = Site.GetFarmLaneTarget(hLaneCreepList);
		local nSearchRange = bot:GetAttackRange() + 180
		if nSearchRange > 1600 then nSearchRange = 1600 end
		local nNeutrals = bot:GetNearbyNeutralCreeps(nSearchRange);
		if farmTarget ~= nil and #nNeutrals == 0 then
						
			if farmTarget:GetTeam() == bot:GetTeam() 
			   and IsInAllyArea(farmTarget)
			then
				bot:Action_MoveToLocation(farmTarget:GetLocation() + RandomVector(300));
				return
			end
			
			if farmTarget:GetTeam() ~= bot:GetTeam()
			then
				--如果小兵正在被友方小兵攻击且生命值略高于自己的击杀线则S自己的出手
				local allyTower = bot:GetNearbyTowers(1000,true)[1];
				if bot:GetAttackTarget() == farmTarget
				   and ( GetAttackEnemysAllyCreepCount(farmTarget, 800) > 0
						   or ( allyTower ~= nil and allyTower:GetAttackTarget() == farmTarget ) )
				then
					local botDamage = bot:GetAttackDamage();
					local nDamageReduce = bot:GetAttackCombatProficiency(farmTarget)
					if bot:FindItemSlot("item_quelling_blade") > 0
						or bot:FindItemSlot("item_bfury") > 0
					then
						botDamage = botDamage + 18;
					end
					
					if not mutil.CanKillTarget(farmTarget, botDamage * nDamageReduce, DAMAGE_TYPE_PHYSICAL)
					   and mutil.CanKillTarget(farmTarget, (botDamage +99) * nDamageReduce, DAMAGE_TYPE_PHYSICAL)
					then
						bot:Action_ClearActions( true );
					    return
					end
				end
			
				if bot:GetAttackRange() > 310 
				then
					if GetUnitToUnitDistance(bot,farmTarget) > bot:GetAttackRange() + 180
					then
						bot:Action_MoveToLocation(farmTarget:GetLocation());
						return
					else
						bot:SetTarget(farmTarget)
						bot:Action_AttackUnit(farmTarget, true);
						return
					end
				else
					if ( GetUnitToUnitDistance(bot,farmTarget) > bot:GetAttackRange() + 100 )
						or bot:GetAttackDamage() > 200
					then
						bot:SetTarget(hLaneCreepList[1])
						bot:Action_AttackUnit(hLaneCreepList[1], true);
						return
					else
						bot:SetTarget(farmTarget)
						bot:Action_AttackUnit(farmTarget, true);
						return
					end
				end
			end
		end
	end
	
	
	
	if preferedCamp2 == nil then preferedCamp2 = Site.GetClosestNeutralSpwan(bot, availableCamp);end
	
	if preferedCamp2 ~= nil 
	-- and DotaTime() < 30*60
	then
		local targetFarmLoc = preferedCamp2.cattr.location;
		local cDist = GetUnitToLocationDistance(bot, targetFarmLoc);
		local nNeutrals = bot:GetNearbyNeutralCreeps(888);
		if #nNeutrals >= 3 and cDist <= 600 and cDist > 240
		   and ( bot:GetLevel() >= 10 or not nNeutrals[1]:IsAncientCreep())
		then farmState = 1 end;
		
		if farmState == 0 
		   and ( mutil.IsValid(nNeutrals[1]) or #nNeutrals > 1)
		   and not mutil.IsRoshan2(nNeutrals[1])
		   and ( bot:GetLevel() >= 10 or not nNeutrals[1]:IsAncientCreep())
		then
		
			if GetUnitToUnitDistance(bot,nNeutrals[1]) < bot:GetAttackRange() + 150
				and HasNotActionLast(4.0,'creep')
			then
				Role['availableCampTable'] = Site.UpdateCommonCamp(nNeutrals[1],Role['availableCampTable']);
			end
			
			local farmTarget = Site.FindFarmNeutralTarget(nNeutrals)
			if farmTarget ~= nil 
			then
				bot:SetTarget(farmTarget);
				bot:Action_AttackUnit(farmTarget, true);
				return;
			else
				bot:SetTarget(nNeutrals[1]);
				bot:Action_AttackUnit(nNeutrals[1], true);
				return;
			end
			
		elseif  farmState == 0 
				and #nNeutrals == 0
		        and cDist > 240
		        and ( not IsLocCanBeSeen(targetFarmLoc) or cDist > 600 )
			then
				
				bot:SetTarget(nil);
				
				if bot:GetLevel() >= 12
					 and Role.ShouldTpToFarm() 
				then
					local mostFarmDesireLane,mostFarmDesire = GetMostFarmLaneDesire();
					local tps = bot:GetItemInSlot(nTpSolt);
					local tpLoc = GetLaneFrontLocation(GetTeam(),mostFarmDesireLane,0);
					local bestTpLoc = GetNearbyLocationToTp(tpLoc);
					local nAllies = GetAlliesNearLoc(tpLoc, 1400);
					if mostFarmDesire > BOT_MODE_DESIRE_VERYHIGH 
						and IsLocHaveTower(1850,false,tpLoc)
						and bestTpLoc ~= nil					
						and #nAllies == 0
					then
						if tps ~= nil and tps:IsFullyCastable() 
						   and GetUnitToLocationDistance(bot,bestTpLoc) > 4200
						then
							preferedCamp2 = nil;
							Role['lastFarmTpTime'] = DotaTime();
							bot:Action_UseAbilityOnLocation(tps, bestTpLoc);
							return;
						end
					end	
					
					local tBoots = IsItemAvailable("item_travel_boots_2");
					if tBoots == nil then tBoots = IsItemAvailable("item_travel_boots"); end;
					if tBoots ~= nil and tBoots:IsFullyCastable()
					then
						local tpLoc = GetLaneFrontLocation(GetTeam(),mostFarmDesireLane,-600);
						local nAllies = GetAlliesNearLoc(tpLoc, 1600);
						if mostFarmDesire > BOT_MODE_DESIRE_HIGH * 1.12		
						   and #nAllies == 0
						   and GetUnitToLocationDistance(bot,tpLoc) > 3500
						then
							preferedCamp2 = nil;
							Role['lastFarmTpTime'] = DotaTime();
							bot:Action_UseAbilityOnLocation(tBoots, tpLoc);
							return;							
						end
					end					
				end
				
				if hLaneCreepList[1] ~= nil 
				   and not hLaneCreepList[1]:IsNull() 
				   and hLaneCreepList[1]:IsAlive() 
				then
					bot:Action_MoveToLocation( hLaneCreepList[1]:GetLocation() );
					return;
				end
				
				if CouldBlink(bot,targetFarmLoc) then return end;
				
				if CouldBlade(bot,targetFarmLoc) then return end;
							
				bot:Action_MoveToLocation(targetFarmLoc);
				return;
		else
			local neutralCreeps = bot:GetNearbyNeutralCreeps(1000); 
			
			if #neutralCreeps >= 2 then
				
				farmState = 1;
				
				local farmTarget = Site.FindFarmNeutralTarget(neutralCreeps)
				if farmTarget ~= nil 
				then
					bot:SetTarget(farmTarget);
					bot:Action_AttackUnit(farmTarget, true);
					return;
				end
				
			elseif ( IsLocCanBeSeen(targetFarmLoc) and cDist <= 600 ) or cDist <= 240
				then
					
					farmState = 0;
					Role['availableCampTable'], preferedCamp2 = Site.UpdateAvailableCamp(bot, preferedCamp2, Role['availableCampTable']);
					availableCamp = Role['availableCampTable'];	
					preferedCamp2  = Site.GetClosestNeutralSpwan(bot, availableCamp);


					local farmTarget = Site.FindFarmNeutralTarget(neutralCreeps)
					if farmTarget ~= nil 
					then
						bot:SetTarget(farmTarget);
						bot:Action_AttackUnit(farmTarget, true);
						return;
					end
			else
			
				local farmTarget = Site.FindFarmNeutralTarget(neutralCreeps)
				if farmTarget ~= nil 
				then
					bot:SetTarget(farmTarget);
					bot:Action_AttackUnit(farmTarget, true);
					return;
				end
				
				bot:SetTarget(nil);
				
				if cDist > 200 then bot:Action_MoveToLocation(targetFarmLoc) return end
			end
		end			
	end
	
	
	
	bot:SetTarget(nil);
	bot:Action_MoveToLocation( ( RB + DB )/2 );
	return;
	
	
	
	
end

function IsHumanPlayerInTeam()
	for _,id in pairs(GetTeamPlayers(GetTeam())) 
	do 
		if not IsPlayerBot(id) 
		then 
			return true;
		end
	end 
	return false;
end

function IsThereT3Detroyed()
	
	local T3s = {
		TOWER_TOP_3,
		TOWER_MID_3,
		TOWER_BOT_3
	}
	
	for _,t in pairs(T3s) do
		local tower = GetTower(GetOpposingTeam(), t);
		if tower == nil or not tower:IsAlive() then
			return true;
		end
	end	
	return false;
end

function GetTargetShrine()
	local shrines = {
		 SHRINE_JUNGLE_1,
		 SHRINE_JUNGLE_2 
	}
	for _,s in pairs(shrines) do
		local shrine = GetShrine(GetOpposingTeam(), s);
		if  shrine ~= nil and shrine:IsAlive() then
			return shrine;
		end	
	end	
	return nil;
end

function IsSuitableToDestroyShrine()
	local mode = bot:GetActiveMode();
	if bot:WasRecentlyDamagedByTower(2.0) or bot:WasRecentlyDamagedByAnyHero(3.0)
	   or mode == BOT_MODE_DEFEND_TOWER_TOP
	   or mode == BOT_MODE_DEFEND_TOWER_MID
	   or mode == BOT_MODE_DEFEND_TOWER_BOT
	   or mode == BOT_MODE_ATTACK
	   or mode == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH
	then
		return false;
	end
	return true;
end


function GetSaveLocToFarmLane()
	local minDist = 100000;
	local clashLoc = nil;
	for _,lane in pairs(lanes)
	do
		local tFLoc = GetLaneFrontLocation(GetTeam(), lane, 0);
		local eFLoc = GetLaneFrontLocation(GetOpposingTeam(), lane, 0);
		local fDist = utils.GetDistance(tFLoc, eFLoc);
		local uDist = GetUnitToLocationDistance(bot, tFLoc);
		if fDist <= 1000 and uDist < minDist and (not IsUnitAroundLocation(eFLoc, 2000) or IsUnitAroundLocation(eFLoc, 2000) ) 
			and GetNEnemyAroundLocation(eFLoc, 1600, 2.0) <= 3  
			and GetNAllyAroundLocation(tFLoc, 1600, 10.0)  >= 1
			and not IsAllyAroundLocation(tFLoc, 1600)
		then
			minDist = uDist;
			clashLoc = tFLoc;
		end
	end
	return clashLoc;
end

function IsUnitAroundLocation(vLoc, nRadius)
	for i,id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id);
			if info ~= nil then
				local dInfo = info[1];
				if dInfo ~= nil and utils.GetDistance(vLoc, dInfo.location) <= nRadius and dInfo.time_since_seen < 1.0 then
					return true;
				end
			end
		end
	end
	return false;
end

function IsAllyAroundLocation(vLoc, nRadius)
	for i = 1, 5
	do
		local npcAlly = GetTeamMember( i )
		if npcAlly ~= nil
			and npcAlly:IsAlive()
			and GetUnitToLocationDistance( npcAlly, vLoc ) <= nRadius
		then
			return true
		end
	end

	return false
end

function GetWeakestUnit(units)
	local lowestHP = 10000;
	local lowestUnit = nil;
	for _,unit in pairs(units)
	do
		local hp = unit:GetHealth();
		if hp < lowestHP then
			lowestHP = hp;
			lowestUnit = unit;	
		end
	end
	return lowestUnit;
end

-----------------------------















function IsNearLaneFront( bot )
	local testDist = 1600;
	for _,lane in pairs(nLaneList)
	do
		local tFLoc = GetLaneFrontLocation(GetTeam(), lane, 0);
		if GetUnitToLocationDistance(bot,tFLoc) <= testDist
		then
		    return true;
		end		
	end
	return false;
end


-- function X.IsUnitAroundLocation(vLoc, nRadius)
	-- for i,id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		-- if IsHeroAlive(id) then
			-- local info = GetHeroLastSeenInfo(id);
			-- if info ~= nil then
				-- local dInfo = info[1];
				-- if dInfo ~= nil and J.Site.GetDistance(vLoc, dInfo.location) <= nRadius and dInfo.time_since_seen < 1.0 then
					-- return true;
				-- end
			-- end
		-- end
	-- end
	-- return false;
-- end


local enemyPids = nil;
function ShouldRun(bot)
		
	if bot:IsChanneling() 
	   or not bot:IsAlive()
	then
		return 0;
	end	   
	
	local botLevel    = bot:GetLevel();
	local botMode     = bot:GetActiveMode();
	local botTarget   = GetProperTarget(bot);
	local hEnemyHeroList = GetEnemyList(bot,1600);
	local hAllyHeroList  = GetAllyList(bot,1600);
	local enemyFountainDistance = GetDistanceFromEnemyFountain(bot);
	local enemyAncient = GetAncient(GetOpposingTeam());
	local enemyAncientDistance = GetUnitToUnitDistance(bot,enemyAncient);
	local aliveEnemyCount = GetNumOfAliveHeroes(true)
	local rushEnemyTowerDistance = 250;
	
	--禁止冲泉
	if enemyFountainDistance < 1560
	then
		return 2;
	end
	
	--防止离开自家泉水
	if bot:DistanceFromFountain() < 200
		and botMode ~= BOT_MODE_RETREAT
		and ( GetHP(bot) + GetMP(bot) < 1.7 )
	then
		return 3;
	end
	
	--防止低等级过于深入追击
	if botLevel <= 4
		and enemyFountainDistance < 7666
	then
		return 3.33;
	end
	
	--防止低等级追到南天门
	if botLevel < 6
		and DotaTime() > 30
		and DotaTime() < 8 * 60
		and enemyFountainDistance < 8111
	then
		if botTarget ~= nil and botTarget:IsHero()
		   and GetHP(botTarget) > 0.35
		   and (  not mutil.IsInRange(bot,botTarget,bot:GetAttackRange() + 150) 
				  or not mutil.CanKillTarget(botTarget, bot:GetAttackDamage() * 2.33, DAMAGE_TYPE_PHYSICAL) )
		then
			return 2.88;
		end
	end
	
	--防止低等级打远古野
	if bot:GetLevel() < 10
	   and bot:GetAttackDamage() < 133
	   and botTarget ~= nil
	   and botTarget:IsAncientCreep()
	   and #hAllyHeroList <= 1 
	   and bot:DistanceFromFountain() > 3000
	then
		bot:SetTarget(nil);
		return 6.21;
	end
	
	--没破高地塔
	if not IsThereT3Detroyed() 
	   and aliveEnemyCount >= 3 
	   and #hAllyHeroList < aliveEnemyCount + 2
	   and not Role.IsPvNMode()
	   and ( DotaTime() % 600 > 285 or DotaTime() < 18 * 60 )--处于夜间或小于18分钟
	then
		--不冲高地
		local allyLevel = GetAverageLevel(false);
		local enemyLevel = GetAverageLevel(true);
		if enemyFountainDistance < 4765
		then
			local nAllyLaneCreeps = bot:GetNearbyLaneCreeps(550,false);
			if( allyLevel - 4 < enemyLevel and allyLevel < 24 )
			   and not ( allyLevel - 2 > enemyLevel and aliveEnemyCount == 3)
			   and #nAllyLaneCreeps <= 4
			then
				return 1.33;
			end
		end
				
	end
	
	local nEnemyTowers = bot:GetNearbyTowers(898, true);
	local nEnemyBrracks = bot:GetNearbyBarracks(800,true);
	
	--破兵营前不冲基地
	if #nEnemyBrracks >= 1 and aliveEnemyCount >= 2
	then
		if #nEnemyTowers >= 2
		   or enemyAncientDistance <= 1314
		   or enemyFountainDistance <= 2828
		then
			return 2;
		end
	end
	
	--20级前不冲塔杀人
	if nEnemyTowers[1] ~= nil and botLevel < 20
	then
		if nEnemyTowers[1]:HasModifier("modifier_invulnerable") and aliveEnemyCount > 1
		then
			return 2.5;
		end
		
		if  enemyAncientDistance > 2100
			and enemyAncientDistance < GetUnitToUnitDistance(nEnemyTowers[1],enemyAncient) - rushEnemyTowerDistance
		then
			local nTarget = GetProperTarget(bot);
			if nTarget == nil
			then
				return 3.9;
			end
			
			if nTarget ~= nil and nTarget:IsHero() and aliveEnemyCount > 2
			then
				
				local assistAlly = false;
				
				for _,ally in pairs(hAllyHeroList)
				do
					if GetUnitToUnitDistance(ally,nTarget) <= ally:GetAttackRange() + 100
						and (ally:GetAttackTarget() == nTarget or ally:GetTarget() == nTarget)
					then
						assistAlly = true;
						break;
					end
				end
				
				if not assistAlly 
				then
					return 2.5;
				end
				
			end
		end
	end
	
	--低等级避免近塔
	if  botLevel <= 10
		and (#hEnemyHeroList > 0 or bot:GetHealth() < 700)
	then
		local nLongEnemyTowers = bot:GetNearbyTowers(999, true);
		if bot:GetAssignedLane() == LANE_MID 
		then 
			 nLongEnemyTowers = bot:GetNearbyTowers(988, true); 
			 nEnemyTowers     = bot:GetNearbyTowers(966, true); 
		end
		if ( botLevel <= 2 or DotaTime() < 2 * 60 )
			and nLongEnemyTowers[1] ~= nil
		then
			return 1;
		end	
		if ( botLevel <= 4 or DotaTime() < 3 * 60 )
			and nEnemyTowers[1] ~= nil
		then
			return 1;
		end	
		if botLevel <= 9
			and nEnemyTowers[1] ~= nil
			and nEnemyTowers[1]:GetAttackTarget() == bot
			and #hAllyHeroList <= 1
		then
			return 1;
		end
	end
	
	--隐身了别浪
	if  bot:IsInvisible() and DotaTime() > 8 * 60
		and botMode == BOT_MODE_RETREAT
		and bot:GetActiveModeDesire() > 0.4
		and #hAllyHeroList <= 1
		and mutil.IsValid(hEnemyHeroList[1])
		and bot:GetUnitName() ~= "npc_dota_hero_riki"
		and bot:GetUnitName() ~= "npc_dota_hero_bounty_hunter"
		and bot:GetUnitName() ~= "npc_dota_hero_slark"
		and GetDistanceFromAncient(bot,false) < GetDistanceFromAncient(hEnemyHeroList[1], false)
	then
		return 5;
	end	

	--一个人的时候小心点
	if #hAllyHeroList <= 1 
	   and botMode ~= BOT_MODE_TEAM_ROAM
	   and botMode ~= BOT_MODE_LANING
	   and botMode ~= BOT_MODE_RETREAT
	   and ( botLevel <= 1 or botLevel > 5 ) 
	   and bot:DistanceFromFountain() > 1400
	then
		if enemyPids == nil then
			enemyPids = GetTeamPlayers(GetOpposingTeam())
		end	
		local enemyCount = 0
		for i = 1, #enemyPids do
			local info = GetHeroLastSeenInfo(enemyPids[i])
			if info ~= nil then
				local dInfo = info[1]; 
				if dInfo ~= nil and dInfo.time_since_seen < 2.0  
					and GetUnitToLocationDistance(bot,dInfo.location) < 1000 
				then
					enemyCount = enemyCount +1;
				end
			end	
		end
		if (enemyCount >= 4 or #hEnemyHeroList >= 4) 
			and botMode ~= BOT_MODE_ATTACK
			and botMode ~= BOT_MODE_TEAM_ROAM
			and bot:GetCurrentMovementSpeed() > 300
		then
			local nNearByHeroes = bot:GetNearbyHeroes(700,true,BOT_MODE_NONE);
			if #nNearByHeroes < 2
	        then
				return 4;
			end
		end	
		if  botLevel >= 9 and botLevel <= 17  
			and (enemyCount >= 3 or #hEnemyHeroList >= 3) 
			and botMode ~= BOT_MODE_LANING
			and bot:GetCurrentMovementSpeed() > 300
		then
			local nNearByHeroes = bot:GetNearbyHeroes(700,true,BOT_MODE_NONE);
			if #nNearByHeroes < 2
	        then
				return 3;
			end
		end	
		
		local nEnemy = bot:GetNearbyHeroes(800,true,BOT_MODE_NONE);
		for _,enemy in pairs(nEnemy)
		do
			if mutil.IsValid(enemy)
				and enemy:GetUnitName() == "npc_dota_hero_necrolyte"
				and enemy:GetMana() >= 200
				and GetHP(bot) < 0.45
				and enemy:IsFacingLocation(bot:GetLocation(),20)
			then
				return 3;
			end
		end
		
	end	
	

	return 0;
end


function CouldHitAndRun(bot)

	local nCreeps = bot:GetNearbyCreeps(800,true);
	local nNearByCreeps = bot:GetNearbyCreeps(300,true);
	
	if botName == "npc_dota_hero_templar_assassin" 
	   and #nCreeps >= 2 and #nNearByCreeps >= 2
	then
		local nAttackPoint = bot:GetAttackPoint();
		local nAttackSpeed = bot:GetSecondsPerAttack();
		local nAttackPost  = nAttackSpeed - nAttackPoint;
		
		local lastAttackTime = GameTime() - bot:GetLastAttackTime();
		if lastAttackTime > 0.01 and lastAttackTime < nAttackPost - 0.1
		then
			local nMoveLoc = GetUnitTowardDistanceLocation(nNearByCreeps[1],bot,400);
			if IsLocationPassable(nMoveLoc)
			then
				bot:Action_MoveToLocation(nMoveLoc);
				return true;
			end
		end
	end
	
	return false;
end


function CouldBlade(bot,nLocation) 
	local blade = IsItemAvailable("item_quelling_blade");
	if blade == nil then blade = IsItemAvailable("item_bfury"); end
	
	if blade ~= nil 
	   and blade:IsFullyCastable() 
	then
		local trees = bot:GetNearbyTrees(380);
		local dist = GetUnitToLocationDistance(bot,nLocation);
		local vStart = Site.GetXUnitsTowardsLocation(bot, nLocation, 32 );
		local vEnd  = Site.GetXUnitsTowardsLocation(bot, nLocation, dist - 32 );
		for _,t in pairs(trees)
		do
			if t ~= nil
			then
				local treeLoc = GetTreeLocation(t);
				local tResult = PointToLineDistance(vStart, vEnd, treeLoc);
				if tResult ~= nil 
				   and tResult.within 
				   and tResult.distance <= 96
				   and GetLocationToLocationDistance(treeLoc,nLocation) < dist
				then
					bot:Action_UseAbilityOnTree(blade, t);
					return true;
				end
			end			
		end
	end
	
	return false;
end


function CouldBlink(bot,nLocation)
	
	
	local maxBlinkDist = 1199;
	local blink = IsItemAvailable("item_blink");
	
	if botName == "npc_dota_hero_antimage"
	then
		blink = bot:GetAbilityByName( "antimage_blink" );
		maxBlinkDist = blink:GetSpecialValueInt("blink_range");
	end
	
	if botName == "npc_dota_hero_queenofpain"
	then
		blink = bot:GetAbilityByName( "queenofpain_blink" );
		maxBlinkDist = blink:GetSpecialValueInt("blink_range");
	end
	
	if blink ~= nil 
	   and blink:IsFullyCastable() 
       and IsRunning(bot)
	then
		local bDist = GetUnitToLocationDistance(bot,nLocation);
		local maxBlinkLoc = Site.GetXUnitsTowardsLocation(bot, nLocation, maxBlinkDist );
		if bDist <= 600  -- recommend by oyster 2019/4/16
		then
			return false;
		elseif bDist < maxBlinkDist +1
			then
				if botName == "npc_dota_hero_antimage"
				then
					bot:Action_ClearActions(true);
		
					if not IsPTReady(bot,ATTRIBUTE_INTELLECT) 
					then
						SetQueueSwitchPtToINT(bot);
					end
							
					bot:ActionQueue_UseAbilityOnLocation(blink, nLocation);
									
					return true;
				end
			
				bot:Action_UseAbilityOnLocation(blink, nLocation);
				return true;
		elseif IsLocationPassable(maxBlinkLoc)
			then
				
				if botName == "npc_dota_hero_antimage"
				then
					bot:Action_ClearActions(true);
		
					if not IsPTReady(bot,ATTRIBUTE_INTELLECT) 
					then
						SetQueueSwitchPtToINT(bot);
					end
							
					bot:ActionQueue_UseAbilityOnLocation(blink, maxBlinkLoc);
									
					return true;
				end
				
				bot:Action_UseAbilityOnLocation(blink, maxBlinkLoc);
				return true;
		end
	end

	return false;
end


function IsLocCanBeSeen(vLoc)

	if GetUnitToLocationDistance(GetBot(),vLoc) < 180 then return true end
	
	local tempLocUp    = vLoc + Vector(5  ,0  );
	local tempLocDown  = vLoc + Vector(0  ,10 );
	local tempLocLeft  = vLoc + Vector(-15,0  );
	local tempLocRight = vLoc + Vector(0  ,-20);
	
	return IsLocationVisible(tempLocRight) 
		   and IsLocationVisible(tempLocLeft) 
	       and IsLocationVisible(tempLocUp) 
		   and IsLocationVisible(tempLocDown)

end


function IsNormalFarmer(bot)

	local botName = bot:GetUnitName();
	
	 return botName == "npc_dota_hero_chaos_knight" 
		 or botName == "npc_dota_hero_dragon_knight"
		 or botName == "npc_dota_hero_ogre_magi"
		 or botName == "npc_dota_hero_omniknight"
		 or botName == "npc_dota_hero_bristleback" 
		 or botName == "npc_dota_hero_sand_king" 
		 or botName == "npc_dota_hero_skeleton_king"
		 or botName == "npc_dota_hero_kunkka"
		 or botName == "npc_dota_hero_sniper"
		 or botName == "npc_dota_hero_viper" 
		 or botName == "npc_dota_hero_clinkz" 
		 or botName == "npc_dota_hero_mirana" 
		 or botName == "npc_dota_hero_disruptor"
		 or botName == "npc_dota_hero_shadow_demon"
		 or botName == "npc_dota_hero_vengefulspirit"
		 or botName == "npc_dota_hero_omniknight"
		 or botName == "npc_dota_hero_abaddon"

end


function IsHighFarmer(bot)

	local botName = bot:GetUnitName();
	
	return botName == "npc_dota_hero_nevermore"
		or botName == "npc_dota_hero_templar_assassin"
		or botName == "npc_dota_hero_phantom_assassin"
		or botName == "npc_dota_hero_phantom_lancer"
		or botName == "npc_dota_hero_drow_ranger"
		or botName == "npc_dota_hero_luna"
		or botName == "npc_dota_hero_antimage"
		or botName == "npc_dota_hero_arc_warden"
		or botName == "npc_dota_hero_bloodseeker"
		or botName == "npc_dota_hero_medusa"
		or botName == "npc_dota_hero_razor"
		or botName == "npc_dota_hero_huskar"
		or botName == "npc_dota_hero_juggernaut"
		or botName == "npc_dota_hero_slark"
		or botName == "npc_dota_hero_naga_siren"
		or botName == "npc_dota_hero_legion_commander"
		
end


function IsVeryHighFarmer(bot)

	local botName = bot:GetUnitName();
	
	return botName == "npc_dota_hero_nevermore"
		or botName == "npc_dota_hero_luna"
		or botName == "npc_dota_hero_antimage"
		or botName == "npc_dota_hero_medusa"
		or botName == "npc_dota_hero_naga_siren"
		or botName == "npc_dota_hero_phantom_lancer"
		or botName == "npc_dota_hero_razor"
		
end

function SetPushBonus( bot )


	if not GetTeamMember(1):IsBot()	then return end

	local initBotFile = nil
	if pcall( require, 'game/botsinit' )
	then
		initBotFile = require( 'game/botsinit' )
	end
	
	
	local bonusType = nil
	if pcall( require,  'game/bot_bonus' )
	then
		bonusType = require( 'game/bot_bonus' )
	end
	
	
	if bonusType == nil or bonusType == '7.29TY'
	then
		return
	end
	
	if initBotFile['bonusType'] ~= bonusType
	then
		bot:ActionImmediate_Chat( "由于客户端上次的更新, 经验翻倍补丁已经失效, 请重新安装补丁.", true)
		return
	end
	
	local bonusNoticeTable = {
		["7.29Y3"] = "大神, 当前挑战的是三倍金钱经验夜魇AI.",
		["7.29Y2"] = "勇士, 当前挑战的是双倍金钱经验夜魇AI.",
		["7.29T2"] = "勇士, 当前挑战的是双倍金钱经验天辉AI.",
		["7.29Y1.5"] = "少年, 当前挑战的是1.5倍金钱经验夜魇AI.",		
	}
	
	if bonusNoticeTable[bonusType] ~= nil
	then
		bot:ActionImmediate_Chat( bonusNoticeTable[bonusType], true )
		return
	end


end






function GetProperTarget( bot )

	local target = bot:GetTarget()

	if target == nil
	then
		target = bot:GetAttackTarget()
	end

	if target ~= nil
		and target:GetTeam() == bot:GetTeam()
		and ( target:IsHero() or target:IsBuilding() )
	then
		target = nil
	end

	return target

end


function GetEnemyList( bot, nRadius )

	if nRadius > 1600 then nRadius = 1600 end
	local nRealEnemyList = {}
	local nCandidate = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE )
	if nCandidate[1] == nil then return nCandidate end

	for _, enemy in pairs( nCandidate )
	do
		if enemy ~= nil and enemy:IsAlive()
			and not IsSuspiciousIllusion( enemy )
		then
			table.insert( nRealEnemyList, enemy )
		end
	end

	return nRealEnemyList

end


function IsSuspiciousIllusion( npcTarget )

	if not npcTarget:IsHero()
		or npcTarget:IsCastingAbility()
		or npcTarget:IsUsingAbility()
		or npcTarget:IsChanneling()
		-- or npcTarget:HasModifier( "modifier_item_satanic_unholy" )
		-- or npcTarget:HasModifier( "modifier_item_mask_of_madness_berserk" )
		-- or npcTarget:HasModifier( "modifier_black_king_bar_immune" )
		-- or npcTarget:HasModifier( "modifier_rune_doubledamage" )
		-- or npcTarget:HasModifier( "modifier_rune_regen" )
		-- or npcTarget:HasModifier( "modifier_rune_haste" )
		-- or npcTarget:HasModifier( "modifier_rune_arcane" )
		-- or npcTarget:HasModifier( "modifier_item_phase_boots_active" )
	then
		return false
	end

	local bot = GetBot()

	if npcTarget:GetTeam() == bot:GetTeam()
	then
		return npcTarget:IsIllusion() or npcTarget:HasModifier( "modifier_arc_warden_tempest_double" )
	elseif npcTarget:GetTeam() == GetOpposingTeam()
	then

		if npcTarget:HasModifier( 'modifier_illusion' )
			or npcTarget:HasModifier( 'modifier_phantom_lancer_doppelwalk_illusion' )
			or npcTarget:HasModifier( 'modifier_phantom_lancer_juxtapose_illusion' )
			or npcTarget:HasModifier( 'modifier_darkseer_wallofreplica_illusion' )
			or npcTarget:HasModifier( 'modifier_terrorblade_conjureimage' )
		then
			return true
		end

		local tID = npcTarget:GetPlayerID()

		if not IsHeroAlive( tID )
		then
			return true
		end

		if GetHeroLevel( tID ) > npcTarget:GetLevel()
		then
			return true
		end
		--[[
		if GetSelectedHeroName( tID ) ~= "npc_dota_hero_morphling"
			and GetSelectedHeroName( tID ) ~= npcTarget:GetUnitName()
		then
			return true
		end
		--]]
	end

	return false

end



function GetHP( bot )

	return bot:GetHealth() / bot:GetMaxHealth()

end


function GetMP( bot )

	return bot:GetMana() / bot:GetMaxMana()

end


function GetAllyList( bot, nRadius )

	if nRadius > 1600 then nRadius = 1600 end

	local nRealAllyList = {}
	local nCandidate = bot:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE )
	if #nCandidate <= 1 then return nCandidate end

	for _, ally in pairs( nCandidate )
	do
		if ally ~= nil and ally:IsAlive()
			and not ally:IsIllusion()
		then
			table.insert( nRealAllyList, ally )
		end
	end

	return nRealAllyList

end


function GetDistanceFromEnemyFountain( bot )

	local EnemyFountain = mutil.GetEnemyFountain()
	local Distance = GetUnitToLocationDistance( bot, EnemyFountain )

	return Distance

end


function GetNumOfAliveHeroes( bEnemy )

	local count = 0
	local nTeam = GetTeam()
	if bEnemy then nTeam = GetOpposingTeam() end

	for i, id in pairs( GetTeamPlayers( nTeam ) )
	do
		if IsHeroAlive( id )
		then
			count = count + 1
		end
	end

	return count

end


function GetAverageLevel( bEnemy )

	local count = 0
	local sum = 0
	local nTeam = GetTeam()
	if bEnemy then nTeam = GetOpposingTeam() end

	for i, id in pairs( GetTeamPlayers( nTeam ) )
	do
		sum = sum + GetHeroLevel( id )
		count = count + 1
	end

	return sum / count

end


function GetDistanceFromAncient( bot, bEnemy )

	local targetAncient = GetAncient( GetTeam() )

	if bEnemy then targetAncient = GetAncient( GetOpposingTeam() ) end

	return GetUnitToUnitDistance( bot, targetAncient )

end


function GetSpecialModeAllies( bot, nDistance, nMode )

	local allyList = {}
	local numPlayer = GetTeamPlayers( GetTeam() )
	for i = 1, #numPlayer
	do
		local member = GetTeamMember( i )
		if member ~= nil and member:IsAlive()
		then
			if member:GetActiveMode() == nMode
				and GetUnitToUnitDistance( member, bot ) <= nDistance
			then
				table.insert( allyList, member )
			end
		end
	end

	return allyList

end


function GetTeamFightLocation( bot )

	local targetLocation = nil
	local numPlayer = GetTeamPlayers( GetTeam() )

	for i = 1, #numPlayer
	do
		local member = GetTeamMember( i )
		if member ~= nil and member:IsAlive()
			and IsInTeamFight( member, 1500 )
			and GetEnemyCount( member, 1400 ) >= 2
		then
			local allyList = GetSpecialModeAllies( member, 1400, BOT_MODE_ATTACK )
			targetLocation = GetCenterOfUnits( allyList )
			break
		end
	end

	return targetLocation

end

function IsInTeamFight( bot, nRadius )

	if nRadius == nil or nRadius > 1600 then nRadius = 1600 end

	local attackModeAllyList = bot:GetNearbyHeroes( nRadius, false, BOT_MODE_ATTACK )

	return #attackModeAllyList >= 2 and bot:GetActiveMode() ~= BOT_MODE_RETREAT

end


function GetEnemyCount( bot, nRadius )

	local nRealEnemyList = GetEnemyList( bot, nRadius )

	return #nRealEnemyList

end


function GetCenterOfUnits( nUnits )

	if #nUnits == 0
	then
		return Vector( 0.0, 0.0 )
	end

	local sum = Vector( 0.0, 0.0 )
	local num = 0

	for _, unit in pairs( nUnits )
	do
		if unit ~= nil
			and unit:IsAlive()
		then
			sum = sum + unit:GetLocation()
			num = num + 1
		end
	end

	if num == 0 then return Vector( 0.0, 0.0 ) end

	return sum / num

end

function GetUnitTowardDistanceLocation( bot, towardTarget, nDistance )

	local npcBotLocation = bot:GetLocation()
	local tempVector = ( towardTarget:GetLocation() - npcBotLocation ) / GetUnitToUnitDistance( bot, towardTarget )

	return npcBotLocation + nDistance * tempVector

end

function IsItemAvailable( sItemName )

	local bot = GetBot()

	local slot = bot:FindItemSlot( sItemName )

	if slot >= 0 and slot <= 5
	then
		return bot:GetItemInSlot( slot )
	end

end

function GetLocationToLocationDistance( fLoc, sLoc )

	local x1 = fLoc.x
	local x2 = sLoc.x
	local y1 = fLoc.y
	local y2 = sLoc.y

	return math.sqrt( math.pow( ( y2-y1 ), 2 ) + math.pow( ( x2-x1 ), 2 ) )

end


function IsRunning( bot )

	if not bot:IsAlive() then return false end

	return bot:GetAnimActivity() == ACTIVITY_RUN

end

function SetQueueSwitchPtToINT( bot )

	local pt = IsItemAvailable( "item_power_treads" )
	if pt ~= nil and pt:IsFullyCastable()
	then
		if pt:GetPowerTreadsStat() == ATTRIBUTE_INTELLECT
		then
			bot:ActionQueue_UseAbility( pt )
			bot:ActionQueue_UseAbility( pt )
			return
		elseif pt:GetPowerTreadsStat() == ATTRIBUTE_STRENGTH
			then
				bot:ActionQueue_UseAbility( pt )
				return
		end
	end

end

function SetQueuePtToINT( bot, bSoulRingUsed )

	bot:Action_ClearActions( true )

	if bSoulRingUsed then SetQueueUseSoulRing( bot ) end

	if not IsPTReady( bot, ATTRIBUTE_INTELLECT )
	then
		SetQueueSwitchPtToINT( bot )
	end

end



function IsPTReady( bot, status )

	if not bot:IsAlive()
		or bot:IsMuted()
		or bot:IsChanneling()
		or (bot:IsInvisible() and bot:GetHealth() / bot:GetMaxHealth() < 0.2 )
		or bot:GetHealth() / bot:GetMaxHealth() < 0.2
	then
		return true
	end

	if status == ATTRIBUTE_INTELLECT
	then
		status = ATTRIBUTE_AGILITY
	elseif status == ATTRIBUTE_AGILITY
		then
			status = ATTRIBUTE_INTELLECT
	end

	local pt = IsItemAvailable( "item_power_treads" )
	if pt ~= nil and pt:IsFullyCastable()
	then
		if pt:GetPowerTreadsStat() ~= status
		then
			return false
		end
	end

	return true

end


function ShouldSwitchPTStat( bot, pt )

	local ptStatus = pt:GetPowerTreadsStat()
	if ptStatus == ATTRIBUTE_INTELLECT
	then
		ptStatus = ATTRIBUTE_AGILITY
	elseif ptStatus == ATTRIBUTE_AGILITY
		then
			ptStatus = ATTRIBUTE_INTELLECT
	end

	return bot:GetPrimaryAttribute() ~= ptStatus

end



function IsHaveAegis( bot )

	return bot:FindItemSlot( "item_aegis" ) >= 0

end

function GetNumOfTeamTotalKills( bEnemy )

	local count = 0
	local nTeam = GetOpposingTeam()
	if bEnemy then nTeam = GetTeam() end

	for i, id in pairs( GetTeamPlayers( nTeam ) )
	do
		count = count + GetHeroDeaths( id )
	end

	return count

end


function GetAllyCount( bot, nRadius )

	local nRealAllyList = GetAllyList( bot, nRadius )

	return #nRealAllyList

end


function GetAlliesNearLoc( vLoc, nRadius )

	local allies = {}
	for i = 1, 5
	do
		local member = GetTeamMember( i )
		if member ~= nil
			and member:IsAlive()
			and GetUnitToLocationDistance( member, vLoc ) <= nRadius
		then
			table.insert( allies, member )
		end
	end

	return allies

end


function IsTeamActivityCount( bot, nCount )

	local numPlayer = GetTeamPlayers( GetTeam() )
	for i = 1, #numPlayer
	do
		local member = GetTeamMember( i )
		if member ~= nil and member:IsAlive()
		then
			if GetAllyCount( member, 1600 ) >= nCount
			then
				return true
			end
		end
	end

	return false

end

function IsInAllyArea( bot )

	local hAllyAcient = GetAncient( GetTeam() )
	local hEnemyAcient = GetAncient( GetOpposingTeam() )
	
	if GetUnitToUnitDistance( bot, hAllyAcient ) + 768 < GetUnitToUnitDistance( bot, hEnemyAcient )
	then
		return true
	end
	
	return false

end

function GetMostDefendLaneDesire()

	local nTopDesire = GetDefendLaneDesire( LANE_TOP )
	local nMidDesire = GetDefendLaneDesire( LANE_MID )
	local nBotDesire = GetDefendLaneDesire( LANE_BOT )

	if nTopDesire > nMidDesire and nTopDesire > nBotDesire
	then
		return LANE_TOP, nTopDesire
	end

	if nBotDesire > nMidDesire and nBotDesire > nTopDesire
	then
		return LANE_BOT, nBotDesire
	end

	return LANE_MID, nMidDesire

end

function GetLocationTowardDistanceLocation( bot, towardLocation, nDistance )

	local npcBotLocation = bot:GetLocation()
	local tempVector = ( towardLocation - npcBotLocation ) / GetUnitToLocationDistance( bot, towardLocation )

	return npcBotLocation + nDistance * tempVector

end


function GetAttackEnemysAllyCreepCount( target, nRadius )

	local bot = GetBot()
	local nAllyCreeps = bot:GetNearbyCreeps( nRadius, false )
	local nAttackEnemyCount = 0
	for _, creep in pairs( nAllyCreeps )
	do
		if creep:IsAlive()
			and creep:GetAttackTarget() == target
		then
			nAttackEnemyCount = nAttackEnemyCount + 1
		end
	end

	return nAttackEnemyCount

end


local LastActionTime = {}
function HasNotActionLast( nCD, nNumber )

	if LastActionTime[nNumber] == nil then LastActionTime[nNumber] = -90 end

	if DotaTime() > LastActionTime[nNumber] + nCD
	then
		LastActionTime[nNumber] = DotaTime()
		return true
	end

	return false

end


function GetMostFarmLaneDesire()

	local nTopDesire = GetFarmLaneDesire( LANE_TOP )
	local nMidDesire = GetFarmLaneDesire( LANE_MID )
	local nBotDesire = GetFarmLaneDesire( LANE_BOT )

	if nTopDesire > nMidDesire and nTopDesire > nBotDesire
	then
		return LANE_TOP, nTopDesire
	end

	if nBotDesire > nMidDesire and nBotDesire > nTopDesire
	then
		return LANE_BOT, nBotDesire
	end

	return LANE_MID, nMidDesire

end


function GetNearbyLocationToTp( nLoc )

	local nTeam = GetTeam()
	local nFountain = mutil.GetTeamFountain()

	if GetLocationToLocationDistance( nLoc, nFountain ) <= 2500
	then
		return nLoc
	end

	local targetTower = nil
	local minDist = 99999
	for i=0, 10, 1 do
		local tower = GetTower( nTeam, i )
		if tower ~= nil
			and GetUnitToLocationDistance( tower, nLoc ) < minDist
		then
			 targetTower = tower
			 minDist = GetUnitToLocationDistance( tower, nLoc )
		end
	end

	local watchTowerList = Site.GetAllWatchTower()
	for _, watchTower in pairs( watchTowerList )
	do
		if watchTower ~= nil
			and watchTower:GetTeam() == nTeam
			and GetUnitToLocationDistance( watchTower, nLoc ) < minDist - 1300
			and ( not IsEnemyHeroAroundLocation( watchTower:GetLocation(), 600 )
					or IsAllyHeroAroundLocation( watchTower:GetLocation(), 600 ) )
		then
			 targetTower = watchTower
			 minDist = GetUnitToLocationDistance( watchTower, nLoc ) + 1300
		end
	end

	if targetTower ~= nil
	then
		return GetLocationTowardDistanceLocation( targetTower, nLoc, 575 )
	end

	return nFountain

end

function IsEnemyHeroAroundLocation( vLoc, nRadius )

	for i, id in pairs( GetTeamPlayers( GetOpposingTeam() ) )
	do
		if IsHeroAlive( id ) then
			local info = GetHeroLastSeenInfo( id )
			if info ~= nil then
				local dInfo = info[1]
				if dInfo ~= nil
					and GetLocationToLocationDistance( vLoc, dInfo.location ) <= nRadius
					and dInfo.time_since_seen < 2.0
				then
					return true
				end
			end
		end
	end

	return false

end


function GetNEnemyAroundLocation(vLoc, nRadius, fTime)
	local nUnit = 0;
	for i,id in pairs(enemyPlayer) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id);
			if info ~= nil then
				local dInfo = info[1];
				if dInfo ~= nil 
					and utils.GetDistance(vLoc, dInfo.location) <= nRadius 
					and dInfo.time_since_seen < fTime 
				then
					nUnit = nUnit + 1;
				end
			end
		end
	end
	return nUnit;
end


function GetNAllyAroundLocation(vLoc, nRadius, fTime)
	local nUnit = 0;
	-- local vLoc = bot:GetLocation()
	-- for i,id in pairs(teamPlayer) do
		-- if IsHeroAlive(id) then
			-- local info = GetHeroLastSeenInfo(id);
			-- if info ~= nil then
				-- local dInfo = info[1];
				-- if dInfo ~= nil 
					-- and utils.GetDistance(vLoc, dInfo.location) <= nRadius 
					-- and dInfo.time_since_seen < fTime 
				-- then
					-- nUnit = nUnit + 1;
				-- end
			-- end
		-- end
	-- end
	
	
	for i = 1, 5
	do
		local npcAlly = GetTeamMember( i )
		if npcAlly ~= nil
			and npcAlly:IsAlive()
			and GetUnitToLocationDistance( npcAlly, vLoc ) <= nRadius
		then
			nUnit = nUnit + 1;
			-- return true
		end
	end
	
	return nUnit;
end

function IsAllyHeroAroundLocation( vLoc, nRadius )

	for i = 1, 5
	do
		local npcAlly = GetTeamMember( i )
		if npcAlly ~= nil
			and npcAlly:IsAlive()
			and GetUnitToLocationDistance( npcAlly, vLoc ) <= nRadius
		then
			return true
		end
	end

	return false

end


function IsLocHaveTower( nRadius, bEnemy, nLoc )

	local nTeam = GetTeam()
	if bEnemy then nTeam = GetOpposingTeam() end

	if ( not bEnemy and GetLocationToLocationDistance( nLoc, mutil.GetTeamFountain() ) < 2500 )
		or ( bEnemy and GetLocationToLocationDistance( nLoc, mutil.GetEnemyFountain() ) < 2500 )
	then
		return true
	end

	for i = 0, 10
	do
		local tower = GetTower( nTeam, i )
		if tower ~= nil and GetUnitToLocationDistance( tower, nLoc ) <= nRadius
		then
			 return true
		end
	end

	return false

end



function GetSaveLocToFarmRetreat()
		local minDist = 10000;
		
	local clashLoc = nil;
	for _,lane in pairs(lanes)
	do
		local tFLoc = GetLaneFrontLocation(GetTeam(), lane, 0);
		local eFLoc = GetLaneFrontLocation(GetOpposingTeam(), lane, 0);
		local fDist = utils.GetDistance(tFLoc, eFLoc);
		local uDist = GetUnitToLocationDistance(bot, tFLoc);
		if fDist <= 1000 and uDist < minDist and (IsUnitAroundLocation(eFLoc, 2000) or not IsUnitAroundLocation(eFLoc, 2000) ) then
			minDist = uDist;
			clashLoc = tFLoc;
		end
	end
	return clashLoc;
end



function GetClosestSafeLaneToFarm()
	local minDist = 100000;
	local loc = nil
	local lane = nil;
	for i=1, #lanes
	do
		local tFLoc = GetLaneFrontLocation(myTeam, lanes[i], -200);
		local eFLoc = GetLaneFrontLocation(enemyTeam, lanes[i], -200);
		local fDist = utils.GetDistance(tFLoc, eFLoc);
		local uDist = GetUnitToLocationDistance(bot, tFLoc);
		if ( fDist < 1000 or uDist < 1000 ) 
			and GetUnitToLocationDistance(eAncient, tFLoc) > 3000
			and uDist < minDist 
			and GetNEnemyAroundLocation(eFLoc, 1600, 2.0) <= 2  
			and GetNAllyAroundLocation(eFLoc, 1600, 2.0) >= 1
		then
			minDist = uDist;
			loc = tFLoc;
			lane = lanes[i]
		end
	end
	return loc, minDist, lane;
end 





function CanHitHero(bot,hero)	
	-- local hero = nil;
	-- if hero == nil then hero = bot:GetTarget() end
	
	return hero ~= nil and  hero ~= bot:GetTarget() and hero:IsAlive() and hero:IsHero() and not hero:IsNull() 
	and GetUnitToUnitDistance (bot,hero) < attackRange; 
end


function CanLastHitCreep(bot, creep)
	return creep:GetActualIncomingDamage(1.05*bot:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL) >= creep:GetHealth()
end

function IsTargetedByCreepOrTower(bot, ecreeps, etowers)
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
	return false
end

function GetCreepToLastHit(bot, creeps, towers)
	for i=1, #creeps do
		if CanLastHitCreep(bot, creeps[i]) == true 
		then
			return creeps[i];
		end
	end
	return nil;
end

function GetRangeCreeps(bot, creeps, towers)
	for i=1, #creeps do
		if (towers[1] == nil or (towers[1] ~= nil and GetUnitToUnitDistance(creeps[i], towers[1]) > 700) ) and creeps[i]:GetAttackRange() > 150
		then
			return creeps[i];
		end
	end
	return nil;
end

function GetRandomCreep(bot, creeps, towers)
	for i=1, #creeps do
		if (towers[1] == nil or (towers[1] ~= nil and GetUnitToUnitDistance(creeps[i], towers[1]) > 700) ) and creeps[i]:GetHealth() > 2*bot:GetAttackDamage()
		then
			return creeps[i];
		end
	end
	return nil;
end

function GetTargetCreepToAttack(bot, ecreeps, acreeps, etowers)
	local tgt = GetCreepToLastHit(bot, ecreeps, etowers)
	if tgt == nil then
		tgt = GetCreepToLastHit(bot, acreeps, etowers)
		if tgt == nil then
			tgt = GetRangeCreeps(bot, ecreeps, etowers)
			if tgt == nil and #ecreeps == 0 and etowers[1] ~= nil then
				tgt = etowers[1];
			end
		end
	end
	return tgt;
end



function GetWeakestUnit(units)
	local lowestHP = 10000;
	local lowestUnit = nil;
	for _,unit in pairs(units)
	do
		local hp = unit:GetHealth();
		if hp < lowestHP then
			lowestHP = hp;
			lowestUnit = unit;	
		end
	end
	return lowestUnit;
end



function GetTargetCreepToAttack2(bot,ecreeps,acreeps,etowers,eheros)
	
	
	local tgt = GetCreepToLastHit2(bot,eheros, ecreeps, etowers)
	if tgt == nil then
		tgt = GetCreepToLastHit2(bot,eheros, acreeps, etowers)
		if tgt == nil then
			tgt = GetRangeCreeps2(bot, ecreeps, etowers)
				if tgt == nil and #ecreeps == 0 and etowers[1] ~= nil then
				tgt = etowers[1];
				if tgt == nil then 
					tgt = GetRandomCreep(bot,ecreeps, etowers) 
			
				if tgt == nil and #ecreeps >= 0 and #etowers == 0 and eheros[1] ~= nil then
				tgt = eheros[1];
				
			end
		end
	end
	end
	end
	return tgt;
end

function GetRangeCreeps2(bot, creeps, towers)
	local enemyHeroes = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
	local Rcreeps = bot:GetNearbyCreeps(1600, true);
	
	for i=1, #creeps do
		if (towers[1] == nil or (towers[1] ~= nil and GetUnitToUnitDistance(creeps[i], towers[1]) > 700) ) 
		and (creeps[i]:GetAttackRange() > 50 and creeps[i]:GetAttackRange() <= 100  ) 
		and  bot:WasRecentlyDamagedByCreep(5.0) and #Rcreeps >= 8
		-- and #enemyHeroes == 0
		then
			return creeps[i];
		end
	end
	
	
	for i=1, #creeps do
		if (towers[1] == nil or (towers[1] ~= nil and GetUnitToUnitDistance(creeps[i], towers[1]) > 700) ) 
		and (creeps[i]:GetAttackRange() > 150 and creeps[i]:GetAttackRange() <= 700  ) 
		and not bot:WasRecentlyDamagedByCreep(5.0) and #Rcreeps >= 8
		-- and #enemyHeroes == 0
		then
			return creeps[i];
		end
	end
	
	
	
	return nil;
end

function GetCreepToLastHit2(bot,heros, creeps, towers)
	for i=1, #creeps do
		if CanLastHitCreep(bot, creeps[i]) == true 
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

-- dota2jmz@163.com QQ:2462331592.
