fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'mack-Law fines and Doctor Charges'

client_scripts {
    'client/lclient.lua',
	'client/dclient.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/lserver.lua',
	'server/dserver.lua'
}

lua54 'yes'
