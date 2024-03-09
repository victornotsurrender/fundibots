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

local npcBot = GetBot();
local bot = GetBot();

local abilityQ = nil;
local abilityE = nil;
local abilityR = nil;

local castQDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

function AbilityUsageThink()
	
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- ability_item_usage_generic.UnImplementedItemUsage();
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	
	if abilityQ == nil then abilityQ = npcBot:GetAbilityByName( "bounty_hunter_shuriken_toss" ) end
	if abilityE == nil then abilityE = npcBot:GetAbilityByName( "bounty_hunter_wind_walk" ) end
	if abilityR == nil then abilityR = npcBot:GetAbilityByName( "bounty_hunter_track" ) end

	castQDesire, castQTarget = ConsiderQ();
	castEDesire              = ConsiderE();
	castRDesire, castRTarget = ConsiderR();
	
	

	if ( castRDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityR, castRTarget );
		return;
	end

	if ( castQDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityQ, castQTarget );
		return;
	end
	
	if ( castEDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityE );
		return;
	end
	
end

function ConsiderQ()

	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() or npcBot:HasModifier('modifier_bounty_hunter_wind_walk') ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius    = abilityQ:GetSpecialValueInt( "bounce_aoe" );
	-- local nCastRange = abilityQ:GetCastRange( );
	local nCastRange = 1600;
	local nCastPoint = abilityQ:GetCastPoint( );
	local nManaCost  = abilityQ:GetManaCost( );
	local nDamage    = abilityQ:GetSpecialValueInt( 'bonus_damage' );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
	local tableNearbyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange , true );
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if npcEnemy:IsChanneling() then
			local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
		if mutil.CanCastOnNonMagicImmune(npcEnemy) and mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) 
		then
			if mutil.IsInRange(npcEnemy, npcBot, nCastRange) then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			elseif tableNearbyCreeps[1] ~= nil and mutil.StillHasModifier(npcEnemy, 'modifier_bounty_hunter_track') 
				and mutil.IsInRange(npcEnemy, tableNearbyCreeps[1], nRadius - 150)
			then	
				return BOT_ACTION_DESIRE_HIGH, tableNearbyCreeps[1] ;
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
	
	
	-- if npcBot:GetActiveMode() == BOT_MODE_FARM 
	-- then
		-- local npcTarget = npcBot:GetAttackTarget();
		-- if npcTarget ~= nil and not npcTarget:IsBuilding() then
			-- return BOT_ACTION_DESIRE_LOW, npcTarget;
		-- end
	-- end	
	
	
	-- if (npcBot:GetActiveMode() == BOT_MODE_LANING  or mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot)) and currManaP > 0.80
	-- then	
		-- local laneCreeps = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		-- for _,creep in pairs(laneCreeps)
		-- do
			-- if creep:GetHealth() <= nDamage then
				-- return BOT_ACTION_DESIRE_MODERATE, creep;
		    -- end
        -- end
	-- end
	
	
	

	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local trackedEnemy = 0;
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.StillHasModifier(npcEnemy, 'modifier_bounty_hunter_track')  ) 
			then
				trackedEnemy = trackedEnemy + 1;
			end
		end
		if trackedEnemy >= 2 then
			if tableNearbyCreeps[1] ~= nil then
				return BOT_ACTION_DESIRE_HIGH, tableNearbyCreeps[1];
			elseif tableNearbyEnemyHeroes[1] ~= nil and mutil.IsInRange(tableNearbyEnemyHeroes[1], npcBot, nCastRange ) 
			then
				return BOT_ACTION_DESIRE_HIGH, tableNearbyEnemyHeroes[1];
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) 
		then
			if mutil.IsInRange(npcTarget, npcBot, nCastRange ) then
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			elseif npcTarget:HasModifier('modifier_bounty_hunter_track') 
			then
				for i=1, #tableNearbyCreeps do
					if tableNearbyCreeps[i] ~= nil and mutil.IsInRange(npcTarget, tableNearbyCreeps[i], nRadius - 150)
					then
						return BOT_ACTION_DESIRE_HIGH, tableNearbyCreeps[i] ;
					end
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderE()

	-- Make sure it's castable
	if ( not abilityE:IsFullyCastable() or npcBot:HasModifier('modifier_bounty_hunter_wind_walk') ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nCastPoint = abilityQ:GetCastPoint( );
	local nManaCost  = abilityQ:GetManaCost( );

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 ) or npcBot:WasRecentlyDamagedByTower(2.5) 
		then
			local cpos = utils.GetTowardsFountainLocation(bot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	
	--Roshan
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if (  mutil.IsRoshan(npcTarget) and  mutil.CanCastOnMagicImmune(npcTarget) and  mutil.IsInRange(npcTarget, npcBot, 350)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and not mutil.IsInRange(npcTarget, npcBot, 1000) and mutil.IsInRange(npcTarget, npcBot, 2500)
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderR()

	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	-- local nCastRange = abilityR:GetCastRange( );
	local nCastRange = 1600;
	local nCastPoint = abilityR:GetCastPoint( );
	local nManaCost  = abilityR:GetManaCost( );
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange , true, BOT_MODE_NONE );
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if 	mutil.IsValidTarget(npcEnemy)
			and mutil.CanCastOnNonMagicImmune(npcEnemy) 
			and not mutil.StillHasModifier(npcEnemy, 'modifier_bounty_hunter_track') 
		then
			local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
