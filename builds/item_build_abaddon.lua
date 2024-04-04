X = {}

local IBUtil  = require( "bots/ItemBuildUtility");
local npcBot  = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = {
	"item_magic_wand",
	--"item_headdress",
	"item_phase_boots",
	"item_hand_of_midas",
	-- "item_orb_of_corrosion",
	"item_blade_mail",
	--"item_echo_sabre",
	"item_lotus_orb",
	"item_manta",
	"item_basher",
	--"item_skadi",
	--"item_mask_of_madness",	
	-- "item_holy_locket",
	--"item_kaya_and_sange",
	--"item_assault",
	"item_abyssal_blade",
	"item_moon_shard",
	"item_ultimate_scepter_2"
	--"item_shivas_guard"
};

X["builds"] = {
	{1,2,3,3,2,4,2,3,3,2,4,1,1,1,4},
	{2,1,3,2,2,4,2,1,1,1,4,3,3,3,4},
	{1,2,1,2,3,4,1,2,1,2,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,6,8}, talents
	  -- {1,2,3,4,5,6,7,8}, talents
);

return X