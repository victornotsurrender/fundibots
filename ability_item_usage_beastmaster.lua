if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
local mutils = require( "bots/MyUtility")
local abUtils = require("bots/AbilityItemUsageUtility")
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

-- local npcBot = nil;
-- local bot = nil;
local npcBot = GetBot();
local bot = GetBot();

local abilities = {};

local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

local ListRune = {
	RUNE_BOUNTY_1,
	RUNE_BOUNTY_2,
	RUNE_BOUNTY_3,
	RUNE_BOUNTY_4,
	RUNE_POWERUP_1,
	RUNE_POWERUP_2
}


local hawkLocDire = {
	Vector(-3788.000000, -280.000000, 0.000000),
	Vector(-166.000000, -4568.000000, 0.000000),
	GetRuneSpawnLocation(ListRune[1]),
	GetRuneSpawnLocation(ListRune[2]),
	GetRuneSpawnLocation(ListRune[3]),
	GetRuneSpawnLocation(ListRune[4]),
	GetRuneSpawnLocation(ListRune[5]),
	GetRuneSpawnLocation(ListRune[6])
}

local hawkLocRadiant = {
	Vector(-943.000000, 3546.000000, 0.000000),
	Vector(3136.000000, -370.000000, 0.000000),
	GetRuneSpawnLocation(ListRune[1]),
	GetRuneSpawnLocation(ListRune[2]),
	GetRuneSpawnLocation(ListRune[3]),
	GetRuneSpawnLocation(ListRune[4]),
	GetRuneSpawnLocation(ListRune[5]),
	GetRuneSpawnLocation(ListRune[6])
}


function AbilityUsageThink()


	-- if npcBot == nil then npcBot = GetBot(); end
	-- if bot == nil then bot = GetBot(); end
	
	if #abilities == 0 then abilities = mutils.InitiateAbilities(bot, {0,1,2,5}) end
	
	if mutils.CantUseAbility(bot) then return end
	
	-- ability_item_usage_generic.UnImplementedItemUsage();
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	
	castQDesire, targetQ = ConsiderQ();
	castWDesire, targetW = ConsiderW();
	castEDesire, targetE  = ConsiderE();
	castRDesire, targetR = ConsiderR();
	
	
	
	if castRDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[4], targetR);		
		return
	end
	
	if castQDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[1], targetQ);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_UseAbility(abilities[2]);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[3], targetE);		
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
	local nDamage = abilities[1]:GetSpecialValueInt("axe_damage");
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange-100, bot);
		
		if target ~= nil and  mutil.IsDisabled(true, target) then
			
			return BOT_ACTION_DESIRE_HIGH,target:GetLocation();		
		elseif target ~= nil and not mutil.IsDisabled(true, target) then
			
			return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation(target:GetLocation(),nCastRange);
		end
	end
	
	
	
	-- If a mode has set a target, and we can kill them, do it
	local target = bot:GetTarget();
	if mutils.IsValidTarget(target) and mutils.CanCastOnMagicImmune(target) and
	   mutils.CanKillTarget(target, nDamage, DAMAGE_TYPE_PHYSICAL) and mutils.IsInRange(target, bot, nCastRange) 
	then
		return BOT_ACTION_DESIRE_MODERATE, npcBot:GetXUnitsTowardsLocation(target:GetLocation(),nCastRange);
	end
	
	--if we can hit any enemies with regen modifier
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and (npcEnemy:HasModifier("modifier_clarity_potion") or npcEnemy:HasModifier("modifier_flask_healing") )then
			return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation(npcEnemy:GetLocation(),nCastRange);
		end
	end
	
	
	
	-- -- If we're farming and can kill 3+ creeps with LSA
	-- if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		-- local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		-- if ( locationAoE.count >= 3 ) then
			-- return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		-- end
	-- end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and currManaP > 0.45
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW,npcTarget:GetLocation();
		end
	end	
	
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local target = bot:GetAttackTarget();
		if ( mutils.IsRoshan(target) and mutils.CanCastOnMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, target:GetLocation();
		end
	end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and  tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					then
						if mutil.IsInRange(neutral,bot,nCastRange) and not mutil.IsInRange(neutral,bot,nCastRange-200)
							then
					return BOT_ACTION_DESIRE_MODERATE,npcBot:GetXUnitsTowardsLocation(neutral:GetLocation(),nCastRange);
				end
			end
		end
	end
	end
	
	
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING)  and currManaP > 0.45
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
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					
					return BOT_ACTION_DESIRE_MODERATE, npcBot:GetXUnitsTowardsLocation(npcEnemy:GetLocation(),nCastRange);
				end
			end
		end
	end
	end
	end
	
	
	if mutils.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) then
			local target = mutils.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(target:GetLocation(),nCastRange);
			end
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and mutils.CanSpamSpell(bot, manaCost)
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 ) then
			local target = mutils.GetVulnerableUnitNearLoc(false, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(target:GetLocation(),nCastRange);
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		local npcTarget = npcBot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) 
		and mutils.IsInRange(target, bot, nCastRange) and not mutil.IsSuspiciousIllusion(target)
		and  mutil.IsDisabled(true, npcTarget) and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			
		return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		elseif  mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) 
		and mutils.IsInRange(target, bot, nCastRange) and not mutil.IsDisabled(true, npcTarget) and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			
			return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(target:GetLocation(),nCastRange);
		end
	end
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange+200, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderW()
	if not mutils.CanBeCast(abilities[2]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local manaCost  = abilities[1]:GetManaCost();
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies > 0 then	
			return BOT_ACTION_DESIRE_HIGH, nil;
		end
	end
	
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING) and mutils.CanSpamSpell(bot, manaCost)
	then
		local creeps = bot:GetNearbyCreeps(600, true);
		if #creeps > 0 then	
			return BOT_ACTION_DESIRE_HIGH, nil;
		end
	end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW,nil;
		end
	end	
	
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnMagicImmune(target) and mutils.IsInRange(target, bot, 1000)
		then
			return BOT_ACTION_DESIRE_HIGH, nil;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

function ConsiderE()
	if not mutils.CanBeCast(abilities[3]) 
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local roll = RandomInt(1,8);
	if GetTeam() == TEAM_RADIANT then
		return BOT_ACTION_DESIRE_MODERATE, hawkLocRadiant[roll];
	else
		return BOT_ACTION_DESIRE_MODERATE, hawkLocDire[roll];
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
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil and not mutil.IsSuspiciousIllusion(target)
		then
			
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300)
	then
		local target = mutils.GetStrongestUnit(nCastRange, bot, true, false, 5.0);
		if target ~= nil and not mutil.IsSuspiciousIllusion(target) then
			
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	
	
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING)  and currManaP > 0.45
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
									
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
	end
	end
	end
	-- end
	
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) 
		and mutils.IsInRange(target, bot, nCastRange+200) and not mutils.IsDisabled(true, target)
		and not mutil.IsSuspiciousIllusion(target)
		then
			local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end
	