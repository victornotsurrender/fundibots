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

local castSSDesire = 0;
local castTSDesire = 0;
local castPCDesire = 0;
local castFGDesire = 0;
local castBPDesire = 0;

local defDuration = 2;
local offDuration = 4.25;
local CCStartTime = 0;

local abilityTS = nil;
local abilityPC = nil;
local abilitySS = nil;
local abilityFG = nil;
local abilityBP = nil;

-- local npcBot = nil;
local npcBot = GetBot();
local bot = GetBot();
function AbilityUsageThink()
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	-- if npcBot == nil then npcBot = GetBot(); end
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	
	-- ability_item_usage_generic.UnImplementedItemUsage();

	if abilityTS == nil then abilityTS = npcBot:GetAbilityByName( "alchemist_unstable_concoction_throw" ) end
	if abilityPC == nil then abilityPC = npcBot:GetAbilityByName( "alchemist_unstable_concoction" ) end
	if abilitySS == nil then abilitySS = npcBot:GetAbilityByName( "alchemist_acid_spray" ) end
	if abilityFG == nil then abilityFG = npcBot:GetAbilityByName( "alchemist_chemical_rage" ) end
	if abilityBP == nil then abilityBP = npcBot:GetAbilityByName( "alchemist_berserk_potion" ) end

	-- Consider using each ability
	castSSDesire, castSSLocation = ConsiderStaticStorm();
	castTSDesire, castTSTarget = ConsiderThunderStorm();
	castPCDesire = ConsiderPounce();
	castFGDesire = ConsiderFleshGolem();
	castBPDesire, castBPTarget = ConsiderBerserkPotion();
	
	if ( castFGDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityFG );
		return;
	end

	if ( castTSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityTS, castTSTarget );
		return;
	end
	
	if ( castSSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilitySS, castSSLocation );
		return;
	end
	
	if ( castPCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityPC );
		CCStartTime =  DotaTime();
		return;
	end
	
	if ( castBPDesire > 0 ) 
	then
		-- local typeAOE = mutil.CheckFlag(abilityBP:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET);
		-- if typeAOE == true then
		npcBot:ActionPush_UseAbilityOnEntity( abilityBP, castBPTarget );
		return;
	end
	-- end
	
	-- if ( castFSDesire > 0 ) 
	-- then
		-- local typeAOE = mutil.CheckFlag(abilityFS:GetBehavior(), ABILITY_BEHAVIOR_POINT);
		-- if typeAOE == true then
			-- npcBot:Action_UseAbilityOnLocation( abilityFS, castFSTarget:GetLocation() );
		-- else
			-- npcBot:Action_UseAbilityOnEntity( abilityFS, castFSTarget );
		-- end
		-- return;
	-- end
	
end


function ConsiderPounce()

	-- Make sure it's castable
	if ( not abilityPC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nCastRange = abilityPC:GetCastRange()
	local nDamage = abilityPC:GetSpecialValueInt( "max_damage" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 )  and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) )
	then
		if (  mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_PHYSICAL) and mutil.IsInRange(npcTarget, npcBot, nCastRange - 200)  )
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange - 200)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end



function ConsiderThunderStorm()

	-- Make sure it's castable
	if ( not abilityTS:IsFullyCastable() or abilityTS:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- Get some of its values
	local nCastRange = abilityTS:GetCastRange();
	local nDamage = abilityPC:GetSpecialValueInt( "max_damage" );
	
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) )
	then
		if ( ( DotaTime() == CCStartTime + offDuration or 
				mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_PHYSICAL)  ) and 
				mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do 
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) and DotaTime() >= CCStartTime + defDuration ) 
			then
				
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if mutil.IsValidTarget(npcTarget) and 
		   mutil.CanCastOnNonMagicImmune(npcTarget) and 
		   ( DotaTime() >= CCStartTime + offDuration or npcTarget:GetHealth() < nDamage or npcTarget:IsChanneling() ) 
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end

	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and 
		   ( DotaTime() >= CCStartTime + offDuration or npcEnemy:GetHealth() < nDamage or npcEnemy:IsChanneling() ) and 
		   mutil.IsInRange(npcTarget, npcBot, nCastRange+200)  ) 
		then
			
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderStaticStorm()

	-- Make sure it's castable
	if ( not abilitySS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilitySS:GetSpecialValueInt( "radius" );
	local nCastRange = abilitySS:GetCastRange();
	local nCastPoint = abilitySS:GetCastPoint( );

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
				return BOT_ACTION_DESIRE_MODERATE, npcBot:GetLocation();
			end
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 400, 300, 0, 0 );
		if  locationAoE.count >= 3 then
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
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING or
	     mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) ) and npcBot:GetMana() / npcBot:GetMaxMana() > 0.5
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange+200, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if  locationAoE.count >= 2 then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) ) 
		then
			local EnemyHeroes = npcTarget:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			if ( #EnemyHeroes >= 2 )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
			end
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange+200, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
	
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderFleshGolem()
	-- Make sure it's castable
	if ( not abilityFG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = 1000;
	
	if npcBot:GetHealth() / npcBot:GetMaxHealth() < 0.5 then
		return BOT_ACTION_DESIRE_LOW;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.55
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil then
			return BOT_ACTION_DESIRE_LOW;
		end
	end	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 300)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE  );
		if ( #tableNearbyEnemyHeroes >= 2 )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If we're going after someone
	if  mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius-400) ) 
		then
			
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderBerserkPotion()

	-- Make sure it's castable
	if ( not abilityBP:IsFullyCastable() or abilityBP:IsHidden() == true  ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- Get some of its values
	local nCastRange = abilityBP:GetCastRange();
	
	local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	for _,myFriend in pairs(tableNearbyFriendlyHeroes) 
	do
		if  myFriend:GetUnitName() ~= npcBot:GetUnitName() and mutil.IsRetreating(myFriend) and
			myFriend:WasRecentlyDamagedByAnyHero(2.0) and mutil.CanCastOnNonMagicImmune(myFriend)
			and not  myFriend:HasModifier("modifier_alchemist_berserk_potion")
		then
			return BOT_ACTION_DESIRE_MODERATE, myFriend;
		end
	end	
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do 
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and not  npcBot:HasModifier("modifier_alchemist_berserk_potion")) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcBot;
			end
		end
	end
	
	
	-- If we're in a teamfight, use it on the protect ally
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local lowHpAlly = nil;
		local nLowestHealth = 10000;
		local tableNearbyAllies = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE  );
		for _,npcAlly in pairs( tableNearbyAllies )
		do
			if ( npcAlly:GetUnitName() ~= npcBot:GetUnitName() and mutil.CanCastOnNonMagicImmune(npcAlly) 
			    and not  npcAlly:HasModifier("modifier_alchemist_berserk_potion"))
			then
				local nAllyHP = npcAlly:GetHealth();
				if ( ( nAllyHP < nLowestHealth or npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.5 ) or mutil.IsDisabled(false, npcAlly) )
				then
					nLowestHealth = nAllyHP;
					lowHpAlly = npcAlly;
				end
			end
		end

		if ( lowHpAlly ~= nil )
		then
			return BOT_ACTION_DESIRE_MODERATE,lowHpAlly;
		end
	end
	

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget(); 
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) 
		   and mutil.IsInRange(npcTarget, npcBot, nCastRange/2) and not  npcBot:HasModifier("modifier_alchemist_berserk_potion")
		    
		then
			return BOT_ACTION_DESIRE_MODERATE, npcBot;
		end
	end
	
	

	
	
	return BOT_ACTION_DESIRE_NONE;
end
