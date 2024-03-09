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
		bot:Action_UseAbilityOnEntity(abilities[3], ETarget);		
		return
	end
	
end

function ConsiderQ()
	if not abUtils.CanBeCast(abilities[1]) then
		return BOT_ACTION_DESIRE_NONE, {};
	end
	
	local castRange = abUtils.GetProperCastRange(false, bot, abilities[1]);
	local castPoint = abilities[1]:GetCastPoint();
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost  = abilities[1]:GetManaCost();
	local nRadius   = abilities[1]:GetSpecialValueInt( "start_radius" );
	local nDuration = abilities[1]:GetDuration();
	local nSpeed    = abilities[1]:GetSpecialValueInt('speed');
	local nDamage   = abilities[1]:GetSpecialValueInt('burn_damage');
	local nManaCost  = abilities[1]:GetManaCost( );
	local nCastRange = abUtils.GetProperCastRange(false, bot, abilities[1]);
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	local target  = bot:GetTarget(); 
	local enemies = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);

	if abUtils.IsRetreating(bot)
	then
		if #enemies > 0 and bot:WasRecentlyDamagedByAnyHero(2.0) then
			local enemy = abUtils.GetLowestHPUnit(enemies, false);
			if enemy ~= nil then
				local cpos = utils.GetTowardsFountainLocation( bot:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, abUtils.GetProperLocation( enemy, (GetUnitToUnitDistance(bot, enemy)/nSpeed)+castPoint );
			end	
		end
	end	
	
	if ( abUtils.IsPushing(bot) or abUtils.IsDefending(bot) ) and abUtils.AllowedToSpam(bot, manaCost)
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(castRange, true);
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), castRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 8 and #lanecreeps >= 8  ) 
		then
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( castRange, true, BOT_MODE_NONE );
			for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
			do
			if mutil.CanCastOnNonMagicImmune2(npcEnemy) then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nCastPoint);
				end
			end
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
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and currManaP > 0.45
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	

	
	if ( mutil.IsPushing(npcBot) or  mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING) and currManaP > 0.45 and  abilities[1]:GetLevel() > 1
	then
	   
	
		local laneCreeps = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		for _,creep in pairs(laneCreeps)
		do
			if creep:GetHealth() <= nDamage then
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( castRange, true, BOT_MODE_NONE );
			for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
			do
			if mutil.CanCastOnNonMagicImmune2(npcEnemy) then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nCastPoint);
				end
			end
		    end
        end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, CastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetExtrapolatedLocation(CastPoint);
		end
	end
	
	
	

	if abUtils.IsGoingOnSomeone(bot)
	then
		if abUtils.IsValidTarget(target) and abUtils.CanCastOnNonMagicImmune(target) and abUtils.IsInRange(target, bot, castRange) 
		and (not mutil.StillHasModifier(target, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(target, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, abUtils.GetProperLocation( target, (GetUnitToUnitDistance(bot, target)/nSpeed)+castPoint );
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end

	
	return BOT_ACTION_DESIRE_NONE, {};
end

function ConsiderW()
	if not abUtils.CanBeCast(abilities[2]) then
		return BOT_ACTION_DESIRE_NONE, {};
	end
	
	local castRange = abUtils.GetProperCastRange(false, bot, abilities[2]);
	local castPoint = abilities[2]:GetCastPoint();
	local manaCost  = abilities[2]:GetManaCost();
	local nRadius   = abilities[2]:GetSpecialValueInt( "path_radius" );
	local nDelay    = abilities[2]:GetSpecialValueFloat('path_delay')/2.0;
	local nDamage   = abilities[2]:GetSpecialValueInt('damage');
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	local target  = bot:GetTarget(); 
	local enemies = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);

	for _,enemy in pairs(enemies)
	do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
		end
	end
	
	
	--if we can hit any enemies with regen modifier
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( castRange, true, BOT_MODE_NONE );
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
			if enemy ~= nil and not abUtils.IsDisabled(true, enemy) then
				return BOT_ACTION_DESIRE_HIGH, abUtils.GetProperLocation( enemy, nDelay+castPoint );
			end	
		end
	end	
	
	if ( abUtils.IsPushing(bot) or abUtils.IsDefending(bot) ) and abUtils.AllowedToSpam(bot, manaCost)
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(castRange, true);
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), castRange/2, nRadius, castPoint, 0 );
		if ( locationAoE.count >= 8 and #lanecreeps >= 8  ) 
		then
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( castRange, true, BOT_MODE_NONE );
			for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
			do
			if mutil.CanCastOnNonMagicImmune2(npcEnemy) then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nCastPoint);
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
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
				end
			end
		end
	end
	end
	end
	
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, castRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetExtrapolatedLocation(CastPoint);
		end
	end
	
	if abUtils.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange, nRadius, nDelay+castPoint, 0 );
		local unitCount = abUtils.CountNotStunnedUnits(enemies, locationAoE, nRadius, 2);
		if ( unitCount >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	if abUtils.IsGoingOnSomeone(bot)
	then
		if abUtils.IsValidTarget(target) and abUtils.CanCastOnNonMagicImmune(target) and abUtils.IsInRange(target, bot, castRange) and not abUtils.IsDisabled(true, target)
		then
			local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, abUtils.GetProperLocation( target, nDelay+castPoint );
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, castRange, 2.0);
	
	if skThere then
		local cpos = utils.GetTowardsFountainLocation( skLoc, 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end

	
	return BOT_ACTION_DESIRE_NONE, {};
end

function ConsiderE()
	if not abUtils.CanBeCast(abilities[3]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local castRange = bot:GetAttackRange() + 200;
	
	local target  = bot:GetTarget(); 
	local aTarget = bot:GetAttackTarget(); 
	local enemies = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);

	if #enemies > 0 then
		local enemy = abUtils.GetLowestHPUnit(enemies, false);
		if enemy ~= nil then
			return BOT_ACTION_DESIRE_HIGH, enemy;
		end	
	end
	
	if aTarget ~= nil and aTarget:IsBuilding() then
		return BOT_ACTION_DESIRE_HIGH, aTarget;
	end	
	
	if ( abUtils.IsPushing(bot) or abUtils.IsDefending(bot) ) 
	then
		local towers = bot:GetNearbyTowers(castRange, true);
		if #towers > 0 and towers[1] ~= nil and not towers[1]:IsInvulnerable() then
			return BOT_ACTION_DESIRE_HIGH, towers[1];
		end
		local barracks = bot:GetNearbyBarracks(castRange, true);
		if #barracks > 0 and barracks[1] ~= nil and not barracks[1]:IsInvulnerable() then
			return BOT_ACTION_DESIRE_HIGH, barracks[1];
		end
		local creeps = bot:GetNearbyLaneCreeps(castRange, true);
		if #creeps > 0 and creeps[1] ~= nil then
			return BOT_ACTION_DESIRE_HIGH, creeps[1];
		end
	end

	if abUtils.IsGoingOnSomeone(bot)
	then
		if abUtils.IsValidTarget(target) and abUtils.CanCastOnNonMagicImmune(target) and abUtils.IsInRange(target, bot, castRange) 
		then
			local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, target;
		end	
	end
	
	if target ~= nil and target:GetUnitName() == "npc_dota_roshan" and abUtils.IsInRange(target, bot, 350)  then
		return BOT_ACTION_DESIRE_HIGH, target;
	end

	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderR()
	if not abUtils.CanBeCast(abilities[4]) then
		return BOT_ACTION_DESIRE_NONE, {};
	end
	
	local castRange = abUtils.GetProperCastRange(false, bot, abilities[4]);
	local castPoint = abilities[4]:GetCastPoint();
	local manaCost  = abilities[4]:GetManaCost();
	local nRadius   = abilities[4]:GetSpecialValueInt( "path_radius" );
	local nDamage   = abilities[4]:GetSpecialValueInt('damage');
	
	local target  = bot:GetTarget(); 
	local enemies = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);

	if abUtils.IsRetreating(bot)
	then
		if #enemies > 0 and bot:WasRecentlyDamagedByAnyHero(2.0) then
			local enemy = abUtils.GetLowestHPUnit(enemies, false);
			if enemy ~= nil then
				return BOT_ACTION_DESIRE_HIGH, abUtils.GetProperLocation( enemy, castPoint );
			end	
		end
	end	
	
	if ( abUtils.IsDefending(bot) ) and abUtils.AllowedToSpam(bot, manaCost)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange, nRadius, castPoint, 0 );
		local unitCount = abUtils.CountVulnerableUnit(enemies, locationAoE, nRadius, 2);
		if ( unitCount >= 16 ) 
		then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( castRange, true, BOT_MODE_NONE );
			for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
			do
			if mutil.CanCastOnNonMagicImmune2(npcEnemy) then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nCastPoint);
				end
			end
		
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
		and not mutil.IsSuspiciousIllusion(target) and (not mutil.StillHasModifier(target, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(target, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local targetAllies = target:GetNearbyHeroes(2*nRadius, false, BOT_MODE_NONE);
			if #targetAllies >= 2 then
				local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, abUtils.GetProperLocation( target, castPoint );
			end
		end
	end
	
	
	-- local skThere, skLoc = mutil.IsSandKingThere(npcBot, castRange-200, 2.0);
	
	-- if skThere then
		-- return BOT_ACTION_DESIRE_MODERATE, skLoc;
	-- end

	
	return BOT_ACTION_DESIRE_NONE, {};
end

