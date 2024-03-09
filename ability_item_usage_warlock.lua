local bot = GetBot();
local npcBot = GetBot();

if bot:IsInvulnerable() or bot:IsHero() == false or bot:IsIllusion() then return; end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
local mutils = require("bots/MyUtility")
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

--[[ Abilities
"Ability1"		"warlock_fatal_bonds"
"Ability2"		"warlock_shadow_word"
"Ability3"		"warlock_upheaval"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"warlock_rain_of_chaos"
"Ability10"		"special_bonus_unique_warlock_5"
"Ability11"		"special_bonus_cast_range_125"
"Ability12"		"special_bonus_exp_boost_40"
"Ability13"		"special_bonus_unique_warlock_3"
"Ability14"		"special_bonus_unique_warlock_4"
"Ability15"		"special_bonus_unique_warlock_6"
"Ability16"		"special_bonus_unique_warlock_2"
"Ability17"		"special_bonus_unique_warlock_1"
]]

--[[
modifier_warlock_fatal_bonds
modifier_warlock_shadow_word
modifier_warlock_upheaval
modifier_warlock_rain_of_chaos_death_trigger
modifier_warlock_rain_of_chaos_thinker
modifier_special_bonus_unique_warlock_1
modifier_special_bonus_unique_warlock_2
modifier_warlock_golem_flaming_fists
modifier_warlock_golem_permanent_immolation
modifier_warlock_golem_permanent_immolation_debuff
]]--

local abilities = mutils.InitiateAbilities(bot, {0,1,2,5,11});

local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

local castRefresher = 0;

-- local abilityWW = nil


local function ConsiderQ()

	

	if  mutils.CanBeCast(abilities[1]) == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost   = abilities[1]:GetManaCost();
	local nRadius    = abilities[1]:GetSpecialValueInt( "search_aoe" );
	local nCount     = abilities[1]:GetSpecialValueInt( "count" );
	
	if mutils.IsRetreating(bot)
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil and mutils.GetUnitCountAroundEnemyTarget(target, nRadius) >= nCount/2 then
				local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	-- local npcTarget = npcBot:GetTarget();
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) and abilities[1]:GetLevel () >= 2 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nCastRange, true );
		for _,creep in pairs(tableNearbyEnemyCreeps) do
			if ( mutil.IsInRange(creep, npcBot, nCastRange) and #tableNearbyEnemyHeroes == 0 and npcBot:GetMana()/npcBot:GetMaxMana() > 0.7 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, creep;
			end
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_MODERATE,npcTarget;
		end
	end

	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange) 
		then
			if mutils.GetUnitCountAroundEnemyTarget(target, nRadius) >= nCount/2 then
				local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil;
end

local lastCheck = -90;
local function ConsiderW()
	if  mutils.CanBeCast(abilities[2]) == false then
		return BOT_ACTION_DESIRE_NONE, "", nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[2]:GetCastRange());
	local nCastPoint = abilities[2]:GetCastPoint();
	local manaCost   = abilities[2]:GetManaCost();
	local nRadius    = 0;
	
	-- if abilityWW:IsTrained()  then nRadius = 250 end
	if bot:HasModifier("modifier_item_aghanims_shard")   then nRadius = 450 end
	
	if DotaTime() >= lastCheck + 2.0 then 
		local weakest = nil;
		local minHP = 100000;
		local allies = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE);
		if #allies > 0 then
			for i=1,#allies do
				if allies[i]:HasModifier("modifier_warlock_shadow_word") == false
				   and mutils.CanCastOnNonMagicImmune(allies[i]) 
				   and allies[i]:GetHealth() <= minHP
     			   and allies[i]:GetHealth() <= 0.55*allies[i]:GetMaxHealth()  
				then
					weakest = allies[i];
					minHP = allies[i]:GetHealth();
				end
			end
		end
		if weakest ~= nil then
			-- if abilities[5]:IsTrained() and abilityWW:IsTrained() then
			-- if  abilityWW:IsTrained() then
			if  bot:HasModifier("modifier_item_aghanims_shard")  then
				return BOT_ACTION_DESIRE_HIGH, "loc", weakest:GetLocation();
			else
				return BOT_ACTION_DESIRE_HIGH, "unit", weakest;
			end
		end
		lastCheck = DotaTime();
	end
	
	-- if mutils.IsInTeamFight(bot, 1200) and abilities[5]:IsTrained()  and abilityWW:IsTrained()
	if mutils.IsInTeamFight(bot, 1200) 
	-- and abilityWW:IsTrained()
	and bot:HasModifier("modifier_item_aghanims_shard")
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, "loc", locationAoE.targetloc;
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) 
		and mutil.IsInRange(npcTarget, npcBot, nCastRange) and npcTarget:HasModifier("modifier_warlock_shadow_word") == false  )
		then
			return BOT_ACTION_DESIRE_LOW,"unit", npcTarget;
		end
	end
	
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	local npcTarget = npcBot:GetTarget();
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) and abilities[2]:GetLevel () >= 2 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nCastRange, true );
		for _,npcCreepTarget in pairs(tableNearbyEnemyCreeps) do
			if ( mutil.IsInRange(npcTarget, npcBot, nCastRange) and #tableNearbyEnemyHeroes == 0 and #tableNearbyEnemyCreeps >= 4  
			and npcCreepTarget:HasModifier("modifier_warlock_fatal_bonds")  and npcCreepTarget:HasModifier("modifier_warlock_shadow_word") == false) 
			then
				
				return BOT_ACTION_DESIRE_MODERATE,"unit", npcCreepTarget;
			end
		end
	end
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() and npcTarget:HasModifier("modifier_warlock_shadow_word") == false
		then
			return BOT_ACTION_DESIRE_HIGH, "unit", npcTarget;
		end
	end	
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange) 
		   and target:HasModifier("modifier_warlock_shadow_word") == false
		then
			-- if abilities[5]:IsTrained() and abilityWW:IsTrained() then
			-- if abilityWW:IsTrained() then
			if bot:HasModifier("modifier_item_aghanims_shard") then
				local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, "loc", target:GetLocation();
			else
				local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, "unit", target;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, "", nil;
end

local function GetTotalMana(slot)
	local total = 0;
	for i=1,#slot do
		total = total + abilities[slot[i]]:GetManaCost();
	end
	return total;
end

local function ConsiderE()
	if not mutils.CanBeCast(abilities[3]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	if abilities[4]:IsFullyCastable() and bot:GetMana() >= GetTotalMana({3,4}) then
		return BOT_ACTION_DESIRE_NONE, nil;
	elseif abilities[4]:IsFullyCastable() == false 	
		   and abilities[1]:IsFullyCastable() 
		   and abilities[2]:IsFullyCastable() 
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[3]:GetCastRange());
	local nCastPoint = abilities[3]:GetCastPoint();
	local manaCost   = abilities[3]:GetManaCost();
	local nRadius    = abilities[3]:GetSpecialValueInt( "aoe" );
	
	if mutils.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	-- If we're going after someone
	if mutils.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if mutils.IsValidTarget(npcTarget) and mutils.CanCastOnNonMagicImmune(npcTarget) and mutils.IsInRange(npcTarget, bot, nCastRange + 200) 
		then
			local enemies = npcTarget:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
			if #enemies >= 2 then
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(nCastPoint);
			end	
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

local function ConsiderR()
	if not mutils.CanBeCast(abilities[4]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	if abilities[1]:IsFullyCastable() and bot:GetMana() >= GetTotalMana({1,3,4}) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[4]:GetCastRange());
	local nCastPoint = abilities[4]:GetCastPoint();
	local manaCost   = abilities[4]:GetManaCost();
	local nRadius    = abilities[4]:GetSpecialValueInt( "aoe" );
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
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
	local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_ATTACK );
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy)
			and #tableNearbyAlliedHeroes>=2 ) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
			end
		end
	end
	
	if mutils.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange/2)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange/2) 
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function AbilityUsageThink()
	
	if mutils.CantUseAbility(bot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	
	-- if abilityWW == nil then abilityWW = npcBot:GetAbilityByName( "special_bonus_unique_warlock_6" ) end
	
	castQDesire, qTarget 		= ConsiderQ();
	castWDesire, wType, wTarget = ConsiderW();
	castEDesire, eTarget 		= ConsiderE();
	castRDesire, rTarget        = ConsiderR();
	
	
	
	if castRDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[4], rTarget);		
		return
	end
	
	if castQDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[1], qTarget);		
		return
	end
	
	if castWDesire > 0 then
		if wType == "loc" then
			bot:Action_UseAbilityOnLocation(abilities[2], wTarget);
		else
			bot:Action_UseAbilityOnEntity(abilities[2], wTarget);	
		end	
		return
	end
	
	if castEDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[3], eTarget);		
		return
	end
	
end