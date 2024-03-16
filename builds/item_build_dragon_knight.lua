X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_power_treads_str",
	"item_invis_sword",
	"item_blink",
	--"item_armlet",
	"item_ultimate_scepter",
	"item_black_king_bar",
	--"item_sange_and_yasha",
	"item_greater_crit",
	"item_silver_edge",
	"item_assault",
	"item_ultimate_scepter_2",
	"item_overwhelming_blink",
	"item_moon_shard",
	"item_aghanims_shard"
	--"item_heart",
};	

X["builds"] = {
	{1,3,1,3,1,4,2,1,3,3,4,2,2,2,4},
	{3,2,3,1,3,4,3,1,1,1,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,8}, talents
);

return X