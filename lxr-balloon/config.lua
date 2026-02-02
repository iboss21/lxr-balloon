--[[
    ██╗      █████╗ ███╗   ██╗██████╗      ██████╗ ███████╗    ██╗    ██╗ ██████╗ ██╗    ██╗   ██╗███████╗███████╗
    ██║     ██╔══██╗████╗  ██║██╔══██╗    ██╔═══██╗██╔════╝    ██║    ██║██╔═══██╗██║    ██║   ██║██╔════╝██╔════╝
    ██║     ███████║██╔██╗ ██║██║  ██║    ██║   ██║█████╗      ██║ █╗ ██║██║   ██║██║    ██║   ██║█████╗  ███████╗
    ██║     ██╔══██║██║╚██╗██║██║  ██║    ██║   ██║██╔══╝      ██║███╗██║██║   ██║██║    ╚██╗ ██╔╝██╔══╝  ╚════██║
    ███████╗██║  ██║██║ ╚████║██████╔╝    ╚██████╔╝██║         ╚███╔███╔╝╚██████╔╝███████╗╚████╔╝ ███████╗███████║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝      ╚═════╝ ╚═╝          ╚══╝╚══╝  ╚═════╝ ╚══════╝ ╚═══╝  ╚══════╝╚══════╝
                                                                                                                    
    🐺 LXR Balloon System - Hot Air Balloon Configuration
    
    This configuration file controls all aspects of the hot air balloon system.
    Players can purchase, rent, and manage hot air balloons for scenic transportation.
    
    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════
    
    Server:      The Land of Wolves 🐺
    Tagline:     Georgian RP 🇬🇪 | მგლების მიწა - რჩეულთა ადგილი!
    Description: ისტორია ცოცხლდება აქ! (History Lives Here!)
    Type:        Serious Hardcore Roleplay
    Access:      Discord & Whitelisted
    
    Developer:   iBoss21 / The Lux Empire
    Website:     https://www.wolves.land
    Discord:     https://discord.gg/CrKcWdfd3A
    GitHub:      https://github.com/iBoss21
    Store:       https://theluxempire.tebex.io
    Server:      https://servers.redm.net/servers/detail/8gj7eb
    
    ═══════════════════════════════════════════════════════════════════════════════
    
    Version: 2.0.0
    Performance Target: Optimized for minimal server overhead and client FPS impact
    
    Tags: RedM, Georgian, SeriousRP, Whitelist, Transportation, Balloon, Economy
    
    Framework Support:
    - VORP Core (Primary)
    - RedEM:RP
    - Standalone
    
    ═══════════════════════════════════════════════════════════════════════════════
    CREDITS
    ═══════════════════════════════════════════════════════════════════════════════
    
    Original Script Author: riversafe (https://github.com/riversafe33)
    Modified & Branded by: iBoss21 / The Lux Empire for The Land of Wolves
    
    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
    Original Script © riversafe | With respect and appreciation
]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 RESOURCE NAME PROTECTION - RUNTIME CHECK
-- ═══════════════════════════════════════════════════════════════════════════════
-- Safeguard: Verify resource name at config load time
-- This prevents the script from functioning if renamed
-- ═══════════════════════════════════════════════════════════════════════════════

local REQUIRED_RESOURCE_NAME = "lxr-balloon"
local currentResourceName = GetCurrentResourceName()

if currentResourceName ~= REQUIRED_RESOURCE_NAME then
    error(string.format([[
        
        ═══════════════════════════════════════════════════════════════════════════════
        ❌ CRITICAL ERROR: RESOURCE NAME MISMATCH ❌
        ═══════════════════════════════════════════════════════════════════════════════
        
        Expected: %s
        Got: %s
        
        This resource is branded and must maintain the correct name.
        Rename the folder to "%s" to continue.
        
        🐺 wolves.land - The Land of Wolves
        
        ═══════════════════════════════════════════════════════════════════════════════
        
    ]], REQUIRED_RESOURCE_NAME, currentResourceName, REQUIRED_RESOURCE_NAME))
end

Config = {}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SERVER BRANDING & INFO ████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.ServerInfo = {
    name = 'The Land of Wolves 🐺',
    tagline = 'Georgian RP 🇬🇪 | მგლების მიწა - რჩეულთა ადგილი!',
    description = 'ისტორია ცოცხლდება აქ!', -- History Lives Here!
    type = 'Serious Hardcore Roleplay',
    access = 'Discord & Whitelisted',
    
    -- Contact & Links
    website = 'https://www.wolves.land',
    discord = 'https://discord.gg/CrKcWdfd3A',
    github = 'https://github.com/iBoss21',
    store = 'https://theluxempire.tebex.io',
    serverListing = 'https://servers.redm.net/servers/detail/8gj7eb',
    
    -- Developer Info
    developer = 'iBoss21 / The Lux Empire',
    
    -- Tags
    tags = {'RedM', 'Georgian', 'SeriousRP', 'Whitelist', 'Transportation', 'Balloon', 'Economy'}
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ FRAMEWORK CONFIGURATION ███████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

--[[
    Framework Priority (in order):
    1. LXRCore (Primary) - https://github.com/lxrcore - The Land of Wolves
    2. RSG-Core (Primary) - https://github.com/Rexshack-RedM
    3. VORP Core (Legacy Support)
    4. RedEM:RP (Legacy Support)
    5. Standalone (No Framework)
    
    The script will auto-detect which framework is running.
    Set Config.Framework to override auto-detection.
]]

Config.Framework = 'auto' -- Options: 'auto', 'lxrcore', 'rsg-core', 'vorp', 'redemrp', 'standalone'

-- Framework-specific resource names and triggers
Config.FrameworkSettings = {
    lxrcore = {
        enabled = true,
        resource = 'lxr-core',
        exportName = 'lxr-core',
        getSharedObject = 'lxr-core:getSharedObject',
        playerLoaded = 'LXR:Client:OnPlayerLoaded',
        playerUnloaded = 'LXR:Client:OnPlayerUnload',
        jobUpdate = 'LXR:Client:OnJobUpdate',
        notification = 'lxr', -- 'lxr', 'vorp', 'native'
    },
    ['rsg-core'] = {
        enabled = true,
        resource = 'rsg-core',
        exportName = 'rsg-core',
        getSharedObject = 'rsg-core:getSharedObject',
        playerLoaded = 'RSGCore:Client:OnPlayerLoaded',
        playerUnloaded = 'RSGCore:Client:OnPlayerUnload',
        jobUpdate = 'RSGCore:Client:OnJobUpdate',
        notification = 'rsg',
    },
    vorp = {
        enabled = true,
        resource = 'vorp_core',
        exportName = 'vorp_core',
        getSharedObject = 'vorp:getSharedObject',
        playerLoaded = 'vorp:SelectedCharacter',
        playerUnloaded = 'vorp:PlayerLogout',
        jobUpdate = 'vorp:updateJob',
        notification = 'vorp',
    },
    redemrp = {
        enabled = true,
        resource = 'redem_roleplay',
        exportName = 'redem_roleplay',
        getSharedObject = 'redem:getSharedObject',
        playerLoaded = 'RedEM:PlayerLoaded',
        playerUnloaded = 'RedEM:PlayerUnload',
        jobUpdate = 'RedEM:JobUpdate',
        notification = 'redemrp',
    },
    standalone = {
        enabled = true,
        resource = nil,
        exportName = nil,
        notification = 'native',
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LANGUAGE CONFIGURATION ████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Change the language
Config.Lang = 'English' -- 'English' -- 'French' -- 'Portuguese_BR' -- 'Portuguese_PT'  -- 'German'  -- 'Italian' -- 'Spanish' -- 'Romanian'

-- ████████████████████████████████████████████████████████████████████████████████
-- ███████████████████ HOT AIR BALLOON RENTAL SETTINGS ████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

------------------------------- Hot Air Balloon Rental ------------------------------
Config.KeyToBuyBalloon = 0xD9D0E1C0 -- [ SPACE ] Key to rent the balloon

-- Rental price settings
Config.EnableTax = true   -- If true, the balloon rental fee will be charged, if false, it will be free.
Config.BallonPrice = 5.00 -- Rental price
Config.BallonUseTime = 30 -- Rental duration time in minutes
Config.BalloonModel = "hotairballoon01x"

-- Fuel requirement settings
Config.FuelRequirement = {
    enabled = true,                -- Enable/disable fuel requirement for balloon rentals
    itemName = 'balloon_fuel',     -- Name of the fuel item (must match your server's item database)
    minMinutesPerFuel = 10,        -- Minimum flight time per fuel can in minutes
    maxMinutesPerFuel = 15,        -- Maximum flight time per fuel can in minutes
    -- Note: For 30 minute rental with these settings:
    --   - Best case: 30/15 = 2 fuel cans needed
    --   - Worst case: 30/10 = 3 fuel cans needed
    --   - System will randomly calculate between min and max for realistic consumption
}

-- Passenger invite system settings
Config.PassengerSystem = {
    enabled = true,                -- Enable/disable passenger invite system
    maxPassengers = 2,             -- Maximum passengers (not including owner), total 3 players
    inviteDistance = 10.0,         -- Maximum distance in meters to invite a player
    inviteTimeout = 30,            -- Time in seconds for invite to expire
}

-- Hot Air Balloon Rental locations
Config.BalloonLocations = {
    [1] = {
        coords = vector3(-397.65, 715.95, 114.88), -- Blip and prompt
        spawn = vector3(-406.58, 714.25, 115.47),     -- Where the balloon appears
        name = "Hot Air Balloon Rental",
        sprite = -1595467349
    },
    -- you can continue adding more by continuing with [2]
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ██████████████████████ HOT AIR BALLOON STORE SETTINGS ██████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

------------------------------ Hot Air Balloon store ----------------------------------

Config.Marker = {
    ["valentine"]   = {
        name = "Hot Air Balloon Store", -- Blip name
        sprite = -780469251, -- Blip sprite
        x = -290.4917, y = 691.4873, z = 112.3616, -- Blip and prompt
        spawn = {x = -289.77, y = 699.64, z = 113.45} -- Where the balloon appears
    },
    ["saint_denis"] = {
        name = "Hot Air Balloon Store", 
        sprite = -780469251,
        x = 2477.2075, y = -1364.8922, z = 45.3138,
        spawn = {x = 2463.88, y = -1372.9, z = 45.31}
    },
    ["rhodes"]      = {
        name = "Hot Air Balloon Store", 
        sprite = -780469251,
        x = 1225.9724, y = -1271.1418, z = 74.9349,
        spawn = {x = 1225.82, y = -1255.61, z = 74.53}
    },
    ["strawberry"]  = {
        name = "Hot Air Balloon Store", 
        sprite = -780469251,
        x = -1843.94, y = -431.16, z = 159.55,
        spawn = {x = -1847.04, y = -440.17, z = 159.42}
    },
    ["blackwater"]  = {
        name = "Hot Air Balloon Store", 
        sprite = -780469251,
        x = -839.0341, y = -1218.6031, z = 42.3995,
        spawn = {x = -839.63, y = -1212.74, z = 43.33}
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ███████████████████████ NPC CONFIGURATION SETTINGS █████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.NPC = {
    model = "A_M_M_UniBoatCrew_01",
    coords = {
        vector4(-290.4917297363281, 691.4873657226562, 112.36164855957031, 309.47),     -- Valentine Npc
        vector4(2477.20751953125, -1364.8922119140625, 45.31382369995117, 103.17),      -- Saint Denis Npc
        vector4(1225.972412109375, -1271.141845703125, 74.93492889404297, 249.81),      -- Rhodes Npc
        vector4(-1843.4991455078125, -431.02191162109375, 158.57522583007812, 153.76),  -- Strawberry Npc
        vector4(-839.0341796875, -1218.6031494140625, 42.39957809448242, 12.37),        -- Blackwater Npc
        vector4(-397.655517578125, 715.9544677734375, 114.88623809814453, 109.31),      -- Valentine Rental Npc
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ██████████████████████ SELLING CONFIGURATION SETTINGS ██████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

------------------------------ Sell % price ----------------------------------

Config.Sellprice = 0.6 -- 60% of the original value 1.0 returns you the same as the cost original

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████ BALLOON PRODUCTS & PRICING SETTINGS ███████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

------------------------------ Sale price ----------------------------------

Config.Globo = {
    [1] = {
        ['Text'] = "Hot Air Balloon",   -- Change it to your language
        ['Param'] = {
           ['Name'] = "Hot Air Balloon", -- Change it to your language
           ['Price'] = 1250,               -- Sale price
        }
    },
}
