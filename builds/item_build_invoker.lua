X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_urn_of_shadows",
	--"item_ancient_janggo",
	"item_witch_blade",
	--"item_force_staff",
	"item_spirit_vessel",
	"item_black_king_bar",
	"item_ultimate_scepter",
	"item_octarine_core",
	"item_ultimate_scepter_2",
	"item_sheepstick",
	"item_moon_shard",
	"item_aghanims_shard"
	--"item_shivas_guard"
	--"item_hurricane_pike"
};			

X["builds"] = {
	{3,1,3,1,3,1,3,1,2,3,3,3,2,2,2,2,2,2,1,1,1},
	{1,2,1,2,1,2,1,2,3,2,2,2,3,3,3,1,1,1,3,3,3}
}

X["skills"] = IBUtil.GetBuildPattern(
	"invoker", 
	IBUtil.GetRandomBuild(X['builds']), skills, 
	{1,4,5,8}, talents
);

return X