# 🚀 Quick Start Guide - LXR Balloon System

Get up and running in 5 minutes!

---

## ⚡ Prerequisites Check

Before starting, ensure you have:
- [ ] RedM server (latest build)
- [ ] Database (MySQL/MariaDB)
- [ ] One of these frameworks:
  - [ ] LXRCore, or
  - [ ] RSG-Core, or
  - [ ] VORP Core, or
  - [ ] RedEM:RP, or
  - [ ] None (Standalone works too!)
- [ ] uiprompt resource installed
- [ ] oxmysql resource installed

---

## 📦 Installation (5 Steps)

### Step 1: Download
```bash
# Clone or download the repository
git clone https://github.com/iboss21/lxr-balloon.git
```

### Step 2: Place Resource
```bash
# Copy to your resources folder
cp -r lxr-balloon /path/to/your/server/resources/

# ⚠️ IMPORTANT: Folder MUST be named "lxr-balloon"
```

### Step 3: Database
```sql
-- Import the SQL file
mysql -u your_username -p your_database < lxr-balloon/sql.sql

-- Or use phpMyAdmin/HeidiSQL to import sql.sql
```

### Step 4: Server Config
```cfg
# Add to your server.cfg (after dependencies)
ensure vorp_core        # or your framework
ensure oxmysql
ensure uiprompt

ensure lxr-balloon      # ⚠️ Must be this exact name
```

### Step 5: Configure (Optional)
```lua
-- Edit lxr-balloon/config.lua

-- Change language if needed
Config.Lang = 'English'  -- or Spanish, French, etc.

-- Adjust prices
Config.BallonPrice = 5.00        -- Rental price
Config.Globo[1]['Param']['Price'] = 1250  -- Purchase price
```

---

## ✅ Verify Installation

### 1. Start Server
```bash
# Start or restart your server
restart your_server_name
```

### 2. Check Console
Look for:
```
✅ [lxr-balloon] Resource started successfully
✅ [lxr-balloon] Framework detected: vorp (or your framework)
```

**If you see name violation error:**
```
🚫 RESOURCE NAME VIOLATION DETECTED!
```
→ Rename folder to exactly `lxr-balloon`

### 3. Test In-Game
1. Join your server
2. Open map
3. Look for balloon blips (🎈 icons)
4. Visit Valentine balloon store
5. Interact with NPC

---

## 🎮 Player Quick Guide

### Purchasing a Balloon
1. Visit any balloon store (check map for blips)
2. Talk to the NPC
3. Select "Buy Balloon"
4. Choose balloon type
5. Confirm purchase

**Store Locations:**
- Valentine (New Hanover)
- Saint Denis (Lemoyne)
- Rhodes (Lemoyne)
- Strawberry (West Elizabeth)
- Blackwater (West Elizabeth)

### Renting a Balloon
1. Visit rental location (different blip)
2. Press `[SPACE]` when prompted
3. Pay rental fee
4. Balloon spawns nearby
5. Enter and fly!

### Flying the Balloon
```
Controls:
[W/S]     - North/South movement
[A/D]     - West/East movement  
[Q/E]     - Up/Down altitude
[X]       - Brake/Descend quickly
[Space]   - Lock current altitude
[H]       - Delete balloon (owned only)
```

### Selling Your Balloon
1. Visit any balloon store
2. Talk to NPC
3. Select "Sell Balloon"
4. Confirm sale
5. Receive 60% of purchase price (configurable)

---

## ⚙️ Quick Configuration

### Change Language
```lua
-- In config.lua
Config.Lang = 'Spanish'  -- English, French, Portuguese_BR, 
                         -- Portuguese_PT, German, Italian, 
                         -- Spanish, Romanian
```

### Adjust Economy
```lua
-- Rental Settings
Config.EnableTax = true              -- Charge for rentals
Config.BallonPrice = 5.00            -- Rental cost
Config.BallonUseTime = 30            -- Minutes

-- Purchase Settings
Config.Globo[1]['Param']['Price'] = 1250  -- Buy price
Config.Sellprice = 0.6               -- 60% return on sale
```

### Add Locations
```lua
-- Add to Config.BalloonLocations
[2] = {
    coords = vector3(x, y, z),       -- Your coordinates
    spawn = vector3(x, y, z),        -- Spawn point
    name = "Your Location",
    sprite = -1595467349
}
```

---

## 🔧 Framework Configuration

### Auto-Detection (Recommended)
```lua
Config.Framework = 'auto'  -- Automatically detects framework
```

### Manual Override
```lua
Config.Framework = 'lxrcore'  -- Force specific framework
-- Options: 'lxrcore', 'rsg-core', 'vorp', 'redemrp', 'standalone'
```

---

## 🐛 Troubleshooting

### Resource Won't Start

**Problem:** Resource shows as stopped

**Quick Fix:**
```bash
# Check resource name
ls resources/ | grep balloon

# Should show: lxr-balloon
# If different, rename it:
mv resources/old-name resources/lxr-balloon
```

### Database Errors

**Problem:** "Table doesn't exist" error

**Quick Fix:**
```bash
# Re-import SQL
mysql -u username -p database < lxr-balloon/sql.sql

# Verify tables exist
mysql -u username -p -e "SHOW TABLES LIKE 'balloon%';" database
```

### NPCs Not Spawning

**Problem:** Can't find balloon stores

**Quick Fix:**
```lua
-- Check NPC coordinates in config.lua
-- Restart resource
restart lxr-balloon
```

### Can't Rent/Purchase

**Problem:** Nothing happens when interacting

**Quick Fix:**
1. Check you have enough money
2. Verify framework is detected (check server console)
3. Check dependencies are running:
   ```
   restart vorp_core
   restart oxmysql
   restart uiprompt
   restart lxr-balloon
   ```

---

## 📚 Need More Help?

### Documentation
- 📖 [Full Installation Guide](./INSTALLATION.md)
- ⚙️ [Configuration Reference](./CONFIGURATION.md)
- 🔧 [Developer API Docs](./DEVELOPER.md)
- 📋 [Changelog](./CHANGELOG.md)

### Support
- 💬 **Discord:** [The Land of Wolves](https://discord.gg/CrKcWdfd3A)
- 🐛 **Issues:** [GitHub Issues](https://github.com/iboss21/lxr-balloon/issues)
- 🌐 **Website:** [wolves.land](https://www.wolves.land)

### Original Author
- 💻 **GitHub:** [riversafe33](https://github.com/riversafe33)
- 💝 **Support:** [Ko-fi](https://ko-fi.com/riversafe33)

---

## ✨ Tips & Tricks

### Performance
- Default settings are optimized
- Rental timers use efficient checks
- NPCs spawn only when near

### Economy Balance
```lua
# Low-end server
Config.BallonPrice = 2.00
Config.Globo[1]['Param']['Price'] = 500

# Mid-range server (default)
Config.BallonPrice = 5.00
Config.Globo[1]['Param']['Price'] = 1250

# High-end server
Config.BallonPrice = 50.00
Config.Globo[1]['Param']['Price'] = 5000
```

### Custom Locations
Get coordinates in-game:
1. Stand at desired location
2. F8 console
3. Type: `/getcoords`
4. Copy vector3 coordinates
5. Add to config.lua

---

## 🎯 Next Steps

1. ✅ Install and test basic functionality
2. 📝 Customize prices for your economy
3. 📍 Add custom locations if desired
4. 🌍 Change language if needed
5. 🎨 Enjoy your new balloon system!

---

## 🏁 You're Ready!

Your LXR Balloon System is now installed and configured. Players can now:
- 🎈 Purchase hot air balloons
- 🎈 Rent balloons temporarily
- 🎈 Fly across the map
- 🎈 Sell and transfer balloons

**Enjoy scenic transportation in Red Dead Redemption 2!**

---

**🐺 The Land of Wolves** - მგლების მიწა  
**© 2026 iBoss21 / The Lux Empire | wolves.land**  
**Original Script © riversafe | All Rights Reserved**
