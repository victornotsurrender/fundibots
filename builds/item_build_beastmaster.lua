X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(2));

X["items"] = {
	"item_magic_wand",
	"item_phase_boots",
	"item_orb_of_corrosion",
	"item_medallion_of_courage",
	"item_blink",
	"item_vladmir",
	"item_pipe",
	"item_solar_crest",
	"item_ultimate_scepter_2",
	"item_helm_of_the_overlord",
	"item_assault",
	"item_overwhelming_blink",
	"item_aghanims_shard",
	"item_moon_shard"
	--"item_shivas_guard"
	-- "item_bloodthorn",
	--"item_vladmir",
	-- "item_black_king_bar",
	-- "item_necronomicon_3",
	--"item_heavens_halberd",
	-- "item_armlet",
};

X["builds"] = {
	{1,3,1,3,1,4,1,3,3,2,4,2,2,2,4},
	{1,3,1,2,1,4,1,2,2,2,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,5,7}, talents
);

return X