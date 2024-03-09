X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_echo_sabre",
	"item_ancient_janggo",
	"item_vladmir",
	"item_sange_and_yasha",
	"item_ultimate_scepter",
	"item_assault",
	"item_ultimate_scepter_2",
	"item_monkey_king_bar"
};			

X["builds"] = {
	{2,1,2,1,1,4,1,3,3,3,4,3,2,2,4},
	{1,2,1,3,1,4,1,3,3,3,4,2,2,2,4},
	{2,1,3,1,2,4,1,2,1,2,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,7}, talents
);

return X;