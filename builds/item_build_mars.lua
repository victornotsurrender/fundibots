X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	--"item_magic_wand",
	"item_arcane_boots",
	"item_blink",
	--"item_lotus_orb",
	"item_desolator",
	--"item_black_king_bar",
	--"item_hood_of_defiance",
	"item_pipe",
	"item_abyssal_blade",
	"item_guardian_greaves",
	"item_heavens_halberd",
	"item_overwhelming_blink",
	"item_ultimate_scepter_2",
	"item_moon_shard"
};			

X["builds"] = {
	{2,1,2,3,2,4,2,1,1,1,4,3,3,3,4},
	{2,1,2,1,2,4,1,2,1,3,4,3,3,3,4},
	{2,3,3,2,1,4,2,3,2,3,4,1,1,1,4},
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,4,6,7}, talents
);

return X