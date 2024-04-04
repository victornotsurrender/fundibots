X = {}
local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = {
	--"item_magic_wand",
	"item_power_treads_agi",
	"item_ring_of_health",
	"item_bfury",
	"item_manta",
	"item_skadi",
	"item_abyssal_blade",
	"item_butterfly",
	"item_moon_shard",
	"item_ultimate_scepter_2"
};

X["builds"] = {
	{1,2,3,1,2,4,2,2,1,1,4,3,3,3,4},
	{2,1,1,3,1,4,1,2,2,2,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,4,6,7}, talents
);

return X