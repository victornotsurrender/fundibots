X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_tranquil_boots",
	"item_glimmer_cape",
	"item_blink",
	"item_black_king_bar",
	"item_ultimate_scepter",
	"item_aether_lens",
	"item_ultimate_scepter_2",
	"item_shivas_guard",
	"item_octarine_core",
	"item_arcane_blink",
	"item_moon_shard",
	"item_aghanims_shard"
};			

X["builds"] = {
	{1,3,2,3,3,4,3,1,1,1,4,2,2,2,4},
	{2,3,1,3,3,4,3,1,1,1,4,2,2,2,4},
	{2,3,1,3,3,4,3,1,2,1,4,2,1,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,5,7}, talents
);

return X