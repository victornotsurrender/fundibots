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

local castIVDesire = 0;
local castBSDesire = 0;
local castLBDesire = 0;

local abilityIV = nil;
local abilityBS = nil;
local abilityLB = nil;

-- local npcBot = nil;

local bot = GetBot();
local npcBot = GetBot();

function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();

	if abilityIV == nil then abilityIV = npcBot:GetAbilityByName( "huskar_inner_fire" ) end
	if abilityBS == nil then abilityBS = npcBot:GetAbilityByName( "huskar_burning_spear" ) end
	if abilityLB == nil then abilityLB = npcBot:GetAbilityByName( "huskar_life_break" ) end

	-- Consider using each ability
	castIVDesire, castIVTarget = ConsiderInnerVitality();
	castBSDesire, castBSTarget = ConsiderBurningSpear();
	castLBDesire, castLBTarget = ConsiderLifeBreak();
	
	
	
	if abilityBS:IsTrained() then
		ToggleBurningAttack();
	end
	

	if ( castLBDesire > castIVDesire and castLBDesire > castBSDesire ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityLB, castLBTarget );
		return;
	end

	if ( castIVDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityIV );
		return;
	end
	
	if ( castBSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityBS, castBSTarget );
		return;
	end

end




function ToggleBurningAttack()

	local currHealthP = npcBot:GetHealth() / npcBot:GetMaxHealth();
	local npcTarget = npcBot:GetTarget();
	
	if ( npcTarget ~= nil and (npcTarget:IsHero() or npcTarget:GetUnitName() == "npc_dota_roshan"  ) or   ( npcBot:GetActiveMode() == BOT_MODE_FARM  )  and currHealthP > 0.4)
	then
		if not abilityBS:GetAutoCastState( ) then
			abilityBS:ToggleAutoCast()
		end
	else 
		if  abilityBS:GetAutoCastState( ) then
			abilityBS:ToggleAutoCast()
		end
	end
	
end


function ConsiderInnerVitality()

	-- Make sure it's castable
	if ( not abilityIV:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityIV:GetCastRange();
	local nAttackRange = npcBot:GetAttackRange();
	local nRadius = abilityIV:GetSpecialValueInt("radius");
	local nManaCost = abilityIV:GetManaCost()
	local nDamage = abilityIV:GetSpecialValueInt( "damage" );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius-100, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 ) 
		then
			local cpos = utils.GetTowardsFountainLocation( npcBot:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1600) 
	then
		local enemies = npcBot:GetNearbyHeroes(nRadius-100, true, BOT_MODE_NONE);
		if ( #enemies >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius -100)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nRadius - 100 );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					then 
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
		end
	end
	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nRadius, true);
		
		if ( lanecreeps~= nil and #lanecreeps >= 8  ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_LANING and currManaP > 0.80 or  mutil.IsPushing(npcBot) or  mutil.IsDefending(npcBot)
	then
		local laneCreeps = npcBot:GetNearbyLaneCreeps(nRadius - 100, true);
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
		if mutil.IsValidTarget(npcTarget)  and mutil.CanCastOnNonMagicImmune(npcTarget)  and mutil.IsInRange(npcTarget, npcBot, nRadius-100)
		and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local eTarget = npcTarget:GetAttackTarget();
			if mutil.IsValidTarget(eTarget) or eTarget ~= nil  and eTarget == npcBot then
				local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nRadius - 100, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderBurningSpear()

	-- Make sure it's castable
	if ( not abilityBS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityBS:GetCastRange();
	local nDamage = abilityBS:GetSpecialValueInt("burn_damage") * 8 + npcBot:GetAttackDamage() ;
	local nRadius = 0;
	local nAttackRange = npcBot:GetAttackRange();
	
	
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
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsSuspiciousIllusion(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nCastRange + 200, true );
		for _,npcCreepTarget in pairs(tableNearbyEnemyCreeps) do
			if ( mutil.IsInRange(npcTarget, npcBot, nAttackRange) and npcBot:GetHealth()/npcBot:GetMaxHealth() > 0.4 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcCreepTarget;
			end
		end
	end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and npcBot:GetHealth()/npcBot:GetMaxHealth() > 0.4
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_MODERATE,npcTarget;
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_LANING  or mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) and npcBot:GetHealth()/npcBot:GetMaxHealth() > 0.4
	then
	   
	
		local laneCreeps = npcBot:GetNearbyLaneCreeps(nAttackRange, true);
		for _,creep in pairs(laneCreeps)
		do
			if creep:GetHealth() <= nDamage then
				return BOT_ACTION_DESIRE_MODERATE, creep;
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
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nAttackRange+200)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderLifeBreak()

	-- Make sure it's castable
	if ( not abilityLB:IsFullyCastable() or npcBot:IsRooted() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = mutil.GetProperCastRange(false, npcBot, abilityLB:GetCastRange());
	local currHealthP = npcBot:GetHealth() / npcBot:GetMaxHealth();
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 and npcBot:WasRecentlyDamagedByAnyHero(3.0) then
			local loc = mutil.GetEscapeLoc();
			local furthestUnit = mutil.GetClosestEnemyUnitToLocation(npcBot, nCastRange, loc);
			if furthestUnit ~= nil and ( GetUnitToUnitDistance(furthestUnit, npcBot) >= 0.5*nCastRange or GetUnitToUnitDistance(furthestUnit, npcBot) >= 350 )
			then
				local cpos = utils.GetTowardsFountainLocation( bot:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_LOW, furthestUnit;
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
	
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currHealthP > 0.65
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 
				and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					then 
					return BOT_ACTION_DESIRE_MODERATE,neutral;
				end
			end
		end
	end
	
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_VERYHIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
