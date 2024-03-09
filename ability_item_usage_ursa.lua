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

local castESDesire = 0;
local castOPDesire = 0;
local castERDesire = 0;

local abilityES = nil;
local abilityOP = nil;
local abilityER = nil;

-- local npcBot = nil;
local npcBot = GetBot();
local bot = GetBot();

function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	

	if abilityES == nil then abilityES = npcBot:GetAbilityByName( "ursa_earthshock" ) end
	if abilityOP == nil then abilityOP = npcBot:GetAbilityByName( "ursa_overpower" ) end
	if abilityER == nil then abilityER = npcBot:GetAbilityByName( "ursa_enrage" ) end
	
	-- Consider using each ability
	castESDesire = ConsiderEarthshock();
	castOPDesire = ConsiderOverpower();
	castERDesire = ConsiderEnrage();
	

	
	if ( castERDesire > castESDesire and castERDesire > castESDesire ) 
	then
		npcBot:Action_UseAbility( abilityER );
		return;
	end

	if ( castESDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityES );
		return;
	end
	
	if ( castOPDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityOP );
		return;
	end

end

function ConsiderEarthshock()

	-- Make sure it's castable
	if ( not abilityES:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius = abilityES:GetSpecialValueInt( "shock_radius" );
	local nCastRange = 0;
	local nDamage = abilityES:GetAbilityDamage();
	local nManaCost = abilityES:GetManaCost();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 2*nRadius, true, BOT_MODE_NONE );
		if ( #tableNearbyEnemyHeroes > 0 and ( npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0) ) ) 
		then
			local loc = mutil.GetEscapeLoc();
			if utils.IsFacingLocation(npcBot,loc,15) then
				local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 ) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nRadius, true);
		
		if ( lanecreeps~= nil and #lanecreeps >= 4  ) 
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
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end


function ConsiderOverpower()

	-- Make sure it's castable
	if ( not abilityOP:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're pushing a lane 
	if mutil.IsPushing(npcBot) and npcBot:GetMana() / npcBot:GetMaxMana() >= 0.65 
	then
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 800, true );
		local lanecreeps = npcBot:GetNearbyLaneCreeps(800, true);
		if (tableNearbyEnemyTowers ~= nil and #tableNearbyEnemyTowers >= 1 and tableNearbyEnemyTowers[1] ~= nil and
		   mutil.IsInRange(tableNearbyEnemyTowers[1], npcBot, 300)) or (lanecreeps~= nil and #lanecreeps >= 4)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if  npcBot:GetActiveMode() == BOT_MODE_FARM 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil then
			return BOT_ACTION_DESIRE_LOW;
		end
	end	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 300)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 400) 
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderEnrage()

	-- Make sure it's castable
	if ( not abilityER:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and bot:HasModifier('modifier_ursa_enrage') == false
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if  npcBot:GetActiveMode() == BOT_MODE_FARM and bot:HasModifier('modifier_ursa_enrage') == false
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil then
			return BOT_ACTION_DESIRE_LOW;
		end
	end	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  )  and bot:HasModifier('modifier_ursa_enrage') == false
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 300)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.65 and bot:HasModifier('modifier_ursa_enrage') == false
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 300) 
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end
