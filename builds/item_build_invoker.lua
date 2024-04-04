X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_hand_of_midas",
	"item_orchid",
	--"item_urn_of_shadows",
	--"item_ancient_janggo",
	--"item_force_staff",
	--"item_spirit_vessel",
	"item_black_king_bar",
	"item_manta",
	--"item_arcane_blink",
	--"item_octarine_core",
	"item_sheepstick",
	"item_bloodthorn",
	"item_moon_shard",
	"item_ultimate_scepter_2"
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