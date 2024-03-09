if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end


local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
local skills = require("bots/SkillsUtility")
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
local castUFBDesire = 0;
local castIGDesire = 0;
local castTLDesire = 0;

local abilityUFB = nil;
local abilityFB = nil;
local abilityTL = nil;
local abilityIG = nil;
local ability4 = nil;
local ability5 = nil;

local setTarget = false;
-- local npcBot = nil;
local castUltDelay = 0;
local castUltTime = -90;
local castTeleLandTime = DotaTime();
local lastStolenSpellTarget = "";
local lastSSScepterTime = DotaTime();

local npcBot = GetBot();
local bot = GetBot();

function AbilityUsageThink()

	-- if npcBot == nil then npcBot = GetBot(); end
	-- Check if we're already using an ability	
	if mutil.CanNotUseAbility(npcBot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	if abilityUFB == nil then abilityUFB = npcBot:GetAbilityByName( "rubick_spell_steal" ) end
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "rubick_telekinesis" ) end
	if abilityTL == nil then abilityTL = npcBot:GetAbilityByName( "rubick_telekinesis_land" ) end
	if abilityIG == nil then abilityIG = npcBot:GetAbilityByName( "rubick_fade_bolt" ) end
	ability4 = npcBot:GetAbilityInSlot(3) 
	ability5 = npcBot:GetAbilityInSlot(4)
	
	-- Consider using each ability
	castFBDesire, castFBTarget = ConsiderFireblast();
	castTLDesire, castTLLocation = ConsiderTeleLand();
	castUFBDesire, castUFBTarget = ConsiderUnrefinedFireblast();
	castIGDesire, castIGTarget = ConsiderIgnite();
	
	
	
	if ( castUFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityUFB, castUFBTarget );
		castUltTime = DotaTime();
		lastStolenSpellTarget = castUFBTarget:GetUnitName();
		lastSSScepterTime = DotaTime();
		return;
	end

	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		setTarget = false;
		return;
	end
	
	if ( castTLDesire > 0 and not setTarget ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTL, castTLLocation );
		castTeleLandTime = DotaTime();
		setTarget = true;
		return;
	end

	if ( castIGDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityIG, castIGTarget );
		return;
	end
	
	skills.CastStolenSpells(ability4);
	skills.CastStolenSpells(ability5);

end

function ConsiderFireblast()

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
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
			if GetUnitToLocationDistance(bot,u:GetLocation()) <= 700 
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
	
	
	---------------------------------------
	-- If we're  defending a lane and can hit a Hero, go for it
	if ( mutil.IsDefending(npcBot)  or npcBot:GetActiveMode() == BOT_MODE_LANING) 
	and npcBot:GetMana()/npcBot:GetMaxMana() > 0.6 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		local tableNearbyAlliesTower = npcBot:GetNearbyTowers(450, false);
		
		for _,u in pairs(tableNearbyAlliesTower) 
		do
		if mutil.IsInRange(u, npcBot, 450) then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.IsInRange(npcEnemy, npcBot, nCastRange)  and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	end
	end
	end
	
	----------------------------------------------
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcBot:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	
	local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	for _,myFriend in pairs(tableNearbyFriendlyHeroes) 
	do
		if  myFriend:GetUnitName() ~= npcBot:GetUnitName() and mutil.IsRetreating(myFriend) and
			myFriend:WasRecentlyDamagedByAnyHero(2.0) 
		then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange-200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
		if  mutil.CanCastOnNonMagicImmune(npcEnemy) and mutil.IsInRange(npcEnemy, npcBot, nCastRange-200) 
		and not mutil.IsDisabled(true, npcEnemy) and not npcEnemy:IsIllusion()
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
		end
	end	
	end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) and
           not mutil.IsDisabled(true, npcTarget)		
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderTeleLand()
	
	-- Make sure it's castable
	if ( DotaTime() < castTeleLandTime + 0.5 or abilityTL == nil or not abilityTL:IsFullyCastable() or abilityTL:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityFB:GetCastRange();
	local nRadius = abilityTL:GetSpecialValueInt("radius");
	
	if ( npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or npcBot:GetActiveMode() == BOT_MODE_RETREAT  ) 
	then
		return BOT_ACTION_DESIRE_MODERATE, npcBot:GetXUnitsInFront( nCastRange + nRadius );
	end
	
	
	
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING) 
	-- and npcBot:GetMana()/npcBot:GetMaxMana() > 0.75 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		local tableNearbyAlliesTower = npcBot:GetNearbyTowers(700, false);
		
		for _,u in pairs(tableNearbyAlliesTower) 
		do
		if mutil.IsInRange(u, npcBot, 700) then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.IsInRange(npcEnemy, npcBot, nCastRange)  and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, u:GetLocation();
		end
	end
	end
	end
	end
	
	
	
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		return BOT_ACTION_DESIRE_MODERATE, npcBot:GetLocation();
	end

	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderIgnite()

	-- Make sure it's castable
	if ( not abilityIG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityIG:GetCastRange();
	local nDamage = abilityIG:GetSpecialValueInt( "damage" );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
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
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil and not npcTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_MODERATE,npcTarget;
		end
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)  or npcBot:GetActiveMode() == BOT_MODE_LANING) and npcBot:GetMana()/npcBot:GetMaxMana() > 0.75 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 8 and tableNearbyEnemyCreeps[1] ~= nil
		then
			return BOT_ACTION_DESIRE_MODERATE, tableNearbyEnemyCreeps[1];
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) 
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderUnrefinedFireblast()

	-- Make sure it's castable
	if ( not abilityUFB:IsFullyCastable() or DotaTime() - castUltTime <= castUltDelay ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	if not string.find(ability4:GetName(), 'empty') and ability4:GetName() ~= "life_stealer_infest"  and not ability4:IsToggle() and ability4:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityUFB:GetCastRange();
	local projSpeed = abilityUFB:GetSpecialValueInt('projectile_speed')
	
	if nCastRange + 200 > 1600 then nCastRange = 1600 end
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	if npcBot:HasScepter() == true then
		if mutil.IsGoingOnSomeone(npcBot)
		then
			local enemies = npcBot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
			for i=0, #enemies do
				if mutil.IsValidTarget(enemies[i]) and mutil.CanCastOnNonMagicImmune(enemies[i]) 
					and ( ( enemies[i]:GetUnitName() ~= lastStolenSpellTarget ) or ( enemies[i]:GetUnitName() == lastStolenSpellTarget and DotaTime() > lastSSScepterTime + 5.0 ) )
				then
					return BOT_ACTION_DESIRE_HIGH, enemies[i];
				end
			end
		end	
	else
		-- If we're going after someone
		if mutil.IsGoingOnSomeone(npcBot)
		then
			local npcTarget = npcBot:GetTarget();
			if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) 
			then
				castUltDelay = GetUnitToUnitDistance(npcBot, npcTarget) / projSpeed + ( 2*0.1 ); 
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end	
	
	return BOT_ACTION_DESIRE_NONE, 0;

end



