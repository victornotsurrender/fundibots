X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = {
	"item_phase_boots",
	"item_vladmir",
	"item_radiance",
	"item_blink",
	"item_basher",
	"item_assault",
	--"item_black_king_bar",
	"item_abyssal_blade",
	"item_helm_of_the_overlord",
	--"item_lotus_orb",
	--"item_shivas_guard",
	"item_overwhelming_blink",
	"item_moon_shard",
	"item_ultimate_scepter_2",
	"item_aghanims_shard"
}; 

X["builds"] = {
	{1,3,1,3,1,4,1,3,3,2,4,2,2,2,4},
	{2,3,1,1,1,4,1,3,3,3,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,6,7}, talents
);

return X