X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_power_treads_agi",
	"item_diffusal_blade",
	"item_greater_crit",
	"item_ultimate_scepter",
	"item_abyssal_blade",
	"item_skadi",
	"item_ultimate_scepter_2",
	"item_butterfly",
	"item_moon_shard"
};			

X["builds"] = {
	{3,2,1,3,3,4,3,2,2,2,4,1,1,1,4},
	{3,1,3,2,3,4,3,2,1,2,4,1,2,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,8}, talents
);

return X