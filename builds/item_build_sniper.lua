X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_agi",
	"item_mask_of_madness",
	"item_invis_sword",
	"item_maelstrom",
	"item_dragon_lance",
	-- "item_black_king_bar",
	"item_mjollnir",
	"item_greater_crit",
	"item_silver_edge",
	"item_monkey_king_bar",
	"item_hurricane_pike"
};			

X["builds"] = {
	{2,1,1,3,1,4,1,3,3,3,4,2,2,2,4},
	{1,3,1,2,1,4,1,3,3,3,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,6,8}, talents
);

return X