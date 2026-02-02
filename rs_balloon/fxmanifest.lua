fx_version "adamant"
game "rdr3"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

client_scripts {
	"@uiprompt/uiprompt.lua",
	"client/client.lua",
	"client/utils.lua",
    'client/balloonanimations.lua',
}

shared_scripts {
	'translation/translation.lua',
	'config.lua'
}

server_scripts {
	'server/server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html'
}

lua54 'yes'

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 LXR Balloon System - The Land of Wolves
-- ═══════════════════════════════════════════════════════════════════════════════
author 'iBoss21 / The Lux Empire'
description 'Hot Air Balloon System for The Land of Wolves 🐺 | Georgian RP'
version '2.0.0'

-- Server Information
-- Server:      The Land of Wolves 🐺
-- Developer:   iBoss21 / The Lux Empire
-- Website:     https://www.wolves.land
-- Discord:     https://discord.gg/CrKcWdfd3A
-- GitHub:      https://github.com/iBoss21
-- Store:       https://theluxempire.tebex.io
-- 
-- © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
-- ═══════════════════════════════════════════════════════════════════════════════
