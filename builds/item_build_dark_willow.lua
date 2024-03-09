X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	--"item_arcane_boots",
	"item_power_treads_int",
	"item_rod_of_atos",
	"item_force_staff",
	"item_ultimate_scepter",
	"item_bloodthorn",
	--"item_aether_lens",
	--"item_cyclone",
	"item_bloodstone",
	"item_hurricane_pike",
	"item_ultimate_scepter_2",
	"item_gungir",
	"item_moon_shard",
	"item_sheepstick",
	"item_aghanims_shard"
	--"item_shivas_guard"
};			

X["builds"] = {
	{1,2,2,3,2,4,2,1,1,1,4,3,3,3,4},
	{1,2,3,1,1,4,1,3,3,3,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,8}, talents
);

return X