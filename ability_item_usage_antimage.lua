if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile("bots/ability_item_usage_generic" )
local utils = require("bots/util")
local mutil = require( "bots/MyUtility")

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

local castTWDesire = 0;
local castCHDesire = 0;
local castCSDesire = 0;
local castBFDesire = 0;

local abilityTW = nil;
local abilityCH = nil;
local abilityCS = nil;
local abilityBF = nil;

local npcBot = nil;
local bot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	if bot == nil then bot = GetBot(); end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	if abilityTW == nil then abilityTW = npcBot:GetAbilityByName( "antimage_blink" ); end
	if abilityCH == nil then abilityCH = npcBot:GetAbilityByName( "antimage_mana_void" ); end
	if abilityCS == nil then abilityCS = npcBot:GetAbilityByName( "antimage_counterspell" ); end
	if abilityBF == nil then abilityBF = npcBot:GetAbilityByName( "antimage_mana_overload" ); end
	-- Consider using each ability
	castTWDesire, castTWLocation = ConsiderTimeWalk();
	castCHDesire, castCHTarget = ConsiderCorrosiveHaze();
	castCSDesire = ConsiderCounterSpell();
	castBFDesire, castBFLocation = ConsiderBlinkFragment();
	
	
	
	if ( castTWDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTW, castTWLocation );
		return;
	end	
	
	if ( castCHDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityCH, castCHTarget );
		return;
	end
	
	if ( castCSDesire > 0 ) then
		npcBot:Action_UseAbility( abilityCS );
		return;
	end
	
	
	if ( castBFDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityBF, castBFLocation );
		return;
	end	
	
end


function ConsiderTimeWalk()

	-- Make sure it's castable
	if ( abilityTW:IsFullyCastable() == false or mutil.CanNotBeCast(npcBot)  ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityTW:GetSpecialValueInt("blink_range");
	local nCastPoint = abilityTW:GetCastPoint( );

	if mutil.IsStuck(npcBot)
	then
		local loc = mutil.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( loc, nCastRange );
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		if mutil.ShouldEscape(npcBot)
		then
			local loc = mutil.GetEscapeLoc();
			local location = npcBot:GetXUnitsTowardsLocation( loc, nCastRange );
			return BOT_ACTION_DESIRE_MODERATE, location;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and not mutil.IsInRange(npcTarget, npcBot, 2*npcBot:GetAttackRange()) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)  
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
			if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes < 2 then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( 1.5*nCastPoint );
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end




function ConsiderBlinkFragment()

	-- Make sure it's castable
	if ( abilityBF:IsFullyCastable() == false or mutil.CanNotBeCast(npcBot) or npcBot:HasScepter() == false  ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityTW:GetSpecialValueInt("blink_range");
	local nCastPoint = abilityBF:GetCastPoint( );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	-- if mutil.IsStuck(npcBot)
	-- then
		-- local loc = mutil.GetEscapeLoc();
		-- return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( loc, nCastRange );
	-- end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nCastRange/2, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget)
		-- and not mutil.IsInRange(npcTarget, npcBot, 2*npcBot:GetAttackRange()) 
		and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)  
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
			-- if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes < 2 then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
			end
		-- end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
		local enemyCreeps = bot:GetNearbyLaneCreeps(1600, true);
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 2 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive()  and #tableNearbyEnemyHeroes == 0 
					then 
					return BOT_ACTION_DESIRE_MODERATE,neutral:GetLocation();
				else 
			if enemyCreeps ~= nil and #enemyCreeps >= 2 then
					for _,creep in pairs(enemyCreeps)
				do
					if creep:CanBeSeen() and creep:IsAlive() and #tableNearbyEnemyHeroes == 0
					then 
					return BOT_ACTION_DESIRE_MODERATE,creep:GetLocation();
				end
			end
		end
	end
	end
	end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderCounterSpell()

	-- Make sure it's castable
	if ( abilityCS:IsFullyCastable() == false or mutil.CanNotBeCast(npcBot) ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local incProj = npcBot:GetIncomingTrackingProjectiles()
		for _,p in pairs(incProj)
		do
			if GetUnitToLocationDistance(npcBot, p.location) <= 300 and p.is_attack == false then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	
	
	
	if mutil.IsRetreating(npcBot) 
	then
	if mutil.ShouldEscape(npcBot) then
	
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE )
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1  ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 300)  )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 450, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 ) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 600)  
		then
			local incProj = npcBot:GetIncomingTrackingProjectiles()
			for _,p in pairs(incProj)
			do
				if GetUnitToLocationDistance(npcBot, p.location) <= 300 and p.is_attack == false then
					return BOT_ACTION_DESIRE_HIGH;
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderCorrosiveHaze()

	-- Make sure it's castable
	if ( not abilityCH:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityCH:GetCastRange();
	local nDamagaPerHealth = abilityCH:GetSpecialValueFloat("mana_void_damage_per_mana");

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnTargetAdvanced(npcTarget)
		then
			local EstDamage = nDamagaPerHealth * ( npcTarget:GetMaxMana() - npcTarget:GetMana() )
			local TPerMana = npcTarget:GetMana()/npcTarget:GetMaxMana();
			if mutil.CanKillTarget(npcTarget, EstDamage, DAMAGE_TYPE_MAGICAL) or TPerMana < 0.01
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	

	-- If we're in a teamfight, use it on the scariest enemy
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local npcToKill = nil;
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			local EstDamage = nDamagaPerHealth * ( npcEnemy:GetMaxMana() - npcEnemy:GetMana() )
			local TPerMana = npcEnemy:GetMana()/npcEnemy:GetMaxMana();
			if mutil.IsValidTarget(npcEnemy) and mutil.CanCastOnTargetAdvanced(npcEnemy) and mutil.IsInRange(npcEnemy, npcBot, nCastRange+200) and
			   ( mutil.CanKillTarget(npcEnemy, EstDamage, DAMAGE_TYPE_MAGICAL) or TPerMana < 0.01 ) 
			then
				npcToKill = npcEnemy;
			end
		end

		if ( npcToKill ~= nil  )
		then
			return BOT_ACTION_DESIRE_HIGH, npcToKill;
		end
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		local EstDamage = nDamagaPerHealth * ( npcEnemy:GetMaxMana() - npcEnemy:GetMana() )
		local TPerMana = npcEnemy:GetMana()/npcEnemy:GetMaxMana();
		if mutil.IsValidTarget(npcEnemy) and mutil.CanCastOnTargetAdvanced(npcEnemy) and mutil.IsInRange(npcEnemy, npcBot, nCastRange+200) and
		   ( mutil.CanKillTarget(npcEnemy, EstDamage, DAMAGE_TYPE_MAGICAL) or TPerMana < 0.01 or npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end
