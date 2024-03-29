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

local castFBDesire = 0;
local castUFBDesire = 0;
local castIGDesire = 0;
local castBLDesire = 0;

local abilityUFB = nil;
local abilityFB = nil;
local abilityIG = nil;
local abilityBL = nil;
local abilityR = nil;

-- local npcBot = nil;
local npcBot = GetBot()
local bot = GetBot()

function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();

	if abilityUFB == nil then abilityUFB = npcBot:GetAbilityByName( "ogre_magi_unrefined_fireblast" ) end
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "ogre_magi_fireblast" ) end
	if abilityIG == nil then abilityIG = npcBot:GetAbilityByName( "ogre_magi_ignite" ) end
	if abilityBL == nil then abilityBL = npcBot:GetAbilityByName( "ogre_magi_bloodlust" ) end
	if abilityR == nil then abilityR = npcBot:GetAbilityByName( "ogre_magi_multicast" ) end

	-- Consider using each ability
	castFBDesire, castFBTarget = ConsiderFireblast();
	castUFBDesire, castUFBTarget = ConsiderUnrefinedFireblast();
	castIGDesire, castIGTarget = ConsiderIgnite();
	castBLDesire, castBLTarget = ConsiderBloodlust();
	
	
	
	if ( castUFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityUFB, castUFBTarget );
		return;
	end

	if ( castFBDesire > castIGDesire and castFBDesire > castBLDesire ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end

	if ( castIGDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityIG, castIGTarget );
		return;
	end
	
	if ( castBLDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityBL, castBLTarget );
		return;
	end

end






function ConsiderFireblast()

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();
	local nDamage = abilityFB:GetAbilityDamage();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and mutil.CanCastOnNonMagicImmune2(npcEnemy) and not mutil.IsSuspiciousIllusion2(npcEnemy) ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if (mutil.CanCastOnNonMagicImmune2(npcEnemy) and mutil.CanKillTarget2(npcEnemy, nDamage*2, DAMAGE_TYPE_MAGICAL)
		and abilityR:IsTrained())  
		then
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
	
	if ( mutil.IsPushing(npcBot) or  mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING) 
	and currManaP > 0.45 and  abilityFB:GetLevel() > 1
	then
	   
	
		local laneCreeps = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		for _,creep in pairs(laneCreeps)
		do
			if creep:GetHealth() <= nDamage then
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
			for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
			do
			if mutil.CanCastOnNonMagicImmune2(npcEnemy) then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end
		    end
        end
	end
	
	-- if npcBot:GetActiveMode() == BOT_MODE_FARM and currManaP > 0.45
	-- then
		-- local npcTarget = npcBot:GetAttackTarget();
		-- if npcTarget ~= nil and not npcTarget:IsBuilding() then
			-- return BOT_ACTION_DESIRE_MODERATE,npcTarget;
		-- end
	-- end
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING) 
	and currManaP > 0.45 and  abilityFB:GetLevel() > 1
	then
	   local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
		local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy)
			and npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.80 ) and #tableNearbyAlliedHeroes >=1
			then
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
			then
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		   and not mutil.IsDisabled(true, npcTarget) and not mutil.IsSuspiciousIllusion(npcTarget)
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderIgnite()

	-- Make sure it's castable
	if ( not abilityIG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityIG:GetCastRange();
	local nDuration = abilityIG:GetSpecialValueInt( "duration" );
	local nDOT = abilityIG:GetSpecialValueInt( "burn_damage" );
	local nRadius = 0;
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
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
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
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
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if abilityR:IsTrained() and ( mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) ) and npcBot:GetMana()/npcBot:GetMaxMana() > 0.45
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 and  tableNearbyEnemyCreeps[1] ~= nil 
		then
			return BOT_ACTION_DESIRE_MODERATE, tableNearbyEnemyCreeps[1];
		elseif  not abilityR:IsTrained() and ( mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) ) and npcBot:GetMana()/npcBot:GetMaxMana() > 0.45
		then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange, true );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if (mutil.IsInRange(npcEnemy,npcBot,nCastRange) and mutil.CanCastOnNonMagicImmune(npcEnemy) )
			and tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		end	
	end
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and currManaP > 0.45
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_MODERATE,npcTarget;
		end
	end
	
	
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderBloodlust()

	-- Make sure it's castable
	if ( not abilityBL:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityBL:GetCastRange();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and currManaP > 0.45
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_MODERATE,npcTarget;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local cpos = utils.GetTowardsFountainLocation( npcBot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcBot;
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
	
	-- If we're pushing or defending a lane
	if  mutil.IsDefending(npcBot)
	then
		local tableNearbyFriendlyTowers = npcBot:GetNearbyTowers( nCastRange+200, false );
		for _,myTower in pairs(tableNearbyFriendlyTowers) do
			if ( not myTower:HasModifier("modifier_ogre_magi_bloodlust") ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, myTower;
			end
		end
		local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes(  nCastRange+200, false, BOT_MODE_NONE );
		for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
			if ( not myFriend:HasModifier("modifier_ogre_magi_bloodlust") ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, myFriend;
			end
		end	
		if not npcBot:HasModifier("modifier_ogre_magi_bloodlust") then
			return BOT_ACTION_DESIRE_MODERATE, npcBot;
		end
	end
	
	-- If we're pushing or defending a lane
	if  mutil.IsPushing(npcBot)
	then
		local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes(  nCastRange+200, false, BOT_MODE_NONE );
		for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
			if ( not myFriend:HasModifier("modifier_ogre_magi_bloodlust") ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, myFriend;
			end
		end	
		if not npcBot:HasModifier("modifier_ogre_magi_bloodlust") then
			return BOT_ACTION_DESIRE_MODERATE, npcBot;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) 
	then
		local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes(  nCastRange+200, false, BOT_MODE_NONE );
		for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
			if ( not myFriend:HasModifier("modifier_ogre_magi_bloodlust") ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, myFriend;
			end
		end	
		if not npcBot:HasModifier("modifier_ogre_magi_bloodlust") then
			return BOT_ACTION_DESIRE_MODERATE, npcBot;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderUnrefinedFireblast()

	-- Make sure it's castable
	if ( not abilityUFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if ( not npcBot:HasScepter() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	if castFBDesire > 0 then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	-- Get some of its values
	local nCastRange = abilityUFB:GetCastRange();
	local nDamage = abilityFB:GetAbilityDamage();
	local curPMana  = npcBot:GetMana()/npcBot:GetMaxMana();

	if ( curPMana > 0.5 ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and mutil.CanKillTarget2(npcEnemy, nDamage*2, DAMAGE_TYPE_MAGICAL) 
		 and abilityR:IsTrained()
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end

	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
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
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune2(npcEnemy) and not mutil.IsSuspiciousIllusion2(npcEnemy) ) 
			then
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) and not mutil.IsSuspiciousIllusion(npcTarget)
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end



