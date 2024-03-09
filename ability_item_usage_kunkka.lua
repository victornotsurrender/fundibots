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

local Combo1Time = 0; 
local Combo2Time = 0; 
local Combo3Time = 0; 

local C1Delay = 2.2; 
local C2Delay = 1.8; 
local C3Delay = 3.2; 
local Combo1 = 0;
local Combo2 = 0;
local Combo3 = 0;

local castTODesire = 0;
local castXSDesire = 0;
local castGSDesire = 0;
local castTSDesire = 0;
local castXRTDesire = 0;

local abilityTO = "";
local abilityXS = "";
local abilityRT = "";
local abilityGS = "";
local abilityTS = "";
-- local npcBot = nil;
local npcBot = GetBot();
local bot = GetBot();



local XmarkLoc = Vector(0, 0, 0);
local XmarkCastTime = -100;
local XmarkCastGap  = 0.1;

function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	
	if not npcBot:IsAlive() then
		Combo1Time = 0;
		Combo2Time = 0;
		Combo3Time = 0;
	end
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced() or npcBot:NumQueuedActions() > 0   ) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	if abilityTO == "" then abilityTO = npcBot:GetAbilityByName( "kunkka_torrent" ); end
	if abilityXS == "" then abilityXS = npcBot:GetAbilityByName( "kunkka_x_marks_the_spot" ); end
	if abilityRT == "" then abilityRT = npcBot:GetAbilityByName( "kunkka_return" ); end
	if abilityGS == "" then abilityGS = npcBot:GetAbilityByName( "kunkka_ghostship" ); end
	if abilityTS == "" then abilityTS = npcBot:GetAbilityByName( "kunkka_torrent_storm" ); end
	
	Combo1, Combo1Target, Combo1Loc = ConsiderCombo1();
	Combo2, Combo2Target, Combo2Loc = ConsiderCombo2();
	Combo3, Combo3Target, Combo3Loc = ConsiderCombo3();
	castTODesire, castTOLoc = ConsiderTorrent()
	castXSDesire, castXSTarget = ConsiderXMark()
	castGSDesire, castGSLoc = ConsiderGhostShip()
	castTSDesire = ConsiderTorrentStorm()
	castXRTDesire = ConsiderXMarkReturn()
	
	-- ability_item_usage_generic.SwapItemsTest()
	
	if not abilityRT:IsHidden() and 
		( 
		  ( Combo3Time ~= 0 and DotaTime() >= Combo3Time + C3Delay ) or 
		  ( Combo1Time ~= 0 and DotaTime() >= Combo1Time + C1Delay ) or
		  ( Combo2Time ~= 0 and DotaTime() >= Combo2Time + C2Delay ) 
		)
	then
		npcBot:Action_UseAbility(abilityRT);
		Combo1Time = 0;
		Combo2Time = 0;
		Combo3Time = 0;
		return
	end
	
	if Combo1 > 0 then
		Combo1Time = DotaTime();
		npcBot:Action_ClearActions(false);
		npcBot:ActionQueue_UseAbilityOnEntity(abilityXS, Combo1Target);
		npcBot:ActionQueue_UseAbilityOnLocation(abilityGS,  Combo1Loc);
		npcBot:ActionQueue_UseAbilityOnLocation(abilityTO, Combo1Loc);
		return;
	end
	
	if Combo2 > 0 then
		Combo2Time = DotaTime();
		npcBot:Action_ClearActions(false);
		npcBot:ActionQueue_UseAbilityOnEntity(abilityXS, Combo2Target);
		npcBot:ActionQueue_UseAbilityOnLocation(abilityTO, Combo2Loc);
		return;
	end
	
	if Combo3 > 0 then
		Combo3Time = DotaTime();
		npcBot:Action_ClearActions(false);
		npcBot:ActionQueue_UseAbilityOnEntity(abilityXS, Combo3Target);
		npcBot:ActionQueue_UseAbilityOnLocation(abilityGS,  Combo3Loc);
		return;
	end
	
	-- if castTODesire > 0 then 
	if castTODesire > Combo1 and castTODesire > Combo2 and castTODesire > Combo3 then 
		npcBot:Action_UseAbilityOnLocation(abilityTO,  castTOLoc);
		return;
	end
	
	-- if castXSDesire > 0 then
	if castXSDesire > Combo1 and castXSDesire > Combo2 and castXSDesire > Combo3 then
		Combo1Time = DotaTime() + C2Delay;
		npcBot:Action_UseAbilityOnEntity(abilityXS,  castXSTarget);
		return;
	end
	
	-- if castGSDesire > 0 then
	if castGSDesire > Combo1 and castGSDesire > Combo2 and castGSDesire > Combo3 then
		npcBot:Action_UseAbilityOnLocation(abilityGS,  castGSLoc);
		return;
	end
	
	-- if castTSDesire > 0 then
	if castTSDesire > Combo1 and castTSDesire > Combo2 and castTSDesire > Combo3 then
		npcBot:Action_UseAbility(abilityTS);
		return;
	end
	
	
	-- if castXRTDesire> 0 then
	if castXRTDesire > Combo1 and castXRTDesire > Combo2 and castXRTDesire > Combo3 then
	    npcBot:Action_UseAbility(abilityRT);
		XmarkCastTime = DotaTime();
		XmarkLoc = castXSTarget:GetLocation();
		
		return;
	end
	
end

function CanCastXMarkOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function GetTowardsFountainLocation( unitLoc, distance )
	local destination = {};
	if ( GetTeam() == TEAM_RADIANT ) then
		destination[1] = unitLoc[1] - distance / math.sqrt(2);
		destination[2] = unitLoc[2] - distance / math.sqrt(2);
	end

	if ( GetTeam() == TEAM_DIRE ) then
		destination[1] = unitLoc[1] + distance / math.sqrt(2);
		destination[2] = unitLoc[2] + distance / math.sqrt(2);
	end
	return Vector(destination[1], destination[2]);
end

function ConsiderCombo1()
	
	if not abilityTO:IsFullyCastable() or not abilityXS:IsFullyCastable() or not abilityGS:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local CurrMana = npcBot:GetMana();
	
	local ComboMana = abilityTO:GetManaCost() + abilityXS:GetManaCost() + abilityGS:GetManaCost();
	
	if ComboMana > CurrMana then
		return BOT_ACTION_DESIRE_NONE, nil
	end
	
	local nCastRange = abilityXS:GetCastRange();
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and 
			GetUnitToUnitDistance(npcTarget, npcBot) > nCastRange/2 and GetUnitToUnitDistance(npcTarget, npcBot) < nCastRange ) 
		then
			--return BOT_ACTION_DESIRE_HIGH, npcTarget, npcTarget:GetLocation();
			return BOT_ACTION_DESIRE_HIGH, npcTarget, npcTarget:GetXUnitsInFront( 75 )
		end
	end
	
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
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy,npcEnemy:GetXUnitsInFront( 75 );
				end
			end
		end
	end
	end
	end
	
	
	
	
	return BOT_ACTION_DESIRE_NONE, nil
end

function ConsiderCombo2()
	if not abilityTO:IsFullyCastable() or not abilityXS:IsFullyCastable() or abilityGS:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil, {};
	end
	
	local CurrMana = npcBot:GetMana();
	
	local ComboMana = abilityTO:GetManaCost() + abilityXS:GetManaCost() 
	
	if ComboMana > CurrMana then
		return BOT_ACTION_DESIRE_NONE, nil, {};
	end
	
	local nCastRange = abilityXS:GetCastRange();
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and GetUnitToUnitDistance(npcTarget, npcBot) < nCastRange ) 
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget, npcTarget:GetXUnitsInFront( 75 )
		end
	end
	
	
	
	
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
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy,npcEnemy:GetXUnitsInFront( 75 );
				end
			end
		end
	end
	end
	end
	
	
	
	
	
	
	return BOT_ACTION_DESIRE_NONE, nil, {};
end

function ConsiderCombo3()
	
	if not abilityGS:IsFullyCastable() or not abilityXS:IsFullyCastable() or abilityTO:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil, {};
	end
	
	local CurrMana = npcBot:GetMana();
	
	local ComboMana = abilityGS:GetManaCost() + abilityXS:GetManaCost() 
	
	if ComboMana > CurrMana then
		return BOT_ACTION_DESIRE_NONE, nil, {};
	end
	
	local nCastRange = abilityXS:GetCastRange();
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget)  and 
			GetUnitToUnitDistance(npcTarget, npcBot) > nCastRange/2 and GetUnitToUnitDistance(npcTarget, npcBot) < nCastRange ) 
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget, npcTarget:GetLocation();
		end
	end
	
	
	
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
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy,npcEnemy:GetXUnitsInFront( 75 );
				end
			end
		end
	end
	end
	end
	
	
	
	
	
	
	return BOT_ACTION_DESIRE_NONE, nil, {};
end

function ConsiderTorrent()
	
	if not abilityTO:IsFullyCastable() or Combo1 > 0 or Combo2 > 0 or Combo3 > 0
	then
		return BOT_ACTION_DESIRE_NONE, {};
	end
	
	local nCastRange = abilityTO:GetCastRange();
	local nRadius    = abilityTO:GetSpecialValueInt('radius');
	local nCastPoint = abilityTO:GetCastPoint();
	local nDelay = abilityTO:GetSpecialValueFloat("delay");
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nManaCost    = abilityTO:GetManaCost( )
	
	
	-- --------------------------------------
	-- -- Mode based usage
	-- --------------------------------------
	
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
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					
					return BOT_ACTION_DESIRE_MODERATE,npcEnemy:GetXUnitsInFront( 75 );
				end
			end
		end
	end
	end
	end
	
	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange/2, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange/2, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 8 and #lanecreeps >= 8  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange/2, nRadius/2, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 600)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if (npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation(nDelay + nCastPoint);
			end
		end
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
		end
	end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange/2 );
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
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and GetUnitToUnitDistance(npcTarget, npcBot) < 1600 ) 
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(nDelay + nCastPoint);
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, 1000, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end	
	
	return BOT_ACTION_DESIRE_NONE, {};
end

function ConsiderXMark()
	
	if not abilityXS:IsFullyCastable() or Combo1 > 0 or Combo2 > 0 or Combo3 > 0
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = abilityXS:GetCastRange();
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if (npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	
	if mutil.IsDefending(npcBot) 
	 then
	  local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE ); 
	  local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	  local lanecreeps = npcBot:GetNearbyLaneCreeps(1600, true);
	if tableNearbyAttackingAlliedHeroes ~= nil and tableNearbyEnemyHeroes ~= nil 
	 and ( #tableNearbyAttackingAlliedHeroes >= 0 )  and #tableNearbyEnemyHeroes >= 2  and #lanecreeps >= 4
	 then
	   return BOT_ACTION_DESIRE_MODERATE, npcBot;
	  end
	end
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) 
		  and not mutil.IsSuspiciousIllusion(npcTarget)
		then
			local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	
	
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() or ( npcEnemy:GetActiveMode() == BOT_MODE_RETREAT and npcEnemy:GetActiveModeDesire() >= BOT_MODE_DESIRE_MODERATE ) ) 
		then
			local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end









function ConsiderXMarkReturn()
	
	if  abilityRT:IsHidden() then 
	return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	
	if DotaTime() < XmarkCastTime + XmarkCastGap then
		return BOT_ACTION_DESIRE_NONE, {};
	end
	
	if mutil.IsGoingOnSomeone(npcBot)  and  npcBot:HasModifier("modifier_kunkka_x_marks_the_spot") 
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 600)  
		then
			local incProj = npcBot:GetIncomingTrackingProjectiles()
			for _,p in pairs(incProj)
			do
				if GetUnitToLocationDistance(npcBot, p.location) <= 300 and p.is_attack == false then
					return BOT_ACTION_DESIRE_HIGH;
				end
			end
		end
	end
	
	
	if mutil.IsGoingOnSomeone(npcBot)  and  npcBot:HasModifier("modifier_kunkka_x_marks_the_spot") 
	then
	local npcTarget = npcBot:GetTarget();
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if (npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
		
	end
	
	
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderGhostShip()
	
	if not abilityGS:IsFullyCastable() or Combo1 > 0 or Combo2 > 0 or Combo3 > 0
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = abilityGS:GetCastRange();
	local nRadius = abilityGS:GetSpecialValueInt("ghostship_width");
	local nCastPoint = abilityGS:GetCastPoint();
	local nManaCost    = abilityGS:GetManaCost( );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if (npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				local cpos = utils.GetTowardsFountainLocation( npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE, GetTowardsFountainLocation(npcBot:GetLocation(), nCastRange/2)
			end
		end
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
		end
	end
	
	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange+200, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius/2, nCastPoint, 0 );
		if ( locationAoE.count >= 16 and #lanecreeps >= 16  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange/2, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderTorrentStorm()

	-- Make sure it's castable
	if ( abilityTS:IsFullyCastable() == false or npcBot:HasScepter() == false ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius    = abilityTS:GetSpecialValueInt( "torrent_max_distance" );
	local nCastPoint = abilityTS:GetCastPoint( );
	local nManaCost  = abilityTS:GetManaCost( );

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius - 200, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) and npcBot:DistanceFromFountain() < 7500 and mutil.AllowedToSpam(npcBot, nManaCost)
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nRadius/2, true);
		
		if (  #lanecreeps >= 16  ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius-200)
		then
			local enemies = npcTarget:GetNearbyHeroes(nRadius/2, false, BOT_MODE_NONE);
			if #enemies >= 2 then
				local cpos = utils.GetTowardsFountainLocation( npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, 1000, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end	

	return BOT_ACTION_DESIRE_NONE;
end