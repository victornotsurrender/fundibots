if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
local mutil = require("bots/MyUtility")
local mutils = require("bots/MyUtility")
local items = require("bots/ItemUtility" )

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

local castWADesire = 0;
local castMFDesire = 0;
local castWBDesire = 0;
local castASSDesire = 0;
local castPRDesire = 0;

local abilityWA = nil;
local abilityMF = nil;
local abilityWB = nil;
local abilityASS = nil;
local abilityPR = nil;


local ItemHM = nil;

-- local npcBot = nil;
local npcBot = GetBot();
local bot = GetBot();
function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	if abilityWA == nil then abilityWA = npcBot:GetAbilityByName( "arc_warden_spark_wraith" ) end
	if abilityMF == nil then abilityMF = npcBot:GetAbilityByName( "arc_warden_magnetic_field" ) end
	if abilityWB == nil then abilityWB = npcBot:GetAbilityByName( "arc_warden_tempest_double" ) end
	if abilityASS == nil then abilityASS = npcBot:GetAbilityByName( "arc_warden_scepter" ) end
	if abilityPR == nil then abilityPR = npcBot:GetAbilityByName( "arc_warden_flux" ) end
	
	
	ItemHM = mutil.GetComboItem(npcBot, "item_hand_of_midas")

	-- Consider using each ability
	castPRDesire, castPRTarget = ConsiderFlux();
	castWADesire, castWALocation = ConsiderSparkWraith();
	castMFDesire, castMFLocation = ConsiderMagneticField();
	-- castASSDesire, castASSLoc = ConsiderAghScepterSkill();
	castWBDesire = ConsiderTempestDouble();

	if ( castPRDesire > castWADesire ) 
	then
		--print("Use WA");
		npcBot:Action_UseAbilityOnEntity( abilityPR, castPRTarget );
		return;
	end

	if ( castWADesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityWA, castWALocation );
		return;
	end
	
	if ( castMFDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityMF, castMFLocation );
		return;
	end
	
	if ( castASSDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityASS );
		return;
	end
	
	if ( castWBDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityWB );
		return;
	end

end


function ConsiderSparkWraith()

	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityWA:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
--
	-- If we want to cast Laguna Blade at all, bail
	--[[if ( castPRDesire > 0 ) 
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end]]--

	-- Get some of its values
	local nRadius = abilityWA:GetSpecialValueInt( "radius" );
	local nCastRange = mutils.GetProperCastRange(false, bot, abilityWA:GetCastRange());
	local nDamage = abilityWA:GetSpecialValueInt("spark_damage");
	local nDelay = abilityWA:GetSpecialValueInt("activation_delay");
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget)
	then
		if ( mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nDelay );
		end
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				
				return BOT_ACTION_DESIRE_MODERATE, npcBot:GetExtrapolatedLocation( nDelay )
			end
		end
	end
	
	
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING)  and currManaP > 0.45
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
									
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation( nDelay )
				end
			end
		end
	end
	end
	end
	-- end
	
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
	

	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), 1000, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end

	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nDelay );
		end
	end
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange+200, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderMagneticField()

	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityMF:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
--
	-- If we want to cast Laguna Blade at all, bail
	--[[if ( castPRDesire > 0 ) 
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end]]--

	-- Get some of its values
	local nRadius = abilityMF:GetSpecialValueInt( "radius" );
	local nCastRange = abilityMF:GetCastRange();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and npcBot:HasModifier("modifier_arc_warden_magnetic_field_attack_speed") == false
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

	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  and npcBot:HasModifier("modifier_arc_warden_magnetic_field_attack_speed") == false  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcBot:GetLocation();
		end
	end
	
	-- If we're farming and can kill 3+ creeps with LSA
	-- if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		-- local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 600, nRadius, 0, 0 );
		-- if ( locationAoE.count >= 3 and not npcBot:HasModifier("modifier_arc_warden_magnetic_field_attack_speed") ) then
			-- return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation();
		-- end
	-- end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 600, nRadius, 0, 0 );
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and locationAoE.count >= 3 and not npcTarget:IsBuilding() and not npcBot:HasModifier("modifier_arc_warden_magnetic_field_attack_speed") then
			return BOT_ACTION_DESIRE_LOW,npcBot:GetLocation();
		end
	end	

	if mutil.IsInTeamFight(npcBot, 1200) and npcBot:HasModifier("modifier_arc_warden_magnetic_field_attack_speed") == false
	then
		local locationAoE = npcBot:FindAoELocation( false, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) ) and npcBot:HasModifier("modifier_arc_warden_magnetic_field_attack_speed") == false
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( 800, true );
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 800, true );
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 ) or ( tableNearbyEnemyTowers ~= nil and #tableNearbyEnemyTowers >= 1 ) 
		then
			return BOT_ACTION_DESIRE_LOW, npcBot:GetLocation();
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) 
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and  mutil.IsInRange(npcTarget, npcBot, nCastRange)  
		then
			local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_ATTACK );
			for _,npcAlly in pairs( tableNearbyAttackingAlliedHeroes )
			do
				if ( mutil.IsInRange(npcAlly, npcBot, nCastRange) and not npcAlly:HasModifier("modifier_arc_warden_magnetic_field_attack_speed")  ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcAlly:GetLocation();
				end
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderFlux()

	-- Make sure it's castable
	if ( not abilityPR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityPR:GetCastRange();
	local nDot = abilityPR:GetSpecialValueInt( "damage_per_second" );
	local nDuration = abilityPR:GetSpecialValueInt( "duration" );
	local nDamage = nDot * nDuration;
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) 
		and mutil.CanCastOnNonMagicImmune(npcTarget) 
		and mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) 
		and mutil.IsInRange(npcTarget, npcBot, nCastRange) 
		and npcTarget:HasModifier('modifier_arc_warden_flux') == false
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end
	
	-- If we're in a teamfight, use it on the scariest enemy
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE  );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and npcEnemy:HasModifier('modifier_arc_warden_flux') == false ) 
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
	end

	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) 
			and mutil.CanCastOnMagicImmune(npcTarget) 
			and mutil.IsInRange(npcTarget, npcBot, nCastRange)
			and npcTarget:HasModifier('modifier_arc_warden_flux') == false	)
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if mutil.IsValidTarget(npcTarget) 
			and mutil.CanCastOnNonMagicImmune(npcTarget)
			and mutil.IsInRange(npcTarget, npcBot, nCastRange)
			and npcTarget:HasModifier('modifier_arc_warden_flux') == false
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end



function ConsiderTempestDouble()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityWB:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end

	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 800)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if  mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( 800, true );
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 800, true );
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 ) or ( tableNearbyEnemyTowers ~= nil and #tableNearbyEnemyTowers >= 1 ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and items.HasItem(bot, "item_hand_of_midas") == true and ItemHM ~= nil and ItemHM:IsFullyCastable()
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	

	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if mutil.IsInRange(npcTarget, npcBot, 1000)
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 1000) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderAghScepterSkill()

	if ( abilityASS:IsFullyCastable() == false or abilityASS:IsHidden() == true  ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	return BOT_ACTION_DESIRE_HIGH;
	
end
