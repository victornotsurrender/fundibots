if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
local mutils = require("bots/MyUtility")
local mutil = require("bots/MyUtility")
local abUtils = require("bots/AbilityItemUsageUtility")

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

local bot = GetBot();
local npcBot = GetBot();

local abilities = {};

local castCombo1Desire = 0;
local castCombo2Desire = 0;
local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castE2Desire = 0;
local castRDesire = 0;

local lastCheck = -90;

function AbilityUsageThink()
	
	if #abilities == 0 then abilities = mutils.InitiateAbilities(bot, {0,1,2,3,6}) end
	
	if mutils.CantUseAbility(bot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	
	castQDesire, targetQ 	= ConsiderQ();
	-- castWDesire, targetType, tgt = ConsiderW();
	castWDesire, targetW 	= ConsiderW();
	castEDesire, targetE  	= ConsiderE();
	castE2Desire,targetE2   = ConsiderE2();
	castDDesire, targetD  	= ConsiderD();
	--castRDesire, targetR 	= ConsiderR();
	
	-- ability_item_usage_generic.SwapItemsTest()
	
	if castRDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[4], targetR);		
		return
	end
	
	if castQDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[1], targetQ);		
		return
	end
	
	-- if castWDesire > 0 then
		-- if targetType == "loc" then
			-- bot:Action_UseAbilityOnLocation(abilities[2], tgt);
		-- elseif targetType == "unit" then
			-- bot:Action_UseAbilityOnEntity(abilities[2], tgt);
		-- -- else
			-- -- bot:Action_UseAbility(abilities[2]);
		-- end	
		-- return
	-- end
	
	if castWDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[2], targetW);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_UseAbilityOnTree( abilities[3], targetE );	
		return
	end
	
	if castE2Desire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[5], targetE2);		
		return
	end
	
	if castDDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[4], targetD);		
		return
	end
	
end

function ConsiderQ()
	if not mutils.CanBeCast(abilities[1]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost  = abilities[1]:GetManaCost();
	local nRadius   = abilities[1]:GetSpecialValueInt( "radius" );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	-- local speed    	 = 1000

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
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
				end
			end
		end
	end
	end
	end
	
	
	
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM or mutils.IsPushing(bot) or mutils.IsDefending(bot) or bot:GetActiveMode() == BOT_MODE_LANING ) and mutils.CanSpamSpell(bot, manaCost)
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 8 ) then
			local target = mutils.GetVulnerableUnitNearLoc(false, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) then
			local target = mutils.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM or mutils.IsPushing(bot) or mutils.IsDefending(bot) or bot:GetActiveMode() == BOT_MODE_LANING or bot:GetActiveMode() == BOT_MODE_FARM  ) and mutils.CanSpamSpell(bot, manaCost)
	then
		local locationAoE = bot:FindAoELocation( true,true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			local target = mutils.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius, locationAoE.targetloc, bot);
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
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange)
			and mutils.IsDisabled(true, target) == false and (not mutil.StillHasModifier(target, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(target, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end





function ConsiderW()
	if not mutils.CanBeCast(abilities[2]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[2]:GetCastRange());
	local nCastPoint = abilities[2]:GetCastPoint();
	local manaCost  = abilities[2]:GetManaCost();
	local nDamage  = abilities[1]:GetSpecialValueInt("avalanche_damage");
	local nDamage2  = abilities[2]:GetSpecialValueInt("toss_damage");
	local nRadius   = abilities[2]:GetSpecialValueInt( "grab_radius" );
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		if abilities[1]:IsFullyCastable() then 
			local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
			for i=1,#enemies do
				if mutils.IsValidTarget(enemies[i]) and mutils.CanCastOnNonMagicImmune(enemies[i]) and enemies[i]:GetHealth() < nDamage + nDamage2 then
					return BOT_ACTION_DESIRE_LOW, enemies[i];
				end
			end
		else
			local loc = mutils.GetEscapeLoc();
			local furthestTarget = mutils.GetFurthestUnitToLocationFrommAll(bot, nCastRange, loc);
			if furthestTarget ~= nil and GetUnitToUnitDistance(furthestTarget, bot) > nRadius then
				local tTarget = mutils.GetClosestUnitToLocationFrommAll2(bot, nRadius, bot:GetLocation());
				if mutils.IsValidTarget(tTarget) and tTarget:GetTeam() ~= bot:GetTeam() then
					return BOT_ACTION_DESIRE_LOW, furthestTarget;
				end
			elseif furthestTarget ~= nil and GetUnitToUnitDistance(furthestTarget, bot) <= nRadius then
				local tTarget = mutils.GetClosestUnitToLocationFrommAll2(bot, nRadius, bot:GetLocation());
				if mutils.IsValidTarget(tTarget) and tTarget:GetTeam() ~= bot:GetTeam() then
					return BOT_ACTION_DESIRE_LOW, tTarget;	
				end
			end
		end
	end
	
	-- if mutils.IsInTeamFight(bot, 1300)  and mutils.CanCastOnNonMagicImmune(bot) == true
	-- then
		-- local enemies = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE);
		-- local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 0, nRadius, 0, 0 );
		-- local unitCount = abUtils.CountVulnerableUnit(enemies, locationAoE, nRadius, 2);
		-- if ( unitCount >= 2 ) 
		-- then
			-- return BOT_ACTION_DESIRE_LOW, bot;
		-- end
	-- end
	
	if mutils.IsGoingOnSomeone(bot) and mutils.CanCastOnNonMagicImmune(bot) == true
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) 
		then
			if mutils.IsInRange(target, bot, nRadius) then
				 return BOT_ACTION_DESIRE_LOW, target;
			elseif mutils.IsInRange(target, bot, nRadius) == false and mutils.IsInRange(target, bot, nCastRange) == true then
				local aCreep = bot:GetNearbyLaneCreeps(nRadius, false);
				local eCreep = bot:GetNearbyLaneCreeps(nRadius, true);
				if #aCreep >= 1 or #eCreep >= 1 then
					local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					return BOT_ACTION_DESIRE_LOW, target;
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	









function ConsiderE()
	if not mutils.CanBeCast(abilities[3]) or bot:HasModifier("modifier_tiny_tree_grab") == true
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[3]:GetCastRange());
	
	if mutils.IsRetreating(bot) == false and bot:GetHealth() > 0.15*bot:GetMaxHealth() and bot:DistanceFromFountain() > 1000 then
		local trees = bot:GetNearbyTrees(500);
		if #trees > 0 and ( IsLocationVisible(GetTreeLocation(trees[1])) or IsLocationPassable(GetTreeLocation(trees[1])) ) then
			return BOT_ACTION_DESIRE_LOW, trees[1];
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end		

function ConsiderE2()
	if not mutils.CanBeCast(abilities[5]) or bot:HasModifier("modifier_tiny_tree_grab") == false
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[5]:GetCastRange());
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	
	
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
	
	
	
	
	
	
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
	
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if (npcEnemy:GetActiveMode() == BOT_MODE_RETREAT and npcEnemy:GetActiveModeDesire() >= BOT_MODE_DESIRE_MODERATE 
		and mutil.CanCastOnNonMagicImmune2(npcEnemy) and not mutil.IsSuspiciousIllusion2(npcEnemy) 
        and mutils.IsInRange(npcEnemy, bot, 0.3*nCastRange) == false and mutils.IsInRange(npcEnemy, bot, nCastRange) == true		) 
		then
			-- bot:ActionImmediate_Chat("Cogeeeeeeeee!!!",true);
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	
	
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(target, bot, 0.3*nCastRange) == false and mutils.IsInRange(target, bot, nCastRange) == true
			and bot:GetAttackDamage() >= target:GetHealth()
		then
			local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end		

function ConsiderD()
	if not mutils.CanBeCast(abilities[4]) or bot:HasScepter() == false 
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[4]:GetCastRange());
	local nRadius =  abilities[4]:GetSpecialValueInt('tree_grab_radius');
	local nRadius2 =  abilities[4]:GetSpecialValueInt('splash_radius');
	local manaCost  = abilities[4]:GetManaCost();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	-- local speed    	 = 1000

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING) and currManaP > 0.45
	or mutil.IsRetreating(npcBot)   
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(1400, true, BOT_MODE_NONE);
		local allies = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE);
		local Atowers = npcBot:GetNearbyTowers(1400, false);
		local trees = bot:GetNearbyTrees(nRadius);
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  mutil.CanCastOnNonMagicImmune(npcEnemy) and #trees >= 3
			then	
		for _,u in pairs(Atowers) do
			if GetUnitToLocationDistance(bot,u:GetLocation()) <= 700 and GetUnitToLocationDistance(npcEnemy,u:GetLocation()) <= 700
				then
			if #allies >= 0  then
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
				end
			end
		end
	end
	end
	end
	-- end
	
	if mutils.IsInTeamFight(bot, 1300)  
	then
		local trees = bot:GetNearbyTrees(nRadius);
		if #trees >= 3 then
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius2, 0, 0 );
			if ( locationAoE.count >= 2 ) then
				local target = mutils.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius2, locationAoE.targetloc, bot);
				if target ~= nil then
					return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
				end
			end
		end
	end
	
	
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) or bot:GetActiveMode() == BOT_MODE_LANING or bot:GetActiveMode() == BOT_MODE_FARM  ) and mutils.CanSpamSpell(bot, manaCost)
	then
		local trees = bot:GetNearbyTrees(nRadius);
		if #trees >= 3 then
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius2, 0, 0 );
			if ( locationAoE.count >= 2 ) then
				local target = mutils.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius2, locationAoE.targetloc, bot);
				if target ~= nil then
					return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
				end
			end
		end
	end
	
	
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange) == true
		then
			local trees = bot:GetNearbyTrees(nRadius);
			if #trees >= 3 then
				local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end		

function ConsiderR()
	if not mutils.CanBeCast(abilities[4]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[4]:GetCastRange());
	local nCastPoint = abilities[4]:GetCastPoint();
	local manaCost  = abilities[4]:GetManaCost();
	local nRadius   = abilities[4]:GetSpecialValueInt( "jump_range" );
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) then
			local target = mutils.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange)
		then
			local enemies = target:GetNearbyHeroes( nRadius-200, false, BOT_MODE_NONE );
			local nInvUnit = mutils.CountInvUnits(false, enemies);
			if nInvUnit >= 2 then
				local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end
	