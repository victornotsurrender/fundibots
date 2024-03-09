local bot = GetBot();
local npcBot = GetBot();

if bot:IsInvulnerable() or bot:IsHero() == false or bot:IsIllusion() then return; end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )

local utils = require("bots/util")
local mutil = require("bots/MyUtility")
local mutils = require("bots/MyUtility")
local utility = require("bots/Utility")
-- local modfarm = require("bots/mode_farm_generic")

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

-- local abilities = mutils.InitiateAbilities(bot, {0,1,2,5,3});

local castQDesire = 0;
local castWDesire = 0;
local castRDesire = 0;
local castDDesire = 0;
-- local AttackDesire = 0;

local abilityQ = nil;
local abilityW = nil;
local abilityR = nil;
local abilityD = nil;


local moveS = 0;
local moveST = nil;
-- local ProxRange = 1300;

function AbilityUsageThink()

	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	
	if mutil.CanNotUseAbility(npcBot) then return end
	if mutils.CantUseAbility(bot) then return end
	
	-- AttackDesire, AttackTarget = ConsiderAttacking(npcBot);
	-- if (AttackDesire > 0)
		-- then
			-- -- npcBot:Action_AttackUnit( AttackTarget, true );
			 -- bot:Action_AttackMove(AttackTarget);
		-- return
	-- end
	if abilityQ == nil then abilityQ = npcBot:GetAbilityByName( "pudge_meat_hook" ) end
	if abilityW == nil then abilityW = npcBot:GetAbilityByName( "pudge_rot") end
	if abilityR == nil then abilityR = npcBot:GetAbilityByName( "pudge_dismember" ) end
	if abilityD == nil then abilityD = npcBot:GetAbilityByName( "pudge_eject" ) end
	
	if bot:IsChanneling() then
		if mutils.CanBeCast(abilityW) == true 
			and  mutils.IsGoingOnSomeone(bot)
		then
			local nRadius = abilityW:GetSpecialValueInt('rot_radius');
			local target = bot:GetTarget();
			if mutils.IsValidTarget(target) 
				and mutils.CanCastOnNonMagicImmune(target) 
				and bot:IsFacingLocation(target:GetLocation(),15) 
				and mutils.IsInRange(bot, target, nRadius)	
				and abilityW:GetToggleState() == false 
			then
				bot:Action_UseAbility(abilityW);		
				return
			end
		end
	end
	
	
	castQDesire, qTarget = ConsiderQ();
	castWDesire			 = ConsiderW();	
	castRDesire, rTarget = ConsiderR();
	castDDesire			 = ConsiderD();
	
	
	
	
	
	if castQDesire > 0 then
		-- bot:Action_ClearActions(false);
		bot:Action_UseAbilityOnLocation(abilityQ, qTarget);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_ClearActions(false);
		bot:ActionQueue_UseAbility(abilityW);		
		return
	end
	
	if castRDesire > 0 then
		bot:Action_ClearActions(false);
		bot:Action_UseAbilityOnEntity(abilityR, rTarget);		
		return
	end
	
	if castDDesire > 0 then
		bot:Action_ClearActions(false);
		bot:Action_UseAbility(abilityD);		
		return
	end
	
end



-- function ConsiderAttacking(npcBot)
	
	-- local target = npcBot:GetTarget();
	-- local AR = npcBot:GetAttackRange();
	-- local AD = npcBot:GetAttackDamage();
	
	-- if target == nil or target:IsTower() or target:IsBuilding() then
		-- target = npcBot:GetAttackTarget();
	-- end
	
	
	-- -- if npcBot:GetActiveMode() == BOT_MODE_FARM 
	-- -- then
		-- -- local npcTarget = npcBot:GetAttackTarget();
		-- -- if npcTarget ~= nil and not npcTarget:IsBuilding() then
			-- -- return BOT_ACTION_DESIRE_LOW, npcTarget;
		-- -- end
	-- -- end	
	
	-- local enemyCreeps = bot:GetNearbyLaneCreeps(1600, true);
	-- local allyCreeps = bot:GetNearbyLaneCreeps(1600, false);
	-- local enemyTowers = bot:GetNearbyTowers(1600, true);
	-- local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	
	-- -- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	-- -- local distance = GetUnitToUnitDistance(enemies[i], bot)
		-- for _,npcCreeps in pairs( enemyCreeps )
		-- do
			-- if ( npcBot:WasRecentlyDamagedByCreep(  2.0 )  and GetUnitToUnitDistance(npcCreeps, npcBot) < AR) and #enemyTowers == 0 and #tableNearbyEnemyHeroes == 0 
			-- then
				-- -- local Loc = npcCreeps:GetLocation()
				-- bot:ActionImmediate_Chat("AttackTarget",true);
				-- return BOT_ACTION_DESIRE_HIGH, npcCreeps:GetLocation();
			-- end
		-- end
	
	
	
	
	-- -- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	-- -- if mutil.IsRetreating(npcBot)
	-- -- then
		-- -- local tableNearbyEnemyHeroes = hMinionUnit:GetNearbyHeroes( ProxRange, true, BOT_MODE_NONE );
		-- -- for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		-- -- do
			-- -- if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and GetUnitToUnitDistance(hMinionUnit, npcBot) <= ProxRange)
			-- -- or (mutil.IsDisabled2(npcBot) and GetUnitToUnitDistance(hMinionUnit, npcBot) <= ProxRange)  or (mutil.IsDisabled2(npcBot) and npcBot:HasScepter())
			-- -- or (npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.35 and GetUnitToUnitDistance(hMinionUnit, npcBot) <= ProxRange) or (npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.35 and npcBot:HasScepter())
			-- -- then
				-- -- return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			-- -- end
		-- -- end
	-- -- end
	
	-- -- if target ~= nil and GetUnitToUnitDistance(hMinionUnit, npcBot) <= ProxRange then
		-- -- return BOT_ACTION_DESIRE_MODERATE, target;
	-- -- end
	
	-- return BOT_ACTION_DESIRE_NONE, 0;
-- end


function IsHeroBetweenMeAndTarget(source, target, endLoc, radius)
	local vStart = source:GetLocation();
	local vEnd = endLoc;
	local enemy_heroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for i=1, #enemy_heroes do
		if enemy_heroes[i] ~= target
			and enemy_heroes[i] ~= source
		then	
			local tResult = PointToLineDistance(vStart, vEnd, enemy_heroes[i]:GetLocation());
			if tResult ~= nil 
				and tResult.within == true  
				and tResult.distance < radius + 25 			
			then
				return true;
			end
		end
	end
	local ally_heroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
	for i=1, #ally_heroes do
		if ally_heroes[i] ~= target
			and ally_heroes[i] ~= source
		then	
			local tResult = PointToLineDistance(vStart, vEnd, ally_heroes[i]:GetLocation());
			if tResult ~= nil 
				and tResult.within == true  
				and tResult.distance < radius + 25 			
			then
				return true;
			end
		end
	end
	return false;
end

function IsAllyUnitAroundLocation(vLoc, nRadius)
	for i,id in pairs(GetTeamPlayers(GetTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id);
			if info ~= nil then
				local dInfo = info[1];
				if dInfo ~= nil and utils.GetDistance(vLoc, dInfo.location) <= nRadius and dInfo.time_since_seen < 1.0 then
					return true;
				end
			end
		end
	end
	return false;
end


function IsEnemyUnitAroundLocation(vLoc, nRadius)
	for i,id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id);
			if info ~= nil then
				local dInfo = info[1];
				if dInfo ~= nil and utils.GetDistance(vLoc, dInfo.location) <= nRadius and dInfo.time_since_seen < 1.0 then
					return true;
				end
			end
		end
	end
	return false;
end


function ConsiderQ()

	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastPoint = abilityQ:GetCastPoint();
	local manaCost   = abilityQ:GetManaCost();
	local nRadius    = abilityQ:GetSpecialValueInt('hook_width');
	local speed    	 = abilityQ:GetSpecialValueInt('hook_speed');
	local nCastRange = mutils.GetProperCastRange(false, bot, abilityQ:GetCastRange())-300;
	local nDamage    = abilityQ:GetAbilityDamage();
	-- local nRadius2    = abilityQ:GetSpecialValueInt('hook_width')*1.5;
	
	local alliesRadius = bot:GetNearbyHeroes(100, false, BOT_MODE_NONE);
	-- local Allydistance = GetUnitToUnitDistance( bot,alliesRadius[i])
	local enemyCreeps = bot:GetNearbyLaneCreeps(100, true);
	local allyCreeps = bot:GetNearbyLaneCreeps(100, false);
	-- local AllyAR = nil
	-- for i=1, #alliesRadius do
	-- if Allydistance <= nRadius then 
		-- return BOT_ACTION_DESIRE_NONE;
	-- end
	-- end
	
	-- if  #alliesRadius > 0 or  #enemyCreeps  > 0  or  #allyCreeps  > 0 
			-- then 
			-- AllyAR =  AlliesAroundHook(allies)
		-- if  bot:IsFacingLocation ( AllyAR:GetLocation(),5) then
		-- return BOT_ACTION_DESIRE_NONE;
	-- end
	-- end
	
	-- if  #alliesRadius > 0 or  #enemyCreeps  > 0  or  #allyCreeps  > 0 
			-- then 
		-- return BOT_ACTION_DESIRE_NONE;
	-- end
	

	local tableNearbyFriendlyHeroes = bot:GetNearbyHeroes( 100, false, BOT_MODE_NONE );
	for _,myFriend in pairs(tableNearbyFriendlyHeroes) 
	do
	if  bot:IsFacingLocation ( myFriend:GetLocation(),10) then
	return BOT_ACTION_DESIRE_NONE;
	end
	end

	
	
	
	
	
	
	if IsEnemyUnitAroundLocation(bot:GetLocation(), nCastRange) then
		-- local target = bot:GetTarget();
		-- if mutils.IsValidTarget(target) 
			-- and mutils.CanCastOnMagicImmune(target) 
			-- and bot:IsFacingLocation(target:GetLocation(),15) 
			-- and mutils.IsInRange(bot, target, nCastRange)
		-- then
		local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		for i=1, #enemies do
		if mutils.IsValidTarget(enemies[i]) and mutils.CanCastOnMagicImmune(enemies[i])
			then
				local distance = GetUnitToUnitDistance(enemies[i], bot)
				local moveCon = enemies[i]:GetMovementDirectionStability();
				local pLoc = enemies[i]:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
				local loc = enemies[i]:GetLocation();
				if moveCon < 0.65 then
					pLoc = enemies[i]:GetLocation();
				end
				if IsHeroBetweenMeAndTarget(bot, enemies[i], pLoc, nRadius) == false 
					and mutils.IsCreepBetweenMeAndTarget(bot, enemies[i], pLoc, nRadius + 150) == false
					and not mutils.IsAllyHeroBetweenMeAndTarget(bot, enemies[i], pLoc, nRadius + 150) == true 
					
				then
				local allies = bot:GetNearbyHeroes(250, false, BOT_MODE_NONE);
				local vLoc = bot:GetLocation();
				if not IsAllyUnitAroundLocation(bot:GetLocation(), nRadius + 150)
					and not mutils.GetAlliesNearLoc(vLoc, nRadius + 150) 
					then
					local cpos = utils.GetTowardsFountainLocation(pLoc, 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					return BOT_ACTION_DESIRE_HIGH, pLoc;
				end
			else
					if mutils.IsCreepBetweenMeAndTarget(bot, enemies[i], pLoc, nRadius) == false then
					local cpos = utils.GetTowardsFountainLocation(loc, 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH,npcBot:GetXUnitsTowardsLocation( loc, nCastRange ); 
			end
		end
	end
	end
	end
	
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnMagicImmune(target) 
			and bot:IsFacingLocation(target:GetLocation(),15) 
			and mutils.IsInRange(bot, target, nCastRange)
		then
			-- if moveST ~= target:GetUnitName() or target:GetMovementDirectionStability() ~= moveS then
				-- print(target:GetUnitName().." : "..tostring(target:GetMovementDirectionStability()))
				-- moveST = target:GetUnitName();
				-- moveS = target:GetMovementDirectionStability();
			-- end
			local allies = bot:GetNearbyHeroes(150, false, BOT_MODE_NONE);
			
			if #allies <= 1 then
				local distance = GetUnitToUnitDistance(target, bot)
				local moveCon = target:GetMovementDirectionStability();
				local pLoc = target:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
				if moveCon < 0.65 then
					pLoc = target:GetLocation();
				end
				if mutils.IsAllyHeroBetweenMeAndTarget(bot, target, pLoc, nRadius) == false 
					and mutils.IsCreepBetweenMeAndTarget(bot, target, pLoc, nRadius + 150) == false
				then
						local cpos = utils.GetTowardsFountainLocation(pLoc, 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					return BOT_ACTION_DESIRE_MODERATE, pLoc;
					else
						local cpos = utils.GetTowardsFountainLocation(target:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					return BOT_ACTION_DESIRE_MODERATE,npcBot:GetXUnitsTowardsLocation( target:GetLocation(), nCastRange );
					
				end
			end
		end
	end
	
	
	
	
	
	
	
	
	
	
	local allies = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_RETREAT);
	if #allies > 0 then
		local botBaseDist = bot:DistanceFromFountain();
		for i=1, #allies do
			if mutils.IsValidTarget(allies[i])
				and allies[i] ~= bot
				and mutils.CanCastOnMagicImmune(allies[i])
				and allies[i]:WasRecentlyDamagedByAnyHero(5.0)
				and allies[i]:GetHealth() < 0.5*allies[i]:GetMaxHealth()
				and ( allies[i]:GetTarget() == nil or allies[i]:GetAttackTarget() == nil )
				and allies[i]:DistanceFromFountain() > botBaseDist
				and GetUnitToUnitDistance(allies[i], bot) > 0.5*nCastRange
			then
				local distance = GetUnitToUnitDistance(allies[i], bot)
				local moveCon = allies[i]:GetMovementDirectionStability();
				local pLoc = allies[i]:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
				if moveCon < 0.65 then
					pLoc = allies[i]:GetLocation();
				end
				if IsHeroBetweenMeAndTarget(bot, allies[i], pLoc, nRadius) == false 
					and mutils.IsCreepBetweenMeAndTarget(bot, allies[i], pLoc, nRadius) == false
				then
					return BOT_ACTION_DESIRE_MODERATE, pLoc;
				end
			end	
		end	
	end
	
	
	
	
	-- if bot:GetActiveMode() == BOT_MODE_FARM then
	 -- local vLoc = bot:GetXUnitsTowardsLocation(bot:GetLocation(),1300);
	 -- local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
	 -- local allies = bot:GetNearbyHeroes(1300, false, BOT_MODE_NONE);
	 -- local NeutralCreeps = npcBot:GetNearbyNeutralCreeps( nRadius+200);
	 
		-- if modfarm.IsUnitAroundLocation(vLoc, 1300) then
		-- if  #enemies == 1 and # allies >= 0 and #NeutralCreeps == 0 then 
		 -- enemyLoc = modfarm.IsUnitAroundLocation(vLoc, 1300)
		 -- if bot:GetHealth() > 0.3*bot:GetMaxHealth()  and GetUnitToLocationDistance(bot,enemyLoc) <= 1300 then
			
			-- bot:ActionImmediate_Chat("Come on over here!!!",true);
			-- return BOT_ACTION_DESIRE_MODERATE, enemyLoc:GetLocation() + (RandomVector(200));
		 
		
		-- end
	  -- end
	 -- end
	-- end
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING) 
	or (mutil.IsRetreating(npcBot) and bot:GetHealth() > 0.35*bot:GetMaxHealth()  )
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		local allies = bot:GetNearbyHeroes(150, false, BOT_MODE_NONE);
		local Atowers = npcBot:GetNearbyTowers(nCastRange, false);
		
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  mutil.CanCastOnNonMagicImmune(npcEnemy)
			then	
		for _,u in pairs(Atowers) do
			if GetUnitToLocationDistance(bot,u:GetLocation()) <= 700
				then
			if #allies >= 0 then
				local distance = GetUnitToUnitDistance(npcEnemy, bot)
				local moveCon = npcEnemy:GetMovementDirectionStability();
				local pLoc = npcEnemy:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
				if moveCon < 1  then
					pLoc = npcEnemy:GetLocation();
				end
				if mutils.IsAllyHeroBetweenMeAndTarget(bot, npcEnemy, pLoc, nRadius) == false 
					and mutils.IsCreepBetweenMeAndTarget(bot, npcEnemy, pLoc, nRadius + 150) == false
				then
						local cpos = utils.GetTowardsFountainLocation(pLoc, 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					
					return BOT_ACTION_DESIRE_MODERATE, pLoc;
					else
						local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
						bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					return BOT_ACTION_DESIRE_MODERATE,npcBot:GetXUnitsTowardsLocation( npcEnemy:GetLocation(), nCastRange ); 
				end
			end
		end
	end
	end
	end
	end
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and mutil.CanKillTarget2(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) 
		 or npcEnemy:IsChanneling()
		then
			local distance = GetUnitToUnitDistance(npcEnemy, bot)
				local moveCon = npcEnemy:GetMovementDirectionStability();
				local pLoc = npcEnemy:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
				if moveCon < 1  then
					pLoc = npcEnemy:GetLocation();
				end
				if mutils.IsAllyHeroBetweenMeAndTarget(bot, npcEnemy, pLoc, nRadius) == false 
					and mutils.IsCreepBetweenMeAndTarget(bot, npcEnemy, pLoc, nRadius) == false
				then
					
				return BOT_ACTION_DESIRE_MODERATE, pLoc;
			
			end
		end
	end
	
	

	
	
	return BOT_ACTION_DESIRE_NONE;
end	

function ConsiderW()

	-- Make sure it's castable
	if ( not abilityW:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	if  mutils.CanBeCast(abilityW) == false  then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastPoint = abilityW:GetCastPoint();
	local manaCost   = abilityW:GetManaCost();
	local nRadius    = abilityW:GetSpecialValueInt("rot_radius");
	
	
	if (npcBot:GetActiveMode() == BOT_MODE_FARM or mutils.IsPushing(bot) or mutils.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING) and bot:GetHealth() > 0.65*bot:GetMaxHealth() 
	then
		local creeps = bot:GetNearbyLaneCreeps(nRadius, true);
		if #creeps >= 3 and abilityW:GetToggleState() == false then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if (npcBot:GetActiveMode() == BOT_MODE_FARM or mutils.IsPushing(bot) or mutils.IsDefending(bot) or  bot:GetActiveMode() == BOT_MODE_LANING) and bot:GetHealth() > 0.65*bot:GetMaxHealth() 
	then
		local creeps = bot:GetNearbyLaneCreeps(nRadius, true);
		if #creeps >= 3 and abilityW:GetToggleState() == true then
			return BOT_ACTION_DESIRE_NONE;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and bot:GetHealth() > 0.3*bot:GetMaxHealth()
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) and abilityW:GetToggleState() == false ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and bot:GetHealth() > 0.3*bot:GetMaxHealth()
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) and abilityW:GetToggleState() == true ) 
			then
				return BOT_ACTION_DESIRE_NONE;
			end
		end
	end
	
		-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and bot:GetHealth() < 0.3*bot:GetMaxHealth()
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) and abilityW:GetToggleState() == true ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and bot:GetHealth() > 0.3*bot:GetMaxHealth()
	then
		local creeps = npcBot:GetNearbyCreeps(nRadius,true)
		for _,npcCreeps in pairs( creeps )
		do
			if ( npcBot:WasRecentlyDamagedByCreep(  2.0 ) and abilityW:GetToggleState() == false ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and bot:GetHealth() > 0.3*bot:GetMaxHealth()
	then
		local creeps = npcBot:GetNearbyCreeps(nRadius,true)
		for _,npcCreeps in pairs( creeps )
		do
			if ( npcBot:WasRecentlyDamagedByCreep(  2.0 ) and abilityW:GetToggleState() == true ) 
			then
				return BOT_ACTION_DESIRE_NONE;
			end
		end
	end
	
		-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and bot:GetHealth() < 0.3*bot:GetMaxHealth()
	then
		local creeps = npcBot:GetNearbyCreeps(nRadius,true)
		for _,npcCreeps in pairs( creeps )
		do
			if ( npcBot:WasRecentlyDamagedByCreep(  2.0 ) and abilityW:GetToggleState() == true ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nRadius-150 );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and tableNearbyEnemyHeroes ~= nil 
				and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1 and abilityW:GetToggleState() == false
					then 
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM  
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nRadius);
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if neutral:CanBeSeen() and neutral:IsAlive() and tableNearbyEnemyHeroes ~= nil 
				and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1 and abilityW:GetToggleState() == true
					then 
					return BOT_ACTION_DESIRE_NONE;
				end
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and bot:IsFacingLocation(target:GetLocation(),15) 
		then
			if mutils.IsInRange(bot, target, nRadius)	
				and abilityW:GetToggleState() == false 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			elseif mutils.IsInRange(bot, target, nRadius) == false 
				and abilityW:GetToggleState() == true 	
			then	
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	else
		local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
		if (( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) ) or #enemies == 0 )
			and abilityW:GetToggleState() == true
		then 
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
	-- return 0.0
end	

 -- function ConsiderE()
	-- if  mutils.CanBeCast(abilities[3]) == false then
		-- return BOT_ACTION_DESIRE_NONE, nil;
	-- end
	
	
	-- return BOT_ACTION_DESIRE_NONE, nil;
-- end	

function ConsiderR()

	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if  mutils.CanBeCast(abilityR) == false or mutil.CanNotBeCast(npcBot) then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastPoint = abilityR:GetCastPoint();
	local manaCost   = abilityR:GetManaCost();
	local nStr = bot:GetAttributeValue(ATTRIBUTE_STRENGTH);
	local nStrMultiply = abilityR:GetSpecialValueFloat('strength_damage')
	local nDamage    = (abilityR:GetSpecialValueInt('dismember_damage')+nStrMultiply*nStr)*3;
	local nCastRange = mutils.GetProperCastRange(false, bot, abilityR:GetCastRange());
	
	
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		local ally1 = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE);
		local ally2 = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_ATTACK);
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil and not mutil.IsSuspiciousIllusion(target) and ((#enemies <= #ally1 ) or (#enemies <= #ally2) ) then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	

	if npcBot:GetActiveMode() == BOT_MODE_FARM and bot:GetHealth() <= 0.35*bot:GetMaxHealth()
	then
		local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
		local lanecreeps = npcBot:GetNearbyNeutralCreeps(nCastRange+200) or  npcBot:GetNearbyCreeps( nCastRange+200, true ); 
		local target = mutil.GetMostHpUnit(lanecreeps);
		if target ~= nil and #enemies == 0 then
			return BOT_ACTION_DESIRE_LOW, target;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and bot:IsFacingLocation(target:GetLocation(),15) 
			and mutils.IsInRange(bot, target, nCastRange)	
			and mutils.IsDisabled(true, target) == false	
			and target:GetHealth() >  0.5*nDamage
		then
			local enemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
			local allies = bot:GetNearbyHeroes(1000, false, BOT_MODE_ATTACK);
			if enemies ~= nil and allies ~= nil and  #enemies <= #allies then
				local cpos = utils.GetTowardsFountainLocation( target:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_ABSOLUTE, target;
			end
		end
	end
	
	----------------------------------------------------------
	
	local tableNearbyFriendlyHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	for _,myFriend in pairs(tableNearbyFriendlyHeroes) 
	do
		if  (myFriend:GetUnitName() ~= bot:GetUnitName() and mutil.IsRetreating(myFriend) and
			myFriend:WasRecentlyDamagedByAnyHero(3.0) and mutil.CanCastOnNonMagicImmune(myFriend)
			and (bot:HasScepter() == true or bot:HasModifier("modifier_item_ultimate_scepter_consumed") == true) 
			and myFriend:GetHealth()/myFriend:GetMaxHealth() < 0.35 )
			or  (myFriend:GetHealth()/myFriend:GetMaxHealth() <= 0.25 and (bot:HasScepter() == true or bot:HasModifier("modifier_item_ultimate_scepter_consumed") == true))
		then
			return BOT_ACTION_DESIRE_MODERATE, myFriend;
		end
	end	
	
	
	
	return BOT_ACTION_DESIRE_NONE;
end	



function ConsiderD()

	-- Make sure it's castable
	if ( not abilityD:IsFullyCastable() or mutil.CanNotBeCast(npcBot) ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	if  mutils.CanBeCast(abilityD) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastRange = 1400;
	
	local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
	
	if enemies == nil and #enemies == 0 then
		return BOT_ACTION_DESIRE_ABSOLUTE
	end
	
	return BOT_ACTION_DESIRE_NONE;
end