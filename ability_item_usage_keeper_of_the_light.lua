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




local castFBDesire = 0;
local castCSDesire = 0;
local castCSSDesire = 0;
local castCS2Desire = 0;
local castBLDesire = 0;
local castFGDesire = 0;
local castRCDesire = 0;
local castWoWDesire = 0;

local CancelIlmDesire = 0;
local castCSFDesire = 0;

local abilityFB = nil;
local abilityCS = nil;
local abilityCSS = nil;
local abilityCS2 = nil;
local abilityBL = nil;
local abilityFB = nil;
local abilityRC = nil;
local abilityWoW = nil;
local abilitySFC = nil;

local npcBot = GetBot();
local bot = GetBot();



local LigthIluminateDamage  = 0;






function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot)  or npcBot:NumQueuedActions() > 0  then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "keeper_of_the_light_mana_leak" ) end
	if abilityCS == nil then abilityCS = npcBot:GetAbilityByName( "keeper_of_the_light_illuminate" ) end
	if abilityCSS == nil then abilityCSS = npcBot:GetAbilityByName( "keeper_of_the_light_spirit_form_illuminate" ) end
	if abilityCS2 == nil then abilityCS2 = npcBot:GetAbilityByName( "keeper_of_the_light_blinding_light" ) end
	if abilityBL == nil then abilityBL = npcBot:GetAbilityByName( "keeper_of_the_light_chakra_magic" ) end
	if abilityFG == nil then abilityFG = npcBot:GetAbilityByName( "keeper_of_the_light_spirit_form" ) end
	if abilityRC == nil then abilityRC = npcBot:GetAbilityByName( "keeper_of_the_light_recall" ) end
	if abilityWoW == nil then abilityWoW = npcBot:GetAbilityByName( "keeper_of_the_light_will_o_wisp" ) end
	if abilitySFC == nil then abilitySFC = npcBot:GetAbilityByName( "keeper_of_the_light_spirit_form_illuminate_end" ) end
	
	CancelIlmDesire = ConsiderCancelIlm();
	-- ability_item_usage_generic.SwapItemsTest()
	
	if CancelIlmDesire > 0 then
		npcBot:Action_MoveToLocation(npcBot:GetLocation()+RandomVector(200))
		
		return
	end
	
	

	-- Consider using each ability
	-- castFBDesire, castFBTarget = ConsiderFireblast();
	castCSDesire, castCSLocation = ConsiderChrono();
	castCSSDesire, castCSSLocation = ConsiderChronoS();
	castCS2Desire, castCS2Location = ConsiderChrono2();
	castBLDesire, castBLTarget = ConsiderBloodlust();
	castWoWDesire, castWoWLoc = ConsiderWillOWisp();
	castCSS, castWoWLoc = ConsiderWillOWisp();
	castCSFDesire     = ConsiderChronoSCancel();
	
	
	

	-- castFGDesire, castFGTarget = ConsiderFleshGolem();
	-- castRCDesire, castRCTarget = ConsiderRecall();
	if ( castWoWDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityWoW, castWoWLoc );
		return;
	end	


	if ( castFGDesire > 0 ) 
	then
		
		npcBot:Action_UseAbility( abilityFG );
		return;
	end
	
	if ( castCS2Desire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityCS2, castCS2Location );
		return;
	end	
	
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end
	
	if ( castCSDesire > 0 ) 
	then
		npcBot:Action_ClearActions( true ); 
		npcBot:ActionQueue_UseAbilityOnLocation( abilityCS, castCSLocation );
		npcBot:ActionQueue_Delay( 0.5 );
		-- nCountTime = DotaTime();
		return;
	end	
	if ( castCSSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityCSS, castCSSLocation );
		return;
	end	
	
	if ( castBLDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityBL, castBLTarget );
		return;
	end
	
	if ( castRCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityRC, castRCTarget );
		return;
	end
	
	
	
end

if npcBot:IsChanneling() then

	if abilityCS:IsInAbilityPhase() then 
		if abilityCS:GetChannelTime () == 1 then
			LigthIluminateDamage = 200
			elseif abilityCS:GetChannelTime () == 2 then
			LigthIluminateDamage = 300
			elseif abilityCS:GetChannelTime () == 3 then
			LigthIluminateDamage = 400
			elseif abilityCS:GetChannelTime () == 4 then
			LigthIluminateDamage = 500		
		end
	end
	return
end


function ConsiderFireblast()

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderChrono()

	-- Make sure it's castable
	if ( abilityCS:IsHidden() or not abilityCS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityCS:GetSpecialValueInt("radius");
	local nCastRange = abilityCS:GetCastRange();
	local nCastPoint = abilityCS:GetCastPoint();
	local ChannelTime = abilityCS:GetSpecialValueInt("max_channel_time");
	local nDamage =  abilityCS:GetSpecialValueInt("total_damage"); 
	local nSpeed   = abilityCS:GetSpecialValueInt("speed");
    
		
	
	if nCastRange > 1600 then
		nCastRange = 1600;
	end
	
	
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and not mutil.IsRetreating(npcBot))
	then
		if (  mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and mutil.IsInRange(npcTarget, npcBot, nCastRange - 200)  )
		then
			return BOT_ACTION_DESIRE_HIGH,npcTarget:GetLocation();
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(1200, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange-200, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 8 and #lanecreeps >= 8 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange/2)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange/2, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange-200 );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					then 
					return BOT_ACTION_DESIRE_MODERATE,neutral:GetLocation();
				end
			end
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-200)
		and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
		
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange-200, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end	

	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderChronoS()

	-- Make sure it's castable
	if ( not abilityCSS:IsFullyCastable() or abilityCSS:IsHidden() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityCSS:GetSpecialValueInt("radius");
	local nCastRange = abilityCSS:GetCastRange() ;
	local nCastPoint = abilityCSS:GetCastPoint();

	if nCastRange > 1600 then
		nCastRange = 1600;
	end
	
	
	local nSpeed   = abilityCSS:GetSpecialValueInt("speed");
	local ChannelTime = abilityCSS:GetSpecialValueInt("max_channel_time");
	local nDamage =  abilityCSS:GetSpecialValueInt("total_damage");
	
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and not mutil.IsRetreating(npcBot) )
	then
		if (  mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and mutil.IsInRange(npcTarget, npcBot, nCastRange - 200)  )
		then
			return BOT_ACTION_DESIRE_HIGH,npcTarget:GetLocation();
		end
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and ( npcBot:HasModifier("modifier_keeper_of_the_light_spirit_form") or npcBot:HasScepter() ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 )
			then
				local cpos = utils.GetTowardsFountainLocation( bot:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_LOW, npcBot:GetXUnitsInFront(400);
			end
		end
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(1600, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					then 
					return BOT_ACTION_DESIRE_MODERATE,neutral:GetLocation();
				end
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end	
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderBloodlust()

	-- Make sure it's castable
	if ( not abilityBL:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityBL:GetCastRange();
	
	if  npcBot:GetMana() / npcBot:GetMaxMana() < 0.75 then
		return BOT_ACTION_DESIRE_MODERATE, npcBot;
	else
		local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
		for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
			if ( mutil.CanCastOnNonMagicImmune(myFriend) and myFriend:GetMana() / myFriend:GetMaxMana() < 0.65  ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, myFriend;
			end
		end	
	end
	
	-- if  npcBot:GetMana() / npcBot:GetMaxMana() > 0.5 then
		-- -- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
		-- if mutil.IsRetreating(npcBot)
		-- then
			-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
			-- for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			-- do
				-- if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
				-- then
					-- return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				-- end
			-- end
		-- end

		-- -- If we're going after someone
		-- if mutil.IsGoingOnSomeone(npcBot)
		-- then
			-- local npcTarget = npcBot:GetTarget();
			-- if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
			-- then
				-- return BOT_ACTION_DESIRE_HIGH, npcTarget;
			-- end
		-- end
	-- end
	
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderFleshGolem()

	-- Make sure it's castable
	if ( npcBot:HasScepter() or npcBot:HasModifier("modifier_keeper_of_the_light_spirit_form") or not abilityFG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = 1000;
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
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
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1000)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderChrono2()

	-- Make sure it's castable
	if ( 
		-- not npcBot:HasModifier("modifier_keeper_of_the_light_spirit_form") 
		abilityCS2:IsHidden() or 
		not abilityCS2:IsFullyCastable() 
	) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityCS2:GetSpecialValueInt("radius");
	local nCastRange = abilityCS2:GetCastRange();
	local nCastPoint = abilityCS2:GetCastPoint();
	local nDamage    = abilityCS2:GetSpecialValueInt( "damage");
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();

	
	
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) )
	then
		if (  mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_HIGH,npcTarget:GetLocation();
		end
	end
	
	
	
	
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) )
			then
				if GetUnitToUnitDistance(npcEnemy, npcBot) < nRadius then
					return BOT_ACTION_DESIRE_LOW, npcBot:GetLocation()
				else
					return BOT_ACTION_DESIRE_LOW, npcEnemy:GetExtrapolatedLocation(nCastPoint)
				end
			end
		end
	end
	
	
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(1600, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 8 and #lanecreeps >= 8 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetExtrapolatedLocation(nCastPoint);
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
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					then 
					return BOT_ACTION_DESIRE_MODERATE,neutral:GetLocation();
				end
			end
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange - (nRadius / 2))
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange+200, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderRecall()

	-- Make sure it's castable
	if ( not npcBot:HasModifier("modifier_keeper_of_the_light_spirit_form") or abilityRC:IsHidden() or not abilityRC:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	local numPlayer =  GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local player = GetTeamMember(i);
		if player ~= nil and not IsPlayerBot(player:GetPlayerID()) and player:IsAlive() and GetUnitToUnitDistance(npcBot, player) > 1000 then
				local p = player:GetMostRecentPing();
				if p ~= nil and GetUnitToLocationDistance(player, p.location) < 1000 and GameTime() - p.time < 10 then
					--print("Human pinged to get recalled")
					return BOT_ACTION_DESIRE_MODERATE, player;
				end
		end
	end
	
	if  mutil.IsDefending(npcBot)
	then
		local nearbyTower = npcBot:GetNearbyTowers(1000, false) 
		if nearbyTower[1] ~= nil then
			local maxDist = 0;
			local target = nil;
			for i = 1, #numPlayer
			do
				local player = GetTeamMember(i);
				if player ~= nil and player:IsAlive() and player:GetActiveMode() ~= BOT_MODE_RETREAT then
					local dist = GetUnitToUnitDistance(nearbyTower[1], player);
					local health = player:GetHealth()/player:GetMaxHealth();
					if IsPlayerBot(player:GetPlayerID()) and dist > maxDist and dist > 2500 and health >= 0.25 then
						maxDist = dist;
						target = GetTeamMember(i);
					end
				end
			end
			if target ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, target;
			end
		end
	end
	
	if mutil.IsPushing(npcBot)
	then
		local nearbyTower = npcBot:GetNearbyTowers(1000, true) 
		if nearbyTower[1] ~= nil then
			local maxDist = 0;
			local target = nil;
			for i = 1, #numPlayer
			do
				local player = GetTeamMember(i);
				if player ~= nil and player:IsAlive() and player:GetActiveMode() ~= BOT_MODE_RETREAT then
					local dist = GetUnitToUnitDistance(nearbyTower[1], player);
					local health = player:GetHealth()/player:GetMaxHealth();
					if IsPlayerBot(player:GetPlayerID()) and dist > maxDist and dist > 2500 and health >= 0.25  then
						maxDist = dist;
						target = GetTeamMember(i);
					end
				end
			end
			if target ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, target;
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil  and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < 1000  ) 
		then	
			local maxDist = 0;
			local target = nil;
			for i = 1, #numPlayer
			do
				local player = GetTeamMember(i);
				if player ~= nil and player:IsAlive() and player:GetActiveMode() ~= BOT_MODE_RETREAT then
					local dist = GetUnitToUnitDistance(player, npcBot);
					local health = player:GetHealth()/player:GetMaxHealth();
					if IsPlayerBot(player:GetPlayerID()) and dist > maxDist and dist > 2500 and health >= 0.25 then
						maxDist = dist;
						target = GetTeamMember(i);
					end
				end
			end
			if target ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, target;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

-- function ConsiderCancelIlm()

	-- if not npcBot:IsChanneling() or not npcBot:HasModifier('modifier_keeper_of_the_light_illuminate') 
	-- then
	-- return BOT_MODE_NONE; end
	
	
	-- local nCastRange = abilityCS:GetCastRange();
	-- local nCastPoint = abilityCS:GetCastPoint();

	-- if nCastRange > 1600 then
		-- nCastRange = 1600;
	-- end
	-- -- local nDamage =  abilityCSS:GetSpecialValueInt("total_damage");
	-- local nSpeed   = abilityCSS:GetSpecialValueInt("speed");
	-- local ChannelTime = abilityCSS:GetSpecialValueInt("max_channel_time");
	-- -- local nDamagePs   =  abilityCSS:GetSpecialValueInt("damage_per_second");
	
	-- for i=1,#DotaTime() do
	-- CCStartTime = CCStartTime + 1
	-- CCSEndTime  = CCSEndTime  + 1	
	-- local nDamage = {}	
	-- end
	-- -----------------------------------------------------------------
	-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	-- local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );	
	-- if (tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 and npcBot:WasRecentlyDamagedByAnyHero(2.0)  and  tableNearbyAlliedHeroes ~= nil and #tableNearbyAlliedHeroes == 0 ) 
		-- then
		-- return BOT_ACTION_DESIRE_HIGH;
	-- end
	
	-- -----------------------------------------------
	
	-- -- If a mode has set a target, and we can kill them, do it
	-- local npcTarget = npcBot:GetTarget();
	-- if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) )
	-- then	
		-- if  CCStartTime >= DotaTime() + 1 and CCSEndTime < DotaTime() + 2 then
			-- nDamage = 100
		-- if mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and mutil.IsInRange(npcTarget, npcBot, nCastRange )
			-- then
			-- npcBot:ActionImmediate_Chat("nDamage 100", true)
			-- return BOT_ACTION_DESIRE_HIGH;
		-- elseif  CCStartTime > DotaTime() + 1 and CCSEndTime < DotaTime() + 3 then
			-- nDamage = 200
		-- if mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and mutil.IsInRange(npcTarget, npcBot, nCastRange )
			-- then
			-- npcBot:ActionImmediate_Chat("nDamage 200", true)
			-- return BOT_ACTION_DESIRE_HIGH;
		-- elseif  CCStartTime > DotaTime() + 2 and CCSEndTime < DotaTime() + 4 then
			-- nDamage = 300
		-- if mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and mutil.IsInRange(npcTarget, npcBot, nCastRange )
			-- then
			-- npcBot:ActionImmediate_Chat("nDamage 300", true)
			-- return BOT_ACTION_DESIRE_HIGH;
		-- elseif  CCStartTime > DotaTime() + 3 and CCSEndTime < DotaTime() + 5 then
			-- nDamage = 400
		-- if mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and mutil.IsInRange(npcTarget, npcBot, nCastRange )
			-- then
			-- npcBot:ActionImmediate_Chat("nDamage 400", true)
			-- return BOT_ACTION_DESIRE_HIGH;
		-- elseif  CCStartTime > DotaTime() + 4 and CCSEndTime <= DotaTime() + 5 then
			-- nDamage = 500
		-- if mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and mutil.IsInRange(npcTarget, npcBot, nCastRange )
			-- then
			-- npcBot:ActionImmediate_Chat("nDamage 500", true)
			-- return BOT_ACTION_DESIRE_HIGH;
		-- end
	-- end
	-- end
	-- end
	-- end
	-- end
	-- end
	
	
	
	-- local nCastRange = 900
	-- local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange, 2.0);
	
	-- if skThere then
		-- return BOT_ACTION_DESIRE_MODERATE;
	-- end	
	
	-- return BOT_ACTION_DESIRE_NONE;
	
-- end




function ConsiderCancelIlm()


	local nRadius = abilityCS:GetSpecialValueInt("radius");
	local nCastRange = 1200

	if not npcBot:IsChanneling() or not npcBot:HasModifier('modifier_keeper_of_the_light_illuminate')  then return BOT_MODE_NONE; end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	
	if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 and npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0)
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	
	
	
		-- If a mode has set a target, and we can kill them, do it
	local target = npcBot:GetTarget();
	
	if  mutil.IsValidTarget(target) and mutil.CanCastOnNonMagicImmune(target) and mutil.IsInRange(target, npcBot, nCastRange )
		and not npcBot:IsFacingLocation(target:GetLocation(),5) 
		then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	
	if  mutil.IsValidTarget(target) and mutil.CanCastOnNonMagicImmune(target) 
		and mutil.CanKillTarget(target, LigthIluminateDamage, DAMAGE_TYPE_MAGICAL) and mutil.IsInRange(target, npcBot, nCastRange )
		and npcBot:IsFacingLocation(target:GetLocation(),5) 
	then
	local enemy_heroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	if #enemy_heroes > 0 then
		for i=1, #enemy_heroes do
		if mutils.IsValidTarget(enemy_heroes[i]) and  mutil.CanCastOnMagicImmune(enemy_heroes[i])
		then
		local distance = GetUnitToUnitDistance(enemy_heroes[i], bot)
				local moveCon = enemy_heroes[i]:GetMovementDirectionStability();
				local pLoc = enemy_heroes[i]:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
				if moveCon < 3.0 then
					pLoc = enemy_heroes[i]:GetLocation();
				end
	if IsHeroBetweenMeAndTarget(bot, enemy_heroes[i], pLoc, nRadius) == true
		then
	
	return BOT_ACTION_DESIRE_HIGH;
	end	
	end
	end
	end
	end
	
		
	
	
	
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE;
	end	
	
	
	return BOT_ACTION_DESIRE_NONE;
	
end



function ConsiderChronoSCancel()


	local nRadius = abilityCS:GetSpecialValueInt("radius");
	local nCastRange = 1200

	-- if not npcBot:IsChanneling() or not npcBot:HasModifier('modifier_keeper_of_the_light_illuminate')  then return BOT_MODE_NONE; end
	
	-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	
	-- if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 and npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0)
	-- then
		-- return BOT_ACTION_DESIRE_HIGH;
	-- end
	
	
	
	
		-- If a mode has set a target, and we can kill them, do it
	local target = npcBot:GetTarget();
	
	if  mutil.IsValidTarget(target) and mutil.CanCastOnNonMagicImmune(target) and mutil.IsInRange(target, npcBot, nCastRange )
		and not npcBot:IsFacingLocation(target:GetLocation(),5) 
		then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	
	if  mutil.IsValidTarget(target) and mutil.CanCastOnNonMagicImmune(target) 
		and mutil.CanKillTarget(target, LigthIluminateDamage, DAMAGE_TYPE_MAGICAL) and mutil.IsInRange(target, npcBot, nCastRange )
		and npcBot:IsFacingLocation(target:GetLocation(),5) 
	then
	local enemy_heroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	if #enemy_heroes > 0 then
		for i=1, #enemy_heroes do
		if mutils.IsValidTarget(enemy_heroes[i]) and  mutil.CanCastOnMagicImmune(enemy_heroes[i])
		then
		local distance = GetUnitToUnitDistance(enemy_heroes[i], bot)
				local moveCon = enemy_heroes[i]:GetMovementDirectionStability();
				local pLoc = enemy_heroes[i]:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
				if moveCon < 3.0 then
					pLoc = enemy_heroes[i]:GetLocation();
				end
	if IsHeroBetweenMeAndTarget(bot, enemy_heroes[i], pLoc, nRadius) == true
		then
	
	return BOT_ACTION_DESIRE_HIGH;
	end	
	end
	end
	end
	end
	
		
	
	
	
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE;
	end	
	
	
	return BOT_ACTION_DESIRE_NONE;
	
end

function ConsiderWillOWisp()

	-- Make sure it's castable
	if ( abilityWoW:IsHidden() or not abilityWoW:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityWoW:GetSpecialValueInt("radius");
	local nCastRange = abilityWoW:GetCastRange();
	local nCastPoint = abilityWoW:GetCastPoint();
	
	if nCastRange > 1300 then
		nCastRange = 1300;
	end

	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius+200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation();
			end
		end
	end

	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		and not mutil.IsSuspiciousIllusion(npcTarget)
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end


















function IsHeroBetweenMeAndTarget(source, target, endLoc, radius)
	local vStart = source:GetLocation();
	local vEnd = endLoc;
	local enemy_heroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for i=1, #enemy_heroes do
		if enemy_heroes[i] ~= target
			and enemy_heroes[i] ~= source
		then	
			local tResult = PointToLineDistance(vStart, vEnd, enemy_heroes[i]:GetLocation());
			if tResult ~= nil 
				and tResult.within == true  
				and tResult.distance < radius + 25 			
			then
				return true;
			end
		end
	end
	local ally_heroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
	for i=1, #ally_heroes do
		if ally_heroes[i] ~= target
			and ally_heroes[i] ~= source
		then	
			local tResult = PointToLineDistance(vStart, vEnd, ally_heroes[i]:GetLocation());
			if tResult ~= nil 
				and tResult.within == true  
				and tResult.distance < radius + 25 			
			then
				return true;
			end
		end
	end
	return false;
end