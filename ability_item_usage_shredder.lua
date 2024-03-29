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

local ClosingDesire = 0;
local castSCDesire = 0;
local castTCDesire = 0;
local castCHDesire = 0;
local castCH2Desire = 0;
local castCHRDesire = 0;
local castCHR2Desire = 0;

local abilitySC = nil;
local abilityTC = nil;
local abilityCH = nil;
local abilityCH2 = nil;
local abilityCHR = nil;
local abilityCHR2 = nil;
local abilityFL = nil;

local ultLoc = 0;
local ultLoc2 = 0;
-- local npcBot = nil;
local ultTime1 = 0;
local ultETA1 = 0;
local ultTime2 = 0;
local ultETA2 = 0;

local bot = GetBot();
local npcBot = GetBot();

local ultUseTime1 = -90;
local ultUseTime2 = -90;
function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	-- Check if we're already using an ability
	
	-- ability_item_usage_generic.SwapItemsTest()
	
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	
	if abilitySC == nil then abilitySC = npcBot:GetAbilityByName( "shredder_whirling_death" ) end
	if abilityTC == nil then abilityTC = npcBot:GetAbilityByName( "shredder_timber_chain" ) end
	if abilityCH == nil then abilityCH = npcBot:GetAbilityByName( "shredder_chakram" ) end
	if abilityCH2 == nil then abilityCH2 = npcBot:GetAbilityByName( "shredder_chakram_2" ) end
	if abilityCHR == nil then abilityCHR = npcBot:GetAbilityByName( "shredder_return_chakram" ) end
	if abilityCHR2 == nil then abilityCHR2 = npcBot:GetAbilityByName( "shredder_return_chakram_2" ) end
	if abilityFL == nil then abilityFL = npcBot:GetAbilityByName( "shredder_flamethrower" ) end

	-- Consider using each ability
	castSCDesire = ConsiderSlithereenCrush();
	castTCDesire, castTree, castType = ConsiderTimberChain();
	castCHDesire, castCHLocation, eta = ConsiderChakram();
	castCH2Desire, castCH2Location, eta2 = ConsiderChakram2();
	castCHRDesire = ConsiderChakramReturn();
	castCHR2Desire = ConsiderChakramReturn2();
	ClosingDesire, Target = ConsiderClosing();
	
	if ( castCHRDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityCHR );
		ultLoc = 0; 
		return;
	end
	
	if ( castCHR2Desire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityCHR2 );
		ultLoc2 = 0; 
		return;
	end
	
	if ( castCHDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityCH, castCHLocation );
		ultLoc = castCHLocation; 
		ultTime1 = DotaTime();
		ultETA1 = eta + 0.5;
		ultUseTime1 = DotaTime();
		return;
	end
	
	if ( castCH2Desire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityCH2, castCH2Location );
		ultLoc2 = castCH2Location; 
		ultTime2 = DotaTime();
		ultETA2 = eta2 + 0.5;
		ultUseTime2 = DotaTime();
		return;
	end
	
	if ( castTCDesire > 0 ) 
	then
		--print("Chain")
		if castType == "tree" then
			npcBot:Action_UseAbilityOnLocation( abilityTC, GetTreeLocation(castTree) );
		else
			npcBot:Action_UseAbilityOnLocation( abilityTC, castTree );
		end	
		return;
	end
	
	if ( castSCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySC );
		npcBot:Action_UseAbility(abilityFL);
		return;
	end
	
	if ClosingDesire > 0 then
		npcBot:Action_MoveToLocation(Target);
		return
	end
	
end

function StillTraveling(cType)
	local proj = GetLinearProjectiles();
	for _,p in pairs(proj)
	do
		if p ~= nil and (( cType == 1 and p.ability:GetName() == "shredder_chakram" ) or (  cType == 2 and p.ability:GetName() == "shredder_chakram_2" ) ) then
			return true; 
		end
	end
	return false;
end

function GetBestTree(npcBot, enemy, nCastRange, hitRadios)
   
	--find a tree behind enemy
	local bestTree=nil;
	local mindis=10000;

	local trees=npcBot:GetNearbyTrees(nCastRange);
	
	for _,tree in pairs(trees) do
		local x=GetTreeLocation(tree);
		local y=npcBot:GetLocation();
		local z=enemy:GetLocation();
		
		if x~=y then
			local a=1;
			local b=1;
			local c=0;
		
			if x.x-y.x ==0 then
				b=0;
				c=-x.x;
			else
				a=-(x.y-y.y)/(x.x-y.x);
				c=-(x.y + x.x*a);
			end
		
			local d = math.abs((a*z.x+b*z.y+c)/math.sqrt(a*a+b*b));
			if d<=hitRadios and mindis>GetUnitToLocationDistance(enemy,x) and (GetUnitToLocationDistance(enemy,x)<=GetUnitToLocationDistance(npcBot,x)) then
				bestTree=tree;
				mindis=GetUnitToLocationDistance(enemy,x);
			end
		end
	end
	
	return bestTree;

end

function GetBestRetreatTree(npcBot, nCastRange)
	local trees=npcBot:GetNearbyTrees(nCastRange);
	
	local dest=utils.VectorTowards(npcBot:GetLocation(),utils.Fountain(GetTeam()),1000);
	
	local BestTree=nil;
	local maxdis=0;
	
	for _,tree in pairs(trees) do
		local loc=GetTreeLocation(tree);
		
		if (not utils.AreTreesBetween(loc,100)) and 
			GetUnitToLocationDistance(npcBot,loc)>maxdis and 
			GetUnitToLocationDistance(npcBot,loc)<nCastRange and 
			utils.GetDistance(loc,dest)<880 
		then
			maxdis=GetUnitToLocationDistance(npcBot,loc);
			BestTree=loc;
		end
	end
	
	if BestTree~=nil and maxdis>250 then
		return BestTree;
	end
	
	return nil;
end

function GetUltLoc(npcBot, enemy, nManaCost, nCastRange, s)

	local v=enemy:GetVelocity();
	local sv=utils.GetDistance(Vector(0,0),v);
	if sv>800 then
		v=(v / sv) * enemy:GetCurrentMovementSpeed();
	end
	
	local x=npcBot:GetLocation();
	local y=enemy:GetLocation();
	
	local a=v.x*v.x + v.y*v.y - s*s;
	local b=-2*(v.x*(x.x-y.x) + v.y*(x.y-y.y));
	local c= (x.x-y.x)*(x.x-y.x) + (x.y-y.y)*(x.y-y.y);
	
	local t=math.max((-b+math.sqrt(b*b-4*a*c))/(2*a) , (-b-math.sqrt(b*b-4*a*c))/(2*a));
	
	local dest = (t+0.35)*v + y;

	if GetUnitToLocationDistance(npcBot,dest)>nCastRange or npcBot:GetMana()<100+nManaCost then
		return nil;
	end
	
	if enemy:GetMovementDirectionStability()<0.4 or ((not utils.IsFacingLocation(enemy,utils.Fountain(GetOpposingTeam()),60)) ) then
		dest=utils.VectorTowards(y,utils.Fountain(GetOpposingTeam()),180);
	end

	if mutil.IsDisabled(true, enemy) then
		dest=enemy:GetLocation();
	end
	
	return dest;
	
end

function ConsiderClosing()

	-- Make sure it's castable
	if ( not npcBot:HasModifier("modifier_shredder_chakram_disarm") ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if  mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1000) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderSlithereenCrush()

	-- Make sure it's castable
	if ( not abilitySC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilitySC:GetSpecialValueInt( "whirling_radius" );
	local nCastRange = 0;
	local nDamage = abilitySC:GetSpecialValueInt("whirling_damage");
    local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nManaCost = abilitySC:GetManaCost()
	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 ) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	-- If we're farming and can kill 3+ creeps with LSA
		if (npcBot:GetActiveMode() == BOT_MODE_FARM or npcBot:GetActiveMode() == BOT_MODE_LANING  or  mutil.IsPushing(npcBot) or  mutil.IsDefending(npcBot)) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
		local NearbyCreeps = npcBot:GetNearbyCreeps(nRadius, true);
		if NearbyCreeps ~= nil and #NearbyCreeps >= 3 and npcBot:GetMana()/npcBot:GetMaxMana() > 0.45 then 
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nRadius );	
		for _,neutral in pairs(tableNearbyNeutrals)
		do
		if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 2 then
		return BOT_ACTION_DESIRE_LOW;
		end
	end	
	
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius/2)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	
	
	if (npcBot:GetActiveMode() == BOT_MODE_LANING  or  mutil.IsPushing(npcBot) or  mutil.IsDefending(npcBot)) and currManaP > 0.80
	then
	   
	
		local laneCreeps = npcBot:GetNearbyLaneCreeps(nRadius, true);
		for _,creep in pairs(laneCreeps)
		do
			if creep:GetHealth() <= nDamage then
				return BOT_ACTION_DESIRE_HIGH;
		    end
        end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();

		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)
		and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH;
		end
	end


	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderTimberChain()

	-- Make sure it's castable
	if ( not abilityTC:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	-- Get some of its values
	local nRadius = abilityTC:GetSpecialValueInt( "chain_radius" );
	local nSpeed = abilityTC:GetSpecialValueInt( "speed" );
	local nCastRange = abilityTC:GetCastRange();
	local nDamage = abilityTC:GetSpecialValueInt("damage");

	if mutil.IsStuck(npcBot)
	then
		return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( GetAncient(GetTeam()):GetLocation(), nCastRange ), "loc";
	end
	
	-- -- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	-- if mutil.IsRetreating(npcBot) and npcBot:DistanceFromFountain() > 1000
	-- then
		-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		-- if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 then
			-- local BRTree = GetBestRetreatTree(npcBot, nCastRange);
			-- if BRTree ~= nil then
				-- return BOT_ACTION_DESIRE_MODERATE, BRTree, "loc";
			-- end
		-- end
	-- end
	
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
			if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 then
				local BRTree = GetBestRetreatTree(npcBot, nCastRange);
				if BRTree ~= nil then
				local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, BRTree, "loc";
			end
		  end
	    end
	  end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) and
			not utils.AreTreesBetween( npcTarget:GetLocation(),nRadius ) ) 
		then
			
			local BTree = GetBestTree(npcBot, npcTarget, nCastRange, nRadius);
			if BTree ~= nil then
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, BTree, "tree";
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderChakram()

	-- Make sure it's castable
	if ( not abilityCH:IsFullyCastable() or abilityCH:IsHidden() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0, 0;
	end


	-- Get some of its values
	local nRadius = abilityCH:GetSpecialValueFloat( "radius" );
	local nSpeed = abilityCH:GetSpecialValueFloat( "speed" );
	local nCastRange = abilityCH:GetCastRange();
	local nManaCost = abilityCH:GetManaCost( );
	local nDamage = 2*abilityCH:GetSpecialValueInt("pass_damage");
	local nCastPoint = abilityCH:GetCastPoint( );

	--------------------------------------
	-- Mode based usage
	-------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				local loc = npcEnemy:GetLocation();
				local eta = GetUnitToLocationDistance(npcBot, loc) / nSpeed;
				local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, loc, eta;
			end
		end
	end
	
	-- if npcBot:GetActiveMode() == BOT_MODE_FARM 
	-- then
		-- local npcTarget = npcBot:GetAttackTarget();
		-- if npcTarget ~= nil and not npcTarget:IsBuilding() 
		-- then
		-- local Loc = GetUltLoc(npcBot, npcTarget, nManaCost, nCastRange, nSpeed)
			-- if Loc ~= nil then
				-- local eta = GetUnitToLocationDistance(npcBot, Loc) / nSpeed;
				-- return BOT_ACTION_DESIRE_MODERATE, Loc, eta;
			-- end
		-- end
	-- end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange - 200)  )
		then
		local Loc = GetUltLoc(npcBot, npcTarget, nManaCost, nCastRange, nSpeed)
			if Loc ~= nil then
				local eta = GetUnitToLocationDistance(npcBot, Loc) / nSpeed;
				return BOT_ACTION_DESIRE_MODERATE, Loc, eta;
			end
		end
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 6 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.65 ) 
		then
			local loc = locationAoE.targetloc;
			local eta = GetUnitToLocationDistance(npcBot, loc) / nSpeed;
			return BOT_ACTION_DESIRE_LOW, loc, eta;
		end
	end

	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-200) 
		then
			local Loc = GetUltLoc(npcBot, npcTarget, nManaCost, nCastRange, nSpeed)
			if Loc ~= nil then
				local eta = GetUnitToLocationDistance(npcBot, Loc) / nSpeed;
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, Loc, eta;
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderChakram2()

	-- Make sure it's castable
	if ( not npcBot:HasScepter() or not abilityCH2:IsFullyCastable() or abilityCH2:IsHidden() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nRadius = abilityCH:GetSpecialValueFloat( "radius" );
	local nSpeed = abilityCH:GetSpecialValueFloat( "speed" );
	local nCastRange = abilityCH:GetCastRange();
	local nManaCost = abilityCH:GetManaCost( );
	local nDamage = 2*abilityCH:GetSpecialValueInt("pass_damage");

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				local loc = npcEnemy:GetLocation();
				local eta = GetUnitToLocationDistance(npcBot, loc) / nSpeed;
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, loc, eta;
			end
		end
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 6 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.65 ) 
		then
			local loc = locationAoE.targetloc
			local eta = GetUnitToLocationDistance(npcBot, loc) / nSpeed;
			return BOT_ACTION_DESIRE_LOW, loc, eta;
		end
	end
	
	
	-- if npcBot:GetActiveMode() == BOT_MODE_FARM 
	-- then
		-- local npcTarget = npcBot:GetAttackTarget();
		-- if npcTarget ~= nil and not npcTarget:IsBuilding() 
		-- then
		-- local Loc = GetUltLoc(npcBot, npcTarget, nManaCost, nCastRange, nSpeed)
			-- if Loc ~= nil then
				-- local eta = GetUnitToLocationDistance(npcBot, Loc) / nSpeed;
				-- return BOT_ACTION_DESIRE_MODERATE, Loc, eta;
			-- end
		-- end
	-- end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
		local Loc = GetUltLoc(npcBot, npcTarget, nManaCost, nCastRange, nSpeed)
			if Loc ~= nil then
				local eta = GetUnitToLocationDistance(npcBot, Loc) / nSpeed;
				return BOT_ACTION_DESIRE_MODERATE, Loc, eta;
			end
		end
	end

	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-200) 
		then
			local Loc = GetUltLoc(npcBot, npcTarget, nManaCost, nCastRange, nSpeed)
			if Loc ~= nil then
				local eta = GetUnitToLocationDistance(npcBot, Loc) / nSpeed;
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, Loc, eta;
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderChakramReturn()

	-- Make sure it's castable
	if ( ultLoc == 0 or not abilityCHR:IsFullyCastable() or abilityCHR:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if DotaTime() < ultTime1 + ultETA1 or StillTraveling(1) then 
		return BOT_ACTION_DESIRE_NONE;
	end	
	
	local nRadius = abilityCH:GetSpecialValueFloat( "radius" );
	local nDamage = abilityCH:GetSpecialValueInt("pass_damage");
	local nManaCost = abilityCH:GetManaCost( );
	
	if npcBot:GetMana() < 100 or GetUnitToLocationDistance(npcBot, ultLoc) > 1600 then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	if DotaTime() > ultUseTime1 + 5 then 
	return BOT_ACTION_DESIRE_HIGH;
	end
	
	if  mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING
	then
		local nUnits = 0;
		local nLowHPUnits = 0;
		local NearbyUnits = npcBot:GetNearbyLaneCreeps(1300, true);
		for _,c in pairs(NearbyUnits)
		do 
			if GetUnitToLocationDistance(c, ultLoc) < nRadius  then
				nUnits = nUnits + 1;
			end
			if GetUnitToLocationDistance(c, ultLoc) < nRadius and c:GetHealth() <= nDamage then
				nLowHPUnits = nLowHPUnits + 1;
			end
		end
		if nUnits == 0 or nLowHPUnits >= 1  then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if  npcBot:GetActiveMode() == BOT_MODE_RETREAT or mutil.IsGoingOnSomeone(npcBot) 
	then
		local nUnits = 0;
		local nLowHPUnits = 0;
		local NearbyUnits = npcBot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
		for _,c in pairs(NearbyUnits)
		do 
			if GetUnitToLocationDistance(c, ultLoc) < nRadius  then
				nUnits = nUnits + 1;
			end
			if GetUnitToLocationDistance(c, ultLoc) < nRadius and c:GetHealth() <= nDamage / 2 then
				nLowHPUnits = nLowHPUnits + 1;
			end
		end
		if nUnits == 0 or nLowHPUnits >= 1 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderChakramReturn2()

	-- Make sure it's castable
	if ( not npcBot:HasScepter() or ultLoc2 == 0 or not abilityCHR2:IsFullyCastable() or abilityCHR2:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if DotaTime() < ultTime2 + ultETA2 or StillTraveling(2) then 
		return BOT_ACTION_DESIRE_NONE;
	end	
	
	local nRadius = abilityCH:GetSpecialValueFloat( "radius" );
	local nDamage = abilityCH:GetSpecialValueInt("pass_damage");
	local nManaCost = abilityCH:GetManaCost( );
	
	if npcBot:GetMana() < 100 or GetUnitToLocationDistance(npcBot, ultLoc2) > 1600 then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	if DotaTime() > ultUseTime2 + 5 then 
	return BOT_ACTION_DESIRE_HIGH;
	end
	
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING 
	then
		local nUnits = 0;
		local nLowHPUnits = 0;
		local NearbyUnits = npcBot:GetNearbyLaneCreeps(1000, true);
		for _,c in pairs(NearbyUnits)
		do 
			if GetUnitToLocationDistance(c, ultLoc2) < nRadius  then
				nUnits = nUnits + 1;
			end
			if GetUnitToLocationDistance(c, ultLoc2) < nRadius and c:GetHealth() <= nDamage then
				nLowHPUnits = nLowHPUnits + 1;
			end
		end
		--print("Push"..nUnits)
		if nUnits == 0 or nLowHPUnits >= 1  then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_RETREAT or mutil.IsGoingOnSomeone(npcBot) 
	then
		local nUnits = 0;
		local nLowHPUnits = 0;
		local NearbyUnits = npcBot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
		for _,c in pairs(NearbyUnits)
		do 
			if GetUnitToLocationDistance(c, ultLoc2) < nRadius  then
				nUnits = nUnits + 1;
			end
			if GetUnitToLocationDistance(c, ultLoc2) < nRadius and c:GetHealth() <= nDamage / 2 then
				nLowHPUnits = nLowHPUnits + 1;
			end
		end
		--print("Attck"..nUnits)
		if nUnits == 0 or nLowHPUnits >= 1 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end