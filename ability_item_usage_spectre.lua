if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
local mutil = require("bots/MyUtility")
local nutils = require("bots/NewUtility")


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



local castOODesire = 0;
local castFBDesire = 0;
local castVDDesire = 0;
local castSTDesire = 0;
local castDPDesire = 0;

local abilityOO = nil;
local abilityFB = nil;
local abilityVD = nil;
local abilityST = nil;
local abilityDP = nil;

local hauntTime = 0;
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
	

	if abilityOO == nil then abilityOO = npcBot:GetAbilityByName( "spectre_reality" ) end
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "spectre_spectral_dagger" ) end
	if abilityVD == nil then abilityVD = npcBot:GetAbilityByName( "spectre_haunt" ) end
	if abilityST == nil then abilityST = npcBot:GetAbilityByName( "spectre_haunt_single" ) end
	if abilityDP == nil then abilityDP = npcBot:GetAbilityByName( "spectre_dispersion" ) end
	hauntDuration = abilityVD:GetSpecialValueInt("duration");
	
	-- Consider using each ability
	castOODesire, castOOLocation = ConsiderOverwhelmingOdds();
	castFBDesire, castFBTarget, stuck = ConsiderFireblast();
	castVDDesire = ConsiderVendetta();
	castSTDesire, castSTTarget = ConsiderShadowStep();
	castDPDesire, castDPTarget = ConsiderDispersion();

	if ( castOODesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityOO, castOOLocation );
		return;
	end
	
	if ( castSTDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityST, castSTTarget );
		return;
	end
	
	if ( castFBDesire > 0 ) 
	then
		if stuck ~= nil then
			npcBot:Action_UseAbilityOnLocation( abilityFB, castFBTarget );
			return;
		else
			npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
			return;
		end
	end
	
	if ( castVDDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityVD );
		hauntTime = DotaTime();
		return;
	end

	if ( castDPDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityDP, castDPTarget );
		return;
	end
end

function ConsiderOverwhelmingOdds()


	-- Make sure it's castable
	if ( not abilityOO:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	if DotaTime() > hauntTime + hauntDuration then
		return BOT_ACTION_DESIRE_NONE
	end	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and not mutil.IsInRange(npcTarget, npcBot, 550)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation( );
		end
	end
	
	if mutil.IsProjectileIncoming(npcBot, 300)
		then	
    local globalAllies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
    for _,ally in pairs(globalAllies) do
        if mutil.CanCastOnNonMagicImmune(ally) then
            if ally ~= nil 
			and ally:CanBeSeen()
			and ally:IsIllusion()
			and not ally:IsNull()
			and ally:GetUnitName() ~= bot:GetUnitName()
			and not mutil.IsInRange(ally, npcBot, 550)
			then
               local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
                return BOT_ACTION_DESIRE_MODERATE, ally:GetLocation( );
            end
        end
    end
	end
	
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderFireblast()

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();
	local nRadius = abilityFB:GetSpecialValueInt("dagger_radius");
	local nDamage = abilityFB:GetSpecialValueInt("damage")
	local nManaCost = abilityFB:GetManaCost();
	
	if nCastRange > 1600 then nCastRange = 1600 end
	
	if mutil.IsStuck(npcBot)
	then
		local loc = mutil.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( loc, nCastRange/2 ), true;
	end
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	if mutil.IsRetreating(bot)
	then
		if bot.data.enemies ~= nil and #bot.data.enemies > 0 then
			for i=1,#bot.data.enemies do
				
				if IsValidObject(bot.data.enemies[i])
					and GetUnitToUnitDistance(bot, bot.data.enemies[i]) < nCastRange
					then
				if bot.data.enemies[i]:HasModifier("modifier_spectre_spectral_dagger_path_activity_modifier") == false
				and bot:WasRecentlyDamagedByHero( bot.data.enemies[i], 2.0 )
				then 
					local cpos = utils.GetTowardsFountainLocation(bot.data.enemies[i]:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					return BOT_ACTION_DESIRE_HIGH, bot.data.enemies[i];
				end
			end
		end
	end
	if mutil.ShouldEscape2(bot) then
		local cpos = utils.GetTowardsFountainLocation(bot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
		return BOT_ACTION_DESIRE_LOW, bot:GetXUnitsInFront(nCastRange), true;
	end	
	end
	
	
	if nutils.IsInTeamFight(bot)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc, true;
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
	
	
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING) 
	-- and currManaP > 0.45
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
			if GetUnitToLocationDistance(bot,u:GetLocation()) <= 700 and GetUnitToLocationDistance(npcEnemy,u:GetLocation()) <= 700
				then
			if #allies >= 0 then
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
	end
	end
	end
	
	
	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING)
	and mutil.AllowedToSpam(npcBot, nManaCost)
	then
	   local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1400, true, BOT_MODE_NONE );
		local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy)
			and npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.80 ) and #tableNearbyAlliedHeroes >=1
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
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderVendetta()

	if ( not abilityVD:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and not mutil.IsInRange(npcTarget, npcBot, 600) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
end










function ConsiderShadowStep()

	-- Make sure it's castable
	if  not abilityST:IsFullyCastable()
		or abilityST:IsHidden() 
		or not npcBot:HasScepter() or not npcBot:HasModifier("modifier_item_ultimate_scepter_consumed" )
		then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


   

    --------------------------------------
    -- Global Usage
    --------------------------------------
    local globalEnemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
    for _,enemy in pairs(globalEnemies) do
        if enemy:GetHealth()/enemy:GetMaxHealth() < 0.25  and mutil.CanCastOnNonMagicImmune(enemy) then
            if enemy ~= nil 
			and enemy:CanBeSeen()
			and enemy:IsHero()
			and not enemy:IsNull()	then
               
                return BOT_ACTION_DESIRE_MODERATE, enemy;
            end
        end
    end

    --------- CHASING --------------------------------
	if mutil.IsGoingOnSomeone(npcBot) 
	 then
     local npcTarget = npcBot:GetTarget()
		if mutil.IsValidTarget(npcTarget)  and mutil.CanCastOnNonMagicImmune(npcTarget) and not mutil.IsSuspiciousIllusion(npcTarget)
		 then
			if npcTarget:CanBeSeen() and not npcTarget:IsNull() and npcTarget:GetHealth()/npcTarget:GetMaxHealth() < 0.5
			  then 
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
              return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
    end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end




function ConsiderDispersion()
	
	if ( not abilityDP:IsFullyCastable() or bot:HasModifier("modifier_item_aghanims_shard") == false  ) 
	then
		return BOT_ACTION_DESIRE_NONE,0;
	end
	
	local nCastRange = mutil.GetProperCastRange(false, bot, abilityDP:GetSpecialValueInt( "max_radius" ));	
	local nCastPoint = abilityDP:GetCastPoint();
	local manaCost   = abilityDP:GetManaCost();
	local nRadius    = abilityDP:GetSpecialValueInt( "max_radius" );
	
	
	
	
	
	if mutil.IsRetreating(bot)
	then
		if bot.data.enemies ~= nil and #bot.data.enemies > 0 then
			for i=1,#bot.data.enemies do
				
				if IsValidObject(bot.data.enemies[i])
					and GetUnitToUnitDistance(bot, bot.data.enemies[i]) < nCastRange
					then
				if bot:WasRecentlyDamagedByHero( bot.data.enemies[i], 2.0 ) and mutil.CanCastOnNonMagicImmune(bot.data.enemies[i])
				then 
				
					return BOT_ACTION_DESIRE_HIGH, bot.data.enemies[i];
				end
			end
		end
	end
	end
	
	
	if nutils.IsInTeamFight(bot) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcEnemy:IsHero() and role.IsCarry(npcEnemy:GetUnitName()) and mutil.CanCastOnNonMagicImmune(npcEnemy) )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		
		local target = mutil.GetMostHpUnit(tableNearbyEnemyHeroes);
		if target ~= nil and bot:WasRecentlyDamagedByHero( target, 2.0 )  then
			return BOT_ACTION_DESIRE_LOW, target;
		end
	end
	
	
	if mutil.IsGoingOnSomeone(bot) 
	then
		local npcTarget = bot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget)  
		and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')  )
			and mutil.IsInRange(npcTarget, bot, nRadius) 
			then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH,npcTarget;
		end
	end
	
	


	return BOT_ACTION_DESIRE_NONE,0;
end














function IsValidObject(object)
	return object ~= nil and object:IsNull() == false and object:CanBeSeen() == true;
end

function GetUnitCountWithinRadius(tUnits, radius)
	local count = 0;
	if tUnits ~= nil and #tUnits > 0 then
		for i=1,#tUnits do
			if IsValidObject(tUnits[i]) and GetUnitToUnitDistance(bot, tUnits[i]) <= radius then
				count = count + 1;
			end
		end	
	end
	return count;
end


