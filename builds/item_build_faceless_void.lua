X = {}
local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_power_treads_agi",
	"item_mask_of_madness",
	"item_maelstrom",
	"item_lesser_crit",
	"item_monkey_king_bar",
	"item_black_king_bar",
	"item_mjollnir",
	"item_greater_crit",
	"item_butterfly",
	"item_ultimate_scepter_2",
	"item_moon_shard"
	--"item_satanic",
};			

X["builds"] = {
	{1,3,3,1,3,4,3,1,1,2,4,2,2,2,4},
	{1,3,1,3,1,4,1,3,3,2,4,2,2,2,4},
	{1,3,3,2,1,4,1,3,1,3,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,8}, talents
);

return X