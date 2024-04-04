X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_arcane_boots",
	"item_hand_of_midas",
	"item_blade_mail",
	"item_ultimate_scepter",
	"item_mekansm",
	--"item_holy_locket",
	"item_lotus_orb",
	"item_pipe",
	"item_guardian_greaves",
	"item_ultimate_scepter_2",
	"item_heart",
	"item_moon_shard"
};			

X["builds"] = {
	{1,2,2,3,2,4,2,3,3,3,4,1,1,1,4},
	{1,2,2,3,3,4,2,3,2,3,4,1,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,5,7}, talents
);

return X