local U = {}

local dota2team = {

	[1] = {
		['name'] = "Navi TI1";
		['alias'] = "Na'Vi";
		['players'] = {
			'Artstyle.Darer',
			'Puppey',
			'Dendi',
			'LightToHeaveN',
			'XBOCT'
		};
		['sponsorship'] = '';
	},
	[2] = {
		['name'] = "Fumao";
		['alias'] = "Fumao";
		['players'] = {
			'Marihuano',
			'Drogui',
			'CafeXEver',
			'Dotero',
			'Fapper'
		};
		['sponsorship'] = '';
	},
	[3] = {
		['name'] = "IG TI2";
		['alias'] = "iG";
		['players'] = {
			'Zhou',
			'Ferrari_430',
			'YYF',
			'ChuaN',
			'Faith'
		};
		['sponsorship'] = '';
	},
	[4] = {
		['name'] = "Navi TI2";
		['alias'] = "Na'Vi";
		['players'] = {
			'XBOCT',
			'Dendi',
			'LightToHeaveN',
			'Puppey',
			'ARS-ART'
		};
		['sponsorship'] = '';
	},
	[5] = {
		['name'] = "Naruto";
		['alias'] = "Naruto";
		['players'] = {
			'Madara',
			'Naruto',
			'Hashirama',
			'Shikamaru',
			'Obito'
		};
		['sponsorship'] = '';
	},
	[6] = {
		['name'] = "Bahia1";
		['alias'] = "";
		['players'] = {
			'Oriol Bot',
			'Bah3l Bot',
			'_yo_ Bot',
			'Ariel Bot',
			'Lawliet Bot'
		};
		['sponsorship'] = '';
	},
	[7] = {
		['name'] = "Newbee TI4";
		['alias'] = "Newbee";
		['players'] = {
			'Hao',
			'Mu',
			'xiao8',
			'Banana',
			'SanSheng'
		};
		['sponsorship'] = '';
	},
	[8] = {
		['name'] = "VG TI4";
		['alias'] = "VG";
		['players'] = {
			'Sylar',
			'Super',
			'rOtk',
			'fy',
			'Fenrir'
		};
		['sponsorship'] = '';
	},
	[9] = {
		['name'] = "Evil Geniuses TI5";
		['alias'] = "EG";
		['players'] = {
			'Fear',
			'SumaiL.Coffin',
			'UNiVeRsE',
			'Aui_2000',
			'ppd'
		};
		['sponsorship'] = '';
	},
	[10] = {
		['name'] = "Bahia2";
		['alias'] = "";
		['players'] = {
			'Fundi Bot',
			'Hattori Bot',
			'Maxwell Bot',
			'Fokin Bot',
			'Jorge Bot'
		};
		['sponsorship'] = '';
	},
	[11] = {
		['name'] = "Wings Gaming TI6";
		['alias'] = "Wings";
		['players'] = {
			'shadow',
			'跳刀跳刀丶.bLink',
			'Faith_bian.Vicky',
			'y`.innocence',
			'iceice'
		};
		['sponsorship'] = '';
	},
	[12] = {
		['name'] = "Comunista";
		['alias'] = "Rojo";
		['players'] = {
			'Marx',
			'Lenin',
			'Stalin',
			'Mao',
			'Trotski'
		};
		['sponsorship'] = '';
	},
	[13] = {
		['name'] = "Team Liquid TI7";
		['alias'] = "Liquid";
		['players'] = {
			'MATUMBAMAN',
			'Miracle-',
			'MinD_ContRoL',
			'GH',
			'KuroKy'
		};
		['sponsorship'] = '';
	},
	[14] = {
		['name'] = "Newbee TI7";
		['alias'] = "Newbee";
		['players'] = {
			'Moogy',
			'Sccc',
			'kpii',
			'Kaka',
			'Faith'
		};
		['sponsorship'] = '';
	},
	[15] = {
		['name'] = "OG TI8";
		['alias'] = "OG";
		['players'] = {
			'ana',
			'Topson',
			'7ckngMad',
			'JerAx',
			'N0tail'
		};
		['sponsorship'] = '';
	},
	[16] = {
		['name'] = "Nobel";
		['alias'] = "Nobel";
		['players'] = {
			'Einstein',
			'Bohr',
			'Marie Curie',
			'Heisemberg',
			'Oppenheimer'
		};
		['sponsorship'] = '';
	},
	[17] = {
		['name'] = "Nadie";
		['alias'] = "Nadie";
		['players'] = {
			'Fulano',
			'Ciclano',
			'Menganejo',
			'Esperanzejo',
			'Futano'
		};
		['sponsorship'] = '';
	},
	[18] = {
		['name'] = "Linux";
		['alias'] = "Linux";
		['players'] = {
			'Tux',
			'GNU',
			'Torvalds',
			'Kali',
			'Stallman'
		};
		['sponsorship'] = '';
	},
	[19] = {
		['name'] = "Bleach";
		['alias'] = "Bleach";
		['players'] = {
			'Ichigo',
			'Yamamoto',
			'Kempachi',
			'Byakuga',
			'Quincy'
		};
		['sponsorship'] = '';
	},
	[20] = {
		['name'] = "One Piece";
		['alias'] = "OP";
		['players'] = {
			'Luffy',
			'Kaido',
			'Big Mom',
			'Shirohige',
			'Borsalino'
		};
		['sponsorship'] = '';
	},
	[21] = {
		['name'] = "Cuba";
		['alias'] = "PCC";
		['players'] = {
			'Canelo',
			'Marrero',
			'Castro',
			'Gil',
			'Lazo'
		};
		['sponsorship'] = '';
	},
	[22] = {
		['name'] = "History";
		['alias'] = "";
		['players'] = {
			'Sun Tzu',
			'Julio Cesar',
			'Alejandro Magno',
			'Napoleon',
			'Victoria'
		};
		['sponsorship'] = '';
	},
	[23] = {
		['name'] = "Nazi";
		['alias'] = "Nazi";
		['players'] = {
			'Goebbels',
			'Hitler',
			'Bormann',
			'Paulus',
			'Banderas'
		};
		['sponsorship'] = '';
	},
	[24] = {
		['name'] = "America";
		['alias'] = "America";
		['players'] = {
			'Washington',
			'Lincoln',
			'Trump',
			'JFK',
			'Teddy'
		};
		['sponsorship'] = '';
	},
	[25] = {
		['name'] = "GOT";
		['alias'] = "GOT";
		['players'] = {
			'Daenerys',
			'Jon Snow',
			'The Mountain',
			'R.R. Martin',
			'Tyrion'
		};
		['sponsorship'] = '';
	},
	[26] = {
		['name'] = "Shogun";
		['alias'] = "Shogun";
		['players'] = {
			'Shimozuma Jutsurai',
			'Date Masamune',
			'Takeda Shingen',
			'Hattori Hanzo',
			'Uesugi Kenshin'
		};
		['sponsorship'] = '';
	},
	[27] = {
		['name'] = "Instec";
		['alias'] = "Instec";
		['players'] = {
			'Alfo',
			'Ravelo',
			'Piskunov',
			'German',
			'Maikel'
		};
		['sponsorship'] = '';
	},
	[28] = {
		['name'] = "Apostoles";
		['alias'] = "Ap";
		['players'] = {
			'Mateo',
			'Pablo',
			'Pedro',
			'Juan',
			'Judas'
		};
		['sponsorship'] = '';
	},
	[29] = {
		['name'] = "Cuba";
		['alias'] = "";
		['players'] = {
			'Canel',
			'Marrero',
			'Castro',
			'Lazo',
			'Gil'
		};
		['sponsorship'] = '';
	},
	[30] = {
		['name'] = "Ajedrez";
		['alias'] = "Chess";
		['players'] = {
			'Capablanca',
			'Kasparov',
			'Karpov',
			'Carlsen',
			'Fischer'
		};
		['sponsorship'] = '';
	},
	[31] = {
		['name'] = "LOTR";
		['alias'] = "LOTR";
		['players'] = {
			'Gandalf',
			'Sauron',
			'Saruman',
			'Aragorn',
			'Legolas'
		};
		['sponsorship'] = '';
	},
	[32] = {
		['name'] = "Cuba2";
		['alias'] = "Cuba";
		['players'] = {
			'Apagon',
			'Moringa',
			'DPEPDPE',
			'ETECSA',
			'Hambre'
		};
		['sponsorship'] = '';
	},
	[33] = {
		['name'] = "Poet";
		['alias'] = "Poet";
		['players'] = {
			'Quevedo',
			'Garcia Lorca',
			'Marti',
			'Ruben Dario',
			'Guillen'
		};
		['sponsorship'] = '';
	},
	[34] = {
		['name'] = "Atomo";
		['alias'] = "Atomo";
		['players'] = {
			'Neutron',
			'Electron',
			'Proton',
			'Foton',
			'Quarks'
		};
		['sponsorship'] = '';
	},
	[35] = {
		['name'] = "Inclusivo";
		['alias'] = "Inclusivo";
		['players'] = {
			'Nigga',
			'Vegano',
			'Feminista',
			'Gay',
			'Chino'
		};
		['sponsorship'] = '';
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}

local sponsorship = {""};

function U.GetDota2Team()
	local bot_names = {};
	local rand = RandomInt(1, #dota2team); 
	local srand = RandomInt(1, #sponsorship); 
	if GetTeam() == TEAM_RADIANT then
		while rand%2 ~= 0 do
			rand = RandomInt(1, #dota2team); 
		end
	else
		while rand%2 ~= 1 do
			rand = RandomInt(1, #dota2team); 
		end
	end
	local team = dota2team[rand];
	for _,player in pairs(team.players) do
		if team.alias == "" then
			table.insert(bot_names, team.alias..""..player..""..sponsorship[srand]);
		else
			table.insert(bot_names, team.alias.."."..player..""..team.sponsorship);
		end
	end
	return bot_names;
end

return U
