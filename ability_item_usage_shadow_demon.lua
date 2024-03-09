if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
local mutil = require("bots/MyUtility")
local utility = require("bots/Utility")

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

local castDRDesire = 0;
local castSCDesire = 0;
local castSPDesire = 0;
local castSPRDesire = 0;
local castDPDesire = 0;

local abilityDR = nil;
local abilitySC = nil;
local abilitySP = nil;
local abilitySPR = nil;
local abilityDP = nil;

-- local npcBot = nil;
local bot = GetBot();
local npcBot = GetBot();

function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityDR == nil then abilityDR = npcBot:GetAbilityByName( "shadow_demon_disruption" ) end
	if abilitySC == nil then abilitySC = npcBot:GetAbilityByName( "shadow_demon_soul_catcher" ) end
	if abilitySP == nil then abilitySP = npcBot:GetAbilityByName( "shadow_demon_shadow_poison" ) end
	if abilitySPR == nil then abilitySPR = npcBot:GetAbilityByName( "shadow_demon_shadow_poison_release" ) end
	if abilityDP == nil then abilityDP = npcBot:GetAbilityByName( "shadow_demon_demonic_purge" ) end

	-- Consider using each ability
	castDRDesire, castDRTarget = ConsiderDisruption();
	castSCDesire, castSCLocation = ConsiderSoulCatcher();
	castSPDesire, castSPLocation = ConsiderShadowPoison();
	castSPRDesire,castSPRTarget = ConsiderShadowPoisonRelease();
	castDPDesire, castDPTarget = ConsiderDemonicPurge();
	
	

	if ( castDRDesire > castSCDesire and castDRDesire > castSPDesire and castDRDesire > castDPDesire ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityDR, castDRTarget );
		return;
	end

	if ( castSCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilitySC, castSCLocation );
		return;
	end
	
	if ( castSPDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilitySP, castSPLocation );
		return;
	end
	
	if ( castSPRDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySPR);
		return;
	end
	
	if ( castDPDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityDP, castDPTarget );
		return;
	end

end

function ConsiderDisruption()

	-- Make sure it's castable
	if ( not abilityDR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityDR:GetCastRange();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, false, BOT_MODE_NONE );
	for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
		if ( mutil.IsRetreating(myFriend) and myFriend:WasRecentlyDamagedByAnyHero(2.0) and mutil.CanCastOnNonMagicImmune(myFriend) ) 
			or ( mutil.IsDisabled(false, myFriend) and myFriend:GetTarget() == nil )
		then
			return BOT_ACTION_DESIRE_MODERATE, myFriend;
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
	
	
	
	
	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
		then
			local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		if mutil.IsProjectileIncoming(npcBot, 300)
			then
				local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				
			return BOT_ACTION_DESIRE_HIGH, npcBot;
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy) )
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil  )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
		if mutil.IsProjectileIncoming(npcBot, 300)
			then
				local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcBot;
		end
	end
	
	-- If we're going after someone
	if  mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and not mutil.IsInRange(npcTarget, npcBot, (nCastRange+200)/2) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) and
		   not mutil.IsDisabled(true, npcTarget)
		then
			local allies = npcTarget:GetNearbyHeroes(450, true, BOT_MODE_NONE);
			if #allies <= 1 then
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
		if mutil.IsProjectileIncoming(npcBot, 300)
			then
				local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcBot;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderSoulCatcher()

	-- Make sure it's castable
	if ( not abilitySC:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilitySC:GetSpecialValueInt( "radius" );
	local nCastRange = abilitySC:GetCastRange();

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
			end
		end
	end
	
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
		if (  mutil.IsInRange(npcEnemy, npcBot, nCastRange) 
		and mutil.CanCastOnNonMagicImmune(npcEnemy) and npcEnemy:HasModifier("modifier_shadow_demon_disruption")) 
			then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nCastPoint);
		end
	end
	

	-- if npcBot:GetActiveMode() == BOT_MODE_FARM 
	-- then
		-- local npcTarget = npcBot:GetAttackTarget();
		-- if npcTarget ~= nil and not npcTarget:IsBuilding() then
			-- return BOT_ACTION_DESIRE_LOW,npcTarget:GetLocation();
		-- end
	-- end	
	
	-- If we're going after someone
	if  mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) 
		then
			local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderShadowPoison()

	-- Make sure it's castable
	if ( not abilitySP:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
--
	-- If we want to cast Laguna Blade at all, bail
	--[[if ( castPRDesire > 0 ) 
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end]]--

	-- Get some of its values
	local nRadius = abilitySP:GetSpecialValueInt("radius");
	local nCastRange = mutil.GetProperCastRange(false, npcBot, abilitySP:GetCastRange());
	local nCastPoint = abilitySP:GetCastPoint();
	local manaCost = abilitySP:GetManaCost();

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	
	
	if nCastRange > 1600 then nCastRange = 1600 end
	
	
	
	--if we can hit any enemies with regen modifier
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange - 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and (npcEnemy:HasModifier("modifier_clarity_potion") or npcEnemy:HasModifier("modifier_flask_healing") )then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange - 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.StillHasModifier(npcEnemy, 'modifier_shadow_demon_disruption')	and abilitySP:GetLevel() >= 2	
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
		end
	end
	
	
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
	local tableNearbyAllyHeroes =  npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_ATTACK );
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		 
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) 
			and tableNearbyAlliedHeroes ~= nil and  #tableNearbyAllyHeroes >= 2 ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nCastPoint);
			end
		end
	end
	
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
		if (  mutil.IsInRange(npcEnemy, npcBot, nCastRange) 
		and mutil.CanCastOnNonMagicImmune(npcEnemy) and npcEnemy:HasModifier("modifier_shadow_demon_disruption")) 
			then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	

	-- If mana is full and we're laning just hit hero
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING and 
		npcBot:GetMana()/npcBot:GetMaxMana() >= 0.65  ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 1 ) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) ) and  mutil.CanSpamSpell(npcBot, manaCost)
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 ) then
			local target = mutil.GetVulnerableUnitNearLoc(false, true, nCastRange, nRadius, locationAoE.targetloc, npcBot);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
		end
	end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end	
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
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
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( (GetUnitToUnitDistance(npcTarget, npcBot) / 1000) + nCastPoint );
		end
	end
	
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end



function ConsiderShadowPoisonRelease()

	-- Make sure it's castable
	if ( not abilitySPR:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	
	-- -- If we're going after someone
	-- if mutil.IsGoingOnSomeone(npcBot)
	-- then
		-- local npcTarget = npcBot:GetTarget();
		
	-- local maxStacks = abilitySPR:GetSpecialValueInt("max_multiply_stacks");
	-- local stack = 0;
	-- local modIdx = npcTarget:GetModifierByName("modifier_shadow_demon_shadow_poison");
	-- if modIdx > -1 then
		-- stack = npcTarget:GetModifierStackCount(modIdx);
	-- end

		-- if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1600) 
		   -- and ( npcTarget:HasModifier("modifier_shadow_demon_purge_slow")==false or npcTarget:HasModifier("modifier_shadow_demon_disruption")==false or npcTarget:HasModifier("modifier_shadow_demon_soul_catcher")==false)
		   -- and not mutil.IsDisabled(true, npcTarget) 
		-- then
		-- -- stack = stack +1
		-- -- local modIdx = npcTarget:GetModifierByName("modifier_shadow_demon_shadow_poison");
		-- -- stack = npcTarget:GetModifierStackCount(modIdx);
		-- if stack <= maxStacks / 2 then
		-- return BOT_ACTION_DESIRE_NONE;	
		-- elseif stack >= maxStacks  
		-- -- elseif stack == maxStacks 
		-- then
			-- return BOT_ACTION_DESIRE_MODERATE;
		-- end
	-- end
	-- end
	
	
	
	
	
	
	
	
	
	
	--------------------------------------
	-- Generic Variable Setting
	--------------------------------------
	-- local ability=AbilitiesReal[abilityNumber];
	
	-- if not ability:IsFullyCastable() then
		-- return BOT_ACTION_DESIRE_NONE, 0;
	-- end
	
	-- local CastRange = ability:GetCastRange();
	-- local Damage = ability:GetAbilityDamage();
	-- local CastPoint = ability:GetCastPoint();
	
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE)
	local WeakestEnemy = utility.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(1600,true)
	local WeakestCreep = utility.GetWeakestUnit(creeps)
	local neutral = npcBot:GetNearbyNeutralCreeps(1600)
	local WeakestNeutralCreep = utility.GetWeakestUnit(neutral)
	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------
	--Try to kill enemy hero
	if (WeakestEnemy~=nil)
	then
		if (GetPoisonCount(WeakestEnemy)>=5)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	
	--Try to kill enemy creeps
	if (WeakestCreep~=nil)
	then
		if (GetPoisonCount(WeakestCreep)>=3)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	
	--Try to kill neutral creeps
	if (WeakestNeutralCreep~=nil)
	then
		if (GetPoisonCount(WeakestNeutralCreep)>=3)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	
	
	
	
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderDemonicPurge()

	-- Make sure it's castable
	if ( not abilityDP:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityDP:GetCastRange();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnMagicImmune(npcEnemy) 
				and not npcEnemy:HasModifier("modifier_shadow_demon_purge_slow")  ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) 
		and mutil.IsInRange(npcTarget, npcBot, nCastRange)  and  mutil.IsDisabled(true, npcTarget) )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange - 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.StillHasModifier(npcEnemy, 'modifier_shadow_demon_disruption')	 then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnMagicImmune(npcEnemy) and not npcEnemy:HasModifier("modifier_shadow_demon_purge_slow") and not mutil.IsDisabled(true, npcEnemy) )
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
			return BOT_ACTION_DESIRE_MODERATE, npcMostDangerousEnemy;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) 
		   and not npcTarget:HasModifier("modifier_shadow_demon_purge_slow") and not mutil.IsDisabled(true, npcTarget)
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end
















function GetPoisonCount(npcTarget)
	local modifier=npcTarget:GetModifierByName("modifier_shadow_demon_shadow_poison")
	if(modifier~=nil)
	then
		return npcTarget:GetModifierStackCount(modifier)
	else
		return 0
	end
end






