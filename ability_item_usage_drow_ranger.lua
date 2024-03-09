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

local bot = GetBot();
local npcBot = GetBot();

local abilityQ = nil;
local abilityQ2 = nil;
local abilityW = nil;
local abilityE = nil;

local castQ2Desire = 0;
local castWDesire = 0;
local castEDesire = 0;



function AbilityUsageThink()
	
	if mutil.CanNotUseAbility(npcBot)  or npcBot:NumQueuedActions() > 0  then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	if abilityQ == nil then abilityQ = npcBot:GetAbilityByName( "drow_ranger_frost_arrows" ) end
	if abilityQ2 == nil then abilityQ2 = npcBot:GetAbilityByName( "drow_ranger_frost_arrows" ) end
	if abilityW == nil then abilityW = npcBot:GetAbilityByName( "drow_ranger_wave_of_silence" ) end
	if abilityE == nil then abilityE = npcBot:GetAbilityByName( "drow_ranger_multishot" ) end

	ConsiderQ();
	castQ2Desire, castQ2Target = ConsiderQ2();
	castWDesire, castWLoc    = ConsiderW();
	castEDesire, castELoc    = ConsiderE();
	

	if ( castQ2Desire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnEntity( abilityQ2, castQ2Target );
		return;
	end
	if ( castEDesire > 0 ) 
	then
		npcBot:Action_ClearActions( true ); 
		npcBot:Action_UseAbilityOnLocation( abilityE, castELoc );
		npcBot:ActionQueue_Delay( 0.5 );
		return;
	end
	
	if ( castWDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityW, castWLoc );
		return;
	end
	
end



function ConsiderQ2()

	-- Make sure it's castable
	if ( not abilityQ2:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	
	local nCastRange   = abilityQ2:GetCastRange();
	local nDamage      = abilityQ2:GetSpecialValueInt("damage") + bot:GetAttackDamage();
	local nCastPoint   = abilityQ2:GetCastPoint( );
	local nManaCost    = abilityQ2:GetManaCost( );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and mutil.CanKillTarget2(npcEnemy, nDamage, DAMAGE_TYPE_PHYSICAL) or npcEnemy:IsChanneling()
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
		 if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
			and mutil.CanCastOnNonMagicImmune(npcEnemy) 
			and not mutil.IsSuspiciousIllusion(npcEnemy) and not npcEnemy:HasModifier("modifier_drow_ranger_frost_arrows_slow") ) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	
	

	if mutil.IsInTeamFight(npcBot, 1200) 
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnMagicImmune(npcEnemy) and mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_PHYSICAL ) and not mutil.IsSuspiciousIllusion(npcEnemy)) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end 
	
	
	
	-- if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING) and mutil.AllowedToSpam(npcBot, nManaCost)
	-- then
	   -- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
		-- local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
		-- for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		-- do
			-- if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy)
			-- and npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.80 ) and #tableNearbyAlliedHeroes >=1
			-- then
				-- return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			-- end
		-- end
		
	-- end
	
	
	-- -- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	-- local npcTarget = npcBot:GetTarget();
	-- if  mutil.IsPushing(npcBot) and abilityW:GetLevel () >= 2
	-- then
		-- local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nCastRange, true );
		-- for _,npcCreepTarget in pairs(tableNearbyEnemyCreeps) do
			-- if ( mutil.IsInRange(npcTarget, npcBot, nCastRange) and #tableNearbyEnemyHeroes == 0 and npcBot:GetMana()/npcBot:GetMaxMana() > 0.65 ) 
			-- then
				-- return BOT_ACTION_DESIRE_MODERATE, npcCreepTarget;
			-- end
		-- end
	-- end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
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
	
	if (mutil.IsRetreating(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING or mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_FARM ) and currManaP > 0.60
	then
	   
	
		local laneCreeps = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		for _,creep in pairs(laneCreeps)
		do
			local t = 2.0*bot:GetAttackPoint()+((GetUnitToUnitDistance(creep, bot))/bot:GetCurrentMovementSpeed());
			if creep:GetHealth() <= nDamage 
			or bot:GetEstimatedDamageToTarget(false, creep, t, DAMAGE_TYPE_PHYSICAL) >= creep:GetHealth()
			then
				return BOT_ACTION_DESIRE_HIGH, creep;
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
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget)
		and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200)
		and not mutil.IsSuspiciousIllusion(npcTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderQ()
	
	-- local npcTarget = npcBot:GetTarget();
	-- if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget)
	-- then
		-- if not abilityQ:GetAutoCastState( ) then
			-- abilityQ:ToggleAutoCast()
		-- end
	-- else 
		-- if  abilityQ:GetAutoCastState( ) then
			-- abilityQ:ToggleAutoCast()
		-- end
	-- end
	
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local npcTarget = npcBot:GetTarget();
	
	if ( npcTarget ~= nil and (npcTarget:IsHero() or npcTarget:GetUnitName() == "npc_dota_roshan" and mutil.CanCastOnNonMagicImmune(npcTarget)   ) and currManaP > .25)   or (npcBot:GetActiveMode() == BOT_MODE_FARM   and currManaP > .85)
	then
		if not abilityQ:GetAutoCastState( ) then
			abilityQ:ToggleAutoCast()
		end
	else 
		if  abilityQ:GetAutoCastState( ) then
			abilityQ:ToggleAutoCast()
		end
	end

end

function ConsiderW()

	-- Make sure it's castable
	if ( not abilityW:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius      = abilityW:GetSpecialValueInt('wave_width');
	local nCastRange   = abilityW:GetCastRange( );
	local nCastPoint   = abilityW:GetCastPoint( );
	local nManaCost    = abilityW:GetManaCost( );
	local nAttackRange = npcBot:GetAttackRange( );

	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune(npcEnemy) and npcEnemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
			end
		end
	end

	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nAttackRange) 
		and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderE()

	-- Make sure it's castable
	if ( abilityE:IsFullyCastable() == false or abilityE:IsTrained() == false ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius      = abilityW:GetSpecialValueInt('arrow_width');
	local nCastRange   = npcBot:GetAttackRange();
	local nCastPoint   = abilityW:GetCastPoint( );
	local nManaCost    = abilityW:GetManaCost( );
	local nAttackRange = npcBot:GetAttackRange( );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING) and currManaP > 0.45
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
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
				end
			end
		end
	end
	end
	end
	

	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	
	-- if npcBot:GetActiveMode() == BOT_MODE_LANING then
		-- local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		-- if ( locationAoE.count >= 2 ) then
			-- return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		-- end
	-- end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
			and mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsInRange(npcEnemy,npcBot,nCastRange) ) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) 
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
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or  npcBot:GetActiveMode() == BOT_MODE_LANING ) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange+200, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 8 and #lanecreeps >= 8  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	
	-- if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	-- then
		-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		-- local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			-- if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				-- for _,neutral in pairs(tableNearbyNeutrals)
				-- do
				-- if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					-- then 
					-- return BOT_ACTION_DESIRE_MODERATE,neutral:GetLocation();
				-- end
			-- end
		-- end
	-- end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nAttackRange + 200) 
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end





