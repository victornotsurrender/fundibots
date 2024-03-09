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

local castCDDesire = 0;
local castEHDesire = 0;
local castNSDesire = 0;

local abilityCD = nil;
local abilityEH = nil;
local abilityNS = nil;

local bot = GetBot();
local npcBot = GetBot();

function AbilityUsageThink()


	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	

	-- Check if we're already using an ability
	if npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness") then
		npcBot:Action_ClearActions(false);
		return
	end
	
	if ( npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness") or mutil.CanNotUseAbility(npcBot) or npcBot:NumQueuedActions() > 0 ) then return end;

	if abilityCD == nil then abilityCD = npcBot:GetAbilityByName( "spirit_breaker_charge_of_darkness" ) end
	if abilityEH == nil then abilityEH = npcBot:GetAbilityByName( "spirit_breaker_bulldoze" ) end
	if abilityNS == nil then abilityNS = npcBot:GetAbilityByName( "spirit_breaker_nether_strike" ) end

	castEHDesire = ConsiderEmpoweringHaste();
	castCDDesire, castCDTarget = ConsiderCharge();
	castNSDesire, castNSTarget = ConsiderNetherStrike();
	
	
	
	if abilityCD:GetCooldownTimeRemaining() > 0 and npcBot.chargeTarget ~= nil 
	then npcBot.chargeTarget = nil end
	
	if ( castNSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityNS, castNSTarget );
		return;
	end

	if ( castEHDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityEH );
		return;
	end
	
	if ( castCDDesire > 0 ) 
	then
		npcBot:Action_ClearActions(true);
		npcBot.chargeTarget = castCDTarget;
		npcBot:ActionQueue_UseAbilityOnEntity( abilityCD, castCDTarget );
		npcBot:ActionQueue_Delay( 1.0 );
		return;
	end
	
end


function ConsiderEmpoweringHaste()

	-- Make sure it's castable
	if ( not abilityEH:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local AttackRange = npcBot:GetAttackRange();
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		if ( npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0) or ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1  ) )
		then
			local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot,350)  )
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
	
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		local dist = GetUnitToUnitDistance( npcBot, npcTarget );
		if  mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 2*AttackRange)
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderCharge()

	-- Make sure it's castable
	if ( not abilityCD:IsFullyCastable() or npcBot:IsRooted() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	-- if bot:GetLastHits() < 20 then 
		-- return BOT_ACTION_DESIRE_NONE, 0;
	-- end
	-- Get some of its values
	local nCastRange = npcBot:GetAttackRange() + 150;
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	if mutil.IsRetreating(npcBot) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local enemyCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS );
		for _,creep in pairs(enemyCreeps) 
		do
			if GetUnitToUnitDistance(creep, npcBot) > 2500 and mutil.CanCastOnNonMagicImmune(creep) then
				return BOT_ACTION_DESIRE_MODERATE, creep;
			end
		end
	end
	
	if mutil.IsStuck (npcBot)
	then
		local enemyCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS );
		for _,creep in pairs(enemyCreeps) 
		do
			if GetUnitToUnitDistance(creep, npcBot) > 2500 and mutil.CanCastOnNonMagicImmune(creep) then
			
				return BOT_ACTION_DESIRE_ABSOLUTE, creep;
			end
		end
	end
	
	
	if npcBot:DistanceFromFountain() < 800 and npcBot:GetHealth()/npcBot:GetMaxHealth() > 0.90
	then
		
		local enemyCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS );
		for _,creep in pairs(enemyCreeps) 
		do
			if GetUnitToUnitDistance(creep, npcBot) > 2500 and mutil.CanCastOnNonMagicImmune(creep) then
				return BOT_ACTION_DESIRE_MODERATE, creep;
			end
		end
	end
	
	
	
		if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING)  and currManaP > 0.45
	or (mutil.IsRetreating(npcBot) and bot:GetHealth() > 0.35*bot:GetMaxHealth()  )   
	then
		local tableNearbyEnemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES );
		local allies = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE);
		local Atowers = npcBot:GetNearbyTowers(nCastRange, false);
		
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  mutil.CanCastOnNonMagicImmune(npcEnemy)
			then	
		for _,u in pairs(Atowers) do
			if  GetUnitToLocationDistance(npcEnemy,u:GetLocation()) <= 500
				then
			if #allies >= 0 then
				
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
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
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and
			not mutil.IsDisabled(true, npcTarget) ) 
		then
			local Ally = npcTarget:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
			local Enemy = npcTarget:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
			if ( #Ally + 1 >= #Enemy  ) or npcTarget:GetHealth() <= ( 100 + (5*npcBot:GetLevel()) ) then
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end	
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderNetherStrike()

	-- Make sure it's castable
	if ( not abilityNS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityNS:GetCastRange();
	local nDamage = abilityNS:GetAbilityDamage();
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if mutil.CanCastOnMagicImmune(npcEnemy) and ( npcEnemy:IsChanneling() or mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL ) )
		then
			local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		and mutil.IsDisabled(true, npcTarget))
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) and
			not mutil.IsDisabled(true, npcTarget) ) 
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end
