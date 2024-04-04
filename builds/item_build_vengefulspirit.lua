X = {}
local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_agi",
	"item_medallion_of_courage",
	"item_blink",
	"item_force_staff",
	"item_desolator",
	"item_solar_crest",
	--"item_ultimate_scepter",
	--"item_cyclone",
	"item_hurricane_pike",
	"item_monkey_king_bar",
	"item_ultimate_scepter_2",
	"item_aghanims_shard",
	"item_moon_shard"
};			

X["builds"] = {
	{1,2,1,3,1,4,1,2,2,2,4,3,3,3,4},
	{1,2,1,3,1,4,1,3,3,3,4,2,2,2,4},
	{1,2,2,3,3,4,2,3,2,3,4,1,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,4,5,8}, talents
);

return X