X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_hand_of_midas",
	"item_arcane_boots",
	"item_invis_sword",
	"item_sheepstick",
	"item_blink",
	"item_guardian_greaves",
	"item_shivas_guard",
	--"item_solar_crest",
	"item_arcane_blink",
	"item_ultimate_scepter_2",
	"item_moon_shard"
	
};

X["builds"] = {
	{1,3,3,2,3,4,3,2,2,2,4,1,1,1,4},
	{1,3,1,2,1,4,1,3,3,3,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,7}, talents
);

return X