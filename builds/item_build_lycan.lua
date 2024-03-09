X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_str",
	"item_echo_sabre",
	"item_orb_of_corrosion",
	"item_solar_crest",
	"item_helm_of_the_dominator",
	--"item_desolator",
	"item_black_king_bar",
	"item_helm_of_the_overlord",
	-- "item_necronomicon_3",
	"item_ultimate_scepter_2",
	"item_abyssal_blade"
	
};			

X["builds"] = {
	{3,1,3,1,1,4,1,3,3,2,4,2,2,2,4},
	{3,2,3,2,3,4,3,2,2,1,4,1,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,5,7}, talents
);

return X