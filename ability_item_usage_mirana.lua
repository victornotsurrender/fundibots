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



local castDPDesire = 0;
local castPCDesire = 0;
local castSDDesire = 0;
local casthookDesire = 0;

local abilityDP = nil; 
local abilityHook = nil; 
local abilityPC = nil; 
local abilitySD = nil; 

local npcBot = GetBot();
local bot = GetBot();

function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	if abilityDP == nil then abilityDP = npcBot:GetAbilityByName( "mirana_starfall" ) end
	if abilityHook == nil then abilityHook = npcBot:GetAbilityByName( "mirana_arrow" ) end
	if abilityPC == nil then abilityPC = npcBot:GetAbilityByName( "mirana_leap" ) end
	if abilitySD == nil then abilitySD = npcBot:GetAbilityByName( "mirana_invis" ) end

	-- Consider using each ability
	castDPDesire = ConsiderDarkPact();
	castHookDesire, castHookTarget = ConsiderHook();
	castPCDesire = ConsiderPounce();
	castSDDesire = ConsiderShadowDance();
	
	
	
	if ( castHookDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityHook, castHookTarget );
		return;
	end
	
	if ( castDPDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityDP );
		return;
	end
	
	if ( castPCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityPC );
		return;
	end
	
	if ( castSDDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySD );
		return;
	end

end




function ConsiderDarkPact()

	-- Make sure it's castable
	if ( not abilityDP:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nCastRange = abilityDP:GetSpecialValueInt( "starfall_radius" );
	local nRadius = abilityDP:GetSpecialValueInt( "starfall_secondary_radius" );
	local nDamage = abilityDP:GetAbilityDamage();
	local nManaCost = abilityDP:GetManaCost( );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	-- If we're farming and can kill 3+ creeps with LSA
	if( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING) and mutil.AllowedToSpam(npcBot, nManaCost) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange- 100, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-100)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange - 100 );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 2 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					then 
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) 
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end


function ConsiderHook()

	-- Make sure it's castable
	if ( not abilityHook:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- If we want to cast priorities at all, bail
	--if ( castPhaseDesire > 0 or castCoilDesire > 50) then
	--	return BOT_ACTION_DESIRE_NONE;
	--end

	-- Get some of its values
	local nRadius = abilityHook:GetSpecialValueInt( "arrow_width" );
	local speed = abilityHook:GetSpecialValueInt( "arrow_speed" );
	local nDamage = abilityHook:GetAbilityDamage();
	local nCastRange = abilityHook:GetSpecialValueInt("arrow_range")
	local nCastPoint = abilityHook:GetCastPoint();
	
	
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
			if GetUnitToLocationDistance(bot,u:GetLocation()) <= 700 
				then
			if #allies >= 0 then
				local distance = GetUnitToUnitDistance(npcEnemy, bot)
				local moveCon = npcEnemy:GetMovementDirectionStability();
				local pLoc = npcEnemy:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
				if moveCon < 1  then
					pLoc = npcEnemy:GetLocation();
				end
				if mutil.IsAllyHeroBetweenMeAndTarget(bot, npcEnemy, pLoc, nRadius) == false 
					and mutil.IsCreepBetweenMeAndTarget(bot, npcEnemy, pLoc, nRadius) == false
				then
					local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
				end
			end
		end
	end
	end
	end
	end

	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and  not mutil.IsEnemyCreepBetweenMeAndTarget(npcBot, npcEnemy, npcEnemy:GetLocation(), nRadius) ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange/2 - 200)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			local distance = GetUnitToUnitDistance(npcTarget, npcBot)
			local moveCon = npcTarget:GetMovementDirectionStability();
			local pLoc = npcTarget:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
			if moveCon < 1 then
				pLoc = npcTarget:GetLocation();
			end
			if not mutil.IsEnemyCreepBetweenMeAndTarget(npcBot, npcTarget, pLoc, nRadius)  then
				local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, pLoc;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderPounce()

	-- Make sure it's castable
	if ( not abilityPC:IsFullyCastable() or npcBot:IsRooted() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nCastRange = abilityPC:GetSpecialValueInt( "leap_distance" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	if mutil.IsStuck(npcBot)
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			local ancient = GetAncient(GetTeam());
			if npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and npcBot:IsFacingUnit(ancient, 10 )
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) and npcBot:HasModifier('modifier_mirana_leap_buff') == false
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 500) == false and mutil.IsInRange(npcTarget, npcBot, 1000) == true 
		   and npcBot:IsFacingUnit(npcTarget, 5)
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
			if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes <= 2 )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderShadowDance()

	-- Make sure it's castable
	if ( not abilitySD:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local cpos = utils.GetTowardsFountainLocation( npcBot:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
		if  mutil.IsValidTarget(npcTarget) and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 and 
			not mutil.IsInRange(npcTarget, npcBot, 1600) and mutil.IsInRange(npcTarget, npcBot, 2500) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end
