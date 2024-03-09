if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
local mutil = require("bots/MyUtility")
local abUtils = require("bots/AbilityItemUsageUtility")
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

local bot = GetBot();
local npcBot = GetBot();

local abilities = {};

local castCombo1Desire = 0;
local castCombo2Desire = 0;
local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

local lastCheck = -90;
local castSwapTime = DotaTime();
local ancient = GetAncient(GetTeam());
local eancient = GetAncient(GetOpposingTeam());
local castSwapForSaveCheck = DotaTime();
local castSwapForChanelling = DotaTime();

function AbilityUsageThink()
	
	if #abilities == 0 then abilities = mutils.InitiateAbilities(bot, {0,1,2,5}) end
	
	if mutils.CantUseAbility(bot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	castQDesire, targetQ = ConsiderQ();
	-- castWDesire, targetW = ConsiderW();
	-- castEDesire, targetE  = ConsiderE();
	castRDesire, targetR, typeR = ConsiderR();
	
	-- ability_item_usage_generic.SwapItemsTest()
	
	if castRDesire > 0 then
		castSwapTime = DotaTime();
		if typeR == 'entity' then
			bot:Action_UseAbilityOnEntity( abilities[4], targetR );
		elseif typeR == 'loc' then
			bot:Action_UseAbilityOnLocation( abilities[4], targetR );
		else
			bot:Action_UseAbility( abilities[4] );
		end		
	end
	
	if castQDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[1], targetQ);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[2], targetW);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_UseAbility( abilities[3] );
	end
	
end

function ConsiderQ()
	if not mutils.CanBeCast(abilities[1]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost  = abilities[1]:GetManaCost();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nManaCost    = abilities[1]:GetManaCost( );
	local nDamage    =  abilities[1]:GetSpecialValueInt( "beam_damage");
	
	
	
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and mutil.CanKillTarget2(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) or npcEnemy:IsChanneling()
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	--if we can hit any enemies with regen modifier
	-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and (npcEnemy:HasModifier("modifier_clarity_potion") or npcEnemy:HasModifier("modifier_flask_healing") )then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	
	
	
	if mutils.CanBeCast(abilities[4]) and bot:GetMana() - manaCost <= abilities[4]:GetManaCost() + 50 then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) ) or 
		( bot:GetActiveMode() == BOT_MODE_LANING and abilities[1]:GetLevel() >= 2 and mutils.CanSpamSpell(bot, manaCost) )
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	
	if mutils.IsInTeamFight(bot, 1300)
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN and mutils.CanSpamSpell(bot, manaCost)  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( mutils.IsRoshan(npcTarget) and mutils.CanCastOnMagicImmune(npcTarget) and mutils.IsInRange(npcTarget, bot, nCastRange) 
            and not mutils.IsDisabled(true, npcTarget) )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	
	if mutils.IsPushing(bot) or mutils.IsDefending(bot) and currManaP > 0.6
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
		-- target = mutils.GetVulnerableWeakestUnit(false, true, nCastRange, bot);
		-- if target ~= nil then
			-- return BOT_ACTION_DESIRE_HIGH, target;
		-- end
	end
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					then 
					return BOT_ACTION_DESIRE_MODERATE,neutral;
				end
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange+200)
		then
			local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
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
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

function ConsiderE()
	if not mutils.CanBeCast(abilities[3]) 
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end		

function ConsiderR()
	if not mutils.CanBeCast(abilities[4]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastPoint = abilities[4]:GetCastPoint();
	local manaCost  = abilities[4]:GetManaCost();
	local nRadius   = abilities[4]:GetSpecialValueInt( "radius" );
	local hitCount = abilities[4]:GetSpecialValueInt( "hit_count" );
	local nDamage = abilities[1]:GetSpecialValueInt( "beam_damage" );
	
	if bot:HasScepter() then
		hitCount = abilities[4]:GetSpecialValueInt( "hit_count_scepter" );
		local nTotalDamage = nDamage * hitCount;
		local nCastRange = mutils.GetProperCastRange(false, bot, abilities[4]:GetSpecialValueInt('cast_range_tooltip_scepter'));
		
		if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
		then
			local  enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
			local  creeps = bot:GetNearbyCreeps(nRadius, true);
			if #enemies > 0 and #creeps <= 2 then
				local cpos = utils.GetTowardsFountainLocation( bot:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, bot, 'entity';
			end
		end
		
		
		
		if mutils.IsInTeamFight(bot, 1300)
		then
			local nInvUnit = mutils.FindNumInvUnitInLoc(false, bot, nRadius, nRadius, bot:GetLocation());
			local creeps = bot:GetNearbyCreeps(nRadius, true);
			if mutils.IsGoingOnSomeone(bot) and nInvUnit >= 2 and #creeps <= 3 then
				return BOT_ACTION_DESIRE_HIGH, bot, 'entity';
			end
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
			if ( locationAoE.count >= 2 ) then
				local target = mutils.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius, locationAoE.targetloc, bot);
				if target ~= nil then
					return BOT_ACTION_DESIRE_HIGH, target:GetLocation(), 'loc';
				end
			end
		end
		
		if mutils.IsGoingOnSomeone(bot)
		then
			local target = bot:GetTarget();
			if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) 
				and mutils.IsInRange(target, bot, nCastRange) == true 
			then
				local nInvUnit = mutils.FindNumInvUnitInLoc(false, target, nRadius, nRadius, target:GetLocation());
				local  creeps = target:GetNearbyCreeps(nRadius, false);
				if nInvUnit >= 2 and #creeps <= 3 then
					local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					return BOT_ACTION_DESIRE_HIGH, target:GetLocation(), 'loc';
				end
			end
		end
	else
		local nTotalDamage = nDamage * hitCount;
		if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
		then
			local  enemies = bot:GetNearbyHeroes(nRadius-200, true, BOT_MODE_NONE);
			local  creeps = bot:GetNearbyCreeps(nRadius, true);
			if #enemies > 0 and #creeps <= 2 then
				local cpos = utils.GetTowardsFountainLocation( bot:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, nil, 'notarget';
			end
		end
		
		if mutils.IsGoingOnSomeone(bot)
		then
			local target = bot:GetTarget();
			if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) 
				and mutils.IsInRange(target, bot, nRadius) == true 
			then
				local  enemies = bot:GetNearbyHeroes(nRadius-200, true, BOT_MODE_NONE);
				local  creeps = bot:GetNearbyCreeps(nRadius, true);
				if #enemies >= 2 and #creeps <= 2 then
					local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					return BOT_ACTION_DESIRE_HIGH, nil, 'notarget';
				end
			end
		end
	end
	
	
	
	
	
	
	return BOT_ACTION_DESIRE_NONE, nil;
end
	