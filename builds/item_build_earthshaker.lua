X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_blink",
	--"item_veil_of_discord",
	"item_ultimate_scepter",
	"item_bfury",
	--"item_cyclone",
	"item_greater_crit",
	"item_silver_edge",
	"item_ultimate_scepter_2",
	"item_rapier",
	--"item_force_staff",
	--"item_kaya_and_sange",
	"item_overwhelming_blink",
	--"item_hurricane_pike",
	"item_moon_shard",
	"item_aghanims_shard"
	--"item_octarine_core",
	--"item_wind_waker"
};			

X["builds"] = {
	{1,2,3,3,3,4,3,1,1,1,4,2,2,2,4},
	{1,2,3,1,1,4,1,3,3,3,4,2,2,2,4},
	{1,2,3,2,2,4,2,3,3,3,4,1,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,4,6,8}, talents
);

return X