if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

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

local bot = GetBot();
local npcBot = GetBot();

local abilities = {};

local castQDesire = 0;
local castWDesire = 0;
local castRDesire = 0;
local castR2Desire = 0;

function AbilityUsageThink()
	
	if #abilities == 0 then abilities = mutils.InitiateAbilities(bot, {0,1,5,6}) end
	
	if mutils.CantUseAbility(bot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	castQDesire, QLoc = ConsiderQ();
	castWDesire       = ConsiderW();
	castRDesire       = ConsiderR();
	castR2Desire      = ConsiderR2();
	
	
	
	
	if castRDesire > 0 then
		bot:Action_UseAbility(abilities[3]);		
		return
	end
	
	if castQDesire > 0 then
		-- print(tostring(QLoc))
		bot:Action_UseAbilityOnLocation(abilities[1], QLoc);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_UseAbility(abilities[2]);		
		return
	end
	
	if castR2Desire > 0 then
		bot:Action_UseAbility(abilities[4]);		
		return
	end
	
end



	

function ConsiderQ()
	if not mutils.CanBeCast(abilities[1]) or bot:HasModifier("modifier_pangolier_gyroshell") or bot:HasModifier('modifier_pangolier_swashbuckle_stunned') 
	   or bot:IsRooted()	
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost  = abilities[1]:GetManaCost();
	local nRadius   = abilities[1]:GetSpecialValueInt( "start_radius" );
	local nManaCost  = abilities[1]:GetManaCost();
	local nDamage    = abilities[1]:GetSpecialValueInt("damage") * 4
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	if mutils.IsStuck(bot)
	then
		local loc = mutils.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation( loc, nCastRange );
	end
	
	
	if mutils.IsStuck2(bot)
	then
		local loc = mutils.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation( loc, nCastRange );
	end
	
	if mutils.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( bot:WasRecentlyDamagedByAnyHero(2.0) or bot:WasRecentlyDamagedByTower(2.0) or #tableNearbyEnemyHeroes > 1 )
		then
			local loc = mutils.GetEscapeLoc();
			local cpos = utils.GetTowardsFountainLocation( bot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
		    return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation( loc, nCastRange );
		end	
	end
	
	-- if npcBot:IsAlive() then return BOT_ACTION_DESIRE_LOW,npcBot:GetLocation();end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	if npcBot:GetActiveMode() == BOT_MODE_FARM and currManaP > 0.60
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW,npcTarget:GetLocation();
		end
	end	
	

	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange+200, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 8 and #lanecreeps >= 8  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	
	-- if npcBot:GetActiveMode() == BOT_MODE_LANING  or  mutil.IsPushing(npcBot) or  mutil.IsDefending(npcBot) and currManaP > 0.60
	-- then
	   
	
		-- local laneCreeps = npcBot:GetNearbyLaneCreeps(nCastRange/2, true);
		-- for _,creep in pairs(laneCreeps)
		-- do
			-- if creep:GetHealth() <= nDamage then
				-- return BOT_ACTION_DESIRE_HIGH, creep:GetLocation ();
		    -- end
        -- end
	-- end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if mutils.IsValidTarget(npcTarget) and mutils.CanCastOnMagicImmune(npcTarget) and mutils.IsInRange(npcTarget, bot, nCastRange) and not mutil.IsSuspiciousIllusion(npcTarget)
		then
			local tableNearbyEnemies = npcTarget:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
			local tableNearbyAllies = npcTarget:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
			if #tableNearbyEnemies <= #tableNearbyAllies then
				local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE, nil;
end


function ConsiderW()
	if not mutils.CanBeCast(abilities[2]) then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilities[2]:GetSpecialValueInt("radius");
	local nCastPoint = abilities[2]:GetCastPoint();
	local manaCost  = abilities[2]:GetManaCost();
	local nManaCost  = abilities[2]:GetManaCost();
	
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if #tableNearbyEnemyHeroes > 0 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	
	-- if npcBot:GetActiveMode() == BOT_MODE_FARM 
	-- then
		-- local npcTarget = npcBot:GetAttackTarget();
		-- if npcTarget ~= nil and not npcTarget:IsBuilding() then
			-- return BOT_ACTION_DESIRE_LOW;
		-- end
	-- end	
	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nRadius, true);
		
		if ( lanecreeps~= nil and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW;
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
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nRadius)
		then
			local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
			if #enemies >= 2 then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderR()
	if not mutils.CanBeCast(abilities[3]) then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if mutils.IsRetreating(bot) and bot:GetHealth() <0.35*bot:GetMaxHealth()
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( bot:WasRecentlyDamagedByAnyHero(2.0) or bot:WasRecentlyDamagedByTower(2.0) or #tableNearbyEnemyHeroes > 1 )
		then
		    return BOT_ACTION_DESIRE_HIGH;
		end	
	end
	
	if mutils.IsInTeamFight(bot, 1300)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local nInvUnit = mutils.CountInvUnits(false, tableNearbyEnemyHeroes);
		if nInvUnit >= 2 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, 600)
		then
			local enemies = target:GetNearbyHeroes(600, false, BOT_MODE_NONE);
			if #enemies >= 3 then
				local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderR2()
	return BOT_ACTION_DESIRE_NONE;
end