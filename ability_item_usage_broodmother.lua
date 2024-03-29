if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
local mutil = require("bots/MyUtility")

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

local castSSDesire = 0;
local castSWDesire = 0;
local castIHDesire = 0;
local castSBDesire = 0;

local abilitySS = nil;
local abilitySW = nil;
local abilityIH = nil;
local abilitySB = nil;

local cast = false;
local timeCast = 0;
-- local npcBot = nil;
local npcBot = GetBot();
local bot = GetBot();

function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	if abilitySS == nil then abilitySS = npcBot:GetAbilityByName( "broodmother_spawn_spiderlings" ); end
	if abilitySW == nil then abilitySW = npcBot:GetAbilityByName( "broodmother_spin_web" ); end
	if abilityIH == nil then abilityIH = npcBot:GetAbilityByName( "broodmother_insatiable_hunger" ); end
	if abilitySB == nil then abilitySB = npcBot:GetAbilityByName( "broodmother_silken_bola" ); end

	-- Consider using each ability
	castSSDesire, castSSTarget = ConsiderSpawnSpiderlings();
	castSWDesire, castSWLocation = ConsiderSpinWeb();
	castIHDesire = ConsiderInsatiableHunger();
	castSBDesire, castSBTarget = ConsiderSilkenBola();
	-- ability_item_usage_generic.SwapItemsTest()
	
	
	if ( castSSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilitySS, castSSTarget );
		return;
	end
	
	if ( castSBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilitySB, castSBTarget );
		return;
	end
	
	if ( castSWDesire > 0 and DotaTime() >= timeCast + 0.8 ) 
	then
		npcBot:ActionPush_UseAbilityOnLocation( abilitySW, castSWLocation );
		timeCast = DotaTime();
		return;
	end
	if ( castIHDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityIH );
		return;
	end
	
end

function LocationOverlapWeb(location, nRadius)
	local unit = GetUnitList(UNIT_LIST_ALLIES);
	for _,u in pairs (unit)
	do
		if u:GetUnitName() == "npc_dota_broodmother_web"
		then
			local flag = ( 1.5*nRadius ) + 150;
			if GetUnitToLocationDistance(u, location) <= flag then
				return true
			end
		end
	end
	return false;
end

function GetTowardsFountainLocation( unitLoc, distance )
	local destination = {};
	if ( GetTeam() == TEAM_RADIANT ) then
		destination[1] = unitLoc[1] - distance / math.sqrt(2);
		destination[2] = unitLoc[2] - distance / math.sqrt(2);
	end

	if ( GetTeam() == TEAM_DIRE ) then
		destination[1] = unitLoc[1] + distance / math.sqrt(2);
		destination[2] = unitLoc[2] + distance / math.sqrt(2);
	end
	return Vector(destination[1], destination[2]);
end

function ConsiderSpawnSpiderlings()

	-- Make sure it's castable
	if ( not abilitySS:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilitySS:GetCastRange();
	local nDamage = abilitySS:GetSpecialValueInt("damage");
	local level = abilitySS:GetLevel();
	local mana = npcBot:GetMana() / npcBot:GetMaxMana();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and 
	   mutil.IsInRange(npcTarget, npcBot, nCastRange + 200)
	   and not mutil.IsSuspiciousIllusion(npcTarget)
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end
	
	
	--if we can hit any enemies with regen modifier
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and (npcEnemy:HasModifier("modifier_clarity_potion") or npcEnemy:HasModifier("modifier_flask_healing") )then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end

	-- If we're going after someone
	if  npcBot:GetActiveMode() == BOT_MODE_LANING or
		mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps ( nCastRange + 200, true );
		for _,creep in pairs(tableNearbyEnemyCreeps)
		do
			if mutil.CanKillTarget(creep, nDamage, DAMAGE_TYPE_MAGICAL) and mana > .45 then
				return BOT_ACTION_DESIRE_HIGH, creep;
			end
		end
	end
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if (  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-200) and not mutil.IsSuspiciousIllusion(npcTarget) ) 
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderSpinWeb()

	-- Make sure it's castable
	if ( not abilitySW:IsFullyCastable() or npcBot:IsCastingAbility() or abilitySW:IsInAbilityPhase() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nRadius = abilitySW:GetSpecialValueInt( "radius" );
	local nCastRange = 900;
	local nCastPoint = abilitySW:GetCastPoint( );
    
	local enemies = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
	
	-- if DotaTime() > 15 and npcBot:DistanceFromFountain() > 1000 
		-- and not LocationOverlapWeb( npcBot:GetXUnitsInFront(nCastRange), nRadius )
		-- and #enemies == 0
	   -- then
		-- return BOT_ACTION_DESIRE_MODERATE, npcBot:GetXUnitsInFront(nCastRange);
	-- end
	
	if mutil.IsStuck(npcBot)
	then
		return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation();
	end
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and 
				not LocationOverlapWeb(GetTowardsFountainLocation( npcBot:GetLocation(), nCastRange ), nRadius ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, GetTowardsFountainLocation( npcBot:GetLocation(), nCastRange );
			end
		end
	end
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM   
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nRadius/2);
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0
				and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1 
				and not LocationOverlapWeb(GetTowardsFountainLocation( npcBot:GetLocation(), nCastRange ), nRadius )
					then 
					return BOT_ACTION_DESIRE_MODERATE,npcBot:GetLocation();
				end
			end
		end
	end
	
	

	if mutil.IsPushing(npcBot) 
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		local NearbyTower = npcBot:GetNearbyTowers(nRadius, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius / 3, 0, 0 );
		if locationAoE.count >= 3 and #lanecreeps >= 3 and not LocationOverlapWeb(locationAoE.targetloc, nRadius) then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
		if NearbyTower[1] ~= nil and not NearbyTower[1]:IsInvulnerable() and 
			not LocationOverlapWeb(NearbyTower[1]:GetLocation(), nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE, NearbyTower[1]:GetLocation();
		end
	end
	
	if mutil.IsDefending(npcBot)
	then
		local NearbyTower = npcBot:GetNearbyTowers(nRadius, false);
		if NearbyTower[1] ~= nil and not NearbyTower[1]:IsInvulnerable() and 
			not LocationOverlapWeb(NearbyTower[1]:GetLocation(), nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE, NearbyTower[1]:GetLocation();
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_LANING then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( 800, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 4 and not LocationOverlapWeb(npcBot:GetLocation(), nRadius ) then
			return BOT_MODE_DESIRE_MODERATE, npcBot:GetLocation();
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) and 
			not LocationOverlapWeb(npcTarget:GetExtrapolatedLocation( nCastPoint ), nRadius)   
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderInsatiableHunger()

	-- Make sure it's castable
	if ( not abilityIH:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nAttackRange = npcBot:GetAttackRange();
	local currHealthP = npcBot:GetHealth() / npcBot:GetMaxHealth();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and currHealthP < 0.50
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 2*nAttackRange)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end












function ConsiderSilkenBola()

	-- Make sure it's castable
	if ( not abilitySB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilitySB:GetCastRange();
	local nDamage = abilitySB:GetSpecialValueInt( "impact_damage" );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and mutil.CanCastOnNonMagicImmune2(npcEnemy) and not mutil.IsSuspiciousIllusion2(npcEnemy) ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if (mutil.CanCastOnNonMagicImmune2(npcEnemy) and mutil.CanKillTarget2(npcEnemy, nDamage*2, DAMAGE_TYPE_MAGICAL)
		and abilitySB:IsTrained())  
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	if ( mutil.IsPushing(npcBot) or  mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING) 
	and currManaP > 0.45 and  abilitySB:GetLevel() > 1
	then
	   
	
		local laneCreeps = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		for _,creep in pairs(laneCreeps)
		do
			if creep:GetHealth() <= nDamage then
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
			for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
			do
			if mutil.CanCastOnNonMagicImmune2(npcEnemy) then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end
		    end
        end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and currManaP > 0.45
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_MODERATE,npcTarget;
		end
	end
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING) 
	and currManaP > 0.45 and  abilitySB:GetLevel() > 1
	then
	   local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
		local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy)
			and npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.80 ) and #tableNearbyAlliedHeroes >=1
			then
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
			then
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		   and not mutil.IsDisabled(true, npcTarget) and not mutil.IsSuspiciousIllusion(npcTarget)
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end
