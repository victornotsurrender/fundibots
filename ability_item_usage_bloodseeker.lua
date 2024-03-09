if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
local mutil = require("bots/MyUtility")
local role = require("bots/RoleUtility");

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
local abilityW = nil;
local abilityR = nil;

local castQDesire = 0;
local castWDesire = 0;
local castRDesire = 0;

function AbilityUsageThink()
	
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- ability_item_usage_generic.UnImplementedItemUsage();
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	
	if abilityQ == nil then abilityQ = npcBot:GetAbilityByName( "bloodseeker_bloodrage" ) end
	if abilityW == nil then abilityW = npcBot:GetAbilityByName( "bloodseeker_blood_bath" ) end
	if abilityR == nil then abilityR = npcBot:GetAbilityByName( "bloodseeker_rupture" ) end

	castQDesire, castQTarget = ConsiderQ();
	castWDesire, castWLoc    = ConsiderW();
	castRDesire, castRTarget = ConsiderR();
	
	-- ability_item_usage_generic.SwapItemsTest()

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
	
	if ( castWDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityW, castWLoc );
		return;
	end
	
end







function ConsiderQ()

	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityQ:GetCastRange();
	local nCastPoint = abilityQ:GetCastPoint( );
	local nManaCost  = abilityQ:GetManaCost( );
	local nDamage    = npcBot:GetAttackDamage()+ (( abilityQ:GetSpecialValueInt( 'damage_increase_pct' ) / 100 ) * npcBot:GetAttackDamage());
	
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING  ) 
	     and not mutil.StillHasModifier(npcBot, 'modifier_bloodseeker_bloodrage')
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( 1000, true );
		local tableNearbyAllyCreeps  = npcBot:GetNearbyLaneCreeps( 1000, false );
		for _,ECreep in pairs(tableNearbyEnemyCreeps)
		do
			if mutil.CanKillTarget(ECreep, nDamage, DAMAGE_TYPE_PHYSICAL) then
				return BOT_ACTION_DESIRE_HIGH, npcBot;
			end
		end
		for _,ACreep in pairs(tableNearbyAllyCreeps)
		do
			if mutil.CanKillTarget(ACreep, nDamage, DAMAGE_TYPE_PHYSICAL) then
				return BOT_ACTION_DESIRE_HIGH, npcBot;
			end
		end
	end	
	
	if  npcBot:GetActiveMode() == BOT_MODE_FARM 
	    and not mutil.StillHasModifier(npcBot, 'modifier_bloodseeker_bloodrage')
	then
		local tableNearbyCreeps  = npcBot:GetNearbyCreeps( 1000, true );
		for _,ECreep in pairs(tableNearbyCreeps)
		do
			if mutil.CanKillTarget(ECreep, nDamage, DAMAGE_TYPE_PHYSICAL) then
				return BOT_ACTION_DESIRE_HIGH, npcBot;
			end
		end
	end	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) 
		     and not mutil.StillHasModifier(npcBot, 'modifier_bloodseeker_bloodrage')  )
		then
			return BOT_ACTION_DESIRE_LOW, npcBot;
		end
	end

	if mutil.IsInTeamFight(npcBot, 1200) or  mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
	    
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 then
			local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, false, BOT_MODE_NONE );
			local highesAD = 0;
			local highesADUnit = nil;
			
			for _,npcAlly in pairs( tableNearbyAllyHeroes )
			do
				local AllyAD = npcAlly:GetAttackDamage();
				if ( mutil.CanCastOnNonMagicImmune(npcAlly) and not mutil.StillHasModifier(npcAlly, 'modifier_bloodseeker_bloodrage') and
					 AllyAD > highesAD ) 
				then
					highesAD = AllyAD;
					highesADUnit = npcAlly;
				end
			end
			
			if highesADUnit ~= nil then
				return BOT_ACTION_DESIRE_HIGH, highesADUnit;
			end
		
		end	
		
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) 
		then
		    if mutil.IsDisabled(false, npcTarget) and not mutil.StillHasModifier(npcTarget, 'modifier_bloodseeker_bloodrage') then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			elseif not mutil.StillHasModifier(npcBot, 'modifier_bloodseeker_bloodrage') then 
				return BOT_ACTION_DESIRE_HIGH, npcBot;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderW()

	-- Make sure it's castable
	if ( not abilityW:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius    = abilityW:GetSpecialValueInt('damage');
	local nCastRange = abilityW:GetCastRange();
	local nCastPoint = abilityW:GetCastPoint( );
	local nDelay	 = abilityW:GetSpecialValueFloat( 'delay' );
	local nManaCost  = abilityW:GetManaCost( );
	local nDamage    = abilityW:GetSpecialValueInt( 'damage');
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune(npcEnemy) and mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_PURE)
		then
			if  npcEnemy:GetMovementDirectionStability() >= 0.75 then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nDelay);
			else
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
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
					return BOT_ACTION_DESIRE_MODERATE,neutral:GetLocation();
				end
			end
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_LANING and mutil.AllowedToSpam(npcBot, nManaCost) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 1000, nRadius/2, nCastPoint, nDamage );
		if ( locationAoE.count >= 8 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
	end	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) and mutil.AllowedToSpam(npcBot, nManaCost) 
		 and tableNearbyEnemyHeroes == nil or #tableNearbyEnemyHeroes == 0 
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(1000, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 1000, nRadius/2, nCastPoint, nDamage );
		if ( locationAoE.count >= 8 and #lanecreeps >= 8 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
	end	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				local cpos = utils.GetTowardsFountainLocation(bot:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation();
			end
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

	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange - 200, nRadius/2, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			local nInvUnit = mutil.FindNumInvUnitInLoc(false, npcBot, nCastRange, nRadius/2, locationAoE.targetloc);
			if nInvUnit >= locationAoE.count then
				return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) 
		then
			if  npcTarget:GetMovementDirectionStability() >= 0.75 then
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(nCastPoint);
			else
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
			end
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderR()

	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange   = abilityR:GetCastRange();
	local nCastPoint   = abilityR:GetCastPoint( );
	local nManaCost    = abilityR:GetManaCost( );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	-- local speed    	 = 1000
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) 
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and not mutil.IsSuspiciousIllusion(npcEnemy) ) 
			then
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end

	if mutil.IsInTeamFight(npcBot, 1200)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcEnemy:IsHero() and role.IsCarry(npcEnemy:GetUnitName()) and mutil.CanCastOnMagicImmune(npcEnemy) 
				 and not mutil.StillHasModifier(npcEnemy, 'modifier_bloodseeker_rupture') and not mutil.IsDisabled(true, npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
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
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
	end
	end
	end
	-- end
	
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget)and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200)
           and not mutil.StillHasModifier(npcTarget, 'modifier_bloodseeker_rupture') and not mutil.IsDisabled(true, npcTarget) and not mutil.IsSuspiciousIllusion(npcTarget)
		then
			local allies = npcTarget:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
			if ( allies ~= nil and #allies >= 2 )
			then
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end
