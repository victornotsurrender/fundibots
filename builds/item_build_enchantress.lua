X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_power_treads_int",
	"item_hand_of_midas",
	"item_dragon_lance",
	"item_witch_blade",
	"item_hurricane_pike",
	"item_bloodthorn",
	"item_sphere",
	"item_ultimate_scepter_2",
	"item_sheepstick",
	"item_moon_shard"
	--"item_shivas_guard"
};			

X["builds"] = {
	{3,1,1,3,1,4,1,3,3,2,4,2,2,2,4},
	{3,1,1,2,1,4,1,3,3,3,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,7}, talents
);

return X