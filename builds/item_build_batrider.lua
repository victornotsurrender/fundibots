X = {}
local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = {
	"item_magic_wand",
	"item_tranquil_boots",
	"item_blink",
	"item_force_staff",
	"item_cyclone",
	"item_octarine_core",
	"item_lotus_orb",
	--"item_black_king_bar",
	"item_wind_waker",
	"item_hurricane_pike",
	"item_ultimate_scepter_2",
	--"item_shivas_guard",
	"item_arcane_blink",
	"item_aghanims_shard",
	"item_moon_shard"
		
};

X["builds"] = {
	{1,3,1,2,1,4,1,3,3,3,4,2,2,2,4},
	{1,3,1,3,3,4,3,1,1,2,4,2,2,2,4},
	{1,3,3,2,3,4,3,2,2,2,4,1,1,1,4},
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,5,7}, talents
);

return X