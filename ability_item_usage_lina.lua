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
	castWDesire, targetW = ConsiderW();
	-- castEDesire, targetE  = ConsiderE();
	castRDesire, targetR = ConsiderR();
	
	-- ability_item_usage_generic.SwapItemsTest()
	
	if castQDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[1], targetQ);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[2], targetW);		
		return
	end
	
	if castRDesire > 0 then
		castSwapTime = DotaTime();
		bot:Action_UseAbilityOnEntity(abilities[4], targetR);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_UseAbilityOnEntity( abilities[3], targetE );
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
	local nManaCost  = abilities[1]:GetManaCost();
	local nRadius   = abilities[1]:GetSpecialValueInt( "dragon_slave_width_end" );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nDamage = abilities[1]:GetAbilityDamage()
	
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
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
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) or bot:GetActiveMode() == BOT_MODE_LANING or bot:GetActiveMode() == BOT_MODE_FARM) and mutils.CanSpamSpell(bot, manaCost) and currManaP > 0.45
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 ) then
			local target = mutils.GetVulnerableUnitNearLoc(false, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			if target ~= nil and abilities[1]:GetLevel() > 1 then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
		end
	end
	
	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
	   local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange , true, BOT_MODE_NONE );
		local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy)
			and npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.80 ) and #tableNearbyAlliedHeroes >=1 and abilities[1]:GetLevel() > 1
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
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
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN and mutils.CanSpamSpell(bot, manaCost)  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( mutils.IsRoshan(npcTarget) and mutils.CanCastOnMagicImmune(npcTarget) and mutils.IsInRange(npcTarget, bot, nCastRange) 
            and not mutils.IsDisabled(true, npcTarget) )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and currManaP > 0.45
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  or npcBot:GetActiveMode() == BOT_MODE_LANING and currManaP > 0.45
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
		local enemyCreeps = bot:GetNearbyLaneCreeps(1600, true);
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 2 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=2
					then 
					return BOT_ACTION_DESIRE_MODERATE,neutral:GetLocation();
				else
			if enemyCreeps ~= nil and #enemyCreeps >= 2 then
					for _,creep in pairs(enemyCreeps)
				do
					if creep:CanBeSeen() and creep:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and enemyCreeps ~= nil and #enemyCreeps >=2
					then 
					return BOT_ACTION_DESIRE_MODERATE,creep:GetLocation();
				end
			end
		end
	end
	end
	end
	end 
	
	
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
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					
					return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
				end
			end
		end
	end
	end
	end
	
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange+200) and not mutils.IsDisabled(true, target)
		and (not mutil.StillHasModifier(target, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(target, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
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
	local nManaCost  = abilities[2]:GetManaCost();
	local nRadius   = abilities[2]:GetSpecialValueInt( "light_strike_array_aoe" );
	local nDelay   = abilities[2]:GetSpecialValueInt( "light_strike_array_delay_time" );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nDamage =	abilities[2]:GetSpecialValueInt( "light_strike_array_damage" );
	
	
	
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
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					
					return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
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
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) then
			local target = mutils.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			if target ~= nil then
				local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
		end
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
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
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and currManaP > 0.45
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  or npcBot:GetActiveMode() == BOT_MODE_LANING and currManaP > 0.45
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
		local enemyCreeps = bot:GetNearbyLaneCreeps(1600, true);
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 2 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=2
					then 
					return BOT_ACTION_DESIRE_MODERATE,neutral:GetLocation();
				else
			if enemyCreeps ~= nil and #enemyCreeps >= 2 then
					for _,creep in pairs(enemyCreeps)
				do
					if creep:CanBeSeen() and creep:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and enemyCreeps ~= nil and #enemyCreeps >=2
					then 
					return BOT_ACTION_DESIRE_MODERATE,creep:GetLocation();
				end
			end
		end
	end
	end
	end
	end 
	
	
	
	
	
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN and mutils.CanSpamSpell(bot, manaCost)  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( mutils.IsRoshan(npcTarget) and mutils.CanCastOnMagicImmune(npcTarget) and mutils.IsInRange(npcTarget, bot, nCastRange) 
            and not mutils.IsDisabled(true, npcTarget) )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) or bot:GetActiveMode() == BOT_MODE_LANING ) and mutils.CanSpamSpell(bot, manaCost)
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 6 ) then
			local target = mutils.GetVulnerableUnitNearLoc(false, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
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
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, bot:GetAttackRange()+100) and not mutils.IsDisabled(true, target)
		and (not mutil.StillHasModifier(target, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(target, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )then
			local moveCon = target:GetMovementDirectionStability();
			local pLoc = target:GetExtrapolatedLocation( nCastPoint + nDelay );
			-- if moveCon < 1 then
				-- pLoc = target:GetLocation();
			-- end
			local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, pLoc;
		end
	end
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange-100, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
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
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[4]:GetCastRange());
	local nCastPoint = abilities[4]:GetCastPoint();
	local manaCost  = abilities[4]:GetManaCost();
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300)
	then
		local target = mutils.GetStrongestUnit(nCastRange, bot, true, false, 5.0);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange+200) 
			and target:HasModifier('modifier_templar_assassin_refraction_absorb') == false
		then
			local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end
	