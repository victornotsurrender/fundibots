X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_aether_lens",
	"item_glimmer_cape",
	--"item_meteor_hammer",
	"item_force_staff",
	"item_octarine_core",
	"item_guardian_greaves",
	"item_sheepstick",
	"item_ultimate_scepter",
	"item_arcane_blink",
	"item_hurricane_pike",
	"item_ultimate_scepter_2",
	"item_ethereal_blade",
	"item_moon_shard",
	"item_aghanims_shard"
};

X["builds"] = {
	{2,3,2,3,2,4,2,3,3,1,4,1,1,1,4},
	{3,2,2,1,1,4,2,2,1,1,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,4,5,8}, talents
);

return X