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



local castGCDesire = 0;
local castSADesire = 0;
local castSFDesire = 0;
local castGKCDesire = 0;
local castSAGDesire = 0;

local abilityGC = nil;
local abilitySA = nil;
local abilitySF = nil;
local abilityGKC = nil;
local abilitySAG = nil;

local abilitySTF = nil;

local npcBot = GetBot();
local bot = GetBot();

function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	
	if abilityGC == nil then abilityGC = npcBot:GetAbilityByName( "visage_grave_chill" ) end
	if abilitySA == nil then abilitySA = npcBot:GetAbilityByName( "visage_soul_assumption" ) end
	if abilitySF == nil then abilitySF = npcBot:GetAbilityByName( "visage_summon_familiars" ) end
	if abilityGKC == nil then abilityGKC = npcBot:GetAbilityByName( "visage_gravekeepers_cloak" ) end
	if abilitySTF == nil then abilitySTF = npcBot:GetAbilityByName( "visage_stone_form_self_cast" ) end
	if abilitySAG == nil then abilitySAG = npcBot:GetAbilityByName( "visage_silent_as_the_grave" ) end
	
	
	-- Consider using each ability
	castGCDesire, castGCTarget = ConsiderGraveChill();
	castSADesire, castSATarget = ConsiderSoulAssumption();
	castSFDesire, castSFTarget = ConsiderSummonFamiliar();
	
	castGKCDesire			   = ConsiderGraveKeepersCloak();
	castSAGDesire			   = ConsiderSilentAsTheGrave();
	
	
	
	if ( castGCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityGC, castGCTarget );
		return;
	end
	
	if ( castSADesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilitySA, castSATarget );
		return;
	end
	
	if ( castSFDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySF );
		return;
	end
	
	if ( castGKCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityGKC );
		return;
	end
	
	if ( castSAGDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySAG );
		return;
	end
	
end


function ConsiderGraveChill()

	-- Make sure it's castable
	if ( not abilityGC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityGC:GetCastRange();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
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
	
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if mutil.CanCastOnNonMagicImmune(npcEnemy) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderSoulAssumption()

	-- Make sure it's castable
	if ( not abilitySA:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local SAStack = 0;
	local npcModifier = npcBot:NumModifiers();
	
	for i = 0, npcModifier 
	do
		if npcBot:GetModifierName(i) == "modifier_visage_soul_assumption" then
			SAStack = npcBot:GetModifierStackCount(i);
			break;
		end
	end
	
	local nCastRange = abilitySA:GetCastRange();
	local nStackLimit = abilitySA:GetSpecialValueInt("stack_limit");
	local nBaseDamage = abilitySA:GetSpecialValueInt("soul_base_damage");
	local nChargeDamage = abilitySA:GetSpecialValueInt("soul_charge_damage");
	local nTotalDamage = nBaseDamage + (SAStack * nChargeDamage);
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If a mode has set a target, and we can kill them, do it
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if mutil.CanKillTarget(npcEnemy, nTotalDamage, DAMAGE_TYPE_MAGICAL ) and mutil.CanCastOnNonMagicImmune(npcEnemy) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) and SAStack == nStackLimit ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if mutil.IsValidTarget(npcEnemy) and mutil.CanCastOnNonMagicImmune(npcEnemy) and SAStack == nStackLimit
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) 
		   and SAStack == nStackLimit
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderSummonFamiliar()

	-- Make sure it's castable
	if ( not abilitySF:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local numFamiliar = 0;
	
	local listFamiliar = GetUnitList(UNIT_LIST_ALLIES);
	for _,unit in pairs(listFamiliar)
	do
		if string.find(unit:GetUnitName(), "npc_dota_visage_familiar") then
			numFamiliar = numFamiliar + 1;
		end
	end
	
	if numFamiliar < 1 then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	return BOT_ACTION_DESIRE_NONE;
end



function ConsiderGraveKeepersCloak()

	-- Make sure it's castable
	if ( not abilityGKC:IsFullyCastable() or bot:HasModifier('modifier_item_aghanims_shard') == false  ) then
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius = abilitySTF:GetSpecialValueInt( "stun_radius" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.45 )
			then
				local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	

	if mutil.IsInTeamFight(npcBot, 1200) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius - 100, true, BOT_MODE_NONE  );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget)
		and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local EnemyHeroes = npcBot:GetNearbyHeroes( nRadius , true, BOT_MODE_NONE );
			if ( mutil.IsInRange(npcTarget, npcBot, nRadius - 100) and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.65 ) or ( EnemyHeroes ~= nil and #EnemyHeroes >= 2 )
			then
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE;

end 









function ConsiderSilentAsTheGrave()

	-- Make sure it's castable
	if ( not abilitySAG:IsFullyCastable() or abilitySAG:IsHidden() or npcBot:HasScepter()== false  ) then
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	-- local nRadius = abilitySTF:GetSpecialValueInt( "stun_radius" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 )  )
			then
			
				local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	

	if mutil.IsInTeamFight(npcBot, 1200) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes(1200, true, BOT_MODE_NONE  );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget)
		-- and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local EnemyHeroes = npcBot:GetNearbyHeroes( 1200 , true, BOT_MODE_NONE );
			if (not  mutil.IsInRange(npcTarget, npcBot, 1200) ) or ( EnemyHeroes ~= nil and #EnemyHeroes >= 2 )
			then
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE;

end 