fx_version 'cerulean'
game 'gta5'

author 'Hoàng Đức'
version '1.1.0'
description 'MojiaGarages - Best advanced garages for QB-Core Framework'

shared_scripts {
    'config.lua',
    '@qb-core/shared/locale.lua',
    'locales/en.lua' -- Change this to your preferred language
}
client_scripts {
    '@PolyZone/client.lua',
	'client.lua'
}
server_script {
	'@oxmysql/lib/MySQL.lua',
    'server.lua'
}

lua54 'yes'
