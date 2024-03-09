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
local castLADesire = 0;
local castIGDesire = 0;
local castOGDesire = 0;

local abilityOG = nil;
local abilityIG = nil;
local abilityLA = nil;
local abilityFB = nil;

-- local npcBot = nil;
local bot = GetBot();
local npcBot = GetBot();


function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	
	if abilityOG == nil then abilityOG = npcBot:GetAbilityByName( "winter_wyvern_arctic_burn" ) end
	if abilityIG == nil then abilityIG = npcBot:GetAbilityByName( "winter_wyvern_splinter_blast" ) end
	if abilityLA == nil then abilityLA = npcBot:GetAbilityByName( "winter_wyvern_cold_embrace" ) end
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "winter_wyvern_winters_curse" ) end

	-- Consider using each ability
	castOGDesire, castOGTarget = ConsiderOvergrowth();
	castIGDesire, castIGTarget = ConsiderIgnite();
	castLADesire, castLATarget = ConsiderLivingArmor();
	castFBDesire, castFBTarget = ConsiderFireblast();
	
	-- ability_item_usage_generic.SwapItemsTest()
	
	if abilityOG:IsTrained() and npcBot:HasScepter() or npcBot:HasModifier("modifier_item_ultimate_scepter_consumed") then
		ToggleArticBurnAttack();
	end
	
	if ( castOGDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityOG );
		return;
	end
	
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end
	
	if ( castIGDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityIG, castIGTarget );
		return;
	end
	
	if ( castLADesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityLA, castLATarget );
		return;
	end
	
	
end


function ToggleArticBurnAttack()

	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local npcTarget = npcBot:GetAttackTarget();
	
	if ( npcTarget ~= nil and  npcTarget:IsHero() or npcTarget:GetUnitName() == "npc_dota_roshan"  )  and currManaP > .60
	then
		if not abilityOG:GetAutoCastState( ) then
			abilityOG:ToggleAutoCast()
		end
	else 
		if  abilityOG:GetAutoCastState( ) then
			abilityOG:ToggleAutoCast()
		end
	end
	
	
	if ( npcTarget ~= nil and npcTarget:IsCreep()   ) and currManaP > .60
	then
		if not abilityOG:GetAutoCastState( ) then
			abilityOG:ToggleAutoCast()
		end
	else 
		if  abilityOG:GetAutoCastState( ) then
			abilityOG:ToggleAutoCast()
		end
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and #tableNearbyEnemyHeroes >= 1 ) 
			then
				if not abilityOG:GetAutoCastState( ) then
					abilityOG:ToggleAutoCast()
				end
			else
				if  abilityOG:GetAutoCastState( ) and #tableNearbyEnemyHeroes == 0 then
					abilityOG:ToggleAutoCast()
				end
				
			end
		end
	end
	
	
	
	
	
end


function ConsiderOvergrowth()
	
	-- Make sure it's castable
	if ( not abilityOG:IsFullyCastable()  ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = 1000;
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nRange = abilityOG:GetSpecialValueInt('attack_range_bonus');
	local attackRange = npcBot:GetAttackRange();
	
	if npcBot:HasScepter() == false then
	
		if mutil.IsStuck(npcBot)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
		
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
		
		-- If we're going after someone
		if mutil.IsGoingOnSomeone(npcBot)
		then
			local npcTarget = npcBot:GetTarget();

			if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, attackRange+0.5*nRange)
			then
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( 800 );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 3 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and #tableNearbyEnemyHeroes == 0
					and neutral ~= nil 
					-- and not  bot:HasModifier("modifier_item_aghanims_shard") 
					then 
					-- return BOT_ACTION_DESIRE_MODERATE,'target',npcBot;
					-- -- else
					return BOT_ACTION_DESIRE_MODERATE ;
				end
			end
		end
	end
	
	---------------------
	else ------------
	-----------------------
		if mutil.IsStuck(npcBot) and abilityOG:GetToggleState() == false
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
		
		if mutil.IsGoingOnSomeone(npcBot)
		then
			local npcTarget = npcBot:GetTarget();

			if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, attackRange+0.5*nRange)
			then
				if npcTarget:HasModifier('modifier_winter_wyvern_arctic_burn_slow') == false and abilityOG:GetToggleState() == false 
				then 
					local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					return BOT_ACTION_DESIRE_HIGH;
				elseif npcTarget:HasModifier('modifier_winter_wyvern_arctic_burn_slow') == true and abilityOG:GetToggleState() == true 
				then
					local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					return BOT_ACTION_DESIRE_HIGH;
				elseif npcTarget:CanBeSeen() == false and abilityOG:GetToggleState() == true 	
				then
					local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					return BOT_ACTION_DESIRE_HIGH;
				end	
			end
		else
			if abilityOG:GetToggleState() == true 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
		
	end
	
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderIgnite()

	-- Make sure it's castable
	if ( not abilityIG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityIG:GetCastRange();
	local nDamage = abilityIG:GetAbilityDamage();
	local nRadius = abilityIG:GetSpecialValueInt( "split_radius" );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				local tableNearbyEnemyHeroes = npcEnemy:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
				local tableNearbyEnemyCreeps = npcEnemy:GetNearbyLaneCreeps( nRadius, false );
				for _, h in pairs(tableNearbyEnemyHeroes) 
				do
					if h:GetUnitName() ~= npcEnemy:GetUnitName() and mutil.CanCastOnNonMagicImmune(h) 
					then
						return BOT_ACTION_DESIRE_HIGH, h;
					end
				end
				for _, c in pairs(tableNearbyEnemyCreeps) 
				do
					if mutil.CanCastOnNonMagicImmune(c)
					then
						return BOT_ACTION_DESIRE_HIGH, c;
					end
				end
			end
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if (npcBot:GetActiveMode() == BOT_MODE_LANING or npcBot:GetActiveMode() == BOT_MODE_FARM or mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) and npcBot:GetMana()/npcBot:GetMaxMana() > 0.65
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nCastRange, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 5 and tableNearbyEnemyCreeps[2] ~= nil
		-- and abilityIG:GetLevel() > 2
		then
			return BOT_ACTION_DESIRE_MODERATE, tableNearbyEnemyCreeps[2];
		end
	end
	
	
	if (mutil.IsPushing(bot) or mutil.IsDefending(bot) or npcBot:GetActiveMode() == BOT_MODE_LANING or npcBot:GetActiveMode() == BOT_MODE_FARM) and currManaP > 0.6 
	-- and abilityIG:GetLevel() > 1
	then
		local target = mutil.GetVulnerableWeakestUnit3(false, true, nCastRange, bot);
		local lanecreeps = bot:GetNearbyCreeps(1200, true);
		if target ~= nil and #lanecreeps > 2  then
			-- return BOT_ACTION_DESIRE_HIGH, target;
			local target2 = mutil.GetMostHpUnit(lanecreeps);
			if target2 ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target2;
		end
		end 
		-- target = mutils.GetVulnerableWeakestUnit(false, true, nCastRange, bot);
		-- if target ~= nil then
			-- return BOT_ACTION_DESIRE_HIGH, target;
		-- end
	end
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			local tableNearbyEnemyCreeps = npcTarget:GetNearbyLaneCreeps( nRadius, false );
			for _,h in pairs(tableNearbyEnemyHeroes) 
			do
				if h:GetUnitName() ~= npcTarget:GetUnitName() and mutil.CanCastOnNonMagicImmune(h)
				then
					return BOT_ACTION_DESIRE_HIGH, h;
				end
			end
			for _,c in pairs(tableNearbyEnemyCreeps) 
			do
				if mutil.CanCastOnNonMagicImmune(c)
				then
					return BOT_ACTION_DESIRE_HIGH, c;
				end
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;
end



function ConsiderLivingArmor()

	-- Make sure it's castable
	if ( not abilityLA:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcBot;
			end
		end
	end

	local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		for _,npcAlly in pairs( tableNearbyAllyHeroes )
		do
			if mutil.CanCastOnNonMagicImmune(npcAlly) and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.25 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcAlly;
			end
		end
	end
	
	for _,npcAlly in pairs( tableNearbyAllyHeroes )
	do
		if mutil.CanCastOnNonMagicImmune(npcAlly) and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.25 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcAlly;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderFireblast()

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nRadius = abilityFB:GetSpecialValueInt("radius");
	local nCastRange = abilityFB:GetCastRange();
	local nDamage = 500;

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're in a teamfight, use it on the scariest enemy
	if mutil.IsInTeamFight(npcBot, 1200)
	then

		local npcMostWeakEnemy = nil;
		local nMostWeakHP = 10000;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( #tableNearbyEnemyHeroes >= 3 ) then
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( mutil.CanCastOnMagicImmune( npcEnemy ) and not mutil.IsDisabled(true, npcEnemy) )
				then
					local nHealth = npcEnemy:GetHealth()
					if ( nHealth < nMostWeakHP )
					then
						nMostWeakHP = nHealth;
						npcMostWeakEnemy = npcEnemy;
					end
				end
			end

			if ( npcMostWeakEnemy ~= nil  )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcMostWeakEnemy;
			end
		end
	end
	
	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() and  mutil.CanCastOnMagicImmune( npcEnemy ) and not mutil.IsDisabled(true, npcEnemy) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
		end
	end

	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
		if tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2
		then
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and  mutil.CanCastOnMagicImmune( npcEnemy ) and not mutil.IsDisabled(true, npcEnemy) ) 
				then
					local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and not mutil.IsDisabled(true, npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) 
		then
			local NearbyEnemyHeroes = npcTarget:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			local nInvUnit = mutil.CountInvUnits(true, NearbyEnemyHeroes);
			if nInvUnit >= 3 then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

