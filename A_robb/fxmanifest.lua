fx_version 'cerulean'
game 'gta5'

name "A_robb"
description "Rob a Buisness"
author "AntoX"
version "1.0"

shared_scripts {
	'@es_extended/imports.lua',
	'shared/*.lua'
}


client_scripts {
	'client/*.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua'
}
