X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_hood_of_defiance",
	"item_bloodstone",
	"item_cyclone",
	"item_black_king_bar",
	"item_eternal_shroud",
	--"item_octarine_core",
	"item_ultimate_scepter_2",
	"item_shivas_guard",
	"item_wind_waker",
	"item_moon_shard",
	"item_aghanims_shard"
};			

X["builds"] = {
	{3,1,3,1,3,4,3,1,1,2,4,2,2,2,4},
	{1,3,3,1,3,4,3,1,1,2,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,5,8}, talents
);

return X