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
	castWDesire, targetW = ConsiderW();
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
		bot:Action_UseAbility(abilities[3], targetE);		
		return
	end
	
end


function CanCastDeathCoilOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end


function ConsiderQ()
	if not mutils.CanBeCast(abilities[1]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost  = abilities[1]:GetManaCost();
	--local nRadius   = abilities[1]:GetSpecialValueInt( "bolt_aoe" );
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
			if GetUnitToLocationDistance(bot,u:GetLocation()) <= 250 and GetUnitToLocationDistance(npcEnemy,u:GetLocation()) <= 250
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
	
	
	
--	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
--	then
--		if bot:HasScepter() == true then
--			local loc = mutils.GetEscapeLoc();
--			local furthestUnit = mutils.GetClosestEnemyUnitToLocation(bot, nCastRange, loc);
--			if furthestUnit ~= nil and GetUnitToUnitDistance(furthestUnit, npcBot) >= 0.5*nCastRange then
--				local cpos = utils.GetTowardsFountainLocation(furthestUnit:GetLocation(), 0);
--				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
--				return BOT_ACTION_DESIRE_LOW, furthestUnit;
--			end
--		else
--			local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
--			if target ~= nil then
--				local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
--				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
--				return BOT_ACTION_DESIRE_HIGH, target;
--			end
--		end	
--	end
	
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
		
	if not mutils.CanBeCast(abilities[3]) 
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	


		if mutil.IsInTeamFight(npcBot, 1200) then
		local tableNearbyAllies = npcBot:GetNearbyHeroes( 450, false, BOT_MODE_NONE  );
		for _,npcAlly in pairs( tableNearbyAllies )
		do
			if ( CanCastDeathCoilOnTarget( npcAlly ) )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcAlly,
			end
		end
		
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end	

function ConsiderE()
	if not mutils.CanBeCast(abilities[3]) 
	then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	
	
		local tableNearbyAllies = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE  );
		for _,npcAlly in pairs( tableNearbyAllies ) do
			return BOT_ACTION_DESIRE_MODERATE, npcAlly,
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
	