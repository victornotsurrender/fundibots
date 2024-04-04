X = {}
local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_str",
	"item_blink",
	"item_echo_sabre",
	--"item_kaya_and_sange",
	"item_greater_crit",
	"item_ultimate_scepter",
	"item_assault",
	"item_overwhelming_blink",
	"item_guardian_greaves",
	"item_ultimate_scepter_2",
	"item_sheepstick",
	"item_moon_shard",
	"item_aghanims_shard"
	
};			

X["builds"] = {
	{3,1,2,2,2,4,2,1,1,1,4,3,3,3,4},
	{3,1,2,1,2,4,1,2,1,2,4,3,3,3,4},
	{3,1,2,1,1,4,1,2,2,2,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,6,8}, talents
);

return X