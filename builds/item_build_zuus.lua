X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_aether_lens",
	"item_cyclone",
	"item_veil_of_discord",
	"item_ultimate_scepter",
	--"item_blink",
	"item_bloodstone",
	"item_octarine_core",
	"item_ultimate_scepter_2",
	"item_sheepstick",
	"item_wind_waker",
	"item_guardian_greaves",
	"item_aghanims_shard",
	"item_moon_shard"
	--"item_silver_edge"
};			

X["builds"] = {
	{1,2,2,1,2,4,2,1,1,3,4,3,3,3,4},
	{1,2,2,3,2,4,2,1,1,1,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,7}, talents
);

return X