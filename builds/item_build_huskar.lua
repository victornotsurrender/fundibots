X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_power_treads_str",
	--"item_armlet",
	--"item_dragon_lance",
	"item_ultimate_scepter",
	"item_heavens_halberd",
	"item_black_king_bar",
	"item_abyssal_blade",
	--"item_hurricane_pike",
	"item_satanic",
	"item_ultimate_scepter_2",
	"item_assault",
	"item_moon_shard"
};			

X["builds"] = {
	{2,3,2,1,2,4,2,3,3,3,4,1,1,1,4},
	{2,3,3,1,3,4,3,1,1,1,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,8}, talents
);

return X