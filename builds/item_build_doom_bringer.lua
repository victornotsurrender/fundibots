X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_sange",
	--"item_vanguard",
	--"item_blade_mail",
	--"item_invis_sword",
	"item_blink",
	"item_ultimate_scepter",
	"item_black_king_bar",
	"item_heavens_halberd",
	--"item_crimson_guard",
	"item_ultimate_scepter_2",
	"item_shivas_guard",
	"item_silver_edge",
	"item_overwhelming_blink"
};	

X["builds"] = {
	{3,1,2,2,2,4,2,3,3,3,4,1,1,1,4},
	{3,1,2,3,3,4,3,2,2,2,4,1,1,1,4},
	{1,3,1,2,1,4,1,2,2,2,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,4,6,7}, talents
);

return X