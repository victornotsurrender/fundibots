X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot  = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	--"item_tranquil_boots",
	"item_power_treads_str",
	"item_vanguard",
	"item_blink",
	"item_blade_mail",
	"item_black_king_bar",
	"item_overwhelming_blink",
	--"item_manta",
	--"item_abyssal_blade",
	--"item_swift_blink",
	"item_crimson_guard",
	"item_ultimate_scepter_2",
	"item_shivas_guard",
	"item_travel_boots",
	"item_heart"
	
	--"item_lotus_orb"
};			

X["builds"] = {
	{3,1,3,2,3,4,3,1,1,1,4,2,2,2,4},
	{3,1,3,2,3,4,3,1,1,1,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,5,7}, talents
);

return X