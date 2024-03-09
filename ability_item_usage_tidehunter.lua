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
local abilityE = nil;
local abilityR = nil;

local castQDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

function AbilityUsageThink()
	
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	
	if abilityQ == nil then abilityQ = npcBot:GetAbilityByName( "tidehunter_gush" ) end
	if abilityE == nil then abilityE = npcBot:GetAbilityByName( "tidehunter_anchor_smash" ) end
	if abilityR == nil then abilityR = npcBot:GetAbilityByName( "tidehunter_ravage" ) end

	castQDesire, castQTarget, Aghs = ConsiderQ();
	castEDesire                    = ConsiderE();
	castRDesire                    = ConsiderR();
	
	-- ability_item_usage_generic.SwapItemsTest()
	
	if ( castRDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityR );
		return;
	end

	if ( castQDesire > 0 ) 
	then
		if Aghs then
			npcBot:Action_UseAbilityOnLocation( abilityQ, castQTarget );
			return;
		else
			npcBot:Action_UseAbilityOnEntity( abilityQ, castQTarget );
			return;
		end
	end
	
	if ( castEDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityE );
		return;
	end
	
end

function ConsiderQ()

	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius 	 = abilityQ:GetSpecialValueInt('aoe_scepter');
	local nCastRange = abilityQ:GetCastRange();
	local nCastPoint = abilityQ:GetCastPoint( );
	local nManaCost  = abilityQ:GetManaCost( );
	local nDamage    = abilityQ:GetAbilityDamage( );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	local HasScepter = npcBot:HasScepter();
	
	if HasScepter then nCastRange = abilityQ:GetSpecialValueInt('cast_range_scepter') end
	
	if nCastRange > 1600 then nCastRange = 1600 else nCastRange = nCastRange + 200 end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune(npcEnemy) and mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) then
			if HasScepter then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation(), true;
			else
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, false;
			end	
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy) ) 
			then
				if HasScepter then
						local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation(), true;
				else
					local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					return BOT_ACTION_DESIRE_HIGH, npcEnemy, false;
				end	
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			if HasScepter then
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation(), true;
			else
				return BOT_ACTION_DESIRE_HIGH, npcTarget, false;
			end	
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
				
					
					if HasScepter then
					local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation(), true;
			else
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, false;
				end
			end
		end
	end
	end
	end
	end
	
	

	
	
	
	if mutil.IsInTeamFight(npcBot, 1200) and HasScepter
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange-(2*nRadius), nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, true;
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) 
		   and not mutil.IsDisabled(true, npcTarget)
		then
			if HasScepter then
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation(), true;
			else
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcTarget, false;
			end	
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderE()

	-- Make sure it's castable
	if ( not abilityE:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius    = abilityE:GetSpecialValueInt( "radius" );
	local nCastPoint = abilityE:GetCastPoint( );
	local nManaCost  = abilityE:GetManaCost( );
	local nDamage    = abilityE:GetAbilityDamage( );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and npcBot:WasRecentlyDamagedByAnyHero( 2.0 )
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1  ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	-- then
		-- local npcTarget = npcBot:GetAttackTarget();
		-- if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)  )
		-- then
			-- return BOT_ACTION_DESIRE_HIGH
		-- end
	-- end
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
		local tableNearbyCreeps = npcBot:GetNearbyLaneCreeps( nRadius, true );
		if ( tableNearbyCreeps ~= nil and #tableNearbyCreeps >= 4 ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_LANING  or  mutil.IsPushing(npcBot) or  mutil.IsDefending(npcBot) and currManaP > 0.80
	then
	   
	
		local laneCreeps = npcBot:GetNearbyLaneCreeps(nRadius - 100, true);
		for _,creep in pairs(laneCreeps)
		do
			if creep:GetHealth() <= nDamage then
				return BOT_ACTION_DESIRE_HIGH;
		    end
        end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW;
		end
	end	
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius-150)
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderR()

	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius    = abilityR:GetSpecialValueInt( "radius" );
	local nCastPoint = abilityR:GetCastPoint( );
	local nManaCost  = abilityR:GetManaCost( );
	local nDamage    = abilityR:GetAbilityDamage( );
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and npcBot:WasRecentlyDamagedByAnyHero( 2.0 )
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius - 200, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes  = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_ATTACK );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyAllyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 and #tableNearbyAllyHeroes >= 2  ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius/2, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius/2 + 200)
		then
			-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
			-- if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 3 ) 
			-- then
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH;
			-- end
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end



