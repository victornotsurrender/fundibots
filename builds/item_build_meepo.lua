X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

--[[ NOT SURE IF STILL AN ISSUE: warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will possilby break! ]]

X["items"] = { 
	"item_power_treads",
	"item_sange_and_yasha",
	"item_skadi",
	"item_blink",
	"item_ultimate_scepter",
	"item_sheepstick",
	"item_swift_blink",
	--"item_heart",
	"item_ultimate_scepter_2",
	"item_bloodthorn",
	--"item_octarine_core"
};			

X["builds"] = {
	{2,1,4,2,2,3,2,3,3,4,3,1,1,1,4},
	{2,1,4,2,2,3,2,1,1,4,3,3,1,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "meepo", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,5,7}, talents
);

return X