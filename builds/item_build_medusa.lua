X = {}
local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	--"item_phase_boots",
	"item_power_treads_agi",
	"item_mask_of_madness",
	"item_maelstrom",
	"item_dragon_lance",
	"item_ultimate_scepter",
	"item_yasha",
	--"item_mjollnir",
	"item_skadi",
	"item_manta",
	"item_ultimate_scepter_2",
	"item_greater_crit",
	--"item_butterfly",
	"item_hurricane_pike",
	"item_moon_shard",
	"item_aghanims_shard"
};			

X["builds"] = {
	{2,3,2,3,2,4,2,3,3,1,4,1,1,1,4},
	{2,3,2,1,3,4,2,3,2,3,4,1,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,7}, talents
);

return X