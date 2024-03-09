----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------

local Site = {}

local role = require( "bots/RoleUtility");

Site.nLaneList = {
					[1] = LANE_BOT,
					[2] = LANE_MID,
					[3] = LANE_TOP,
				 }


Site.nTowerList = {
					TOWER_TOP_1,
					TOWER_MID_1,
					TOWER_BOT_1,
					TOWER_TOP_2,
					TOWER_MID_2,
					TOWER_BOT_2,
					TOWER_TOP_3,
					TOWER_MID_3,
					TOWER_BOT_3,
					TOWER_BASE_1,
					TOWER_BASE_2,
				  }

local vRadiantTowerLocationList = {}
local vDireTowerLocationList = {}
for _, nTower in pairs( Site.nTowerList )
do
	vRadiantTowerLocationList[nTower] = GetTower( TEAM_RADIANT, nTower ):GetLocation()
	vDireTowerLocationList[nTower] = GetTower( TEAM_DIRE, nTower ):GetLocation()
end

local nWatchTower_1 = nil
local nWatchTower_2 = nil
local allUnitList = GetUnitList( UNIT_LIST_ALL )
for _, v in pairs( allUnitList )
do
	if v:GetUnitName() == '#DOTA_OutpostName_North'
		or v:GetUnitName() == '#DOTA_OutpostName_South'
	then
		if nWatchTower_1 == nil
		then
			nWatchTower_1 = v
		else
			nWatchTower_2 = v
		end
	end
end

Site.nWatchTowerList = {
	nWatchTower_1,
	nWatchTower_2,
}

Site.nRuneList = {
				RUNE_POWERUP_1, --上
				RUNE_POWERUP_2, --下
				RUNE_BOUNTY_1, 	--天辉上  --天辉神秘符
				RUNE_BOUNTY_2, 	--夜魇下  --天辉优势路符
--				RUNE_BOUNTY_3, 	--天辉下 --夜魇神秘符
--				RUNE_BOUNTY_4, 	--夜魇上 --夜魇优势路符
}

Site.nShopList = {
				SHOP_HOME, --家里商店
				SHOP_SIDE, --天辉下路商店
				SHOP_SIDE2, 	--夜魇上路商店
				SHOP_SECRET, 	--天辉上路神秘
				SHOP_SECRET2, 	--夜魇下路神秘
}

Site["top_power_rune"] = Vector( -1767, 1233 )
Site["bot_power_rune"] = Vector( 2597, -2014 )

Site["roshan"] = Vector( -2862, 2260 )

Site["dire_ancient"] = Vector( 5517, 4981 )
Site["radiant_ancient"] = Vector( -5860, -5328 )

Site["radiant_base"] = Vector( -7200, -6666 )
Site["dire_base"] = Vector( 7137, 6548 )


local visionRad = 2000 --假眼查重范围
local trueSightRad = 1000 --真眼查重范围


local RADIANT_RUNE_WARD = Vector( 2606, -1547, 0 )

local RADIANT_T3TOPFALL = Vector( -6600.000000, -3072.000000, 0.000000 ) --高地防御眼
local RADIANT_T3MIDFALL = Vector( -4314.000000, -3887.000000, 0.000000 )
local RADIANT_T3BOTFALL = Vector( -3586.000000, -6131.000000, 0.000000 )

local RADIANT_T2TOPFALL = Vector( -4345, -1018, 663 )  --二塔野区高台
local RADIANT_T2MIDFALL = Vector( 1283, -5109, 655 ) --天辉下路野区高台
local RADIANT_T2BOTFALL = Vector( -514, -3321, 655 )  --下路野区内高台

local RADIANT_T1TOPFALL = Vector( -4089, 1544, 535 )  --天辉上路野区高台
local RADIANT_T1MIDFALL = Vector( 2818, -3047, 655 )  --下方河道野区高台
local RADIANT_T1BOTFALL = Vector( 5253, -4844, 0 ) --下路野区十字路口

local RADIANT_MANDATE1 = Vector( -1243, -200, 0 )   ---天辉中路河道眼       
local RADIANT_MANDATE2 = RADIANT_RUNE_WARD  ---天辉看符眼

---DIRE WARDING SPOT
local DIRE_RUNE_WARD = Vector( 2606, -1547, 0 )

local DIRE_T3TOPFALL = Vector( 3087.000000, 5690.000000, 0.000000 )
local DIRE_T3MIDFALL = Vector( 4024.000000, 3445.000000, 0.000000 )
local DIRE_T3BOTFALL = Vector( 6354.000000, 2606.000000, 0.000000 )

local DIRE_T2TOPFALL = Vector( 514, 4107, 655 )  --夜魇上路野区高台
local DIRE_T2MIDFALL = Vector( 2047, -769, 655 )  --夜魇中路河道野区入口
local DIRE_T2BOTFALL = Vector( 4620, 788, 655 ) --夜魇下路高台

local DIRE_T1TOPFALL = Vector( -2815, 3565, 256 )   --夜魇上路野区河道路口
local DIRE_T1MIDFALL = Vector( -760, 2053, 655 )    --夜魇中路一塔野区入口高台
local DIRE_T1BOTFALL = Vector( 5122, -1930, 527 )   --夜魇下路一塔高台

local DIRE_MANDATE1 =  DIRE_RUNE_WARD       --夜魇看符眼      
local DIRE_MANDATE2 =  Vector( -463, 447, 0 )   --夜魇中路河道眼      

local RADIANT_AGGRESSIVETOP  = DIRE_T2TOPFALL --夜魇上路野区高台
local RADIANT_AGGRESSIVEMID1 = DIRE_T1MIDFALL --夜魇中路一塔野区入口高台
local RADIANT_AGGRESSIVEMID2 = DIRE_T2MIDFALL --夜魇中路河道野区入口
local RADIANT_AGGRESSIVEBOT  = DIRE_T2BOTFALL --夜魇下路高台

local DIRE_AGGRESSIVETOP  = RADIANT_T1TOPFALL --天辉上路野区高台
local DIRE_AGGRESSIVEMID1 = RADIANT_T2TOPFALL --天辉二塔野区高台
local DIRE_AGGRESSIVEMID2 = RADIANT_T2MIDFALL --天辉下路野区高台
local DIRE_AGGRESSIVEBOT  = RADIANT_T2BOTFALL --天辉下路野区内高台


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


function Site.GetDistance( s, t )

    return math.sqrt( ( s[1]-t[1] ) * ( s[1]-t[1] ) + ( s[2]-t[2] ) * ( s[2]-t[2] ) )

end


function Site.GetXUnitsTowardsLocation( hUnit, vLocation, nDistance )

    local direction = ( vLocation - hUnit:GetLocation() ):Normalized()

    return hUnit:GetLocation() + direction * nDistance

end




--获得塔的初始位置
function Site.GetTowerLocation( nTeam, nTower )

	if nTeam == TEAM_RADIANT
	then
		return vRadiantTowerLocationList[nTower]
	else
		return vDireTowerLocationList[nTower]
	end

end


function Site.GetNearestWatchTower( bot )

	if GetUnitToUnitDistance( bot, nWatchTower_1 ) < GetUnitToUnitDistance( bot, nWatchTower_2 )
	then
		return nWatchTower_1
	else
		return nWatchTower_2
	end

end


function Site.GetAllWatchTower()

	return Site.nWatchTowerList

end


--固定强制眼位
function Site.GetMandatorySpot()

	local MandatorySpotRadiant = {
		RADIANT_MANDATE1,
		RADIANT_MANDATE2,
	}

	local MandatorySpotDire = {
		DIRE_MANDATE1,
		DIRE_MANDATE2
	}

	--12分钟后加入一塔眼
	-- if DotaTime() > 12 * 60
	if DotaTime() > 6 * 60
	then
		MandatorySpotRadiant = {
			RADIANT_MANDATE1,
			RADIANT_MANDATE2,
			RADIANT_T1TOPFALL,
			RADIANT_T1MIDFALL,
			RADIANT_T1BOTFALL,
		}

		MandatorySpotDire = {
			DIRE_MANDATE1,
			DIRE_MANDATE2,
			DIRE_T1TOPFALL,
			DIRE_T1MIDFALL,
			DIRE_T1BOTFALL,
		}
	end


	if GetTeam() == TEAM_RADIANT
	then
		return MandatorySpotRadiant
	else
		return MandatorySpotDire
	end

end


--防御眼
function Site.GetWardSpotWhenTowerFall()

	local wardSpot = {}

	for i = 1, #Site.nTowerList
	do
		local t = GetTower( GetTeam(), Site.nTowerList[i] )
		if t == nil
		then
			if GetTeam() == TEAM_RADIANT
			then
				table.insert( wardSpot, WardSpotTowerFallRadiant[i] )
			else
				table.insert( wardSpot, WardSpotTowerFallDire[i] )
			end
		end
	end

	return wardSpot

end


--进攻眼
function Site.GetAggressiveSpot()

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

	if GetTeam() == TEAM_RADIANT
	then
		return AggressiveRadiant
	else
		return AggressiveDire
	end

end


function Site.GetItemWard( bot )

	for i = 0, 8
	do
		local item = bot:GetItemInSlot( i )
		if item ~= nil
			and ( item:GetName() == 'item_ward_observer' or item:GetName() == 'item_ward_dispenser'  or item:GetName() == 'item_ward_sentry' )
		then
			return item
		end
	end

end


function Site.GetAvailableSpot( bot )

	local temp = {}

	--先算必插眼位
	if DotaTime() < 38 * 60
	then
		for _, s in pairs( Site.GetMandatorySpot() )
		do
			if not Site.IsCloseToAvailableWard( s )
			then
				table.insert( temp, s )
			end
		end
	end

	--再算丢塔后的防御眼位
	for _, s in pairs( Site.GetWardSpotWhenTowerFall() )
	do
		if not Site.IsCloseToAvailableWard( s )
		then
			table.insert( temp, s )
		end
	end

	--10分钟后计算进攻眼位
	if DotaTime() > 10 * 60
	then
		for _, s in pairs( Site.GetAggressiveSpot() )
		do
			if GetUnitToLocationDistance( bot, s ) <= 1200
				and not Site.IsCloseToAvailableWard( s )
			then
				table.insert( temp, s )
			end
		end
	end

	return temp

end


--位置是否已有眼
function Site.IsCloseToAvailableWard( wardLoc )

	local WardList = GetUnitList( UNIT_LIST_ALLIED_WARDS )
	for _, ward in pairs( WardList )
	do
		if Site.IsObserver( ward )
			and GetUnitToLocationDistance( ward, wardLoc ) <= visionRad
		then
			return true
		end
	end

	return false

end


--位置是否已有真实视野
function Site.IsLocationHaveTrueSight( vLocation )

	local WardList = GetUnitList( UNIT_LIST_ALLIED_WARDS )

	for _, ward in pairs( WardList )
	do
		if Site.IsSentry( ward )
			and GetUnitToLocationDistance( ward, wardLoc ) <= trueSightRad
		then
			return true
		end
	end

	local tNearbyTowerList = GetBot():GetNearbyTowers( 1600, false )
	for _, tower in pairs( tNearbyTowerList )
	do
		if GetUnitToLocationDistance( tower, vLocation ) < trueSightRad
		then
			return true
		end
	end

	return false
end


--获得可用眼位中最近的一个
function Site.GetClosestSpot( bot, spotList )

	local cDist = 100000
	local cTarget = nil
	for _, spot in pairs( spotList ) do
		local dist = GetUnitToLocationDistance( bot, spot )
		if dist < cDist
		then
			cDist = dist
			cTarget = spot
		end
	end

	return cTarget, cDist

end


function Site.IsObserver( wardUnit )
	return wardUnit:GetUnitName() == "npc_dota_observer_wards"
end

function Site.IsSentry( wardUnit )
	return wardUnit:GetUnitName() == "npc_dota_sentry_wards"
end

----------- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ----------------------------
----------- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ----------------------------
----------- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ----------------------------
----------- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ----------------------------
----------- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ----------------------------
----------- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ----------------------------
local CStackTime = {55, 55, 55, 55, 55, 54, 55, 55, 55, 55, 55, 55, 55, 55, 55, 55, 55, 55}
local CStackLoc = {
	Vector( 1854.000000, -4469.000000, 0.000000 ),
	Vector( 1249.000000, -2416.000000, 0.000000 ),
	Vector( 3471.000000, -5841.000000, 0.000000 ),
	Vector( 5153.000000, -3620.000000, 0.000000 ),
	Vector( - 1846.000000, -2996.000000, 0.000000 ),
	Vector( -4961.000000, 559.000000, 0.000000 ),
	Vector( -3873.000000, -833.000000, 0.000000 ),
	Vector( -3146.000000, 702.000000, 0.000000 ),
	Vector( 1141.000000, -3111.000000, 0.000000 ),
	Vector( 660.000000, 2300.000000, 0.000000 ),
	Vector( 3666.000000, 1836.000000, 0.000000 ),
	Vector( 482.000000, 4723.000000, 0.000000 ),
	Vector( 3173.000000, -861.000000, 0.000000 ),
	Vector( -3443.000000, 6098.000000, 0.000000 ),
	Vector( -4353.000000, 4842.000000, 0.000000 ),
	Vector( - 1083.000000, 3385.000000, 0.000000 ),
	Vector( -922.000000, 4299.000000, 0.000000 ),
	Vector( 4136.000000, - 1753.000000, 0.000000 )
}


function Site.IsVaildCreep( nUnit )

	return nUnit ~= nil
		   and not nUnit:IsNull()
		   and nUnit:IsAlive()
		   and nUnit:GetHealth() < 5000
		   and ( GetBot():GetLevel() > 9 or not nUnit:IsAncientCreep() )		  
		  
end


function Site.HasArmorReduction( nUnit )

	return nUnit:HasModifier( "modifier_templar_assassin_meld_armor" )
			or nUnit:HasModifier( "modifier_item_medallion_of_courage_armor_reduction" )
			or nUnit:HasModifier( "modifier_item_solar_crest_armor_reduction" )

end


local tFarmerList = {
	["npc_dota_hero_nevermore"] = true,
	["npc_dota_hero_medusa"] = true,
	["npc_dota_hero_razor"] = true,
	["npc_dota_hero_luna"] = true,
	["npc_dota_hero_sven"] = true,
	["npc_dota_hero_antimage"] = true,
	["npc_dota_hero_phantom_assassin"] = true,
	["npc_dota_hero_phantom_lancer"] = true,
	["npc_dota_hero_naga_siren"] = true,
	["npc_dota_hero_templar_assassin"] = true,
}
function Site.IsSpecialFarmer( bot )

	local botName = bot:GetUnitName()

	return tFarmerList[botName] == true

end


local tFarmHeroList = {
	["npc_dota_hero_nevermore"] = true,
	["npc_dota_hero_drow_ranger"] = true,
	["npc_dota_hero_luna"] = true,
	["npc_dota_hero_sven"] = true,
	["npc_dota_hero_axe"] = true,
	["npc_dota_hero_antimage"] = true,
	["npc_dota_hero_arc_warden"] = true,
	["npc_dota_hero_bloodseeker"] = true,
	["npc_dota_hero_medusa"] = true,
	["npc_dota_hero_razor"] = true,
	["npc_dota_hero_phantom_assassin"] = true,
	["npc_dota_hero_phantom_lancer"] = true,
	["npc_dota_hero_naga_siren"] = true,
	["npc_dota_hero_templar_assassin"] = true,
	["npc_dota_hero_huskar"] = true,
	["npc_dota_hero_clinkz"] = true,
	["npc_dota_hero_juggernaut"] = true,
	["npc_dota_hero_tidehunter"] = true,
	["npc_dota_hero_slark"] = true,
}
function Site.IsShouldFarmHero( bot )

	local botName = bot:GetUnitName()

	return tFarmHeroList[botName] == true

end


function Site.GetCampMoveToStack( id )

	return CStackLoc[id]

end


function Site.GetCampStackTime( camp )

	if camp.cattr.speed == "fast"
	then
		return 56
	elseif camp.cattr.speed == "slow"
	then
		return 55
	else
		return 56
	end

end


function Site.IsEnemyCamp( camp )

	return camp.team ~= GetTeam()

end


function Site.IsAncientCamp( camp )

	return camp.type == "ancient"

end


function Site.IsSmallCamp( camp )

	return camp.type == "small"

end


function Site.IsMediumCamp( camp )

	return camp.type == "medium"

end


function Site.IsLargeCamp( camp )

	return camp.type == "large"

end


function Site.RefreshCamp( bot )

	local camps = GetNeutralSpawners()
	local allCampList = {}
	local nSum = 0
	local nCount = 0
	for i, id in pairs( GetTeamPlayers( GetTeam() ) )
	do
		nSum = nSum + GetHeroLevel( id )
		nCount = nCount + 1
	end
	local nAverageLV = nSum / nCount


	for k, camp in pairs( camps )
	do
		if ( nAverageLV < 6 or bot:GetAttackDamage() <= 66 )
		then
			if not Site.IsEnemyCamp( camp )
				and not Site.IsLargeCamp( camp )
				and not Site.IsAncientCamp( camp )
			then
				table.insert( allCampList, { idx = k, cattr = camp } )
			end
		elseif nAverageLV <= 10
		then
			if not Site.IsEnemyCamp( camp )
				and not Site.IsAncientCamp( camp )
			then
				table.insert( allCampList, { idx = k, cattr = camp } )
			end
		elseif nAverageLV < 12
		then
			if not Site.IsEnemyCamp( camp )
			then
				table.insert( allCampList, { idx = k, cattr = camp } )
			end
		else
			table.insert( allCampList, { idx = k, cattr = camp } )
		end
	end

	return allCampList, #allCampList

end


function Site.GetClosestNeutralSpwan( bot, availableCampList )

	local minDist = 15000
	local pCamp = nil

	for _, camp in pairs( availableCampList )
	do
	   local dist = GetUnitToLocationDistance( bot, camp.cattr.location )
	   if Site.IsEnemyCamp( camp ) then dist = dist * 1.5 end
	  
	   if Site.IsTheClosestOne( bot, camp.cattr.location )
	      and dist < minDist
		  and ( bot:GetLevel() > 9 or not Site.IsAncientCamp( camp ) )
	   then
			minDist = dist
			pCamp = camp
	   end
	end

	return pCamp

end


function Site.IsTheClosestOne( bot, loc )

	local minDist = GetUnitToLocationDistance( bot, loc )
	local closestMember = bot

	for k, v in pairs( GetTeamPlayers( GetTeam() ) )
	do
		local member = GetTeamMember( k )
		if  member ~= nil
			and member:IsAlive()
			and member:GetActiveMode() == BOT_MODE_FARM
		then
			local memberDist = GetUnitToLocationDistance( member, loc )
			if memberDist < minDist
			then
				minDist = memberDist
				closestMember = member
			end
		end
	end

	return closestMember == bot

end


function Site.GetNearestCreep( creepList )

	if Site.IsVaildCreep( creepList[1] )
	then
		return creepList[1]
	end

end


function Site.GetMaxHPCreep( creepList )

	local nHPMax  = 0
	local targetCreep = nil
	for _, creep in pairs( creepList )
	do
		if not creep:IsNull()
		   and Site.HasArmorReduction( creep )
		then
			return creep
		end

		if Site.IsVaildCreep( creep )
		   and creep:GetHealth() > nHPMax
		then
			nHPMax = creep:GetHealth()
			targetCreep = creep
		end
	end


	return targetCreep

end


function Site.GetMinHPCreep( creepList )

	local nHPMin = 4000
	local targetCreep = nil

	for _, creep in pairs( creepList )
	do
		if not creep:IsNull()
		   and Site.HasArmorReduction( creep )
		then
			return creep
		end

		if Site.IsVaildCreep( creep )
		   and creep:GetHealth() < nHPMin
		then
			nHPMin = creep:GetHealth()
			targetCreep = creep
		end
	end

	return targetCreep

end

----------------------------------
Site.ConsiderFarmNeutralType = {}

Site.ConsiderFarmNeutralType["npc_dota_hero_templar_assassin"] = function()	return 'nearest' end

Site.ConsiderFarmNeutralType["npc_dota_hero_sven"] = function()	return 'nearest' end

Site.ConsiderFarmNeutralType["npc_dota_hero_drow_ranger"] = function() return 'nearest' end

Site.ConsiderFarmNeutralType["npc_dota_hero_phantom_lancer"] = function() return 'nearest' end

Site.ConsiderFarmNeutralType["npc_dota_hero_naga_siren"] = function() return 'nearest' end

Site.ConsiderFarmNeutralType["npc_dota_hero_viper"] = function() return 'maxHP' end

Site.ConsiderFarmNeutralType["npc_dota_hero_huskar"] = function() return 'maxHP' end

Site.ConsiderFarmNeutralType["npc_dota_hero_razor"] = function() return 'maxHP' end

Site.ConsiderFarmNeutralType["npc_dota_hero_phantom_assassin"] = function()

	local bot = GetBot()

	if Site.IsHaveItem( bot, "item_bfury" )
	then
		return 'nearest'
	end

	return 'minHP'

end

Site.ConsiderFarmNeutralType["npc_dota_hero_medusa"] = function()

	local bot = GetBot()
	local farmAbility = bot:GetAbilityByName( "medusa_split_shot" )
	return farmAbility:IsTrained() and 'maxHP' or 'minHP'

end

Site.ConsiderFarmNeutralType["npc_dota_hero_luna"] = function()

	local bot = GetBot()
	local farmAbility = bot:GetAbilityByName( 'luna_moon_glaive' )
	return farmAbility:IsTrained() and 'maxHP' or 'minHP'

end

Site.ConsiderFarmNeutralType["npc_dota_hero_tidehunter"] = function()

	local bot = GetBot()
	local farmAbility = bot:GetAbilityByName( "tidehunter_anchor_smash" )
	local ultimateAbility = bot:GetAbilityByName( "tidehunter_ravage" )

	if farmAbility:IsTrained()
		and ultimateAbility:IsTrained()
		and bot:GetMana() > ultimateAbility:GetManaCost() + 200
	then
		return 'maxHP'
	end

	return 'minHP'

end

Site.ConsiderFarmNeutralType["npc_dota_hero_nevermore"] = function()

	local bot = GetBot()

	if bot:GetMana() > 200 and bot:GetLevel() >= 13	then return 'maxHP'	end

	return 'minHP'

end

Site.ConsiderFarmNeutralType["npc_dota_hero_dragon_knight"] = function()

	return GetBot():GetAttackRange() > 330 and 'maxHP' or 'minHP'

end

----------------------------------

function Site.FindFarmNeutralTarget( creepList )

	local bot = GetBot()
	local botName = bot:GetUnitName()
	local targetCreep = nil

	if Site.ConsiderFarmNeutralType[botName] ~= nil
	then
		local sFarmNeutralType = Site.ConsiderFarmNeutralType[botName]()
		if sFarmNeutralType == 'nearest'
		then
			targetCreep = Site.GetNearestCreep( creepList )
			if targetCreep ~= nil then return targetCreep end
		elseif sFarmNeutralType == 'maxHP'
		then
			targetCreep = Site.GetMaxHPCreep( creepList )
			if targetCreep ~= nil then return targetCreep end
		else
			targetCreep = Site.GetMinHPCreep( creepList )
			if targetCreep ~= nil then return targetCreep end
		end
	end

	if Site.IsHaveItem( bot, "item_bfury" )
	   or Site.IsHaveItem( bot, "item_maelstrom" )
	   or Site.IsHaveItem( bot, "item_mjollnir" )
	   or Site.IsHaveItem( bot, "item_radiance" )
	then
		targetCreep = Site.GetMaxHPCreep( creepList )
		if targetCreep ~= nil then return targetCreep end
	end

	return Site.GetMinHPCreep( creepList )

end


function Site.GetFarmLaneTarget( creepList )

	local bot = GetBot()
	local botName = bot:GetUnitName()
	local targetCreep = nil

	local nAllyCreeps = bot:GetNearbyLaneCreeps( 1000, false )

	if botName ~= "npc_dota_hero_medusa"
	   and botName ~= "npc_dota_hero_razor"
	   and #nAllyCreeps > 0
	then
		targetCreep = Site.GetNearestCreep( creepList )
		if targetCreep ~= nil then return targetCreep end
	end

	if botName == "npc_dota_hero_medusa"
	then
		targetCreep = Site.GetMinHPCreep( creepList )
		if targetCreep ~= nil then return targetCreep end
	end

	targetCreep = Site.GetMaxHPCreep( creepList )

	return targetCreep

end





function Site.IsSuitableFarmMode( mode )

	return	mode ~= BOT_MODE_RUNE
		and mode ~= BOT_MODE_ATTACK
		and mode ~= BOT_MODE_SECRET_SHOP
		and mode ~= BOT_MODE_SIDE_SHOP
		and mode ~= BOT_MODE_DEFEND_ALLY
		and mode ~= BOT_MODE_EVASIVE_MANEUVERS

end


local maskGetGold = 0
local maskGet = false
function Site.IsModeSuitableToFarm( bot )

	local mode = bot:GetActiveMode()
	local botLevel = bot:GetLevel()
	local botName = bot:GetUnitName()

	if not maskGet
		and Site.IsHaveItem( bot, "item_mask_of_madness" )
	then
		maskGet = true
		maskGetGold = bot:GetNetWorth()
	end

	if Site.IsMaskFarmTime( bot, mode )
		and Site.IsSuitableFarmMode( mode )
	then
		return true
	end

	if  botLevel <= 9
	    and ( mode == BOT_MODE_PUSH_TOWER_TOP
		or mode == BOT_MODE_PUSH_TOWER_MID
		or mode == BOT_MODE_PUSH_TOWER_BOT
		or mode == BOT_MODE_LANING )
	then
		local enemyAncient = GetAncient( GetOpposingTeam() )
		if GetUnitToUnitDistance( bot, enemyAncient ) > 6600 
		then
			return false
		end
	end

	if Site.IsSpecialFarmer( bot )
		and botLevel >= 6
		and botLevel <= 24
		and Site.IsSuitableFarmMode( mode )
		and mode ~= BOT_MODE_ROSHAN
		and mode ~= BOT_MODE_TEAM_ROAM
		and mode ~= BOT_MODE_LANING
		and mode ~= BOT_MODE_WARD
	then
		return true
	end

	if Site.IsSuitableFarmMode( mode )
	   and mode ~= BOT_MODE_WARD
	   and mode ~= BOT_MODE_LANING
	   and mode ~= BOT_MODE_DEFEND_TOWER_TOP
	   and mode ~= BOT_MODE_DEFEND_TOWER_MID
	   and mode ~= BOT_MODE_DEFEND_TOWER_BOT
	   and mode ~= BOT_MODE_ASSEMBLE
	   and mode ~= BOT_MODE_TEAM_ROAM
	   and mode ~= BOT_MODE_ROSHAN
	   and botLevel >= 6
	then
		return true
	end

	return false

end


function Site.IsMaskFarmTime( bot, mode )

	if maskGet
	   and bot:GetNetWorth() < maskGetGold + 2000
	then
		return true
	end

	return false

end


function Site.IsTimeToFarm( bot )

	if DotaTime() < 6 * 60 or DotaTime() > 90 * 60 then return false end

	local botName = bot:GetUnitName()
	local botNetWorth = bot:GetNetWorth()

	--防止单独无用的推进
	if bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT
		or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
		or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP
	then
		local enemyAncient = GetAncient( GetOpposingTeam() )
		local allyList = bot:GetNearbyHeroes( 1400, false, BOT_MODE_NONE )
		local enemyAncientDistance = GetUnitToUnitDistance( bot, enemyAncient )
		if  enemyAncientDistance < 2800
		    and enemyAncientDistance > 1400
			and bot:GetActiveModeDesire() < BOT_MODE_DESIRE_HIGH
			and #allyList <= 1
		then
			return true
		end

		if Site.IsShouldFarmHero( bot )
		then
			if  bot:GetActiveModeDesire() < BOT_MODE_DESIRE_MODERATE
				and enemyAncientDistance > 1600
				and enemyAncientDistance < 5600
				and #allyList <= 1
			then
				return true
			end
		end
	end

	if Site.ConsiderIsTimeToFarm[botName] ~= nil
	   and Site.ConsiderIsTimeToFarm[botName]() == true
	then
		return true
	end

	return false

end

-----------------------------------------------------------
Site.ConsiderIsTimeToFarm = {}

Site.ConsiderIsTimeToFarm["npc_dota_hero_antimage"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	if DotaTime() > 9 * 60
	   and ( bot:GetLevel() < 25 or botNetWorth < 23000 )
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_black_king_bar" )
	   and botNetWorth < 18000
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_satanic" )
		and botNetWorth < 28000
	then
		if Site.GetAroundAllyCount( bot, 1200 ) <= 2
		then
			return true
		end
	end

	return false

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_arc_warden"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	if DotaTime() > 15 * 60
		and ( bot:GetLevel() < 25 or botNetWorth < 22000 )
	then
		return true
	end	
	
	if Site.IsHaveItem( bot, "item_gloves" )
		and not Site.IsHaveItem( bot, "item_hand_of_midas" )
		and bot:GetGold() > 800
	then
		return true
	end

	if Site.IsHaveItem( bot, "item_yasha" )
		and not Site.IsHaveItem( bot, "item_manta" )
		and bot:GetGold() > 1000
	then
		return true
	end

	if Site.IsHaveItem( bot, "item_hand_of_midas" )
		and Site.GetAroundAllyCount( bot, 1200 ) <= 3
		and botNetWorth <= 26000
	then
		return true
	end

	return false

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_axe"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	if DotaTime() > 7 * 60
	   and ( bot:GetLevel() < 25 or botNetWorth < 20000 )
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_echo_sabre" )
		and botNetWorth < 12000
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_heart" )
		and botNetWorth < 21000
	then
		if Site.GetAroundAllyCount( bot, 1100 ) <= 1
		then
			return true
		end
	end

	return false

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_bloodseeker"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	if DotaTime() > 9 * 60
		and ( bot:GetLevel() < 25 or botNetWorth < 22000 )
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_black_king_bar" )
		and botNetWorth < 16000
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_abyssal_blade" )
		and botNetWorth < 26000
	then
		if Site.GetAroundAllyCount( bot, 1200 ) <= 1
		then
			return true
		end
	end

	return false
end

Site.ConsiderIsTimeToFarm["npc_dota_hero_bristleback"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	local botKills = GetHeroKills( bot:GetPlayerID() )
	local botDeaths = GetHeroDeaths( bot:GetPlayerID() )
	local allyCount = Site.GetAroundAllyCount( bot, 1200 )

	if botKills >= botDeaths + 4
	   and botDeaths <= 3
	then
		return false
	end

	if bot:GetLevel() >= 10
		and allyCount <= 2
		and botNetWorth < 15000
	then
		return true
	end

	if bot:GetLevel() >= 20
	   and allyCount <= 1
	   and botNetWorth < 21000
	then
		return true
	end

	return false

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_chaos_knight"] = function()

	return Site.ConsiderIsTimeToFarm["npc_dota_hero_bristleback"]()

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_clinkz"] = function()

	return Site.ConsiderIsTimeToFarm["npc_dota_hero_templar_assassin"]()

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_dragon_knight"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	if not Site.IsHaveItem( bot, "item_assault" )
	   and botNetWorth < 22000
	then
		local allyCount = Site.GetAroundAllyCount( bot, 1200 )
		if bot:GetAttackRange() > 300
			and allyCount <= 2
		then
			return true
		end

		if bot:GetMana() > 450
			and bot:GetCurrentVisionRange() < 1000
			and allyCount < 2
		then
			return true
		end
	end

	return false

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_drow_ranger"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	if bot:GetLevel() >= 6
	   and ( bot:GetLevel() < 25 or botNetWorth < 20000 )
	then
		return true
	end

	if Site.IsHaveItem( bot, "item_mask_of_madness" )
		and botNetWorth < 9999
	then
		return true
	end

	if Site.IsHaveItem( bot, "item_blade_of_alacrity" )
		and not Site.IsHaveItem( bot, "item_ultimate_scepter" )
	then
		return true
	end

	if  Site.IsHaveItem( bot, "item_shadow_amulet" )
		and not Site.IsHaveItem( bot, "item_invis_sword" )
		and bot:GetGold() > 400
	then
		return true
	end

	if Site.IsHaveItem( bot, "item_yasha" )
		and not Site.IsHaveItem( bot, "item_manta" )
		and bot:GetGold() > 1000
	then
		return true
	end

	if Site.IsHaveItem( bot, "item_ultimate_scepter" )
		and botNetWorth < 23000
	then
		if Site.GetAroundAllyCount( bot, 1100 ) <= 2
		then
			return true
		end
	end

	return false

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_huskar"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	if DotaTime() > 9 * 60
		and ( bot:GetLevel() < 25 or botNetWorth < 20000 )
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_hurricane_pike" )
		and botNetWorth < 18000
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_black_king_bar" )
		and botNetWorth < 26000
	then
		if Site.GetAroundAllyCount( bot, 1100 ) < 2
		then
			return true
		end
	end

	if bot:GetLevel() > 20
	   and botNetWorth < 23333
	then
		if Site.GetAroundAllyCount( bot, 1100 ) <= 1
		then
			return true
		end
	end

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_juggernaut"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	if DotaTime() > 9 * 60
		and ( bot:GetLevel() < 25 or botNetWorth < 20000 )
	then
		return true
	end


	if not Site.IsHaveItem( bot, "item_black_king_bar" )
		and botNetWorth < 20000
	then
		if Site.GetAroundAllyCount( bot, 1100 ) <= 2
		then
			return true
		end
	end

	if not Site.IsHaveItem( bot, "item_satanic" )
		and botNetWorth < 24000
	then
		if Site.GetAroundAllyCount( bot, 1000 ) <= 1
		then
			return true
		end
	end

	return false

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_kunkka"] = function()

	return Site.ConsiderIsTimeToFarm["npc_dota_hero_bristleback"]()

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_luna"] = function()

	return Site.ConsiderIsTimeToFarm["npc_dota_hero_huskar"]()

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_mirana"] = function()

	return Site.ConsiderIsTimeToFarm["npc_dota_hero_templar_assassin"]()

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_medusa"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	if DotaTime() > 9 * 60
		and ( bot:GetLevel() < 25 or botNetWorth < 20000 )
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_black_king_bar" )
		and botNetWorth < 16000
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_satanic" )
		and botNetWorth < 28000
	then
		if Site.GetAroundAllyCount( bot, 1100 ) <= 1
		then
			return true
		end
	end

	return false

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_nevermore"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	if DotaTime() > 9 * 60
		and ( bot:GetLevel() < 25 or botNetWorth < 22000 )
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_skadi" )
		and botNetWorth < 16000
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_sphere" )
		and botNetWorth < 28000
	then
		if Site.GetAroundAllyCount( bot, 1100 ) <= 2
		then
			return true
		end
	end

	return false

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_omniknight"] = function()

	return Site.ConsiderIsTimeToFarm["npc_dota_hero_bristleback"]()

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_ogre_magi"] = function()

	return Site.ConsiderIsTimeToFarm["npc_dota_hero_bristleback"]()

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_phantom_assassin"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	if DotaTime() > 9 * 60
		and ( bot:GetLevel() < 25 or botNetWorth < 20000 )
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_desolator" )
		and botNetWorth < 16000
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_black_king_bar" )
		and botNetWorth < 24000
	then
		if Site.GetAroundAllyCount( bot, 1000 ) <= 2
		then
			return true
		end
	end

	if not Site.IsHaveItem( bot, "item_satanic" )
		and botNetWorth < 26000
	then
		if Site.GetAroundAllyCount( bot, 1100 ) <= 1
		then
			return true
		end
	end

	return false

end



Site.ConsiderIsTimeToFarm["npc_dota_hero_phantom_lancer"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	if DotaTime() > 9 * 60
		and ( bot:GetLevel() < 25 or botNetWorth < 23000 )
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_skadi" )
		and botNetWorth < 18000
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_sphere" )
		and botNetWorth < 22000
	then
		if Site.GetAroundAllyCount( bot, 1300 ) <= 3
		then
			return true
		end
	end

	if not Site.IsHaveItem( bot, "item_heart" )
		and botNetWorth < 26000
	then
		if Site.GetAroundAllyCount( bot, 1100 ) <= 1
		then
			return true
		end
	end

	return false

end


Site.ConsiderIsTimeToFarm["npc_dota_hero_naga_siren"] = function()

	return Site.ConsiderIsTimeToFarm["npc_dota_hero_phantom_lancer"]()

end


Site.ConsiderIsTimeToFarm["npc_dota_hero_razor"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	if DotaTime() > 7 * 60
	   and ( bot:GetLevel() < 25 or botNetWorth < 20000 )
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_black_king_bar" )
		and botNetWorth < 15000
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_satanic" )
		and botNetWorth < 25000
	then
		if Site.GetAroundAllyCount( bot, 1100 ) <= 1
		then
			return true
		end
	end

	return false

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_sand_king"] = function()

	return Site.ConsiderIsTimeToFarm["npc_dota_hero_bristleback"]()

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_slardar"] = function()

	return Site.ConsiderIsTimeToFarm["npc_dota_hero_bristleback"]()

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_legion_commander"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	if DotaTime() > 7 * 60
	   and ( bot:GetLevel() < 25 or botNetWorth < 20000 )
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_echo_sabre" )
		and botNetWorth < 12000
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_heart" )
		and botNetWorth < 21000
	then
		if Site.GetAroundAllyCount( bot, 1100 ) <= 1
		then
			return true
		end
	end

	return false

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_slark"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	if DotaTime() > 9 * 60
		and ( bot:GetLevel() < 25 or botNetWorth < 20000 )
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_invis_sword" )
		and botNetWorth < 18000
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_silver_edge" )
		and botNetWorth < 21000
	then
		if Site.GetAroundAllyCount( bot, 1100 ) <= 2
		then
			return true
		end
	end

	if not Site.IsHaveItem( bot, "item_abyssal_blade" )
		and botNetWorth < 25000
	then
		if Site.GetAroundAllyCount( bot, 1300 ) <= 1
		then
			return true
		end
	end

	return false

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_skeleton_king"] = function()

	return Site.ConsiderIsTimeToFarm["npc_dota_hero_bristleback"]()

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_sven"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	if DotaTime() > 9 * 60
		and ( bot:GetLevel() < 25 or botNetWorth < 20000 )
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_black_king_bar" )
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_satanic" )
		and botNetWorth < 22000
	then
		if Site.GetAroundAllyCount( bot, 1000 ) <= 2
		then
			return true
		end
	end

	if not Site.IsHaveItem( bot, "item_greater_crit" )
		and botNetWorth < 26000
	then
		if Site.GetAroundAllyCount( bot, 1100 ) <= 1
		then
			return true
		end
	end

	return false

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_sniper"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	if bot:GetLevel() >= 10
		and not Site.IsHaveItem( bot, "item_monkey_king_bar" )
		and botNetWorth < 22000
	then
		local botKills = GetHeroKills( bot:GetPlayerID() )
		local botDeaths = GetHeroDeaths( bot:GetPlayerID() )
		if botKills - 3 <=  botDeaths
			and botDeaths > 2
			and Site.GetAroundAllyCount( bot, 1200 ) <= 2
		then
			return true
		end
	end

	return false

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_templar_assassin"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	if DotaTime() > 9 * 60
		and ( bot:GetLevel() < 25 or botNetWorth < 20000 )
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_black_king_bar" )
		and botNetWorth < 16000
	then
		return true
	end

	if not Site.IsHaveItem( bot, "item_hurricane_pike" )
		and botNetWorth < 20000
	then
		if Site.GetAroundAllyCount( bot, 1300 ) <= 3
		then
			return true
		end
	end

	if not Site.IsHaveItem( bot, "item_satanic" )
		and botNetWorth < 26000
	then
		if Site.GetAroundAllyCount( bot, 1100 ) <= 1
		then
			return true
		end
	end

	return false

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_tidehunter"] = function()

	return Site.ConsiderIsTimeToFarm["npc_dota_hero_sven"]()

end


Site.ConsiderIsTimeToFarm["npc_dota_hero_viper"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()

	if bot:GetLevel() >= 10
		and not Site.IsHaveItem( bot, "item_mjollnir" )
		and botNetWorth < 20000
	then
		local botKills = GetHeroKills( bot:GetPlayerID() )
		local botDeaths = GetHeroDeaths( bot:GetPlayerID() )
		local allyCount = Site.GetAroundAllyCount( bot, 1300 )
		if botKills - 4 <=  botDeaths
			and botDeaths > 2
			and allyCount < 3
		then
			return true
		end

		if bot:GetMana() > 650
			and bot:GetCurrentVisionRange() < 1000
			and allyCount <= 1
		then
			return true
		end
	end

	return false

end

Site.ConsiderIsTimeToFarm["npc_dota_hero_new"] = function()

	local bot = GetBot()
	local botNetWorth = bot:GetNetWorth()



	return false
end

------------------------------------------------------------------


--根据地点来刷新阵营
function Site.UpdateAvailableCamp( bot, preferedCamp2, availableCampList )

	if preferedCamp2 ~= nil
	then
		for i = 1, #availableCampList
		do
			if availableCampList[i].cattr.location == preferedCamp2.cattr.location
				or GetUnitToLocationDistance( bot, availableCampList[i].cattr.location ) < 500
			then
				table.remove( availableCampList, i )
				return availableCampList, nil
			end
		end
	end

	return availableCampList, nil

end

--根据生物来刷新阵营
local lastCreep = nil
function Site.UpdateCommonCamp( creep, availableCampList )

	if lastCreep ~= creep
	then
		lastCreep = creep
		for i = 1, #availableCampList
		do
			if GetUnitToLocationDistance( creep, availableCampList[i].cattr.location ) < 500
			then
				table.remove( availableCampList, i )
				return availableCampList
			end
		end
	end

	return availableCampList

end


function Site.IsHaveItem( bot, itemName )

    local slot = bot:FindItemSlot( itemName )

	if slot >= 0 and slot <= 5
	then
		return true
	end

    return false

end

function Site.GetAroundAllyCount( bot, nRadius )

	local nCount = 0
	for i = 1, 5
	do
		local member = GetTeamMember( i )
		if member ~= nil
			and member:IsAlive()
			and GetUnitToUnitDistance( bot, member ) <= nRadius
		then
			nCount = nCount + 1
		end
	end

	return nCount

end



----------------------------------
function Site.GetTowardsFountainLocation( unitLoc, distance )
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


function CDOTA_Bot_Script:GetForwardVector()
    local radians = self:GetFacing() * math.pi / 180
    local forward_vector = Vector(math.cos(radians), math.sin(radians))
    return forward_vector
end

----------------------------------------------------------------------------------------------------

function CDOTA_Bot_Script:IsFacingUnit( hTarget, degAccuracy )
    local direction = (hTarget:GetLocation() - self:GetLocation()):Normalized()
    local dot = direction:Dot(self:GetForwardVector())
    local radians = degAccuracy * math.pi / 180
    return dot > math.cos(radians)
end

----------------------------------------------------------------------------------------------------

function CDOTA_Bot_Script:GetXUnitsTowardsLocation( vLocation, nUnits)
    local direction = (vLocation - self:GetLocation()):Normalized()
    return self:GetLocation() + direction * nUnits
end

----------------------------------------------------------------------------------------------------

function CDOTA_Bot_Script:GetXUnitsInFront( nUnits )
    return self:GetLocation() + self:GetForwardVector() * nUnits
end








function Site.GetFarmLaneTarget2( creepList )

	local bot = GetBot()
	local botName = bot:GetUnitName()
	local targetCreep = nil

	local nAllyCreeps = bot:GetNearbyCreeps( 1000, false )

	-- if botName ~= "npc_dota_hero_medusa"
	   -- and botName ~= "npc_dota_hero_razor"
	   -- and #nAllyCreeps > 0
	-- then
		-- targetCreep = Site.GetNearestCreep( creepList )
		-- if targetCreep ~= nil then return targetCreep end
	-- end
	
	if bot:IsAlive() and  not role.IsCarry(botName)
	   and #nAllyCreeps > 0
	then
		targetCreep = Site.GetNearestCreep2( creepList )
		if targetCreep ~= nil then return targetCreep end
	end

	-- if botName == "npc_dota_hero_medusa"
	-- then
		-- targetCreep = Site.GetMinHPCreep( creepList )
		-- if targetCreep ~= nil then return targetCreep end
	-- end
	
	if bot:IsAlive() and  role.IsCarry(botName) 
	then
		targetCreep = Site.GetMinHPCreep2( creepList )
		if targetCreep ~= nil then return targetCreep end
	end

	targetCreep = Site.GetMaxHPCreep2( creepList )

	return targetCreep

end






function Site.GetNearestCreep2( creepList )

	if Site.IsVaildCreep( creepList[1] )
	then
		return creepList[1]
	end

end




function Site.GetMinHPCreep2( creepList )

	local nHPMin = 4000
	local targetCreep = nil

	for _, creep in pairs( creepList )
	do
		if not creep:IsNull()
		   -- and Site.HasArmorReduction( creep )
		then
			return creep
		end

		if Site.IsVaildCreep( creep )
		   and creep:GetHealth() < nHPMin
		then
			nHPMin = creep:GetHealth()
			targetCreep = creep
		end
	end

	return targetCreep

end



function Site.GetMaxHPCreep2( creepList )

	local nHPMax  = 0
	local targetCreep = nil
	for _, creep in pairs( creepList )
	do
		if not creep:IsNull()
		   -- and Site.HasArmorReduction( creep )
		then
			return creep
		end

		if Site.IsVaildCreep( creep )
		   and creep:GetHealth() > nHPMax
		then
			nHPMax = creep:GetHealth()
			targetCreep = creep
		end
	end


	return targetCreep

end




return Site
-- dota2jmz@163.com QQ:2462331592.