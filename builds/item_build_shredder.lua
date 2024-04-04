X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_arcane_boots",
	"item_hood_of_defiance",
	"item_bloodstone",
	"item_ultimate_scepter",
	"item_lotus_orb",
	"item_eternal_shroud",
	--"item_pipe",
	"item_shivas_guard",
	"item_guardian_greaves",
	"item_ultimate_scepter_2",
	"item_crimson_guard",
	"item_moon_shard"	
	
};			

X["builds"] = {
	{3,1,3,2,3,4,3,2,2,2,4,1,1,1,4},
	{3,2,3,1,3,4,3,2,2,2,4,1,1,1,4},
	{3,2,1,3,2,4,1,3,2,1,4,3,2,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,6,8}, talents
);

return X