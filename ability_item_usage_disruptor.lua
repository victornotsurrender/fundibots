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

local castSSDesire = 0;
local castTSDesire = 0;
local castGMDesire = 0;
local castKFDesire = 0;

local abilityTS = nil;
local abilityGM = nil;
local abilitySS = nil;
local abilityKF = nil;

local bot = GetBot();
local npcBot = GetBot();

function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();

	if abilityTS == nil then abilityTS = npcBot:GetAbilityByName( "disruptor_thunder_strike" ) end
	if abilityGM == nil then abilityGM = npcBot:GetAbilityByName( "disruptor_glimpse" ) end
	if abilitySS == nil then abilitySS = npcBot:GetAbilityByName( "disruptor_static_storm" ) end
	if abilityKF == nil then abilityKF = npcBot:GetAbilityByName( "disruptor_kinetic_field" ) end
	

	-- Consider using each ability
	castSSDesire, castSSLocation = ConsiderStaticStorm();
	castKFDesire, castKFLocation = ConsiderKineticField();
	castTSDesire, castTSTarget = ConsiderThunderStorm();
	castGMDesire, castGMTarget = ConsiderGlimpse();
	
	
	
	if ( castTSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityTS, castTSTarget );
		return;
	end
	
	if ( castKFDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityKF, castKFLocation );
		return;
	end
	
	if ( castSSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilitySS, castSSLocation );
		return;
	end
	
	if ( castGMDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityGM, castGMTarget );
		return;
	end
end

function ConsiderThunderStorm()

	-- Make sure it's castable
	if ( not abilityTS:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityTS:GetCastRange();
	local nDamage = 4 * abilityTS:GetAbilityDamage( );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nManaCost  = abilityTS:GetManaCost();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and 
	   mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) and mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL)
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
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and  tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					then 
					return BOT_ACTION_DESIRE_MODERATE,neutral;
				end
			end
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	-- -- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	-- if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING
	-- then
		-- local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nCastRange, true );
		-- for _,npcCreepTarget in pairs(tableNearbyEnemyCreeps) do
			-- if ( mutil.IsInRange(npcTarget, npcBot, nCastRange) and npcBot:GetMana()/npcBot:GetMaxMana() > 0.6 ) 
			-- then
				-- return BOT_ACTION_DESIRE_MODERATE, npcCreepTarget;
			-- end
		-- end
	-- end
	
	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
	   local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
		local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy)
			and npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.80 ) and #tableNearbyAlliedHeroes >=1
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		
	end
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderGlimpse()

	-- Make sure it's castable
	if ( not abilityGM:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityGM:GetCastRange();
	if nCastRange > 1600 then
		nCastRange = 1600;
	end
	-- local nManaCost  = abilities[3]:GetManaCost();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	-- -- If we're going after someone
	-- if mutil.IsGoingOnSomeone(npcBot)
	-- then
		-- local npcTarget = npcBot:GetTarget();
		-- if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) 
		   -- and not mutil.IsInRange(npcTarget, npcBot, nCastRange/2) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		-- then
			-- return BOT_ACTION_DESIRE_HIGH, npcTarget;
		-- end
	-- end
	
	if mutil.IsInTeamFight(npcBot, 1200) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnMagicImmune(npcEnemy) and not mutil.IsSuspiciousIllusion(npcEnemy)) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end 
	
	
	
	
	
	
	
	
	
	
	
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderStaticStorm()

	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilitySS:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nRadius = abilitySS:GetSpecialValueInt( "radius" );
	local nCastRange = abilitySS:GetCastRange();
	local nCastPoint = abilitySS:GetCastPoint( );
	local nDamage = 5 * abilitySS:GetSpecialValueInt("damage_max");
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
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
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if  locationAoE.count >= 2  then
			local nInvUnit = mutil.FindNumInvUnitInLoc(false, npcBot, nCastRange, nRadius/2, locationAoE.targetloc);
			if nInvUnit >= locationAoE.count then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local EnemyHeroes = npcTarget:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			local nInvUnit = mutil.CountInvUnits(false, EnemyHeroes);
			if nInvUnit >= 2 then
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
			end
		end
	end
	
	
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING)  and currManaP > 0.45
	or mutil.IsRetreating(npcBot)   
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(1400, true, BOT_MODE_NONE);
		local allies = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE);
		local Atowers = npcBot:GetNearbyTowers(1400, false);
		
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  mutil.CanCastOnNonMagicImmune(npcEnemy)
			then	
		for _,u in pairs(Atowers) do
			if GetUnitToLocationDistance(bot,u:GetLocation()) <= 700 and GetUnitToLocationDistance(npcEnemy,u:GetLocation()) <= 700
				then
			if #allies >= 0 then
				
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation( nCastPoint );
				end
			end
		end
	end
	end
	end
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange+200, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderKineticField()

	-- Make sure it's castable
	if ( not abilityKF:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityKF:GetSpecialValueInt( "radius" );
	local nCastRange = abilityKF:GetCastRange();
	local nCastPoint = abilityKF:GetCastPoint( );
	local nDamage = 1000
	local speed    	 = 1000
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING) and currManaP > 0.45
	or mutil.IsRetreating(npcBot)   
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(1400, true, BOT_MODE_NONE);
		local allies = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE);
		local Atowers = npcBot:GetNearbyTowers(1400, false);
		
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  mutil.CanCastOnNonMagicImmune(npcEnemy)
			then	
		for _,u in pairs(Atowers) do
			if GetUnitToLocationDistance(bot,u:GetLocation()) <= 700 and GetUnitToLocationDistance(npcEnemy,u:GetLocation()) <= 700
				then
			if #allies >= 0 then
					local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					
					return BOT_ACTION_DESIRE_MODERATE,npcEnemy:GetLocation();
				end
			end
		end
	end
	end
	end
	-- end

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, npcBot:GetLocation();
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if locationAoE.count >= 2 then
			local nInvUnit = mutil.FindNumInvUnitInLoc(false, npcBot, nCastRange, nRadius/2, locationAoE.targetloc);
			if nInvUnit >= locationAoE.count then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) 
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange+200, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end
