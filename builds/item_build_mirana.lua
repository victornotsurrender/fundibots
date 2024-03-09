X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads",
	"item_dragon_lance",
	"item_maelstrom",
	"item_yasha",
	"item_diffusal_blade",
	"item_manta",
	--"item_black_king_bar",
	"item_gungir",
	"item_bloodthorn",
	--"item_mjollnir",
	"item_hurricane_pike",
	"item_ultimate_scepter_2",
	"item_moon_shard",
	"item_aghanims_shard",
	--"item_monkey_king_bar",
	"item_skadi"
};			

X["builds"] = {
	{2,3,1,1,1,4,1,3,3,3,4,2,2,2,4},
	{3,2,1,1,1,4,1,3,3,3,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,5,8}, talents
);

return X