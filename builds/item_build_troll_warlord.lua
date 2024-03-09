X = {}
local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(2));

X["items"] = { 
	"item_magic_wand",
	--"item_phase_boots",
	"item_power_treads_agi",
	"item_bfury",
	"item_sange_and_yasha",
	"item_monkey_king_bar",
	"item_abyssal_blade",
	--"item_skadi",
	"item_butterfly",
	"item_ultimate_scepter_2",
	"item_aghanims_shard",
	"item_moon_shard"
};			

X["builds"] = {
	{1,2,3,3,3,1,3,4,1,1,4,2,2,2,4},
	{1,2,3,3,3,4,3,1,1,1,4,3,3,3,4},
	{1,2,3,3,2,4,3,2,3,2,4,1,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,4,6,8}, talents
);

return X