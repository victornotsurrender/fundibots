if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile("bots/ability_item_usage_generic" )
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

local castCombo1Desire = 0;
local castCombo2Desire = 0;
local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;
local castDDesire = 0;

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
	castEDesire  = ConsiderE();
	--castRDesire, targetR = ConsiderR();
	castDDesire  = ConsiderD();
	-- ability_item_usage_generic.SwapItemsTest()
	

	
	if castRDesire > 0 then
		castSwapTime = DotaTime();
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
		bot:Action_UseAbility( abilities[3] );
		return
	end
	
	if castDDesire > 0 then
		castSwapTime = DotaTime();
		bot:Action_UseAbility(abilities[4]);		
		return
	end
	
end





function ConsiderQ()
	if not mutils.CanBeCast(abilities[1]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	local nAttackRange = bot:GetAttackRange();
	local nAttackDamage = bot:GetAttackDamage();
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost  = abilities[1]:GetManaCost();
	local nDamage  = abilities[1]:GetSpecialValueInt('base_damage') + abilities[1]:GetSpecialValueInt('attack_factor_tooltip') / 100 *nAttackDamage; 
	-- local nDamage  = abilities[1]:GetSpecialValueInt('base_damage') + nAttackDamage; 
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and mutil.CanKillTarget2(npcEnemy, nDamage, DAMAGE_TYPE_PHYSICAL) or npcEnemy:IsChanneling()
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
	
	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING) 
	and currManaP > 0.45 and  abilities[1]:GetLevel() > 1
	then
	   local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy)
			and npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.80 ) and #tableNearbyAlliedHeroes >=1
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		
	end
	
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0)
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot) ;
		if target ~= nil  then
			local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	
	-- if (mutil.IsRetreating(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING or mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_FARM ) and currManaP > 0.45
	-- then
	   
	
		-- local laneCreeps = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		-- for _,creep in pairs(laneCreeps)
		-- do
			-- if creep:GetHealth() <= nDamage then
				-- return BOT_ACTION_DESIRE_VERYHIGH, creep;
		    -- end
        -- end
	-- end
	
	if (mutil.IsRetreating(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING or mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_FARM ) and abilities[1]:GetLevel() >= 2 and mutils.CanSpamSpell(bot, manaCost)then
		-- local target = mutils.GetVulnerableWeakestUnit(false, true, nCastRange, bot);
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		-- if target ~= nil and target:GetHealth() <= nDamage then
			-- return BOT_ACTION_DESIRE_HIGH, target;
		-- end
		-- target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN and mutils.CanSpamSpell(bot, manaCost)  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( mutils.IsRoshan(npcTarget) and mutils.CanCastOnMagicImmune(npcTarget) and mutils.IsInRange(npcTarget, bot, nCastRange) )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	-- if mutils.IsPushing(bot) and mutils.CanSpamSpell(bot, manaCost)
	-- then
		-- local target = mutils.GetVulnerableWeakestUnit(false, true, nCastRange, bot);
		-- if target ~= nil and target:GetHealth() <= nDamage then
			-- return BOT_ACTION_DESIRE_LOW, target;
		-- end
	-- end
	
	-- if  mutils.IsDefending(bot) and mutils.CanSpamSpell(bot, manaCost)
	-- then
		-- local target = mutils.GetVulnerableWeakestUnit(false, true, nCastRange, bot);
		-- if target ~= nil  then
			-- return BOT_ACTION_DESIRE_LOW, target;
		-- end
	-- end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and #tableNearbyEnemyHeroes == 0
					then 
					return BOT_ACTION_DESIRE_MODERATE,neutral;
				end
			end
		end
	end
	
	-- if npcBot:GetActiveMode() == BOT_MODE_FARM 
	-- then
		-- local npcTarget = npcBot:GetAttackTarget();
		-- if npcTarget ~= nil and not npcTarget:IsBuilding() then
			-- return BOT_ACTION_DESIRE_MODERATE,npcTarget;
		-- end
	-- end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(target, bot, 2*nAttackRange) == false and mutils.IsInRange(target, bot, nCastRange) and not target:IsIllusion()
			and not mutils.IsDisabled(true, target)
		then
			local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, target;
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

	
	
	
	
	
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderW()
	if not mutils.CanBeCast(abilities[2]) or bot:IsRooted() then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[2]:GetCastRange());
	local nCastPoint = abilities[2]:GetCastPoint();
	local manaCost  = abilities[2]:GetManaCost();
	local nAttackRange = bot:GetAttackRange();
	local nAttackDamage = bot:GetAttackDamage();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nDamage  = abilities[1]:GetSpecialValueInt('base_damage') + abilities[1]:GetSpecialValueInt('attack_factor_tooltip') / 100 *nAttackDamage; 
	
	
	if mutils.IsRetreating(bot) 
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 and bot:WasRecentlyDamagedByAnyHero(3.0) then
			local loc = mutils.GetEscapeLoc();
			local furthestUnit = mutils.GetClosestUnitToLocationFrommAll(bot, nCastRange, loc);
			if furthestUnit ~= nil and GetUnitToUnitDistance(furthestUnit, bot) >= 0.3*nCastRange then
				local cpos = utils.GetTowardsFountainLocation( bot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_LOW, furthestUnit;
			end
		end
	end
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and mutil.CanKillTarget2(npcEnemy, nDamage, DAMAGE_TYPE_PHYSICAL) or npcEnemy:IsChanneling()
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	-- if npcBot:GetActiveMode() == BOT_MODE_FARM 
	-- then
		-- local npcTarget = npcBot:GetAttackTarget();
		-- if npcTarget ~= nil and not npcTarget:IsBuilding() then
			-- return BOT_ACTION_DESIRE_MODERATE,npcTarget;
		-- end
	-- end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and #tableNearbyEnemyHeroes == 0
					then 
					return BOT_ACTION_DESIRE_MODERATE,neutral;
				end
			end
		end
	end
	
	
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN and mutils.CanSpamSpell(bot, manaCost)  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( mutils.IsRoshan(npcTarget) and mutils.CanCastOnMagicImmune(npcTarget) and mutils.IsInRange(npcTarget, bot, nCastRange) )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(target, bot, 2*nAttackRange) == false and mutils.IsInRange(target, bot, nCastRange)  and not target:IsIllusion()
		then
			local enemy = target:GetNearbyHeroes(1300, false, BOT_MODE_NONE);
			local ally = target:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
			if enemy ~= nil and  ally ~= nil and #enemy <= #ally then
				local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

function ConsiderE()
	if not mutils.CanBeCast(abilities[3]) 
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nRadius = abilities[3]:GetSpecialValueInt('radius');
	
	if mutils.IsRetreating(bot) 
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes == nil or #tableNearbyEnemyHeroes == 0 ) and bot:WasRecentlyDamagedByAnyHero(3.0) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	-- If we're going after someone
	if mutils.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if mutils.IsValidTarget(npcTarget) and mutils.CanCastOnNonMagicImmune(npcTarget) 
		   and mutils.IsInRange(npcTarget, bot, 1600) == false and mutils.IsInRange(npcTarget, bot, 2500)
		then
			local enemy = bot:GetNearbyHeroes(nRadius + 200, true, BOT_MODE_NONE);
			if #enemy == 0 then
				local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end		

function ConsiderR()
	if not mutils.CanBeCast(abilities[4]) or DotaTime() < castSwapTime + 0.5 then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[4]:GetCastRange());
	local nCastPoint = abilities[4]:GetCastPoint();
	local manaCost  = abilities[4]:GetManaCost();
	local nRadius   = abilities[4]:GetSpecialValueInt( "scepter_radius" );
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local  enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		local loc = mutils.GetEscapeLoc();
		local minDist = GetUnitToLocationDistance(bot, loc);
		local target = nil;
		for i=1, #enemies do
			if enemies[i] ~= nil 
				and GetUnitToUnitDistance(enemies[i], bot) >= nCastRange / 2 and GetUnitToUnitDistance(enemies[i], bot) <= nCastRange
				and mutils.CanCastOnNonMagicImmune(enemies[i]) 
				and GetUnitToLocationDistance(enemies[i], loc) < minDist
			then
				minDist = GetUnitToLocationDistance(enemies[i], loc);
				target = enemies[i];
			end	
		end
		local  allies = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE);
		for i=1, #allies do
			if allies[i] ~= nil and allies[i] ~= bot
				and GetUnitToUnitDistance(allies[i], bot) >= nCastRange / 2 and GetUnitToUnitDistance(allies[i], bot) <= nCastRange
				and mutils.CanCastOnNonMagicImmune(allies[i]) 
				and GetUnitToLocationDistance(allies[i], loc) < minDist
			then
				minDist = GetUnitToLocationDistance(allies[i], loc);
				target = allies[i];
			end	
		end
		
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	local  enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
	
	if DotaTime() > castSwapForChanelling + 1.0 then
		for i=1, #enemies do
			if enemies[i] ~= nil 
				and enemies[i]:IsChanneling()
				and mutils.CanCastOnNonMagicImmune(enemies[i]) 
			then
				return BOT_ACTION_DESIRE_HIGH, enemies[i];
			end	
		end
		castSwapForChanelling = DotaTime();
	end	
	
	local  allies = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_RETREAT);
	
	if DotaTime() > castSwapForSaveCheck + 1.0 then
		for i=1, #allies do
			if allies[i] ~= nil and allies[i] ~= bot
				and mutils.IsRetreating(allies[i])
				and allies[i]:WasRecentlyDamagedByAnyHero(3.0)
				and mutils.CanCastOnNonMagicImmune(allies[i])
				and GetUnitToUnitDistance(ancient, allies[i]) > GetUnitToUnitDistance(ancient, bot) + nCastRange / 2
			then
				return BOT_ACTION_DESIRE_HIGH, allies[i];
			end	
		end
		castSwapForSaveCheck = DotaTime();
	end	
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and target:WasRecentlyDamagedByAnyHero(2.0) == false and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(target, bot, nCastRange/2) == false and mutils.IsInRange(target, bot, nCastRange) == true
			and GetUnitToUnitDistance(eancient, target) < GetUnitToUnitDistance(eancient, bot)
 		then
			if bot:HasScepter() == true then
				return BOT_ACTION_DESIRE_HIGH, target;
			else
				local tAllies = target:GetNearbyHeroes(700, false, BOT_MODE_NONE)
				if #tAllies <= 2 then
					return BOT_ACTION_DESIRE_HIGH, target;
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end



function ConsiderD()
	if not mutils.CanBeCast(abilities[4]) 
	or DotaTime() < castSwapTime + 0.5 
		or abilities[4]:IsHidden() or bot:HasModifier("modifier_item_aghanims_shard") == false
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, 550);
	local nCastPoint = abilities[4]:GetCastPoint();
	local manaCost  = abilities[4]:GetManaCost();
	local nRadius   = abilities[4]:GetSpecialValueInt( "radius" );
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local  enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		local loc = mutils.GetEscapeLoc();
		local minDist = GetUnitToLocationDistance(bot, loc);
		local target = nil;
		for i=1, #enemies do
			if enemies[i] ~= nil 
				and GetUnitToUnitDistance(enemies[i], bot) >= nCastRange / 2 and GetUnitToUnitDistance(enemies[i], bot) <= nCastRange
				and mutils.CanCastOnNonMagicImmune(enemies[i]) 
				and GetUnitToLocationDistance(enemies[i], loc) < minDist
			then
				minDist = GetUnitToLocationDistance(enemies[i], loc);
				target = enemies[i];
			end	
		end
		local  allies = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE);
		for i=1, #allies do
			if allies[i] ~= nil and allies[i] ~= bot
				and GetUnitToUnitDistance(allies[i], bot) >= nCastRange / 2 and GetUnitToUnitDistance(allies[i], bot) <= nCastRange
				and mutils.CanCastOnNonMagicImmune(allies[i]) 
				and GetUnitToLocationDistance(allies[i], loc) < minDist
			then
				minDist = GetUnitToLocationDistance(allies[i], loc);
				target = allies[i];
			end	
		end
		
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	local  enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
	
	if DotaTime() > castSwapForChanelling + 1.0 then
		for i=1, #enemies do
			if enemies[i] ~= nil 
				and enemies[i]:IsChanneling()
				and mutils.CanCastOnNonMagicImmune(enemies[i]) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end	
		end
		castSwapForChanelling = DotaTime();
	end	
	
	local  allies = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_RETREAT);
	
	if DotaTime() > castSwapForSaveCheck + 1.0 then
		for i=1, #allies do
			if allies[i] ~= nil and allies[i] ~= bot
				and mutils.IsRetreating(allies[i])
				and allies[i]:WasRecentlyDamagedByAnyHero(3.0)
				and mutils.CanCastOnNonMagicImmune(allies[i])
				and GetUnitToUnitDistance(ancient, allies[i]) > GetUnitToUnitDistance(ancient, bot) + nCastRange / 2
			then
				return BOT_ACTION_DESIRE_HIGH;
			end	
		end
		castSwapForSaveCheck = DotaTime();
	end	
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and target:WasRecentlyDamagedByAnyHero(2.0) == false and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(target, bot, nCastRange/2) == false and mutils.IsInRange(target, bot, nCastRange) == true
			and GetUnitToUnitDistance(eancient, target) < GetUnitToUnitDistance(eancient, bot)
 		then
			if bot:HasScepter() == true then
				return BOT_ACTION_DESIRE_HIGH;
			else
				local tAllies = target:GetNearbyHeroes(700, false, BOT_MODE_NONE)
				if #tAllies <= 2 then
					return BOT_ACTION_DESIRE_HIGH;
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end
	