X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_int",
	"item_orchid",
	"item_blink";
	--"item_cyclone",
	"item_mjollnir",
	"item_ultimate_scepter",
	"item_sphere",
	"item_bloodthorn",
	"item_ultimate_scepter_2",
	"item_black_king_bar",
	"item_arcane_blink",
	"item_moon_shard"
};			

X["builds"] = {
	{1,2,1,3,3,4,3,3,2,2,4,2,1,1,4},
	{2,1,3,3,3,4,3,1,2,2,4,2,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,6,8}, talents
);

return X