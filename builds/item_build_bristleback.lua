X = {}
local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_vanguard",
	"item_blade_mail",
	--"item_voodoo_mask",
	"item_eternal_shroud",
	"item_heart",
	"item_guardian_greaves",
	--"item_pipe",
	"item_crimson_guard",
	"item_bloodstone",
	"item_ultimate_scepter_2",
	"item_aghanims_shard",
	"item_moon_shard"
	--"item_shivas_guard"
	--"item_octarine_core"
};

X["builds"] = {
	{2,3,2,3,2,4,2,3,3,1,4,1,1,1,4},
	{2,3,2,3,2,4,2,1,3,3,4,1,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,7}, talents
);

return X