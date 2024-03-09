X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_orchid",
	"item_ultimate_scepter",
	--"item_arcane_boots",
	--"item_mekansm",
	-- "item_phase_boots",
	--"item_maelstrom",
	-- "item_cyclone",
	--"item_lesser_crit",
	"item_black_king_bar",
	"item_sheepstick",
	--"item_guardian_greaves",
	"item_ultimate_scepter_2",
	--"item_heart",
	--"item_shivas_guard",
	"item_greater_crit",
	"item_aghanims_shard",
	"item_moon_shard"
	--"item_mjollnir"
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