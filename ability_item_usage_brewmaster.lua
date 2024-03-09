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

local castPSDesire = 0;
local castTCDesire = 0;
local castDHDesire = 0;
local castDBDesire = 0;

local abilityTC = nil;
local abilityDH = nil;
local abilityDB = nil;
local abilityPS = nil;

-- local npcBot = nil;
local npcBot = GetBot();
local bot = GetBot();

function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();

	if abilityTC == nil then abilityTC = npcBot:GetAbilityByName( "brewmaster_thunder_clap" ) end
	if abilityDH == nil then abilityDH = npcBot:GetAbilityByName( "brewmaster_cinder_brew" ) end
	if abilityDB == nil then abilityDB = npcBot:GetAbilityByName( "brewmaster_drunken_brawler" ) end
	if abilityPS == nil then abilityPS = npcBot:GetAbilityByName( "brewmaster_primal_split" ) end
	
	-- Consider using each ability
	castTCDesire = ConsiderThunderClap();
	castDBDesire = ConsiderDrunkenBrawler();
	castDHDesire, castDHTarget = ConsiderDrunkenHaze();
	castPSDesire = ConsiderPrimalSplit();
	
	

	if ( castDHDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityDH, castDHTarget:GetLocation() );
		return;
	end	
	if ( castTCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityTC );
		return;
	end
	if ( castDBDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityDB );
		return;
	end
	
	if ( castPSDesire > 0  ) 
	
	then
		npcBot:Action_UseAbility( abilityPS );
		return;
	end
	

end

function ConsiderThunderClap()

	-- Make sure it's castable
	if ( not abilityTC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilityTC:GetSpecialValueInt( "radius" );
	local nCastRange = 0;
	local nDamage = abilityTC:GetSpecialValueInt("damage");
	local nManaCost = abilityTC:GetManaCost()
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius - 100, true, BOT_MODE_NONE );
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune(npcEnemy) and mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	
	

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
			then
				local cpos = utils.GetTowardsFountainLocation(bot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius - 100)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're farming and can kill 3+ creeps with LSA
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) and mutil.AllowedToSpam(npcBot, nManaCost) 
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nRadius, true);
		
		if ( lanecreeps~= nil and #lanecreeps >= 8  ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	
	
	-- if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	-- then
		-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		-- local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nRadius - 100 );
			-- if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				-- for _,neutral in pairs(tableNearbyNeutrals)
				-- do
				-- if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					-- then 
					-- return BOT_ACTION_DESIRE_MODERATE;
				-- end
			-- end
		-- end
	-- end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and currManaP > 0.45
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW;
		end
	end	
	
	
	
	
	-- if (npcBot:GetActiveMode() == BOT_MODE_LANING  or  mutil.IsPushing(npcBot) or  mutil.IsDefending(npcBot) )and currManaP > 0.80
	-- then
	   
	
		-- local laneCreeps = npcBot:GetNearbyLaneCreeps(nRadius - 100, true);
		-- for _,creep in pairs(laneCreeps)
		-- do
			-- if creep:GetHealth() <= nDamage then
				-- return BOT_ACTION_DESIRE_HIGH;
		    -- end
        -- end
	-- end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius - 100)
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_VERYHIGH;
		end
	end
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nRadius - 100, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE;
	end

	return BOT_ACTION_DESIRE_NONE;

end


function ConsiderDrunkenBrawler()

	-- Make sure it's castable
	if ( not abilityDB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = 300;
	-- local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're farming and can kill 3+ creeps with LSA
	if ( mutil.IsPushing(npcBot) ) 
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nRadius, true);
		
		if ( lanecreeps~= nil and #lanecreeps >= 8  ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW;
		end
	end	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_VERYHIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end


function ConsiderPrimalSplit()

	-- Make sure it's castable
	if ( not abilityPS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	-- if #tableNearbyAllyHeroes == 0 then
		-- return BOT_ACTION_DESIRE_NONE;
	-- end
	
	local distance = 300;
	
	-- if mutil.IsRetreating(npcBot)
	-- then
		-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		-- local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
		-- if (tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 and tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2)
		-- then
			-- return BOT_ACTION_DESIRE_MODERATE;
		
		-- end
	-- end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(bot) and bot:GetHealth()/bot:GetMaxHealth() <= 0.5
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 )     ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	
	
	if mutil.IsInTeamFight(npcBot, 1200) and not abilityTC:IsFullyCastable()
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 3 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) and not abilityTC:IsFullyCastable()
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 400) 
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
			local tableNearbyAlly = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_ATTACK );
			if tableNearbyEnemyHeroes ~= nil and tableNearbyAlly ~= nil and #tableNearbyEnemyHeroes >= 2 and #tableNearbyAlly >= 2 then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderDrunkenHaze()

	-- Make sure it's castable
	if ( not abilityDH:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityDH:GetCastRange();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
			local npcTarget = npcBot:GetTarget();
			if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and
			     mutil.IsInRange(npcTarget, npcBot, nCastRange+200) and not npcTarget:HasModifier("modifier_brewmaster_drunken_haze") )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
	end
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end

	-- If we're in a teamfight, use it on the scariest enemy
	if mutil.IsInTeamFight(npcBot, 1200)
	then

		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if mutil.CanCastOnNonMagicImmune(npcEnemy) and not npcEnemy:HasModifier("modifier_brewmaster_drunken_haze") 
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
	end
	
	-- if npcBot:GetActiveMode() == BOT_MODE_FARM and currManaP > 0.45
	-- then
		-- local npcTarget = npcBot:GetAttackTarget();
		-- if npcTarget ~= nil and not npcTarget:IsBuilding() then
			-- return BOT_ACTION_DESIRE_LOW, npcTarget;
		-- end
	-- end	
	
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end
