X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	
	"item_phase_boots",
	"item_power_treads_agi",
	"item_vladmir",
	"item_maelstrom",
	--"item_mask_of_madness",
	"item_ultimate_scepter",
	"item_skadi",
	"item_butterfly",
	--"item_helm_of_the_overlord",
	"item_abyssal_blade",
	"item_mjollnir",
	--"item_butterfly",
	"item_monkey_king_bar",
	"item_ultimate_scepter_2",
	"item_hurricane_pike",
	"item_moon_shard",
	"item_aghanims_shard"
};			

X["builds"] = {
	{1,2,1,3,1,4,1,2,2,2,4,3,3,3,4},
	{1,2,1,3,1,2,1,2,2,3,3,3,4,4,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,6,8}, talents
);

return X