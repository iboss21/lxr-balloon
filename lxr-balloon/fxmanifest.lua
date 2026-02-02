fx_version "adamant"
game "rdr3"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 RESOURCE NAME PROTECTION - DO NOT MODIFY
-- ═══════════════════════════════════════════════════════════════════════════════
-- This script is branded as LXR-BALLOON and must maintain this name.
-- Changing the resource name will break the script intentionally.
-- ═══════════════════════════════════════════════════════════════════════════════

local REQUIRED_RESOURCE_NAME = "lxr-balloon"
local currentResourceName = GetCurrentResourceName()

if currentResourceName ~= REQUIRED_RESOURCE_NAME then
    error(string.format([[
        
        ═══════════════════════════════════════════════════════════════════════════════
        🚫 RESOURCE NAME VIOLATION DETECTED! 🚫
        ═══════════════════════════════════════════════════════════════════════════════
        
        This resource MUST be named: "%s"
        Current resource name: "%s"
        
        ❌ The script will NOT start with an incorrect resource name.
        
        🐺 LXR Balloon System - The Land of Wolves
        This is a branded resource for wolves.land
        
        To fix this issue:
        1. Rename the resource folder to: %s
        2. Update your server.cfg: ensure %s
        3. Restart your server
        
        © 2026 iBoss21 / The Lux Empire | wolves.land
        Original Script © riversafe
        
        ═══════════════════════════════════════════════════════════════════════════════
        
    ]], REQUIRED_RESOURCE_NAME, currentResourceName, REQUIRED_RESOURCE_NAME, REQUIRED_RESOURCE_NAME))
    return
end

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

-- Original Author: riversafe (https://github.com/riversafe33)
-- Modified & Branded by: iBoss21 / The Lux Empire for The Land of Wolves

-- Server Information
-- Server:      The Land of Wolves 🐺
-- Developer:   iBoss21 / The Lux Empire
-- Website:     https://www.wolves.land
-- Discord:     https://discord.gg/CrKcWdfd3A
-- GitHub:      https://github.com/iBoss21
-- Store:       https://theluxempire.tebex.io
-- 
-- © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
-- Original Script © riversafe - https://github.com/riversafe33
-- ═══════════════════════════════════════════════════════════════════════════════
