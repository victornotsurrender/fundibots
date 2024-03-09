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

local castSNDesire = 0;
local castFFDesire = 0;
local castFBDesire = 0;
local castFLDesire = 0;
local castBlinkDesire = 0;
local castForceDesire = 0;

local abilitySN = nil;
local abilityFB = nil;
local abilityFF = nil;
local abilityFL = nil;

-- local npcBot = nil;
local npcBot = GetBot();
local bot = GetBot();
function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	
	if abilitySN == nil then abilitySN = npcBot:GetAbilityByName( "batrider_sticky_napalm" ); end
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "batrider_flamebreak" ); end
	if abilityFF == nil then abilityFF = npcBot:GetAbilityByName( "batrider_firefly" ); end
	if abilityFL == nil then abilityFL = npcBot:GetAbilityByName( "batrider_flaming_lasso" ); end

	-- Consider using each ability
	castSNDesire, castDCLocation = ConsiderStickyNapalm();
	castFBDesire, castFBLocation = ConsiderFlameBreak();
	castFFDesire = ConsiderFireFly();
	castFLDesire, castFLTarget = ConsiderFlamingLasso();
	castBlinkDesire, itemBlink, castBlinkLoc = ConsiderBlink();
	castForceDesire, itemForce, castForceTarget = ConsiderForceStaff();
	
	if castForceDesire > 0 then
		npcBot:Action_UseAbilityOnEntity( itemForce, castForceTarget );
		return;
	end
	
	if castBlinkDesire > 0 then
		npcBot:Action_UseAbilityOnLocation( itemBlink, castBlinkLoc );
		return;
	end
	
	if ( castFLDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFL, castFLTarget );
		return;
	end
	
	if ( castFFDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityFF );
		return;
	end

	if ( castSNDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilitySN, castDCLocation );
		return;
	end
	
	if ( castFBDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnLocation( abilityFB, castFBLocation );
		return;
	end	
	

end


function ConsiderStickyNapalm()

	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilitySN:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nRadius = abilitySN:GetSpecialValueInt( "radius" );
	local nCastRange = abilitySN:GetCastRange();
	local nCastPoint = abilitySN:GetCastPoint( );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	--------------------------------------
	-- Mode based usage
	---------------------
	
	
	
	
	
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING)  and currManaP > 0.45
	or mutil.IsRetreating(npcBot)   
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		local allies = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE);
		local Atowers = npcBot:GetNearbyTowers(nCastRange, false);
		
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  mutil.CanCastOnNonMagicImmune(npcEnemy)
			then	
		for _,u in pairs(Atowers) do
			if GetUnitToLocationDistance(bot,u:GetLocation()) <= 700 and GetUnitToLocationDistance(npcEnemy,u:GetLocation()) <= 700
				then
			if #allies >= 0 then
				
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
				end
			end
		end
	end
	end
	end
	
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and  tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					then 
					return BOT_ACTION_DESIRE_MODERATE,neutral:GetLocation();
				end
			end
		end
	end
	
	
	
	
	
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
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
	if  ( npcBot:GetActiveMode() == BOT_MODE_LANING or
		mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) ) and npcBot:GetMana() / npcBot:GetMaxMana() > 0.75
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange+200, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4   ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)  ) 
		then
			
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
	
--
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderFlameBreak()

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityFB:GetSpecialValueInt("explosion_radius");
	local nSpeed = abilityFB:GetSpecialValueInt("speed");
	local nCastRange = abilityFB:GetCastRange();
	local nCastPoint = abilityFB:GetCastPoint();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nManaCost  = abilityFB:GetManaCost();
	local nDamage = abilityFB:GetSpecialValueInt("damage_per_second") * abilityFB:GetSpecialValueFloat("damage_duration") + abilityFB:GetSpecialValueInt("damage_impact");


	
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and mutil.CanKillTarget2(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) or npcEnemy:IsChanneling()
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	-- if we can hit any enemies with regen modifier
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and (npcEnemy:HasModifier("modifier_clarity_potion") or npcEnemy:HasModifier("modifier_flask_healing") )then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	


	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) )
			then
				if GetUnitToUnitDistance(npcEnemy, npcBot) < nRadius then
					
					return BOT_ACTION_DESIRE_LOW, npcBot:GetLocation()
				else
					
					return BOT_ACTION_DESIRE_LOW, npcEnemy:GetExtrapolatedLocation(nCastPoint)
				end
			end
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
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
	
	
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING)  and currManaP > 0.45
	or mutil.IsRetreating(npcBot)   
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		local allies = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE);
		local Atowers = npcBot:GetNearbyTowers(nCastRange, false);
		
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  mutil.CanCastOnNonMagicImmune(npcEnemy)
			then	
		for _,u in pairs(Atowers) do
			if GetUnitToLocationDistance(bot,u:GetLocation()) <= 700 and GetUnitToLocationDistance(npcEnemy,u:GetLocation()) <= 700
				then
			if #allies >= 0 then
				
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
				end
			end
		end
	end
	end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1000) ) 
		then
			local nDelay = ( GetUnitToUnitDistance( npcTarget, npcBot ) / nSpeed ) + nCastPoint
			
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nDelay);
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange+200, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end



function ConsiderFireFly()

	-- Make sure it's castable
	if ( not abilityFF:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilityFF:GetSpecialValueInt( "radius" );
	
	if mutil.IsStuck(npcBot)
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	if npcBot:HasModifier('modifier_batrider_flaming_lasso_self') then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE  );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1000)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderFlamingLasso()

	-- Make sure it's castable
	if ( not abilityFL:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityFL:GetCastRange();
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	
	
	-- -- If we're in a teamfight, use it on the protect ally
	-- if mutil.IsInTeamFight(npcBot, 1200) and  npcBot:HasModifier("modifier_item_aghanims_shard")
	-- then
		-- local lowHpAlly = nil;
		-- local nLowestHealth = 1000;
		-- local tableNearbyAllies = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE  );
		-- for _,npcAlly in pairs( tableNearbyAllies )
		-- do
			-- if ( npcAlly:GetUnitName() ~= npcBot:GetUnitName() and mutil.CanCastOnNonMagicImmune(npcAlly) 
			    -- -- and not  npcAlly:HasModifier("modifier_alchemist_berserk_potion"))
			-- then
				-- local nAllyHP = npcAlly:GetHealth();
				-- if ( ( nAllyHP < nLowestHealth or npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.5 ) or mutil.IsDisabled(false, npcAlly) )
				-- then
					-- nLowestHealth = nAllyHP;
					-- lowHpAlly = npcAlly;
				-- end
			-- end
		-- end

		-- if ( lowHpAlly ~= nil )
		-- then
			-- return BOT_ACTION_DESIRE_MODERATE, lowHpAlly;
		-- end
	-- end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if mutil.CanCastOnMagicImmune(npcEnemy)
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	-- If we're in a teamfight, use it on the scariest enemy
	if mutil.IsInTeamFight(npcBot, 1200) 
	then
	if not npcBot:HasModifier("modifier_item_aghanims_shard") then
		local npcToKill = nil;
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if mutil.CanCastOnMagicImmune(npcEnemy) and mutil.IsInRange(npcEnemy, npcBot, nCastRange+200)
			then
				npcToKill = npcEnemy;
			end
			end
			if ( npcToKill ~= nil  )
			then
			return BOT_ACTION_DESIRE_HIGH, npcToKill;
		elseif npcBot:HasModifier("modifier_item_aghanims_shard") 
		then
			local lowHpAlly = nil;
			local nLowestHealth = 1000;
			local tableNearbyAllies = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE  );
			for _,npcAlly in pairs( tableNearbyAllies )
			do
			if ( npcAlly:GetUnitName() ~= npcBot:GetUnitName() and mutil.CanCastOnNonMagicImmune(npcAlly) )
			    -- and not  npcAlly:HasModifier("modifier_alchemist_berserk_potion")
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
			return BOT_ACTION_DESIRE_MODERATE, lowHpAlly;
		end
	end
			
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderBlink()
	local blink = nil;
	
	for i=0,5 do
		local item = npcBot:GetItemInSlot(i)
		if item ~= nil and item:GetName() == "item_blink" then
			blink = item;
			break
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot) and blink ~= nil and blink:IsFullyCastable() and abilityFL:IsFullyCastable()
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and not mutil.IsInRange(npcTarget, npcBot, 600) and mutil.IsInRange(npcTarget, npcBot, 1000) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, blink, npcTarget:GetExtrapolatedLocation(0.1);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil, nil;
end

function ConsiderForceStaff()
	local force = nil;
	
	for i=0,5 do
		local item = npcBot:GetItemInSlot(i)
		if item ~= nil and item:GetName() == "item_force_staff" then
			force = item;
			break
		end
	end
	
	if force ~= nil and force:IsFullyCastable() and npcBot:HasModifier('modifier_batrider_flaming_lasso_self') and npcBot:IsFacingLocation(mutil.GetTeamFountain(),10)
	then
		return BOT_ACTION_DESIRE_MODERATE, force, npcBot
	end
	
	return BOT_ACTION_DESIRE_NONE, nil, nil;
end
