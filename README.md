# 🎈 LXR Balloon System - Advanced Hot Air Balloon Experience

```
    ██╗      █████╗ ███╗   ██╗██████╗      ██████╗ ███████╗    ██╗    ██╗ ██████╗ ██╗    ██╗   ██╗███████╗███████╗
    ██║     ██╔══██╗████╗  ██║██╔══██╗    ██╔═══██╗██╔════╝    ██║    ██║██╔═══██╗██║    ██║   ██║██╔════╝██╔════╝
    ██║     ███████║██╔██╗ ██║██║  ██║    ██║   ██║█████╗      ██║ █╗ ██║██║   ██║██║    ██║   ██║█████╗  ███████╗
    ██║     ██╔══██║██║╚██╗██║██║  ██║    ██║   ██║██╔══╝      ██║███╗██║██║   ██║██║    ╚██╗ ██╔╝██╔══╝  ╚════██║
    ███████╗██║  ██║██║ ╚████║██████╔╝    ╚██████╔╝██║         ╚███╔███╔╝╚██████╔╝███████╗╚████╔╝ ███████╗███████║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝      ╚═════╝ ╚═╝          ╚══╝╚══╝  ╚═════╝ ╚══════╝ ╚═══╝  ╚══════╝╚══════╝
```

## 📖 About

A comprehensive hot air balloon system for **The Land of Wolves** 🐺 | Georgian RP 🇬🇪

**Server:** The Land of Wolves - მგლების მიწა - რჩეულთა ადგილი!  
**Tagline:** ისტორია ცოცხლდება აქ! (History Lives Here!)  
**Type:** Serious Hardcore Roleplay Server  
**Access:** Discord & Whitelisted

Experience immersive aerial transportation with realistic mechanics including fuel consumption, damage systems, passenger invites, and repair requirements. Perfect for roleplay servers seeking authentic hot air balloon gameplay.

## 🔗 Links

- 🌐 **Website:** [wolves.land](https://www.wolves.land)
- 💬 **Discord:** [Join our community](https://discord.gg/CrKcWdfd3A)
- 🛒 **Store:** [The Lux Empire Store](https://theluxempire.tebex.io)
- 📊 **Server Listing:** [RedM Servers](https://servers.redm.net/servers/detail/8gj7eb)
- 💻 **GitHub:** [iBoss21](https://github.com/iBoss21)

## 💝 Support Development

I create and share digital tools with passion and purpose.

There's absolutely no pressure to donate, but if my work has been helpful to you, any contribution is sincerely appreciated.

Your support goes directly toward upgrading my PC and developing more free scripts for everyone.

Thank you for your support! ❤️

**Ko-fi:** [ko-fi.com/riversafe33](https://ko-fi.com/riversafe33)

---

## 🎯 Core Features

### 🛒 Ownership & Commerce
- **Purchase Balloons:** Buy and permanently own hot air balloons
- **Rental System:** Temporary balloon rentals with time limits
- **Sell Balloons:** Sell owned balloons back for 60% of purchase price
- **Transfer Ownership:** Gift or trade balloons to other players
- **Multiple Locations:** Stores and rental points across the map

### ⛽ Fuel System
- **Required Fuel:** Balloons require `balloon_fuel` items to operate
- **Random Consumption:** Each fuel can provides 10-15 minutes of flight (randomized)
- **Smart Calculation:** System automatically calculates fuel needs per rental
- **Configurable:** Can be enabled/disabled via config
- **Multi-Framework:** Works with all inventory systems

### 👥 Passenger System (NEW!)
- **Invite Players:** Owners can invite up to 2 passengers (3 total capacity)
- **Owner-Only Controls:** Only the balloon owner can control flight
- **Nearby Invites:** Invite players within configurable distance
- **Accept/Decline:** Players can accept or decline invitations
- **Safety:** Passengers can ride but cannot interfere with controls

### 💥 Damage & Combat System (NEW!)
- **Arrow Damage:** Takes 10-15 arrow hits to damage a balloon
- **Bullet Damage:** Bullets count as 2x damage (faster destruction)
- **Owner Death:** Balloon crashes if the owner is killed
- **Crash Mechanics:** Damaged balloons lose altitude and crash to ground
- **No Invincibility:** Players in balloons can be shot and killed
- **Visual Effects:** Crash animations and audio feedback

### 🔧 Repair System (NEW!)
- **Spawn Point Repairs:** Visit any balloon spawn location to repair
- **Material Requirements:**
  - Money (configurable amount)
  - Wood items (from crafting scripts)
  - Cloth items (from crafting scripts)
- **Damage Status:** Check balloon health in menu
- **Repair Menu:** Easy-to-use repair interface

### 🎮 Immersive Controls
- **Camera-Relative Movement:** Natural directional controls
- **Altitude Lock:** Lock balloon at current height
- **Variable Speed:** Hold sprint for faster movement
- **Storage System:** Store balloons safely when landed
- **Smart Prompts:** Context-sensitive UI prompts

### 🌍 Multi-Language Support
Complete translations in 9 languages:
- English 🇬🇧
- Georgian 🇬🇪
- Spanish 🇪🇸
- French 🇫🇷
- Portuguese (BR) 🇧🇷
- Portuguese (PT) 🇵🇹
- German 🇩🇪
- Italian 🇮🇹
- Romanian 🇷🇴

### 🔌 Multi-Framework Support
- **LXRCore** (Primary) - The Land of Wolves custom framework
- **RSG-Core** (Primary) - Rexshack Gaming framework
- **VORP Core** (Legacy) - Full support maintained
- **RedEM:RP** (Legacy) - Full support maintained
- **Standalone** - Works without framework

---

## 📋 Dependencies

### Required
- [uiprompt](https://github.com/riversafe33/uiprompt) - UI prompt system
- [oxmysql](https://github.com/overextended/oxmysql) - Database connector
- RedM Server (Build 1491 or higher recommended)

### Optional
- Framework (LXRCore, RSG-Core, VORP, or RedEM:RP)
- Crafting script that provides `wood` and `cloth` items

---

## 🎮 How It Works

### For Players

#### Purchasing a Balloon
1. Visit any balloon store (marked on map)
2. Speak with the NPC vendor
3. Select "Buy Balloon" from menu
4. Pay the purchase price
5. Your balloon is now owned!

#### Renting a Balloon
1. Visit a rental location (marked on map)
2. Ensure you have:
   - Enough money for rental fee
   - Required fuel cans (2-3 for 30 minutes)
3. Press `[SPACE]` at the rental point
4. Balloon spawns for the rental duration

#### Flying the Balloon
- **W/S:** Move North/South
- **A/D:** Move West/East
- **Space:** Ascend
- **X:** Descend
- **A Key:** Lock/Unlock altitude
- **Horn:** Store balloon (when landed)

#### Inviting Passengers
1. Enter your balloon as owner
2. Open the menu
3. Select "Invite Passenger"
4. Choose a nearby player (max 2 passengers)
5. They receive an invite prompt
6. They press `[ENTER]` to accept or `[BACKSPACE]` to decline

#### If Your Balloon Gets Damaged
- Takes 10-15 arrow hits or equivalent bullets
- Balloon starts losing altitude automatically
- Can't control balloon properly when damaged
- Must land and visit spawn location
- Use repair menu to fix (requires money, wood, cloth)

#### Combat Awareness
- You are **NOT invincible** in the balloon
- Arrows and bullets can hit and kill you
- If owner dies, balloon crashes
- Passengers should watch for threats
- Keep altitude and be aware of surroundings

---

## ⚙️ Configuration

### Basic Settings
```lua
-- Rental Settings
Config.EnableTax = true
Config.BallonPrice = 5.00
Config.BallonUseTime = 30 -- minutes

-- Fuel Requirements
Config.FuelRequirement = {
    enabled = true,
    itemName = 'balloon_fuel',
    minMinutesPerFuel = 10,
    maxMinutesPerFuel = 15,
}
```

### Passenger System
```lua
Config.PassengerSystem = {
    enabled = true,
    maxPassengers = 2,        -- Max 2 passengers + owner = 3 total
    inviteDistance = 10.0,    -- Meters
    inviteTimeout = 30,       -- Seconds
}
```

### Damage System
```lua
Config.DamageSystem = {
    enabled = true,
    arrowHitsToDestroy = 10,
    arrowHitsToDestroyMax = 15,
    bulletDamageMultiplier = 2,
    ownerDeathCrash = true,
    crashDescentSpeed = 0.5,
    
    repairMoney = 50,
    repairItems = {
        { name = 'wood', amount = 5 },
        { name = 'cloth', amount = 3 },
    }
}
```

---

## 🎨 Screenshots

![20250927003200_1](https://github.com/user-attachments/assets/f76c6e5b-82b2-4514-86f8-6d8d8f9df023)

![20250927003210_1](https://github.com/user-attachments/assets/edb5a4bd-268d-4ad4-82c4-f8c607ac0a91)

![20250927003224_1](https://github.com/user-attachments/assets/bbba01b3-97c3-43e1-85da-a4a68c1be3b0)

![20250927003238_1](https://github.com/user-attachments/assets/8fd5d72c-9a58-4387-a9ac-a61e87a9a1e9)

![20250927003315_1](https://github.com/user-attachments/assets/f78b9fdd-cd0a-48c3-8d17-cd4f90ec1443)

![20250927003323_1](https://github.com/user-attachments/assets/91779dc4-22cd-45d3-b6b9-11804fef277a)

---

## 🚀 Installation

### ⚠️ IMPORTANT: Resource Name Protection

This resource **MUST** be named `lxr-balloon`. The script includes a safeguard in config.lua that prevents it from running if renamed.

### Step 1: Download & Extract
1. Download the latest release
2. Extract to your resources directory
3. Ensure folder is named `lxr-balloon`

### Step 2: Database Setup
```sql
-- Run the sql.sql file in your database
-- This creates 4 tables:
-- - balloon_buy (ownership tracking)
-- - balloon_rentals (rental tracking)
-- - balloon_passengers (passenger invites)
-- - balloon_damage (damage tracking)
```

### Step 3: Item Setup
Add these items to your framework's item database:

```lua
-- Balloon Fuel (Required for rentals)
balloon_fuel = {
    name = 'balloon_fuel',
    label = 'Balloon Fuel',
    weight = 500,
    type = 'item',
    image = 'baloonfuel.png',
    unique = false,
    useable = false,
    description = 'Fuel for hot air balloons'
}

-- Wood (Required for repairs)
wood = {
    name = 'wood',
    label = 'Wood Planks',
    weight = 250,
    type = 'item',
    image = 'wood.png',
    description = 'Wooden planks for repairs'
}

-- Cloth (Required for repairs)
cloth = {
    name = 'cloth',
    label = 'Cloth',
    weight = 100,
    type = 'item',
    image = 'cloth.png',
    description = 'Fabric for balloon repairs'
}
```

### Step 4: Server Configuration
```cfg
# Add to server.cfg
ensure oxmysql
ensure uiprompt
ensure lxr-balloon
```

### Step 5: Configuration
1. Edit `config.lua` to customize:
   - Prices and rental durations
   - Fuel requirements
   - Damage settings
   - Repair costs
   - Passenger system settings
   - Language preference

### Step 6: Restart Server
```
restart lxr-balloon
```

---

## 📖 Documentation

- **[Installation Guide](docs/INSTALLATION.md)** - Detailed setup instructions
- **[Configuration Guide](docs/CONFIGURATION.md)** - All config options explained
- **[Developer Guide](docs/DEVELOPER.md)** - API and events documentation
- **[Changelog](docs/CHANGELOG.md)** - Version history

---

## 🎯 Gameplay Tips

### For Balloon Owners
- Always check fuel before long trips
- Keep repair materials in inventory
- Watch for hostile players with bows/guns
- Invite trusted passengers only
- Land safely before logging out

### For Passengers
- Respect the owner's flight path
- Don't spam invites
- Be ready to bail if balloon is under attack
- Enjoy the view!

### For Raiders/Bandits
- 10-15 arrows to bring down a balloon
- Bullets work faster (2x damage)
- Aim for the balloon fabric, not just the basket
- Killing the owner crashes the balloon
- Downed balloons can be looted

---

## 🔧 Troubleshooting

### Balloon won't spawn
- Check fuel inventory
- Verify you have enough money
- Ensure no active rental exists
- Check console for errors

### Can't control balloon
- You must be the owner
- Passengers cannot control
- Check if balloon is damaged

### Repair not working
- Verify you have required items
- Check money balance
- Balloon must be at spawn location
- Must be damaged to repair

### Players are invincible
- This has been fixed in v2.1.0
- Players can now be damaged/killed
- Update to latest version

---

## 🤝 Credits

### Original Script
**Author:** riversafe  
**GitHub:** [riversafe33](https://github.com/riversafe33)

### Modified & Enhanced By
**Developer:** iBoss21 / The Lux Empire  
**For:** The Land of Wolves - მგლების მიწა  
**GitHub:** [iBoss21](https://github.com/iBoss21)

### Special Thanks
- The Land of Wolves community
- RedM development community
- All contributors and testers

---

## 📝 License & Usage

© 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved  
Original Script © riversafe - With respect and appreciation

**Usage Terms:**
- Free for personal use
- Commercial use requires permission
- Must maintain credits
- Resource name must remain `lxr-balloon`

---

## 🐛 Support & Issues

Found a bug? Have a suggestion?

- **Discord:** [Join our community](https://discord.gg/CrKcWdfd3A)
- **GitHub Issues:** [Report a bug](https://github.com/iBoss21/lxr-balloon/issues)
- **Documentation:** Check the docs/ folder

---

## 🔄 Version

**Current Version:** 2.2.0  
**Last Updated:** February 2, 2026  
**Compatibility:** RedM Build 1491+

### Recent Updates
- ✅ Passenger invite system
- ✅ Damage and combat mechanics
- ✅ Repair system with material requirements
- ✅ Fixed player invincibility
- ✅ Enhanced translations
- ✅ Improved performance

---

<div align="center">

**Made with ❤️ for The Land of Wolves 🐺**

*ისტორია ცოცხლდება აქ! (History Lives Here!)*

</div>
