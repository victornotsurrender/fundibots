X = {};

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_medallion_of_courage",
	"item_rod_of_atos",
	"item_radiance",
	"item_solar_crest",
	"item_ultimate_scepter",
	"item_bloodthorn",
	--"item_shivas_guard",
	"item_ultimate_scepter_2",
	"item_assault",
	"item_gungir",
	"item_guardian_greaves",
	"item_aghanims_shard",
	"item_moon_shard"
	--"item_monkey_king_bar"
};			

X["builds"] = {
	{1,2,1,3,1,4,1,3,3,3,4,2,2,2,4},
	{1,2,3,2,2,4,2,3,3,3,4,1,1,1,4},
	{1,2,3,2,3,4,2,3,2,3,4,1,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,4,5,8}, talents
);

return X