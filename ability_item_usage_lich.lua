if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
local mutil = require("bots/MyUtility")
local mutils = require("bots/MyUtility")
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

local castCombo1Desire = 0;
local castCombo2Desire = 0;
local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

local lastCheck = -90;

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
		bot:Action_UseAbilityOnEntity(abilities[4], targetR);		
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
		local typeAOE = mutils.CheckFlag(abilities[3]:GetBehavior(), ABILITY_BEHAVIOR_POINT);
		if typeAOE == true then
			bot:Action_UseAbilityOnLocation( abilities[3], targetE:GetLocation() );
		else
			bot:Action_UseAbilityOnEntity( abilities[3], targetE );
		end	
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
	local nDamage = abilities[1]:GetAbilityDamage() + abilities[1]:GetSpecialValueInt("aoe_damage");
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	
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
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_LANING and mutils.CanSpamSpell(bot, manaCost)then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
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
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and mutils.CanSpamSpell(bot, manaCost)
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 8 ) then
			local target = mutils.GetVulnerableUnitNearLoc(false, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and currManaP > 0.45
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
		local npcTarget = mutils.GetVulnerableUnitNearLoc(false, true, nCastRange, nRadius, locationAoE.targetloc, bot);
		if npcTarget ~= nil  then
			return BOT_ACTION_DESIRE_MODERATE,npcTarget;
		end
	end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange)
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
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[2]:GetCastRange());
	local nCastPoint = abilities[2]:GetCastPoint();
	local manaCost  = abilities[2]:GetManaCost();
	local nRadius   = abilities[2]:GetSpecialValueInt( "radius" );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		if abilities[1]:IsFullyCastable() == false and mutils.CanCastOnNonMagicImmune(bot) then
			local cpos = utils.GetTowardsFountainLocation( bot:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
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
	
	
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcBot;
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
	
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nRadius-100 );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and  tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					then 
					return BOT_ACTION_DESIRE_MODERATE,npcBot;
				end
			end
		end
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
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[3]:GetCastRange());
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutils.CanCastOnNonMagicImmune(npcEnemy) and  npcEnemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( mutils.IsRoshan(npcTarget) and mutils.CanCastOnMagicImmune(npcTarget) and mutils.IsInRange(npcTarget, bot, nCastRange) 
            and not mutils.IsDisabled(true, npcTarget) )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end

	if mutils.IsInTeamFight(bot, 1200)
	then
		local highesAD = 0;
		local highesADUnit = nil;
		
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			local EnemyAD = npcEnemy:GetAttackDamage();
			if ( mutils.CanCastOnNonMagicImmune(npcEnemy) and not mutils.IsDisabled(true, npcEnemy) and
				 EnemyAD > highesAD ) 
			then
				highesAD = EnemyAD;
				highesADUnit = npcEnemy;
			end
		end
		
		if highesADUnit ~= nil then
			return BOT_ACTION_DESIRE_HIGH, highesADUnit;
		end
	end
	
	
	
	
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
					local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
	end
	end
	end
	
	
	
	
	
	
	-- If we're going after someone
	if mutils.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if mutils.IsValidTarget(npcTarget) and mutils.CanCastOnNonMagicImmune(npcTarget) and mutils.IsInRange(npcTarget, bot, nCastRange + 200) 
		   and not mutils.IsDisabled(true, npcTarget)
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
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
	local nRadius   = abilities[4]:GetSpecialValueInt( "jump_range" );
	local nManaCost  = abilities[4]:GetManaCost();
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
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
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) then
			local target = mutils.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end
	
	
	
	
	-- -- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	-- if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) and npcBot:DistanceFromFountain() < 7500
	-- then
		-- local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nCastRange, true );
		-- for _,npcCreepTarget in pairs(tableNearbyEnemyCreeps) do
			-- if ( mutil.IsInRange(npcTarget, npcBot, nCastRange) and #tableNearbyEnemyCreeps >= 16 ) 
			-- then
				-- return BOT_ACTION_DESIRE_MODERATE, npcCreepTarget;
			-- end
		-- end
	-- end
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
	   local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	   local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nCastRange, true );
	local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy)
			and npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.80 ) and #tableNearbyAlliedHeroes >=1 and #tableNearbyEnemyCreeps >= 3
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		
	end
	
	
	
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange)
		then
			local enemies = target:GetNearbyHeroes( nRadius-200, false, BOT_MODE_NONE );
			local nInvUnit = mutils.CountInvUnits(false, enemies);
			if nInvUnit >= 2 then
				local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end
	