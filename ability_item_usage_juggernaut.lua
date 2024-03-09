if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
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

-- local abilities = {};

local castCombo1Desire = 0;
local castCombo2Desire = 0;
local castQDesire = 0;
local castWDesire = 0;
-- local castEDesire = 0;
local castDDesire = 0;
local castRDesire = 0;

local abilityQ = nil;
local abilityW = nil;
local abilityR = nil;
local abilityD = nil;

local lastCheck = -90;

function AbilityUsageThink()
	
	-- if #abilities == 0 then abilities = mutils.InitiateAbilities(bot, {0,1,3,5,7}) end
	
	if mutils.CantUseAbility(bot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	if abilityQ == nil then abilityQ = npcBot:GetAbilityByName( "juggernaut_blade_fury" ) end
	if abilityW == nil then abilityW = npcBot:GetAbilityByName( "juggernaut_healing_ward" ) end
	if abilityR == nil then abilityR = npcBot:GetAbilityByName( "juggernaut_omni_slash" ) end
	if abilityD == nil then abilityD = npcBot:GetAbilityByName( "juggernaut_swift_slash" ) end
	
	
	castQDesire, targetQ = ConsiderQ();
	castWDesire, targetW = ConsiderW();
	-- castEDesire, targetE  = ConsiderE();
	castDDesire, targetD  = ConsiderD();
	castRDesire, targetR = ConsiderR();
	
	-- ability_item_usage_generic.SwapItemsTest()
	
	if castRDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilityR, targetR);		
		return
	end
	
	if castQDesire > 0 then
		bot:Action_UseAbility(abilityQ);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilityW, targetW);		
		return
	end
	
	-- if castEDesire > 0 then
		-- local typeAOE = mutils.CheckFlag(abilities[3]:GetBehavior(), ABILITY_BEHAVIOR_POINT);
		-- if typeAOE == true then
			-- bot:Action_UseAbilityOnLocation( abilities[3], targetE:GetLocation() );
		-- else
			-- bot:Action_UseAbilityOnEntity( abilities[3], targetE );
		-- end	
		-- return
	-- end
	
	 if castDDesire > 0 then
		bot:Action_UseAbilityOnEntity( abilityD, targetD );
		return
	end
	
end

function ConsiderQ()
	-- if not mutils.CanBeCast(abilityQ) then
		-- return BOT_ACTION_DESIRE_NONE, nil;
	-- end
	
	
	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilityQ:GetCastRange());
	local nCastPoint = abilityQ:GetCastPoint();
	local manaCost  = abilityQ:GetManaCost();
	local nRadius   = abilityQ:GetSpecialValueInt( "blade_fury_radius" );
	local nDuration   = abilityQ:GetSpecialValueFloat( "duration" );
	local nDamage   = abilityQ:GetSpecialValueInt( "blade_fury_damage" );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0)
	then
		local incProj = bot:GetIncomingTrackingProjectiles()
		for _,p in pairs(incProj)
		do
			if GetUnitToLocationDistance(bot, p.location) <= 350 and p.is_attack == false then
				local cpos = utils.GetTowardsFountainLocation( bot:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
		local enemy = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemy > 0 then
			local cpos = utils.GetTowardsFountainLocation( bot:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
		    return BOT_ACTION_DESIRE_HIGH;
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
	if npcBot:GetActiveMode() == BOT_MODE_FARM and currManaP > 0.45
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() and mutil.IsInRange(npcTarget,npcBot,nRadius) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and mutils.CanSpamSpell(bot, manaCost)
	then
		local enemy = bot:GetNearbyLaneCreeps(nRadius, true);
		if #enemy >= 4 then
		    return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300) 
	then
		local enemy = bot:GetNearbyHeroes(2*nRadius, true, BOT_MODE_NONE);
		local nAEnemy = 0;
		for i=1, #enemy do
			if mutils.IsValidTarget(enemy[i]) and bot:WasRecentlyDamagedByHero(enemy[i], 2.0)
			then
				nAEnemy = nAEnemy + 1;
			end
		end
		if nAEnemy >= 2 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) 
		then
			local incProj = bot:GetIncomingTrackingProjectiles()
			for _,p in pairs(incProj)
			do
				if GetUnitToLocationDistance(bot, p.location) <= 350 and p.is_attack == false then
					local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					return BOT_ACTION_DESIRE_HIGH;
				end
			end
			if mutils.IsInRange(target, bot, nRadius) and target:GetHealth() <= nDuration * nDamage then
				local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nRadius , 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderW()
	-- if not mutils.CanBeCast(abilityW) then
		-- return BOT_ACTION_DESIRE_NONE, nil;
	-- end
	
	
	-- Make sure it's castable
	if ( not abilityW:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilityW:GetCastRange());
	local nCastRange2 = bot:GetAttackRange();
	local nCastPoint = abilityW:GetCastPoint();
	local manaCost  = abilityW:GetManaCost();
	local nRadius   = abilityW:GetSpecialValueInt( "healing_ward_aura_radius" );
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0) and bot:GetHealth() <= 0.45 * bot:GetMaxHealth()
	then
		return BOT_ACTION_DESIRE_LOW, bot:GetLocation()+RandomVector(200);
	end
	
	
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcBot:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	
	
	
	
	if mutils.IsInTeamFight(bot, 1300) 
	then
		local ally = bot:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
		local nLowHP = 0;
		for i=1, #ally do
			if ally[i]:GetHealth() <= 0.5 * ally[i]:GetMaxHealth() then
				nLowHP = nLowHP + 1;
			end
		end
		if nLowHP >=2 then
			return BOT_ACTION_DESIRE_LOW, bot:GetLocation()+RandomVector(200);
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) and bot:GetHealth() <= 0.45 * bot:GetMaxHealth()
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.IsInRange(target, bot, 3*nCastRange2)
		then
			local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()+RandomVector(200);
		end
	end
	
	
	
	if bot:GetHealth() <= 0.35 * bot:GetMaxHealth()
	then
		return BOT_ACTION_DESIRE_MODERATE,bot:GetLocation()+RandomVector(200);
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

-- function ConsiderE()
	-- if not mutils.CanBeCast(abilities[3]) then
		-- return BOT_ACTION_DESIRE_NONE, nil;
	-- end
	
	-- local nCastRange = mutils.GetProperCastRange(false, bot, abilities[3]:GetCastRange());
	-- local nCastPoint = abilities[3]:GetCastPoint();
	-- local manaCost  = abilities[3]:GetManaCost();
	-- local manaCost2  = abilities[1]:GetManaCost();
	-- local nRadius   = abilities[4]:GetSpecialValueInt( "omni_slash_radius" );
	-- local nDuration = abilities[3]:GetSpecialValueFloat( "duration" );
	-- local nRate = abilities[4]:GetSpecialValueFloat( "attack_rate_multiplier" );
	-- local nAttackDamage = bot:GetAttackDamage();
	-- local nDamage = nAttackDamage + abilities[4]:GetSpecialValueFloat( "bonus_damage" );
	
	-- if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0) 
		-- and bot:GetMana() >= manaCost + manaCost2 and abilities[1]:GetCooldownTimeRemaining() <= nDuration
	-- then
		-- local enemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		-- for i=1, #enemy do
			-- if mutils.IsValidTarget(enemy[i]) and mutils.CanCastOnNonMagicImmune(enemy[i]) 
			-- then
				-- return BOT_ACTION_DESIRE_HIGH, enemy[i];
			-- end
		-- end
	-- end
	
	-- -- if mutils.IsInTeamFight(bot, 1300)
	-- -- then
		-- -- local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		-- -- if ( locationAoE.count >= 2 ) then
			-- -- local target = mutils.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			-- -- if target ~= nil then
				-- -- return BOT_ACTION_DESIRE_HIGH, target;
			-- -- end
		-- -- end
	-- -- end
	
	-- if mutils.IsGoingOnSomeone(bot)
	-- then
		-- local target = bot:GetTarget();
		-- if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange)
		-- then
			-- local attr = bot:GetAttributeValue(ATTRIBUTE_AGILITY);
			-- local aps = (((100+attr)*0.01)/1.7)*nRate;
			-- local nTotalDamage = nDuration * aps * nDamage;
			
			-- --print(tostring(abilities[4]:GetEstimatedDamageToTarget(target, nDuration, DAMAGE_TYPE_PHYSICAL)))
			-- local enemies = target:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			-- local nInvUnit = mutils.CountInvUnits(false, enemies);
			-- if nInvUnit >= 2 then
				-- return BOT_ACTION_DESIRE_HIGH, target;
			-- else
				-- if target:GetHealth() > 0.25*nTotalDamage and target:GetHealth() < nTotalDamage then
					-- return BOT_ACTION_DESIRE_HIGH, target;
				-- end	
			-- end
		-- end
	-- end
	
	-- return BOT_ACTION_DESIRE_NONE, nil;
-- end	



function ConsiderD()

	-- if not mutils.CanBeCast(abilityD) or bot:HasScepter() == false then
		-- return BOT_ACTION_DESIRE_NONE, nil;
	-- end
	
	-- Make sure it's castable
	if ( not abilityD:IsFullyCastable() or mutil.CanNotBeCast(npcBot) or  bot:HasScepter() == false ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilityD:GetCastRange());
	local nCastPoint = abilityD:GetCastPoint();
	local manaCost  = abilityD:GetManaCost();
	local manaCost2  = abilityQ:GetManaCost();
	local nRadius   = abilityR:GetSpecialValueInt( "omni_slash_radius" );
	local nDuration = abilityD:GetSpecialValueFloat( "duration" );
	local nRate = abilityR:GetSpecialValueFloat( "attack_rate_multiplier" );
	local nAttackDamage = bot:GetAttackDamage();
	local nDamage = nAttackDamage + abilityR:GetSpecialValueFloat( "bonus_damage" );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0) 
		and bot:GetMana() >= manaCost + manaCost2 and abilityQ:GetCooldownTimeRemaining() <= nDuration
	then
		local enemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		for i=1, #enemy do
			if mutils.IsValidTarget(enemy[i]) and mutils.CanCastOnNonMagicImmune(enemy[i]) 
			then
				return BOT_ACTION_DESIRE_HIGH, enemy[i];
			end
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
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and currManaP > 0.45
	then
		local eCreeps = bot:GetNearbyCreeps(nRadius, true);
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() and mutil.IsInRange(npcTarget,npcBot,nRadius)
			and #eCreeps >=4 and eCreeps ~= nil
		then
			return BOT_ACTION_DESIRE_MODERATE,npcTarget;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange)
		then
			local attr = bot:GetAttributeValue(ATTRIBUTE_AGILITY);
			local aps = (((100+attr)*0.01)/1.7)*nRate;
			local nTotalDamage = nDuration * aps * nDamage;
			
			--print(tostring(abilityR:GetEstimatedDamageToTarget(target, nDuration, DAMAGE_TYPE_PHYSICAL)))
			local enemies = target:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			local nInvUnit = mutils.CountInvUnits(false, enemies);
			if nInvUnit >= 2 then
				return BOT_ACTION_DESIRE_HIGH, target;
			else
				if target:GetHealth() > 0.25*nTotalDamage and target:GetHealth() < nTotalDamage then
					return BOT_ACTION_DESIRE_HIGH, target;
				end	
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end		

function ConsiderR()
	-- if not mutils.CanBeCast(abilityR) then
		-- return BOT_ACTION_DESIRE_NONE, nil;
	-- end
	
	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilityR:GetCastRange());
	local nCastPoint = abilityR:GetCastPoint();
	local manaCost  = abilityR:GetManaCost();
	local manaCost2  = abilityQ:GetManaCost();
	local nRadius   = abilityR:GetSpecialValueInt( "omni_slash_radius" );
	local nDuration = abilityR:GetSpecialValueFloat( "duration" );
	local nRate = abilityR:GetSpecialValueFloat( "attack_rate_multiplier" );
	local nAttackDamage = bot:GetAttackDamage();
	local nDamage = nAttackDamage + abilityR:GetSpecialValueFloat( "bonus_damage" );
	
	-- if bot:HasScepter() then
		-- nDuration = abilityR:GetSpecialValueFloat( "duration_scepter" );
	-- end
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0) 
		and bot:GetMana() >= manaCost + manaCost2 and abilityQ:GetCooldownTimeRemaining() <= nDuration
	then
		local enemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		for i=1, #enemy do
			if mutils.IsValidTarget(enemy[i]) and mutils.CanCastOnNonMagicImmune(enemy[i]) 
			then
				return BOT_ACTION_DESIRE_HIGH, enemy[i];
			end
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
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange)
		then
			local attr = bot:GetAttributeValue(ATTRIBUTE_AGILITY);
			local aps = (((100+attr)*0.01)/1.7)*nRate;
			local nTotalDamage = nDuration * aps * nDamage;
			
			--print(tostring(abilityR:GetEstimatedDamageToTarget(target, nDuration, DAMAGE_TYPE_PHYSICAL)))
			local enemies = target:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			local nInvUnit = mutils.CountInvUnits(false, enemies);
			if nInvUnit >= 2 then
				return BOT_ACTION_DESIRE_HIGH, target;
			else
				if target:GetHealth() > 0.3*nTotalDamage and target:GetHealth() < nTotalDamage then
					return BOT_ACTION_DESIRE_HIGH, target;
				end	
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end
	