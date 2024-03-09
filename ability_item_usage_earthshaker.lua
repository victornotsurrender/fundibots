if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( "bots/ability_item_usage_generic" )
local utils = require("bots/util")
local mutil = require("bots/MyUtility")

local nutils = require("bots/NewUtility")

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


--[[ Skill Slot
"Ability1"		"earthshaker_fissure"
"Ability2"		"earthshaker_enchant_totem"
"Ability3"		"earthshaker_aftershock"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"earthshaker_echo_slam"
]]--
--[[ Related Modifier
modifier_earthshaker_fissure_stun
modifier_earthshaker_fissure
modifier_fissure_rooted
modifier_earthshaker_enchant_totem_leap
modifier_earthshaker_enchant_totem
modifier_earthshaker_aftershock
]]
local abilities = {};

local castQDesire = 0;
local castWDesire = 0;
local castRDesire = 0;

local function IsValidObject(object)
	return object ~= nil and object:IsNull() == false and object:CanBeSeen() == true;
end

local function GetUnitCountWithinRadius(tUnits, radius)
	local count = 0;
	if tUnits ~= nil and #tUnits > 0 then
		for i=1,#tUnits do
			if IsValidObject(tUnits[i]) and GetUnitToUnitDistance(bot, tUnits[i]) <= radius then
				count = count + 1;
			end
		end	
	end
	return count;
end

local function ConsiderQ()
	if not mutil.CanBeCast(abilities[1]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = 1200
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost   = abilities[1]:GetManaCost();
	local nRadius    = abilities[1]:GetSpecialValueInt( "fissure_radius" );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nDamage   =  abilities[1]:GetAbilityDamage();
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	local nManaCost = abilities[1]:GetManaCost();
	
	if nCastRange > 1600 then nCastRange = 1600 end
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and mutil.CanKillTarget2(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) or npcEnemy:IsChanneling()
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	--if we can hit any enemies with regen modifier
	-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and (npcEnemy:HasModifier("modifier_clarity_potion") or npcEnemy:HasModifier("modifier_flask_healing") )then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	
	if bot.data.enemies ~= nil and #bot.data.enemies > 0 then
		for i=1,#bot.data.enemies do
			if IsValidObject(bot.data.enemies[i]) and GetUnitToUnitDistance(bot, bot.data.enemies[i]) < nCastRange and bot.data.enemies[i]:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, bot.data.enemies[i]:GetLocation();
			end
		end
	end
	
	if mutil.IsRetreating(bot)
	then
		if bot.data.enemies ~= nil and #bot.data.enemies > 0 then
			for i=1,#bot.data.enemies do
				if IsValidObject(bot.data.enemies[i]) and GetUnitToUnitDistance(bot, bot.data.enemies[i]) < nCastRange then
					return BOT_ACTION_DESIRE_HIGH, bot.data.enemies[i]:GetLocation();
				end
			end
		end
	end
	
	if nutils.IsInTeamFight(bot)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end
	
	
	
	
	if (bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, bot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) or bot:GetActiveMode() == BOT_MODE_LANING) and mutil.AllowedToSpam(bot, nManaCost)
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(nCastRange, true);
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius/2, nCastPoint, 0 );
		if ( locationAoE.count >= 8 and #lanecreeps >= 8  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	-- if (bot:GetActiveMode() == BOT_MODE_LANING  or  mutil.IsPushing(bot) or  mutil.IsDefending(bot)) and currManaP > 0.65
	-- then
	   
	
		-- local laneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true);
		-- for _,creep in pairs(laneCreeps)
		-- do
			-- if creep:GetHealth() <= nDamage then
				-- return BOT_ACTION_DESIRE_HIGH, creep:GetLocation ();
		    -- end
        -- end
	-- end
	

	
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
	
	
	
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
	   local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1400, true, BOT_MODE_NONE );
		local tableNearbyAlliedHeroes = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) and not mutil.IsDisabled(true, npcEnemy)
			and npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.80 ) and #tableNearbyAlliedHeroes >=1
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
			end
		end
		
	end
	
	
	
	
	
	-- if npcBot:GetActiveMode() == BOT_MODE_FARM  and currManaP > 0.45
	-- then
		-- local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		-- local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( nCastRange );
			-- if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				-- for _,neutral in pairs(tableNearbyNeutrals)
				-- do
				-- if neutral:CanBeSeen() and neutral:IsAlive() and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					-- then 
					-- return BOT_ACTION_DESIRE_MODERATE,neutral:GetLocation();
				-- end
			-- end
		-- end
	-- end

	if mutil.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, bot, nCastRange) 
		and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange - 200, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

local function ConsiderW()
	
	if not mutil.CanBeCast(abilities[2]) then
		return BOT_ACTION_DESIRE_NONE, "", nil;
	end
	local nCastRange = 0;
	if bot:HasScepter() == true or bot:HasModifier("modifier_item_ultimate_scepter_consumed") == true then
		nCastRange = abilities[2]:GetSpecialValueInt("distance_scepter");
	end
	local nCastPoint = abilities[2]:GetCastPoint();
	local manaCost   = abilities[2]:GetManaCost();
	local nRadius    = abilities[2]:GetSpecialValueInt( "aftershock_range" );
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	
	
	if bot:HasScepter() and mutil.IsStuck(bot) 
	and bot:GetMana() == 1.0 * bot:GetMaxMana() and bot:GetHealth() == 1.0 * bot:GetMaxHealth() 
	then
		local loc = mutil.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, "loc", bot:GetXUnitsTowardsLocation( loc, nCastRange );
	end
	
	-- if mutil.IsRetreating(bot)
	-- then
		-- if bot.data.enemies ~= nil and #bot.data.enemies > 0 then
			-- if bot:HasScepter() or bot:HasModifier("modifier_item_ultimate_scepter_consumed")  then
				-- local loc = mutil.GetEscapeLoc();
				-- return BOT_ACTION_DESIRE_HIGH, "loc", bot:GetXUnitsTowardsLocation( loc, nCastRange );
			-- else
				-- for i=1,#bot.data.enemies do
					-- if IsValidObject(bot.data.enemies[i]) and GetUnitToUnitDistance(bot, bot.data.enemies[i]) < nRadius then
						-- return BOT_ACTION_DESIRE_HIGH, "", nil;
					-- end
				-- end
			-- end
		-- end
	-- end
	
	
	if (bot:GetActiveMode() == BOT_MODE_LANING or mutil.IsPushing(bot) or mutil.IsDefending(bot)) and mutil.CanSpamSpell(bot, manaCost) 
	then
	   
	
		local laneCreeps = bot:GetNearbyLaneCreeps(nRadius, true);
		for _,creep in pairs(laneCreeps)
		do
			if creep:GetHealth() <= 0.25 *creep:GetMaxHealth()  then
				return BOT_ACTION_DESIRE_MODERATE,"", nil;
				elseif bot:HasScepter() or bot:HasModifier("modifier_item_ultimate_scepter_consumed") then
				if mutil.IsInRange(creep, bot, nRadius) == false and mutil.IsInRange(creep, bot, nCastRange) then
				return BOT_ACTION_DESIRE_MODERATE, "loc", creep:GetLocation();
		    end
        end
    end
	end
	
	
	
	if mutil.IsRetreating(npcBot)
	then
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		 if mutil.ShouldEscape2(npcBot) then
			if npcBot:HasScepter() or npcBot:HasModifier("modifier_item_ultimate_scepter_consumed") then
				local loc = mutil.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, "loc", bot:GetXUnitsTowardsLocation( loc, nCastRange );
			else
				
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune2(npcEnemy) and GetUnitCountWithinRadius(npcBot.data.enemies, nRadius) >= 2  )
       		then
						return BOT_ACTION_DESIRE_HIGH, "", nil;
					end
				end
			end
		end
	end
	
	if nutils.IsInTeamFight(bot) and GetUnitCountWithinRadius(bot.data.enemies, nRadius) >= 2 
	then
		if bot:HasScepter() or bot:HasModifier("modifier_item_ultimate_scepter_consumed") then
			return BOT_ACTION_DESIRE_HIGH, "unit", bot;
		else
			return BOT_ACTION_DESIRE_HIGH, "", nil;
		end	
	end

	if ( mutil.IsDefending(bot) or mutil.IsPushing(bot) ) and mutil.CanSpamSpell(bot, manaCost) 
	   and bot:HasModifier("modifier_earthshaker_enchant_totem") == false and GetUnitCountWithinRadius(bot.data.e_creeps, nRadius) >= 3 
	then
		if bot:HasScepter() or bot:HasModifier("modifier_item_ultimate_scepter_consumed") then
			return BOT_ACTION_DESIRE_HIGH, "unit", bot;
		else
			return BOT_ACTION_DESIRE_HIGH, "", nil;
		end	
	end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_FARM and bot:HasModifier("modifier_earthshaker_enchant_totem") == false 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local tableNearbyNeutrals = npcBot:GetNearbyNeutralCreeps( 800 );
			if tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >= 1 then
				for _,neutral in pairs(tableNearbyNeutrals)
				do
				if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 0 
				and tableNearbyNeutrals ~= nil and #tableNearbyNeutrals >=1
					then 
					if npcBot:HasScepter() == false or bot:HasModifier("modifier_item_ultimate_scepter_consumed") == false and mutil.IsInRange(neutral, npcBot, nRadius)
					then
						return BOT_ACTION_DESIRE_HIGH, "", nil;
				elseif bot:HasScepter() or bot:HasModifier("modifier_item_ultimate_scepter_consumed") then
					if mutil.IsInRange(neutral, bot, nRadius) == false and mutil.IsInRange(neutral, bot, nCastRange)
					then
						return BOT_ACTION_DESIRE_HIGH, "loc", neutral:GetLocation();
				elseif mutil.IsInRange(neutral, bot, nRadius) 
					then
					return BOT_ACTION_DESIRE_HIGH, "unit", bot;
					
					end
					end
					
				end
			end
		end
	end
	
	
	
	
	
	if mutil.IsGoingOnSomeone(bot) and bot:HasModifier("modifier_earthshaker_enchant_totem") == false
	then
		local npcTarget = bot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget)  
		and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			if bot:HasScepter() == false or npcBot:HasModifier("modifier_item_ultimate_scepter_consumed") == false 
			and mutil.IsInRange(npcTarget, bot, nRadius) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_HIGH, "", nil;
			elseif bot:HasScepter() or npcBot:HasModifier("modifier_item_ultimate_scepter_consumed") then
				if mutil.IsInRange(npcTarget, bot, nRadius) == false 
					and mutil.IsInRange(npcTarget, bot, nCastRange)
				then
					local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					return BOT_ACTION_DESIRE_HIGH, "loc", npcTarget:GetLocation();
				elseif mutil.IsInRange(npcTarget, bot, nRadius) 
				then
					local cpos = utils.GetTowardsFountainLocation(npcTarget:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
					return BOT_ACTION_DESIRE_HIGH, "unit", bot;				
				end
			end	
		end
	end
	
	
	
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange+200, 2.0);	
	if skThere then
		if npcBot:HasScepter () or npcBot:HasModifier("modifier_item_ultimate_scepter_consumed")then
			return BOT_ACTION_DESIRE_MODERATE,"loc", skLoc;
		elseif not npcBot:HasScepter() or not npcBot:HasModifier("modifier_item_ultimate_scepter_consumed")then
			local skThere, skLoc = mutil.IsSandKingThere(npcBot, nRadius-100, 2.0);
		if skThere then
			return BOT_ACTION_DESIRE_HIGH, "", nil;
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE, "", nil;
end

local function ConsiderR()
	
	if not mutil.CanBeCast(abilities[3]) then
		return BOT_ACTION_DESIRE_NONE;
	end
	local nCastRange = 0;
	local nCastPoint = abilities[3]:GetCastPoint();
	local manaCost   = abilities[3]:GetManaCost();
	local nRadius    = abilities[2]:GetSpecialValueInt( "aftershock_range" ) + 50;
	local nDamage   =  abilities[3]:GetSpecialValueInt( "echo_slam_initial_damage" ) * #bot.data.enemies
	
	
	
	
	--if we can kill any enemies
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune2(npcEnemy) and mutil.CanKillTarget2(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) then
		 
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if nutils.IsInTeamFight(bot) and GetUnitCountWithinRadius(bot.data.enemies, nRadius) >= 2
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius/2, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and mutil.CanCastOnNonMagicImmune2(npcEnemy)  ) 
			then
				local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	
	-- If we're farming and can kill 3+ creeps with LSA
	if mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) or npcBot:GetActiveMode() == BOT_MODE_LANING
	then
		local NearbyCreeps = npcBot:GetNearbyLaneCreeps(nRadius/2, true);
		if NearbyCreeps ~= nil and #NearbyCreeps >= 12 then 
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius/2)
		and (not mutil.StillHasModifier(npcTarget, 'modifier_shadow_demon_disruption') or not mutil.StillHasModifier(npcTarget, 'modifier_obsidian_destroyer_astral_imprisonment_prison')      )
		then
			local cpos = utils.GetTowardsFountainLocation(npcEnemy:GetLocation(), 0);
					bot:ActionImmediate_Ping( cpos.x,  cpos.y, true)
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nRadius-100, 2.0);
	
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	

	return BOT_ACTION_DESIRE_NONE;
end

function AbilityUsageThink()
	if #abilities == 0 then abilities = mutil.InitiateAbilities(bot, {0,1,5}) end
	
	if mutil.CantUseAbility(bot) then return end
	
	-- if ability_item_usage_generic.SwapItemsTest() then return end
	-- ability_item_usage_generic.UnImplementedItemUsage();
	
	castQDesire, QLoc  			 = ConsiderQ();
	castWDesire, targetType, tgt = ConsiderW();
	castRDesire        			 = ConsiderR();
	
	
	
	
	if castRDesire > 0 then
		bot:Action_UseAbility(abilities[3]);		
		return
	end
	if castQDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[1], QLoc);		
		return
	end
	if castWDesire > 0 then
		if targetType == "loc" then
			bot:Action_UseAbilityOnLocation(abilities[2], tgt);
		elseif targetType == "unit" then
			bot:Action_UseAbilityOnEntity(abilities[2], tgt);
		else
			bot:Action_UseAbility(abilities[2]);
		end	
		return
	end
end