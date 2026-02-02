-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 LXR Balloon System - Server Script
-- ═══════════════════════════════════════════════════════════════════════════════
-- Multi-framework support: lxr-core (primary), rsg-core (primary), vorp (legacy), standalone
-- ═══════════════════════════════════════════════════════════════════════════════

local T = Translation.Langs[Config.Lang]
local Core = nil

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
end)

-- Helper function to get character data with multi-framework support
local function GetCharacterData(src)
    if not Core then return nil end
    
    local User = Framework.GetUser(src)
    if not User then return nil end
    
    local Character = {}
    
    if Framework.Type == 'lxrcore' or Framework.Type == 'rsg-core' then
        local PlayerData = User.PlayerData
        if not PlayerData then return nil end
        
        Character.identifier = PlayerData.citizenid or PlayerData.cid
        Character.charIdentifier = PlayerData.citizenid or PlayerData.cid
        Character.money = PlayerData.money.cash or 0
        
        -- Add currency management functions
        Character.removeCurrency = function(currencyType, amount)
            User.Functions.RemoveMoney('cash', amount)
        end
        
        Character.addCurrency = function(currencyType, amount)
            User.Functions.AddMoney('cash', amount)
        end
    elseif Framework.Type == 'vorp' then
        local UsedCharacter = User.getUsedCharacter
        if not UsedCharacter then return nil end
        
        Character.identifier = UsedCharacter.identifier
        Character.charIdentifier = UsedCharacter.charIdentifier
        Character.money = UsedCharacter.money or 0
        Character.removeCurrency = UsedCharacter.removeCurrency
        Character.addCurrency = UsedCharacter.addCurrency
    elseif Framework.Type == 'redemrp' then
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

RegisterServerEvent('rs_balloon:checkOwned')
AddEventHandler('rs_balloon:checkOwned', function()
    local src = source
    local Character = GetCharacterData(src)
    
    if not Character then
        print('[lxr-balloon] ERROR: Could not get character data for player ' .. src)
        return
    end
    
    local u_identifier = Character.identifier
    local u_charid = Character.charIdentifier

    exports.oxmysql:execute('SELECT * FROM balloon_buy WHERE identifier = @identifier AND charid = @charid LIMIT 1', {
        ['@identifier'] = u_identifier,
        ['@charid'] = u_charid
    }, function(result)
        if result and result[1] then
            TriggerClientEvent('rs_balloon:openMenu', src, true)
        else
            TriggerClientEvent('rs_balloon:openMenu', src, false)
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
    
    local money = Character.money
    local cost = Config.BallonPrice
    local duration = Config.BallonUseTime * 60
    local requiredFuel = 0

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

    if money < cost then
        Framework.NotifyLeft(src, T.Tittle, T.NeedMoney .. "  " .. cost .. "$ " .. T.ToRentBalloon,  "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end

    exports.oxmysql:execute("SELECT * FROM balloon_rentals WHERE user_id = ? AND character_id = ?", {
        Character.identifier,
        Character.charIdentifier
    }, function(result)
        if result[1] then
            Framework.NotifyLeft(src, T.Tittle, T.AlreadyHasBalloon, "menu_textures", "cross", 4000, "COLOR_RED")
            return
        end

        -- Remove currency first to ensure player can afford rental
        Character.removeCurrency(0, cost)
        
        -- Remove fuel after successful payment (using the previously calculated amount)
        if Config.FuelRequirement.enabled and requiredFuel > 0 then
            Framework.RemoveItem(src, Config.FuelRequirement.itemName, requiredFuel)
        end
        
        Framework.NotifyLeft(src, T.Tittle, T.BalloonRented .. " " .. Config.BallonUseTime .. " " .. T.Minutes, "generic_textures", "tick", 4000, "COLOR_GREEN")

        exports.oxmysql:execute("INSERT INTO balloon_rentals (user_id, character_id, duration) VALUES (?, ?, ?)", {
            Character.identifier,
            Character.charIdentifier,
            duration
        }, function()
            exports.oxmysql:execute("SELECT LAST_INSERT_ID() AS id", {}, function(idResult)
                if idResult and idResult[1] and idResult[1].id then
                    local balloonId = idResult[1].id
                    TriggerClientEvent("rs_balloon:spawnBalloon1", src, balloonId, locationIndex)
                    startBalloonCountdown(Character.identifier, Character.charIdentifier, src, balloonId)
                end
            end)
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

            exports.oxmysql:execute("UPDATE balloon_rentals SET duration = duration - ? WHERE user_id = ? AND character_id = ?", {
                interval,
                user_id,
                character_id
            })

            exports.oxmysql:execute("SELECT duration FROM balloon_rentals WHERE user_id = ? AND character_id = ?", {
                user_id,
                character_id
            }, function(result)
                if result[1] then
                    local remaining = tonumber(result[1].duration)

                    if remaining == 90 and not warned_90 then
                        TriggerClientEvent("rs_balloon:balloonWarning", src, remaining)
                        warned_90 = true
                    end

                    if remaining == 60 and not warned_60 then
                        TriggerClientEvent("rs_balloon:balloonWarning", src, remaining)
                        warned_60 = true
                    end

                    if remaining == 30 and not warned_30 then
                        TriggerClientEvent("rs_balloon:balloonWarning", src, remaining)
                        warned_30 = true
                    end

                    if remaining <= 0 then
                        TriggerClientEvent("rs_balloon:balloonWarning", src, 0)
                        exports.oxmysql:execute("DELETE FROM balloon_rentals WHERE user_id = ? AND character_id = ?", {
                            user_id,
                            character_id
                        })
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

    exports.oxmysql:execute("DELETE FROM balloon_rentals WHERE user_id = ? AND character_id = ?", {
        Character.identifier,
        Character.charIdentifier
    })
    
    if balloonNetId then
        cleanupBalloonData(balloonNetId)
    end
end)

RegisterServerEvent('rs_balloon:buyballoon')
AddEventHandler('rs_balloon:buyballoon', function(args)
    local _price = args['Price']
    local _name = args['Name']
    local Character = GetCharacterData(source)
    
    if not Character then
        print('[lxr-balloon] ERROR: Could not get character data for player ' .. source)
        return
    end

    local u_identifier = Character.identifier
    local u_charid = Character.charIdentifier
    local u_money = Character.money

    if u_money < _price then
        Framework.NotifyLeft(source, T.Tittle, T.Noti,  "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end

    Character.removeCurrency(0, _price)

    local Parameters = {
        ['identifier'] = u_identifier,
        ['charid'] = u_charid,
        ['name'] = _name
    }

    exports.oxmysql:execute("INSERT INTO balloon_buy (`identifier`, `charid`, `name`) VALUES (@identifier, @charid, @name)", Parameters)
    Framework.NotifyLeft(source, T.Tittle, T.Noti1, "generic_textures", "tick", 4000, "COLOR_GREEN")
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

    local Parameters = {
        ['@identifier'] = u_identifier,
        ['@charid'] = u_charid
    }

    exports.oxmysql:execute('SELECT * FROM balloon_buy WHERE identifier = @identifier AND charid = @charid', Parameters, function(HasBalloons)
        if HasBalloons[1] then
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

    -- Verificar si el receptor ya tiene un globo
    exports.oxmysql:execute('SELECT * FROM balloon_buy WHERE identifier = @identifier AND charid = @charid LIMIT 1', {
        ['@identifier'] = target_identifier,
        ['@charid'] = target_charid
    }, function(existing)
        if existing and existing[1] then
            Framework.NotifyLeft(src, T.Tittle, T.has, "menu_textures", "cross", 4000, "COLOR_RED")
        else
            -- Transferir el globo al nuevo jugador
            exports.oxmysql:execute('UPDATE balloon_buy SET identifier = @newIdentifier, charid = @newCharId WHERE identifier = @oldIdentifier AND charid = @oldCharId LIMIT 1', {
                ['@newIdentifier'] = target_identifier,
                ['@newCharId'] = target_charid,
                ['@oldIdentifier'] = sender_identifier,
                ['@oldCharId'] = sender_charid
            }, function()
                Framework.NotifyLeft(src, T.Tittle, T.Tranfer, "generic_textures", "tick", 4000, "COLOR_GREEN")
                Framework.NotifyLeft(tonumber(targetId), T.Tittle, T.Received, "generic_textures", "tick", 4000, "COLOR_GREEN")
            end)
        end
    end)
end)

RegisterServerEvent('rs_balloon:sellballoon')
AddEventHandler('rs_balloon:sellballoon', function(args)
    if not args then
        Framework.NotifyLeft(source, T.Tittle, T.Error, "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end

    local Character = GetCharacterData(source)
    
    if not Character then
        print('[lxr-balloon] ERROR: Could not get character data for player ' .. source)
        return
    end

    local u_identifier = Character.identifier
    local u_charid = Character.charIdentifier
    local original_price = nil

    for _, globo in pairs(Config.Globo) do
        original_price = globo.Param.Price
        break
    end

    if original_price then
        local sell_price = original_price * Config.Sellprice

        Character.addCurrency(0, sell_price)

        exports.oxmysql:execute("DELETE FROM balloon_buy WHERE identifier = @identifier AND charid = @charid", {
            ['@identifier'] = u_identifier,
            ['@charid'] = u_charid,
        })
        Framework.NotifyLeft(source, T.Tittle, T.Buy .. " " .. sell_price .. "$",  "generic_textures", "tick", 4000, "COLOR_GREEN")
    else
        Framework.NotifyLeft(source, T.Tittle, T.Dont, "menu_textures", "cross", 4000, "COLOR_RED")
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- PASSENGER SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

RegisterNetEvent('rs_balloon:trackBalloonOwner')
AddEventHandler('rs_balloon:trackBalloonOwner', function(balloonNetId)
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
        maxHits = math.random(10, 15),
        isDamaged = false
    }
    
    -- Store in database
    exports.oxmysql:execute('INSERT INTO balloon_ownership (balloon_id, owner_id, owner_charid) VALUES (?, ?, ?)', {
        balloonNetId,
        Character.identifier,
        Character.charIdentifier
    })
end)

RegisterNetEvent('rs_balloon:invitePassenger')
AddEventHandler('rs_balloon:invitePassenger', function(balloonNetId, targetSrc)
    local src = source
    
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
    
    if passengerCount >= 2 then
        Framework.NotifyLeft(src, T.Tittle, "Balloon is full (max 2 passengers)", "menu_textures", "cross", 4000, "COLOR_RED")
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
    
    if not pendingInvites[src] or pendingInvites[src].inviterSrc ~= inviterSrc then
        Framework.NotifyLeft(src, T.Tittle, "No valid invite found", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end
    
    local balloonNetId = pendingInvites[src].balloonNetId
    local passengerCount = 0
    
    if balloonPassengers[balloonNetId] then
        for _, _ in pairs(balloonPassengers[balloonNetId]) do
            passengerCount = passengerCount + 1
        end
    end
    
    if passengerCount >= 2 then
        Framework.NotifyLeft(src, T.Tittle, "Balloon is full", "menu_textures", "cross", 4000, "COLOR_RED")
        pendingInvites[src] = nil
        return
    end
    
    local slotKey = passengerCount == 0 and "passenger1" or "passenger2"
    balloonPassengers[balloonNetId][slotKey] = src
    
    TriggerClientEvent('rs_balloon:passengerAdded', inviterSrc, src, balloonNetId)
    TriggerClientEvent('rs_balloon:youArePassenger', src, balloonNetId)
    
    Framework.NotifyLeft(src, T.Tittle, "You joined the balloon", "generic_textures", "tick", 4000, "COLOR_GREEN")
    Framework.NotifyLeft(inviterSrc, T.Tittle, GetPlayerName(src) .. " joined your balloon", "generic_textures", "tick", 4000, "COLOR_GREEN")
    
    pendingInvites[src] = nil
end)

RegisterNetEvent('rs_balloon:declineInvite')
AddEventHandler('rs_balloon:declineInvite', function(inviterSrc)
    local src = source
    
    if pendingInvites[src] and pendingInvites[src].inviterSrc == inviterSrc then
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
            maxHits = math.random(10, 15),
            isDamaged = false
        }
    end
    
    balloonDamage[balloonNetId].hits = balloonDamage[balloonNetId].hits + damageAmount
    
    if balloonDamage[balloonNetId].hits >= balloonDamage[balloonNetId].maxHits then
        balloonDamage[balloonNetId].isDamaged = true
        
        exports.oxmysql:execute('INSERT INTO balloon_damage (balloon_id, damage_hits, is_damaged) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE damage_hits = ?, is_damaged = ?', {
            balloonNetId,
            balloonDamage[balloonNetId].hits,
            1,
            balloonDamage[balloonNetId].hits,
            1
        })
        
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
            TriggerClientEvent('rs_balloon:updateDamage', ownerSrc, balloonNetId, damagePercent)
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
    local isDamaged = false
    local damagePercent = 0
    
    if balloonDamage[balloonNetId] then
        isDamaged = balloonDamage[balloonNetId].isDamaged or balloonDamage[balloonNetId].hits > 0
        damagePercent = math.floor((balloonDamage[balloonNetId].hits / balloonDamage[balloonNetId].maxHits) * 100)
    end
    
    TriggerClientEvent('rs_balloon:receiveDamageStatus', src, isDamaged, damagePercent)
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
    
    if not Config.RepairSystem or not Config.RepairSystem.enabled then
        Framework.NotifyLeft(src, T.Tittle, "Repair system is not enabled", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end
    
    local repairCost = Config.RepairSystem.repairCost or 50
    local woodRequired = Config.RepairSystem.woodRequired or 5
    local clothRequired = Config.RepairSystem.clothRequired or 3
    
    if Character.money < repairCost then
        Framework.NotifyLeft(src, T.Tittle, "Not enough money. Need $" .. repairCost, "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end
    
    local woodCount = Framework.GetItemCount(src, Config.RepairSystem.woodItem or "wood")
    local clothCount = Framework.GetItemCount(src, Config.RepairSystem.clothItem or "cloth")
    
    if woodCount < woodRequired then
        Framework.NotifyLeft(src, T.Tittle, "Not enough wood. Need " .. woodRequired .. " (Have " .. woodCount .. ")", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end
    
    if clothCount < clothRequired then
        Framework.NotifyLeft(src, T.Tittle, "Not enough cloth. Need " .. clothRequired .. " (Have " .. clothCount .. ")", "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end
    
    Character.removeCurrency(0, repairCost)
    Framework.RemoveItem(src, Config.RepairSystem.woodItem or "wood", woodRequired)
    Framework.RemoveItem(src, Config.RepairSystem.clothItem or "cloth", clothRequired)
    
    balloonDamage[balloonNetId] = {
        hits = 0,
        maxHits = math.random(10, 15),
        isDamaged = false
    }
    
    exports.oxmysql:execute('DELETE FROM balloon_damage WHERE balloon_id = ?', { balloonNetId })
    
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
    
    exports.oxmysql:execute('DELETE FROM balloon_ownership WHERE balloon_id = ?', { balloonNetId })
    exports.oxmysql:execute('DELETE FROM balloon_damage WHERE balloon_id = ?', { balloonNetId })
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
    
    exports.oxmysql:execute("DELETE FROM balloon_rentals", {}, function()
    end)
    exports.oxmysql:execute("DELETE FROM balloon_ownership", {}, function()
    end)
    exports.oxmysql:execute("DELETE FROM balloon_damage", {}, function()
    end)
end)
