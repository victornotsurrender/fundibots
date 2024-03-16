X = {}
local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_power_treads_str",
	--"item_vanguard",
	"item_blade_mail",
	"item_blink",
	"item_desolator",
	"item_greater_crit",
	"item_ultimate_scepter",
	--"item_black_king_bar",
	--"item_invis_sword",
	--"item_bloodthorn",
	--"item_silver_edge",
	--"item_travel_boots",
	--"item_assault",
	"item_ultimate_scepter_2",
	"item_abyssal_blade",
	"item_overwhelming_blink",
	"item_moon_shard",
	"item_aghanims_shard"
	--"item_monkey_king_bar"
};			

X["builds"] = {
	{1,3,1,2,1,4,1,2,2,2,4,3,3,3,4},
	{3,2,3,2,3,4,3,2,2,1,4,1,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,6,7}, talents
);

return X