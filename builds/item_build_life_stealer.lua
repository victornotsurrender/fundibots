X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_phase_boots",
	--"item_orb_of_corrosion",
	"item_hand_of_midas",
	"item_radiance",
	"item_maelstrom",
	"item_basher",
	"item_mjollnir",
	"item_assault",
	"item_abyssal_blade",
	"item_monkey_king_bar",
	--"item_heavens_halberd",
	"item_moon_shard"
};			

X["builds"] = {
	{2,3,1,1,1,4,1,3,3,3,4,2,2,2,4},
	{2,3,1,1,1,4,1,2,2,2,4,3,3,3,4},
	{2,3,2,1,2,4,2,1,1,1,4,3,3,3,4},
	{2,3,2,1,1,4,1,1,3,3,4,3,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,4,5,7}, talents
);

return X