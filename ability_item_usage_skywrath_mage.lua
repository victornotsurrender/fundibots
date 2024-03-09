local bot = GetBot();
local npcBot = GetBot();

if bot:IsInvulnerable() or bot:IsHero() == false or bot:IsIllusion() then return; end
if npcBot:IsInvulnerable() or npcBot:IsHero() == false or npcBot:IsIllusion() then return; end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
local mutils =  require("bots/MyUtility")
local mutil =  require("bots/MyUtility")

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

local abilities = mutils.InitiateAbilities(bot, {0,1,2,5});

local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

local function CanCastOnCreep(unit)
	return unit:CanBeSeen() and unit:IsMagicImmune() == false and unit:IsInvulnerable() == false; 
end

local function GetReservedMana(ability_idx)
	local reserved = 0;
	for i=1, #abilities do
		if i~=ability_idx  
			and ( mutils.CanBeCast(abilities[i]) == true
			or ( abilities[i]:IsTrained() and abilities[i]:GetCooldownTimeRemaining() < 3 ) ) 
		then
			reserved = reserved + abilities[i]:GetManaCost();
		end	
	end
	return reserved;
end

local function ConsiderQ()
	if  mutils.CanBeCast(abilities[1]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost   = abilities[1]:GetManaCost();
	local nDamage   = abilities[1]:GetSpecialValueFloat('bolt_damage')+bot:GetAttributeValue(ATTRIBUTE_INTELLECT)*abilities[1]:GetSpecialValueFloat('int_multiplier');
	local nRadius    = abilities[1]:GetSpecialValueInt('scepter_radius');
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	
	
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and mutil.CanKillTarget2(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) 
		then
			return BOT_ACTION_DESIRE_HIGH,npcEnemy;
		end
	end
	
	--if we can hit any enemies with regen modifier
	-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and (npcEnemy:HasModifier("modifier_clarity_potion") or npcEnemy:HasModifier("modifier_flask_healing") )then
			return BOT_ACTION_DESIRE_HIGH,npcEnemy;
		end
	end
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) ) or 
		( bot:GetActiveMode() == BOT_MODE_LANING and abilities[1]:GetLevel() >= 2 and mutils.CanSpamSpell(bot, manaCost) )
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and  mutils.CanSpamSpell(bot, manaCost) and abilities[1]:GetLevel() > 3
	then
		local creeps = bot:GetNearbyLaneCreeps(nCastRange, true);
		for i=1, #creeps do
			if creeps[i] ~= nil 
				and CanCastOnCreep(creeps[i]) == true
				and nDamage > creeps[i]:GetHealth()
			then	
				return BOT_ACTION_DESIRE_MODERATE, creeps[i];
			end
		end
		local heroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		for i=1, #heroes do
			if mutils.IsValidTarget(heroes[i]) 
				and mutils.CanCastOnNonMagicImmune(heroes[i]) 
			then	
				return BOT_ACTION_DESIRE_MODERATE, heroes[i];
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(target, bot, nCastRange)
			and bot:GetMana() > GetReservedMana(1)
		then
			local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	

local function ConsiderW()
	if  mutils.CanBeCast(abilities[2]) == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastPoint = abilities[2]:GetCastPoint();
	local manaCost   = abilities[2]:GetManaCost();
	local nRadius    = abilities[2]:GetSpecialValueInt('slow_radius');
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[2]:GetCastRange());
	local nDamage   = abilities[2]:GetSpecialValueInt("damage");
	local nManaCost   = abilities[2]:GetManaCost();
	
	
	if nCastRange > 1600 then nCastRange = 1600 end
	
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
					
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
		end
	end
	end
	end
	
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and mutil.CanKillTarget2(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) or npcEnemy:IsChanneling()
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	--if we can hit any enemies with regen modifier
	-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and (npcEnemy:HasModifier("modifier_clarity_potion") or npcEnemy:HasModifier("modifier_flask_healing") )then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING)
	and mutil.AllowedToSpam(npcBot, nManaCost)
	then
	   local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy)
			and npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.80 ) and #tableNearbyAlliedHeroes >= 1
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
		
	end
	
	
	
	if  mutils.IsRetreating(bot) 
		and bot:WasRecentlyDamagedByAnyHero(4.0) 
	then
		local enemies=bot:GetNearbyHeroes(nCastRange,true,BOT_MODE_NONE);
		if #enemies > 0 then
			local cpos = utils.GetTowardsFountainLocation(bot:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE;
		end	
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target)
			and mutils.IsInRange(target, bot, nCastRange) 
			and mutils.IsDisabled(true, target) == false
		then
			local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderE()
	if  mutils.CanBeCast(abilities[3]) == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastPoint = abilities[3]:GetCastPoint();
	local manaCost   = abilities[3]:GetManaCost();
	local nDamage    = abilities[3]:GetSpecialValueInt('damage');
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[3]:GetCastRange());
	
	local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	for i=1, #enemies do
		if mutils.IsValidTarget(enemies[i]) 
			and mutils.CanCastOnNonMagicImmune(enemies[i])
			and enemies[i]:IsChanneling() == true
		then
			return BOT_ACTION_DESIRE_HIGH, enemies[i];
		end	
	end
	
	if  mutils.IsRetreating(bot) 
		and bot:WasRecentlyDamagedByAnyHero(4.0) 
	then
		local target = mutils.GetStrongestUnit(nCastRange, bot, true, false, 5.0);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target)
			and mutils.IsInRange(target, bot, nCastRange) 
			and mutils.IsDisabled(true, target) == false
		then
			local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderR()
	if  mutils.CanBeCast(abilities[4]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[4]:GetCastRange());
	local nCastPoint = abilities[4]:GetCastPoint();
	local nRadius   = abilities[4]:GetSpecialValueInt( "radius" );
	
	if  mutils.IsRetreating(bot) 
		and bot:WasRecentlyDamagedByAnyHero(4.0) 
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
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
	
	
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target)
			and mutils.IsInRange(target, bot, nCastRange) 
			and (not mutil.StillHasModifier(target, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(target, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			if target:IsRooted() or target:IsStunned() then
				local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, target:GetLocation();
			elseif target:GetCurrentMovementSpeed() < target:GetBaseMovementSpeed() then
				local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, target:GetExtrapolatedLocation(nCastPoint);
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
	castWDesire			 = ConsiderW();
	castEDesire, eTarget = ConsiderE();
	castRDesire, rTarget = ConsiderR();
	
	
	
	if castQDesire > 0 then	
		bot:Action_UseAbilityOnEntity(abilities[1], qTarget);
		return
	end
	
	if castWDesire > 0 then
		bot:Action_UseAbility(abilities[2]);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[3], eTarget);		
		return
	end
	
	if castRDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[4], rTarget);	
		return
	end
	
end