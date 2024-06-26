X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_tranquil_boots",
	"item_blink",
	"item_aether_lens",
	"item_ultimate_scepter",
	--"item_force_staff",
	"item_dagon_5",
	"item_aeon_disk",
	"item_ethereal_blade",
	"item_ultimate_scepter_2",
	"item_octarine_core",
	"item_arcane_blink",
	"item_moon_shard"
	--"item_hurricane_pike",
	--"item_sheepstick",
	
};			

X["builds"] = {
	{1,2,1,3,1,4,1,3,3,3,4,2,2,2,4},
	{1,2,1,3,1,4,1,2,3,3,4,2,2,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,5,7}, talents
);

return X