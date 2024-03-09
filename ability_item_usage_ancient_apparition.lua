if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile("bots/ability_item_usage_generic")
local utils = require("bots/util")
local mutil = require( "bots/MyUtility")
local eUtils = require("bots/EnemyUtility")
-- local uItem = require("bots/ItemUtility" );
-- local itemUseUtils = require("bots/ItemUsageUtility" );

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


-- local swapTime = -90;

local castCFDesire = 0;
local castIBDesire = 0;
local castIVDesire = 0;
local castCTDesire = 0;
local castIBRDesire = 0;

local ReleaseLoc = {};
local ReleaseLocation = {};

local abilityCF = nil;
local abilityIB = nil;
local abilityIV = nil;
local abilityCT = nil;
local abilityIBR = nil;

local npcBot = GetBot();
local bot = GetBot();

function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	-- if bot == nil then bot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	if abilityCF == nil then abilityCF = npcBot:GetAbilityByName( "ancient_apparition_cold_feet" ) end
	if abilityIB == nil then abilityIB = npcBot:GetAbilityByName( "ancient_apparition_ice_blast" ) end
	if abilityIV == nil then abilityIV = npcBot:GetAbilityByName( "ancient_apparition_ice_vortex" ) end
	if abilityCT == nil then abilityCT = npcBot:GetAbilityByName( "ancient_apparition_chilling_touch" ) end
	if abilityIBR == nil then abilityIBR = npcBot:GetAbilityByName( "ancient_apparition_ice_blast_release" ) end

	-- Consider using each ability
	castCFDesire, castCFTarget = ConsiderColdFeet();
	castIBDesire, castIBLocation = ConsiderIceBlast();
	castIVDesire, castIVLocation = ConsiderIceVortex();
	-- castCTDesire, castCTLocation = ConsiderChillingTouch();
	castCTDesire, castCTTarget = ConsiderChillingTouch();
	castIBRDesire = ConsiderIceBlastRelease();
	
	-- SwapItemWards()
	
	
	
	-- Consider using each ability
	if abilityCT:IsTrained() then
		ToggleChillingTouch();
	end
	
	
	

	if ( castIBRDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityIBR );
		return;
	end
	
	-- if ( castCTDesire > 0 ) 
	-- then
		-- npcBot:Action_UseAbilityOnEntity( abilityCT, castCTLocation );
		-- return;
	-- end	
	if ( castCTDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityCT, castCTTarget );
		return;
	end	
	
	if ( castCFDesire > 0 ) 
	then
		local typeAOE = mutil.CheckFlag(abilityCF:GetBehavior(), ABILITY_BEHAVIOR_POINT);
		if typeAOE == true then
			npcBot:Action_UseAbilityOnLocation( abilityCF, castCFTarget:GetLocation() );
		else
			npcBot:Action_UseAbilityOnEntity( abilityCF, castCFTarget );
		end
		return;
	end
	
	if ( castIBDesire > 0  ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityIB, castIBLocation);
		ReleaseLoc = castIBLocation;
		return;
	end		
	
	if ( castIVDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityIV, castIVLocation );
		ReleaseLocation = castIVLocation;
		return;
	end	
	
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


function ToggleChillingTouch()

	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local npcTarget = npcBot:GetTarget();
	
	if ( npcTarget ~= nil and (npcTarget:IsHero() or npcTarget:GetUnitName() == "npc_dota_roshan"  ) or   ( npcBot:GetActiveMode() == BOT_MODE_FARM  )  and currManaP > 0.25) 
	then
		if not abilityCT:GetAutoCastState( ) then
			abilityCT:ToggleAutoCast()
		end
	else 
		if  abilityCT:GetAutoCastState( ) then
			abilityCT:ToggleAutoCast()
		end
	end
end



function ConsiderColdFeet()

	-- Make sure it's castable
	if ( not abilityCF:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityCF:GetCastRange();
	if nCastRange + 200 > 1600 then nCastRange = 1300; end
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nManaCost  = abilityCF:GetManaCost();
	local nDamage  = abilityCF:GetSpecialValueFloat("damage" )*4; 
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and mutil.CanKillTarget2(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) or npcEnemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	--if we can hit any enemies with regen modifier
	-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and (npcEnemy:HasModifier("modifier_clarity_potion") or npcEnemy:HasModifier("modifier_flask_healing") )then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
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
				
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING or npcBot:GetActiveMode() == BOT_MODE_FARM) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
	   local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
		local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy)
			and npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.80 ) and #tableNearbyAlliedHeroes >=1
			then
				
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
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
				if neutral:CanBeSeen() and neutral:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					then 
					return BOT_ACTION_DESIRE_MODERATE,neutral;
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
									
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
	end
	end
	end
	

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) 
		   and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) and not npcTarget:HasModifier("modifier_ancient_apparition_cold_feet")
		then
			
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end





function ConsiderIceVortex()

	-- Make sure it's castable
	if ( not abilityIV:IsFullyCastable() or abilityIV:IsHidden() or mutil.CanNotBeCast(npcBot) ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityIV:GetSpecialValueInt("radius");
	local nCastRange = abilityIV:GetCastRange();
	local nCastPoint = abilityIV:GetCastPoint();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local speed    	 = 1000
	
	if nCastRange + 200 > 1600 then nCastRange = 1300; end

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) )
			then
				
				return BOT_ACTION_DESIRE_LOW, npcEnemy:GetExtrapolatedLocation(nCastPoint);
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) and npcTarget:HasModifier('modifier_ice_vortex') == false  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if  ( mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING) 
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange+200, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 8 and #lanecreeps >= 8 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.8
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1 and not neutral:HasModifier("modifier_ice_vortex")
					then 
					return BOT_ACTION_DESIRE_MODERATE,neutral:GetExtrapolatedLocation(nCastPoint);
				end
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.IsInRange(npcTarget, npcBot, nCastRange+200) and not npcEnemy:HasModifier("modifier_ice_vortex") ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation(nCastPoint);
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) 
			and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) and not npcTarget:HasModifier("modifier_ice_vortex") 
		then
			
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
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
	
	
	
	
	
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange+200, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end



function ConsiderIceBlast()

	-- Make sure it's castable
	if ( not abilityIB:IsFullyCastable() or abilityIB:IsHidden() or mutil.CanNotBeCast(npcBot) ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nSpeed = abilityIB:GetSpecialValueInt("speed");
	local nCastPoint = abilityIB:GetCastPoint();
	
	local nRadius = abilityIB:GetSpecialValueInt( "radius_max" );
	local nCastRange = abilityIB:GetCastRange();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) )
			then
				local nTime = GetUnitToUnitDistance(npcEnemy, npcBot) / nSpeed;
				
				return BOT_ACTION_DESIRE_LOW, npcEnemy:GetLocation()
			end
		end
	end
	
	-- if  mutil.IsInTeamFight(npcBot, 1600)  or IsEnemyUnitAroundLocation(bot:GetLocation(), 10000) 
		-- then
		-- if  currManaP > 0.70 
		-- then
			-- local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), 10000, 500, 2.0, 1000 );
			-- if ( locationAoE.count >= 1 ) 
			-- then
			-- -- bot:ActionImmediate_Chat("11111", true);
		 -- if GetUnitToLocationDistance( npcBot,locationAoE.targetloc ) > 1000 and GetUnitToLocationDistance( npcBot,locationAoE.targetloc ) < 10000 then
			
			-- return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		-- end
		-- end
	-- end
	-- end
	
	
	-- if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.9
	-- then
		-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		-- local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			-- if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 6 then
				-- for _,neutral in pairs(tableNearbyNeutrals)
				-- do
				-- if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=6
					-- then 
					-- local nTime = GetUnitToUnitDistance(neutral, npcBot) / nSpeed;
					-- return BOT_ACTION_DESIRE_MODERATE,neutral:GetExtrapolatedLocation(nTime + nCastPoint);
				-- end
			-- end
		-- end
	-- end
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) )
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nRadius, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 0, nRadius/2, nCastPoint, 0 );
		if ( locationAoE.count >= 8 and #lanecreeps >= 8  ) 
		then
			local target = mutil.GetVulnerableWeakestUnit(false, true, 1600, bot);
			if target ~= nil then
			return BOT_ACTION_DESIRE_LOW, target:GetLocation();
		end
	end
	end
	
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget)  and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local nTime = GetUnitToUnitDistance(npcTarget, npcBot) / nSpeed;
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nTime + nCastPoint);
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end



function ConsiderIceBlastRelease()

	-- Make sure it's castable
	if ( not abilityIBR:IsFullyCastable() or abilityIBR:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = 1000;
	
	local pro = GetLinearProjectiles();
	for _,pr in pairs(pro)
	do
		if pr ~= nil and pr.ability:GetName() == "ancient_apparition_ice_blast"  then
			if ReleaseLoc ~= nil and utils.GetDistance(ReleaseLoc, pr.location) < 100 then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end	
	end
	
	-- if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) )
	-- then
		-- local lanecreeps = npcBot:GetNearbyLaneCreeps(nRadius, true);
		-- local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 10000, nRadius/2, nCastPoint, 0 );
			-- if ( locationAoE.count >= 8 and #lanecreeps >= 8  ) then	
			
		-- local pro = GetLinearProjectiles();
		-- for _,pr in pairs(pro)
		-- do
		-- if pr ~= nil and pr.ability:GetName() == "ancient_apparition_ice_blast"  then
			-- if ReleaseLocation ~= nil and utils.GetDistance(ReleaseLocation, pr.location) < 100 then
				-- return BOT_ACTION_DESIRE_MODERATE;
			-- end
		-- end	
	-- end
	-- end 
	-- end
	
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderChillingTouch()

	-- Make sure it's castable
	if ( abilityCT:IsHidden() or not abilityCT:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = npcBot:GetAttackRange();
	local nManaCost    = abilityCT:GetManaCost( );
	local nDamage  = npcBot:GetAttackDamage() + abilityCT:GetSpecialValueInt("damage" ); 
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	
	
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and mutil.CanKillTarget2(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) or npcEnemy:IsChanneling()
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	--if we can hit any enemies with regen modifier
	-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and (npcEnemy:HasModifier("modifier_clarity_potion") or npcEnemy:HasModifier("modifier_flask_healing") )then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.60
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and #tableNearbyEnemyHeroes == 0
					then 
					return BOT_ACTION_DESIRE_MODERATE,neutral;
				end
			end
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_LANING or mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot)  and currManaP > 0.8
	then
	   
	
		local laneCreeps = npcBot:GetNearbyLaneCreeps(nCastRange + 200, true);
		for _,creep in pairs(laneCreeps)
		do
			if creep:GetHealth() <= nDamage then
				return BOT_ACTION_DESIRE_MODERATE, creep;
		    end
        end
	end

	-- -- If we're going after someone
	-- if mutil.IsGoingOnSomeone(npcBot)
	-- then
		-- local npcTarget = npcBot:GetTarget();
		-- if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		-- then
			-- return BOT_ACTION_DESIRE_VERYHIGH, npcTarget;
		-- end
	-- end
	
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
































-- function SwapItemWards()
	
				
	-- -- for i=1,#items['earlyGameItem'] do
				-- -- local item = items['earlyGameItem'][i];
				-- -- local itemSlot = bot:FindItemSlot(item);
				
	-- -- if itemWard ~= nil and itemUseUtils.IsInventoryFull2(bot) then
		-- -- local swapWardSlot = (bot:FindItemSlot('item_ward_observer') or bot:FindItemSlot('item_ward_sentry') or bot:FindItemSlot('item_ward_dispenser'))
		-- -- local swapWard = bot:GetItemSlotType(swapWardSlot) == ITEM_SLOT_TYPE_MAIN
		-- -- -- local swapWardX = bot:GetItemSlotType(swapWardSlot) == ITEM_SLOT_TYPE_MAIN
		-- -- local slotToSwap = nil;
		-- -- local slotToWard = nil
		
		
		-- -- for i=1,#uItem['all_items'] do
				-- -- local item = uItem['all_items'][i];
				-- -- local itemSlot = bot:FindItemSlot(item);
		-- -- if bot:GetItemSlotType(itemSlot) == ITEM_SLOT_TYPE_MAIN then
			-- -- slotToSwap = itemSlot
		-- -- if bot:GetItemSlotType(swapWardSlot) == ITEM_SLOT_TYPE_MAIN  then
			-- -- slotToWard = swapWardSlot
		-- -- -- local minSlot = bot:FindItemSlot(itemX:GetName());
		-- -- -- local swapWardSlot = bot:FindItemSlot(itemWard:GetName());
		-- -- -- local swapWard = bot:GetItemSlotType(swapWardSlot) == ITEM_SLOT_TYPE_BACKPACK
		-- -- -- if bot:GetItemSlotType(minSlot) == ITEM_SLOT_TYPE_MAIN then
			
			
				-- -- swapTime = DotaTime();
				-- -- bot:ActionImmediate_Chat("Swap Ward",true);
				-- -- bot:ActionImmediate_SwapItems( itemSlot, slotToWard );
				-- -- return
			-- -- end
			-- -- -- local active = bot:GetItemInSlot(swapWardX);
		-- -- -- print(tostring(active:IsFullyCastable()));
	-- -- end
	-- -- end
	-- -- end
	
	
	
	-- local slotToSwap1 = nil
	-- local slotToSwap2 = nil
	
	-- if  itemUseUtils.IsInventoryFull2(bot) then
	
	-- for i=1,#uItem['Wards'] do
				-- local item1 = uItem['Wards'][i];
				-- local itemSlot1 = bot:FindItemSlot(item1);
			-- if itemSlot1 >= 0 and itemSlot1 <= 8 then
					-- if item1 == "item_ward_observer"  
					-- then
					-- local slotToDrop1 = (IsXItemAvailable(bot,"item_ward_observer") or IsXItemAvailable(bot,"item_ward_sentry") or IsXItemAvailable(bot,"item_ward_dispenser") )
			-- if bot:GetItemSlotType(itemSlot1) == ITEM_SLOT_TYPE_BACKPACK or  bot:GetItemSlotType(itemSlot1) == ITEM_SLOT_TYPE_MAIN then		
					-- slotToSwap1 = itemSlot1;
					
	-- for i=1,#uItem['all_items'] do
				-- local item2 = uItem['all_items'][i];
				-- local itemSlot2 = bot:FindItemSlot(item2);
			-- if itemSlot2 >= 0 and itemSlot2 <= 8 then
					-- if item2 == "item_boots_of_elves" or
	-- item2 == "item_belt_of_strength" or
	-- item2 == "item_blade_of_alacrity" or
	-- item2 == "item_blades_of_attack" or
	-- item2 == "item_blight_stone" or
	-- item2 == "item_blink" or
	-- item2 == "item_boots" or
	-- item2 == "item_bottle"or
	-- item2 == "item_broadsword" or
	-- item2 == "item_chainmail" or
	-- -- "item_cheese" 
	-- item2 == "item_circlet" or
	-- item2 == "item_clarity" or
	-- item2 == "item_claymore" or
	-- item2 == "item_cloak" or
	-- item2 == "item_demon_edge" or
	-- item2 == "item_dust" or
	-- item2 == "item_eagle" or
	-- item2 == "item_enchanted_mango" or
	-- item2 == "item_energy_booster" or
	-- item2 == "item_faerie_fire" or
	-- item2 == "item_flying_courier" or
	-- item2 == "item_gauntlets" or
	-- item2 == "item_gem" or
	-- item2 == "item_ghost" or
	-- item2 == "item_gloves" or
	-- item2 == "item_flask" or
	-- item2 == "item_helm_of_iron_will" or
	-- item2 == "item_hyperstone" or
	-- item2 == "item_infused_raindrop"or
	-- item2 == "item_branches" or
	-- item2 == "item_javelin" or
	-- item2 == "item_magic_stick" or
	-- item2 == "item_mantle" or
	-- item2 == "item_mithril_hammer" or
	-- item2 == "item_lifesteal" or
	-- item2 == "item_mystic_staff" or
	
	-- -- "item_ward_observer";
	-- -- "item_ward_sentry";
	-- -- "item_ward_dispenser";
	
	
	
	-- item2 == "item_ogre_axe" or
	-- item2 == "item_orb_of_venom" or
	-- item2 == "item_platemail" or
	-- item2 == "item_point_booster" or
	-- item2 == "item_quarterstaff" or
	-- item2 == "item_quelling_blade" or
	-- item2 == "item_reaver" or
	-- item2 == "item_refresher_shard" or
	-- item2 == "item_ring_of_health" or
	-- item2 == "item_ring_of_protection" or
	-- item2 == "item_ring_of_regen" or
	-- item2 == "item_robe" or
	-- item2 == "item_relic" or
	-- item2 == "item_sobi_mask" or	
	-- item2 == "item_shadow_amulet" or
	-- item2 == "item_slippers" or
	-- item2 == "item_smoke_of_deceit" or
	-- item2 == "item_staff_of_wizardry" or 
	-- -- "item_stout_shield" 
	-- item2 == "item_talisman_of_evasion" or 
	-- item2 == "item_tango" or 
	-- item2 == "item_tango_single" or 
	-- item2 == "item_tome_of_knowledge" or 
	-- -- "item_tpscroll";
	-- item2 == "item_ultimate_orb" or 
	-- item2 == "item_vitality_booster" or 
	-- item2 == "item_void_stone" or 
	-- item2 == "item_wind_lace" or 
	-- item2 == "item_ring_of_tarrasque" or 
	-- item2 == "item_crown" or
	
	-- ----------- Combo items ---
	
	-- item2 == "item_abyssal_blade" or
	-- item2 == "item_aether_lens" or
	-- item2 == "item_arcane_boots" or
	-- item2 == "item_armlet" or
	-- item2 == "item_assault" or
	-- item2 == "item_bfury" or
	-- item2 == "item_black_king_bar" or
	-- item2 == "item_blade_mail" or
	-- item2 == "item_bloodstone" or
	-- item2 == "item_bloodthorn" or
	-- item2 == "item_travel_boots" or
	-- item2 == "item_travel_boots_2" or
	-- item2 == "item_bracer" or
	-- item2 == "item_buckler" or
	-- item2 == "item_butterfly" or 
	-- item2 == "item_crimson_guard" or
	-- item2 == "item_lesser_crit" or
	-- item2 == "item_greater_crit" or
	-- item2 == "item_dagon" or
	-- item2 == "item_dagon_2" or
	-- item2 == "item_dagon_3" or
	-- item2 == "item_dagon_4" or
	-- item2 == "item_dagon_5" or
	-- item2 == "item_desolator" or
	-- item2 == "item_diffusal_blade" or
-- -- 	"item_diffusal_blade_2";
	-- item2 == "item_dragon_lance" or
	-- item2 == "item_ancient_janggo" or
	-- item2 == "item_echo_sabre" or
	-- item2 == "item_ethereal_blade" or
	-- item2 == "item_cyclone" or
	-- item2 == "item_skadi" or
	-- item2 == "item_force_staff" or
	-- item2 == "item_glimmer_cape" or
	-- item2 == "item_guardian_greaves" or
	-- item2 == "item_hand_of_midas" or
	-- item2 == "item_headdress" or
	-- item2 == "item_heart" or
	-- item2 == "item_heavens_halberd" or
	-- item2 == "item_helm_of_the_dominator" or
	-- item2 == "item_hood_of_defiance" or 
	-- item2 == "item_hurricane_pike" or
-- -- 	"item_iron_talon";
	-- item2 == "item_sphere" or
	-- item2 == "item_lotus_orb" or
	-- item2 == "item_maelstrom" or
	-- item2 == "item_magic_wand" or
	-- item2 == "item_manta" or
	-- item2 == "item_mask_of_madness" or
	-- item2 == "item_medallion_of_courage" or
	-- item2 == "item_mekansm" or
	-- item2 == "item_mjollnir" or
	-- item2 == "item_monkey_king_bar" or
	-- item2 == "item_moon_shard" or
	-- item2 == "item_necronomicon" or
	-- item2 == "item_necronomicon_2" or
	-- item2 == "item_necronomicon_3" or    
	-- item2 == "item_null_talisman" or
	-- item2 == "item_oblivion_staff" or
	-- item2 == "item_octarine_core" or 
	-- item2 == "item_orchid" or 
	-- item2 == "item_pers" or
	-- item2 == "item_phase_boots" or
	-- item2 == "item_pipe" or
-- -- 	"item_poor_mans_shield";
	-- -- "item_power_treads_agi";
	-- -- "item_power_treads_int";
	-- -- "item_power_treads_str";
	-- item2 == "item_power_treads" or
	-- item2 == "item_radiance" or
	-- item2 == "item_rapier" or
	-- item2 == "item_refresher" or				
-- -- "item_ring_of_aquila";
	-- item2 == "item_ring_of_basilius" or
	-- item2 == "item_rod_of_atos" or
	-- item2 == "item_sange" or
	-- item2 == "item_sange_and_yasha" or
	-- item2 == "item_satanic" or
	-- item2 == "item_sheepstick" or
	-- item2 == "item_invis_sword" or
	-- item2 == "item_shivas_guard" or
	-- item2 == "item_silver_edge" or
	-- item2 == "item_basher" or
	-- item2 == "item_solar_crest" or
	-- item2 == "item_soul_booster" or
	-- item2 == "item_soul_ring" or
	-- item2 == "item_tranquil_boots" or
	-- item2 == "item_urn_of_shadows" or
	-- item2 == "item_vanguard" or
	-- item2 == "item_veil_of_discord" or
	-- item2 == "item_vladmir" or
	-- item2 == "item_wraith_band" or
	-- item2 == "item_yasha" or

-- ---------- NEW ITEM BELOW ----------------
	-- item2 == "item_meteor_hammer" or
-- --aeon disk
	-- item2 == "item_aeon_disk" or
	-- item2 == "item_spirit_vessel" or
	-- item2 == "item_nullifier" or
-- --kaya
	-- item2 == "item_kaya" or
-- --kaya and sange
	-- item2 == "item_kaya_and_sange" or
-- --yasha and kaya
	-- item2 == "item_yasha_and_kaya" or
-- --item_holy_locket
	-- item2 == "item_holy_locket"
	
	-- then
	-- if bot:GetItemSlotType(itemSlot2) == ITEM_SLOT_TYPE_MAIN or  bot:GetItemSlotType(itemSlot2) == ITEM_SLOT_TYPE_BACKPACK then
		-- slotToSwap2 = itemSlot2;
		-- local slotToDrop2 =  IsXItemAvailable(bot,item2)
	
		-- swapTime = DotaTime ()
		-- bot:ActionImmediate_Chat("Swap Ward",true);
		-- bot:ActionImmediate_SwapItems( slotToSwap1,slotToSwap2 );
		-- -- bot:Action_DropItem(slotToDrop1, bot:GetLocation() + RandomVector(100) )
		-- -- bot:Action_DropItem(slotToDrop2, bot:GetLocation() + RandomVector(100) )
	
	-- end
	-- end
	-- end
	-- end
	-- end
	-- end
	-- end
	-- end
	-- end
	
	
	
-- end

-- function IsItemAvailable(item_name)
    -- for i = 0, 5 do
        -- local item = bot:GetItemInSlot(i);
		-- if (item~=nil) then
			-- if(item:GetName() == item_name) then
				-- return item;
			-- end
		-- end
    -- end
    -- return nil;
-- end

-- function IsXItemAvailable(bot, item_name)
    -- for i = 0, 8 do
        -- local item = bot:GetItemInSlot(i)
        -- if (item ~= nil) then
            -- if (item:GetName() == item_name) then
                -- return item
            -- end
        -- end
    -- end
    -- return nil
-- end
