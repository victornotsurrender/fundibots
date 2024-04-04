X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_power_treads_str",
	"item_lifesteal",
	"item_blink",
	"item_lesser_crit",
	--"item_mask_of_madness",
	"item_black_king_bar",
	"item_desolator",
	"item_ultimate_scepter",
	"item_greater_crit",
	"item_satanic",
	"item_overwhelming_blink",
	"item_ultimate_scepter_2",
	"item_heart",
	"item_rapier",
	"item_moon_shard"
};			

X["builds"] = {
	{1,3,2,2,2,4,2,3,3,3,4,1,1,1,4},
	{1,3,1,2,1,4,1,2,2,2,4,3,3,3,4},
	{1,3,1,2,1,4,1,3,3,3,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,5,7}, talents
);

return X