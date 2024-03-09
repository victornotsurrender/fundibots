if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
local mutil = require("bots/MyUtility")
local mutils = require("bots/MyUtility")
-- local abUtils = require("bots/AbilityItemUsageUtility")

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

local castCH1Desire = 0;
local castTWDesire = 0;

local abilityCH1 = nil;
local abilityTW = nil;

-- local npcBot = nil;
local npcBot = GetBot();
local bot = GetBot();

function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();

	if abilityCH1 == nil then abilityCH1 = npcBot:GetAbilityByName( "phantom_lancer_spirit_lance" ) end
	if abilityTW == nil then abilityTW = npcBot:GetAbilityByName( "phantom_lancer_doppelwalk" ) end
	
	-- Consider using each ability
	castCH1Desire, castCH1Target = ConsiderCorrosiveHaze1();
	castTWDesire, castTWLocation = ConsiderTimeWalk();
	
	

	if ( castCH1Desire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityCH1, castCH1Target );
		return;
	end
	
	if ( castTWDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTW, castTWLocation );
		return;
	end	
	
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

function ConsiderCorrosiveHaze1()

	-- Make sure it's castable
	if ( not abilityCH1:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityCH1:GetCastRange();
	local manaCost  = abilityCH1:GetManaCost();
	local nDamage = abilityCH1:GetSpecialValueInt ("lance_damage")
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	
	if bot:GetActiveMode() == BOT_MODE_LANING and abilityCH1:GetLevel() >= 2 and mutils.CanSpamSpell(bot, manaCost)then
		local target = mutils.GetVulnerableWeakestUnit(false, true, nCastRange, bot);
		if target ~= nil and target:GetHealth() <= nDamage then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
		target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN and mutils.CanSpamSpell(bot, manaCost)  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( mutils.IsRoshan(npcTarget) and mutils.CanCastOnMagicImmune(npcTarget) and mutils.IsInRange(npcTarget, bot, nCastRange) )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	if mutils.IsPushing(bot) and mutils.CanSpamSpell(bot, manaCost)
	then
		local target = mutils.GetVulnerableWeakestUnit(false, true, nCastRange, bot);
		if target ~= nil and target:GetHealth() <= nDamage then
			return BOT_ACTION_DESIRE_LOW, target;
		end
	end
	
	if  mutils.IsDefending(bot) and mutils.CanSpamSpell(bot, manaCost)
	then
		local target = mutils.GetVulnerableWeakestUnit(false, true, nCastRange, bot);
		if target ~= nil  then
			return BOT_ACTION_DESIRE_LOW, target;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end

	-- If we're in a teamfight, use it on the scariest enemy
	if mutil.IsInTeamFight(npcBot, 1200)
	then

		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy ) )
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderTimeWalk()

	-- Make sure it's castable
	if ( not abilityTW:IsFullyCastable() or npcBot:IsRooted() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityTW:GetCastRange();
	local nCastPoint = abilityTW:GetCastPoint( );
	local nDelay = abilityTW:GetSpecialValueFloat("delay");
	
	if mutil.IsStuck(npcBot)
	then
		local loc = mutil.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( loc, nCastRange );
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 3.0 ) ) 
			then
				local cpos = utils.GetTowardsFountainLocation( npcBot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE,  GetTowardsFountainLocation( npcBot:GetLocation(), nCastRange );
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
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint + nDelay);
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE, 0;
end