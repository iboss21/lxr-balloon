# 🐺 LXR Balloon - Installation Guide

## Prerequisites

Before installing LXR Balloon System, ensure you have the following:

### Required
- **RedM Server** - A working RedM server installation
- **VORP Core** - Latest version of VORP framework
- **oxmysql** - Database resource for MySQL connections
- **uiprompt** - UI prompt system ([GitHub](https://github.com/riversafe33/uiprompt))

### Server Requirements
- RedM server build: Latest stable
- MySQL/MariaDB database
- Minimum 2GB RAM allocated to server
- FiveM/Cfx.re artifacts: Latest recommended

---

## Installation Steps

### 1. Download the Resource

```bash
# Clone from GitHub
git clone https://github.com/iboss21/lxr-balloon.git

# Or download the latest release from GitHub
```

### 2. Install Dependencies

Ensure all dependencies are installed and started before LXR Balloon:

```lua
-- In your server.cfg, ensure these are loaded first:
ensure vorp_core
ensure oxmysql
ensure uiprompt
```

### 3. Place the Resource

```bash
# Move the lxr-balloon folder to your resources directory
cp -r lxr-balloon /path/to/your/server/resources/
```

### 4. Database Setup

Import the SQL file to create the required database tables:

```bash
# Using MySQL command line
mysql -u your_username -p your_database < lxr-balloon/sql.sql

# Or use phpMyAdmin / HeidiSQL to import the sql.sql file
```

The script creates two tables:
- `balloon_buy` - Stores balloon ownership data
- `balloon_rentals` - Manages temporary balloon rentals

### 5. Configure the Script

Edit the configuration file to match your server settings:

```bash
nano lxr-balloon/config.lua
```

**Key settings to configure:**
- `Config.Lang` - Set your preferred language
- `Config.BallonPrice` - Rental price
- `Config.BallonUseTime` - Rental duration in minutes
- `Config.BalloonLocations` - Add/modify rental locations
- `Config.Marker` - Configure store locations
- `Config.Globo` - Set balloon purchase prices

### 6. Add to Server Configuration

Add the resource to your `server.cfg`:

```cfg
# LXR Balloon System - The Land of Wolves
ensure lxr-balloon
```

**Important:** Ensure it starts AFTER the required dependencies:

```cfg
# Correct load order:
ensure vorp_core
ensure oxmysql
ensure uiprompt

# Your other resources...

# LXR Balloon System
ensure lxr-balloon
```

### 7. Restart Server

```bash
# Restart your RedM server
restart server_name

# Or if using txAdmin, use the restart button
```

### 8. Verify Installation

1. Join your server
2. Check F8 console for any errors
3. Visit a balloon store location (see config.lua for coordinates)
4. Look for the balloon store blip on the map
5. Interact with the NPC to test purchasing

---

## Troubleshooting

### Script Not Loading

**Problem:** Resource shows as "stopped" in server console

**Solution:**
```bash
# Check for typos in server.cfg
# Verify folder name is exactly: lxr-balloon
# Check file permissions (Linux servers)
chmod -R 755 lxr-balloon/
```

### Database Errors

**Problem:** "Table doesn't exist" errors in console

**Solution:**
- Verify sql.sql was imported correctly
- Check database connection in oxmysql configuration
- Ensure database user has proper permissions

### UI Prompts Not Showing

**Problem:** Can't see interaction prompts

**Solution:**
- Ensure `uiprompt` resource is installed and started
- Check that uiprompt is loaded BEFORE lxr-balloon
- Verify uiprompt path in fxmanifest.lua: `"@uiprompt/uiprompt.lua"`

### NPCs Not Spawning

**Problem:** Balloon store NPCs are missing

**Solution:**
- Check server console for entity creation errors
- Verify NPC coordinates in config.lua match valid map locations
- Restart the resource: `restart lxr-balloon`

### Can't Purchase/Rent Balloons

**Problem:** No money deducted, no balloon spawns

**Solution:**
- Verify VORP Core is working correctly
- Check player has sufficient money
- Review server console for error messages
- Ensure balloon spawn coordinates are valid locations

---

## Post-Installation Configuration

### Adding Custom Locations

You can add more balloon stores and rental locations:

```lua
-- In config.lua, add to Config.BalloonLocations:
[3] = {
    coords = vector3(x, y, z),  -- Your coordinates
    spawn = vector3(x, y, z),   -- Spawn point
    name = "Your Location Name",
    sprite = -1595467349
},
```

### Adjusting Prices

Modify prices to match your server economy:

```lua
Config.BallonPrice = 5.00      -- Rental price
Config.Sellprice = 0.6         -- 60% return on sale
Config.Globo[1]['Param']['Price'] = 1250  -- Purchase price
```

### Language Configuration

Change the language in config.lua:

```lua
Config.Lang = 'English'  -- Options: English, French, Portuguese_BR, 
                         -- Portuguese_PT, German, Italian, Spanish, Romanian
```

---

## Updating the Script

### Manual Update

1. Backup your `config.lua` file
2. Download the latest version
3. Replace all files EXCEPT `config.lua`
4. Review changelog for new configuration options
5. Merge any new config options into your backup
6. Restart the resource

### Git Update

```bash
cd resources/lxr-balloon
git pull origin main
# Review changes and restore your custom config if needed
restart lxr-balloon
```

---

## Support

Need help with installation?

- 📖 **Documentation:** [Full Documentation](./README.md)
- 💬 **Discord:** [Join our community](https://discord.gg/CrKcWdfd3A)
- 🐛 **Issues:** [GitHub Issues](https://github.com/iboss21/lxr-balloon/issues)
- 🌐 **Website:** [wolves.land](https://www.wolves.land)

---

**© 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved**
