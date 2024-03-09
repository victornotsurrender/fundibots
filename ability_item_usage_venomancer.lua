if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
local mutil = require("bots/MyUtility")
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
----------------------------------------------------------------------------------------------------

local castPNDesire = 0;
local castPWDesire = 0;
local castVGDesire = 0;

local abilityPW = nil;
local abilityVG = nil;
local abilityPN = nil;

-- local npcBot = nil;
local bot = GetBot();
local npcBot = GetBot();

function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	
	-- ability_item_usage_generic.SwapItemsTest()
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();

	if abilityPW == nil then abilityPW = npcBot:GetAbilityByName( "venomancer_plague_ward" ) end
	if abilityVG == nil then abilityVG = npcBot:GetAbilityByName( "venomancer_venomous_gale" ) end
	if abilityPN == nil then abilityPN = npcBot:GetAbilityByName( "venomancer_poison_nova" ) end

	-- Consider using each ability
	castPNDesire = ConsiderPoisonNova();
	castPWDesire, castPWLocation = ConsiderPlagueWard();
	castVGDesire, castVGLocation = ConsiderVenomGale();


	if ( castPNDesire > castPWDesire and castPNDesire > castVGDesire )
	then
		npcBot:Action_UseAbility( abilityPN );
		return;
	end

	if ( castPWDesire > 0 )
	then
		npcBot:Action_UseAbilityOnLocation( abilityPW, castPWLocation );
		return;
	end

	if ( castVGDesire > 0 )
	then
		npcBot:Action_UseAbilityOnLocation( abilityVG, castVGLocation );
		return;
	end

end


function ConsiderPlagueWard()

	-- Make sure it's castable
	if ( not abilityPW:IsFullyCastable() )
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- If we want to cast Poison Nova at all, bail
	if ( castPNDesire > 0 )
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	local nCastRange = abilityPW:GetCastRange();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	if ( npcBot:GetActiveMode() == BOT_MODE_LANING and
		npcBot:GetMana()/npcBot:GetMaxMana() >= 0.75 )
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( 1000, true);
		if(tableNearbyEnemyCreeps[1] ~= nil) then
			return BOT_ACTION_DESIRE_LOW, tableNearbyEnemyCreeps[1]:GetLocation();
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW,npcTarget:GetLocation();
		end
	end	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) and npcBot:GetMana()/npcBot:GetMaxMana() >= 0.55
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( 1000, true);
		if(tableNearbyEnemyCreeps[1] ~= nil ) 
		then
			return BOT_ACTION_DESIRE_LOW, tableNearbyEnemyCreeps[1]:GetLocation();
		end
	end

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(0.63);
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

----------------------------------------------------------------------------------------------------

function ConsiderVenomGale()
	
	-- Make sure it's castable
	if ( not abilityVG:IsFullyCastable() ) then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if ( castPNDesire > 0 ) then
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityVG:GetCastRange();
	local nRadius = 125;
	local nCastPoint = abilityVG:GetCastPoint();
	local nManaCost  = abilityVG:GetManaCost( );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) )
			then
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	-- if npcBot:GetActiveMode() == BOT_MODE_FARM 
	-- then
		-- local npcTarget = npcBot:GetAttackTarget();
		-- if npcTarget ~= nil and not npcTarget:IsBuilding() then
			-- return BOT_ACTION_DESIRE_LOW,npcTarget:GetLocation();
		-- end
	-- end	
	
	-- if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) and mutil.AllowedToSpam(npcBot, nManaCost)
	-- then
		-- local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange+200, true);
		-- local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		-- if ( locationAoE.count >= 4 and #lanecreeps >= 4  ) 
		-- then
			-- return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		-- end
	-- end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and mutils.AllowedToSpam(bot, nManaCost)
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(nCastRange, true);
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange/2, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 8 and #lanecreeps >= 8  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
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
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end


----------------------------------------------------------------------------------------------------

function ConsiderPoisonNova()

	-- Make sure it's castable
	if ( not abilityPN:IsFullyCastable() ) then
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius = abilityPN:GetSpecialValueInt( "radius" );
	local nCastRange = 0;
	local nDamage = abilityPN:GetAbilityDamage();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) )
			then
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) 
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nRadius/2, true);
		
		if ( lanecreeps~= nil and #lanecreeps >= 16  ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end

	if mutil.IsInTeamFight(npcBot, 1200) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius - 200, true, BOT_MODE_NONE  );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget)
		and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local EnemyHeroes = npcBot:GetNearbyHeroes( nRadius - 150, true, BOT_MODE_NONE );
			if ( mutil.IsInRange(npcTarget, npcBot, nRadius - 200) and EnemyHeroes ~= nil and #EnemyHeroes >= 2 ) or ( EnemyHeroes ~= nil and #EnemyHeroes >= 3 )
			then
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE;

end 