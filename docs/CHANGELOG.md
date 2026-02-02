# 📋 Changelog

All notable changes to the LXR Balloon System will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.0] - 2026-02-02

### 🎨 Branding & Rebranding
- **BREAKING**: Renamed resource folder from `rs_balloon` to `lxr-balloon`
- Added comprehensive Land of Wolves branding throughout
- Added professional ASCII art headers to config files
- Updated fxmanifest.lua with proper author attribution
- Created professional documentation structure

### 📚 Documentation
- Added comprehensive INSTALLATION.md guide
- Added detailed CONFIGURATION.md reference
- Added CHANGELOG.md for version tracking
- Added CREDITS.md for proper attribution
- Restructured README.md with professional formatting
- Created docs/ folder for organized documentation

### 🏷️ Credits
- Added proper attribution to original author (riversafe)
- Maintained credit links throughout all files
- Added copyright notices with dual attribution

### 🔧 Configuration
- Added `Config.ServerInfo` section for server branding
- Organized config.lua with clear section headers
- Added professional comments and structure
- Maintained backward compatibility with existing configs

### 📝 Files Changed
- `README.md` - Complete professional rewrite
- `fxmanifest.lua` - Updated branding and version
- `config.lua` - Added headers and server info section
- Folder structure - Renamed to lxr-balloon

### ⚠️ Migration Notes
If updating from a previous version:
1. Rename your resource folder from `rs_balloon` to `lxr-balloon`
2. Update `server.cfg` to use `ensure lxr-balloon`
3. Review new `Config.ServerInfo` section (optional customization)
4. No database changes required
5. All existing features remain functional

---

## [1.0.0] - Original Release

### ✨ Features (Original Script by riversafe)
- Hot air balloon rental system
- Balloon purchase and ownership
- Balloon selling with configurable return percentage
- Balloon transfer between players
- Multiple store locations (Valentine, Saint Denis, Rhodes, Strawberry, Blackwater)
- Rental locations with time-based expiration
- NPC vendors at all locations
- Configurable pricing system
- Multi-language support (8 languages)
- Immersive balloon controls
- Camera-relative and fixed control modes
- Altitude locking system
- Time-based rental tracking
- Database persistence for ownership and rentals

### 🗄️ Database
- `balloon_buy` table for ownership tracking
- `balloon_rentals` table for rental management

### 🌍 Languages
- English
- Spanish
- French
- Portuguese (BR)
- Portuguese (PT)
- German
- Italian
- Romanian

### 🎮 Controls
- Directional movement (WASD / Arrow keys)
- Altitude control (Q/E)
- Altitude lock (A key)
- Brake/Descent (X key)
- Delete balloon (Horn - owned balloons only)
- Toggle control mode

### 💰 Economy
- Configurable rental prices
- Configurable purchase prices
- Configurable sell-back percentage
- Tax toggle for rental fees

---

## Upcoming Features

### Planned for Future Releases
- [ ] Multiple balloon models/skins
- [ ] Passenger system (multi-seat balloons)
- [ ] Fuel system for realism
- [ ] Weather-based mechanics
- [ ] Advanced physics options
- [ ] Custom balloon colors/patterns
- [ ] Balloon racing events support
- [ ] Integration with other transportation systems
- [ ] Admin commands for balloon management
- [ ] Statistics tracking (distance traveled, time in air)

---

## Version History

| Version | Date | Description |
|---------|------|-------------|
| 2.0.0 | 2026-02-02 | LXR Rebranding & Professional Documentation |
| 1.0.0 | Original | Initial release by riversafe |

---

## Credits

**Version 2.0.0 - LXR Branding:**
- Rebranded by: iBoss21 / The Lux Empire
- For: The Land of Wolves (wolves.land)
- Changes: Documentation, branding, structure

**Version 1.0.0 - Original Script:**
- Created by: riversafe
- GitHub: https://github.com/riversafe33
- Ko-fi: https://ko-fi.com/riversafe33

---

## Support & Links

- 🌐 **Website:** [wolves.land](https://www.wolves.land)
- 💬 **Discord:** [Join our community](https://discord.gg/CrKcWdfd3A)
- 🛒 **Store:** [The Lux Empire Store](https://theluxempire.tebex.io)
- 💻 **GitHub:** [iBoss21](https://github.com/iBoss21)
- 💝 **Support Original Author:** [Ko-fi riversafe33](https://ko-fi.com/riversafe33)

---

**© 2026 iBoss21 / The Lux Empire | wolves.land**  
**Original Script © riversafe | All Rights Reserved**
