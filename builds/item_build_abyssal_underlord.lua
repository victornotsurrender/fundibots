X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = {
	"item_magic_wand",
	"item_arcane_boots",
	"item_voodoo_mask",
	"item_hood_of_defiance",
	"item_eternal_shroud",
	"item_vanguard",
	"item_lotus_orb",
	-- "item_pipe",
	"item_crimson_guard",
	"item_guardian_greaves",
	"item_shivas_guard",
	"item_heart",
	"item_moon_shard",
	"item_aghanims_shard",
	"item_ultimate_scepter",
	"item_ultimate_scepter_2"
	--"item_octarine_core"
}	

X["builds"] = {
	{3,1,1,3,1,2,1,4,2,2,4,2,3,3,4},
	{1,3,1,2,1,4,1,2,2,2,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,4,5,7}, talents
);

return X;