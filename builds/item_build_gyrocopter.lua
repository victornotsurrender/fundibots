X = {}
local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	--"item_phase_boots",
	"item_power_treads_agi",
	"item_maelstrom",
	"item_lifesteal",
	"item_ultimate_scepter",
	"item_black_king_bar",
	"item_greater_crit",
	"item_satanic",
	"item_butterfly",
	"item_mjollnir",
	"item_ultimate_scepter_2",
	"item_moon_shard",
	"item_aghanims_shard",
	"item_monkey_king_bar"
};			

X["builds"] = {
	{1,2,1,3,1,4,1,3,3,3,4,2,2,2,4},
	{2,1,1,3,1,4,1,3,3,3,4,2,2,2,4},
	{1,2,1,3,1,4,1,2,2,2,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,8}, talents
);

return X