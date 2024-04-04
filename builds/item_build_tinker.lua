X = {}
local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_travel_boots",
	"item_aether_lens",
	"item_dagon_5",
	"item_sheepstick",
	"item_ultimate_scepter",
	"item_gungir",
	"item_ultimate_scepter_2",
	"item_bloodthorn",
	"item_octarine_core",
	"item_aghanims_shard",
	"item_moon_shard"
};			

X["builds"] = {
	{1,2,1,2,1,2,1,2,4,3,3,4,3,3,4},
	{1,2,1,3,3,3,4,3,2,2,2,4,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,8}, talents
);

return X