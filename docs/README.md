# 📚 LXR Balloon System - Documentation Hub

Welcome to the comprehensive documentation for the **LXR Balloon System** - The Land of Wolves' premium hot air balloon script for RedM.

---

## 🔗 Quick Links

| Document | Description |
|----------|-------------|
| [Installation Guide](./INSTALLATION.md) | Step-by-step installation instructions |
| [Configuration Guide](./CONFIGURATION.md) | Complete configuration reference |
| [Developer Documentation](./DEVELOPER.md) | API, events, exports, and integration |
| [Changelog](./CHANGELOG.md) | Version history and updates |
| [Credits](./CREDITS.md) | Attribution and acknowledgments |

---

## 📖 Documentation Overview

### For Server Owners

**Start Here:**
1. [Installation Guide](./INSTALLATION.md) - Get the script running on your server
2. [Configuration Guide](./CONFIGURATION.md) - Customize for your server

**Key Topics:**
- Setting up rental locations
- Configuring pricing and economy
- Adding multiple languages
- Troubleshooting common issues

---

### For Developers

**Start Here:**
1. [Developer Documentation](./DEVELOPER.md) - Complete API reference

**Key Topics:**
- Framework integration (LXRCore, RSG-Core, VORP, etc.)
- Server-side events and exports
- Client-side events and exports
- Database schema
- Custom integration examples

---

### For Contributors

**Start Here:**
1. [Credits](./CREDITS.md) - See who built this
2. [Changelog](./CHANGELOG.md) - Version history

**Contributing:**
- Fork the repository
- Make your improvements
- Submit a pull request
- Maintain attribution to original author

---

## 🚀 Quick Start

### Minimum Requirements
- RedM Server (latest build)
- VORP Core or LXRCore or RSG-Core
- oxmysql database resource
- uiprompt resource

### Basic Installation (3 Steps)

1. **Place the resource:**
```bash
cp -r lxr-balloon /path/to/server/resources/
```

2. **Import database:**
```bash
mysql -u user -p database < lxr-balloon/sql.sql
```

3. **Add to server.cfg:**
```cfg
ensure lxr-balloon
```

**[Full Installation Guide →](./INSTALLATION.md)**

---

## ⚙️ Configuration Examples

### Economy Settings

```lua
-- Budget Server (Low prices)
Config.BallonPrice = 2.00
Config.Globo[1]['Param']['Price'] = 500

-- Realistic Server (High prices)
Config.BallonPrice = 50.00
Config.Globo[1]['Param']['Price'] = 5000
```

**[Full Configuration Guide →](./CONFIGURATION.md)**

---

## 🔧 Developer Quick Reference

### Check Balloon Ownership
```lua
-- Server-side
local ownsBalloon = exports['lxr-balloon']:GetPlayerBalloonOwnership(source)
```

### Spawn Balloon
```lua
-- Client-side
TriggerEvent('rs_balloon:SpawnBalloon', coords, false)
```

### Give Balloon (Admin)
```lua
-- Server-side
exports['lxr-balloon']:GiveBalloonToPlayer(playerId, "Hot Air Balloon")
```

**[Full Developer Documentation →](./DEVELOPER.md)**

---

## 🎨 Features

### Player Features
✅ Purchase and own hot air balloons  
✅ Rent balloons for temporary use  
✅ Sell balloons back to store  
✅ Transfer balloons to other players  
✅ Realistic balloon controls  
✅ Multiple store locations  
✅ Multi-language support

### Technical Features
✅ Multi-framework support (LXRCore, RSG-Core, VORP, RedEM:RP, Standalone)  
✅ Database persistence  
✅ Configurable economy  
✅ Event-driven architecture  
✅ Export system for integration  
✅ Optimized performance  

---

## 🔒 Resource Name Protection

**IMPORTANT:** This resource **MUST** be named `lxr-balloon`.

The script includes built-in safeguards that prevent it from running if the resource name is changed. This protects the branding and ensures compatibility.

**If you see this error:**
```
🚫 RESOURCE NAME VIOLATION DETECTED! 🚫
Expected: lxr-balloon
Got: [your-name]
```

**Solution:**
1. Rename the folder to `lxr-balloon`
2. Update server.cfg to `ensure lxr-balloon`
3. Restart server

This protection is intentional and cannot be bypassed.

---

## 🌍 Supported Languages

- 🇬🇧 English
- 🇪🇸 Spanish (Español)
- 🇫🇷 French (Français)
- 🇧🇷 Portuguese - Brazil (Português BR)
- 🇵🇹 Portuguese - Portugal (Português PT)
- 🇩🇪 German (Deutsch)
- 🇮🇹 Italian (Italiano)
- 🇷🇴 Romanian (Română)

Change language in `config.lua`:
```lua
Config.Lang = 'English'
```

---

## 🎯 Framework Support

### Primary Support (Recommended)
- **LXRCore** - The Land of Wolves custom framework
- **RSG-Core** - Rexshack Gaming framework

### Legacy Support
- **VORP Core** - Full support maintained
- **RedEM:RP** - Full support maintained

### Standalone
- Works without any framework
- Basic economy features

**[Framework Configuration Guide →](./CONFIGURATION.md#framework-support)**

---

## 📸 Screenshots

See the main [README.md](../README.md) for screenshots of the system in action.

---

## 🆘 Getting Help

### Documentation Issues
If you find errors in the documentation:
- Open an issue on GitHub
- Include the document name and section
- Suggest corrections

### Script Issues
For bugs or problems:
- Check [Installation Guide](./INSTALLATION.md) troubleshooting section
- Check [Configuration Guide](./CONFIGURATION.md) troubleshooting section
- Search existing GitHub issues
- Open a new issue with details

### Feature Requests
Have ideas for improvements?
- Open a GitHub issue with "Feature Request" tag
- Describe the feature and use case
- Check if similar requests exist

---

## 🔗 Important Links

### Official Resources
- 🌐 **Website:** [wolves.land](https://www.wolves.land)
- 💬 **Discord:** [Join our community](https://discord.gg/CrKcWdfd3A)
- 💻 **GitHub:** [iBoss21](https://github.com/iBoss21)
- 🛒 **Store:** [The Lux Empire Store](https://theluxempire.tebex.io)

### Original Author
- 💻 **GitHub:** [riversafe33](https://github.com/riversafe33)
- 💝 **Support:** [Ko-fi](https://ko-fi.com/riversafe33)

---

## 📋 Documentation Structure

```
docs/
├── README.md              # This file - Documentation hub
├── INSTALLATION.md        # Installation guide
├── CONFIGURATION.md       # Configuration reference
├── DEVELOPER.md          # Developer API documentation
├── CHANGELOG.md          # Version history
└── CREDITS.md            # Attribution and credits
```

---

## 📝 Documentation Standards

Our documentation follows these standards:
- Clear, concise language
- Code examples for all features
- Troubleshooting sections
- Up-to-date with latest version
- Proper attribution maintained

---

## 🤝 Contributing to Documentation

Help us improve the docs:

1. **Found a typo?** Submit a PR
2. **Missing information?** Open an issue
3. **Better explanation?** Suggest improvements
4. **New examples?** Share your code

---

## 📜 License & Attribution

### Original Script
**© riversafe**  
Original hot air balloon script - [GitHub](https://github.com/riversafe33)

### LXR Modifications
**© 2026 iBoss21 / The Lux Empire**  
Documentation, branding, framework support - [wolves.land](https://www.wolves.land)

**[Full Credits →](./CREDITS.md)**

---

## 🔄 Version Information

**Current Version:** 2.0.0  
**Release Date:** February 2026  
**Framework Support:** LXRCore, RSG-Core, VORP, RedEM:RP, Standalone

**[View Changelog →](./CHANGELOG.md)**

---

## 🎓 Learning Path

### New to the Script?
1. Read the [Installation Guide](./INSTALLATION.md)
2. Follow setup instructions
3. Test basic functionality
4. Customize [Configuration](./CONFIGURATION.md)

### Want to Integrate?
1. Read [Developer Documentation](./DEVELOPER.md)
2. Review API examples
3. Test with your resources
4. Build custom features

### Need Support?
1. Check troubleshooting sections
2. Search existing issues
3. Ask in Discord
4. Open GitHub issue if needed

---

**Thank you for using LXR Balloon System!** 🎈

---

**🐺 The Land of Wolves** - მგლების მიწა  
**© 2026 iBoss21 / The Lux Empire | wolves.land**  
**Original Script © riversafe | All Rights Reserved**
