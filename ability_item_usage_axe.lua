if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
local mutil = require("bots/MyUtility")
local mutils = require("bots/MyUtility")

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

local ItemBM = nil;

local castQDesire = 0;
local castWDesire = 0;
local castRDesire = 0;

function AbilityUsageThink()
	
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	
	if abilityQ == nil then abilityQ = npcBot:GetAbilityByName( "axe_berserkers_call" ) end
	if abilityW == nil then abilityW = npcBot:GetAbilityByName( "axe_battle_hunger" ) end
	if abilityR == nil then abilityR = npcBot:GetAbilityByName( "axe_culling_blade" ) end
	
	ItemBM = mutil.GetComboItem(npcBot, 'item_blade_mail')

	castQDesire, castQTarget = ConsiderQ();
	castWDesire, castWTarget = ConsiderW();
	castRDesire, castRTarget = ConsiderR();

	if ItemBM ~= nil and ItemBM:IsFullyCastable() and castQDesire > 0 and castQTarget == "hero" then
		npcBot:Action_UseAbility( ItemBM );
		return;
	end
	
	if ( castRDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityR, castRTarget );
		return;
	end

	if ( castQDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityQ );
		return;
	end
	
	if ( castWDesire > 0 ) 
	then
		-- if npcBot:HasScepter() == true then
			-- npcBot:Action_UseAbilityOnLocation( abilityW, castWTarget:GetLocation() );
			-- return;
		-- else
			npcBot:Action_UseAbilityOnEntity( abilityW, castWTarget );
			return;
		-- end
	end
	
end

function ConsiderQ()

	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, "";
	end

	-- Get some of its values
	local nRadius    = abilityQ:GetSpecialValueInt( "radius" );
	local nCastPoint = abilityQ:GetCastPoint( );
	local nManaCost  = abilityQ:GetManaCost( );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	
	
	
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
				-- local distance = GetUnitToUnitDistance(npcEnemy, bot)
				-- local moveCon = npcEnemy:GetMovementDirectionStability();
				-- local pLoc = npcEnemy:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
				-- if moveCon < 1  then
					-- pLoc = npcEnemy:GetLocation();
				-- end
				-- if mutils.IsAllyHeroBetweenMeAndTarget(bot, npcEnemy, pLoc, nRadius) == false 
					-- and mutils.IsCreepBetweenMeAndTarget(bot, npcEnemy, pLoc, nRadius) == false
				-- then
					
					return BOT_ACTION_DESIRE_MODERATE, "hero";
				end
			end
		end
	end
	end
	end
	-- end
	

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, "hero";
			end
		end
	end
	
	-- If we're doing Roshan
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcBot, npcTarget, nRadius)  )
		then
			return BOT_ACTION_DESIRE_MODERATE, "creep";
		end
	end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.8
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nRadius - 100 );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					then 
					return BOT_ACTION_DESIRE_MODERATE,"creep";
				end
			end
		end
	end
	
	-- If We're pushing or defending
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nRadius, true );
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 4  ) then
			return BOT_ACTION_DESIRE_MODERATE, "creep";
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius-100)
		then
			return BOT_ACTION_DESIRE_MODERATE, "hero";
		end
	end
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nRadius, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE,"";
	end
	
	return BOT_ACTION_DESIRE_NONE, "";

end

function ConsiderW()

	-- Make sure it's castable
	if ( not abilityW:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityW:GetCastRange();
	local nCastPoint = abilityW:GetCastPoint( );
	local nManaCost  = abilityW:GetManaCost( );
	local nDamage    = abilityW:GetSpecialValueInt( 'damage_per_second') * abilityW:GetSpecialValueInt( 'duration' );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune(npcEnemy) and mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_LANING and mutil.AllowedToSpam(npcBot, nManaCost) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( 1200, false );
		if #tableNearbyEnemyCreeps == 0 and tableNearbyEnemyHeroes[1] ~= nil then
			return BOT_ACTION_DESIRE_HIGH, tableNearbyEnemyHeroes[1];
		end
	end	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_FARM or npcBot:GetActiveMode() == BOT_MODE_LANING ) and currManaP > 0.45
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nCastRange, 0, 0 );
		if ( locationAoE.count >= 1 ) then
		local npcTarget = mutil.GetVulnerableUnitNearLoc(true, true, nCastRange, nCastRange, locationAoE.targetloc, bot);
		if npcTarget ~= nil  then
			return BOT_ACTION_DESIRE_MODERATE,npcTarget;
		end
	end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
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

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderR()

	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityR:GetCastRange();
	local nCastPoint = abilityR:GetCastPoint( );
	local nManaCost  = abilityR:GetManaCost( );
	local nDamage    = abilityR:GetSpecialValueInt('kill_threshold');
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcEnemy:GetHealth() < nDamage and mutil.CanCastOnMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcEnemy:GetHealth() < nDamage and mutil.CanCastOnMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) 
		   and npcTarget:GetHealth() < nDamage
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


