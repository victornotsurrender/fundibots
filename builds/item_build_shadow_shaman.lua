X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_aether_lens",
	"item_ultimate_scepter",
	"item_blink",
	"item_dagon_5",
	"item_octarine_core",
	"item_solar_crest",
	"item_ultimate_scepter_2",
	"item_necronomicon_3",
	"item_guardian_greaves",
	--"item_refresher",
	"item_arcane_blink",
	"item_moon_shard",
	"item_aghanims_shard"
};			

X["builds"] = {
	{1,3,1,2,1,4,1,2,2,2,4,3,3,3,4},
	{3,1,1,2,1,4,1,2,2,2,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,8}, talents
);

return X