if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
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

local npcBot = GetBot();
local bot = GetBot();

local abilityQ = nil;
local abilityW = nil;

local castQDesire = 0;
local castWDesire = 0;

function AbilityUsageThink()
	
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	if abilityQ == nil then abilityQ = npcBot:GetAbilityByName( "bristleback_viscous_nasal_goo" ) end
	if abilityW == nil then abilityW = npcBot:GetAbilityByName( "bristleback_quill_spray" ) end
	
	castQDesire, castQTarget  = ConsiderQ();
	castWDesire 			  = ConsiderW();
	
	
	-- ability_item_usage_generic.SwapItemsTest()
	
	
	if ( castQDesire > 0 ) 
	then
		if npcBot:HasScepter() then
			npcBot:Action_UseAbility( abilityQ );
			return;
		else
			npcBot:Action_UseAbilityOnEntity( abilityQ, castQTarget );
			return;
		end
	end
	
	if ( castWDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityW );
		return;
	end
	
end

function ConsiderQ()

	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius    = abilityQ:GetSpecialValueInt('radius_scepter');
	local nCastRange = abilityQ:GetCastRange();
	local nCastPoint = abilityQ:GetCastPoint( );
	local nManaCost  = abilityQ:GetManaCost( );
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				-- local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				-- bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
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

	if mutil.IsInTeamFight(npcBot, 1200) and npcBot:HasScepter()
	then
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 then
			return BOT_ACTION_DESIRE_LOW, tableNearbyEnemyHeroes[1];
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius) 
		then
			-- local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				-- bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nRadius - 100, 2.0);
	
	if skThere and npcBot:HasScepter() then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderW()

	-- Make sure it's castable
	if ( not abilityW:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius    = abilityW:GetSpecialValueInt( "radius" );
	local nCastPoint = abilityW:GetCastPoint( );
	local nManaCost  = abilityW:GetManaCost( );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nDamage    = abilityW:GetSpecialValueInt("quill_base_damage") * 3;
	
	
	
	--if we can hit any enemies with regen modifier
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and (npcEnemy:HasModifier("modifier_clarity_potion") or npcEnemy:HasModifier("modifier_flask_healing") )then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	-- If we're doing Roshan
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcBot, npcTarget, nRadius)  )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If We're pushing or defending
	if mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or   npcBot:GetActiveMode() == BOT_MODE_LANING
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nRadius, true );
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 and mutil.AllowedToSpam(npcBot, nManaCost) ) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW;
		end
	end	
	
	
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_LANING and currManaP > 0.60 or  mutil.IsPushing(npcBot) or  mutil.IsDefending(npcBot)
	then
	   
	
		local laneCreeps = npcBot:GetNearbyLaneCreeps(nRadius, true);
		for _,creep in pairs(laneCreeps)
		do
			if creep:GetHealth() <= nDamage then
				return BOT_ACTION_DESIRE_HIGH;
		    end
        end
	end
	
	
	
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius-100)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nRadius - 100, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

	

end


