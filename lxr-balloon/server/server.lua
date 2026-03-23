-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 LXR Balloon System - Server Script
-- ═══════════════════════════════════════════════════════════════════════════════
-- Multi-framework support: lxr-core (primary), rsg-core (primary), vorp (legacy), standalone
-- ═══════════════════════════════════════════════════════════════════════════════

local T = Translation.Langs[Config.Lang]
local Core = nil

-- ═══════════════════════════════════════════════════════════════════════════════
-- Database Abstraction Layer
-- ═══════════════════════════════════════════════════════════════════════════════
-- Supports oxmysql for persistent storage and falls back to in-memory tables.

local DB = {}
local useOxmysql = false

-- In-memory storage for non-oxmysql mode
local memBalloonBuy = {}      -- { { identifier=..., charid=..., name=... }, ... }
local memBalloonRentals = {}  -- { { user_id=..., character_id=..., duration=... }, ... }

local function initDatabase()
    local mode = Config.DatabaseMode or 'auto'

    if mode == 'oxmysql' then
        useOxmysql = true
    elseif mode == 'memory' then
        useOxmysql = false
    else -- auto
        local ok, _ = pcall(function()
            return exports.oxmysql
        end)
        if ok and GetResourceState('oxmysql') == 'started' then
            useOxmysql = true
        else
            useOxmysql = false
        end
    end

    if useOxmysql then
        print('[lxr-balloon] Database: oxmysql (persistent)')
    else
        print('[lxr-balloon] Database: in-memory (non-persistent)')
    end
end

-- Safe oxmysql execute wrapper
function DB.execute(query, params, cb)
    if useOxmysql then
        exports.oxmysql:execute(query, params, cb or function() end)
    else
        -- In-memory fallback – handled per-call in the event handlers
        if cb then cb({}) end
    end
end

-- Lookup a balloon_buy row by identifier + charid
function DB.findBalloonBuy(identifier, charid, cb)
    if useOxmysql then
        exports.oxmysql:execute('SELECT * FROM balloon_buy WHERE identifier = @identifier AND charid = @charid LIMIT 1', {
            ['@identifier'] = identifier,
            ['@charid'] = tostring(charid)
        }, cb)
    else
        local result = {}
        for _, row in ipairs(memBalloonBuy) do
            if row.identifier == identifier and tostring(row.charid) == tostring(charid) then
                result[#result + 1] = row
                break
            end
        end
        cb(result)
    end
end

-- Insert a balloon_buy row
function DB.insertBalloonBuy(identifier, charid, name, cb)
    if useOxmysql then
        exports.oxmysql:execute("INSERT INTO balloon_buy (`identifier`, `charid`, `name`) VALUES (?, ?, ?)", {
            tostring(identifier),
            tostring(charid),
            name
        }, cb or function() end)
    else
        memBalloonBuy[#memBalloonBuy + 1] = { identifier = identifier, charid = tostring(charid), name = name }
        if cb then cb({}) end
    end
end

-- Delete a balloon_buy row
function DB.deleteBalloonBuy(identifier, charid, cb)
    if useOxmysql then
        exports.oxmysql:execute("DELETE FROM balloon_buy WHERE identifier = @identifier AND charid = @charid", {
            ['@identifier'] = identifier,
            ['@charid'] = tostring(charid)
        }, cb or function() end)
    else
        for i = #memBalloonBuy, 1, -1 do
            local row = memBalloonBuy[i]
            if row.identifier == identifier and tostring(row.charid) == tostring(charid) then
                table.remove(memBalloonBuy, i)
                break
            end
        end
        if cb then cb({}) end
    end
end

-- Transfer balloon_buy ownership
function DB.transferBalloonBuy(oldId, oldCharid, newId, newCharid, cb)
    if useOxmysql then
        exports.oxmysql:execute('UPDATE balloon_buy SET identifier = @newIdentifier, charid = @newCharId WHERE identifier = @oldIdentifier AND charid = @oldCharId LIMIT 1', {
            ['@newIdentifier'] = newId,
            ['@newCharId'] = tostring(newCharid),
            ['@oldIdentifier'] = oldId,
            ['@oldCharId'] = tostring(oldCharid)
        }, cb or function() end)
    else
        for _, row in ipairs(memBalloonBuy) do
            if row.identifier == oldId and tostring(row.charid) == tostring(oldCharid) then
                row.identifier = newId
                row.charid = tostring(newCharid)
                break
            end
        end
        if cb then cb({}) end
    end
end

-- Get all balloon_buy rows for an owner
function DB.getBalloonsByOwner(identifier, charid, cb)
    if useOxmysql then
        exports.oxmysql:execute('SELECT * FROM balloon_buy WHERE identifier = @identifier AND charid = @charid', {
            ['@identifier'] = identifier,
            ['@charid'] = tostring(charid)
        }, cb)
    else
        local result = {}
        for _, row in ipairs(memBalloonBuy) do
            if row.identifier == identifier and tostring(row.charid) == tostring(charid) then
                result[#result + 1] = row
            end
        end
        cb(result)
    end
end

-- Find rental by user_id + character_id
function DB.findRental(user_id, character_id, cb)
    if useOxmysql then
        exports.oxmysql:execute("SELECT * FROM balloon_rentals WHERE user_id = ? AND character_id = ?", {
            user_id,
            tostring(character_id)
        }, cb)
    else
        local result = {}
        for _, row in ipairs(memBalloonRentals) do
            if row.user_id == user_id and tostring(row.character_id) == tostring(character_id) then
                result[#result + 1] = row
            end
        end
        cb(result)
    end
end

-- Insert rental and return an id
function DB.insertRental(user_id, character_id, duration, cb)
    if useOxmysql then
        exports.oxmysql:execute("INSERT INTO balloon_rentals (user_id, character_id, duration) VALUES (?, ?, ?)", {
            user_id,
            tostring(character_id),
            duration
        }, function()
            exports.oxmysql:execute("SELECT LAST_INSERT_ID() AS id", {}, function(idResult)
                local id = (idResult and idResult[1] and idResult[1].id) or math.random(100000, 999999)
                cb(id)
            end)
        end)
    else
        local id = #memBalloonRentals + 1
        memBalloonRentals[#memBalloonRentals + 1] = {
            id = id,
            user_id = user_id,
            character_id = tostring(character_id),
            duration = duration
        }
        cb(id)
    end
end

-- Update rental duration
function DB.updateRentalDuration(user_id, character_id, decrementSeconds)
    if useOxmysql then
        exports.oxmysql:execute("UPDATE balloon_rentals SET duration = duration - ? WHERE user_id = ? AND character_id = ?", {
            decrementSeconds,
            user_id,
            tostring(character_id)
        })
    else
        for _, row in ipairs(memBalloonRentals) do
            if row.user_id == user_id and tostring(row.character_id) == tostring(character_id) then
                row.duration = row.duration - decrementSeconds
                break
            end
        end
    end
end

-- Get rental remaining duration
function DB.getRentalDuration(user_id, character_id, cb)
    if useOxmysql then
        exports.oxmysql:execute("SELECT duration FROM balloon_rentals WHERE user_id = ? AND character_id = ?", {
            user_id,
            tostring(character_id)
        }, cb)
    else
        local result = {}
        for _, row in ipairs(memBalloonRentals) do
            if row.user_id == user_id and tostring(row.character_id) == tostring(character_id) then
                result[#result + 1] = { duration = row.duration }
            end
        end
        cb(result)
    end
end

-- Delete rental
function DB.deleteRental(user_id, character_id, cb)
    if useOxmysql then
        exports.oxmysql:execute("DELETE FROM balloon_rentals WHERE user_id = ? AND character_id = ?", {
            user_id,
            tostring(character_id)
        }, cb or function() end)
    else
        for i = #memBalloonRentals, 1, -1 do
            local row = memBalloonRentals[i]
            if row.user_id == user_id and tostring(row.character_id) == tostring(character_id) then
                table.remove(memBalloonRentals, i)
            end
        end
        if cb then cb({}) end
    end
end

-- Delete all rentals (used on resource start)
function DB.deleteAllRentals(cb)
    if useOxmysql then
        exports.oxmysql:execute("DELETE FROM balloon_rentals", {}, cb or function() end)
    else
        memBalloonRentals = {}
        if cb then cb({}) end
    end
end

-- Insert/update damage record
function DB.upsertDamage(ownerId, ownerCharid, balloonNetId, hitCount)
    if useOxmysql then
        exports.oxmysql:execute('INSERT INTO balloon_damage (balloon_owner_id, balloon_owner_charid, balloon_net_id, hit_count, is_damaged, damage_time) VALUES (?, ?, ?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE hit_count = ?, is_damaged = ?, damage_time = NOW()', {
            ownerId,
            tostring(ownerCharid),
            balloonNetId,
            hitCount,
            1,
            hitCount,
            1
        })
    end
    -- In-memory mode: damage tracking is handled in balloonDamage table (already in-memory)
end

-- Delete damage by net id
function DB.deleteDamage(balloonNetId, cb)
    if useOxmysql then
        exports.oxmysql:execute('DELETE FROM balloon_damage WHERE balloon_net_id = ?', { balloonNetId }, cb or function() end)
    else
        if cb then cb({}) end
    end
end

-- Delete all damage (used on resource start)
function DB.deleteAllDamage(cb)
    if useOxmysql then
        exports.oxmysql:execute("DELETE FROM balloon_damage", {}, cb or function() end)
    else
        if cb then cb({}) end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- In-Memory Storage for Performance
-- ═══════════════════════════════════════════════════════════════════════════════
local balloonOwners = {}      -- [balloonNetId] = { owner = src, identifier = id, charid = charid }
local balloonPassengers = {}  -- [balloonNetId] = { passenger1 = src, passenger2 = src }
local balloonDamage = {}      -- [balloonNetId] = { hits = 0, maxHits = 15, isDamaged = false }
local pendingInvites = {}     -- [targetSrc] = { balloonNetId = id, inviterSrc = src, inviterName = name }

-- Initialize framework on server start
Citizen.CreateThread(function()
    Core = Framework.InitServer()
    initDatabase()
end)

-- Helper function to get character data with multi-framework support
local function GetCharacterData(src)
    -- For standalone mode, Core is nil by design - still return character data
    if not Core and Framework.Type ~= 'standalone' then return nil end
    
    local User = Framework.GetUser(src)
    
    local Character = {}
    
    if Framework.Type == 'lxrcore' or Framework.Type == 'rsg-core' then
        if not User then return nil end
        local PlayerData = User.PlayerData
        if not PlayerData then return nil end
        
        Character.identifier = PlayerData.citizenid or PlayerData.cid
        Character.charIdentifier = PlayerData.citizenid or PlayerData.cid
        Character.money = PlayerData.money and PlayerData.money.cash or 0
        
        -- Add currency management functions
        Character.removeCurrency = function(currencyType, amount)
            User.Functions.RemoveMoney('cash', amount)
        end
        
        Character.addCurrency = function(currencyType, amount)
            User.Functions.AddMoney('cash', amount)
        end
    elseif Framework.Type == 'vorp' then
        if not User then return nil end
        local UsedCharacter = User.getUsedCharacter
        if not UsedCharacter then return nil end
        
        Character.identifier = UsedCharacter.identifier
        Character.charIdentifier = UsedCharacter.charIdentifier
        Character.money = UsedCharacter.money or 0
        Character.removeCurrency = UsedCharacter.removeCurrency
        Character.addCurrency = UsedCharacter.addCurrency
    elseif Framework.Type == 'redemrp' then
        if not User then return nil end
        Character.identifier = User.getIdentifier()
        Character.charIdentifier = User.getIdentifier()
        Character.money = User.getMoney() or 0
        
        Character.removeCurrency = function(currencyType, amount)
            User.removeMoney(amount)
        end
        
        Character.addCurrency = function(currencyType, amount)
            User.addMoney(amount)
        end
    else
        -- Standalone mode - basic structure
        Character.identifier = tostring(src)
        Character.charIdentifier = tostring(src)
        Character.money = 999999 -- No economy in standalone
        Character.removeCurrency = function() end
        Character.addCurrency = function() end
    end
    
    return Character
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- Job Validation Helper
-- ═══════════════════════════════════════════════════════════════════════════════

local function HasAllowedJob(src)
    if not Config.AllowedJobs or #Config.AllowedJobs == 0 then return true end

    for _, entry in ipairs(Config.AllowedJobs) do
        if entry == "all" then return true end
    end

    -- Framework-aware job lookup
    if Framework.Type == 'standalone' then return true end

    local User = Framework.GetUser(src)
    if not User then return true end

    local playerJob = nil

    if Framework.Type == 'lxrcore' or Framework.Type == 'rsg-core' then
        local PlayerData = User.PlayerData
        if PlayerData and PlayerData.job then
            playerJob = PlayerData.job.name
        end
    elseif Framework.Type == 'vorp' then
        local UsedChar = User.getUsedCharacter
        if UsedChar then playerJob = UsedChar.job end
    elseif Framework.Type == 'redemrp' then
        playerJob = User.getJob and User.getJob() or nil
    end

    if not playerJob then return true end

    for _, entry in ipairs(Config.AllowedJobs) do
        if entry == playerJob then return true end
    end

    return false
end

RegisterServerEvent('rs_balloon:checkOwned')
AddEventHandler('rs_balloon:checkOwned', function()
    local src = source
    local Character = GetCharacterData(src)
    
    if not Character then
        print('[lxr-balloon] ERROR: Could not get character data for player ' .. src)
        Framework.NotifyLeft(src, T.Tittle, T.Error or "Error loading character data", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end
    
    local u_identifier = Character.identifier
    local u_charid = Character.charIdentifier

    DB.findBalloonBuy(u_identifier, u_charid, function(result)
        if result and result[1] then
            TriggerClientEvent('rs_balloon:openMenu', src, true)
        else
            TriggerClientEvent('rs_balloon:openMenu', src, false)
        end
    end)
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- Dedicated Dealer – buy-only interaction (Config.DealerLocation)
-- ═══════════════════════════════════════════════════════════════════════════════

RegisterServerEvent('rs_balloon:checkOwnedDealer')
AddEventHandler('rs_balloon:checkOwnedDealer', function()
    local src = source
    local Character = GetCharacterData(src)

    if not Character then
        print('[lxr-balloon] ERROR: Could not get character data for player ' .. src)
        return
    end

    if not HasAllowedJob(src) then
        Framework.NotifyLeft(src, T.Tittle, T.JobRestricted or "You do not have permission to purchase a balloon", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end

    local u_identifier = Character.identifier
    local u_charid = Character.charIdentifier

    DB.findBalloonBuy(u_identifier, u_charid, function(result)
        if result and result[1] then
            TriggerClientEvent('rs_balloon:openDealerMenu', src, true)
        else
            TriggerClientEvent('rs_balloon:openDealerMenu', src, false)
        end
    end)
end)

RegisterNetEvent('rs_balloon:RentBalloon')
AddEventHandler('rs_balloon:RentBalloon', function(locationIndex)
    local src = source
    local Character = GetCharacterData(src)
    
    if not Character or not Character.identifier then
        print('[lxr-balloon] ERROR: Could not get character data for player ' .. src)
        return
    end

    if not HasAllowedJob(src) then
        Framework.NotifyLeft(src, T.Tittle, T.JobRestricted or "You do not have permission to rent a balloon", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end
    
    local money = Character.money
    local cost = Config.BallonPrice
    local duration = Config.BallonUseTime * 60
    local requiredFuel = 0

    -- Check if rental fee is enabled
    if not Config.EnableTax then
        cost = 0
    end

    -- Check for fuel requirement if enabled
    if Config.FuelRequirement.enabled then
        local fuelCount = Framework.GetItemCount(src, Config.FuelRequirement.itemName)
        
        -- Calculate required fuel with random consumption (only once!)
        -- Random minutes per fuel between min and max
        local minutesPerFuel = math.random(Config.FuelRequirement.minMinutesPerFuel, Config.FuelRequirement.maxMinutesPerFuel)
        requiredFuel = math.ceil(Config.BallonUseTime / minutesPerFuel)
        
        if fuelCount < requiredFuel then
            Framework.NotifyLeft(src, T.Tittle, T.NeedFuel .. " " .. requiredFuel .. " " .. T.FuelCans .. " (" .. T.YouHave .. " " .. fuelCount .. ")",  "menu_textures", "cross", 4000, "COLOR_RED")
            return
        end
    end

    if cost > 0 and money < cost then
        Framework.NotifyLeft(src, T.Tittle, T.NeedMoney .. "  " .. cost .. "$ " .. T.ToRentBalloon,  "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end

    DB.findRental(Character.identifier, Character.charIdentifier, function(result)
        if result and result[1] then
            Framework.NotifyLeft(src, T.Tittle, T.AlreadyHasBalloon, "menu_textures", "cross", 4000, "COLOR_RED")
            return
        end

        -- Remove currency first to ensure player can afford rental
        if cost > 0 then
            Character.removeCurrency(0, cost)
        end
        
        -- Remove fuel after successful payment (using the previously calculated amount)
        if Config.FuelRequirement.enabled and requiredFuel > 0 then
            Framework.RemoveItem(src, Config.FuelRequirement.itemName, requiredFuel)
        end
        
        Framework.NotifyLeft(src, T.Tittle, T.BalloonRented .. " " .. Config.BallonUseTime .. " " .. T.Minutes, "generic_textures", "tick", 4000, "COLOR_GREEN")

        DB.insertRental(Character.identifier, Character.charIdentifier, duration, function(balloonId)
            TriggerClientEvent("rs_balloon:spawnBalloon1", src, balloonId, locationIndex)
            startBalloonCountdown(Character.identifier, Character.charIdentifier, src, balloonId)
        end)
    end)
end)

function startBalloonCountdown(user_id, character_id, src, balloonId)
    local interval = 30
    local interval_ms = interval * 1000
    local shouldStop = false
    local warned_90 = false
    local warned_60 = false
    local warned_30 = false

    Citizen.CreateThread(function()
        while not shouldStop do
            Citizen.Wait(interval_ms)

            DB.updateRentalDuration(user_id, character_id, interval)

            DB.getRentalDuration(user_id, character_id, function(result)
                if result and result[1] then
                    local remaining = tonumber(result[1].duration)

                    if remaining and remaining <= 90 and not warned_90 then
                        TriggerClientEvent("rs_balloon:balloonWarning", src, remaining)
                        warned_90 = true
                    end

                    if remaining and remaining <= 60 and not warned_60 then
                        TriggerClientEvent("rs_balloon:balloonWarning", src, remaining)
                        warned_60 = true
                    end

                    if remaining and remaining <= 30 and not warned_30 then
                        TriggerClientEvent("rs_balloon:balloonWarning", src, remaining)
                        warned_30 = true
                    end

                    if remaining and remaining <= 0 then
                        TriggerClientEvent("rs_balloon:balloonWarning", src, 0)
                        DB.deleteRental(user_id, character_id)
                        TriggerClientEvent("rs_balloon:deleteTemporaryBalloon", src, balloonId)
                        shouldStop = true
                    end
                else
                    shouldStop = true
                end
            end)
        end
    end)
end

RegisterNetEvent("rs_balloon:removeBalloonFromSQL")
AddEventHandler("rs_balloon:removeBalloonFromSQL", function(balloonNetId)
    local src = source
    local Character = GetCharacterData(src)

    if not Character or not Character.identifier then
        return
    end

    DB.deleteRental(Character.identifier, Character.charIdentifier)
    
    if balloonNetId then
        cleanupBalloonData(balloonNetId)
    end
end)

RegisterServerEvent('rs_balloon:buyballoon')
AddEventHandler('rs_balloon:buyballoon', function(args)
    local src = source
    local _price = args['Price']
    local _name = args['Name']
    local Character = GetCharacterData(src)
    
    if not Character then
        print('[lxr-balloon] ERROR: Could not get character data for player ' .. src)
        Framework.NotifyLeft(src, T.Tittle, T.Error or "Error loading character data", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end

    if not HasAllowedJob(src) then
        Framework.NotifyLeft(src, T.Tittle, T.JobRestricted or "You do not have permission to purchase a balloon", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end

    -- Validate price against config to prevent client-side manipulation
    local validPrice = false
    for _, globo in pairs(Config.Globo) do
        if globo.Param.Name == _name and globo.Param.Price == _price then
            validPrice = true
            break
        end
    end

    if not validPrice then
        print('[lxr-balloon] WARNING: Invalid price/name from player ' .. src .. ' - Name: ' .. tostring(_name) .. ' Price: ' .. tostring(_price))
        Framework.NotifyLeft(src, T.Tittle, T.Error or "Invalid balloon selection", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end

    local u_identifier = Character.identifier
    local u_charid = Character.charIdentifier
    local u_money = Character.money

    if u_money < _price then
        Framework.NotifyLeft(src, T.Tittle, T.Noti,  "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end

    Character.removeCurrency(0, _price)

    DB.insertBalloonBuy(u_identifier, u_charid, _name)
    Framework.NotifyLeft(src, T.Tittle, T.Noti1, "generic_textures", "tick", 4000, "COLOR_GREEN")
end)

RegisterServerEvent('rs_balloon:loadownedBallons')
AddEventHandler('rs_balloon:loadownedBallons', function()
    local _source = source
    local Character = GetCharacterData(_source)
    
    if not Character then
        print('[lxr-balloon] ERROR: Could not get character data for player ' .. _source)
        return
    end
    
    local u_identifier = Character.identifier
    local u_charid = Character.charIdentifier

    DB.getBalloonsByOwner(u_identifier, u_charid, function(HasBalloons)
        if HasBalloons and HasBalloons[1] then
            TriggerClientEvent("rs_balloon:loadBallonMenu", _source, HasBalloons)
        end
    end)
end)

RegisterServerEvent('rs_balloon:transferBalloon')
AddEventHandler('rs_balloon:transferBalloon', function(targetId)
    local src = source
    local sender = GetCharacterData(src)
    local targetCharacter = GetCharacterData(tonumber(targetId))
    
    if not sender or not targetCharacter then
        print('[lxr-balloon] ERROR: Could not get character data for transfer')
        return
    end

    local sender_identifier = sender.identifier
    local sender_charid = sender.charIdentifier
    local target_identifier = targetCharacter.identifier
    local target_charid = targetCharacter.charIdentifier

    -- Check if the target already has a balloon
    DB.findBalloonBuy(target_identifier, target_charid, function(existing)
        if existing and existing[1] then
            Framework.NotifyLeft(src, T.Tittle, T.has, "menu_textures", "cross", 4000, "COLOR_RED")
        else
            -- Transfer the balloon to the new player
            DB.transferBalloonBuy(sender_identifier, sender_charid, target_identifier, target_charid, function()
                Framework.NotifyLeft(src, T.Tittle, T.Tranfer, "generic_textures", "tick", 4000, "COLOR_GREEN")
                Framework.NotifyLeft(tonumber(targetId), T.Tittle, T.Received, "generic_textures", "tick", 4000, "COLOR_GREEN")
            end)
        end
    end)
end)

RegisterServerEvent('rs_balloon:sellballoon')
AddEventHandler('rs_balloon:sellballoon', function(args)
    local src = source
    if not args then
        Framework.NotifyLeft(src, T.Tittle, T.Error, "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end

    local Character = GetCharacterData(src)
    
    if not Character then
        print('[lxr-balloon] ERROR: Could not get character data for player ' .. src)
        return
    end

    local u_identifier = Character.identifier
    local u_charid = Character.charIdentifier

    -- Find the matching balloon name in owned balloons, then find its config price
    DB.getBalloonsByOwner(u_identifier, u_charid, function(ownedBalloons)
        if not ownedBalloons or not ownedBalloons[1] then
            Framework.NotifyLeft(src, T.Tittle, T.Dont, "menu_textures", "cross", 4000, "COLOR_RED")
            return
        end

        local ownedName = ownedBalloons[1].name
        local original_price = nil

        for _, globo in pairs(Config.Globo) do
            if globo.Param.Name == ownedName then
                original_price = globo.Param.Price
                break
            end
        end

        -- Fallback: use the first Config.Globo price if no name match
        if not original_price then
            for _, globo in pairs(Config.Globo) do
                original_price = globo.Param.Price
                break
            end
        end

        if original_price then
            local sell_price = original_price * Config.Sellprice

            Character.addCurrency(0, sell_price)

            DB.deleteBalloonBuy(u_identifier, u_charid)
            Framework.NotifyLeft(src, T.Tittle, T.Buy .. " " .. sell_price .. "$",  "generic_textures", "tick", 4000, "COLOR_GREEN")
        else
            Framework.NotifyLeft(src, T.Tittle, T.Dont, "menu_textures", "cross", 4000, "COLOR_RED")
        end
    end)
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- PASSENGER SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local function getMaxPassengers()
    local ps = Config.PassengerSystem
    if ps and type(ps.maxPassengers) == 'number' and ps.maxPassengers > 0 then
        return ps.maxPassengers
    end
    return 2
end

--- Network IDs must be numeric keys; menu/events may send strings.
local function normalizeBalloonNetId(balloonNetId)
    local n = tonumber(balloonNetId)
    return n or balloonNetId
end

RegisterNetEvent('rs_balloon:trackBalloonOwner')
AddEventHandler('rs_balloon:trackBalloonOwner', function(balloonNetId)
    balloonNetId = normalizeBalloonNetId(balloonNetId)
    local src = source
    local Character = GetCharacterData(src)
    
    if not Character then
        print('[lxr-balloon] ERROR: Could not get character data for owner tracking')
        return
    end
    
    balloonOwners[balloonNetId] = {
        owner = src,
        identifier = Character.identifier,
        charid = Character.charIdentifier
    }
    
    balloonPassengers[balloonNetId] = {}
    balloonDamage[balloonNetId] = {
        hits = 0,
        maxHits = math.random(Config.DamageSystem.arrowHitsToDestroy, Config.DamageSystem.arrowHitsToDestroyMax),
        isDamaged = false
    }
end)

RegisterNetEvent('rs_balloon:invitePassenger')
AddEventHandler('rs_balloon:invitePassenger', function(balloonNetId, targetSrc)
    local src = source
    balloonNetId = normalizeBalloonNetId(balloonNetId)
    targetSrc = tonumber(targetSrc)
    local maxPass = getMaxPassengers()

    if not targetSrc then
        Framework.NotifyLeft(src, T.Tittle, "Invalid player id", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end

    if targetSrc == src then
        Framework.NotifyLeft(src, T.Tittle, "You cannot invite yourself", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end

    if not balloonOwners[balloonNetId] or balloonOwners[balloonNetId].owner ~= src then
        Framework.NotifyLeft(src, T.Tittle, "You are not the owner of this balloon", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end
    
    local passengerCount = 0
    if balloonPassengers[balloonNetId] then
        for _, _ in pairs(balloonPassengers[balloonNetId]) do
            passengerCount = passengerCount + 1
        end
    end
    
    if passengerCount >= maxPass then
        Framework.NotifyLeft(src, T.Tittle, "Balloon is full (max " .. maxPass .. " passengers)", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end
    
    local inviterName = GetPlayerName(src)
    pendingInvites[targetSrc] = {
        balloonNetId = balloonNetId,
        inviterSrc = src,
        inviterName = inviterName
    }
    
    TriggerClientEvent('rs_balloon:receiveInvite', targetSrc, src, inviterName, balloonNetId)
    Framework.NotifyLeft(src, T.Tittle, "Invite sent to " .. GetPlayerName(targetSrc), "generic_textures", "tick", 4000, "COLOR_GREEN")
end)

RegisterNetEvent('rs_balloon:acceptInvite')
AddEventHandler('rs_balloon:acceptInvite', function(inviterSrc)
    local src = source
    inviterSrc = tonumber(inviterSrc)

    if not inviterSrc or not pendingInvites[src] or pendingInvites[src].inviterSrc ~= inviterSrc then
        Framework.NotifyLeft(src, T.Tittle, "No valid invite found", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end
    
    local balloonNetId = normalizeBalloonNetId(pendingInvites[src].balloonNetId)
    local maxPass = getMaxPassengers()
    local passengerCount = 0
    
    if balloonPassengers[balloonNetId] then
        for _, _ in pairs(balloonPassengers[balloonNetId]) do
            passengerCount = passengerCount + 1
        end
    end
    
    if passengerCount >= maxPass then
        Framework.NotifyLeft(src, T.Tittle, "Balloon is full", "menu_textures", "cross", 4000, "COLOR_RED")
        pendingInvites[src] = nil
        return
    end
    
    if not balloonPassengers[balloonNetId] then
        balloonPassengers[balloonNetId] = {}
    end

    local slotKey = passengerCount == 0 and "passenger1" or "passenger2"
    balloonPassengers[balloonNetId][slotKey] = src
    
    TriggerClientEvent('rs_balloon:passengerAdded', inviterSrc, src, balloonNetId)
    TriggerClientEvent('rs_balloon:youArePassenger', src, inviterSrc, balloonNetId, slotKey)
    
    Framework.NotifyLeft(src, T.Tittle, "You joined the balloon", "generic_textures", "tick", 4000, "COLOR_GREEN")
    Framework.NotifyLeft(inviterSrc, T.Tittle, GetPlayerName(src) .. " joined your balloon", "generic_textures", "tick", 4000, "COLOR_GREEN")
    
    pendingInvites[src] = nil
end)

RegisterNetEvent('rs_balloon:declineInvite')
AddEventHandler('rs_balloon:declineInvite', function(inviterSrc)
    local src = source
    inviterSrc = tonumber(inviterSrc)

    if inviterSrc and pendingInvites[src] and pendingInvites[src].inviterSrc == inviterSrc then
        Framework.NotifyLeft(inviterSrc, T.Tittle, GetPlayerName(src) .. " declined your invite", "menu_textures", "cross", 4000, "COLOR_RED")
        pendingInvites[src] = nil
    end
end)

RegisterNetEvent('rs_balloon:removePassenger')
AddEventHandler('rs_balloon:removePassenger', function(balloonNetId, passengerSrc)
    local src = source
    
    if not balloonOwners[balloonNetId] or balloonOwners[balloonNetId].owner ~= src then
        return
    end
    
    if balloonPassengers[balloonNetId] then
        for key, pSrc in pairs(balloonPassengers[balloonNetId]) do
            if pSrc == passengerSrc then
                balloonPassengers[balloonNetId][key] = nil
                TriggerClientEvent('rs_balloon:removedFromBalloon', passengerSrc, balloonNetId)
                Framework.NotifyLeft(passengerSrc, T.Tittle, "You were removed from the balloon", "menu_textures", "cross", 4000, "COLOR_RED")
                Framework.NotifyLeft(src, T.Tittle, "Passenger removed", "generic_textures", "tick", 4000, "COLOR_GREEN")
                break
            end
        end
    end
end)

RegisterNetEvent('rs_balloon:getBalloonOwner')
AddEventHandler('rs_balloon:getBalloonOwner', function(balloonNetId)
    local src = source
    local ownerData = balloonOwners[balloonNetId]
    
    TriggerClientEvent('rs_balloon:receiveBalloonOwner', src, ownerData)
end)

RegisterNetEvent('rs_balloon:getBalloonPassengers')
AddEventHandler('rs_balloon:getBalloonPassengers', function(balloonNetId)
    local src = source
    local passengers = {}
    
    if balloonPassengers[balloonNetId] then
        for _, pSrc in pairs(balloonPassengers[balloonNetId]) do
            table.insert(passengers, {
                source = pSrc,
                name = GetPlayerName(pSrc)
            })
        end
    end
    
    TriggerClientEvent('rs_balloon:receivePassengerList', src, passengers)
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- DAMAGE SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

RegisterNetEvent('rs_balloon:balloonDamaged')
AddEventHandler('rs_balloon:balloonDamaged', function(balloonNetId, damageAmount)
    local src = source
    
    if not balloonDamage[balloonNetId] then
        balloonDamage[balloonNetId] = {
            hits = 0,
            maxHits = math.random(Config.DamageSystem.arrowHitsToDestroy, Config.DamageSystem.arrowHitsToDestroyMax),
            isDamaged = false
        }
    end
    
    balloonDamage[balloonNetId].hits = balloonDamage[balloonNetId].hits + damageAmount
    
    if balloonDamage[balloonNetId].hits >= balloonDamage[balloonNetId].maxHits then
        balloonDamage[balloonNetId].isDamaged = true
        
        if balloonOwners[balloonNetId] then
            DB.upsertDamage(
                balloonOwners[balloonNetId].identifier,
                balloonOwners[balloonNetId].charid,
                balloonNetId,
                balloonDamage[balloonNetId].hits
            )
        end
        
        if balloonOwners[balloonNetId] then
            local ownerSrc = balloonOwners[balloonNetId].owner
            TriggerClientEvent('rs_balloon:balloonDestroyed', ownerSrc, balloonNetId)
            Framework.NotifyLeft(ownerSrc, T.Tittle, "Your balloon has been destroyed!", "menu_textures", "cross", 4000, "COLOR_RED")
            
            if balloonPassengers[balloonNetId] then
                for _, pSrc in pairs(balloonPassengers[balloonNetId]) do
                    TriggerClientEvent('rs_balloon:balloonDestroyed', pSrc, balloonNetId)
                end
            end
            
            cleanupBalloonData(balloonNetId)
        end
    else
        local damagePercent = math.floor((balloonDamage[balloonNetId].hits / balloonDamage[balloonNetId].maxHits) * 100)
        
        if balloonOwners[balloonNetId] then
            local ownerSrc = balloonOwners[balloonNetId].owner
            TriggerClientEvent('rs_balloon:updateDamage', ownerSrc, balloonNetId, balloonDamage[balloonNetId].hits, balloonDamage[balloonNetId].maxHits, balloonDamage[balloonNetId].isDamaged)
        end
    end
end)

RegisterNetEvent('rs_balloon:ownerDied')
AddEventHandler('rs_balloon:ownerDied', function(balloonNetId)
    local src = source
    
    if not balloonOwners[balloonNetId] or balloonOwners[balloonNetId].owner ~= src then
        return
    end
    
    TriggerClientEvent('rs_balloon:triggerCrash', -1, balloonNetId)
    
    Framework.NotifyLeft(src, T.Tittle, "Your balloon is crashing!", "menu_textures", "cross", 4000, "COLOR_RED")
    
    if balloonPassengers[balloonNetId] then
        for _, pSrc in pairs(balloonPassengers[balloonNetId]) do
            Framework.NotifyLeft(pSrc, T.Tittle, "The balloon owner died! Crash incoming!", "menu_textures", "cross", 4000, "COLOR_RED")
        end
    end
    
    Citizen.SetTimeout(5000, function()
        cleanupBalloonData(balloonNetId)
    end)
end)

RegisterNetEvent('rs_balloon:checkBalloonDamage')
AddEventHandler('rs_balloon:checkBalloonDamage', function(balloonNetId)
    local src = source
    local damageInfo = nil
    
    if balloonDamage[balloonNetId] then
        damageInfo = {
            isDamaged = balloonDamage[balloonNetId].isDamaged or balloonDamage[balloonNetId].hits > 0,
            hits = balloonDamage[balloonNetId].hits,
            maxHits = balloonDamage[balloonNetId].maxHits,
            damagePercent = math.floor((balloonDamage[balloonNetId].hits / balloonDamage[balloonNetId].maxHits) * 100)
        }
    end
    
    TriggerClientEvent('rs_balloon:receiveDamageStatus', src, damageInfo)
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- REPAIR SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

RegisterNetEvent('rs_balloon:repairBalloon')
AddEventHandler('rs_balloon:repairBalloon', function(balloonNetId)
    local src = source
    local Character = GetCharacterData(src)
    
    if not Character then
        print('[lxr-balloon] ERROR: Could not get character data for repair')
        return
    end
    
    if not balloonOwners[balloonNetId] or balloonOwners[balloonNetId].owner ~= src then
        Framework.NotifyLeft(src, T.Tittle, "You are not the owner of this balloon", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end
    
    if not balloonDamage[balloonNetId] or (balloonDamage[balloonNetId].hits == 0 and not balloonDamage[balloonNetId].isDamaged) then
        Framework.NotifyLeft(src, T.Tittle, "Balloon is not damaged", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end
    
    if not Config.DamageSystem or not Config.DamageSystem.enabled then
        Framework.NotifyLeft(src, T.Tittle, "Repair system is not enabled", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end
    
    local repairCost = Config.DamageSystem.repairMoney or 50
    
    if Character.money < repairCost then
        Framework.NotifyLeft(src, T.Tittle, "Not enough money. Need $" .. repairCost, "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end
    
    for _, item in ipairs(Config.DamageSystem.repairItems) do
        local itemCount = Framework.GetItemCount(src, item.name)
        if itemCount < item.amount then
            Framework.NotifyLeft(src, T.Tittle, "Not enough " .. item.name .. ". Need " .. item.amount .. " (Have " .. itemCount .. ")", "menu_textures", "cross", 4000, "COLOR_RED")
            return
        end
    end
    
    Character.removeCurrency(0, repairCost)
    
    for _, item in ipairs(Config.DamageSystem.repairItems) do
        Framework.RemoveItem(src, item.name, item.amount)
    end
    
    balloonDamage[balloonNetId] = {
        hits = 0,
        maxHits = math.random(Config.DamageSystem.arrowHitsToDestroy, Config.DamageSystem.arrowHitsToDestroyMax),
        isDamaged = false
    }
    
    DB.deleteDamage(balloonNetId)
    
    TriggerClientEvent('rs_balloon:balloonRepaired', src, balloonNetId)
    Framework.NotifyLeft(src, T.Tittle, "Balloon repaired successfully!", "generic_textures", "tick", 4000, "COLOR_GREEN")
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- CLEANUP HELPERS
-- ═══════════════════════════════════════════════════════════════════════════════

function cleanupBalloonData(balloonNetId)
    balloonOwners[balloonNetId] = nil
    balloonPassengers[balloonNetId] = nil
    balloonDamage[balloonNetId] = nil
    
    DB.deleteDamage(balloonNetId)
end

RegisterNetEvent('rs_balloon:cleanupBalloon')
AddEventHandler('rs_balloon:cleanupBalloon', function(balloonNetId)
    cleanupBalloonData(balloonNetId)
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    
    balloonOwners = {}
    balloonPassengers = {}
    balloonDamage = {}
    pendingInvites = {}
    
    DB.deleteAllRentals()
    DB.deleteAllDamage()
end)
