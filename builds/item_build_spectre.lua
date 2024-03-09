X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	--"item_phase_boots",
	--"item_vanguard",
	--"item_diffusal_blade",
	"item_power_treads_agi",
	"item_mask_of_madness",
	"item_diffusal_blade",
	"item_manta",
	"item_skadi",
	"item_abyssal_blade",
	--"item_radiance",
	--"item_heart"
	"item_butterfly"
	
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