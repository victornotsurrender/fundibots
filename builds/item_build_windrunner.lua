X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_javelin",
	--"item_maelstrom",
	"item_force_staff",
	"item_black_king_bar",
	"item_monkey_king_bar",
	"item_blink",
	"item_ultimate_scepter",
	--"item_orchid",
	--"item_bloodthorn",
	"item_arcane_blink",
	--"item_mjollnir",
	"item_ultimate_scepter_2",
	"item_octarine_core",
	"item_hurricane_pike"
	
	
};			

X["builds"] = {
	{3,2,2,1,3,4,2,2,1,1,4,1,3,3,4},
	{2,3,2,1,2,4,2,3,3,3,4,1,1,1,4},
	{3,2,2,1,2,4,2,1,1,1,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,4,5,8}, talents
);

return X