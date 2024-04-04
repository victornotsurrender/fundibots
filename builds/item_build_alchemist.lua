X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	--"item_phase_boots",
	--"item_radiance",
	"item_power_treads_str",
	"item_radiance",
	"item_lesser_crit",
	"item_manta",
	"item_black_king_bar",
	"item_basher",
	"item_greater_crit",
	"item_abyssal_blade",
	"item_moon_shard",
	"item_ultimate_scepter_2"
};

X["builds"] = {
	{3,1,3,2,3,4,3,1,1,1,4,2,2,2,4},
	{3,1,3,1,3,4,3,1,1,2,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,7}, talents
);			

return X