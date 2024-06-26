X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_tranquil_boots",
	"item_glimmer_cape",
	"item_ultimate_scepter",
	"item_aether_lens",
	"item_force_staff",
	"item_dagon_5",
	"item_hurricane_pike",
	"item_ultimate_scepter_2",
	"item_sheepstick",
	"item_octarine_core",
	"item_moon_shard"
};			

X["builds"] = {
	{2,1,1,2,1,4,1,2,2,3,4,3,3,3,4},
	{1,2,1,3,1,4,1,2,2,3,4,2,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,5,8}, talents
);

return X