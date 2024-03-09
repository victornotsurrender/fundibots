if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end


local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
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

local castDCDesire = 0;
local castBLDesire = 0;
local castSCDesire = 0;
local castTWDesire = 0;

local abilityDC = nil;
local abilityBL = nil;
local abilityTW = nil;
local abilitySC = nil;

-- local npcBot = nil;
local bot = GetBot();
local npcBot = GetBot();

function IsEnemyHerosNearby(location, radius)
	local units = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,u in pairs(units) do
		if u ~= nil  and GetUnitToLocationDistance(u, location) < radius then
			return true;
		end
	end
	return false;
end 

function IsEnemyHerosInPath(location, dist)
	-- if npcBot:IsFacingLocation(location, 5) then
	if npcBot:IsFacingUnit(GetAncient(GetTeam()), 10) then
		local units = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,u in pairs(units) do
			if u ~= nil
			   and npcBot:IsFacingLocation(u:GetLocation(), 10) and GetUnitToUnitDistance(u, npcBot) < dist 
			then
				return true;
			end
		end
	end
	return false;
end

function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	if abilityDC == nil then abilityDC = npcBot:GetAbilityByName( "magnataur_shockwave" ) end
	if abilityBL == nil then abilityBL = npcBot:GetAbilityByName( "magnataur_empower" ) end
	if abilityTW == nil then abilityTW = npcBot:GetAbilityByName( "magnataur_skewer" ) end
	if abilitySC == nil then abilitySC = npcBot:GetAbilityByName( "magnataur_reverse_polarity" ) end
	
	-- Consider using each ability
	castDCDesire, castDCLocation = ConsiderDecay();
	castBLDesire, castBLTarget = ConsiderBloodlust();
	castTWDesire, castTWLocation = ConsiderTimeWalk();
	castSCDesire = ConsiderSlithereenCrush();
	
	-- ability_item_usage_generic.SwapItemsTest()
	
	if ( castSCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySC );
		return;
	end
	if ( castDCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityDC, castDCLocation );
		return;
	end
	if ( castTWDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTW, castTWLocation );
		return;
	end	
	if ( castBLDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityBL, castBLTarget );
		return;
	end
	
end

function ConsiderDecay()

	-- Make sure it's castable
	if ( not abilityDC:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nRadius = abilityDC:GetSpecialValueInt( "radius" );
	local nCastRange = abilityDC:GetCastRange();
	local nCastPoint = abilityDC:GetCastPoint( );
	local nDamage = abilityDC:GetSpecialValueInt("shock_damage");
	local nSpeed = abilityDC:GetSpecialValueInt("shock_speed");
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();

	if npcBot:GetLevel() >= 20 then nCastRange = 1600 end

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
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
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and currManaP > 0.45
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_LANING  or  mutil.IsPushing(npcBot) or  mutil.IsDefending(npcBot) and currManaP > 0.80
	then
	   
	
		local laneCreeps = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		for _,creep in pairs(laneCreeps)
		do
			if creep:GetHealth() <= nDamage then
				return BOT_ACTION_DESIRE_HIGH, creep:GetLocation ();
		    end
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
	
	
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) ) and npcBot:GetMana() / npcBot:GetMaxMana() > 0.6
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if (  locationAoE.count >= 4 and #lanecreeps >= 4   ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-200) ) 
		and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation((GetUnitToUnitDistance(npcTarget, npcBot)/nSpeed)+nCastPoint);
		end
	end
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderBloodlust()

	-- Make sure it's castable
	if ( not abilityBL:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityBL:GetCastRange();
	if nCastRange > 1600 then nCastRange = 1600; end
	-- If we're pushing or defending a lane
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING and npcBot:GetMana() / npcBot:GetMaxMana() > 0.6
	then
		if not npcBot:HasModifier("modifier_magnataur_empower") then
			return BOT_ACTION_DESIRE_MODERATE, npcBot;
		end
		local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, false, BOT_MODE_NONE );
		for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
			if ( not myFriend:HasModifier("modifier_magnataur_empower") ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, myFriend;
			end
		end	
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and  not npcBot:HasModifier("modifier_magnataur_empower") 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange/2 );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					then 
					return BOT_ACTION_DESIRE_MODERATE,npcBot;
				end
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcBot;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if not npcBot:HasModifier("modifier_magnataur_empower") then
			return BOT_ACTION_DESIRE_MODERATE, npcBot;
		end
		local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, false, BOT_MODE_NONE );
		for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
			if ( not myFriend:HasModifier("modifier_magnataur_empower") ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, myFriend;
			end
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
	local nCastRange = abilityTW:GetSpecialValueInt("range");
	local nSpeed = abilityTW:GetSpecialValueInt("skewer_speed");
	local nCastPoint = abilityTW:GetCastPoint( );
	local nRadius = abilityTW:GetSpecialValueInt("skewer_radius");
	if nCastRange > 1600 then nCastRange = 1600; end
	
	-------------------------------------------------
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
		then
			local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
		end
	end
	
	if mutil.IsStuck(npcBot)
	then
		local loc = mutil.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( loc, nCastRange );
	end
	
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local loc = mutil.GetEscapeLoc();
				local cpos = utils.GetTowardsFountainLocation( bot:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( loc, nCastRange );
			end
		end
	end
	
	 
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-200) 
		then
			local SkewerEnemyHerosNearby = IsEnemyHerosNearby(npcBot:GetLocation(), nRadius);
			local SkewerEnemyHerosInPath  = IsEnemyHerosInPath (npcBot:GetLocation(),nCastRange)
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
			
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do		
		if mutil.CanCastOnNonMagicImmune(npcEnemy) and mutil.IsInRange(npcEnemy, npcBot, 600) 
			then		
		if SkewerEnemyHerosNearby  or SkewerEnemyHerosInPath 
			then
			local loc = mutil.GetEscapeLoc();
				local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( loc, nCastRange );
			else
				local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation((GetUnitToUnitDistance(npcTarget, npcBot)/nSpeed)+nCastPoint);			
			end
		  end
		end			
	  end
	end
	
	
	
	
		
	
--
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderSlithereenCrush()

	-- Make sure it's castable
	if ( not abilitySC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilitySC:GetSpecialValueInt( "pull_radius" );
	local nCastRange = 0;
	local nDamage = abilitySC:GetSpecialValueInt("polarity_damage");

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and  ( not npcBot:HasModifier("modifier_magnataur_skewer_movement") or not abilityTW:IsInAbilityPhase() )
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius-100, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 800, false, BOT_MODE_ATTACK );
		if #tableNearbyAllyHeroes >= 2 and #tableNearbyEnemyHeroes > 0 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		local nInvUnit = mutil.CountInvUnits(true, tableNearbyEnemyHeroes);
		if nInvUnit >= 2 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget)
		and mutil.IsInRange(npcTarget, npcBot, nRadius-100) and not mutil.IsSuspiciousIllusion(npcTarget) ) 
		and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	

	return BOT_ACTION_DESIRE_NONE;

end

