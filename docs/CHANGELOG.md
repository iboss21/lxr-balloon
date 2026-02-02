# 📋 Changelog

All notable changes to the LXR Balloon System will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.2.0] - 2026-02-02

### 🎉 Major Feature Release

This release adds three major gameplay systems to create a complete and immersive balloon experience.

### ✨ New Features

#### 👥 Passenger Invite System
- **Invite System**: Balloon owners can invite up to 2 passengers (3 total capacity)
- **Owner-Only Controls**: Only the owner can control the balloon; passengers ride along
- **Invite Menu**: Owners can select nearby players to invite
- **Accept/Decline**: Players receive prompts to accept (ENTER) or decline (BACKSPACE) invitations
- **Distance Limit**: Configurable invite distance (default: 10 meters)
- **Timeout**: Invitations expire after 30 seconds
- **Passenger Counter**: Owners can see how many passengers are aboard

#### 💥 Damage & Combat System
- **Arrow Damage**: Balloons take 10-15 arrow hits before becoming damaged
- **Bullet Damage**: Bullets count as 2x damage (faster destruction)
- **Hit Counter**: System tracks hits and calculates damage threshold
- **Crash Mechanics**: Damaged balloons lose altitude and crash to the ground
- **Owner Death**: If owner is killed, balloon automatically crashes
- **Visual Effects**: Crash animations and audio feedback
- **Projectile Detection**: Automatically detects arrows and bullets hitting balloon
- **No Invincibility**: Fixed issue where players in balloons couldn't be killed
  - Players can now be damaged and killed while flying
  - Balloon vehicle no longer blocks projectiles
  - All entity proofs disabled for realism

#### 🔧 Repair System
- **Spawn Point Repairs**: Visit any balloon spawn location to repair damaged balloons
- **Material Requirements**: 
  - Money (configurable amount, default: $50)
  - Wood items (configurable amount, default: 5)
  - Cloth items (configurable amount, default: 3)
- **Damage Status**: Check balloon health in the menu
- **Repair Validation**: System checks for all required materials before repair
- **Database Tracking**: Damage state persisted in database

### 🗄️ Database Changes
- Added `balloon_passengers` table for passenger tracking
- Added `balloon_damage` table for damage state tracking
- Automatic cleanup on balloon deletion

### 🔧 Configuration Changes
- Added `Config.PassengerSystem` section:
  - `enabled` - Enable/disable passenger system
  - `maxPassengers` - Maximum passengers (default: 2)
  - `inviteDistance` - Maximum invite distance (default: 10.0)
  - `inviteTimeout` - Invitation timeout (default: 30)

- Added `Config.DamageSystem` section:
  - `enabled` - Enable/disable damage system
  - `arrowHitsToDestroy` - Minimum arrow hits (default: 10)
  - `arrowHitsToDestroyMax` - Maximum arrow hits (default: 15)
  - `bulletDamageMultiplier` - Bullet damage multiplier (default: 2)
  - `ownerDeathCrash` - Crash on owner death (default: true)
  - `crashDescentSpeed` - Descent speed when crashing (default: 0.5)
  - `repairMoney` - Money required for repair (default: 50)
  - `repairItems` - Items required for repair (wood: 5, cloth: 3)

### 🗣️ Translations
- Added 32 new translation keys across all 7 languages:
  - Passenger system messages (18 keys)
  - Damage system messages (14 keys)
  - English, Spanish, French, Portuguese (BR/PT), German, Italian, Romanian

### 🎮 Server Events Added
- `rs_balloon:trackBalloonOwner` - Register balloon ownership
- `rs_balloon:invitePassenger` - Send invitation to player
- `rs_balloon:acceptInvite` - Accept balloon invitation
- `rs_balloon:declineInvite` - Decline balloon invitation
- `rs_balloon:removePassenger` - Remove passenger from balloon
- `rs_balloon:getBalloonOwner` - Get current balloon owner
- `rs_balloon:balloonDamaged` - Register damage hit
- `rs_balloon:ownerDied` - Handle owner death
- `rs_balloon:repairBalloon` - Repair damaged balloon
- `rs_balloon:checkBalloonDamage` - Check damage status
- `rs_balloon:getBalloonPassengers` - Get passenger list

### 🎮 Client Events Added
- `rs_balloon:receiveInvite` - Show invitation prompt
- `rs_balloon:inviteExpired` - Clear invitation
- `rs_balloon:passengerJoined` - Passenger joined notification
- `rs_balloon:passengerLeft` - Passenger left notification
- `rs_balloon:updatePassengerCount` - Update passenger UI
- `rs_balloon:balloonCrashing` - Trigger crash sequence
- `rs_balloon:damageStatusUpdated` - Update damage display
- `rs_balloon:notOwnerControl` - Show control restriction message

### 🔒 Security Fixes
- **CRITICAL**: Fixed player invincibility in balloons
  - Players can now be shot and killed while in balloons
  - Removed unintended god mode in vehicles
  - Balloon entity no longer blocks damage to players
  - All entity proofs properly disabled

### 📚 Documentation
- **Complete README rewrite** with all new features
- Updated installation instructions
- Added passenger system documentation
- Added damage system documentation
- Added repair system documentation
- Added gameplay tips section
- Added troubleshooting guide

### 🎯 Gameplay Changes
- Balloons are now vulnerable to combat
- Teamwork encouraged through passenger system
- Strategic gameplay with repair requirements
- Risk/reward balance with material costs
- Enhanced realism with damage mechanics

### 🔄 Backward Compatibility
- All new systems can be disabled via config
- Existing balloons work without modifications
- No breaking changes to core functionality
- Optional feature adoption

---

## [2.1.0] - 2026-02-02

### ✨ New Features
- **Fuel Requirement System**: Added optional fuel requirement for balloon rentals
  - Configurable fuel item name (default: `balloon_fuel`)
  - Random fuel consumption between min/max values for realistic gameplay
  - Smart calculation: 1 fuel = 10-15 minutes of flight time
  - Can be enabled/disabled via config
  - Multi-framework inventory support

### 🔧 Configuration Changes
- Added `Config.FuelRequirement` section with the following options:
  - `enabled` - Toggle fuel requirement on/off
  - `itemName` - Set the fuel item name
  - `minMinutesPerFuel` - Minimum flight time per fuel can
  - `maxMinutesPerFuel` - Maximum flight time per fuel can

### 🌍 Framework Support
- Added `Framework.GetItemCount()` - Check player inventory for items
- Added `Framework.RemoveItem()` - Remove items from player inventory
- Full support for:
  - LXRCore inventory system
  - RSG-Core inventory system
  - VORP inventory system
  - RedEM:RP inventory system
  - Standalone mode (fuel always available)

### 🗣️ Translations
- Added fuel-related messages to all 7 supported languages:
  - English, Spanish, French, Portuguese (BR/PT), German, Italian, Romanian
  - New keys: `NeedFuel`, `FuelCans`, `YouHave`

### 📚 Documentation
- Updated CONFIGURATION.md with fuel system documentation
- Added example item configuration
- Added framework compatibility notes

### ⚙️ Default Configuration
- Fuel system is **enabled by default** (can be disabled via `Config.FuelRequirement.enabled = false`)
- All existing functionality remains unchanged when disabled
- No database changes required

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
