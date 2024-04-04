X = {}
local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_agi",
	"item_hand_of_midas",
	"item_glimmer_cape",
	"item_rod_of_atos",
	"item_orchid",
	"item_ghost",
	"item_bloodthorn",
	"item_ethereal_blade"
	"item_gungir",
	"item_ultimate_scepter_2",
	"item_moon_shard"
};

X["builds"] = {
	{1,2,1,3,1,4,1,2,2,2,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,4,6,8}, talents
);

return X