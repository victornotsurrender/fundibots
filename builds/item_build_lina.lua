X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	--"item_arcane_boots",
	"item_phase_boots",
	"item_falcon_blade",
	"item_rod_of_atos",
	"item_witch_blade",
	"item_black_king_bar",
	--"item_cyclone",
	--"item_aether_lens",
	"item_gungir",
	"item_ultimate_scepter",
	--"item_shivas_guard",
	"item_sheepstick",
	"item_ultimate_scepter_2",
	"item_assault"
	--"item_octarine_core"
};			

X["builds"] = {
	{1,3,1,2,1,4,1,2,2,2,4,3,3,3,4},
	{1,2,1,3,1,4,1,2,2,2,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,5,7}, talents
);

return X