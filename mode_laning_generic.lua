---------------------------------------------------------------------------
--- The Creation Come From: A Beginner AI 
--- Author: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
---------------------------------------------------------------------------
if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or GetBot():IsIllusion() then
	return
end

-- local X = {}
local bot = GetBot()


-- local aliveEnemyCount2 = GetNumOfAliveHeroes(true);
-- local aliveAllyCount2  = GetNumOfAliveHeroes(false);
function GetDesire()

	local currentTime = DotaTime()
	local botLV = bot:GetLevel()

	if currentTime <= 10
	then
		return 0.268
	end
	
	if currentTime <= 9 * 60
		and botLV <= 7
	then
		return 0.446
	end
	
	if currentTime <= 12 * 60
		and botLV <= 11
	then
		return 0.369
	end
	
	-- if aliveAllyCount2 >= aliveEnemyCount2 *2
	-- then
		
	
		-- return 1.33
	-- end
	
	
	-- if botLV > 17
	-- then
		-- return 0.457
	-- end

	return 0

end




-- function GetNumOfAliveHeroes( bEnemy )

	-- local count = 0
	-- local nTeam = GetTeam()
	-- if bEnemy then nTeam = GetOpposingTeam() end

	-- for i, id in pairs( GetTeamPlayers( nTeam ) )
	-- do
		-- if IsHeroAlive( id )
		-- then
			-- count = count + 1
		-- end
	-- end

	-- return count

-- end



-- dota2jmz@163.com QQ:2462331592.
