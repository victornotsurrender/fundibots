X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_power_treads_agi",
	"item_blade_mail",
	"item_diffusal_blade",
	--"item_diffusal_blade",
	"item_radiance",
	"item_manta",
	"item_heart",
	--"item_vanguard",
	"item_abyssal_blade",
	--"item_butterfly",
	"item_ultimate_scepter_2",
	"item_aghanims_shard",
	"item_moon_shard"
	
};			

X["builds"] = {
	{1,2,1,3,1,4,1,2,2,2,4,3,3,3,4},
	{1,2,1,3,1,4,1,3,2,3,4,2,3,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,6,7}, talents
);

return X