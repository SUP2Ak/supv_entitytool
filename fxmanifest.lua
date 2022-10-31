fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'SUP2Ak'
version '0.0'
link 'https://github.com/SUP2Ak/supv_entitytool'

description 'a nice tool'

shared_scripts {
    '@supv_core/import.lua', 
    '@ox_lib/init.lua',
    '_g.lua',
    'config/shared.lua'
}

client_scripts {
    'config/client.lua', 
    'main/client.lua'
}

server_scripts {
    'config/server.lua',
    'main/server.lua'
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/script.js',
}