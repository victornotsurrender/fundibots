X = {}
local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_agi",
	"item_dragon_lance",
	"item_desolator",
	"item_blink",
	"item_black_king_bar",
	"item_greater_crit",
	"item_hurricane_pike",
	"item_monkey_king_bar",
	"item_swift_blink",
	"item_ultimate_scepter_2",
	"item_moon_shard"
	
};			

X["builds"] = {
	{3,1,1,3,1,4,1,2,2,2,4,2,3,3,4},
	{1,3,1,2,3,4,1,1,2,2,4,2,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,6,7}, talents
);

return X