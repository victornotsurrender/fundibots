X = {}
local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_soul_ring",
	"item_travel_boots",
	"item_aether_lens",
	"item_ultimate_scepter",
	"item_blink",
	"item_kaya",
	"item_dagon_5",
	"item_kaya_and_sange",
	"item_arcane_blink",
	"item_ultimate_scepter_2",
	"item_sheepstick",
	"item_octarine_core"
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