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

--[[
"Ability1"		"razor_plasma_field"
"Ability2"		"razor_static_link"
"Ability3"		"razor_unstable_current"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"razor_eye_of_the_storm"
"Ability10"		"special_bonus_hp_200"
"Ability11"		"special_bonus_agility_15"
"Ability12"		"special_bonus_unique_razor"
"Ability13"		"special_bonus_unique_razor_3"
"Ability14"		"special_bonus_armor_10"
"Ability15"		"special_bonus_unique_razor_2"
"Ability16"		"special_bonus_attack_speed_100"
"Ability17"		"special_bonus_unique_razor_4"
]]--

--[[
modifier_razor_plasma_field_thinker
modifier_razor_static_link
modifier_razor_static_link_buff
modifier_razor_static_link_debuff
modifier_razor_link_vision
modifier_razor_unstable_current
modifier_razor_unstablecurrent_slow
modifier_razor_eye_of_the_storm
modifier_razor_eye_of_the_storm_armor
]]--

local abilities = mutils.InitiateAbilities(bot, {0,1,2,5});

local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

local function ConsiderQ()
	if  mutils.CanBeCast(abilities[1]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost   = abilities[1]:GetManaCost();
	local nRadius    = abilities[1]:GetSpecialValueInt('radius');
	
	if mutils.IsRetreating(bot) then
		local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and  mutils.CanSpamSpell(bot, manaCost) 
	then
		local creeps = bot:GetNearbyLaneCreeps(nRadius, true);
		if #creeps >= 8 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)  )
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
	
	if mutils.IsInTeamFight(bot, 1200) then
		local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
		if #enemies >= 2 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nRadius) 
		and (not mutil.StillHasModifier(target, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(target, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	

local function ConsiderW()
	if  mutils.CanBeCast(abilities[2]) == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[2]:GetCastRange());
	local nCastPoint = abilities[2]:GetCastPoint();
	local manaCost   = abilities[2]:GetManaCost();
	
	if mutils.IsRetreating(bot) or mutils.IsInTeamFight(bot, 1200) then
		local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		if #enemies > 0 then
			local target = nil;
			local maxAD = 0;	
			for i=1, #enemies do
				if mutils.CanCastOnNonMagicImmune(enemies[i]) and enemies[i]:GetAttackDamage() >= maxAD 
				then
					target = enemies[i];
					maxAD  = enemies[i]:GetAttackDamage();
				end
			end
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
			local allies  = target:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
			local enemies = target:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE);
			if #allies >= #enemies then
				local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderR()
	if  mutils.CanBeCast(abilities[4]) == false and bot:HasModifier("modifier_razor_eye_of_the_storm") == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilities[4]:GetSpecialValueInt('radius');
	
	if mutils.IsInTeamFight(bot, 1200) and bot:GetActiveMode() ~= BOT_MODE_RETREAT then
		local enemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE);
		if #enemies >= 2 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if ( mutils.IsPushing(bot) or  mutils.IsDefending(bot)) and bot:HasScepter()
	then
		local towers   = bot:GetNearbyTowers(nRadius, true);
		local barracks = bot:GetNearbyBarracks(nRadius, true);
		if #towers > 0 or #barracks > 0 then
			local allies = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
			local creeps = bot:GetNearbyLaneCreeps(1000, false);
			if #allies >= 2 and #creeps >= 4 then
				return BOT_ACTION_DESIRE_HIGH;
			end	
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	
	
	return BOT_ACTION_DESIRE_NONE;
end	

function AbilityUsageThink()
	
	if mutils.CantUseAbility(bot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	castQDesire		  	 = ConsiderQ();
	castWDesire, wTarget = ConsiderW();
	castRDesire	         = ConsiderR();
	
	-- ability_item_usage_generic.SwapItemsTest()
	
	if castRDesire > 0 then
		bot:Action_UseAbility(abilities[4]);		
		return
	end
	
	if castQDesire > 0 then
		bot:Action_UseAbility(abilities[1]);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[2], wTarget);	
		return
	end
	
end