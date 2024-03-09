X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	--"item_arcane_boots",
	"item_power_treads_agi",
	"item_diffusal_blade",
	"item_vanguard",
	"item_mage_slayer",
	"item_maelstrom",
	"item_abyssal_blade",
	--"item_yasha_and_kaya",
	"item_mjollnir",
	"item_crimson_guard",
	"item_ultimate_scepter_2",
	"item_aghanims_shard",
	"item_moon_shard"
};			

X["builds"] = {
	{1,2,1,2,1,4,1,2,2,3,4,3,3,3,4},
	{1,3,1,2,1,4,1,2,2,2,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,5,8}, talents
);

return X