X = {}
local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_mask_of_madness",
	--"item_vladmir",
	--"item_sange_and_yasha",
	"item_blink",
	"item_assault",
	"item_abyssal_blade",
	"item_monkey_king_bar",
	"item_swift_blink",
	"item_ultimate_scepter_2",
	"item_moon_shard",
	"item_aghanims_shard"
};			

X["builds"] = {
	{3,2,3,2,3,4,3,2,2,1,4,1,1,1,4},
	{3,1,3,2,1,4,3,1,3,1,4,2,2,2,4},
	{3,1,3,2,2,4,1,2,1,2,4,1,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,5,8}, talents
);

return X