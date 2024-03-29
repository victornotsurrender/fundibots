if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end


--require(GetScriptDirectory() ..  "/ability_item_usage_generic")
local ability_item_usage_generic = dofile("bots/ability_item_usage_generic" )
local utils = require("bots/util")
local inspect = require("bots/inspect")
local enemyStatus = require("bots/enemy_status" )
local teamStatus = require("bots/team_status" )
local mutil = require("bots/MyUtility")
local mutils = require("bots/MyUtility")

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end
function ItemUsageThink()
	ability_item_usage_generic.ItemUsageThink();
end

local courierTime = 0
----------------------------------------------------------------------------------------------------

-- local castBADesire = 0;
-- local castCogsDesire = 0;
-- local castHookDesire = 0;
-- local castFlareDesire = 0;
-- local castBlinkInitDesire = 0; 
-- local castForceEnemyDesire = 0;
-- local castOverclockDesire = 0;

local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;
local castDDesire = 0;

local abilityQ = nil;
local abilityW = nil;
local abilityE = nil;
local abilityR = nil;
local abilityD = nil;

local npcBot = GetBot();
local bot = GetBot();



function AbilityUsageThink()
	-- local npcBot = GetBot();
		
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	
	-- abilityBA = npcBot:GetAbilityByName( "rattletrap_battery_assault" );
	-- abilityCogs = npcBot:GetAbilityByName( "rattletrap_power_cogs" );
	-- abilityHook = npcBot:GetAbilityByName( "rattletrap_hookshot" );
	-- abilityFlare = npcBot:GetAbilityByName( "rattletrap_rocket_flare" );
	-- abilityOverclock = npcBot:GetAbilityByName( "rattletrap_overclocking" );
	-- itemForce = "item_force_staff";
	-- itemBlink = "item_blink";
	
	-- for i=0, 5 do
		-- if(npcBot:GetItemInSlot(i) ~= nil) then
			-- local _item = npcBot:GetItemInSlot(i):GetName()
			-- if(_item == itemBlink) then
				-- itemBlink = npcBot:GetItemInSlot(i);
			-- end
			-- if(_item == itemForce) then
				-- itemForce = npcBot:GetItemInSlot(i);
			-- end
		-- end
	-- end
	
	if abilityQ == nil then abilityQ = npcBot:GetAbilityByName( "rattletrap_battery_assault" ) end
	if abilityW == nil then abilityW = npcBot:GetAbilityByName( "rattletrap_power_cogs" ) end
	if abilityE == nil then abilityE = npcBot:GetAbilityByName( "rattletrap_rocket_flare" ) end
	if abilityR == nil then abilityR = npcBot:GetAbilityByName( "rattletrap_hookshot" ) end
	if abilityD == nil then abilityD = npcBot:GetAbilityByName( "rattletrap_overclocking" ) end

	-- Consider using each ability

	-- castCogsDesire = ConsiderCogs();
	-- castHookDesire, castHookTarget = ConsiderHook();
	-- castBADesire = ConsiderAssault();
	-- castFlareDesire, castFlareTarget = ConsiderFlare();
	-- castBlinkInitDesire, castBlinkInitTarget = ConsiderBlinkInit();
	-- castForceEnemyDesire, castForceEnemyTarget = ConsiderForceEnemy();
	-- castOverclockDesire = ConsiderOverclock();
	
	castQDesire = ConsiderQ();
	castWDesire = ConsiderW();
	castEDesire, castETarget = ConsiderE();	
	castRDesire, castRTarget = ConsiderR();	
	castDDesire = ConsiderD();
	
	-- ability_item_usage_generic.SwapItemsTest()

	-- local highestDesire = castCogsDesire;
	-- local desiredSkill = 1;

	-- if ( castHookDesire > highestDesire) 
		-- then
			-- highestDesire = castHookDesire;
			-- desiredSkill = 2;
	-- end

	-- if ( castBADesire > highestDesire) 
		-- then
			-- highestDesire = castBADesire;
			-- desiredSkill = 3;
	-- end

	-- if ( castFlareDesire > highestDesire) 
		-- then
			-- highestDesire = castFlareDesire;
			-- desiredSkill = 4;
	-- end

	-- if ( castBlinkInitDesire > highestDesire) 
		-- then
			-- highestDesire = castBlinkInitDesire;
			-- desiredSkill = 6;
	-- end

	-- if ( castForceEnemyDesire > highestDesire) 
		-- then
			-- highestDesire = castForceEnemyDesire;
			-- desiredSkill = 7;
	-- end

	-- print("desires".. castOrbDesire .. castSilenceDesire .. castPhaseDesire .. castJauntDesire .. castCoilDesire);
	-- if highestDesire == 0 then return;
    -- elseif desiredSkill == 1 then 
		-- npcBot:Action_UseAbility( abilityCogs );
    -- elseif desiredSkill == 2 then 
		-- npcBot:Action_UseAbilityOnLocation( abilityHook, castHookTarget );
    -- elseif desiredSkill == 3 then 
		-- npcBot:Action_UseAbility( abilityBA );
    -- elseif desiredSkill == 4 then 
		-- npcBot:Action_UseAbilityOnLocation( abilityFlare, castFlareTarget );
    -- elseif desiredSkill == 6 then 
		-- performBlinkInit( castBlinkInitTarget );
    -- elseif desiredSkill == 7 then 
		-- performForceEnemy( castForceEnemyTarget );
	-- end	
	
	-- if castOverclockDesire > 0 then
		-- npcBot:Action_UseAbility( abilityOverclock );
	-- end
	
	if ( castQDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityQ );
		return;
	end
	
	if ( castWDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityW );
		return;
	end
	
	if ( castEDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityE, castETarget );
		return;
	end
	
	if ( castRDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityR, castRTarget);
		return;
	end
	
	if ( castDDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityD );
		return;
	end

end

----------------------------------------------------------------------------------------------------

-- function CanCastHookOnTarget( npcTarget )
	-- return not npcTarget:IsInvulnerable();
-- end


-- function CanCastFlareOnTarget( npcTarget )
	-- return not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
-- end


function CanCastBAOnTarget( npcTarget )
	return npcTarget:CanBeSeen()  and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end


function IsHeroBetweenMeAndTarget(source, target, endLoc, radius)
	local vStart = source:GetLocation();
	local vEnd = endLoc;
	local enemy_heroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for i=1, #enemy_heroes do
		if enemy_heroes[i] ~= target
			and enemy_heroes[i] ~= source
		then	
			local tResult = PointToLineDistance(vStart, vEnd, enemy_heroes[i]:GetLocation());
			if tResult ~= nil 
				and tResult.within == true  
				and tResult.distance < radius + 25 			
			then
				return true;
			end
		end
	end
	local ally_heroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
	for i=1, #ally_heroes do
		if ally_heroes[i] ~= target
			and ally_heroes[i] ~= source
		then	
			local tResult = PointToLineDistance(vStart, vEnd, ally_heroes[i]:GetLocation());
			if tResult ~= nil 
				and tResult.within == true  
				and tResult.distance < radius + 25 			
			then
				return true;
			end
		end
	end
	return false;
end

----------------------------------------------------------------------------------------------------

function ConsiderQ()

	-- local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- If we want to cast priorities at all, bail
	--if ( castPhaseDesire > 0 or castCoilDesire > 50) then
	--	return BOT_ACTION_DESIRE_NONE;
	--end

	-- Get some of its values
	local nRadius = abilityQ:GetSpecialValueInt( "radius" );
	local nDamage = 10 * abilityQ:GetAbilityDamage();
    local nManaCost = abilityQ:GetManaCost()
	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	-- -- If we're going after someone
	-- if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 -- npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 -- npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 -- npcBot:GetActiveMode() == BOT_MODE_GANK or
		 -- npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	-- then
		-- local npcTarget = npcBot:GetTarget();

		-- if ( npcTarget ~= nil  and npcTarget:IsHero() ) 
		-- then
			-- if GetUnitToUnitDistance( npcBot, npcTarget ) < nRadius then
				-- return BOT_ACTION_DESIRE_MODERATE
			-- end
		-- end
	-- end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 ) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW;
		end
	end	
	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot)  or npcBot:GetActiveMode() == BOT_MODE_LANING) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nRadius, true);
		
		if ( lanecreeps~= nil and #lanecreeps >= 8  ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	

	-- If enemy is channeling cancel it
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
	for _,npcTarget in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcTarget:IsChanneling() and GetUnitToUnitDistance( npcTarget, npcBot ) < nRadius ) 
		then
			if ( CanCastBAOnTarget( npcTarget ) ) 
			then
			--print("retreat Net")
				return BOT_ACTION_DESIRE_MODERATE
			end
		end
	end

	-- If a mode has set a target, and we can kill them, do it
	if ( npcTarget ~= nil  and npcTarget:IsHero() and CanCastBAOnTarget( npcTarget ) )
	then
		if ( npcTarget:GetActualIncomingDamage( nDamage, 2 ) > npcTarget:GetHealth() and GetUnitToUnitDistance( npcTarget, npcBot ) < nRadius )
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and 
	       mutil.IsInRange(npcTarget, npcBot, nRadius - 50) 
		   and not mutil.IsSuspiciousIllusion(npcTarget) and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison'))
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	

	return BOT_ACTION_DESIRE_NONE, 0;
end





---------------------------------------------------------------------------------------------

function ConsiderW()	
	
	-- Make sure it's castable
	if ( not abilityW:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- local npcBot = GetBot();

	local nRadius = abilityW:GetSpecialValueInt( "cogs_radius" );
	local nActivationRadius = abilityW:GetSpecialValueInt( "trigger_distance" )
	local nDamage = abilityW:GetAbilityDamage();

	
	--[[if npcBot:DistanceFromFountain() > 1300 then
		return BOT_ACTION_DESIRE_ABSOLUTE
	end]]--

	--if we are laning and enemy is going for a last hit and we're very bored

	--if we are retreating and enemy will be outside cogs
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 and tableNearbyEnemyHeroes[1] ~= nil ) 
		then
			if ( GetUnitToUnitDistance(npcBot,tableNearbyEnemyHeroes[1] ) > nRadius+100 and tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes < 2 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE
			end
		end
	end

	--if in a team fight
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nRadius) 
		then
			local distance = GetUnitToUnitDistance(npcTarget, npcBot);
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	--if enemy is under our tower
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	local tableNearbyFriendlyTowers = npcBot:GetNearbyTowers( 1300, false );
	for _,v in pairs(tableNearbyEnemyHeroes) do
		local tower = tableNearbyFriendlyTowers[1];	
		if tower ~= nil then
			if ( GetUnitToUnitDistance( v, tower ) < 700 and GetUnitToUnitDistance( v, npcBot ) < nRadius ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;

end




------------------------------------------------------------------------------------------------------

function ConsiderE()
	-- local npcBot = GetBot();

	if ( not abilityE:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nRadius = abilityE:GetSpecialValueInt( "radius" );
	local speed = abilityE:GetSpecialValueInt( "speed" );
	local nDamage = abilityE:GetAbilityDamage();
	local nCastPoint = abilityE:GetCastPoint();
    local nManaCost  = abilityE:GetManaCost();
	local nCastRange = 2000;
	
	
	
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and mutil.CanKillTarget2(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	--if we can hit any enemies with regen modifier
	-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and (npcEnemy:HasModifier("modifier_clarity_potion") or npcEnemy:HasModifier("modifier_flask_healing") )then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
			end
		end
	end
	
	

	-- farming
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING and npcBot:GetMana() > (npcBot:GetMaxMana() * .5)) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		local npcTarget = tableNearbyEnemyHeroes[1];

		if ( npcTarget ~= nil ) 
		then
			local locationAoE = npcBot:FindAoELocation( true, false, npcTarget:GetLocation(), nRadius * .8, nRadius, 0.0, 20000 );
			--print(locationAoE.count)
			if ( locationAoE.count >= 8 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
			end
		end

		
	end
	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
	
		local lanecreeps = npcBot:GetNearbyLaneCreeps(1000, true);
		local npcTarget = lanecreeps[1];
		
		if ( npcTarget ~= nil ) 
		then		
			local locationAoE = npcBot:FindAoELocation( true, false, npcTarget:GetLocation(), nRadius * .8, nRadius, 0, 20000 );
			if ( locationAoE.count >= 4  ) 
		    then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW,npcTarget:GetLocation();
		end
	end	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1000)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end

	local npcTarget = npcBot:GetTarget();
	if ( npcTarget ~= nil and npcTarget:IsHero() and npcTarget:CanBeSeen() )
	then
		if ( npcTarget:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL  ) > npcTarget:GetHealth() )
		then
			local distance = GetUnitToUnitDistance(npcTarget, npcBot);
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nRadius * .8, nRadius, 0.0, 20000 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	-- if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 -- npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 -- npcBot:GetActiveMode() == BOT_MODE_GANK or
		 -- npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 -- npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	-- then
		-- if ( npcTarget ~= nil and npcTarget:IsHero() and npcTarget:CanBeSeen() ) 
		-- then
			-- local distance = GetUnitToUnitDistance(npcTarget, npcBot);
			-- return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
			-- return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
		-- end
	-- end
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) 
		and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local distance = GetUnitToUnitDistance(npcTarget, npcBot);
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(nCastPoint + ( distance / speed ) );
		end
	end
	-- harassing

	-- sniping

	-- scouting

	-- check rosh

	return BOT_ACTION_DESIRE_NONE;

end

----------------------------------------------------------------------------------------------------

function ConsiderR()
	-- local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- If we want to cast priorities at all, bail
	--if ( castPhaseDesire > 0 or castCoilDesire > 50) then
	--	return BOT_ACTION_DESIRE_NONE;
	--end

	-- Get some of its values
	local nRadius = abilityR:GetSpecialValueInt( "latch_radius" );
	local speed = abilityR:GetSpecialValueInt( "speed" );
	local nDamage = abilityR:GetAbilityDamage();
	local nCastRange = mutils.GetProperCastRange(false, bot, 1600);
	-- abilityR:GetCastRange();
	local nCastPoint = abilityR:GetCastPoint();
	
	
	
	
	if mutils.IsRetreating(bot) 
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 and bot:WasRecentlyDamagedByAnyHero(3.0) then
			local loc = mutils.GetEscapeLoc();
			local furthestUnit = mutils.GetClosestUnitToLocationFrommAll(bot, nCastRange, loc);
			if furthestUnit ~= nil and GetUnitToUnitDistance(furthestUnit, bot) >= nCastRange/2   then
				return BOT_ACTION_DESIRE_LOW, furthestUnit:GetLocation();
			end
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING) 
	or (mutil.IsRetreating(npcBot) and bot:GetHealth() > 0.35*bot:GetMaxHealth()  )
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
		local allies = bot:GetNearbyHeroes(150, false, BOT_MODE_NONE);
		local Atowers = npcBot:GetNearbyTowers(1600, false);
		
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  mutil.CanCastOnNonMagicImmune(npcEnemy)
			then	
		for _,u in pairs(Atowers) do
			if GetUnitToLocationDistance(bot,u:GetLocation()) <= 700
				then
			if #allies >= #tableNearbyEnemyHeroes then
				local distance = GetUnitToUnitDistance(npcEnemy, bot)
				local moveCon = npcEnemy:GetMovementDirectionStability();
				local pLoc = npcEnemy:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
				if moveCon < 1  then
					pLoc = npcEnemy:GetLocation();
				end
				if mutils.IsAllyHeroBetweenMeAndTarget(bot, npcEnemy, pLoc, nRadius) == false 
					and mutils.IsCreepBetweenMeAndTarget(bot, npcEnemy, pLoc, nRadius) == false
				then
					
					return BOT_ACTION_DESIRE_MODERATE, pLoc;
				end
			end
		end
	end
	end
	end
	end
	
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnMagicImmune(target) 
			-- and bot:IsFacingLocation(target:GetLocation(),15) 
			and mutils.IsInRange(bot, target, nCastRange)
		then
			-- if moveST ~= target:GetUnitName() or target:GetMovementDirectionStability() ~= moveS then
				-- print(target:GetUnitName().." : "..tostring(target:GetMovementDirectionStability()))
				-- moveST = target:GetUnitName();
				-- moveS = target:GetMovementDirectionStability();
			-- end
			local allies = bot:GetNearbyHeroes(150, false, BOT_MODE_NONE);
			if #allies <= 1 then
				local distance = GetUnitToUnitDistance(target, bot)
				local moveCon = target:GetMovementDirectionStability();
				local pLoc = target:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
				if moveCon < 0.65 then
					pLoc = target:GetLocation();
				end
				if mutils.IsAllyHeroBetweenMeAndTarget(bot, target, pLoc, nRadius) == false 
					and mutils.IsCreepBetweenMeAndTarget(bot, target, pLoc, nRadius) == false
				then
					local cpos = utils.GetTowardsFountainLocation(pLoc, 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					return BOT_ACTION_DESIRE_MODERATE, pLoc;
				end
			end
		end
	end
	

	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			local distance = GetUnitToUnitDistance(npcTarget, npcBot)
			local moveCon = npcTarget:GetMovementDirectionStability();
			local pLoc = npcTarget:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
			if moveCon < 1 then
				pLoc = npcTarget:GetLocation();
			end
			if not mutil.IsAllyHeroBetweenMeAndTarget(npcBot, npcTarget, pLoc, nRadius) 
			and not mutil.IsCreepBetweenMeAndTarget(npcBot, npcTarget, pLoc, nRadius) then
				local cpos = utils.GetTowardsFountainLocation(pLoc, 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, pLoc;
			end
		end
	end
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and mutil.CanKillTarget2(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) 
		 or npcEnemy:IsChanneling()
		then
			local distance = GetUnitToUnitDistance(npcEnemy, bot)
				local moveCon = npcEnemy:GetMovementDirectionStability();
				local pLoc = npcEnemy:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
				if moveCon < 1  then
					pLoc = npcEnemy:GetLocation();
				end
				if mutils.IsAllyHeroBetweenMeAndTarget(bot, npcEnemy, pLoc, nRadius) == false 
					and mutils.IsCreepBetweenMeAndTarget(bot, npcEnemy, pLoc, nRadius) == false
				then
					
				return BOT_ACTION_DESIRE_MODERATE, pLoc;
			
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


----------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------



function ConsiderD()

	-- local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityD:IsFullyCastable() ) or npcBot:HasScepter() == false then 
		return BOT_ACTION_DESIRE_NONE;
	end

	--if in a team fight
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and npcTarget:IsIllusion() == false and GetUnitToUnitDistance( npcTarget, npcBot ) < 600) 
		then
			local skillslot = {0,1,2,5};
			local n_ability = 0;
			for i=1, #skillslot do
				local ability = npcBot:GetAbilityInSlot(skillslot[i]);
				if ability ~= nil 
					and ability:IsTrained() == true
					and ItemUsageModule.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_PASSIVE) == false
					and ItemUsageModule.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_HIDDEN) == false
				then
					if ability:GetCooldownTimeRemaining() > 3 then
						n_ability = n_ability + 1;
					end
				end
			end
			if  n_ability >= 3 then
				return BOT_ACTION_DESIRE_ABSOLUTE, nil;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

----------------------------------------------------------------------------------------------------

-- function ConsiderBlinkInit()

	-- -- local npcBot = GetBot();

	-- -- Make sure it's castable
	-- if ( not abilityCogs:IsFullyCastable() or
		-- not abilityBA:IsFullyCastable()) 
	-- then 
		-- return BOT_ACTION_DESIRE_NONE, 0;
	-- end

	-- -- Get some of its values
	-- local nCastRange = 1200;
	-- local nRadius = abilityCogs:GetSpecialValueInt( "radius" );

	-- -- Find a big group to nuke

	-- local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 1300, nRadius, 0, 0 );
	-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	-- local npcTarget = tableNearbyEnemyHeroes[1];	
	-- if npcTarget ~= nil then
		-- if ( locationAoE.count >= 3 and GetUnitToLocationDistance( npcTarget, locationAoE.targetloc ) < nRadius ) 
		-- then
			-- return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		-- end
	-- end
	-- return BOT_ACTION_DESIRE_NONE, 0;

-- end
----------------------------------------------------------------------------------------------------

-- function ConsiderForceEnemy()

	-- -- local npcBot = GetBot();

	-- -- Make sure it's castable
	-- if ( itemForce == "item_force_staff" or not itemForce:IsFullyCastable()) 
	-- then 
		-- return BOT_ACTION_DESIRE_NONE, 0;
	-- end

	-- -- Get some of its values
	-- local nCastRange = 800;
	-- local nPushRange = 600;

	-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	-- local tableNearbyFriendlyTowers = npcBot:GetNearbyTowers( 1000, false );
	-- local npcTarget = tableNearbyEnemyHeroes[1];
	-- local tower = tableNearbyFriendlyTowers[1];	
	-- if npcTarget ~= nil and tower ~= nil then
		-- if ( GetUnitToUnitDistance( npcTarget, tower ) < 1000 ) 
		-- then
			-- if(npcTarget:IsFacingUnit( tower, 15 )) then

				-- return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			-- end
		-- end
	-- end
	-- return BOT_ACTION_DESIRE_NONE, 0;

-- end

-- ----------------------------------------------------------------------------------------------------

-- function performBlinkInit( castBlinkInitTarget )
	-- -- local npcBot = GetBot();
	-- local orbTarget = npcBot:GetLocation();

	-- if( itemBlink ~= "item_blink" and itemBlink:IsFullyCastable()) then
		-- npcBot:Action_UseAbilityOnLocation( itemBlink, castBlinkInitTarget);
	-- end
-- end

-- ----------------------------------------------------------------------------------------------------

-- function performForceEnemy( castForceEnemyTarget )
	-- -- local npcBot = GetBot();
	-- npcBot:Action_UseAbilityOnEntity( itemForce, castForceEnemyTarget );
-- end

----------------------------------------------------------------------------------------------------
