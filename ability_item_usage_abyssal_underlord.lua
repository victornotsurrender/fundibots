if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require( "bots/util")
local mutil = require( "bots/MyUtility")

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

local castFSDesire = 0;
local castPMDesire = 0;
local castDRDesire = 0;
local abilityFS = nil;
local abilityPM = nil;
local abilityDR = nil;

-- local npcBot = nil;
local npcBot = GetBot();
local bot = GetBot();
local team = GetTeam();
function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityFS == nil then abilityFS = npcBot:GetAbilityByName( "abyssal_underlord_firestorm" ) end
	if abilityPM == nil then abilityPM = npcBot:GetAbilityByName( "abyssal_underlord_pit_of_malice" ) end
	if abilityDR == nil then abilityDR = npcBot:GetAbilityByName( "abyssal_underlord_dark_rift" ) end
	

	-- Consider using each ability
	
	-- castFSDesire, castFSType,castFSTarget  = ConsiderFireStorm();
	-- castPMDesire, castPMLocation = ConsiderPitOfMalice();
	-- castDRDesire,castDRType,castDRTarget  = ConsiderDarkRift();
	
	-- Consider using each ability original
	castFSDesire, castFSLocation = ConsiderFireStorm();
	castPMDesire, castPMLocation = ConsiderPitOfMalice();
	castDRDesire, castDRLocation = ConsiderDarkRift();
	
	-- if ( castDRDesire > 0 ) 
	-- then
		-- if castDRType == "target" then
			
			-- npcBot:ActionPush_UseAbilityOnEntity( abilityDR, castDRTarget );
			-- return;
		-- else
			
			-- npcBot:Action_UseAbilityOnLocation( abilityDR, castDRTarget );
			-- return;
		-- end
	-- end
	
	
	
	-- if ( castFSDesire > 0 ) 
	-- then
		-- if castFSType == "target" and bot:HasModifier("modifier_item_aghanims_shard") then
			
			-- npcBot:ActionPush_UseAbilityOnEntity( abilityFS, castFSTarget );
			-- return;
		-- end
	-- end
	
	-- if ( castFSDesire > 0 ) 
	-- then
		-- -- if castFSType == "location" and not bot:HasModifier("modifier_item_aghanims_shard") then
			
			-- npcBot:Action_UseAbilityOnLocation( abilityFS, castFSTarget );
			-- return;
		-- -- end
	-- end
	
	if ( castPMDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityPM, castPMLocation );
		return;
	end
	
	if ( castFSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityFS, castFSLocation );
		return;
	end
	
	if ( castDRDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityDR, castDRLocation );
		return;
	end
	
	
	
	---------------------------
	
	-- --- Save my Allies
	local numPlayer =  GetTeamPlayers(GetTeam());
	
	if FindSuroundedAlly and  bot:HasScepter() then
	for i = 1, #numPlayer
	do
		local Player = GetTeamMember(i);
		if Player:IsAlive() and Player:HasModifier('modifier_teleporting') == false and Player:GetHealth()/Player:GetMaxHealth() < 0.55 and 
		   mutil.IsRetreating(Player) and Player:DistanceFromFountain() > 3000 and GetUnitToUnitDistance(Player,npcBot) > 2500
		then
				npcBot:ActionPush_UseAbilityOnEntity( abilityDR, Player );
			-- return BOT_ACTION_DESIRE_MODERATE, 'target', Player;
		end
	end
	end
	

end

function FindSuroundedEnemy()
	local enemyheroes = GetUnitList(UNIT_LIST_ENEMY_HEROES );
	for _,enemy in pairs(enemyheroes)
	do
		local allyNearby = enemy:GetNearbyHeroes(1600, false, BOT_MODE_ATTACK);
		if allyNearby ~= nil and #allyNearby >= 2 then
			return enemy;
		end
	end
	return nil;
end



function FindSuroundedAlly()
	local Alliesheroes = GetUnitList(UNIT_LIST_ALLIED_HEROES );
	for _,ally in pairs(Alliesheroes)
	do
		local allyNearby = ally:GetNearbyHeroes(1600, true, BOT_MODE_ATTACK);
		if allyNearby ~= nil and #allyNearby >= 1 then
			return ally;
		end
	end
	return nil;
end


function ConsiderFireStorm()

	-- Make sure it's castable
	if ( not abilityFS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE,0;
	end


	-- Get some of its values
	local nRadius = abilityFS:GetSpecialValueInt( "radius" );
	local nCastRange = abilityFS:GetCastRange();
	local nCastPoint = abilityFS:GetCastPoint( );
	local nDamage = 6 * abilityFS:GetSpecialValueInt("wave_damage");
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nAttackRange    = bot:GetAttackRange();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	
	
	
	
	
	
	
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING) 
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
				
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
				end
			end
		end
	end
	end
	end
	
	
	-- if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	-- then
		-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		-- local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			-- if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 3 then
				-- for _,neutral in pairs(tableNearbyNeutrals)
				-- do
				-- if neutral:CanBeSeen() and neutral:IsAlive() and #tableNearbyEnemyHeroes == 0
					-- and neutral ~= nil 
					-- -- and  bot:HasModifier("modifier_item_aghanims_shard")
					-- then 
					-- return BOT_ACTION_DESIRE_MODERATE,'target',npcBot;
					-- -- else
					-- -- return BOT_ACTION_DESIRE_MODERATE,'location',neutral:GetLocation() ;
				-- end
			-- end
		-- end
	-- end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 3 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and #tableNearbyEnemyHeroes == 0
					and neutral ~= nil 
					-- and not  bot:HasModifier("modifier_item_aghanims_shard") 
					then 
					-- return BOT_ACTION_DESIRE_MODERATE,'target',npcBot;
					-- -- else
					return BOT_ACTION_DESIRE_MODERATE,neutral:GetLocation() ;
				end
			end
		end
	end
	
	
	
	
	
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) )
	then
		if  mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) and mutil.IsInRange(npcTarget, npcBot, nCastRange-200) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
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
	
	-- -- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	-- if mutil.IsRetreating(npcBot) 
	
	-- then
		-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		-- for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		-- do
			-- if  npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
			-- and ( not mutil.IsInRange(npcEnemy, npcBot, nCastRange-200) and mutil.IsInRange(npcEnemy, npcBot, nAttackRange + 200) )
			-- and  bot:HasModifier("modifier_item_aghanims_shard")
			-- then
				-- return BOT_ACTION_DESIRE_MODERATE, 'target', npcBot;
			 -- else
			 -- if  (mutil.IsValidTarget2(npcEnemy) and mutil.CanCastOnNonMagicImmune2(npcEnemy) )
					-- and   (mutil.IsInRange2(npcEnemy, npcBot, nCastRange-200) and not mutil.IsInRange2 (npcEnemy, npcBot, nAttackRange + 200))
					-- and (not bot:HasModifier("modifier_item_aghanims_shard") or bot:HasModifier("modifier_item_aghanims_shard") )
				-- then 
				-- return BOT_ACTION_DESIRE_MODERATE, 'location', npcEnemy:GetExtrapolatedLocation( nCastPoint );
				-- -- else
					-- -- return BOT_ACTION_DESIRE_MODERATE, 'location', npcEnemy:GetLocation();
			-- end
			-- end
		-- end
	-- end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING or
	     mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) ) and npcBot:GetMana() / npcBot:GetMaxMana() > 0.65
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange+200, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	
	-- if mutil.IsGoingOnSomeone(npcBot)
	-- then
	-- local npcTarget = npcBot:GetTarget();
		-- if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) 
		-- and (  mutil.IsInRange(npcTarget, npcBot, nCastRange-200) and mutil.IsInRange(npcTarget, npcBot, nAttackRange + 200) )
        -- and bot:HasModifier("modifier_item_aghanims_shard")) 
		-- then
			-- return BOT_ACTION_DESIRE_MODERATE, 'target', npcBot;
		-- else
		-- if  (mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) )
			-- and   (mutil.IsInRange(npcTarget, npcBot, nCastRange) and not mutil.IsInRange (npcTarget, npcBot, nAttackRange + 200)
			-- and (not bot:HasModifier("modifier_item_aghanims_shard") or bot:HasModifier("modifier_item_aghanims_shard") ))
		  -- then 
		-- return BOT_ACTION_DESIRE_MODERATE, 'location', npcTarget:GetExtrapolatedLocation( nCastPoint );
		-- -- else
		-- -- npcTarget = npcBot:GetAttackTarget();
		
		-- -- return BOT_ACTION_DESIRE_MODERATE, 'location', npcTarget:GetLocation();
		-- end
	-- end
	-- end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-200) ) 
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
				bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange+200, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
	
	
	-- local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange+200, 2.0);
	
	-- if skThere 
	-- then
		-- if GetUnitToLocationDistance (bot,skLoc) <= nAttackRange + 200 and bot:HasModifier("modifier_item_aghanims_shard") then
		-- return BOT_ACTION_DESIRE_MODERATE, 'target', npcBot;
		-- else
		-- if GetUnitToLocationDistance (bot,skLoc) > nAttackRange + 200 and (not bot:HasModifier("modifier_item_aghanims_shard") or bot:HasModifier("modifier_item_aghanims_shard") ) then 
		-- return BOT_ACTION_DESIRE_MODERATE, 'location', skLoc;
	-- end
	-- end
	-- end
	return BOT_ACTION_DESIRE_NONE, 0;
	
	
	
end

function ConsiderPitOfMalice()

	-- Make sure it's castable
	if ( not abilityPM:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityPM:GetSpecialValueInt( "radius" );
	local nCastRange = abilityPM:GetCastRange();
	local nCastPoint = abilityPM:GetCastPoint( );
	local nDamage = 1000
	local speed    	 = 1000
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	
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
				-- local distance = GetUnitToUnitDistance(npcEnemy, bot)
				-- local moveCon = npcEnemy:GetMovementDirectionStability();
				-- local pLoc = npcEnemy:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
				-- if moveCon < 1  then
					-- pLoc = npcEnemy:GetLocation();
				-- end
				-- if mutils.IsAllyHeroBetweenMeAndTarget(bot, npcEnemy, pLoc, nRadius) == false 
					-- and mutils.IsCreepBetweenMeAndTarget(bot, npcEnemy, pLoc, nRadius) == false
				-- then
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
				end
			end
		end
	end
	end
	end
	-- end
	
	
	
	
	
	
	
	
	
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange+200, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if  mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 1000 );
		if ( locationAoE.count >= 12 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	
	-- if npcBot:GetActiveMode() == BOT_MODE_FARM and npcBot:GetMana() / npcBot:GetMaxMana() > 0.8 and abilityPM:GetLevel() >=3
	-- then
		-- local lanecreeps = npcBot:GetNearbyNeutralCreeps(nCastRange);
		-- local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange/2, nRadius/2, 0, 0 );
		-- if ( locationAoE.count >= 2 and #lanecreeps >= 2 ) 
		-- then
			-- return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		-- end
	-- end

	
	-- If we're going after someone
	if  mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-200)  ) 
		and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderDarkRift()

	-- Make sure it's castable
	if ( not abilityDR:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0,"";
	end

	if npcBot:DistanceFromFountain() < 3000 then
		return BOT_ACTION_DESIRE_NONE, 0,"";
	end	
		
	-- Get some of its values
	local nRadius = abilityDR:GetSpecialValueInt( "radius" );

	-- ------------------------------------
	-- Mode based usage
	-- ------------------------------------
	if mutil.IsStuck(npcBot)
	then
	local location = mutil.GetTeamFountain();
				return BOT_ACTION_DESIRE_LOW, location;
		-- return BOT_ACTION_DESIRE_HIGH, GetAncient(GetTeam()):GetLocation(), 'location';
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local location = mutil.GetTeamFountain();
				return BOT_ACTION_DESIRE_LOW, location;
			end
		end
	end
	
	
	
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and GetUnitToUnitDistance( npcTarget, npcBot ) > 2500 ) 
		then
			local tableNearbyEnemyCreeps = npcTarget:GetNearbyCreeps( 800, true );
			local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			if tableNearbyEnemyCreeps ~= nil and tableNearbyAllyHeroes ~= nil and #tableNearbyEnemyCreeps >= 2 and #tableNearbyAllyHeroes >= 2 then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
			end	
		end
	end
	
	-- --- Save my Allies
	-- local numPlayer =  GetTeamPlayers(GetTeam());
	
	-- if FindSuroundedAlly and  npcBot:HasModifier("modifier_item_aghanims_shard") == true then
	-- for i = 1, #numPlayer
	-- do
		-- local Player = GetTeamMember(i);
		-- if Player:IsAlive() and Player:HasModifier('modifier_teleporting') == false and Player:GetHealth()/Player:GetMaxHealth() < 0.55 and 
		   -- mutil.IsRetreating(Player) and Player:DistanceFromFountain() > 3000 and GetUnitToUnitDistance(Player,npcBot) > 2500
		-- then
			-- return BOT_ACTION_DESIRE_MODERATE, 'target', Player;
		-- end
	-- end
	-- end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
	
	
end

