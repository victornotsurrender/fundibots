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

local bot = GetBot();
local npcBot = GetBot();

local abilityQ = nil;
local abilityW = nil;
local abilityE = nil;
local abilityR = nil;
local abilityAOEW = nil;

local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

local gapTime  = 1.5;
local stunTime = 0;

local cancelMDDesire = 0;

function AbilityUsageThink()
	
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	
	if abilityQ == nil then abilityQ = npcBot:GetAbilityByName( "lion_impale" ) end
	if abilityW == nil then abilityW = npcBot:GetAbilityByName( "lion_voodoo" ) end
	if abilityE == nil then abilityE = npcBot:GetAbilityByName( "lion_mana_drain" ) end
	if abilityR == nil then abilityR = npcBot:GetAbilityByName( "lion_finger_of_death" ) end
	if abilityAOEW == nil then abilityAOEW = npcBot:GetAbilityByName( "special_bonus_unique_lion_4" ) end
	
	if IsThereUnitMDed() then
		cancelMDDesire = ConsiderCancelMD()
		if cancelMDDesire > 0 then	
			npcBot:Action_MoveToLocation(npcBot:GetLocation()+RandomVector(200))
			return
		end
	end	
	
	
	castQDesire, castQTarget, castQType = ConsiderQ();
	castWDesire, castWTarget = ConsiderW();
	castEDesire, castETarget = ConsiderE();
	castRDesire, castRTarget = ConsiderR();
	
	-- ability_item_usage_generic.SwapItemsTest()
	
	if ( castRDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityR, castRTarget );
		return;
	end

	if ( castQDesire > 0 ) 
	then
		if castQType == "target" then
			stunTime = DotaTime();
			npcBot:Action_UseAbilityOnEntity( abilityQ, castQTarget );
			return;
		else
			stunTime = DotaTime();
			npcBot:Action_UseAbilityOnLocation( abilityQ, castQTarget );
			return;
		end
	end
	
	if ( castWDesire > 0 and DotaTime() >= stunTime + gapTime ) 
	then
		if abilityAOEW:IsTrained() then
			npcBot:Action_UseAbilityOnLocation( abilityW, castWTarget:GetLocation() );
			return;
		else
			npcBot:Action_UseAbilityOnEntity( abilityW, castWTarget );
			return;
		end	
	end
	
	if ( castEDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityE, castETarget );
		return;
	end
	
end

function NonMDSpellOnCD()
	return not abilityQ:IsFullyCastable() and not abilityW:IsFullyCastable() and not abilityR:IsFullyCastable() 
end

function ConsiderQ()
	
	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0, "";
	end

	-- Get some of its values
	local nRadius     = abilityQ:GetSpecialValueInt('width');
	local nLengthBuff = abilityQ:GetSpecialValueInt('length_buffer');
	local nCastRange  = mutil.GetProperCastRange(false, npcBot, abilityQ:GetCastRange()+nLengthBuff);
	local nCastPoint  = abilityQ:GetCastPoint( );
	local nManaCost   = abilityQ:GetManaCost( );
	local nDamage     = abilityQ:GetAbilityDamage();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1400, true, BOT_MODE_NONE );
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
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
			if GetUnitToLocationDistance(bot,u:GetLocation()) <= nCastRange and GetUnitToLocationDistance(npcEnemy,u:GetLocation()) <= nCastRange
				then
			if #allies >= 0 then
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy, 'target';
				end
			end
		end
	end
	end
	end
	
	
	--if we can kill any enemies
	
--	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
--	do
--		if mutil.CanCastOnNonMagicImmune(npcEnemy) and ( mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) or npcEnemy:IsChanneling() ) then
	--		return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'target';
	--	end
	--end
	
	
	--si puede interrumpir un channeling
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune(npcEnemy) and  npcEnemy:IsChanneling()  then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'target';
		end
	end
	
	--if we can hit any enemies with regen modifier
	-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and (npcEnemy:HasModifier("modifier_clarity_potion") or npcEnemy:HasModifier("modifier_flask_healing") )then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'target';
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'target';
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) 
            and not mutil.IsDisabled(true, npcTarget) )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget, 'target';
		end
	end

	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, 'location';
		end
	end
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange+200, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 8 and #lanecreeps >= 8  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, 'location';
		end
	end
	
	-- if npcBot:GetActiveMode() == BOT_MODE_LANING  or mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) and currManaP > 0.80
	-- then
	   
	
		-- local laneCreeps = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		-- for _,creep in pairs(laneCreeps)
		-- do
			-- if creep:GetHealth() <= nDamage then
				-- return BOT_ACTION_DESIRE_MODERATE, creep, 'target';
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
				if neutral:CanBeSeen() and neutral:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 
				and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					then 
					return BOT_ACTION_DESIRE_MODERATE,neutral:GetLocation(),'location';
				end
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) 
		   and not mutil.IsDisabled(true, npcTarget)
		   and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget, 'target';
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange-100, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc,'location';
	end
	
	return BOT_ACTION_DESIRE_NONE, 0, "";

end

function ConsiderW()

	-- Make sure it's castable
	if ( not abilityW:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange  =  abilityW:GetCastRange();
	local nCastPoint  =  abilityW:GetCastPoint( );
	local nManaCost   =  abilityW:GetManaCost( );
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune(npcEnemy) and  npcEnemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) 
            and not mutil.IsDisabled(true, npcTarget) )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end

	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local highesAD = 0;
		local highesADUnit = nil;
		
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			local EnemyAD = npcEnemy:GetAttackDamage();
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy) and
				 EnemyAD > highesAD ) 
			then
				highesAD = EnemyAD;
				highesADUnit = npcEnemy;
			end
		end
		
		if highesADUnit ~= nil then
			return BOT_ACTION_DESIRE_HIGH, highesADUnit;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) 
		   and not mutil.IsDisabled(true, npcTarget)
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderE()

	-- Make sure it's castable
	if ( not abilityE:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange   =  abilityE:GetCastRange();
	local nCastPoint   =  abilityE:GetCastPoint( );
	local nManaCost    =  abilityE:GetManaCost( );
	local nManaDrained =  abilityE:GetSpecialValueFloat( 'duration' )*abilityE:GetSpecialValueInt('mana_per_second');
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	
	--if we can kill any enemies
	if not mutil.IsRetreating(npcBot) and npcBot:GetMaxMana() - npcBot:GetMana() > nManaDrained/2 and ( tableNearbyEnemyHeroes == nil or #tableNearbyEnemyHeroes == 0 )
	then
		local tableNearbyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange + 200, true );
		for _,creep in pairs(tableNearbyCreeps)
		do
			if mutil.CanCastOnNonMagicImmune(creep) and creep:GetAttackRange() > 320 and creep:GetMana() >= nManaDrained/2 
			then
				return BOT_ACTION_DESIRE_HIGH, creep;
			end
		end
	end
	

	if mutil.IsInTeamFight(npcBot, 1200) and NonMDSpellOnCD() and tableNearbyEnemyHeroes[1] ~= nil 
	then
		return BOT_ACTION_DESIRE_HIGH, tableNearbyEnemyHeroes[1];
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) 
		   and NonMDSpellOnCD()
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function IsThereUnitMDed()
	local nCastRange   =  1200;
	local tableNearbyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange + 200, true );
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	
	for _,enemy in pairs(tableNearbyEnemyHeroes) 
	do
		if enemy:HasModifier('modifier_lion_mana_drain') then
			return true;
		end
	end
	for _,creep in pairs(tableNearbyCreeps) 
	do
		if creep:HasModifier('modifier_lion_mana_drain') then
			return true;
		end
	end
	return false;
end

function ConsiderCancelMD()
	
	if mutil.IsInTeamFight(npcBot, 1200) and ( abilityQ:IsFullyCastable() or abilityW:IsFullyCastable() or abilityR:IsFullyCastable() ) then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_ATTACK );
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
	if ( npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByCreep(2.0) or npcBot:WasRecentlyDamagedByTower(2.0) )
	     and ( #tableNearbyAllyHeroes <= #tableNearbyEnemyHeroes or npcBot:GetHealth() < 0.35*npcBot:GetMaxHealth() )
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	return BOT_ACTION_DESIRE_NONE

end

function ConsiderR()

	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius     = 0;
	local nCastRange  = abilityR:GetCastRange();
	local nCastPoint  = abilityR:GetCastPoint( );
	local nManaCost   = abilityR:GetManaCost( );
	local nDamage     = abilityR:GetSpecialValueInt('damage');
	
	if npcBot:HasScepter() then
		nDamage = abilityR:GetSpecialValueInt('damage_scepter');
		nRadius = abilityR:GetSpecialValueInt('splash_radius_scepter');
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
		do
			if mutil.CanCastOnNonMagicImmune(npcEnemy) and mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) then
				return BOT_ACTION_DESIRE_ABSOLUTE, npcEnemy;
			end
		end
	end
	
	-- if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) and npcBot:HasScepter()
	-- then
		-- local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange+200, true );
		-- if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 4 and mutil.AllowedToSpam(npcBot, nManaCost) ) then
			-- return BOT_ACTION_DESIRE_MODERATE, tableNearbyEnemyCreeps[1];
		-- end
	-- end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) and npcBot:HasScepter() 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) 
            and not mutil.IsDisabled(true, npcTarget) and (not abilityW:IsFullyCastable() or not abilityQ:IsFullyCastable()))
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end

	if mutil.IsInTeamFight(npcBot, 1200) and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcEnemy:IsHero() and mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, npcEnemy;
			end
			if ( npcEnemy:IsHero() and mutil.CanCastOnNonMagicImmune(npcEnemy) and npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.5 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) 
		then
			if mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL)
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, npcTarget;
			end
			if ( npcTarget:GetHealth()/npcTarget:GetMaxHealth() < 0.5 ) 
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, npcTarget;
			end
			local NearbyAllies = npcTarget:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
			if NearbyAllies ~= nil and #NearbyAllies >= 2 
			and npcTarget:HasModifier('modifier_templar_assassin_refraction_absorb') == false
			then
				local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end