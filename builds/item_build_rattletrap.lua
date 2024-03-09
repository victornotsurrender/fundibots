X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	--"item_arcane_boots",
	"item_power_treads_str",
	"item_blade_mail",
	"item_force_staff",
	"item_lotus_orb",
	"item_ultimate_scepter",
	"item_hurricane_pike",
	"item_nullifier",
	"item_ultimate_scepter_2",
	"item_heart"
	--"item_octarine_core"
};			

X["builds"] = {
	{1,2,1,3,1,4,1,3,3,3,4,2,2,2,4},
	{2,1,1,3,1,4,1,3,3,3,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,4,6,8}, talents
);

return X