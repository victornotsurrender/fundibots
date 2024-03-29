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

local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

local lastCheck = -90;
local checkChanneling = DotaTime();

function AbilityUsageThink()
	
	if #abilities == 0 then abilities = mutils.InitiateAbilities(bot, {0,1,2,5}) end
	
	if mutils.CantUseAbility(bot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	castQDesire, targetQ = ConsiderQ();
	--castWDesire, targetW = ConsiderW();
	castEDesire, targetE  = ConsiderE();
	castRDesire, targetR = ConsiderR();
	
	-- ability_item_usage_generic.SwapItemsTest()
	
	if castRDesire > 0 then
		bot:Action_UseAbility(abilities[4]);		
		return
	end
	
	if castQDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[1], targetQ);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[2], targetW);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_UseAbility(abilities[3]);		
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
	local nRadius   = abilities[1]:GetSpecialValueInt( "bolt_aoe" );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	if DotaTime() > checkChanneling + 0.5 then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
		do
			if mutils.CanCastOnNonMagicImmune(npcEnemy) and  npcEnemy:IsChanneling() then
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		checkChanneling = DotaTime();
	end
	
	
	
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING or npcBot:GetActiveMode() == BOT_MODE_FARM)  
	or mutil.IsRetreating(npcBot)   
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		local allies = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE);
		local Atowers = npcBot:GetNearbyTowers(nCastRange, false);
		
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
		if bot:HasScepter() == true then
			local loc = mutils.GetEscapeLoc();
			local furthestUnit = mutils.GetClosestEnemyUnitToLocation(bot, nCastRange, loc);
			if furthestUnit ~= nil and GetUnitToUnitDistance(furthestUnit, npcBot) >= 0.5*nCastRange then
				local cpos = utils.GetTowardsFountainLocation(furthestUnit:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_LOW, furthestUnit;
			end
		else
			local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
			if target ~= nil then
				local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end	
	end
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING or npcBot:GetActiveMode() == BOT_MODE_FARM)  and currManaP > 0.85
	then
		local lanecreeps = bot:GetNearbyCreeps(nCastRange, true);
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 and #lanecreeps >= 3  )  and # tableNearbyEnemyHeroes == 0
		then
			local npcTarget = mutils.GetVulnerableUnitNearLoc(false, true, nCastRange, nCastRange, locationAoE.targetloc, bot);
		if npcTarget ~= nil  then
			return BOT_ACTION_DESIRE_MODERATE,npcTarget;
		end
	end
	end
	
	
	-- elseif ( tableNearbyAllyHeroes ~= nil and tableNearbyEnemyHeroes ~= nil  and #tableNearbyAllyHeroes >= #tableNearbyEnemyHeroes ) then 
					-- local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 600, 600, 0.0, 0.0 );
				-- if ( locationAoE.count >= 1 ) then
					-- local target = mutil.GetVulnerableUnitNearLoc(true, true, 600, 600, locationAoE.targetloc, bot);
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	local npcTarget = npcBot:GetTarget();
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) and abilities[1]:GetLevel () >= 2
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nCastRange, true );
		for _,npcCreepTarget in pairs(tableNearbyEnemyCreeps) do
			if ( mutil.IsInRange(npcTarget, npcBot, nCastRange) and #tableNearbyEnemyHeroes == 0 and #tableNearbyEnemyCreeps >= 4
			and npcBot:GetMana()/npcBot:GetMaxMana() > 0.65 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcCreepTarget;
			end
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
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange) and mutils.IsDisabled(true, target) == false
		then
			local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, target;
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
	local nRadius   = abilities[2]:GetSpecialValueInt( "radius" );
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		if abilities[1]:IsFullyCastable() == false and mutils.CanCastOnNonMagicImmune(bot) then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300)  and mutils.CanCastOnNonMagicImmune(bot) == true
	then
		local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 0, nRadius, 0, 0 );
		local unitCount = abUtils.CountVulnerableUnit(enemies, locationAoE, nRadius, 2);
		if ( unitCount >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, bot;
		end
	end
	
	if DotaTime() >= lastCheck + 0.5 then 
		local weakest = nil;
		local minHP = 100000;
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		local allies = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE);
		if #allies > 0 and #enemies >= 1 then
			for i=1,#allies do
				if mutils.CanCastOnNonMagicImmune(allies[i])
				   and allies[i]:WasRecentlyDamagedByAnyHero(2.0) 
				   and ( allies[i]:GetAttackTarget() == nil or mutils.IsRetreating(allies[i]) )
				   and allies[i]:GetHealth() <= minHP
     			   and allies[i]:GetHealth() <= 0.5*allies[i]:GetMaxHealth() 
				then
					weakest = allies[i];
					minHP = allies[i]:GetHealth();
				end
			end
		end
		if weakest ~= nil then
			return BOT_ACTION_DESIRE_HIGH, weakest;
		end
		lastCheck = DotaTime();
	end
	
	if mutils.IsGoingOnSomeone(bot) and mutils.CanCastOnNonMagicImmune(bot) == true
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nRadius)
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

function ConsiderE()
	if not mutils.CanBeCast(abilities[3]) 
	then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastRange = 4*bot:GetAttackRange();
	local nRadius   = abilities[1]:GetSpecialValueInt( "radius" );
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0)
	then
		local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
		if #enemies > 0 then
			local cpos = utils.GetTowardsFountainLocation(bot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( mutils.IsRoshan(npcTarget) and mutils.IsInRange(npcTarget, bot, nCastRange) )
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

	if mutils.IsInTeamFight(bot, 1200)
	then
		local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
		if #enemies >= 2 then
			local allies = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
			if #allies >= 2 then
				return BOT_ACTION_DESIRE_LOW;
			end
		end
	end
	
	-- If we're going after someone
	if mutils.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if mutils.IsValidTarget(npcTarget) 
		then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
			if mutils.IsInRange(npcTarget, bot, nCastRange + #enemies * 150 ) then 
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end		

function ConsiderR()
	if not mutils.CanBeCast(abilities[4]) then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastRange = 4*bot:GetAttackRange();
	
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( mutils.IsRoshan(npcTarget) and mutils.IsInRange(npcTarget, bot, nCastRange) )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if mutils.IsValidTarget(npcTarget) 
		then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
			if mutils.IsInRange(npcTarget, bot, nCastRange + #enemies * 150 ) then 
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
	