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

local castESDesire = 0;
local castVODesire = 0;
local castSHDesire = 0;
local castMSWDesire = 0;

local CancelShackleDesire = 0;

local abilityES = nil;
local abilityVO = nil;
local abilitySH = nil;
local abilityMSW = nil;

-- local npcBot = nil;
local bot = GetBot();
local npcBot = GetBot();

function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	if abilityES == nil then abilityES = npcBot:GetAbilityByName( "shadow_shaman_ether_shock" ) end
	if abilityVO == nil then abilityVO = npcBot:GetAbilityByName( "shadow_shaman_voodoo" ) end
	if abilitySH == nil then abilitySH = npcBot:GetAbilityByName( "shadow_shaman_shackles" ) end
	if abilityMSW == nil then abilityMSW = npcBot:GetAbilityByName( "shadow_shaman_mass_serpent_ward" ) end
	
	CancelShackleDesire = ConsiderCancelShackle();
	-- ability_item_usage_generic.SwapItemsTest()
	
	if CancelShackleDesire > 0 then
		--npcBot:Action_MoveToLocation(npcBot:GetLocation()+RandomVector(200))
		--return
	end
	
	

	-- Consider using each ability
	castESDesire, castESTarget = ConsiderEtherShock();
	castVODesire, castVOTarget = ConsiderVoodoo();
	castSHDesire, castSHTarget = ConsiderShackles();
	castMSWDesire, castMSWLocation = ConsiderMassSerpentWards();

	if ( castMSWDesire > castESDesire and castMSWDesire > castVODesire and castMSWDesire > castSHDesire  ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityMSW, castMSWLocation );
		return;
	end

	if ( castESDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityES, castESTarget );
		return;
	end
	
	if ( castVODesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityVO, castVOTarget );
		return;
	end
	
	if ( castSHDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilitySH, castSHTarget );
		return;
	end
	
end

function ConsiderMassSerpentWards()

	-- Make sure it's castable
	if ( not abilityMSW:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityMSW:GetCastRange();
	local nCastPoint = abilityMSW:GetCastPoint();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
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
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end

	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation( nCastPoint );
		end
	end
	
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if  mutil.IsDefending(npcBot) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange+200, 400, 0, 0 );
		if ( locationAoE.count >= 16 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
		end
	end
	
	
	-- If we're going after someone
	if mutils.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if mutils.IsValidTarget(npcTarget) and mutils.CanCastOnNonMagicImmune(npcTarget)
		and mutils.IsInRange(npcTarget, bot, nCastRange) and not mutil.IsSuspiciousIllusion(npcTarget)
		and not mutil.IsDisabled(true, npcTarget)
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderEtherShock()

	-- Make sure it's castable
	if ( not abilityES:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityES:GetCastRange();
	local nDamage = abilityES:GetSpecialValueInt( "damage" );
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
				local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
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
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_MODERATE,npcTarget;
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) ) and ( npcBot:GetMana() - abilityES:GetManaCost() ) / npcBot:GetMaxMana() >= 0.75 - (0.01*npcBot:GetLevel()) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange+200, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 and tableNearbyEnemyCreeps[1] ~= nil 
		then
			return BOT_ACTION_DESIRE_MODERATE,  tableNearbyEnemyCreeps[1];
		end	
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderVoodoo()

	-- Make sure it's castable
	if ( not abilityVO:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityVO:GetCastRange();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nManaCost  = abilitySH:GetManaCost();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
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
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
	end
	end
	end
	
	
	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
	   local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy)
			and npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.80 ) and #tableNearbyAlliedHeroes > #tableNearbyEnemyHeroes
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		
	end
	
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	

	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy)
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) 
		    and not mutil.IsDisabled(true, npcTarget)
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderShackles()

	-- Make sure it's castable
	if ( not abilitySH:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilitySH:GetCastRange();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nManaCost  = abilitySH:GetManaCost();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING)  
	-- and currManaP > 0.45
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
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
	end
	end
	end
	
	
	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
	   local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy)
			and npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.80 ) and #tableNearbyAlliedHeroes > #tableNearbyEnemyHeroes
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
	local tableNearbyAllyHeroes =  npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		 
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) 
			and tableNearbyAlliedHeroes ~= nil and  #tableNearbyAllyHeroes >= 2 ) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy) ) 
		then
			local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
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
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy)
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
		   and not mutil.IsDisabled(true, npcTarget) 
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderCancelShackle()

	if not npcBot:IsChanneling() then return BOT_MODE_NONE; end
	
	local SCedUnit = nil;
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	
	for _,enemy in pairs(tableNearbyEnemyHeroes)
	do
		if enemy:HasModifier('modifier_shadow_shaman_shackles') then
			SCedUnit = enemy;
			break;
		end
	end
	
	if SCedUnit ~= nil then
		local tableNearbyAllyHeroes = SCedUnit:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		local tableNearbyEnemyHeroes = SCedUnit:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
		
		if #tableNearbyAllyHeroes < #tableNearbyEnemyHeroes and npcBot:WasRecentlyDamagedByAnyHero(2.0) then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
end
