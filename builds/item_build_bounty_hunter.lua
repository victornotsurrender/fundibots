X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_medallion_of_courage",
	"item_orb_of_corrosion",
	"item_desolator",
	"item_solar_crest",
	"item_orchid",
	"item_dagon_5",
	"item_ultimate_scepter",
	"item_ultimate_scepter_2",
	"item_moon_shard",
	"item_ethereal_blade",
	"item_bloodthorn",
	"item_aghanims_shard"
};

X["builds"] = {
	{3,2,1,1,1,4,1,3,3,3,4,2,2,2,4},
	{3,2,2,1,2,4,2,1,1,1,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,6,8}, talents
);

return X