X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(2));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_agi",
	--"item_dragon_lance",
	"item_lifesteal",
	"item_yasha",
	--"item_sange_and_yasha",
	"item_sphere",
	--"item_black_king_bar",
	"item_skadi",
	"item_manta",
	--"item_greater_crit",
	"item_ethereal_blade",
	"item_satanic",
	"item_butterfly",
	--"item_hurricane_pike",
	"item_ultimate_scepter_2",
	"item_moon_shard"
};			

X["builds"] = {
	{3,1,3,2,3,2,3,2,2,4,4,1,1,1,4},
	{3,1,3,2,1,3,1,3,1,4,4,2,2,2,4},
	{3,1,1,3,2,1,3,1,3,2,2,2,4,4,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,6,7}, talents
);

return X