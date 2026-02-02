# 🔧 Developer Documentation - LXR Balloon System

## Table of Contents

1. [Overview](#overview)
2. [Framework Support](#framework-support)
3. [Server-Side Events](#server-side-events)
4. [Client-Side Events](#client-side-events)
5. [Exports](#exports)
6. [Database Schema](#database-schema)
7. [API Reference](#api-reference)
8. [Custom Integration](#custom-integration)
9. [Code Examples](#code-examples)

---

## Overview

The LXR Balloon System is a multi-framework hot air balloon script for RedM servers. It provides a complete balloon rental and ownership system with database persistence.

### Architecture
- **Client:** Player interactions, UI prompts, balloon controls
- **Server:** Database operations, currency management, player data
- **Shared:** Configuration, translations

### Supported Frameworks (Priority Order)
1. **LXRCore** (Primary) - The Land of Wolves custom framework
2. **RSG-Core** (Primary) - Rexshack Gaming framework
3. **VORP Core** (Legacy)
4. **RedEM:RP** (Legacy)
5. **Standalone** (No framework)

---

## Framework Support

### Auto-Detection

The script automatically detects which framework is running:

```lua
-- In config.lua
Config.Framework = 'auto'  -- Auto-detect framework
```

### Manual Override

Force a specific framework:

```lua
Config.Framework = 'lxrcore'  -- Force LXRCore
Config.Framework = 'rsg-core'  -- Force RSG-Core
Config.Framework = 'vorp'      -- Force VORP
Config.Framework = 'standalone' -- No framework
```

### Framework Configuration

Each framework has specific settings:

```lua
Config.FrameworkSettings = {
    lxrcore = {
        enabled = true,
        resource = 'lxr-core',           -- Resource name
        exportName = 'lxr-core',         -- Export name
        getSharedObject = 'lxr-core:getSharedObject',
        playerLoaded = 'LXR:Client:OnPlayerLoaded',
        playerUnloaded = 'LXR:Client:OnPlayerUnload',
        jobUpdate = 'LXR:Client:OnJobUpdate',
        notification = 'lxr',
    },
    -- ... other frameworks
}
```

### Adding New Framework Support

To add support for a new framework:

1. Add framework configuration to `Config.FrameworkSettings`
2. Implement framework-specific functions in `server/server.lua`
3. Add client-side event handlers in `client/client.lua`
4. Test thoroughly

---

## Server-Side Events

### Core Events

#### `rs_balloon:checkOwned`
Checks if a player owns a balloon.

**Trigger:**
```lua
TriggerServerEvent('rs_balloon:checkOwned')
```

**Response:**
Triggers `rs_balloon:openMenu` on client with ownership status.

**Example:**
```lua
-- Client-side
RegisterNetEvent('rs_balloon:openMenu')
AddEventHandler('rs_balloon:openMenu', function(hasOwnedBalloon)
    if hasOwnedBalloon then
        print("Player owns a balloon")
    else
        print("Player does not own a balloon")
    end
end)
```

---

#### `rs_balloon:RentBalloon`
Handles balloon rental transactions.

**Parameters:**
- `locationIndex` (number) - Index of rental location from config

**Trigger:**
```lua
TriggerServerEvent('rs_balloon:RentBalloon', locationIndex)
```

**Functionality:**
- Validates player has sufficient funds
- Checks for existing active rentals
- Deducts rental cost
- Creates rental record in database
- Spawns balloon on client

**Example:**
```lua
-- Rent balloon at location 1
TriggerServerEvent('rs_balloon:RentBalloon', 1)
```

---

#### `rs_balloon:CheckRentalStatus`
Checks if player has an active rental.

**Trigger:**
```lua
TriggerServerEvent('rs_balloon:CheckRentalStatus')
```

**Response:**
Triggers `rs_balloon:RentalStatus` on client.

---

#### `rs_balloon:sell`
Handles selling a player-owned balloon.

**Parameters:**
- `data` (table) - Balloon data including price

**Trigger:**
```lua
TriggerServerEvent('rs_balloon:sell', balloonData)
```

**Functionality:**
- Validates balloon ownership
- Calculates sell price (Config.Sellprice percentage)
- Adds currency to player
- Removes balloon from database

**Example:**
```lua
local balloonData = {
    Param = {
        Price = 1250  -- Original purchase price
    }
}
TriggerServerEvent('rs_balloon:sell', balloonData)
```

---

#### `rs_balloon:buy`
Handles purchasing a new balloon.

**Parameters:**
- `data` (table) - Balloon data including name and price

**Trigger:**
```lua
TriggerServerEvent('rs_balloon:buy', balloonData)
```

**Functionality:**
- Validates player has sufficient funds
- Checks player doesn't already own a balloon
- Deducts purchase cost
- Adds balloon to database

**Example:**
```lua
local balloonData = {
    Text = "Hot Air Balloon",
    Param = {
        Name = "Hot Air Balloon",
        Price = 1250
    }
}
TriggerServerEvent('rs_balloon:buy', balloonData)
```

---

#### `rs_balloon:transfer`
Transfers balloon ownership to another player.

**Parameters:**
- `targetId` (number) - Server ID of target player

**Trigger:**
```lua
TriggerServerEvent('rs_balloon:transfer', targetServerId)
```

**Functionality:**
- Validates source player owns a balloon
- Validates target player exists
- Checks target doesn't already own a balloon
- Updates database ownership
- Notifies both players

**Example:**
```lua
-- Transfer balloon to player with server ID 5
TriggerServerEvent('rs_balloon:transfer', 5)
```

---

#### `rs_balloon:RemoveBalloonAndClean`
Removes and cleans up balloon entities.

**Parameters:**
- `balloonEntity` (number) - Network ID of balloon entity

**Trigger:**
```lua
TriggerServerEvent('rs_balloon:RemoveBalloonAndClean', NetworkGetNetworkIdFromEntity(balloon))
```

**Functionality:**
- Deletes balloon entity from server
- Cleans up database records
- Notifies relevant clients

---

## Client-Side Events

### Core Events

#### `rs_balloon:openMenu`
Opens the balloon store menu.

**Parameters:**
- `hasOwnedBalloon` (boolean) - Whether player owns a balloon

**Usage:**
```lua
RegisterNetEvent('rs_balloon:openMenu')
AddEventHandler('rs_balloon:openMenu', function(hasOwnedBalloon)
    -- Open your custom UI here
    -- hasOwnedBalloon determines available options
end)
```

---

#### `rs_balloon:SpawnBalloon`
Spawns a balloon for the player.

**Parameters:**
- `coords` (vector3) - Spawn coordinates
- `isRental` (boolean) - Whether this is a rental balloon

**Trigger:**
```lua
TriggerEvent('rs_balloon:SpawnBalloon', vector3(x, y, z), false)
```

---

#### `rs_balloon:RentalStatus`
Receives rental status information.

**Parameters:**
- `hasRental` (boolean) - Whether player has active rental
- `timeRemaining` (number) - Seconds remaining (if active)

**Usage:**
```lua
RegisterNetEvent('rs_balloon:RentalStatus')
AddEventHandler('rs_balloon:RentalStatus', function(hasRental, timeRemaining)
    if hasRental then
        print("Rental expires in " .. timeRemaining .. " seconds")
    end
end)
```

---

#### `rs_balloon:CleanupBalloon`
Forces cleanup of player's balloon.

**Usage:**
```lua
TriggerEvent('rs_balloon:CleanupBalloon')
```

---

## Exports

### Server Exports

#### GetPlayerBalloonOwnership
Check if a player owns a balloon.

**Syntax:**
```lua
exports['lxr-balloon']:GetPlayerBalloonOwnership(source)
```

**Parameters:**
- `source` (number) - Player server ID

**Returns:**
- `boolean` - True if player owns a balloon

**Example:**
```lua
-- From another resource's server.lua
local playerId = source
local ownsBalloon = exports['lxr-balloon']:GetPlayerBalloonOwnership(playerId)

if ownsBalloon then
    print("Player owns a balloon!")
end
```

---

#### GetPlayerRentalStatus
Check if a player has an active rental.

**Syntax:**
```lua
exports['lxr-balloon']:GetPlayerRentalStatus(source)
```

**Parameters:**
- `source` (number) - Player server ID

**Returns:**
- `boolean` - True if player has active rental
- `number` - Time remaining in seconds (or nil)

**Example:**
```lua
local playerId = source
local hasRental, timeLeft = exports['lxr-balloon']:GetPlayerRentalStatus(playerId)

if hasRental then
    print("Rental expires in " .. timeLeft .. " seconds")
end
```

---

#### GiveBalloonToPlayer
Administratively give a balloon to a player.

**Syntax:**
```lua
exports['lxr-balloon']:GiveBalloonToPlayer(source, balloonName)
```

**Parameters:**
- `source` (number) - Player server ID
- `balloonName` (string) - Name of balloon to give

**Returns:**
- `boolean` - Success status

**Example:**
```lua
-- Admin command to give balloon
RegisterCommand('giveballoon', function(source, args)
    local targetId = tonumber(args[1])
    local success = exports['lxr-balloon']:GiveBalloonToPlayer(targetId, "Hot Air Balloon")
    
    if success then
        print("Balloon given successfully")
    end
end, true)
```

---

#### RemoveBalloonFromPlayer
Remove a balloon from a player.

**Syntax:**
```lua
exports['lxr-balloon']:RemoveBalloonFromPlayer(source)
```

**Parameters:**
- `source` (number) - Player server ID

**Returns:**
- `boolean` - Success status

**Example:**
```lua
-- Admin command to remove balloon
RegisterCommand('removeballoon', function(source, args)
    local targetId = tonumber(args[1])
    local success = exports['lxr-balloon']:RemoveBalloonFromPlayer(targetId)
end, true)
```

---

### Client Exports

#### IsPlayerInBalloon
Check if local player is currently in a balloon.

**Syntax:**
```lua
exports['lxr-balloon']:IsPlayerInBalloon()
```

**Returns:**
- `boolean` - True if in balloon

**Example:**
```lua
-- From another resource's client.lua
if exports['lxr-balloon']:IsPlayerInBalloon() then
    print("Player is flying!")
end
```

---

#### GetCurrentBalloon
Get the current balloon entity.

**Syntax:**
```lua
exports['lxr-balloon']:GetCurrentBalloon()
```

**Returns:**
- `number` - Balloon entity ID (or nil)

**Example:**
```lua
local balloonEntity = exports['lxr-balloon']:GetCurrentBalloon()
if balloonEntity then
    local coords = GetEntityCoords(balloonEntity)
    print("Balloon is at: " .. tostring(coords))
end
```

---

#### OpenBalloonStore
Programmatically open the balloon store menu.

**Syntax:**
```lua
exports['lxr-balloon']:OpenBalloonStore()
```

**Example:**
```lua
-- Custom NPC interaction
RegisterCommand('balloonshop', function()
    exports['lxr-balloon']:OpenBalloonStore()
end)
```

---

## Database Schema

### Table: `balloon_buy`
Stores balloon ownership data.

```sql
CREATE TABLE IF NOT EXISTS `balloon_buy` (
  `identifier` varchar(40) NOT NULL,  -- Player identifier
  `charid` int(11) NOT NULL,          -- Character ID
  `name` varchar(255) NOT NULL        -- Balloon name
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

**Fields:**
- `identifier`: Player's unique identifier (varies by framework)
- `charid`: Character ID (for multi-character support)
- `name`: Name of the owned balloon

**Indexes:**
- Composite: `(identifier, charid)` for fast ownership lookups

---

### Table: `balloon_rentals`
Manages temporary balloon rentals.

```sql
CREATE TABLE IF NOT EXISTS `balloon_rentals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,  -- Rental ID
  `user_id` varchar(50) NOT NULL,        -- Player identifier
  `character_id` int(11) NOT NULL,       -- Character ID
  `duration` int(11) NOT NULL,           -- Duration in seconds
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Fields:**
- `id`: Auto-incrementing rental ID
- `user_id`: Player's unique identifier
- `character_id`: Character ID
- `duration`: Rental duration in seconds

**Indexes:**
- Primary: `id`
- Composite: `(user_id, character_id)` for active rental checks

---

## API Reference

### Framework Integration Functions

#### GetFramework()
Returns the currently active framework.

**Location:** `server/server.lua` (internal)

**Returns:**
- `string` - Framework name ('lxrcore', 'rsg-core', 'vorp', etc.)

---

#### GetPlayerFromSource(source)
Gets player object from server ID.

**Location:** `server/server.lua` (internal)

**Parameters:**
- `source` (number) - Player server ID

**Returns:**
- `table` - Framework-specific player object

**Framework Variations:**
```lua
-- LXRCore
local Player = LXRCore.Functions.GetPlayer(source)

-- RSG-Core  
local Player = RSGCore.Functions.GetPlayer(source)

-- VORP
local User = VORPcore.getUser(source)
local Character = User.getUsedCharacter
```

---

#### GetPlayerMoney(source)
Gets player's current money.

**Location:** `server/server.lua` (internal)

**Parameters:**
- `source` (number) - Player server ID

**Returns:**
- `number` - Player's cash amount

---

#### RemovePlayerMoney(source, amount)
Removes money from player.

**Location:** `server/server.lua` (internal)

**Parameters:**
- `source` (number) - Player server ID
- `amount` (number) - Amount to remove

**Returns:**
- `boolean` - Success status

---

#### AddPlayerMoney(source, amount)
Adds money to player.

**Location:** `server/server.lua` (internal)

**Parameters:**
- `source` (number) - Player server ID
- `amount` (number) - Amount to add

**Returns:**
- `boolean` - Success status

---

## Custom Integration

### Adding Custom Framework

1. **Add Framework Configuration:**

```lua
-- In config.lua
Config.FrameworkSettings.myframework = {
    enabled = true,
    resource = 'my-framework',
    exportName = 'my-framework',
    getSharedObject = 'myframework:getSharedObject',
    playerLoaded = 'MyFramework:Client:OnPlayerLoaded',
    playerUnloaded = 'MyFramework:Client:OnPlayerUnload',
    jobUpdate = 'MyFramework:Client:OnJobUpdate',
    notification = 'myframework',
}
```

2. **Implement Server Functions:**

```lua
-- In server/server.lua
if Config.Framework == 'myframework' then
    MyFramework = exports['my-framework']:GetCoreObject()
    
    function GetPlayerMoney(source)
        local Player = MyFramework.Functions.GetPlayer(source)
        return Player.PlayerData.money['cash']
    end
    
    -- Implement other required functions...
end
```

3. **Implement Client Functions:**

```lua
-- In client/client.lua
if Config.Framework == 'myframework' then
    RegisterNetEvent('MyFramework:Client:OnPlayerLoaded')
    AddEventHandler('MyFramework:Client:OnPlayerLoaded', function()
        -- Handle player load
    end)
end
```

---

### Custom Notifications

To use custom notification systems:

1. **Add to Framework Settings:**

```lua
Config.FrameworkSettings.lxrcore.notification = 'custom'
```

2. **Implement Notification Function:**

```lua
-- In server/server.lua or client/client.lua
function SendNotification(source, title, message, type, duration)
    if Config.FrameworkSettings[Config.Framework].notification == 'custom' then
        -- Your custom notification code
        TriggerClientEvent('mynotify:send', source, {
            title = title,
            message = message,
            type = type,
            duration = duration
        })
    end
end
```

---

## Code Examples

### Example 1: Check Balloon Ownership from Another Script

**Server-side:**
```lua
-- In your resource's server.lua
RegisterCommand('checkballoon', function(source)
    local ownsBalloon = exports['lxr-balloon']:GetPlayerBalloonOwnership(source)
    
    if ownsBalloon then
        TriggerClientEvent('chat:addMessage', source, {
            args = {'System', 'You own a balloon!'}
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {'System', 'You do not own a balloon.'}
        })
    end
end)
```

---

### Example 2: Custom Balloon Spawn Location

**Client-side:**
```lua
-- Spawn balloon at custom coordinates
RegisterCommand('spawnballoon', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local forwardCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
    
    TriggerEvent('rs_balloon:SpawnBalloon', forwardCoords, false)
end)
```

---

### Example 3: Admin Give Balloon Command

**Server-side:**
```lua
RegisterCommand('adminballoon', function(source, args)
    if not IsPlayerAceAllowed(source, 'admin') then
        return
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('chat:addMessage', source, {
            args = {'Error', 'Usage: /adminballoon [playerid]'}
        })
        return
    end
    
    local success = exports['lxr-balloon']:GiveBalloonToPlayer(targetId, "Hot Air Balloon")
    
    if success then
        TriggerClientEvent('chat:addMessage', source, {
            args = {'Success', 'Balloon given to player ' .. targetId}
        })
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {'Error', 'Failed to give balloon'}
        })
    end
end, true)
```

---

### Example 4: Integration with Economy System

**Server-side:**
```lua
-- Hook into balloon purchases for economy tracking
AddEventHandler('rs_balloon:buy', function(playerId, balloonData)
    -- Log to your economy system
    exports['my-economy']:LogTransaction(playerId, 'balloon_purchase', balloonData.Param.Price)
end)

-- Hook into balloon sales
AddEventHandler('rs_balloon:sell', function(playerId, sellPrice)
    -- Log to your economy system
    exports['my-economy']:LogTransaction(playerId, 'balloon_sale', sellPrice)
end)
```

---

### Example 5: Custom Rental Duration UI

**Client-side:**
```lua
RegisterNetEvent('rs_balloon:RentalStatus')
AddEventHandler('rs_balloon:RentalStatus', function(hasRental, timeRemaining)
    if hasRental then
        -- Show custom UI with time remaining
        local minutes = math.floor(timeRemaining / 60)
        local seconds = timeRemaining % 60
        
        SendNUIMessage({
            type = 'showRentalTimer',
            minutes = minutes,
            seconds = seconds
        })
    end
end)
```

---

## Troubleshooting

### Common Issues

**Issue:** Framework not detected
```lua
-- Solution: Force framework in config
Config.Framework = 'lxrcore'  -- or your framework
```

**Issue:** Database errors
```sql
-- Verify tables exist
SHOW TABLES LIKE 'balloon_%';

-- Check table structure
DESCRIBE balloon_buy;
DESCRIBE balloon_rentals;
```

**Issue:** Events not firing
```lua
-- Enable debug mode (add to config)
Config.Debug = true

-- Check console for event logs
```

---

## Support

For developer support:
- 📖 **Full Docs:** [docs/README.md](./README.md)
- 💬 **Discord:** [Join our community](https://discord.gg/CrKcWdfd3A)
- 🐛 **Issues:** [GitHub Issues](https://github.com/iboss21/lxr-balloon/issues)

---

**© 2026 iBoss21 / The Lux Empire | wolves.land**  
**Original Script © riversafe | All Rights Reserved**
