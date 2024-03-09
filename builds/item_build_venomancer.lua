X = {}
local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_boots",
	"item_veil_of_discord",
	"item_travel_boots",
	"item_bloodstone",
	"item_ultimate_scepter",
	"item_skadi",
	"item_dagon_5",
	"item_sphere",
	"item_ultimate_scepter_2",
	"item_aghanims_shard",
	"item_moon_shard"
	
};			

X["builds"] = {
	{1,2,1,2,1,4,1,2,2,3,4,3,3,3,4},
	{1,2,3,2,3,4,2,3,2,3,4,1,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,5,7}, talents
);

return X;