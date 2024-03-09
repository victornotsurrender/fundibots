X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_agi",
	"item_falcon_blade",
	"item_dragon_lance",
	"item_desolator",
	--"item_orchid",
	"item_black_king_bar",
	"item_monkey_king_bar",
	--"item_bloodthorn",
	"item_ultimate_scepter_2",
	"item_sheepstick",
	"item_hurricane_pike"
};

X["builds"] = {
	{2,1,2,3,2,4,2,1,1,1,4,3,3,3,4},
	{2,3,2,1,2,4,2,1,1,1,4,3,3,3,4},
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,4,6,8}, talents
);

return X