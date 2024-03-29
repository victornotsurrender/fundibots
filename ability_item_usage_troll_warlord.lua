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
local castPC2Desire = 0;
local castSDDesire = 0;

local abilityDP = nil;
local abilityPC = nil;
local abilityPC2 = nil;
local abilitySD = nil;

-- local npcBot = nil;
local npcBot = GetBot();
local bot = GetBot();

local toggleTime = DotaTime();

function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	
	if abilityDP == nil then abilityDP = npcBot:GetAbilityByName( "troll_warlord_berserkers_rage" ) end
	if abilityPC == nil then abilityPC = npcBot:GetAbilityByName( "troll_warlord_whirling_axes_melee" ) end
	if abilityPC2 == nil then abilityPC2 = npcBot:GetAbilityByName( "troll_warlord_whirling_axes_ranged" ) end
	if abilitySD == nil then abilitySD = npcBot:GetAbilityByName( "troll_warlord_battle_trance" ) end

	-- Consider using each ability
	castDPDesire = ConsiderDarkPact();
	castPCDesire = ConsiderPounce();
	castPC2Desire, castPC2Location = ConsiderPounce2();
	castSDDesire = ConsiderShadowDance();
	
	-- ability_item_usage_generic.SwapItemsTest()
	
	if ( castDPDesire > 0 ) 
	then
		toggleTime = DotaTime();
		npcBot:Action_UseAbility( abilityDP );
		return;
	end
	
	if ( castPCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityPC );
		return;
	end
	
	if ( castPC2Desire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityPC2, castPC2Location );
		return;
	end
	
	if ( castSDDesire > 0 ) 
	then
		if npcBot:HasScepter() or npcBot:HasModifier('modifier_item_ultimate_scepter_consumed')  then
			npcBot:Action_UseAbilityOnEntity( abilitySD, npcBot );
		else
			npcBot:Action_UseAbility( abilitySD );
			return;
		end
	end

end


function ConsiderDarkPact()

	-- Make sure it's castable
	if ( not abilityDP:IsFullyCastable() or DotaTime() <= toggleTime + 0.2 ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	--WARStatus true = melee form, otherwise = range form
	local inMelee = false;
	if npcBot:GetAttackRange() < 320 then
		inMelee = true;
	end

	-- Get some of its values
	local nCastRange = 500;
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( 1200 );
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING ) then
		local longestAR = 0;
		for _,enemy in pairs(tableNearbyEnemyHeroes)
		do
			local enemyAR = enemy:GetAttackRange();
			if enemyAR > longestAR then
				longestAR = enemyAR;
			end
		end
		if longestAR < 320 and not inMelee then
			return BOT_ACTION_DESIRE_MODERATE;
		elseif longestAR > 320 and inMelee then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	-----------------------------------------------
	
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		local longestAR = 0;
		for _,enemy in pairs(tableNearbyNeutrals)
		do
			local enemyAR = enemy:GetAttackRange();
			if enemyAR > longestAR then
				longestAR = enemyAR;
			end
		end
		if longestAR < 320 and not inMelee then
			return BOT_ACTION_DESIRE_MODERATE;
		elseif longestAR > 320 and inMelee then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		if #tableNearbyEnemyHeroes > 0 and abilityPC2:IsFullyCastable() and inMelee then
			-- print("cond 9")	
			return BOT_ACTION_DESIRE_MODERATE;
		elseif not abilityPC2:IsFullyCastable() and not inMelee then   	
			-- print("cond 10")
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	if mutil.IsPushing(npcBot)
	then
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 1 and inMelee then
			-- print("cond 6")
			return BOT_ACTION_DESIRE_MODERATE;
		elseif 	tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes < 1 and not inMelee then
			-- print("cond 7")
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() ) 
		then
			local Dist = GetUnitToUnitDistance(npcTarget, npcBot);
			if ( mutil.IsDisabled(true, npcTarget) or npcTarget:IsChanneling() 
				or npcBot:HasModifier('modifier_troll_warlord_battle_trance')
				or npcTarget:GetCurrentMovementSpeed() < npcBot:GetCurrentMovementSpeed() ) and Dist < 1000  	
			then
				if inMelee and abilityPC2:IsFullyCastable() then
					-- print("cond 1")
					return BOT_ACTION_DESIRE_MODERATE;	
				elseif not inMelee and abilityPC2:IsFullyCastable() == false then
					-- print("cond 2")
					return BOT_ACTION_DESIRE_MODERATE;
				end
			else
				if Dist > nCastRange + 200 and not inMelee then
					-- print("cond 3")
					return BOT_ACTION_DESIRE_MODERATE;
				elseif Dist > nCastRange / 2 + 175 and Dist < nCastRange + 200 and inMelee then
					-- print("cond 4")
					return BOT_ACTION_DESIRE_MODERATE;
				elseif Dist < nCastRange / 2 + 175 and not inMelee then
					-- print("cond 5")
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
		end
	end
	
	
	if #tableNearbyEnemyHeroes == 0 and not inMelee then
		-- print("cond 8")
		return BOT_ACTION_DESIRE_MODERATE;
	end

	return BOT_ACTION_DESIRE_NONE;

end


function ConsiderPounce()

	-- Make sure it's castable
	if ( not abilityPC:IsFullyCastable() or npcBot:GetAttackRange() > 320 ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilityPC:GetSpecialValueInt( "max_range" );
	local nManaCost = abilityPC:GetManaCost();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nRadius, true);
		
		if ( lanecreeps~= nil and #lanecreeps >= 3  ) 
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
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderPounce2()

	-- Make sure it's castable
	if ( not abilityPC2:IsFullyCastable() or npcBot:GetAttackRange() < 320 ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nCastRange = abilityPC2:GetCastRange(  );
	local nCastPoint = abilityPC2:GetCastPoint(  );
	local nRadius    = abilityPC2:GetSpecialValueInt("axe_width")
	local nDamage    = abilityPC2:GetSpecialValueInt("axe_damage") * 2.2
	local nManaCost  = abilityPC2:GetManaCost( );
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
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_LANING  or  mutil.IsPushing(npcBot) or  mutil.IsDefending(npcBot) and currManaP > 0.60
	then
	   
	
		local laneCreeps = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		for _,creep in pairs(laneCreeps)
		do
			if creep:GetHealth() <= nDamage then
				return BOT_ACTION_DESIRE_HIGH, creep:GetLocation ();
		    end
        end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW,npcTarget:GetLocation();
		end
	end	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange+200, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 3 and #lanecreeps >= 3 ) 
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

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) 
	then
		local npcTarget = npcBot:GetTarget();

		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-200) 
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderShadowDance()

	-- Make sure it's castable
	if ( not abilitySD:IsFullyCastable() or npcBot:GetHealth() > 0.55* npcBot:GetMaxHealth() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nAttackRange = npcBot:GetAttackRange();
	

	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nAttackRange)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) 
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nAttackRange) 
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end
