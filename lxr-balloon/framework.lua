-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 LXR Balloon System - Framework Detection & Initialization
-- ═══════════════════════════════════════════════════════════════════════════════
-- This file handles automatic framework detection and initialization
-- Supports: lxr-core (primary), rsg-core (primary), vorp (legacy), redemrp (legacy), standalone
-- ═══════════════════════════════════════════════════════════════════════════════

Framework = {}
Framework.Core = nil
Framework.Type = nil

-- Framework detection function
-- Note: Framework type names match Config.FrameworkSettings keys:
--   'lxrcore' (no hyphen) and 'rsg-core' (with hyphen) match the config structure
function Framework.Detect()
    if Config.Framework ~= 'auto' then
        return Config.Framework
    end

    -- Priority 1: LXRCore (The Land of Wolves)
    if GetResourceState('lxr-core') == 'started' then
        return 'lxrcore'  -- Matches config key
    end

    -- Priority 1: RSG-Core (Rexshack Gaming)
    if GetResourceState('rsg-core') == 'started' then
        return 'rsg-core'  -- Matches config key
    end

    -- Legacy: VORP Core
    if GetResourceState('vorp_core') == 'started' then
        return 'vorp'
    end

    -- Legacy: RedEM:RP
    if GetResourceState('redem_roleplay') == 'started' then
        return 'redemrp'
    end

    -- Default: Standalone (no framework)
    return 'standalone'
end

-- Initialize framework on server side
function Framework.InitServer()
    Framework.Type = Framework.Detect()
    
    if Framework.Type == 'lxrcore' then
        -- LXRCore initialization
        if GetResourceState('lxr-core') == 'started' then
            Framework.Core = exports['lxr-core']:GetCoreObject()
            print('[lxr-balloon] Framework detected: LXRCore (Primary)')
        end
    elseif Framework.Type == 'rsg-core' then
        -- RSG-Core initialization
        if GetResourceState('rsg-core') == 'started' then
            Framework.Core = exports['rsg-core']:GetCoreObject()
            print('[lxr-balloon] Framework detected: RSG-Core (Primary)')
        end
    elseif Framework.Type == 'vorp' then
        -- VORP Core initialization (Legacy)
        if GetResourceState('vorp_core') == 'started' then
            Framework.Core = exports.vorp_core:GetCore()
            print('[lxr-balloon] Framework detected: VORP Core (Legacy)')
        end
    elseif Framework.Type == 'redemrp' then
        -- RedEM:RP initialization (Legacy)
        if GetResourceState('redem_roleplay') == 'started' then
            TriggerEvent('redemrp:getSharedObject', function(obj)
                Framework.Core = obj
            end)
            print('[lxr-balloon] Framework detected: RedEM:RP (Legacy)')
        end
    else
        -- Standalone mode (no framework)
        Framework.Core = nil
        print('[lxr-balloon] Framework: Standalone mode (No framework detected)')
    end

    return Framework.Core
end

-- Initialize framework on client side
function Framework.InitClient()
    Framework.Type = Framework.Detect()
    
    if Framework.Type == 'lxrcore' then
        -- LXRCore initialization
        if GetResourceState('lxr-core') == 'started' then
            Framework.Core = exports['lxr-core']:GetCoreObject()
            print('[lxr-balloon] Framework detected: LXRCore (Primary)')
        end
    elseif Framework.Type == 'rsg-core' then
        -- RSG-Core initialization
        if GetResourceState('rsg-core') == 'started' then
            Framework.Core = exports['rsg-core']:GetCoreObject()
            print('[lxr-balloon] Framework detected: RSG-Core (Primary)')
        end
    elseif Framework.Type == 'vorp' then
        -- VORP Core initialization (Legacy)
        if GetResourceState('vorp_core') == 'started' then
            Framework.Core = exports.vorp_core:GetCore()
            print('[lxr-balloon] Framework detected: VORP Core (Legacy)')
        end
    elseif Framework.Type == 'redemrp' then
        -- RedEM:RP initialization (Legacy)
        if GetResourceState('redem_roleplay') == 'started' then
            TriggerEvent('redemrp:getSharedObject', function(obj)
                Framework.Core = obj
            end)
            print('[lxr-balloon] Framework detected: RedEM:RP (Legacy)')
        end
    else
        -- Standalone mode (no framework)
        Framework.Core = nil
        print('[lxr-balloon] Framework: Standalone mode (No framework detected)')
    end

    return Framework.Core
end

-- Get user/character from player source (Server-side)
function Framework.GetUser(source)
    if not Framework.Core then return nil end

    if Framework.Type == 'lxrcore' or Framework.Type == 'rsg-core' then
        return Framework.Core.Functions.GetPlayer(source)
    elseif Framework.Type == 'vorp' then
        return Framework.Core.getUser(source)
    elseif Framework.Type == 'redemrp' then
        return Framework.Core.GetPlayer(source)
    end

    return nil
end

-- Get character data (Server-side)
function Framework.GetCharacter(source)
    local User = Framework.GetUser(source)
    if not User then return nil end

    if Framework.Type == 'lxrcore' or Framework.Type == 'rsg-core' then
        return User.PlayerData
    elseif Framework.Type == 'vorp' then
        return User.getUsedCharacter  -- Property, not a function
    elseif Framework.Type == 'redemrp' then
        return User
    end

    return nil
end

-- Send notification (Server-side)
function Framework.NotifyLeft(source, title, message, dict, icon, duration, color)
    if Framework.Type == 'lxrcore' then
        TriggerClientEvent('lxr-core:client:notify', source, {
            title = title,
            text = message,
            type = color == 'COLOR_RED' and 'error' or 'success',
            duration = duration or 4000
        })
    elseif Framework.Type == 'rsg-core' then
        TriggerClientEvent('rsg-core:client:notify', source, {
            title = title,
            text = message,
            type = color == 'COLOR_RED' and 'error' or 'success',
            duration = duration or 4000
        })
    elseif Framework.Type == 'vorp' and Framework.Core then
        Framework.Core.NotifyLeft(source, title, message, dict or "menu_textures", icon or "cross", duration or 4000, color or "COLOR_WHITE")
    elseif Framework.Type == 'redemrp' then
        TriggerClientEvent('redem_roleplay:NotifyLeft', source, title, message, duration or 4000)
    else
        -- Fallback to basic notification
        TriggerClientEvent('chat:addMessage', source, {
            args = { title, message }
        })
    end
end

return Framework
