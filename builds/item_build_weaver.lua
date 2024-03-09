X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_agi",
	"item_dragon_lance",
	--"item_desolator",
	"item_maelstrom",
	"item_black_king_bar",
	"item_mjollnir",
	"item_skadi",
	"item_greater_crit",
	"item_ultimate_scepter_2",
	--"item_butterfly",
	"item_hurricane_pike"
};			

X["builds"] = {
	{2,3,2,1,2,4,2,1,1,1,4,3,3,3,4},
	{2,3,1,2,2,4,2,3,3,3,4,1,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,7}, talents
);

return X