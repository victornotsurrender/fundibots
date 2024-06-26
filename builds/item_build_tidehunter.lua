X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_lifesteal",
	"item_blink",
	"item_pipe",
	--"item_aeon_disk",
	"item_ultimate_scepter",
	"item_guardian_greaves",
	"item_satanic",
	--"item_sheepstick",
	"item_shivas_guard",
	"item_overwhelming_blink",
	"item_ultimate_scepter_2",
	"item_moon_shard"
	--"item_octarine_core"
};			

X["builds"] = {
	{3,2,2,1,3,4,3,3,2,2,4,1,1,1,4},
	{1,3,1,2,3,4,1,3,1,3,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,5,7}, talents
);

return X