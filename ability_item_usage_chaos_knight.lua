local bot = GetBot();
local npcBot = GetBot();

if bot:IsInvulnerable() or bot:IsHero() == false or bot:IsIllusion() then return; end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
local mutils = require( "bots/MyUtility")
local mutil = require( "bots/MyUtility")

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

--[[
"Ability1"		"chaos_knight_chaos_bolt"
"Ability2"		"chaos_knight_reality_rift"
"Ability3"		"chaos_knight_chaos_strike"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"chaos_knight_phantasm"
"Ability10"		"special_bonus_all_stats_5"
"Ability11"		"special_bonus_movement_speed_20"
"Ability12"		"special_bonus_strength_15"
"Ability13"		"special_bonus_cooldown_reduction_12"
"Ability14"		"special_bonus_gold_income_25"
"Ability15"		"special_bonus_unique_chaos_knight"
"Ability16"		"special_bonus_unique_chaos_knight_2"
"Ability17"		"special_bonus_unique_chaos_knight_3"
]]--

--[[
modifier_chaos_knight_reality_rift
modifier_chaos_knight_chaos_strike
modifier_chaos_knight_chaos_strike_debuff
modifier_chaos_knight_phantasm
]]--

local abilities = mutils.InitiateAbilities(bot, {0,1,2,5});

print(tostring(bot:GetPlayerID())..":"..tostring(abilities[1]));

local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

local function ConsiderQ()
	if  mutils.CanBeCast(abilities[1]) == false or mutil.CanNotBeCast(npcBot) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost   = abilities[1]:GetManaCost();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nDamage = abilities[1]:GetSpecialValueInt( "damage_min") * 1.25;
	
	
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

	local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);	
	if #enemies > 0 then
		for i=1, #enemies do
			if mutils.CanCastOnNonMagicImmune(enemies[i]) and enemies[i]:IsChanneling()
			   or enemies[i]:HasModifier("modifier_teleporting") == true 
			then
				return BOT_ACTION_DESIRE_LOW, enemies[i];
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN and mutils.CanSpamSpell(bot, manaCost) then
		local target =  bot:GetAttackTarget();
		if target ~= nil then
			return BOT_ACTION_DESIRE_LOW, target;
		end
	end
	
	if mutils.IsRetreating(bot) then
		if #enemies > 0 then
			local target = nil;
			local maxDmg = 0;	
			for i=1, #enemies do	
				local estDmg = enemies[i]:GetEstimatedDamageToTarget(true, bot, 2.0, DAMAGE_TYPE_ALL);
				if mutils.CanCastOnNonMagicImmune(enemies[i]) 
				   and estDmg >= maxDmg 
				   and enemies[i]:GetAttackTarget() ~= nil
				then
					target = enemies[i];
					maxAD  = estDmg;
				end
			end
			if target ~= nil then
				local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive()  and #tableNearbyEnemyHeroes == 0 
					then 
					return BOT_ACTION_DESIRE_MODERATE,neutral;
				end
			end
		end
	end
	
	
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING or npcBot:GetActiveMode() == BOT_MODE_FARM)  
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
	
	
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange) 
		   and mutils.IsDisabled(true, target) == false and not mutil.IsSuspiciousIllusion(target)
		then
			local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderW()
	if  mutils.CanBeCast(abilities[2]) == false or mutil.CanNotBeCast(npcBot) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[2]:GetCastRange());
	local nCastPoint = abilities[2]:GetCastPoint();
	local manaCost   = abilities[2]:GetManaCost();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();

	if mutils.IsRetreating(bot) then
		local loc = mutils.GetEscapeLoc();
		local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		local creeps  = bot:GetNearbyLaneCreeps(nCastRange, true);
		local target = nil;
		local minDist = 100000;
		if #enemies > 0 then
			for i=1, #enemies do
				local dist = GetUnitToLocationDistance(enemies[i], loc);
				if mutils.CanCastOnNonMagicImmune(enemies[i]) and dist <= minDist then
					target = enemies[1];
					minDist = dist;
				end
			end
		end
		if #creeps > 0 then
			for i=1, #creeps do
				local dist = GetUnitToLocationDistance(creeps[i], loc);
				if mutils.CanCastOnNonMagicImmune(creeps[i]) and dist <= minDist then
					target = creeps[1];
					minDist = dist;
				end
			end
		end
		if target ~= nil and GetUnitToUnitDistance(bot, target) >= 0.5*nCastRange and minDist < GetUnitToLocationDistance(bot, loc) then
			return BOT_ACTION_DESIRE_NONE, target;
		end
	end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 
				and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					then 
					return BOT_ACTION_DESIRE_MODERATE,neutral[1];
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN and mutils.CanSpamSpell(bot, manaCost) then
		local target =  bot:GetAttackTarget();
		if target ~= nil then
			return BOT_ACTION_DESIRE_LOW, target;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) 
		   and mutils.IsInRange(target, bot, bot:GetAttackRange()) == false and mutils.IsInRange(target, bot, nCastRange) 
		   and not mutil.IsSuspiciousIllusion(target)
		then
			local allies  = target:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
			local enemies = target:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE);
			if #allies >= #enemies then
				local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end
	
	
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING or npcBot:GetActiveMode() == BOT_MODE_FARM)  
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
				-- local distance = GetUnitToUnitDistance(npcEnemy, bot)
				-- local moveCon = npcEnemy:GetMovementDirectionStability();
				-- local pLoc = npcEnemy:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
				-- if moveCon < 1  then
					-- pLoc = npcEnemy:GetLocation();
				-- end
				-- if mutils.IsAllyHeroBetweenMeAndTarget(bot, npcEnemy, pLoc, nRadius) == false 
					-- and mutils.IsCreepBetweenMeAndTarget(bot, npcEnemy, pLoc, nRadius) == false
				-- then
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
	end
	end
	end
	-- end
	
	
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderR()
	if  mutils.CanBeCast(abilities[4]) == false or mutil.CanNotBeCast(npcBot) then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	
	
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 )  ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	if mutils.IsInTeamFight(bot, 1200) and bot:GetActiveMode() ~= BOT_MODE_RETREAT then
		local enemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
		if #enemies >= 2 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if ( mutils.IsPushing(bot) )
	then
		local target = bot:GetAttackTarget();
		local towers = bot:GetNearbyTowers(1000, true);
		if target ~= nil and target:IsBuilding() and #towers > 0 then
			local allies = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
			local creeps = bot:GetNearbyLaneCreeps(1000, false);
			if #allies >= 2 and #creeps >= 5 then
				return BOT_ACTION_DESIRE_HIGH;
			end	
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	

function AbilityUsageThink()
	
	if mutils.CantUseAbility(bot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	castQDesire, qTarget = ConsiderQ();
	castWDesire, wTarget = ConsiderW();
	castRDesire	         = ConsiderR();
	
	
	
	if castRDesire > 0 then
		bot:Action_UseAbility(abilities[4]);		
		return
	end
	
	if castQDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[1], qTarget);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[2], wTarget);	
		return
	end
	
end