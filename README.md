# 🐺 LXR Balloon System - The Land of Wolves

```
    ██╗      █████╗ ███╗   ██╗██████╗      ██████╗ ███████╗    ██╗    ██╗ ██████╗ ██╗    ██╗   ██╗███████╗███████╗
    ██║     ██╔══██╗████╗  ██║██╔══██╗    ██╔═══██╗██╔════╝    ██║    ██║██╔═══██╗██║    ██║   ██║██╔════╝██╔════╝
    ██║     ███████║██╔██╗ ██║██║  ██║    ██║   ██║█████╗      ██║ █╗ ██║██║   ██║██║    ██║   ██║█████╗  ███████╗
    ██║     ██╔══██║██║╚██╗██║██║  ██║    ██║   ██║██╔══╝      ██║███╗██║██║   ██║██║    ╚██╗ ██╔╝██╔══╝  ╚════██║
    ███████╗██║  ██║██║ ╚████║██████╔╝    ╚██████╔╝██║         ╚███╔███╔╝╚██████╔╝███████╗╚████╔╝ ███████╗███████║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝      ╚═════╝ ╚═╝          ╚══╝╚══╝  ╚═════╝ ╚══════╝ ╚═══╝  ╚══════╝╚══════╝
```

## 📖 About

Hot Air Balloon System for **The Land of Wolves** 🐺 | Georgian RP 🇬🇪

**Server:** The Land of Wolves - მგლების მიწა - რჩეულთა ადგილი!  
**Tagline:** ისტორია ცოცხლდება აქ! (History Lives Here!)  
**Type:** Serious Hardcore Roleplay Server  
**Access:** Discord & Whitelisted

This script allows players to buy, sell, and rent hot air balloons in an immersive and dynamic way. Players can purchase their own balloons or rent one for temporary use. Perfect for roleplay servers looking to add a unique and scenic mode of transportation.

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

## 📋 Dependencies

- [uiprompt](https://github.com/riversafe33/uiprompt) - Required for UI prompts
- VORP Core - Framework support

## ✨ Features

- **Buy & Own Balloons:** Players can purchase their own hot air balloons
- **Rental System:** Temporary balloon rentals for short-term use
- **Sell Balloons:** Ability to sell owned balloons back to the store
- **Transfer System:** Transfer balloon ownership to other players
- **Multiple Locations:** Balloon stores and rental points across the map
- **Configurable Pricing:** Customizable purchase and rental prices
- **Time-Based Rentals:** Rental duration with automatic expiration
- **Immersive Controls:** Realistic balloon control system
- **Multi-Language Support:** English, French, Portuguese, German, Italian, Spanish, Romanian

## 📸 Screenshots

![20250927003200_1](https://github.com/user-attachments/assets/f76c6e5b-82b2-4514-86f8-6d8d8f9df023)

![20250927003210_1](https://github.com/user-attachments/assets/edb5a4bd-268d-4ad4-82c4-f8c607ac0a91)

![20250927003224_1](https://github.com/user-attachments/assets/bbba01b3-97c3-43e1-85da-a4a68c1be3b0)

![20250927003238_1](https://github.com/user-attachments/assets/8fd5d72c-9a58-4387-a9ac-a61e87a9a1e9)

![20250927003315_1](https://github.com/user-attachments/assets/f78b9fdd-cd0a-48c3-8d17-cd4f90ec1443)

![20250927003323_1](https://github.com/user-attachments/assets/91779dc4-22cd-45d3-b6b9-11804fef277a)

## 🎮 Installation

**⚠️ IMPORTANT: Resource Name Protection**

This resource **MUST** be named `lxr-balloon`. The script includes a safeguard in config.lua that prevents it from running if renamed. This protects the branding and ensures compatibility.

1. Ensure you have the required dependencies installed
2. Place `lxr-balloon` folder in your resources directory
3. Import the `sql.sql` file into your database
4. Add `ensure lxr-balloon` to your server.cfg
5. Configure settings in `config.lua` to your preferences
6. Restart your server

**📖 [Detailed Installation Guide](docs/INSTALLATION.md)**

---

## 🎯 Framework Support

**Primary Support (Priority):**
- ✅ **LXRCore** - The Land of Wolves custom framework (Priority 1)
- ✅ **RSG-Core** - Rexshack Gaming framework (Priority 1)

**Legacy Support:**
- ✅ **VORP Core** - Full support maintained
- ✅ **RedEM:RP** - Full support maintained

**Standalone:**
- ✅ Works without any framework

The script auto-detects your framework and adapts accordingly.

**📖 [Framework Configuration Guide](docs/CONFIGURATION.md#framework-support)**

## ⚙️ Configuration

All settings are controlled via `config.lua`:
- Language selection
- Framework configuration (auto-detect or manual)
- Rental prices and duration
- Balloon spawn locations
- Store locations and NPCs
- Selling percentages
- Balloon models and prices

**📖 [Complete Configuration Reference](docs/CONFIGURATION.md)**

---

## 🔧 Developer Documentation

Complete API reference with events, exports, and integration examples:

**📖 [Developer Documentation](docs/DEVELOPER.md)**

**Quick Examples:**
```lua
-- Check balloon ownership (server)
local ownsBalloon = exports['lxr-balloon']:GetPlayerBalloonOwnership(source)

-- Spawn balloon (client)
TriggerEvent('rs_balloon:SpawnBalloon', coords, false)

-- Give balloon (admin server command)
exports['lxr-balloon']:GiveBalloonToPlayer(playerId, "Hot Air Balloon")
```

---

## 📚 Documentation

Comprehensive documentation for all users:

- 📖 **[Installation Guide](docs/INSTALLATION.md)** - Step-by-step setup
- ⚙️ **[Configuration Guide](docs/CONFIGURATION.md)** - All config options
- 🔧 **[Developer Docs](docs/DEVELOPER.md)** - API, events, exports
- 📋 **[Changelog](docs/CHANGELOG.md)** - Version history
- 🎖️ **[Credits](docs/CREDITS.md)** - Attribution
- 📸 **[Screenshots](docs/SCREENSHOTS.md)** - Media guide

## 📝 License

© 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved

**Original Script:** © riversafe ([GitHub](https://github.com/riversafe33))  
**Modified & Branded by:** iBoss21 / The Lux Empire for The Land of Wolves

This script was originally created by riversafe and has been modified and branded for The Land of Wolves server. All modifications and branding are © 2026 iBoss21 / The Lux Empire. The original work and credit belong to riversafe.

---

**Developer:** iBoss21 / The Lux Empire  
**Original Author:** riversafe  
**Version:** 2.0.0  
**Framework:** VORP Core, RedEM:RP, Standalone  
**Performance:** Optimized for minimal server overhead and client FPS impact
