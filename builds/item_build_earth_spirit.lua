X = {}
local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_glimmer_cape",
	--"item_power_treads_str",
	"item_spirit_vessel",
	"item_vanguard",
	"item_lotus_orb",
	--"item_blink",
	"item_heavens_halberd",
	"item_crimson_guard",
	--"item_octarine_core",
	--"item_black_king_bar",
	--"item_overwhelming_blink",
	--"item_shivas_guard",
	"item_ultimate_scepter_2",
	"item_moon_shard"
	--"item_hurricane_pike"
	
};			

X["builds"] = {
	{2,1,1,3,1,4,1,3,3,3,4,2,2,2,4},
	{2,1,3,1,1,4,1,3,3,3,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,5,7}, talents
);

return X