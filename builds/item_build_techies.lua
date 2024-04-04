X = {}
local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_arcane_boots",
	"item_hand_of_midas",
	--"item_aether_lens",
	--"item_cyclone",
	"item_bloodstone",
	"item_dagon_5",
	"item_ultimate_scepter",
	--"item_heart",
	"item_octarine_core",
	"item_ultimate_scepter_2",
	"item_sheepstick",
	"item_guardian_greaves",
	"item_moon_shard"
	
};			

X["builds"] = {
	{1,3,1,3,1,4,1,3,3,2,4,2,2,2,4},
	{1,3,1,2,3,4,1,3,1,3,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,6,7}, talents
);

return X