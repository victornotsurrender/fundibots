X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_boots",
	"item_hand_of_midas",
	"item_power_treads_agi",
	"item_maelstrom",
	"item_dragon_lance",
	"item_gungir",
	"item_invis_sword",
	--"item_greater_crit",
	"item_bloodthorn",
	"item_silver_edge",
	"item_hurricane_pike",
	"item_abyssal_blade",
	"item_moon_shard",
	"item_aghanims_shard",
	"item_ultimate_scepter_2",
	"item_sheepstick"
};

X["builds"] = {
	{3,1,1,3,1,4,1,3,3,2,4,2,2,2,4},
	{3,1,3,1,1,4,1,3,3,2,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,5,8}, talents
);

return X