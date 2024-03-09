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

local castGSDesire = 0;
local castSCDesire = 0;
local castCHDesire = 0;

local abilityGS = nil;
local abilitySC = nil;
local abilityCH = nil;

-- local npcBot = nil;
local npcBot = GetBot();
local bot = GetBot();


function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	-- ability_item_usage_generic.SwapItemsTest()
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();

	if abilityGS == nil then abilityGS = npcBot:GetAbilityByName( "necrolyte_sadist" ) end
	if abilitySC == nil then abilitySC = npcBot:GetAbilityByName( "necrolyte_death_pulse" ) end
	if abilityCH == nil then abilityCH = npcBot:GetAbilityByName( "necrolyte_reapers_scythe" ) end

	-- Consider using each ability
	castGSDesire = ConsiderGuardianSprint();
	castSCDesire = ConsiderSlithereenCrush();
	castCHDesire, castCHTarget = ConsiderCorrosiveHaze();
	
	
	

	if ( castCHDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityCH, castCHTarget );
		return;
	end

	if ( castSCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySC );
		return;
	end
	
	if ( castGSDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityGS );
		return;
	end

end






function ConsiderGuardianSprint()

	-- Make sure it's castable
	if ( not abilityGS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilityGS:GetSpecialValueInt( "slow_aoe" );
	local nManaCost    = abilityGS:GetManaCost( );
	local nDamage = abilitySC:GetAbilityDamage();
	
	local SadStack = 0;
	local npcModifier = npcBot:NumModifiers();
	
	for i = 0, npcModifier 
	do
		if npcBot:GetModifierName(i) == "modifier_necrolyte_death_pulse_counter" then
			SadStack = npcBot:GetModifierStackCount(i);
			break;
		end
	end
	----------------------------------------------------------------
	if SadStack >= 8 and npcBot:GetHealth() / npcBot:GetMaxHealth() < 0.5 then
		return BOT_ACTION_DESIRE_LOW;
	end
	-------------------------------------------------------------
	
	if abilityGS:IsFullyCastable() and npcBot:GetMana() - nManaCost <= abilitySC:GetManaCost() + 50 then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	if abilityGS:IsFullyCastable() and npcBot:GetMana() - nManaCost <= abilityCH:GetManaCost() + 50 then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	------------------------------------------------------------
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if npcBot:WasRecentlyDamagedByAnyHero( 2.0 ) and #tableNearbyEnemyHeroes > 0  
		then
			local cpos = utils.GetTowardsFountainLocation( npcBot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	-- if npcBot:GetActiveMode() == BOT_MODE_LANING  or  mutil.IsPushing(npcBot) or  mutil.IsDefending(npcBot) 
	-- then
	   
	
		-- local laneCreeps = npcBot:GetNearbyLaneCreeps(nRadius -250, true);
		-- for _,creep in pairs(laneCreeps)
		-- do
			-- if creep:GetHealth() <= nDamage then
				-- return BOT_ACTION_DESIRE_HIGH;
		    -- end
        -- end
	-- end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius -250, true, BOT_MODE_NONE );
		local tableNearbyAlliesHeroes = npcBot:GetNearbyHeroes( nRadius - 250, false, BOT_MODE_NONE );
		local lowHPAllies = 0;
		for _,ally in pairs(tableNearbyAlliesHeroes)
		do
			local allyHealth = ally:GetHealth() / ally:GetMaxHealth();
			if allyHealth < 0.5 then
				lowHPAllies = lowHPAllies + 1;
			end
		end
		
		if #tableNearbyEnemyHeroes >= 2 or lowHPAllies >= 1 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nRadius-250, true );
		if #tableNearbyEnemyCreeps >= 3  then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius - 250)
		then
			local targetAllies = npcTarget:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
			if #targetAllies == 1 then 
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderSlithereenCrush()

	-- Make sure it's castable
	if ( not abilitySC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilitySC:GetSpecialValueInt( "area_of_effect" );
	local nCastRange = 0;
	local nDamage = abilitySC:GetAbilityDamage();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local currHealthP = npcBot:GetHealth() / npcBot:GetMaxHealth();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 2*nRadius, true, BOT_MODE_NONE );
		if npcBot:WasRecentlyDamagedByAnyHero( 2.0 ) and #tableNearbyEnemyHeroes > 0  
		then
			local cpos = utils.GetTowardsFountainLocation( npcBot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
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
	
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nRadius, true );
		if #tableNearbyEnemyCreeps >= 3 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.65 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	
	-- if npcBot:GetActiveMode() == BOT_MODE_LANING  or  mutil.IsPushing(npcBot) or  mutil.IsDefending(npcBot) and currManaP > 0.60
	-- then
	   
	
		-- local laneCreeps = npcBot:GetNearbyLaneCreeps(250, true);
		-- for _,creep in pairs(laneCreeps)
		-- do
			-- if creep:GetHealth() <= nDamage then
				-- return BOT_ACTION_DESIRE_HIGH;
		    -- end
        -- end
	-- end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and currHealthP < 0.50 and currManaP > 0.45
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW;
		end
	end	
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		local tableNearbyAlliesHeroes = npcBot:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
		local lowHPAllies = 0;
		for _,ally in pairs(tableNearbyAlliesHeroes)
		do
			local allyHealth = ally:GetHealth() / ally:GetMaxHealth();
			if allyHealth < 0.5 then
				lowHPAllies = lowHPAllies + 1;
			end
		end
		
		if #tableNearbyEnemyHeroes >= 2 or lowHPAllies >= 1 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();

		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end


	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderCorrosiveHaze()

	-- Make sure it's castable
	if ( not abilityCH:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityCH:GetCastRange();
	local nDamagaPerHealth = abilityCH:GetSpecialValueFloat("damage_per_health");

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200)
		then
			local EstDamage = nDamagaPerHealth * ( npcTarget:GetMaxHealth() - npcTarget:GetHealth() )
			if mutil.CanKillTarget(npcTarget, EstDamage, DAMAGE_TYPE_MAGICAL ) or npcTarget:IsChanneling() and not npcTarget:IsIllusion() and not npcTarget:HasModifier("modifier_oracle_false_promise")
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	

	-- If we're in a teamfight, use it on the scariest enemy
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local npcToKill = nil;
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			local EstDamage = nDamagaPerHealth * ( npcEnemy:GetMaxHealth() - npcEnemy:GetHealth() )
			if mutil.CanCastOnNonMagicImmune(npcEnemy) and mutil.CanKillTarget(npcEnemy, EstDamage, DAMAGE_TYPE_MAGICAL ) and not npcEnemy:IsIllusion()  and not npcEnemy:HasModifier("modifier_oracle_false_promise")
			then
				npcToKill = npcEnemy;
			end
		end
		if ( npcToKill ~= nil  )
		then
			return BOT_ACTION_DESIRE_HIGH, npcToKill;
		end
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		local EstDamage = nDamagaPerHealth * ( npcEnemy:GetMaxHealth() - npcEnemy:GetHealth() )
		if mutil.CanCastOnNonMagicImmune(npcEnemy) and mutil.CanKillTarget(npcEnemy, EstDamage, DAMAGE_TYPE_MAGICAL )
		and not npcEnemy:IsIllusion() and not npcEnemy:HasModifier("modifier_oracle_false_promise")
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end
