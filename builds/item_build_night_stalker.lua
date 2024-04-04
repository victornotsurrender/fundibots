X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	--"item_urn_of_shadows",
	--"item_spirit_vessel",
	"item_basher",
	--"item_blink",
	"item_black_king_bar",
	--"item_solar_crest",
	"item_greater_crit",
	"item_assault",
	--"item_overwhelming_blink",
	"item_abyssal_blade",
	"item_sphere",
	"item_ultimate_scepter_2",
	"item_moon_shard"
};			

X["builds"] = {
	{1,3,1,2,1,4,1,3,3,3,4,2,2,2,4},
	{1,3,1,3,1,4,1,2,3,3,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,6,8}, talents
);

return X