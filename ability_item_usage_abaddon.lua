if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require( "bots/util")
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
local castACDesire = 0;
local castBTDesire = 0;

-- local npcBot = nil;

local abilityDC = nil;
local abilityAC = nil;
local abilityBT = nil;

local npcBot = GetBot();
local bot = GetBot();

-- local loc = Vector(-5953.000000, 3342.000000, 0.000000)
-- local lastPing = -90;
function AbilityUsageThink()
	-- if npcBot == nil then npcBot = GetBot(); end
	
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	if abilityDC == nil then abilityDC = npcBot:GetAbilityByName( "abaddon_death_coil" ) end
	if abilityAC == nil then abilityAC = npcBot:GetAbilityByName( "abaddon_aphotic_shield" ) end
	if abilityBT == nil then abilityBT = npcBot:GetAbilityByName( "abaddon_borrowed_time" ) end
	
	castACDesire, castACTarget = ConsiderAphoticShield();
	castDCDesire, castDCTarget = ConsiderDeathCoil();
	castBTDesire               = ConsiderBorrowedTime();
	
	-- if DotaTime() > lastPing + 3.0 
		-- then
		-- local cpos = utils.GetTowardsFountainLocation(loc, 0);
				-- bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
	-- print(bot:GetUnitName().."Loc:"..tostring(cpos ))
	-- lastPing = DotaTime()
	-- end
	

	if ( castACDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityAC, castACTarget );
		return;
	end

	if ( castDCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityDC, castDCTarget );
		return;
	end
	
	if ( castBTDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityBT );
		return;
	end
end







function ConsiderDeathCoil()

	-- Make sure it's castable
	if ( not abilityDC:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityDC:GetCastRange();
	local nDamage = abilityDC:GetSpecialValueInt("target_damage");
	local nSelfDamage = abilityDC:GetSpecialValueInt("self_damage");
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local currHealthP = npcBot:GetHealth() / npcBot:GetMaxHealth();
	local nManaCost  = abilityDC:GetManaCost();
	
	
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and mutil.CanKillTarget2(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) or npcEnemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	--if we can hit any enemies with regen modifier
	-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) 
		and (npcEnemy:HasModifier("modifier_clarity_potion") or npcEnemy:HasModifier("modifier_flask_healing") )
		then
			
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	
	-- If we're seriously retreating, see if we can suicide
	if mutil.IsRetreating(npcBot) and npcBot:GetHealth() <= nSelfDamage
	then
		if (npcBot:WasRecentlyDamagedByAnyHero( 2.0 )) then
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		local target = mutil.GetVulnerableWeakestUnit(true, true, nCastRange, npcBot);
		if target ~= nil 
		then
			return BOT_ACTION_DESIRE_MODERATE, target;
		end
	end
	end
	
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsSuspiciousIllusion(npcEnemy) ) 
			then
				
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	
	local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	for _,myFriend in pairs(tableNearbyFriendlyHeroes) 
	do
		if  myFriend:GetUnitName() ~= npcBot:GetUnitName() and mutil.IsRetreating(myFriend) and
			myFriend:WasRecentlyDamagedByAnyHero(2.0) and mutil.CanCastOnNonMagicImmune(myFriend)
		then
			return BOT_ACTION_DESIRE_MODERATE, myFriend;
		end
	end	
	
	
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) ) and mutil.AllowedToSpam(bot, nManaCost) and abilityDC:GetLevel() > 1
	then
				
		local lanecreeps = bot:GetNearbyLaneCreeps(nCastRange, true);
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nCastRange, 0, 0 );
		if ( locationAoE.count <= 4 and #lanecreeps <= 4  ) 
		then
			local tableNearbyAllies = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE  );
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
			for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
			do
			if mutil.CanCastOnNonMagicImmune2(npcEnemy) and #tableNearbyEnemyHeroes <= #tableNearbyAllies then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end
		end
	end
	
	if (mutil.IsPushing(bot) or mutil.IsDefending(bot) or npcBot:GetActiveMode() == BOT_MODE_LANING) and currManaP > 0.6 and abilityDC:GetLevel() > 2
	then
		local target = mutil.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		local lanecreeps = bot:GetNearbyLaneCreeps(1200, true);
		if target ~= nil and #lanecreeps > 4  then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
		target = mutils.GetVulnerableWeakestUnit(false, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	
	
	if npcBot:HasModifier("modifier_abaddon_borrowed_time") then
		local target = mutil.GetVulnerableWeakestUnit(false, true, nCastRange, npcBot);
		if target ~= nil then
			
			return BOT_ACTION_DESIRE_MODERATE, target;
		end
	end
	
	
	-- If we're in a teamfight, use it on ally to protect them 
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local lowHpAlly = nil;
		local nLowestHealth = 1000;
		local tableNearbyAllies = npcBot:GetNearbyHeroes( nCastRange+200, false, BOT_MODE_NONE  );
		for _,npcAlly in pairs( tableNearbyAllies )
		do
			if ( npcAlly:GetUnitName() ~= npcBot:GetUnitName() and mutil.CanCastOnNonMagicImmune(npcAlly) )
			then
				local nAllyHP = npcAlly:GetHealth();
				if ( ( nAllyHP < nLowestHealth and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.5 ) or mutil.IsDisabled(false, npcAlly) )
				then
					nLowestHealth = nAllyHP;
					lowHpAlly = npcAlly;
				end
			end
		end

		if ( lowHpAlly ~= nil )
		then
			return BOT_ACTION_DESIRE_MODERATE, lowHpAlly;
		end
	end
	
	
	
	-- if (npcBot:GetActiveMode() == BOT_MODE_LANING  or mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot)) and currHealthP > 0.50 and currManaP > 0.80
	-- then
	   
	
		-- local laneCreeps = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		-- for _,creep in pairs(laneCreeps)
		-- do
			-- if creep:GetHealth() <= nDamage then
				-- return BOT_ACTION_DESIRE_MODERATE, creep;
		    -- end
        -- end
	-- end
	
	
	if  (npcBot:GetActiveMode() == BOT_MODE_LANING or npcBot:GetActiveMode() == BOT_MODE_FARM or mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot))  and currManaP > 0.65 and currHealthP > 0.50
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					then 
					return BOT_ACTION_DESIRE_MODERATE,neutral;
				end
			end
		end
	end
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and currHealthP > 0.50 and currManaP > 0.45 and abilityDC:GetLevel() > 2
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end	
	
	
	-- if is in Roshan
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if (  mutil.IsRoshan(npcTarget) and  mutil.CanCastOnMagicImmune(npcTarget) and  mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) 
	then
		local npcTarget = npcBot:GetTarget();
		if (  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget)
		and mutil.IsInRange(npcTarget, npcBot, nCastRange) and not mutil.IsSuspiciousIllusion(npcTarget) and npcBot:GetHealth() > 0.35*npcBot:GetMaxHealth()) 
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderAphoticShield()

	-- Make sure it's castable
	if ( not abilityAC:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	

	-- Get some of its values
	local nRadius   = abilityAC:GetSpecialValueInt( "radius" );
	local nCastRange = abilityAC:GetCastRange();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();

	if mutil.IsRetreating(npcBot) and npcBot:WasRecentlyDamagedByAnyHero( 3.0 ) and npcBot:HasModifier('modifier_abaddon_aphotic_shield') == false
	then
		
		return BOT_ACTION_DESIRE_MODERATE, npcBot;
	end
	
	-- If we're in a teamfight, use it on the scariest enemy
	if mutil.IsInTeamFight(npcBot, 1300)
	then
		local lowHpAlly = nil;
		local nLowestHealth = 10000;

		local tableNearbyAllies = npcBot:GetNearbyHeroes( nCastRange+200, false, BOT_MODE_NONE  );
		for _,npcAlly in pairs( tableNearbyAllies )
		do
			if ( npcAlly:GetUnitName() ~= npcBot:GetUnitName() and mutil.CanCastOnMagicImmune(npcAlly) and npcAlly:HasModifier('modifier_abaddon_aphotic_shield') == false )
			then
				local nAllyHP = npcAlly:GetHealth();
				if ( ( nAllyHP < nLowestHealth and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.35 ) or mutil.IsDisabled(false, npcAlly) )
				then
					nLowestHealth = nAllyHP;
					lowHpAlly = npcAlly;
				end
			end
		end

		if ( lowHpAlly ~= nil )
		then
			return BOT_ACTION_DESIRE_MODERATE, lowHpAlly;
		end
	end
	
	local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	for _,myFriend in pairs(tableNearbyFriendlyHeroes) 
	do
		if  myFriend:GetUnitName() ~= npcBot:GetUnitName() and mutil.IsRetreating(myFriend) and
			myFriend:WasRecentlyDamagedByAnyHero(2.0) and mutil.CanCastOnNonMagicImmune(myFriend)
		then
			return BOT_ACTION_DESIRE_MODERATE, myFriend;
		end
	end	
	
	-- if npcBot:GetActiveMode() == BOT_MODE_FARM  and npcBot:HasModifier('modifier_abaddon_aphotic_shield') == false and currManaP > 0.45
	-- then
		-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		-- local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			-- if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				-- for _,neutral in pairs(tableNearbyNeutrals)
				-- do
				-- if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					-- then 
					-- return BOT_ACTION_DESIRE_MODERATE,npcBot;
				-- end
			-- end
		-- end
	-- end
	
	if (mutil.IsPushing(bot) or mutil.IsDefending(bot) or npcBot:GetActiveMode() == BOT_MODE_LANING or (npcBot:GetActiveMode() == BOT_MODE_FARM and npcBot:HasModifier('modifier_abaddon_aphotic_shield') == false)) and currManaP > 0.45 and abilityAC:GetLevel() > 1
	then
		local target = mutil.GetVulnerableWeakestUnit(false, false, nCastRange, bot);
		local Ecreeps = bot:GetNearbyLaneCreeps(1200, true);
		local Acreeps = bot:GetNearbyLaneCreeps(1200, false);
		if target ~= nil and Ecreeps ~= nil and #Ecreeps >= 4   then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
		elseif Acreeps ~= nil  and Ecreeps ~= nil and #Ecreeps >= 4 and  #Acreeps == 0 and currManaP > 0.45 and abilityAC:GetLevel() > 1
			then
		return BOT_ACTION_DESIRE_MODERATE,npcBot;
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and npcBot:HasModifier('modifier_abaddon_aphotic_shield') == false and currManaP > 0.45
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW,npcBot;
		end
	end	
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) and npcBot:HasModifier('modifier_abaddon_aphotic_shield') == false )
		then
			return BOT_ACTION_DESIRE_LOW, npcBot;
		end
	end
	
	
	

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1300) ) 
		then
			local closestAlly = nil;
			local nDist = 10000;

			local tableNearbyAllies = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE  );
			for _,npcAlly in pairs( tableNearbyAllies )
			do
				if ( mutil.CanCastOnMagicImmune(npcAlly) and npcAlly:HasModifier('modifier_abaddon_aphotic_shield') == false )
				then
					local nAllyDist = GetUnitToUnitDistance(npcTarget, npcAlly);
					if nAllyDist < nDist  
					then
						nDist = nAllyDist;
						closestAlly = npcAlly;
					end
				end
			end

			if ( closestAlly ~= nil )
			then
				return BOT_ACTION_DESIRE_MODERATE, closestAlly;
			end
		end
	end
	
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nRadius-100, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, npcBot;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderBorrowedTime()

	-- Make sure it's castable
	if ( not abilityBT:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local tableNearbyAllies = npcBot:GetNearbyHeroes( 900, false, BOT_MODE_NONE  );
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	local currHealthP = npcBot:GetHealth() / npcBot:GetMaxHealth();
	
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and currHealthP < 0.35
	and npcBot:WasRecentlyDamagedByAnyHero( 3.0 ) 
	and mutil.HasDisabledSkills(bot)
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	
	-- If we're in a teamfight, use it on the scariest enemy
	if mutil.IsInTeamFight(npcBot, 900)
	then
		local lowHpAlly = nil;
		local nLowestHealth = 10000;

		-- local tableNearbyAllies = npcBot:GetNearbyHeroes( nCastRange+200, false, BOT_MODE_NONE  );
		for _,npcAlly in pairs( tableNearbyAllies )
		do
			if ( npcAlly:GetUnitName() ~= npcBot:GetUnitName() and mutil.CanCastOnMagicImmune(npcAlly) and npcAlly:HasModifier('modifier_abaddon_aphotic_shield') == false )
			then
				local nAllyHP = npcAlly:GetHealth();
				if ( ( nAllyHP < nLowestHealth and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.35 ) and mutil.IsDisabled(false, npcAlly) )
				then
					nLowestHealth = nAllyHP;
					lowHpAlly = npcAlly;
				end
			end
		end

		if ( lowHpAlly ~= nil ) and #tableNearbyEnemyHeroes >= #tableNearbyAllies
		then
			return BOT_ACTION_DESIRE_MODERATE, lowHpAlly;
		end
	end
	
	
	

	return BOT_ACTION_DESIRE_NONE;
end








