fx_version 'cerulean'
game 'gta5'

description 'Renewed Banking'
Author "RenewedScripts"
version '2.1.0'

lua54 'yes'
use_experimental_fxv2_oal 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
    'modules/targets/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'web/public/index.html'
files {
  'web/public/index.html',
  'web/public/**/*',
  'locales/*.json'
}

dependencies {
    '/server:5848',
    '/onesync',
    'oxmysql',
    'ox_lib',
    'Renewed-Lib'
}

provide 'qb-management'
provide 'esx_society'