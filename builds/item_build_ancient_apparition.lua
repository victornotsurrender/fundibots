X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_tranquil_boots",
	"item_rod_of_atos",
	"item_hand_of_midas",
	--"item_glimmer_cape",
	"item_sheepstick",
	"item_ultimate_scepter",
	"item_force_staff",
	"item_hurricane_pike",
	"item_gungir",
	"item_ultimate_scepter_2",
	"item_aghanims_shard",
	"item_bloodthorn",
	"item_moon_shard"
	
};	

X["builds"] = {
	{3,1,1,2,1,4,1,2,2,2,4,3,3,3,4},
	{1,3,3,2,3,4,1,3,1,1,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,5,8}, talents
);

return X