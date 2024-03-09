if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
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

local bot = GetBot();
local npcBot = GetBot();

local abilities = {};

local castCombo1Desire = 0;
local castCombo2Desire = 0;
local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

function AbilityUsageThink()
	
	if #abilities == 0 then abilities = abUtils.InitiateAbilities(bot, {0,1,2,5}) end
	
	if abUtils.CantUseAbility(bot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	castQDesire, castQLoc = ConsiderQ();
	castWDesire, castWLoc = ConsiderW();
	castEDesire, ETarget  = ConsiderE();
	castRDesire, castRLoc = ConsiderR();
	
	-- ability_item_usage_generic.SwapItemsTest()
	
	if castWDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[2], castWLoc);		
		return
	end
	
	if castRDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[4], castRLoc);		
		return
	end
	
	if castQDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[1], castQLoc);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_UseAbility(abilities[3]);		
		return
	end
	
end

function ConsiderQ()
	if not abUtils.CanBeCast(abilities[1]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local castRange = abUtils.GetProperCastRange(false, bot, abilities[1]);
	local castPoint = abilities[1]:GetCastPoint();
	local manaCost  = abilities[1]:GetManaCost();
	local nRadius   = abilities[1]:GetSpecialValueInt( "spear_width" );
	local nDuration = 1;
	local nSpeed    = abilities[1]:GetSpecialValueInt('spear_speed');
	local nDamage   = abilities[1]:GetSpecialValueInt('damage');
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nCastPoint = abilities[1]:GetCastPoint( );
	local nManaCost  = abilities[1]:GetManaCost( );
	local nCastRange = abUtils.GetProperCastRange(false, bot, abilities[1]);
	
	local target  = bot:GetTarget(); 
	local enemies = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);
	
	
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

	if abUtils.IsRetreating(bot)
	then
		if #enemies > 0 and bot:WasRecentlyDamagedByAnyHero(2.0) then
			local enemy = abUtils.GetLowestHPUnit(enemies, false);
			if enemy ~= nil then
				local cpos = utils.GetTowardsFountainLocation( enemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
			end	
		end
	end	
	
	if ( abUtils.IsPushing(bot) or abUtils.IsDefending(bot) ) and abUtils.AllowedToSpam(bot, manaCost)
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(castRange, true);
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), castRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and currManaP > 0.45
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	
	
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	
	
	
	if abUtils.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange, nRadius, 0, 0 );
		local unitCount = abUtils.CountVulnerableUnit(enemies, locationAoE, nRadius, 2);
		if ( unitCount >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	if abUtils.IsGoingOnSomeone(bot)
	then
		if abUtils.IsValidTarget(target) and abUtils.CanCastOnNonMagicImmune(target) and abUtils.IsInRange(target, bot, castRange) 
		then
			local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, abUtils.GetProperLocation( target, (GetUnitToUnitDistance(bot, target)/nSpeed)+castPoint );
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange-200, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end

	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderW()
	if not abUtils.CanBeCast(abilities[2]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local castRange = abUtils.GetProperCastRange(false, bot, abilities[2]);
	local castPoint = abilities[2]:GetCastPoint();
	local manaCost  = abilities[2]:GetManaCost();
	local nRadius   = abilities[2]:GetSpecialValueInt( "radius" );
	local nDamage   = bot:GetAttackDamage()*abilities[2]:GetSpecialValueInt('crit_mult')/100;
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nCastPoint = abilities[2]:GetCastPoint( );
	local nManaCost  =abilities[2]:GetManaCost( );
	local ncastRange = abUtils.GetProperCastRange(false, bot, abilities[2]);
	
	
	local target  = bot:GetTarget(); 
	local enemies = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);
	
	if abUtils.IsRetreating(bot)
	then
		if #enemies > 0 and bot:WasRecentlyDamagedByAnyHero(2.0) then
			local enemy = abUtils.GetLowestHPUnit(enemies, false);
			if enemy ~= nil and not abUtils.IsDisabled(true, enemy) then
				return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
			end	
		end
	end	
	
	if ( abUtils.IsPushing(bot) or abUtils.IsDefending(bot) ) and abUtils.AllowedToSpam(bot, manaCost)
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(castRange, true);
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), castRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and currManaP > 0.45
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	-- if npcBot:GetActiveMode() == BOT_MODE_LANING  or  mutil.IsPushing(npcBot) or  mutil.IsDefending(npcBot) and currManaP > 0.80
	-- then
	   
	
		-- local laneCreeps = npcBot:GetNearbyLaneCreeps(nRadius-100, true);
		-- for _,creep in pairs(laneCreeps)
		-- do
			-- if creep:GetHealth() <= nDamage then
				-- return BOT_ACTION_DESIRE_HIGH, creep:GetLocation ();
		    -- end
        -- end
	-- end
	
	
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius - 100)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	
	
	if abUtils.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange-150, nRadius/2, castPoint, 0 );
		local unitCount = abUtils.CountNotStunnedUnits(enemies, locationAoE, nRadius, 2);
		if ( unitCount >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	if abUtils.IsGoingOnSomeone(bot)
	then
		if abUtils.IsValidTarget(target) and abUtils.CanCastOnNonMagicImmune(target) and abUtils.IsInRange(target, bot, castRange-200) and not abUtils.IsDisabled(true, target)
		then
			local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end

	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderE()
	if not abUtils.CanBeCast(abilities[3]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	if abUtils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) and abilities[3]:GetToggleState( ) == false
	then
		local allies = bot:GetNearbyHeroes(1300, false, BOT_MODE_ATTACK)
		if #allies > 1 then
			local num_facing = 0;
			local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE)
			for i=1, #enemies do
				if abUtils.IsValidTarget(enemies[i])
					and abUtils.CanCastOnMagicImmune(enemies[i])
					and bot:WasRecentlyDamagedByHero(enemies[i], 3.5)
					and bot:IsFacingLocation(enemies[i]:GetLocation(), 20) 
				then
					num_facing = num_facing + 1;
				end	
			end
			if num_facing >= 1 then
				return BOT_ACTION_DESIRE_HIGH, nil;
			end
		end
	end	
	
	if abUtils.IsGoingOnSomeone(bot) and abilities[3]:GetToggleState( ) == true then
		return BOT_ACTION_DESIRE_HIGH, nil;
	end
	
	local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE)
	if #enemies == 0 and abilities[3]:GetToggleState( ) == true then
		return BOT_ACTION_DESIRE_HIGH, nil;
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end


function ConsiderR()
	if not abUtils.CanBeCast(abilities[4]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local castRange = abUtils.GetProperCastRange(false, bot, abilities[4]);
	local castPoint = abilities[4]:GetCastPoint();
	local manaCost  = abilities[4]:GetManaCost();
	local nRadius   = abilities[4]:GetSpecialValueInt( "radius" );
	local nDamage   = abilities[4]:GetSpecialValueInt('spear_damage');
	
	local target  = bot:GetTarget(); 
	local enemies = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	
	
	
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
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
				end
			end
		end
	end
	end
	end
	

	if abUtils.IsRetreating(bot)
	then
		local tableNearbyAllyHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
		if #enemies > 0 and  #tableNearbyAllyHeroes >= 2 and bot:WasRecentlyDamagedByAnyHero(2.0) then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation();
		end
	end	
	
	if abUtils.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange, nRadius, castPoint, 0 );
		local unitCount = abUtils.CountVulnerableUnit(enemies, locationAoE, nRadius, 2);
		if ( unitCount >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	if abUtils.IsGoingOnSomeone(bot)
	then
		if abUtils.IsValidTarget(target) and abUtils.CanCastOnNonMagicImmune(target) and abUtils.IsInRange(target, bot, castRange) 
		then
			local targetAllies = target:GetNearbyHeroes(2*nRadius, false, BOT_MODE_NONE);
			if #targetAllies >= 2 then
				local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, abUtils.GetProperLocation( target, castPoint );
			end
		end
	end

	
	return BOT_ACTION_DESIRE_NONE, nil;
end

