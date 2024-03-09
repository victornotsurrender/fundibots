local X = {}
local bot = GetBot();
local team =  GetTeam();
local CStackTime = {55,55,55,55,55,54,55,55,55,55,55,55,55,55,55,55,55,55}
-- local CStackLoc = {
	-- Vector(1854.000000, -4469.000000, 0.000000), 
	-- Vector(1249.000000, -2416.000000, 0.000000),
	-- Vector(3471.000000, -5841.000000, 0.000000),
	-- Vector(5153.000000, -3620.000000, 0.000000),
	-- Vector(-1846.000000, -2996.000000, 0.000000),
	-- Vector(-4961.000000, 559.000000, 0.000000),
	-- Vector(-3873.000000, -833.000000, 0.000000),
	-- Vector(-3146.000000, 702.000000, 0.000000),
	-- Vector(1141.000000, -3111.000000, 0.000000),
	-- Vector(660.000000, 2300.000000, 0.000000),
	-- Vector(3666.000000, 1836.000000, 0.000000),
	-- Vector(482.000000, 4723.000000, 0.000000),
	-- Vector(3173.000000, -861.000000, 0.000000),
	-- Vector(-3443.000000, 6098.000000, 0.000000),
	-- Vector(-4353.000000, 4842.000000, 0.000000),
	-- Vector(-1083.000000, 3385.000000, 0.000000),
	-- Vector(-922.000000, 4299.000000, 0.000000),
	-- Vector(4136.000000, -1753.000000, 0.000000)
-- }

local CStackLoc = {
	Vector(1254.000000, -4669.000000, 0.000000), --
	Vector(1649.000000, -2416.000000, 0.000000), --
	Vector(3471.000000, -6141.000000, 0.000000), --
	Vector(5953.000000, -4220.000000, 0.000000), --
	Vector(-1846.000000, -2996.000000, 0.000000), --
	Vector(-5961.000000, 559.000000, 0.000000), --
	Vector(-3873.000000, -833.000000, 0.000000), --
	Vector(-2546.000000, 702.000000, 0.000000), --
	Vector(1141.000000, -3611.000000, 0.000000), --
	Vector(660.000000, 2300.000000, 0.000000), --
	Vector(3666.000000, 1836.000000, 0.000000), --
	Vector(482.000000, 4723.000000, 0.000000), -- 
	Vector(2973.000000, -100.000000, 0.000000), --
	Vector(-3043.000000, 6098.000000, 0.000000), --
	Vector(-5953.000000, 3342.000000, 0.000000), --
	Vector(-583.000000, 2585.000000, 0.000000), --
	Vector(-222.000000, 4699.000000, 0.000000), --
	Vector(4136.000000, -1753.000000, 0.000000)
}


--test hero
local jungler = {
	'npc_dota_hero_alchemist',
	'npc_dota_hero_bloodseeker',
	--'npc_dota_hero_legion_commander',
	--'npc_dota_hero_life_stealer'
	--'npc_dota_hero_skeleton_king',
	--'npc_dota_hero_ursa'
}

------------------------------ My Scripts


--test hero
local jungler1 = {
	
	-- 'npc_dota_hero_bloodseeker',	
	'npc_dota_hero_legion_commander',
	'npc_dota_hero_life_stealer',
	'npc_dota_hero_skeleton_king'
	-- 'npc_dota_hero_alchemist',
	-- 'npc_dota_hero_pudge',
	--'npc_dota_hero_ursa'
	
}

--test hero
local jungler2 = {
	'npc_dota_hero_alchemist',	
	'npc_dota_hero_ursa',
	'npc_dota_hero_lone_druid',
	'npc_dota_hero_shredder',
	'npc_dota_hero_furion',
	'npc_dota_hero_terrorblade',
	'npc_dota_hero_axe',
	'npc_dota_hero_broodmother',	
	'npc_dota_hero_treant',
	'npc_dota_hero_naga_siren',
	'npc_dota_hero_venomancer'
	
	-- 'npc_dota_hero_keeper_of_the_light',
	-- 'npc_dota_hero_bloodseeker',
	-- 'npc_dota_hero_legion_commander',
	-- 'npc_dota_hero_life_stealer',
	-- 'npc_dota_hero_skeleton_king',
	
}


local jungler3 = {
	'npc_dota_hero_snapfire',
	'npc_dota_hero_void_spirit',
	'npc_dota_hero_mars',
	'npc_dota_hero_pangolier',
	'npc_dota_hero_dark_willow',
	'npc_dota_hero_ember_spirit',
	'npc_dota_hero_earth_spirit',
	'npc_dota_hero_phoenix',
	-- 'npc_dota_hero_terrorblade',
	'npc_dota_hero_morphling',
	-- 'npc_dota_hero_shredder',
	-- 'npc_dota_hero_broodmother',
	'npc_dota_hero_antimage',
	'npc_dota_hero_dark_seer',
	'npc_dota_hero_weaver',
	'npc_dota_hero_obsidian_destroyer',
	'npc_dota_hero_batrider',
	-- 'npc_dota_hero_lone_druid',
    'npc_dota_hero_wisp',
    'npc_dota_hero_chen',
	'npc_dota_hero_troll_warlord',
	-- 'npc_dota_hero_alchemist',
	'npc_dota_hero_tinker',
	-- 'npc_dota_hero_furion',
	'npc_dota_hero_templar_assassin',
	'npc_dota_hero_rubick',
	'npc_dota_hero_keeper_of_the_light',
	'npc_dota_hero_ancient_apparition',
	'npc_dota_hero_mirana',
	'npc_dota_hero_medusa',
	'npc_dota_hero_spectre',
	'npc_dota_hero_enigma',
	'npc_dota_hero_visage',
	'npc_dota_hero_riki',
	'npc_dota_hero_lycan',
	'npc_dota_hero_clinkz',
	'npc_dota_hero_techies',
	'npc_dota_hero_winter_wyvern',
	'npc_dota_hero_pugna',
	'npc_dota_hero_queenofpain',
	'npc_dota_hero_silencer',
	'npc_dota_hero_leshrac',
	'npc_dota_hero_enchantress',
	'npc_dota_hero_nyx_assassin',
	'npc_dota_hero_storm_spirit',
	'npc_dota_hero_abaddon',
	'npc_dota_hero_abyssal_underlord',
	'npc_dota_hero_arc_warden',
	'npc_dota_hero_spirit_breaker',
        -- 'npc_dota_hero_axe',
        'npc_dota_hero_bane',
	'npc_dota_hero_beastmaster',
        -- 'npc_dota_hero_bloodseeker',
        'npc_dota_hero_bounty_hunter',
	'npc_dota_hero_brewmaster',
        'npc_dota_hero_bristleback',
	'npc_dota_hero_centaur',
        'npc_dota_hero_chaos_knight',
        'npc_dota_hero_crystal_maiden',
        'npc_dota_hero_dazzle',
        'npc_dota_hero_death_prophet',
	'npc_dota_hero_disruptor',
	'npc_dota_hero_doom_bringer',
        'npc_dota_hero_dragon_knight',
        'npc_dota_hero_drow_ranger',
        'npc_dota_hero_earthshaker',
	'npc_dota_hero_elder_titan',
	'npc_dota_hero_faceless_void',
	'npc_dota_hero_grimstroke',
	'npc_dota_hero_gyrocopter',
	'npc_dota_hero_huskar',
    'npc_dota_hero_invoker',
        'npc_dota_hero_jakiro',
        'npc_dota_hero_juggernaut',
        'npc_dota_hero_kunkka',
	-- 'npc_dota_hero_legion_commander',
        'npc_dota_hero_lich',
	-- 'npc_dota_hero_life_stealer',
        'npc_dota_hero_lina',
        'npc_dota_hero_lion',
        'npc_dota_hero_luna',
	'npc_dota_hero_magnataur',
    'npc_dota_hero_meepo',
	'npc_dota_hero_monkey_king',
	-- 'npc_dota_hero_naga_siren',
        'npc_dota_hero_necrolyte',
        'npc_dota_hero_nevermore',
	'npc_dota_hero_night_stalker',
	'npc_dota_hero_ogre_magi',
        'npc_dota_hero_omniknight',
        'npc_dota_hero_oracle',
        'npc_dota_hero_phantom_assassin',
	'npc_dota_hero_phantom_lancer',
    'npc_dota_hero_puck',
        -- 'npc_dota_hero_pudge',
    'npc_dota_hero_rattletrap',
        'npc_dota_hero_razor',
        'npc_dota_hero_sand_king',
	'npc_dota_hero_shadow_demon',
	'npc_dota_hero_shadow_shaman',
        -- 'npc_dota_hero_skeleton_king',
        'npc_dota_hero_skywrath_mage',
	'npc_dota_hero_slardar',
	'npc_dota_hero_slark',
        'npc_dota_hero_sniper',
        'npc_dota_hero_sven',
        'npc_dota_hero_tidehunter',
        'npc_dota_hero_tiny',
	-- 'npc_dota_hero_treant',
	'npc_dota_hero_tusk',
	'npc_dota_hero_undying',
	-- 'npc_dota_hero_ursa',
        'npc_dota_hero_vengefulspirit',
	-- 'npc_dota_hero_venomancer',
        'npc_dota_hero_viper',
        'npc_dota_hero_warlock',
        'npc_dota_hero_windrunner',
        'npc_dota_hero_witch_doctor',
        'npc_dota_hero_zuus'
}





function X.IsStrongJungler1(bot)
	local name = bot:GetUnitName();
	for _,n in pairs(jungler1)
	do
		if name == n then
			return true;
		end
	end	
	return false;
end



function X.IsStrongJungler2(bot)
	local name = bot:GetUnitName();
	for _,n in pairs(jungler2)
	do
		if name == n then
			return true;
		end
	end	
	return false;
end



function X.IsStrongJungler3(bot)
	local name = bot:GetUnitName();
	for _,n in pairs(jungler3)
	do
		if name == n then
			return true;
		end
	end	
	return false;
end


-- function X.FindFarmedTarget(Creeps)
	-- local minHP = 10000;
	-- local target = nil;
	-- local Creeps = bot:GetNearbyLaneCreeps(1600, true);
	-- for _,creep in pairs(Creeps)
	-- do
		-- local hp = creep:GetHealth(); 
		-- --if team == TEAM_DIRE then print(tostring(creep:CanBeSeen())) end
		-- if creep ~= nil 
		-- and not creep:IsNull() 
		-- and creep:IsAlive() 
		-- and hp < minHP
		-- and creep:CanBeSeen()
		-- then
			-- minHP = hp;
			-- target = creep;
		-- end
	-- end
	-- return target
-- end


function X.FindFarmedTarget2(Creeps)
	local minHP = 10000;
	local target = nil;
	local Creeps = bot:GetNearbyCreeps(1600,true);
	for _,creep in pairs(Creeps)
	do
		local hp = creep:GetHealth(); 
		--if team == TEAM_DIRE then print(tostring(creep:CanBeSeen())) end
		if creep ~= nil and not creep:IsNull() and creep:IsAlive() and hp < minHP  then
			minHP = hp;
			target = creep;
		end
	end
	return target
end



function X.FindFarmedTarget3(enemyHero)
	local minHP = 100000;
	local target = nil;
	local enemyHero =  bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for _,NpcEnemy in pairs(enemyHero)
	do
		local hp = NpcEnemy:GetHealth(); 
		--if team == TEAM_DIRE then print(tostring(creep:CanBeSeen())) end
		if NpcEnemy ~= nil and not NpcEnemy:IsNull() and NpcEnemy:IsAlive() and NpcEnemy:IsHero() and hp < minHP  then
			minHP = hp;
			target = NpcEnemy;
		end
	end
	return target
end


--------------------------------



function X.GetCampMoveToStack(id)
	return CStackLoc[id]
end

function X.GetCampStackTime(camp)
	if camp.cattr.speed == "fast" then
		return 55;
	elseif camp.cattr.speed == "slow" then
		return 54;
	else
		return 55;
	end
end

function X.IsEnemyCamp(camp)
	return camp.team ~= GetTeam();
end

function X.IsAncientCamp(camp)
	return camp.type == "ancient";
end

function X.IsSmallCamp(camp)
	return camp.type == "small";
end

function X.IsMediumCamp(camp)
	return camp.type == "medium";
end

function X.IsLargeCamp(camp)
	return camp.type == "large";
end

function X.RefreshCamp(bot)
	local camps = GetNeutralSpawners();
	local AllCamps = {};
	for k,camp in pairs(camps) do
		if bot:GetLevel() <= 6 then
			if not X.IsEnemyCamp(camp) 
			and not X.IsLargeCamp(camp) 
			and not X.IsAncientCamp(camp)
			then
				table.insert(AllCamps, {idx=k, cattr=camp});
			end
		elseif bot:GetLevel() <= 12 then
			if not X.IsEnemyCamp(camp) and not X.IsAncientCamp(camp)
			then
				table.insert(AllCamps, {idx=k, cattr=camp});
			end
		else
			table.insert(AllCamps, {idx=k, cattr=camp});
		end
	end
	local nCamps = #AllCamps;
	return AllCamps, nCamps;
end

function X.IsStrongJungler(bot)
	local name = bot:GetUnitName();
	for _,n in pairs(jungler)
	do
		if name == n then
			return true;
		end
	end	
	return false;
end

function X.PrintCamps()
	print("========CAMPS==========")
	local camps = GetNeutralSpawners();
	for i=1, #camps do
		print("==============")
		for k,v in pairs(camps[i]) do
			print(tostring(k)..":"..tostring(v))
		end
	end
end

function X.PingCamp(nCamp, nPId, nTeam, bot)
	if bot:GetTeam() == nTeam and bot:GetPlayerID() == nPId then
		local camps = GetNeutralSpawners();
		for i=1, #camps do
			if i == nCamp then
				local cLoc = camps[i].location;
				bot:ActionImmediate_Ping( cLoc.x, cLoc.y, true );	
			end
		end
	end
end

function X.GetClosestNeutralSpwan(bot, AvailableCamp)
	-- local minDist = 10000;
	local minDist = 4500;
	local pCamp = nil;
	for _,camp in pairs(AvailableCamp)
	do
	   local dist = GetUnitToLocationDistance(bot, camp.cattr.location);
	   if X.IsTheClosestOne(bot, dist, camp.cattr.location) and dist < minDist then
			minDist = dist;
			pCamp = camp;
	   end
	end
	return pCamp
end

function X.IsTheClosestOne(bot, bDis, loc)
	local dis = bDis;
	local closest = bot;
	for k,v in pairs(GetTeamPlayers(GetTeam()))
	do	
		local member = GetTeamMember(k);
		if  member ~= nil and not member:IsIllusion() and member:IsAlive() and member:GetActiveMode() == BOT_MODE_FARM then
			local dist = GetUnitToLocationDistance(member, loc);
			if dist < dis then
				dis = dist;
				closest = member;
			end
		end
	end
	return closest:GetUnitName() == bot:GetUnitName();
end

function X.FindFarmedTarget(Creeps)
	local minHP = 10000;
	local target = nil;
	for _,creep in pairs(Creeps)
	do
		local hp = creep:GetHealth(); 
		--if team == TEAM_DIRE then print(tostring(creep:CanBeSeen())) end
		if creep ~= nil 
		and not creep:IsNull()
		and creep:IsAlive() 
		and hp < minHP 
		and creep:CanBeSeen() 
		and not creep:IsBuilding()
		and GetUnitToUnitDistance(bot,creep) <= bot:GetAttackRange() + 200
		then
			minHP = hp;
			target = creep;
		end
	end
	return target
end

function X.IsSuitableToFarm(bot)
	local mode = bot:GetActiveMode();
	if mode == BOT_MODE_RUNE
	   or mode == BOT_MODE_DEFEND_TOWER_TOP
	   or mode == BOT_MODE_DEFEND_TOWER_MID
	   or mode == BOT_MODE_DEFEND_TOWER_BOT
	   or mode == BOT_MODE_ATTACK
	   or mode == BOT_MODE_WARD
	   or mode == BOT_MODE_DEFEND_ALLY
	then
		return false;
	end
	return true;
end

function X.UpdateAvailableCamp(bot, preferedCamp, AvailableCamp)
	if preferedCamp ~= nil then
		for i = 1, #AvailableCamp
		do
			if AvailableCamp[i].cattr.location == preferedCamp.cattr.location or GetUnitToLocationDistance(bot,  AvailableCamp[i].cattr.location) < 300 then
				table.remove(AvailableCamp, i);
				--print("Updating available camp : "..tostring(#AvailableCamp))
				preferedCamp = nil;	
				return AvailableCamp, preferedCamp;
			end
		end
	end
end


return X

--[[
RADIANT CAMP
[VScript] ==============
[VScript] max:Vector 00000000006D9B60 [1112.000000 -4128.000000 512.000061]
[VScript] team:2
[VScript] location:Vector 00000000006D99C8 [384.000000 -4672.000000 519.999939]
[VScript] type:medium
[VScript] min:Vector 00000000006D99F8 [178.999939 -5093.500000 -384.000000]
[VScript] speed:fast
[VScript] ==============
[VScript] max:Vector 00000000006D9D00 [515.999939 -1593.750000 704.000000]
[VScript] team:2
[VScript] location:Vector 00000000006D9BD8 [69.066162 -1851.600098 392.000000]
[VScript] type:medium
[VScript] min:Vector 00000000006D9C08 [-200.000000 -2287.999756 280.500000]
[VScript] speed:fast
[VScript] ==============
[VScript] max:Vector 00000000006D9E80 [3696.000000 -4032.000000 608.000000]
[VScript] team:2
[VScript] location:Vector 00000000006D9D58 [2937.953857 -4557.562012 263.999878]
[VScript] type:small
[VScript] min:Vector 00000000006D9D88 [2784.000000 -4912.000000 -384.000000]
[VScript] speed:normal
[VScript] ==============
[VScript] max:Vector 00000000006DA030 [4768.000000 -4032.000000 800.000000]
[VScript] team:2
[VScript] location:Vector 00000000006D9F08 [4507.048828 -4425.680664 263.999878]
[VScript] type:large
[VScript] min:Vector 00000000006D9F38 [3956.000000 -4736.000000 -384.000000]
[VScript] speed:normal
[VScript] ==============
[VScript] max:Vector 0000000000675730 [-1472.000000 -3808.000000 608.000061]
[VScript] team:2
[VScript] location:Vector 00000000006DA088 [-1848.000000 -4216.000000 263.999878]
[VScript] type:large
[VScript] min:Vector 00000000006DA0B8 [-2224.000000 -4640.000000 -384.000000]
[VScript] speed:fast
[VScript] ==============
[VScript] max:Vector 00000000006758D8 [-3474.999756 1088.000000 528.000061]
[VScript] team:2
[VScript] location:Vector 00000000006757B0 [-3722.178223 872.843018 391.999878]
[VScript] type:medium
[VScript] min:Vector 00000000006757E0 [-4160.000000 192.000000 -383.999817]
[VScript] speed:normal
[VScript] ==============
[VScript] max:Vector 0000000000675A58 [-4288.000000 104.000031 1096.000000]
[VScript] team:2
[VScript] location:Vector 0000000000675930 [-4966.994141 -380.421631 391.999878]
[VScript] type:large
[VScript] min:Vector 0000000000675960 [-5165.500000 -640.000000 112.500000]
[VScript] speed:fast
[VScript] ==============
[VScript] max:Vector 0000000000675BD8 [-2464.750488 -198.250000 592.000000]
[VScript] team:2
[VScript] location:Vector 0000000000675AB0 [-2544.000000 -560.000000 393.000000]
[VScript] type:ancient
[VScript] min:Vector 0000000000675AE0 [-3368.000000 -1024.000000 -384.000000]
[VScript] speed:normal
[VScript] ==============
[VScript] max:Vector 0000000000675D58 [265.249939 -3032.500000 639.999939]
[VScript] team:2
[VScript] location:Vector 0000000000675C30 [-247.370605 -3299.183594 391.999878]
[VScript] type:ancient
[VScript] min:Vector 0000000000675C60 [-617.249939 -3767.500000 -384.000000]
[VScript] speed:fast
DIRE CAMP
[VScript] ==============
[VScript] max:Vector 000000000040B3F8 [-288.000000 2752.000000 896.000000]
[VScript] team:3
[VScript] location:Vector 0000000000675E40 [-948.000000 2268.500000 391.999756]
[VScript] type:medium
[VScript] min:Vector 0000000000675E70 [-1034.875000 1967.999878 383.999756]
[VScript] speed:normal
[VScript] ==============
[VScript] max:Vector 000000000040B578 [4738.593750 1088.000000 944.000000]
[VScript] team:3
[VScript] location:Vector 000000000040B450 [4452.000000 840.000000 391.999878]
[VScript] type:large
[VScript] min:Vector 000000000040B480 [4016.000000 511.999878 384.000000]
[VScript] speed:fast
[VScript] ==============
[VScript] max:Vector 000000000040B6F8 [1592.250000 3827.750000 792.000000]
[VScript] team:3
[VScript] location:Vector 000000000040B5D0 [1346.833252 3289.285156 391.999878]
[VScript] type:large
[VScript] min:Vector 000000000040B600 [615.749939 3036.250000 -384.000000]
[VScript] speed:normal
[VScript] ==============
[VScript] max:Vector 000000000040B878 [3040.000000 424.000000 448.000000]
[VScript] team:3
[VScript] location:Vector 000000000040B750 [2548.799561 92.937256 391.999878]
[VScript] type:medium
[VScript] min:Vector 000000000040B780 [2320.000000 -160.000000 -384.000122]
[VScript] speed:normal
[VScript] ==============
[VScript] max:Vector 000000000040B9F8 [-2142.000000 5193.812500 512.000061]
[VScript] team:3
[VScript] location:Vector 000000000040B8D0 [-2464.000000 4816.000000 298.862183]
[VScript] type:small
[VScript] min:Vector 000000000040B900 [-3138.000000 4374.187500 -384.000000]
[VScript] speed:slow
[VScript] ==============
[VScript] max:Vector 000000000040BB78 [-3920.000000 3946.000000 384.500061]
[VScript] team:3
[VScript] location:Vector 000000000040BA50 [-4235.449219 3424.000000 307.733032]
[VScript] type:large
[VScript] min:Vector 000000000040BA80 [-4748.750000 3254.000000 -384.000000]
[VScript] speed:normal
[VScript] ==============
[VScript] max:Vector 00000000003EA830 [-1392.000000 4665.500000 540.500061]
[VScript] team:3
[VScript] location:Vector 00000000003EA708 [-1864.476807 4431.666504 391.999939]
[VScript] type:medium
[VScript] min:Vector 00000000003EA738 [-2120.000000 4031.999512 77.000061]
[VScript] speed:fast
[VScript] ==============
[VScript] max:Vector 00000000003EA9B0 [113.500061 3760.000000 735.000000]
[VScript] team:3
[VScript] location:Vector 00000000003EA888 [-132.500000 3355.500000 393.000000]
[VScript] type:ancient
[VScript] min:Vector 00000000003EA8B8 [-752.000000 3112.000000 -384.000000]
[VScript] speed:normal
[VScript] ==============
[VScript] max:Vector 00000000003DA990 [4512.000000 -36.000000 400.000000]
[VScript] team:3
[VScript] location:Vector 00000000003EAB18 [4195.220703 -363.070129 440.971680]
[VScript] type:ancient
[VScript] min:Vector 00000000003EAB48 [3464.000000 -752.000000 -384.000000]
[VScript] speed:normal
]]--