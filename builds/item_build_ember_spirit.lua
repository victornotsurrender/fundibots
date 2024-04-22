X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	--"item_orb_of_corrosion",
	"item_pers",
	"item_maelstrom",
	"item_blink",
	"item_bfury",
	--"item_lesser_crit",
	--"item_shivas_guard",
	"item_greater_crit",
	"item_gungir",
	--"item_sphere",
	"item_ultimate_scepter_2",
	"item_swift_blink",
	"item_rapier",
	--"item_mjollnir",
	"item_moon_shard"
};			

X["builds"] = {
	{3,1,3,1,3,4,3,2,1,1,4,2,2,2,4},
	{3,1,3,2,3,4,3,1,1,1,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,5,7}, talents
);

return X