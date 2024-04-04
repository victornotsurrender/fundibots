X = {}
local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_tranquil_boots",
	--"item_phase_boots",
	"item_vanguard",
	"item_hood_of_defiance",
	"item_blink",
	"item_radiance",
	"item_pipe",
	--"item_crimson_guard",
	"item_heart",
	"item_abyssal_blade",
	"item_overwhelming_blink",
	--"item_shivas_guard",
	"item_ultimate_scepter_2",
	"item_moon_shard"
};	
			
X["builds"] = {
	{1,2,2,3,2,4,2,1,1,1,4,3,3,3,4},
	{1,3,2,2,2,4,2,1,1,1,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,5,8}, talents
);

return X