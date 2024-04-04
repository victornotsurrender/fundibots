X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_urn_of_shadows",
	"item_arcane_boots",
	--"item_power_treads_str",
	"item_blade_mail",
	"item_lotus_orb",
	"item_spirit_vessel",
	"item_radiance",
	--"item_vanguard",
	"item_heart",
	"item_guardian_greaves",
	--"item_crimson_guard",
	"item_ultimate_scepter_2",
	"item_moon_shard"
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