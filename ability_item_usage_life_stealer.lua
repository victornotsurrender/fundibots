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

local castRGDesire = 0;
local castOWDesire = 0;
local castINDesire = 0;
local castCODesire = 0;

local abilityRG = nil;
local abilityOW = nil;
local abilityIN = nil;
local abilityCO = nil;

-- local npcBot = nil;
local bot = GetBot();
local npcBot = GetBot();


function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	
	if abilityRG == nil then abilityRG = npcBot:GetAbilityByName( "life_stealer_rage" ) end
	if abilityOW == nil then abilityOW = npcBot:GetAbilityByName( "life_stealer_open_wounds" ) end
	if abilityIN == nil then abilityIN = npcBot:GetAbilityByName( "life_stealer_infest" ) end
	if abilityCO == nil then abilityCO = npcBot:GetAbilityByName( "life_stealer_consume" ) end
	
	castCODesire = ConsiderConsume();
	
	if ( castCODesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityCO );
		return;
	end
	
	
	-- Consider using each ability
	castRGDesire = ConsiderRage();
	castOWDesire, castOWTarget = ConsiderOpenWounds();
	castINDesire, castINTarget = ConsiderInfest();
	
	-- ability_item_usage_generic.SwapItemsTest()
	
	if ( castRGDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityRG );
		return;
	end


	if ( castOWDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityOW, castOWTarget );
		return;
	end
	
	if ( castINDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityIN, castINTarget );
		return;
	end

end

function ConsiderRage()

	-- Make sure it's castable
	if ( not abilityRG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsUsingAbility() )  
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) or npcEnemy:IsUsingAbility() or npcBot:GetHealth()/npcBot:GetMaxHealth() <= 0.15 ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	if ( npcBot:GetActiveMode() == BOT_MODE_FARM and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.65  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil 
		then
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
		if mutil.IsValidTarget(npcTarget) 
		then
			local tDist =  GetUnitToUnitDistance( npcBot, npcTarget );
			local eHeroesCastSpell = false;
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( npcEnemy:IsUsingAbility() ) 
				then
					eHeroesCastSpell = true;
				end
			end
			if ( tDist < 300 or ( tDist < 500 and ( eHeroesCastSpell or npcTarget:IsUsingAbility() ) ) )
			then
				return BOT_ACTION_DESIRE_ABSOLUTE;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end


function ConsiderOpenWounds()

	-- Make sure it's castable
	if ( not abilityOW:IsFullyCastable() or abilityOW:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if ( castRGDesire > 0 ) then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityOW:GetCastRange();
	
	
	
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING)  
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
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
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
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.65  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsAncientCreep() 
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
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
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) and
			not mutil.IsDisabled(true, npcTarget)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderInfest()

	-- Make sure it's castable
	if ( not abilityIN:IsFullyCastable() or abilityIN:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if ( castRGDesire > 0 ) then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityIN:GetCastRange();
	local nDamage = abilityIN:GetSpecialValueInt("damage");
	local nRadius = abilityIN:GetSpecialValueInt("radius");
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 ) 
		then
				local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
				local tableNearbyAlliedCreeps = npcBot:GetNearbyLaneCreeps ( 800, false );
				local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps ( 800, true );
				for _,npcAllied in pairs( tableNearbyAlliedHeroes  )
				do
					if ( npcAllied:GetUnitName() ~= npcBot:GetUnitName() and mutil.CanCastOnNonMagicImmune(npcAllied) and mutil.IsInRange(npcAllied, npcBot, 3*nCastRange) ) 
					then
						return BOT_ACTION_DESIRE_HIGH, npcAllied;
					end
				end
			
				for _,npcACreep in pairs( tableNearbyAlliedCreeps  )
				do
					if mutil.CanCastOnNonMagicImmune(npcACreep) and mutil.IsInRange(npcACreep, npcBot, 3*nCastRange)
					then
						return BOT_ACTION_DESIRE_HIGH, npcACreep;
					end
				end
		
				for _,npcECreep in pairs( tableNearbyEnemyCreeps  )
				do
					if mutil.CanCastOnNonMagicImmune(npcECreep) and mutil.IsInRange(npcECreep, npcBot, 3*nCastRange)
					then
						return BOT_ACTION_DESIRE_HIGH, npcECreep;
					end
				end
		end
	end

	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and mutil.IsInRange(npcTarget, npcBot, nRadius-200)
	then
		local tableNearbyAlliedCreeps = npcBot:GetNearbyLaneCreeps ( 800, false );
			local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps ( 800, true );
		for _,npcACreep in pairs( tableNearbyAlliedCreeps  )
		do
			if mutil.CanCastOnNonMagicImmune(npcACreep) and mutil.IsInRange(npcACreep, npcTarget, nRadius-200)
			then
				return BOT_ACTION_DESIRE_HIGH, npcACreep;
			end
		end
		for _,npcECreep in pairs( tableNearbyEnemyCreeps  )
		do
			if mutil.CanCastOnNonMagicImmune(npcECreep) and mutil.IsInRange(npcECreep, npcTarget, nRadius-200)
			then
				return BOT_ACTION_DESIRE_HIGH, npcECreep;
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot) 
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and not mutil.IsInRange(npcTarget, npcBot,2000)
		then
			local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
			local target = nil;
			for _,npcAllied in pairs( tableNearbyAlliedHeroes  )
			do
				if ( npcAllied:GetUnitName() ~= npcBot:GetUnitName() and npcAllied:GetAttackRange() < 320 ) 
				then
					target = npcAllied;
				end
			end
			if target ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, target;
			end
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderConsume()
	
	-- Make sure it's castable
	if ( not abilityCO:IsFullyCastable() or abilityCO:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	local nDamage = abilityIN:GetSpecialValueInt("damage");
	local nRadius = abilityIN:GetSpecialValueInt("radius");
	local currHealthP = npcBot:GetHealth() / npcBot:GetMaxHealth();
	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes == nil or #tableNearbyEnemyHeroes == 0 or abilityRG:IsFullyCastable() ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius-200, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE;
		end
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius-200) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE;
		end
	end
	
	if currHealthP > 0.85 then 
		return BOT_ACTION_DESIRE_LOW; 
	end
	
	
	
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius-200, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 ) and currHealthP > 0.85
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	

	return BOT_ACTION_DESIRE_NONE;

end


