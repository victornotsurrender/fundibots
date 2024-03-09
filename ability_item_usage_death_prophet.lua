local bot = GetBot();
local npcBot = GetBot();

if bot:IsInvulnerable() or bot:IsHero() == false or GetBot():IsIllusion() then return; end

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

--[[
"Ability1"		"death_prophet_carrion_swarm"
"Ability2"		"death_prophet_silence"
"Ability3"		"death_prophet_spirit_siphon"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"death_prophet_exorcism"
"Ability10"		"special_bonus_attack_damage_50"
"Ability11"		"special_bonus_magic_resistance_12"
"Ability12"		"special_bonus_unique_death_prophet_3"
"Ability13"		"special_bonus_cast_range_150"
"Ability14"		"special_bonus_hp_500"
"Ability15"		"special_bonus_unique_death_prophet_2"
"Ability16"		"special_bonus_unique_death_prophet_4"
"Ability17"		"special_bonus_unique_death_prophet"
]]--

--[[
modifier_death_prophet_witchcraft
modifier_death_prophet_spirit_siphon_charge_counter
modifier_death_prophet_spirit_siphon
modifier_death_prophet_spirit_siphon_slow
modifier_death_prophet_exorcism
]]--

local abilities = mutils.InitiateAbilities(bot, {0,1,2,5});

local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

local spiritCharge = 0;

local function ConsiderQ()

	if  mutils.CanBeCast(abilities[1]) == false or mutil.CanNotBeCast(npcBot) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost   = abilities[1]:GetManaCost();
	local nManaCost   = abilities[1]:GetManaCost();
	local nRadius    = abilities[1]:GetSpecialValueInt( "end_radius" );
	local nSpeed     = abilities[1]:GetSpecialValueInt( "speed" );
	local nDamage    = abilities[1]:GetAbilityDamage();
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
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
				end
			end
		end
	end
	end
	end
	-- end
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and mutil.CanKillTarget2(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) or npcEnemy:IsChanneling()
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	--if we can hit any enemies with regen modifier
	-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and (npcEnemy:HasModifier("modifier_clarity_potion") or npcEnemy:HasModifier("modifier_flask_healing") )then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	
	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
	   local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
		local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy)
			and npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.80 ) and #tableNearbyAlliedHeroes >=1
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
			end
		end
		
	end
	
	
	
	
	if mutils.CanSpamSpell(bot, manaCost) then
		if bot:GetActiveMode() == BOT_MODE_LANING  then
			local target = mutils.GetSpellKillTarget(bot, false, nCastRange, abilities[1]:GetAbilityDamage(), abilities[1]:GetDamageType());
			if target ~= nil and mutils.IsEnemyTargetMyTarget(bot, target) then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
		end
		
		if bot:WasRecentlyDamagedByAnyHero(2.0) 
		then
			local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
			if target ~= nil then
				local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
		end
		
		if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) )
		then
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
			if ( locationAoE.count >= 3 ) then
				local target = mutils.GetVulnerableUnitNearLoc(false, true, nCastRange, nRadius, locationAoE.targetloc, bot);
				if target ~= nil then
					return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
				end
			end
		end
	end
	
	
	
	
	if bot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = bot:GetNearbyNeutralCreeps( nCastRange );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					then 
					-- npcBot:ActionImmediate_Chat("I'm going to make some money creeping", true)
					return BOT_ACTION_DESIRE_MODERATE,neutral:GetLocation();
				end
			end
		end
	end
	
	
	
	if (bot:GetActiveMode() == BOT_MODE_LANING  or  mutils.IsPushing(bot) or  mutils.IsDefending(bot)) and currManaP > 0.80
	then	
		local laneCreeps = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		for _,creep in pairs(laneCreeps)
		do
			if creep:GetHealth() <= nDamage then
				return BOT_ACTION_DESIRE_HIGH, creep:GetLocation ();
		    end
        end
	end
	
	
	
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local target = bot:GetAttackTarget();
		if ( mutils.IsRoshan(target) and mutils.CanCastOnMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, target:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	
	
	
	
	if mutils.IsInTeamFight(bot, 1200) then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			local nInvUnit = mutils.FindNumInvUnitInLoc(true, bot, nCastRange, nRadius, locationAoE.targetloc);
			if nInvUnit >= locationAoE.count then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange) 
		and (not mutil.StillHasModifier(target, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(target, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, target:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange+200, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
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
	local nRadius    = abilities[2]:GetSpecialValueInt( "radius" );
	
	local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
	
	if #enemies > 0 then
		for i=1, #enemies do
			if mutils.CanCastOnNonMagicImmune(enemies[i]) and enemies[i]:IsChanneling()
			   and enemies[i]:HasModifier("modifier_teleporting") == false 
			then
				return BOT_ACTION_DESIRE_LOW, enemies[i]:GetLocation();
			end
		end
	end
	
	if mutils.IsRetreating(bot) then
		if #enemies > 0 then
			for i=1, #enemies do
				if bot:WasRecentlyDamagedByHero(enemies[i], 2.0) and mutils.CanCastOnNonMagicImmune(enemies[i]) then
					return BOT_ACTION_DESIRE_LOW, enemies[i]:GetLocation();
				end
			end
		end
	end
	
	if mutils.IsInTeamFight(bot, 1200) then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			local nInvUnit = mutils.FindNumInvUnitInLoc(true, bot, nCastRange, nRadius, locationAoE.targetloc);
			if nInvUnit >= locationAoE.count then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange) 
		   and mutils.IsDisabled(true, target) == false
		then
			local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, target:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange+200, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderE()
	if  mutils.CanBeCast(abilities[3]) == false or mutil.CanNotBeCast(npcBot) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[3]:GetCastRange());
	local nCastPoint = abilities[3]:GetCastPoint();
	local manaCost   = abilities[3]:GetManaCost();
	
	if mutils.IsRetreating(bot) then
		local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		if #enemies > 0 then
			for i=1, #enemies do
				if bot:WasRecentlyDamagedByHero(enemies[i], 2.0) and mutils.CanCastOnNonMagicImmune(enemies[i]) 
					and enemies[i]:HasModifier("modifier_death_prophet_spirit_siphon_slow") == false  
				then
					local cpos = utils.GetTowardsFountainLocation(enemies[i]:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					return BOT_ACTION_DESIRE_LOW, enemies[i];
				end
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) and bot:GetHealth() <= 0.95*bot:GetMaxHealth() 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange) 
		   and target:HasModifier("modifier_death_prophet_spirit_siphon_slow") == false 
		then
			local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderR()

    local nRadius = abilities[4]:GetSpecialValueInt( "radius" );



	if  mutils.CanBeCast(abilities[4]) == false or bot:HasModifier("modifier_death_prophet_exorcism") 
	or mutil.CanNotBeCast(npcBot) then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if mutils.IsInTeamFight(bot, 1200) and bot:GetActiveMode() ~= BOT_MODE_RETREAT then
		local enemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE);
		if #enemies >= 2 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local target = bot:GetAttackTarget();
		if ( mutils.IsRoshan(target) and mutils.CanCastOnMagicImmune(target) and mutils.IsInRange(target, bot, nRadius)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	
	if ( mutils.IsPushing(bot) )
	then
		local towers = bot:GetNearbyTowers(1000, true);
		if #towers > 0 then
			local allies = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
			local creeps = bot:GetNearbyLaneCreeps(1000, false);
			if #allies >= 2 and #creeps >= 8 then
				return BOT_ACTION_DESIRE_HIGH;
			end	
		end
	end
	
	
	
	if ( mutils.IsDefending(bot) ) then
	 local creeps = bot:GetNearbyLaneCreeps(1000, false);
		if #creeps >= 12 then
			return BOT_ACTION_DESIRE_HIGH;
		end	
	end
	
	
	
	
	
	return BOT_ACTION_DESIRE_NONE;
end	

function AbilityUsageThink()
	
	if mutils.CantUseAbility(bot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	spiritCharge = bot:GetModifierStackCount(bot:GetModifierByName("modifier_death_prophet_spirit_siphon_charge_counter"));
	
	castQDesire, qTarget = ConsiderQ();
	castWDesire, wTarget = ConsiderW();
	castEDesire, eTarget = ConsiderE();
	castRDesire          = ConsiderR();
	
	
	
	if castRDesire > 0 then
		bot:Action_UseAbility(abilities[4]);		
		return
	end
	
	if castQDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[1], qTarget);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[2], wTarget);	
		return
	end
	
	if castEDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[3], eTarget);	
		return
	end
	
end