X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_medallion_of_courage",
	"item_meteor_hammer",
	"item_radiance",
	"item_ultimate_scepter",
	"item_guardian_greaves",
	"item_abyssal_blade",
	--"item_refresher",
	"item_solar_crest",
	"item_ultimate_scepter_2",
	"item_sheepstick",
	"item_aghanims_shard",
	"item_moon_shard"	
};			

X["builds"] = {
	{1,2,1,3,3,4,3,3,2,2,4,2,1,1,4},
	{1,3,3,2,2,4,2,2,3,3,4,1,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,7}, talents
);

return X