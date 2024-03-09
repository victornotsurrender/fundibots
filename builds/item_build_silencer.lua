X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_int",
	"item_hurricane_pike",
	"item_rod_of_atos",
	"item_black_king_bar",
	"item_witch_blade",
	"item_sheepstick",
	"item_ultimate_scepter_2",
	"item_gungir",
	"item_aghanims_shard",
	"item_moon_shard"
	
};			

X["builds"] = {
	{1,3,1,3,1,4,1,3,3,2,4,2,2,2,4},
	{1,2,3,1,1,4,1,3,3,3,4,2,2,2,4},
	{1,2,3,1,3,4,1,3,1,3,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,4,5,7}, talents
);

return X