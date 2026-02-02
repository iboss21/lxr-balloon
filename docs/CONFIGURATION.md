# 🐺 LXR Balloon - Configuration Guide

Complete configuration reference for the LXR Balloon System.

---

## Table of Contents

1. [Server Branding](#server-branding)
2. [Language Settings](#language-settings)
3. [Rental System](#rental-system)
4. [Store Configuration](#store-configuration)
5. [NPC Configuration](#npc-configuration)
6. [Pricing & Economy](#pricing--economy)
7. [Advanced Settings](#advanced-settings)

---

## Server Branding

Located at the top of `config.lua`, this section contains your server's branding information.

```lua
Config.ServerInfo = {
    name = 'The Land of Wolves 🐺',
    tagline = 'Georgian RP 🇬🇪 | მგლების მიწა - რჩეულთა ადგილი!',
    description = 'ისტორია ცოცხლდება აქ!',
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
```

**Customization:**
- Update all URLs and contact information to match your server
- Modify name, tagline, and description for your community
- Add relevant tags that describe your server

---

## Language Settings

### Available Languages

The script supports multiple languages out of the box:

```lua
Config.Lang = 'English'
```

**Supported Languages:**
- `English` - Full English translation
- `French` - French (Français)
- `Portuguese_BR` - Brazilian Portuguese (Português BR)
- `Portuguese_PT` - European Portuguese (Português PT)
- `German` - German (Deutsch)
- `Italian` - Italian (Italiano)
- `Spanish` - Spanish (Español)
- `Romanian` - Romanian (Română)

**Usage:**
Simply change the `Config.Lang` value to your preferred language. All UI prompts, notifications, and menu texts will automatically update.

---

## Rental System

### Basic Rental Settings

```lua
Config.KeyToBuyBalloon = 0xD9D0E1C0  -- SPACE key
Config.EnableTax = true               -- Enable/disable rental fees
Config.BallonPrice = 5.00             -- Rental price in currency
Config.BallonUseTime = 30             -- Duration in minutes
Config.BalloonModel = "hotairballoon01x"
```

**Parameters Explained:**

- **KeyToBuyBalloon**: Control key for renting (0xD9D0E1C0 = SPACE)
- **EnableTax**: 
  - `true` = Players must pay to rent
  - `false` = Rentals are free
- **BallonPrice**: Cost per rental (adjust for your economy)
- **BallonUseTime**: How long the rental lasts (in minutes)
- **BalloonModel**: Game model name (do not change unless using custom models)

### Fuel Requirement Settings

New in this version! You can now require players to have fuel items to rent balloons:

```lua
Config.FuelRequirement = {
    enabled = true,                -- Enable/disable fuel requirement
    itemName = 'balloon_fuel',     -- Name of the fuel item in your inventory system
    minMinutesPerFuel = 10,        -- Minimum flight time per fuel can
    maxMinutesPerFuel = 15,        -- Maximum flight time per fuel can
}
```

**How It Works:**

1. **Random Consumption**: The system randomly calculates fuel consumption between min and max values
2. **Example Calculation** (for 30 minute rental):
   - Best case: 30 ÷ 15 = **2 fuel cans** needed
   - Worst case: 30 ÷ 10 = **3 fuel cans** needed
   - Each rental randomly picks consumption rate for realistic gameplay

**Configuration Options:**

- **enabled**: 
  - `true` = Fuel requirement is active
  - `false` = Disabled (only money required)
- **itemName**: Must match your item name exactly (case-sensitive)
- **minMinutesPerFuel**: Lower value = more fuel consumption
- **maxMinutesPerFuel**: Higher value = less fuel consumption

**Framework Compatibility:**
- ✅ LXRCore
- ✅ RSG-Core  
- ✅ VORP Core
- ✅ RedEM:RP
- ✅ Standalone (fuel always available in standalone mode)

**Item Setup:**
The fuel item must exist in your server's item database. Example item configuration:
```lua
balloon_fuel = {
    name = 'balloon_fuel',
    label = 'Balloon Fuel',
    weight = 500,
    type = 'item',
    image = 'baloonfuel.png',
    unique = true,
    useable = true,
    shouldClose = true,
    combinable = nil,
    level = 0,
    description = 'Fuel for hot air balloons',
    delete = true
}
```

### Rental Locations

Add as many rental locations as you want:

```lua
Config.BalloonLocations = {
    [1] = {
        coords = vector3(-397.65, 715.95, 114.88),  -- Prompt location
        spawn = vector3(-406.58, 714.25, 115.47),   -- Balloon spawn point
        name = "Hot Air Balloon Rental",             -- Blip name
        sprite = -1595467349                         -- Blip icon
    },
    [2] = {
        coords = vector3(x, y, z),
        spawn = vector3(x, y, z),
        name = "Another Rental Location",
        sprite = -1595467349
    },
    -- Add more locations...
}
```

**Finding Coordinates:**
1. Stand at desired location in-game
2. Open F8 console
3. Type: `/getcoords` or stand and get coords from teleport menu
4. Copy the vector3 coordinates

---

## Store Configuration

### Store Locations

Configure permanent balloon stores where players can purchase balloons:

```lua
Config.Marker = {
    ["valentine"] = {
        name = "Hot Air Balloon Store",
        sprite = -780469251,
        x = -290.4917, 
        y = 691.4873, 
        z = 112.3616,
        spawn = {x = -289.77, y = 699.64, z = 113.45}
    },
    ["saint_denis"] = {
        name = "Hot Air Balloon Store",
        sprite = -780469251,
        x = 2477.2075, 
        y = -1364.8922, 
        z = 45.3138,
        spawn = {x = 2463.88, y = -1372.9, z = 45.31}
    },
    -- Add more stores...
}
```

**Default Locations:**
- Valentine
- Saint Denis
- Rhodes
- Strawberry
- Blackwater

**Adding New Stores:**

```lua
["your_location"] = {
    name = "Your Store Name",
    sprite = -780469251,           -- Blip sprite
    x = 0.0, y = 0.0, z = 0.0,    -- Store/NPC location
    spawn = {x = 0.0, y = 0.0, z = 0.0}  -- Where balloon spawns
}
```

---

## NPC Configuration

### NPC Settings

Configure the NPCs that sell and rent balloons:

```lua
Config.NPC = {
    model = "A_M_M_UniBoatCrew_01",
    coords = {
        vector4(-290.4917, 691.4873, 112.3616, 309.47),    -- Valentine Store
        vector4(2477.2075, -1364.8922, 45.3138, 103.17),   -- Saint Denis Store
        vector4(1225.9724, -1271.1418, 74.9349, 249.81),   -- Rhodes Store
        vector4(-1843.4991, -431.0219, 158.5752, 153.76),  -- Strawberry Store
        vector4(-839.0341, -1218.6031, 42.3995, 12.37),    -- Blackwater Store
        vector4(-397.6555, 715.9544, 114.8862, 109.31),    -- Valentine Rental
    }
}
```

**Parameters:**
- **model**: NPC ped model (RedM ped hash)
- **coords**: vector4(x, y, z, heading) for each NPC
  - `x, y, z` = position
  - `heading` = direction NPC faces (0-360 degrees)

**Popular NPC Models:**
- `A_M_M_UniBoatCrew_01` - Default boat crew
- `A_M_M_RanchOwner_01` - Ranch owner
- `A_M_M_SDFancyDancer_01` - Fancy gentleman
- `CS_clay` - Clay (story character)

---

## Pricing & Economy

### Sell Price Configuration

When players sell their balloon back:

```lua
Config.Sellprice = 0.6  -- 60% of original price
```

**Examples:**
- `1.0` = 100% refund (full price back)
- `0.6` = 60% refund (default)
- `0.5` = 50% refund
- `0.0` = No refund (cannot sell)

### Balloon Products

Configure purchasable balloon types and prices:

```lua
Config.Globo = {
    [1] = {
        ['Text'] = "Hot Air Balloon",
        ['Param'] = {
           ['Name'] = "Hot Air Balloon",
           ['Price'] = 1250,  -- Purchase price
        }
    },
    -- Add more balloon types:
    [2] = {
        ['Text'] = "Premium Balloon",
        ['Param'] = {
           ['Name'] = "Premium Balloon",
           ['Price'] = 2500,
        }
    },
}
```

**Adding Multiple Balloon Types:**
1. Copy the existing balloon configuration
2. Increment the index number `[1]`, `[2]`, etc.
3. Change the name and price
4. Players will see multiple options in the store

---

## Advanced Settings

### Control Keys

All control keys use RedM control hashes:

```lua
Config.KeyToBuyBalloon = 0xD9D0E1C0  -- SPACE
```

**Common Control Hashes:**
- `0xD9D0E1C0` - SPACE
- `0xCEFD9220` - E key
- `0x07CE1E61` - ENTER

**Finding Control Hashes:**
See [RedM Controls Documentation](https://docs.fivem.net/docs/game-references/controls/)

### Balloon Model

```lua
Config.BalloonModel = "hotairballoon01x"
```

**Available Models:**
- `hotairballoon01` - Standard hot air balloon
- `hotairballoon01x` - Variant (check game files)

**Custom Models:**
If you have a custom balloon model, replace with your model name.

### Performance Tuning

The script is optimized by default, but you can adjust:

**Thread Wait Times:**
Located in client files (avoid editing unless necessary):
- Balloon control thread: 0ms (active control)
- NPC spawn thread: 1000ms (checks every second)
- Prompt display: 100ms (smooth UI updates)

---

## Example Configurations

### Budget Server (Low Prices)

```lua
Config.BallonPrice = 2.00        -- Cheap rentals
Config.BallonUseTime = 60        -- Long rental time
Config.Sellprice = 0.8           -- High resale value
Config.Globo[1]['Param']['Price'] = 500  -- Affordable purchase
```

### Realistic Economy (High Prices)

```lua
Config.BallonPrice = 50.00       -- Expensive rentals
Config.BallonUseTime = 15        -- Short rental time
Config.Sellprice = 0.4           -- Low resale value
Config.Globo[1]['Param']['Price'] = 5000  -- Premium purchase
```

### Free Transportation Server

```lua
Config.EnableTax = false         -- No rental fee
Config.BallonPrice = 0.00        -- Free (not used)
Config.BallonUseTime = 120       -- 2 hour rentals
Config.Globo[1]['Param']['Price'] = 0  -- Free purchase
```

---

## Troubleshooting Configuration

### Prices Not Working

**Issue:** Players are charged wrong amount

**Solution:**
- Verify `Config.BallonPrice` is a number (no quotes)
- Check `Config.EnableTax` is true for rental fees
- Restart the resource after config changes

### Locations Not Showing

**Issue:** Blips or NPCs missing on map

**Solution:**
- Verify coordinates are valid (test by teleporting there)
- Check vector3/vector4 syntax is correct (commas, no missing values)
- Ensure coordinates are within map bounds
- Check for duplicate location keys (must be unique)

### Language Not Changing

**Issue:** Text still in wrong language

**Solution:**
- Verify `Config.Lang` exactly matches available language
- Check spelling and capitalization
- Restart resource (not just refresh)
- Clear client cache if needed

---

## Support

Need help with configuration?

- 📖 **Full Documentation:** [docs/README.md](./README.md)
- 💬 **Discord:** [Join our community](https://discord.gg/CrKcWdfd3A)
- 🐛 **Report Issues:** [GitHub Issues](https://github.com/iboss21/lxr-balloon/issues)

---

**© 2026 iBoss21 / The Lux Empire | wolves.land**  
**Original Script © riversafe | All Rights Reserved**
