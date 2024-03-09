local X = {}

local visionRad = 800;

---RADIANT WARDING SPOT
local RADIANT_T3TOPFALL = Vector(-6600.000000, -3072.000000, 0.000000);  --- OK
local RADIANT_T3MIDFALL = Vector(-4314.000000, -3887.000000, 0.000000);  --- OK
local RADIANT_T3BOTFALL = Vector(-3586.000000, -6131.000000, 0.000000);  --- OK

local RADIANT_T2TOPFALL = Vector(-4349.000000, -1022.000000, 0.000000);
-- local RADIANT_T2MIDFALL = Vector(-1779.000000, -4861.000000, 0.000000); --- Original No works in 7.29b
local RADIANT_T2MIDFALL = Vector(-518.000000,-3330.000000, 0.000000);  --- OK
-- local RADIANT_T2BOTFALL = Vector(1031.000000, -4101.000000, 0.000000); --- Original No works in 7.29b
local RADIANT_T2BOTFALL = Vector(1275.000000, -5128.000000, 0.000000); --- OK

-- local RADIANT_T1TOPFALL = Vector(-5369.000000, 2303.000000, 0.000000); --- Original No works in 7.29b
local RADIANT_T1TOPFALL = Vector(-4109.000000, 1513.000000, 0.000000); --- OK
-- local RADIANT_T1MIDFALL = Vector(766.000000, -2304.000000, 0.000000);  --- Original No works in 7.29b
local RADIANT_T1MIDFALL = Vector(500.000000, -1750.000000, 0.000000); --- OK
local RADIANT_T1BOTFALL = Vector(5030.000000, -3705.000000, 0.000000); --- OK

local RADIANT_MANDATE1 = Vector(-1571.000000, 215.000000, 0.000000); --- OK
local RADIANT_MANDATE2 = Vector(2800.000000, -3095.000000, 0.000000); --- OK

local RADIANT_AGGRESSIVETOP  = Vector(-1302.000000, 4828.000000, 0.000000);  --- OK
local RADIANT_AGGRESSIVEMID1 = Vector(735.000000, 2689.000000, 0.000000);  --- OK
local RADIANT_AGGRESSIVEMID2 = Vector(3222.000000, -68.000000, 0.000000); --- OK
local RADIANT_AGGRESSIVEBOT  = Vector(4612.000000, 746.000000, 0.000000); --- OK



-- local RADIANT_DEFENSIVE1 = Vector(2865.000000, -2785.000000, 0.000000);	--  RADIANT_T1MIDFALL Ok para observer junto al río
-- local RADIANT_DEFENSIVE2 = Vector(1031.000000, -4101.000000, 0.000000); --RADIANT_TORRE2BOTFALL  Ok para observer medio del bosque
-- local RADIANT_DEFENSIVE3 = Vector(-3441.000000, -1583.000000, 0.000000);   --- DIRE_AGGRESSIVEMID1 --Escalera para defender TOWER_MID_2 RADIANT
-- local RADIANT_DEFENSIVE4  = Vector(-5516.000000, 3804.000000, 0.000000); -- TOWER_TOP_1 RADIANT entrando al bosque Ok 
-- local RADIANT_DEFENSIVE5 = Vector(-5369.000000, 2303.000000, 0.000000);    --Ok TOWER_TOP_1 RADIANT arriba
-- local RADIANT_DEFENSIVE6 = Vector(5030.000000, -3705.000000, 0.000000);   --RADIANT_T1BOTFALL Ok entrando al bosque BOT RADIANT  
-- local RADIANT_DEFENSIVE7 = Vector(-3516.000000, 3504.000000, 0.000000);  --Super Good RADIANT entrando al bosque Top por el río
-- local RADIANT_DEFENSIVE8 = Vector(-752.000000, 3253.000000, 0.000000); --Super Ok AggressiveRadiant Midtorre#1
-- local RADIANT_DEFENSIVE9 = Vector(4865.000000, -2300.000000, 0.000000);  -- Dire TOWER_BOT_1 Fall
-- local RADIANT_DEFENSIVE10 = Vector(3954.851563, -3651.810059, 256.000000);   --- Medio del Bosque BOT RADIANT
-- local RADIANT_DEFENSIVE11 = Vector(4199.194824, -5229.214844, 256.000000);  --Good Defense TOWER_BOT_1 RADIANT














---DIRE WARDING SPOT
local DIRE_T3TOPFALL = Vector(3087.000000, 5690.000000, 0.000000); --- OK
local DIRE_T3MIDFALL = Vector(4024.000000, 3445.000000, 0.000000); --- OK
local DIRE_T3BOTFALL = Vector(6354.000000, 2606.000000, 0.000000); --- OK

-- local DIRE_T2TOPFALL = Vector(1024.000000, 4863.000000, 0.000000); --- Original No works in 7.29b
local DIRE_T2TOPFALL = Vector(515.000000, 4100.000000, 0.000000); --- OK
local DIRE_T2MIDFALL = Vector(756.000000, 2647.000000, 0.000000); --- OK
local DIRE_T2BOTFALL = Vector(4612.000000, 746.000000, 0.000000); --- OK

local DIRE_T1TOPFALL = Vector(-3830.000000, 4412.000000, 0.000000); --- OK
local DIRE_T1MIDFALL = Vector(624.000000, -373.000000, 0.000000); --- OK
-- local DIRE_T1BOTFALL = Vector(4865.000000, -2300.000000, 0.000000); --- Original No works in 7.29b
local DIRE_T1BOTFALL = Vector(4565.000000, -1900.000000, 0.000000);

local DIRE_MANDATE1 = Vector(-754.000000, 2053.000000, 0.000000); --- OK
local DIRE_MANDATE2 = Vector(2598.000000, -1510.000000, 0.000000); --- OK

local DIRE_AGGRESSIVETOP  = Vector(-4579.000000, 481.000000, 0.000000); --- OK
local DIRE_AGGRESSIVEMID1 = Vector(-3441.000000, -1583.000000, 0.000000); --- OK
local DIRE_AGGRESSIVEMID2 = Vector(-889.000000, -3998.000000, 0.000000);  --- OK
local DIRE_AGGRESSIVEBOT  = Vector(1275.000000, -5128.000000, 0.000000); --- OK




-- local DIRE_DEFENSIVE1 = Vector(624.000000, -373.000000, 0.000000);    -- DIRE_T1MIDFALL
-- local DIRE_DEFENSIVE2 = Vector(2044.000000, -766.000000, 0.000000);  -- Old Version Ok arriba buena posición para observer 
-- local DIRE_DEFENSIVE4  = Vector(3222.000000, -68.000000, 0.000000); -- RADIANT_AGGRESSIVEMID2 Ok medio bosque DIRE
-- local DIRE_DEFENSIVE5 = Vector(-5284.000000, 4650.000000, 0.000000);  -- Ok Dire Defense TOWER_TOP_1
-- local DIRE_DEFENSIVE6 = Vector(-3523.000000, 3400.000000, 0.000000);  -- ENtrando al bosque DIRE TOP por la runa 
-- local DIRE_DEFENSIVE7 = Vector(756.000000, 2647.000000, 0.000000); -- Cuidando Escalera TOWER_MID_2 DIRE Defense
-- local DIRE_DEFENSIVE8 = Vector(3954.000000, -3651.000000, 0.000000);   --- Medio del Bosque BOT RADIANT
-- local DIRE_DEFENSIVE9 = Vector(1031.000000, -4101.000000, 0.000000); --RADIANT_TORRE2BOTFALL  Ok para observer medio del bosque
-- local DIRE_DEFENSIVE10 = Vector(4865.000000, -2300.000000, 0.000000);
-- -- local DIRE_DEFENSIVE11 = Vector(-2823.000000, -2300.000000, 0.000000);




local Towers = {
	TOWER_TOP_1,
	TOWER_MID_1,
	TOWER_BOT_1,
	TOWER_TOP_2,
	TOWER_MID_2,
	TOWER_BOT_2,
	TOWER_TOP_3,
	TOWER_MID_3,
	TOWER_BOT_3
}



local WardSpotTowerFallRadiant = {
	RADIANT_T1TOPFALL,
	RADIANT_T1MIDFALL,
	RADIANT_T1BOTFALL,
	RADIANT_T2TOPFALL,
	RADIANT_T2MIDFALL,
	RADIANT_T2BOTFALL,
	RADIANT_T3TOPFALL,
	RADIANT_T3MIDFALL,
	RADIANT_T3BOTFALL
}	

local WardSpotTowerFallDire = {
	DIRE_T1TOPFALL,
	DIRE_T1MIDFALL,
	DIRE_T1BOTFALL,
	DIRE_T2TOPFALL,
	DIRE_T2MIDFALL,
	DIRE_T2BOTFALL,
	DIRE_T3TOPFALL,
	DIRE_T3MIDFALL,
	DIRE_T3BOTFALL
}

function X.GetDistance(s, t)
    --print("S1: "..s[1]..", S2: "..s[2].." :: T1: "..t[1]..", T2: "..t[2]);
    return math.sqrt((s[1]-t[1])*(s[1]-t[1]) + (s[2]-t[2])*(s[2]-t[2]));
end

function X.GetMandatorySpot()
	local MandatorySpotRadiant = {
		RADIANT_MANDATE1,
		RADIANT_MANDATE2
	}

	local MandatorySpotDire = {
		DIRE_MANDATE1,
		DIRE_MANDATE2
	}
	if GetTeam() == TEAM_RADIANT then
		return MandatorySpotRadiant;
	else
		return MandatorySpotDire
	end	
end

function X.GetWardSpotWhenTowerFall()
	local wardSpot = {};
	for i = 1, #Towers
	do
		local t = GetTower(GetTeam(),  Towers[i]);
		if t == nil then
			if GetTeam() == TEAM_RADIANT then
				table.insert(wardSpot, WardSpotTowerFallRadiant[i]);
			else
				table.insert(wardSpot, WardSpotTowerFallDire[i]);
			end
		end
	end
	
	for _,tower in pairs( Towers )
	do
		local t = GetTower(GetTeam(),  tower);
		if t ~= nil 
			and t:GetHealth() < 500 
			and not t:IsNull() 
			and t:IsAlive() 
			and t:IsBuilding()
			then
			if GetTeam() == TEAM_RADIANT then
				table.insert(wardSpot, WardSpotTowerFallRadiant[i]);
			else
				table.insert(wardSpot, WardSpotTowerFallDire[i]);
			end
		end
	end
	
	return wardSpot;
end

function X.GetAggressiveSpot()
	local AggressiveDire = {
		DIRE_AGGRESSIVETOP,
		DIRE_AGGRESSIVEMID1,
		DIRE_AGGRESSIVEMID2,
		DIRE_AGGRESSIVEBOT
	}

	local AggressiveRadiant = {
		RADIANT_AGGRESSIVETOP,
		RADIANT_AGGRESSIVEMID1,
		RADIANT_AGGRESSIVEMID2,
		RADIANT_AGGRESSIVEBOT
	}
	if GetTeam() == TEAM_RADIANT then
		return AggressiveRadiant;
	else
		return AggressiveDire
	end	
end

function X.GetItemWard(bot)
	for i = 0,8 do
		local item = bot:GetItemInSlot(i);
		if item ~= nil
		and ( item:GetName() == 'item_ward_observer' or item:GetName() == 'item_ward_sentry' or item:GetName() == 'item_ward_dispenser'   )
		-- and not item:IsNull()
		then
			return item;
		end
	end
	return nil;
end

function X.IsPingedByHumanPlayer(bot)
	local TeamPlayers = GetTeamPlayers(GetTeam());
	for i,id in pairs(TeamPlayers)
	do
		if not IsPlayerBot(id) then
			local member = GetTeamMember(i);
			if member ~= nil and member:IsAlive() and GetUnitToUnitDistance(bot, member) <= 1000 then
				local ping = member:GetMostRecentPing();
				local Wslot = (member:FindItemSlot('item_ward_observer') or  member:FindItemSlot('item_ward_dispenser')   or member:FindItemSlot('item_ward_sentry'));
				if GetUnitToLocationDistance(bot, ping.location) <= 600 and 
				   GameTime() - ping.time < 5 and 
				   Wslot == -1
				then
					return true, member;
				end	
			end
		end
	end
	return false, nil;
end

function X.GetAvailableSpot(bot)
	local temp = {};
	for _,s in pairs(X.GetMandatorySpot()) do
		if not X.CloseToAvailableWard(s) then
			table.insert(temp, s);
		end
	end
	for _,s in pairs(X.GetWardSpotWhenTowerFall()) do
		if not X.CloseToAvailableWard(s) then
			table.insert(temp, s);
		end
	end
	if DotaTime() > 5*60 then
		for _,s in pairs(X.GetAggressiveSpot()) do
			if GetUnitToLocationDistance(bot, s) <= 1200 and not X.CloseToAvailableWard(s) then
				table.insert(temp, s);
			end
		end
	end
	return temp;
end

function X.CloseToAvailableWard(wardLoc)
	local WardList = GetUnitList(UNIT_LIST_ALLIED_WARDS);
	for _,ward in pairs(WardList) do
		if X.IsObserver(ward) and GetUnitToLocationDistance(ward, wardLoc) <= visionRad then
			return true;
		end
	end
	return false;
end

function X.GetClosestSpot(bot, spots)
	local cDist = 100000;
	local cTarget = nil;
	for _, spot in pairs(spots) do
		local dist = GetUnitToLocationDistance(bot, spot);
		if dist < cDist then
			cDist = dist;
			cTarget = spot;
		end
	end
	return cTarget, cDist;
end

function X.IsObserver(wardUnit)
	return wardUnit:GetUnitName() == "npc_dota_observer_wards" or wardUnit:GetUnitName() == "npc_dota_sentry_wards" or wardUnit:GetUnitName() == "npc_dota_dispenser_wards" ;
end

function X.GetHumanPing()
	local teamIDs = GetTeamPlayers(GetTeam());
	for i,id in pairs(teamIDs)
	do
		local hUnit = GetTeamMember(i);
		if hUnit ~= nil and not hUnit:IsBot() then
			return hUnit:GetMostRecentPing();
		end
	end
	return nil;
end




function X.GetBotPing()
	local teamIDs = GetTeamPlayers(GetTeam());
	for i,id in pairs(teamIDs)
	do
		local hUnit = GetTeamMember(i);
		if hUnit ~= nil and hUnit:IsBot() then
			return hUnit:GetMostRecentPing();
		end
	end
	return nil;
end



return X