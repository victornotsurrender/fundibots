local minionutils = dofile( "bots/NewMinionUtil" )

local bot = GetBot();

function MinionThink(  hMinionUnit ) 
	minionutils.MinionThink(bot, hMinionUnit);
end	