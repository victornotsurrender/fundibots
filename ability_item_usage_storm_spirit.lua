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

local castTWDesire = 0;
local castFBDesire = 0;
local castTDDesire = 0;

local abilityTD = nil;
local abilityFB = nil;
local abilityTW = nil;
local abilityOL = nil;

-- local npcBot = nil;
local bot = GetBot();
local npcBot = GetBot();
local STarget = nil;

function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	if abilityTD == nil then abilityTD = npcBot:GetAbilityByName( "storm_spirit_static_remnant" ) end
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "storm_spirit_electric_vortex" ) end
	if abilityTW == nil then abilityTW = npcBot:GetAbilityByName( "storm_spirit_ball_lightning" ) end
	if abilityOL == nil then abilityOL = npcBot:GetAbilityByName( "storm_spirit_overload" ) end
	
	castTDDesire = ConsiderTimeDilation();
	castFBDesire, castFBTarget = ConsiderFireblast();
	castTWDesire, castTWLocation = ConsiderTimeWalk();
	
	if ( castTWDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTW, castTWLocation );
		return;
	end
	if ( castFBDesire > 0 ) 
	then
		if npcBot:HasScepter() then
			npcBot:Action_UseAbility( abilityFB );
			return;
		else
			npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
			return;
		end
	end
	if ( castTDDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityTD );
		return;
	end


end


function GetTowardsFountainLocation( unitLoc, distance )
	local destination = {};
	if ( GetTeam() == TEAM_RADIANT ) then
		destination[1] = unitLoc[1] - distance / math.sqrt(2);
		destination[2] = unitLoc[2] - distance / math.sqrt(2);
	end

	if ( GetTeam() == TEAM_DIRE ) then
		destination[1] = unitLoc[1] + distance / math.sqrt(2);
		destination[2] = unitLoc[2] + distance / math.sqrt(2);
	end
	return Vector(destination[1], destination[2]);
end

function BallLightningAllowed(manaCost)
	if ( npcBot:GetMana() - manaCost ) / npcBot:GetMaxMana() >= 0.20
	then
		return true
	end
	return false
end

function ConsiderFireblast()

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange() + 200;
	if nCastRange < npcBot:GetAttackRange() then nCastRange = npcBot:GetAttackRange() + 200; end
	if npcBot:HasScepter() then nCastRange = 475 end 
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) and not npcBot:HasScepter()
		then
			local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
		
		if ( npcEnemy:IsChanneling() ) and npcBot:HasScepter()
		then
			local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, nil;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
				 and not npcBot:HasScepter()
			then
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		if (tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2) and npcBot:HasScepter() then
			local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, nil;
		end
	end

	if mutil.IsInTeamFight(npcBot, 1200) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcEnemy:IsHero() and role.IsCarry(npcEnemy:GetUnitName()) and mutil.CanCastOnMagicImmune(npcEnemy) 
				and not mutil.IsSuspiciousIllusion(npcEnemy) or (not npcEnemy:IsBot()	) )
				and not npcBot:HasScepter()
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		
		if (tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2) and npcBot:HasScepter() then
			return BOT_ACTION_DESIRE_MODERATE, nil;
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
			and not  npcBot:HasScepter()
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
		if npcBot:HasScepter() then
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW,nil;
		end
	end
	end
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) 
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-100) and
		   not mutil.IsDisabled(true, npcTarget) and not  npcBot:HasScepter()
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
		if npcBot:HasScepter() then
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-100) and
		   not mutil.IsDisabled(true, npcTarget) 
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, nil;
		end
	 end
	end
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderTimeWalk()

	-- Make sure it's castable
	if ( not abilityTW:IsFullyCastable() or abilityTW:IsInAbilityPhase() or npcBot:HasModifier("modifier_storm_spirit_ball_lightning") or npcBot:IsRooted() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastPoint = abilityTW:GetCastPoint( );
	local nInitialMana = abilityTW:GetSpecialValueInt("ball_lightning_initial_mana_base")
	local nInitialManaP = abilityTW:GetSpecialValueInt("ball_lightning_initial_mana_percentage") / 100
	local nTravelCost = abilityTW:GetSpecialValueInt("ball_lightning_travel_cost_base")
	local nTravelCostP = abilityTW:GetSpecialValueFloat("ball_lightning_travel_cost_percent") / 100
	local nSpeed = abilityTW:GetSpecialValueInt ("ball_lightning_move_speed");
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nRadius = abilityTW:GetSpecialValueInt( "ball_lightning_aoe" );
	
	
	
	if mutil.IsStuck(npcBot)
	then
		local loc = mutil.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( loc, 600 );
	end
	
	-- -- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	-- if mutil.IsRetreating(npcBot)
	-- then
		-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		-- local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_ATTACK );
		-- if ( npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0)
		-- or (tableNearbyAlliedHeroes ~= nil and tableNearbyEnemyHeroes ~= nil and #tableNearbyAlliedHeroes <  #tableNearbyEnemyHeroes) )
		-- then
			-- local loc = mutil.GetEscapeLoc();
		    -- return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( loc, 1600 );
		-- end
	-- end
	
	
	if mutils.IsRetreating(bot) 
	then
		
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
		local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_ATTACK );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 and bot:WasRecentlyDamagedByAnyHero(3.0) then
			local loc = mutils.GetEscapeLoc();
			local furthestUnit = mutils.GetClosestUnitToLocationFrommAll(bot, 1600, loc);
			if furthestUnit ~= nil and (GetUnitToUnitDistance(furthestUnit, bot) >= 600 and GetUnitToUnitDistance(furthestUnit, bot) <= 1600)
				then
				return BOT_ACTION_DESIRE_HIGH, furthestUnit:GetLocation();
			elseif (npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0)) 
				then
				if  ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 1  ) 
				or (tableNearbyAlliedHeroes ~= nil and tableNearbyEnemyHeroes ~= nil and #tableNearbyAlliedHeroes <  #tableNearbyEnemyHeroes) 
				then
				return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( loc, 1600 );
			end
		end
	end
	end
	
	-----------------------------------------------------------------
	
	if ( mutil.IsInTeamFight(npcBot, 1600) or FindSuroundedEnemy() or (IsEnemyUnitAroundLocation(bot:GetLocation(), 3000)  and npcBot:GetHealth()/npcBot:GetMaxHealth() > 0.90 ))
		then
		if  currManaP > 0.90 
		then
			local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), 3000, 3000, 0.0, 3000 );
			if ( locationAoE.count >= 1 ) 
			then
			-- bot:ActionImmediate_Chat("11111", true);
		 if GetUnitToLocationDistance( npcBot,locationAoE.targetloc ) > 800 and GetUnitToLocationDistance( npcBot,locationAoE.targetloc ) < 3000 then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
		end
	end
	end
	
	if (npcBot:GetActiveMode() == BOT_MODE_FARM or npcBot:GetActiveMode() == BOT_MODE_LANING or mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot))
		then
		if  currManaP > 0.90 
		then
			local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 3000, 3000, 0.0, 3000 );
			if ( locationAoE.count >= 4 ) 
			then
			-- bot:ActionImmediate_Chat("222222", true);
		 if GetUnitToLocationDistance( npcBot,locationAoE.targetloc ) > 800 and GetUnitToLocationDistance( npcBot,locationAoE.targetloc ) < 2000 then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
		end
	end
	end
	
	
	-- if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	-- then
		-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
		-- local tableNearbyCreeps = npcBot:GetNearbyCreeps( 1600,true );
			-- if tableNearbyCreeps ~= nil and #tableNearbyCreeps >= 2  and bot:HasModifier("modifier_storm_spirit_overload") == false
			-- then		
				-- -- local tableNearbyAllyHeroes = npcTarget:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
				
				-- for _,neutral in pairs(tableNearbyCreeps)
				-- do	 
					-- local MaxMana = npcBot:GetMaxMana();
					-- local distance = GetUnitToUnitDistance( neutral, npcBot );
					-- local TotalInitMana = nInitialMana + ( nInitialManaP * MaxMana );
					-- local TotalTravelMana = ( nTravelCost * ( distance / 100 ) ) + ( nTravelCostP * MaxMana * ( distance / 100 ) );
					-- local TotalMana = TotalInitMana + TotalTravelMana;
				-- if neutral:CanBeSeen() and neutral:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyCreeps ~= nil and #tableNearbyCreeps >= 4
					-- and BallLightningAllowed( TotalMana ) and ( GetUnitToLocationDistance( npcBot,neutral:GetLocation() ) > 800 and GetUnitToLocationDistance( npcBot,neutral:GetLocation() ) < 1600 )
					 -- then 
					-- return BOT_ACTION_DESIRE_MODERATE,neutral:GetLocation();
				-- end
			-- end
		-- end
	-- end
	
	-- if npcBot:DistanceFromFountain() < 1600 and npcBot:GetHealth()/npcBot:GetMaxHealth() > 0.90 
	-- then
		
		-- local enemyCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS );
		-- for _,creep in pairs(enemyCreeps) 
		-- do
			-- if GetUnitToUnitDistance(creep, npcBot) > 2500 and GetUnitToUnitDistance(creep, npcBot) < 8000 and mutil.CanCastOnNonMagicImmune(creep) then

			-- local tableNearbyEnemyCreeps = creep:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
			-- local tableNearbyAllyTower = creep:GetNearbyTowers(450, true);
			-- for i=1, #creep do
				-- if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 1 and tableNearbyAllyTower ~= nil and #tableNearbyAllyTower >= 1
				-- then			
				-- return BOT_ACTION_DESIRE_ABSOLUTE, creep[i]:GetLocation();
				-- end
			-- end
		-- end
	-- end
	-- end
	
	-- local enemyheroes = GetUnitList(UNIT_LIST_ENEMY_HEROES );
	-- for _,enemy in pairs(enemyheroes)
	-- do
		-- local allyNearby = enemy:GetNearbyHeroes(1200, false, BOT_MODE_ATTACK);
		-- -- local allyNearby = enemy:GetNearbyHeroes(1200, false, BOT_MODE_NONE);
		-- if allyNearby ~= nil and #allyNearby >= 2 then
			-- local Sbot = bot:SetTarget(enemy);
			-- local MaxMana = npcBot:GetMaxMana();
			-- local distance = GetUnitToUnitDistance( enemy, npcBot );
			-- local tableNearbyAllyHeroes = enemy:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
			-- local TotalInitMana = nInitialMana + ( nInitialManaP * MaxMana );
			-- local TotalTravelMana = ( nTravelCost * ( distance / 100 ) ) + ( nTravelCostP * MaxMana * ( distance / 100 ) );
			-- local TotalMana = TotalInitMana + TotalTravelMana;
		-- if Sbot	~= nil and BallLightningAllowed( TotalMana ) then 
			-- return  BOT_ACTION_DESIRE_ABSOLUTE, Sbot:GetLocation();
		-- end
	-- end
	-- end
	-- end
	
	if (npcBot:GetActiveMode() == BOT_MODE_FARM or npcBot:GetActiveMode() == BOT_MODE_LANING or mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)) 
	-- and currManaP > 0.9 and npcBot:GetHealth()/npcBot:GetMaxHealth() > 0.9
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
		local allyNearby = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
		local tableNearbyNeutrals = npcBot:GetNearbyCreeps( 1600,true  );
		local enemyCreeps = bot:GetNearbyLaneCreeps(1600 , true);
		local MaxMana = npcBot:GetMaxMana();
		local distance = GetUnitToUnitDistance( neutral, npcBot );
		local TotalInitMana = nInitialMana + ( nInitialManaP * MaxMana );
		local TotalTravelMana = ( nTravelCost * ( distance / 100 ) ) + ( nTravelCostP * MaxMana * ( distance / 100 ) );
		local TotalMana = TotalInitMana + TotalTravelMana;
			-- if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 2 then
			-- if  currManaP > 0.45 and bot:GetLevel() > 10
			-- then
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if #tableNearbyEnemyHeroes <= #allyNearby and bot:HasModifier("modifier_storm_spirit_overload") == false 
					and BallLightningAllowed( TotalMana ) and ( GetUnitToLocationDistance( npcBot,npcEnemy:GetLocation() ) > 800 and GetUnitToLocationDistance( npcBot,npcEnemy:GetLocation() ) < 1600 )
					then 
					
					return BOT_ACTION_DESIRE_MODERATE,npcEnemy:GetLocation();
					
				end
			end
					
			for _,neutral in pairs(tableNearbyNeutrals)
			do
				if #tableNearbyEnemyHeroes == 0  and #tableNearbyNeutrals >=2 and bot:HasModifier("modifier_storm_spirit_overload") == false
					and BallLightningAllowed( TotalMana ) and ( GetUnitToLocationDistance( npcBot,neutral:GetLocation() ) > 800 and GetUnitToLocationDistance( npcBot,neutral:GetLocation() ) < 1600 )
					then 
					
					return BOT_ACTION_DESIRE_MODERATE,neutral:GetLocation();
				end
			end
			-- if enemyCreeps ~= nil and #enemyCreeps >= 2 then	
			for _,creep in pairs(enemyCreeps)
				do
					distance = GetUnitToUnitDistance( creep, npcBot );
					if #tableNearbyEnemyHeroes == 0 and #enemyCreeps >=2 and bot:HasModifier("modifier_storm_spirit_overload") == false
					and BallLightningAllowed( TotalMana ) and ( GetUnitToLocationDistance( npcBot,creep:GetLocation() ) > 800 and GetUnitToLocationDistance( npcBot,creep:GetLocation() ) < 1600 )
					then 
					return BOT_ACTION_DESIRE_MODERATE,creep:GetLocation();
				
		
				end
			end
	end
	-- end
	
	
	
	
	
	
	
	--------------------------------------------------
	
	
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and not mutil.IsInRange(npcTarget, npcBot, npcBot:GetAttackRange()-200) and  mutil.IsInRange(npcTarget, npcBot, 1600)   
		then
			local MaxMana = npcBot:GetMaxMana();
			local distance = GetUnitToUnitDistance( npcTarget, npcBot );
			local tableNearbyAllyHeroes = npcTarget:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
			local TotalInitMana = nInitialMana + ( nInitialManaP * MaxMana );
			local TotalTravelMana = ( nTravelCost * ( distance / 100 ) ) + ( nTravelCostP * MaxMana * ( distance / 100 ) );
			local TotalMana = TotalInitMana + TotalTravelMana;
			--print(TotalMana)
			if tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2 and BallLightningAllowed( TotalMana )
			then
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
	elseif mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nSpeed)
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( nSpeed, false, BOT_MODE_NONE );
			if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes <= 1 then
					local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation( ( GetUnitToUnitDistance( npcTarget, npcBot )/ nSpeed ) + nCastPoint );
				elseif npcBot:HasModifier("modifier_storm_spirit_overload") == true and npcBot:GetHealth() / npcBot:GetMaxHealth() > 0.80 and BallLightningAllowed( TotalMana/2 )
			then
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation( ( GetUnitToUnitDistance( npcTarget, npcBot )/ nSpeed ) + nCastPoint );
			end		
			end	   
			end
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderTimeDilation()

	-- Make sure it's castable
	if ( not abilityTD:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- Get some of its values
	local nRadius = abilityTD:GetSpecialValueInt("static_remnant_radius");
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local attackRange = bot:GetAttackRange();
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if (tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- if npcBot:GetActiveMode() == BOT_MODE_FARM and currManaP > 0.45
	-- then
		-- local npcTarget = npcBot:GetAttackTarget();
		-- if npcTarget ~= nil and not npcTarget:IsBuilding() and abilityOL:GetLevel() > 0 then
			-- return BOT_ACTION_DESIRE_LOW;
		-- end
	-- end
	
	if (npcBot:GetActiveMode() == BOT_MODE_FARM or npcBot:GetActiveMode() == BOT_MODE_LANING or mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)) and currManaP > 0.45 and abilityOL:GetLevel() > 0
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nRadius  );
		local enemyCreeps = bot:GetNearbyLaneCreeps(nRadius , true);
			-- if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 2 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=2
					then 
					return BOT_ACTION_DESIRE_MODERATE;
				else 
			-- if enemyCreeps ~= nil and #enemyCreeps >= 2 then	
					for _,creep in pairs(enemyCreeps)
				do
					if creep:CanBeSeen() and creep:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and enemyCreeps ~= nil and #enemyCreeps >=2
					then 
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
		end
	end
	end
	
	
	if (npcBot:GetActiveMode() == BOT_MODE_FARM or npcBot:GetActiveMode() == BOT_MODE_LANING or mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
			do
			if  mutil.CanCastOnNonMagicImmune(npcEnemy)
				then 
				return BOT_ACTION_DESIRE_MODERATE;
			
			end
		end
	end
	
	
	
	
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nRadius  );
	for _,neutral in pairs(tableNearbyNeutrals)
		do
	if neutral:CanBeSeen() and neutral:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 
		and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=2 and currManaP > 0.45
		and bot:HasModifier("modifier_storm_spirit_overload") == false
		then 
		return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nRadius, true );
	for _,creep in pairs(tableNearbyEnemyCreeps)
		do
	if creep:CanBeSeen() and creep:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 
		and tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >=2 and currManaP > 0.45
		and  bot:HasModifier("modifier_storm_spirit_overload") == false
		then 
		return BOT_ACTION_DESIRE_MODERATE;
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
	
	
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) and currManaP > 0.45
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nRadius, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3  and abilityOL:GetLevel() > 0 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and not mutil.IsInRange(npcTarget, npcBot, nRadius) and mutil.IsInRange(npcTarget, npcBot, attackRange) 
		and npcBot:HasModifier("modifier_storm_spirit_overload") == false and abilityOL:GetLevel() > 0
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end

function IsEnemyUnitAroundLocation(vLoc, nRadius)
	for i,id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id);
			if info ~= nil then
				local dInfo = info[1];
				if dInfo ~= nil and utils.GetDistance(vLoc, dInfo.location) <= nRadius and dInfo.time_since_seen < 1.0 then
					return true;
				end
			end
		end
	end
	return false;
end







function FindSuroundedEnemy()
	local enemyheroes = GetUnitList(UNIT_LIST_ENEMY_HEROES );
	for _,enemy in pairs(enemyheroes)
	do
		local allyNearby = enemy:GetNearbyHeroes(1200, false, BOT_MODE_ATTACK);
		if allyNearby ~= nil and #allyNearby >= 2 then
			return enemy;
		end
	end
	return nil;
end









