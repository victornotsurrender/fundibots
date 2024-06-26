X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_arcane_boots",
	"item_blink",
	"item_mekansm",
	"item_hood_of_defiance",
	--"item_pipe",
	"item_radiance",
	"item_dagon_5",
	"item_ultimate_scepter",
	"item_eternal_shroud",
	"item_guardian_greaves",
	"item_arcane_blink",
	--"item_heart",
	"item_ultimate_scepter_2",
	"item_octarine_core",
	"item_moon_shard"
};			

X["builds"] = {
	{1,3,1,2,1,4,1,3,3,3,4,2,2,2,4},
	{3,1,1,2,1,4,1,3,3,3,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,5,7}, talents
);

return X