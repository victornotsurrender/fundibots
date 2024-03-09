-- local npcBot = nil;
local mutil = require("bots/MyUtility")
local npcBot = GetBot()

local abilitySTP = nil
local abilityTP  = nil
local abilityPP = nil

function  MinionThink(  hMinionUnit ) 
	
	
	if abilitySTP == nil then abilitySTP = hMinionUnit:GetAbilityByName( "templar_assassin_self_trap" ) end
	if abilityTP == nil then abilityTP = npcBot:GetAbilityByName( "templar_assassin_trap" ) end
	if abilityPP == nil then abilityPP = npcBot:GetAbilityByName( "templar_assassin_trap_teleport" ) end
	
if not hMinionUnit:IsNull() and hMinionUnit ~= nil then 	
	if hMinionUnit:GetUnitName() ==  "npc_dota_templar_assassin_psionic_trap" and hMinionUnit ~= nil and hMinionUnit:GetHealth() > 0 
	then
		-- local abilitySTP = hMinionUnit:GetAbilityByName( "templar_assassin_self_trap" );
		-- local abilityTP = npcBot:GetAbilityByName( "templar_assassin_trap" );
		local nRadius = abilitySTP:GetSpecialValueInt("trap_radius");
		local nRange = npcBot:GetAttackRange();
		local Enemies = hMinionUnit:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
		local Creeps = hMinionUnit:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
		local Enemies2 = hMinionUnit:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
		local Allies = hMinionUnit:GetNearbyHeroes(2*nRadius, false, BOT_MODE_NONE);
		local Allies2 = hMinionUnit:GetNearbyHeroes(2*nRadius, false, BOT_MODE_NONE);
		local distance = GetUnitToUnitDistance(npcBot, hMinionUnit);
		if abilityPP:IsInAbilityPhase() or npcBot:IsChanneling() then npcBot:Action_ClearActions(false) return end
		
		if ( npcBot:IsUsingAbility() or npcBot:IsCastingAbility() ) then return end
		if npcBot:HasScepter() then
			local abilityPP = npcBot:GetAbilityByName( "templar_assassin_trap_teleport" );
			if abilityPP:IsFullyCastable() == true and abilityPP:IsHidden() == false then
				if Enemies ~= nil and #Enemies >=1 and ( distance < 800 or Allies ~= nil ) then
					npcBot:Action_UseAbilityOnLocation( abilityPP, hMinionUnit:GetLocation() );
					return;
				end
			end	
		end
		if npcBot:HasScepter()  then
		if mutil.IsGoingOnSomeone(npcBot) then
			local target = FindTarget();
			if target ~= nil   
			then
			local abilityPP = npcBot:GetAbilityByName( "templar_assassin_trap_teleport" );
			if abilityPP:IsFullyCastable() == true and abilityPP:IsHidden() == false then
			 if distance > 800 then
				-- if Enemies ~= nil and #Enemies >=1 and ( distance > 800 or Allies ~= nil ) then
					npcBot:Action_UseAbilityOnLocation( abilityPP, hMinionUnit:GetLocation() );
					return;
				end
			end	
		end
		end
		end
		if npcBot:HasScepter() then
			if mutil.IsRetreating(npcBot) then
			-- local abilityPP = npcBot:GetAbilityByName( "templar_assassin_trap_teleport" );
			if abilityPP:IsFullyCastable() == true and abilityPP:IsHidden() == false then
				-- if  #Enemies2 == 0 and ( distance > 1600  ) then
				if mutil.ShouldEscape2(npcBot) then
				local loc = mutil.GetTeamFountain()
					npcBot:Action_UseAbilityOnLocation( abilityPP, loc );
					return;
				end
			end	
		end
		end
		if (Enemies ~= nil and #Enemies >=1 )  and ( distance < 800 or Allies ~= nil ) and abilityTP:IsFullyCastable() then
			npcBot:Action_UseAbility( abilityTP );
			return;
		end
		
		if ( Creeps ~= nil and #Creeps >= 3 )  and abilityTP:IsFullyCastable() then
			npcBot:Action_UseAbility( abilityTP );
			return;
		end
	end
end
end




function FindSuroundedEnemy()
	local enemyheroes = GetUnitList(UNIT_LIST_ENEMY_HEROES );
	local Enemies2 = hMinionUnit:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
	local Allies2 = hMinionUnit:GetNearbyHeroes(2*nRadius, false, BOT_MODE_ATTACK);
	for _,enemy in pairs(enemyheroes)
	do
		local allyNearby = enemy:GetNearbyHeroes(1200, false, BOT_MODE_ATTACK);
		if allyNearby ~= nil and #allyNearby >= 2 and Allies2 ~= nil and #Allies2 >= #Enemies2 then
			return enemy;
		end
	end
	return nil;
end


function FindTarget()
	
	local target  = nil;
	
	target = hMinionUnit:GetTarget();
	
	if IsValidTarget(target) then
		return target;	
	end
	
	target = FindLowHPTarget();
	
	if IsValidTarget(target) then
		return target;
	end
	
	target = FindSuroundedEnemy();
	
	if IsValidTarget(target) then
		return target;
	end
	
	
	return target;
	
end

function IsValidTarget(target)
	return  target ~= nil 
			and target:IsAlive() 
			and target:CanBeSeen() 
			and target:IsHero() 
			and not target:IsIllusion() 
			and GetUnitToUnitDistance(target, hMinionUnit) <= 400
end

function FindLowHPTarget(nRadius)
	local enemyheroes = GetUnitList(UNIT_LIST_ENEMY_HEROES );
	
	for _,enemy in pairs(enemyheroes)
	do
		if enemy:GetHealth() < 100 + ( enemy:GetLevel() * 10 ) and GetUnitToUnitDistance (enemy,hMinionUnit) < nRadius then
			return enemy;
		end
	end
	return nil;
end