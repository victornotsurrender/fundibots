X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_agi",
	--"item_falcon_blade",
	"item_dragon_lance",
	"item_mask_of_madness",
	"item_desolator",
	--"item_orchid",
	--"item_black_king_bar",
	--"item_monkey_king_bar",
	"item_bloodthorn",
	"item_greater_crit",
	"item_sheepstick",
	"item_ultimate_scepter_2",
	"item_moon_shard",
	--"item_hurricane_pike",
	"item_abyssal_blade"
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