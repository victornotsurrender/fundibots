if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile("bots/ability_item_usage_generic" )
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

local castHSDesire = 0;
local castDEDesire = 0;
local castRTDesire = 0;
local castSTDesire = 0;

local abilityHS = nil;
local abilityDE = nil;
local abilityRT = nil;
local abilityST = nil;

-- local npcBot = nil;
local npcBot = GetBot();
local bot = GetBot();


function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityHS == nil then abilityHS = npcBot:GetAbilityByName( "centaur_hoof_stomp" ) end
	if abilityDE == nil then abilityDE = npcBot:GetAbilityByName( "centaur_double_edge" ) end
	if abilityRT == nil then abilityRT = npcBot:GetAbilityByName( "centaur_return" ) end
	if abilityST == nil then abilityST = npcBot:GetAbilityByName( "centaur_stampede" ) end

	-- Consider using each ability
	castHSDesire = ConsiderHoofStomp();
	castDEDesire, castDETarget = ConsiderDoubleEdge();
	castRTDesire = ConsiderReturn();
	castSTDesire = ConsiderStampede();
	
	-- ability_item_usage_generic.SwapItemsTest()
	

	if ( castSTDesire > castHSDesire and castSTDesire > castDEDesire ) 
	then
		npcBot:Action_UseAbility( abilityST );
		return;
	end

	if ( castHSDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityHS );
		return;
	end

	if ( castRTDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityRT );
		return;
	end
	
	if ( castDEDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityDE, castDETarget );
		return;
	end

end




function ConsiderHoofStomp()

	-- Make sure it's castable
	if ( not abilityHS:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilityHS:GetSpecialValueInt( "radius" );
	local nCastRange = 0;
	local nDamage = abilityHS:GetSpecialValueInt( "stomp_damage" );
	local nManaCost = abilityHS:GetManaCost();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nRadius , 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE;
	end

	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and 
	   mutil.IsInRange(npcTarget, npcBot, nRadius - 100) 
	then   
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	
	
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 ) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	-- if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	-- then
		-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		-- local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nRadius-100 );
			-- if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 2 then
				-- for _,neutral in pairs(tableNearbyNeutrals)
				-- do
				-- if neutral:CanBeSeen() and neutral:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0
					-- then 
					-- return BOT_ACTION_DESIRE_MODERATE;
				-- end
			-- end
		-- end
	-- end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM or npcBot:GetActiveMode() == BOT_MODE_LANING and currManaP > 0.45
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nRadius );
		local enemyCreeps = bot:GetNearbyLaneCreeps(nRadius , true);
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 2 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=2
					then 
					return BOT_ACTION_DESIRE_MODERATE;
				else 
			if enemyCreeps ~= nil and #enemyCreeps >= 2 then	
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
	end
	end
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING or npcBot:GetActiveMode() == BOT_MODE_FARM )  and currManaP > 0.45 and abilityHS:GetLevel() > 1 
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nRadius, true);
		
		if ( lanecreeps~= nil and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	
	-- if npcBot:GetActiveMode() == BOT_MODE_LANING  or  mutil.IsPushing(npcBot) or  mutil.IsDefending(npcBot) and currManaP > 0.60
	-- then
	   
	
		-- local laneCreeps = npcBot:GetNearbyLaneCreeps(nRadius - 100, true);
		-- for _,creep in pairs(laneCreeps)
		-- do
			-- if creep:GetHealth() <= nDamage then
				-- return BOT_ACTION_DESIRE_HIGH;
		    -- end
        -- end
	-- end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				local cpos = utils.GetTowardsFountainLocation(bot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and 
	       mutil.IsInRange(npcTarget, npcBot, nRadius - 100) and not mutil.IsDisabled(true, npcTarget)
		   and not mutil.IsSuspiciousIllusion(npcTarget) and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end


function ConsiderDoubleEdge()
	
	-- Make sure it's castable
	if ( not abilityDE:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityDE:GetCastRange();
	local nDamage = abilityDE:GetSpecialValueInt( "edge_damage" );
	local nRadius = abilityDE:GetSpecialValueInt( "radius" );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local currHealthP = npcBot:GetHealth() / npcBot:GetMaxHealth();
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and 
	   mutil.IsInRange(npcTarget, npcBot, nCastRange + 100) 
	then
		return BOT_ACTION_DESIRE_MODERATE, npcTarget;
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currHealthP > 0.50 and currManaP > 0.45
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
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and 
	       mutil.IsInRange(npcTarget, npcBot, nCastRange + 100) 
		   and not mutil.IsSuspiciousIllusion(npcTarget)
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderReturn()

	-- Make sure it's castable
	if ( not abilityRT:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = 300;
	local maxStacks = abilityRT:GetSpecialValueInt('max_stacks');

	local stack = 0;
	local modIdx = npcBot:GetModifierByName("modifier_centaur_return_counter");
	if modIdx > -1 then
		stack = npcBot:GetModifierStackCount(modIdx);
	end

	if stack <= maxStacks / 2 then
		return BOT_ACTION_DESIRE_NONE;
	end	

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and 
	       mutil.IsInRange(npcTarget, npcBot, nRadius) 
		then   
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderStampede()

	-- Make sure it's castable
	if ( not abilityST:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 600) 
		and not mutil.IsSuspiciousIllusion(npcTarget)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
