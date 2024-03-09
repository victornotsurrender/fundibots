X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_sange_and_yasha",
	"item_rod_of_atos",
	"item_black_king_bar",
	"item_gungir",
	"item_assault",
	--"item_heart",
	"item_ultimate_scepter_2",
	"item_greater_crit"
};			

X["builds"] = {
	{2,1,2,1,1,4,1,2,2,3,4,3,3,3,4},
	{2,1,2,3,2,4,2,1,1,1,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,8}, talents
);
return X