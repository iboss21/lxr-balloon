# Multi-Framework Support Implementation

## Summary of Changes

This update transforms the lxr-balloon script from a vorp_core-only resource to a multi-framework compatible system that supports multiple frameworks with proper priority ordering.

## Framework Priority

The script now supports frameworks in this priority order:

1. **LXRCore** (Primary) - The Land of Wolves custom framework
2. **RSG-Core** (Primary) - Rexshack Gaming framework
3. **VORP Core** (Legacy) - Optional support maintained
4. **RedEM:RP** (Legacy) - Optional support maintained
5. **Standalone** - Works without any framework

## Key Changes

### 1. Created `framework.lua` (New File)
- Centralized framework detection and initialization
- Auto-detects which framework is running
- Provides unified interface for framework operations
- Handles character data retrieval across all frameworks
- Manages notifications with framework-specific implementations

### 2. Updated `fxmanifest.lua`
- Removed hardcoded `vorp_core` dependency
- Made all framework dependencies optional
- Added `framework.lua` to shared_scripts
- Resource will start regardless of which framework is present

### 3. Refactored `server/server.lua`
- Removed hardcoded `local VORPcore = exports.vorp_core:GetCore()`
- Implemented dynamic framework initialization
- Created `GetCharacterData()` helper function that works with all frameworks
- Replaced all `VORPcore` calls with `Framework` API calls
- Added error handling for missing character data

### 4. Updated `client/client.lua`
- Removed hardcoded vorp_core export call
- Implemented dynamic framework initialization on client side
- Framework detection happens automatically at runtime

## Framework-Specific Implementations

### LXRCore & RSG-Core
```lua
-- Character data structure
Character.identifier = PlayerData.citizenid
Character.money = PlayerData.money.cash
Character.removeCurrency = User.Functions.RemoveMoney
Character.addCurrency = User.Functions.AddMoney
```

### VORP Core
```lua
-- Character data structure (maintained for compatibility)
Character.identifier = UsedCharacter.identifier
Character.money = UsedCharacter.money
Character.removeCurrency = UsedCharacter.removeCurrency
Character.addCurrency = UsedCharacter.addCurrency
```

### RedEM:RP
```lua
-- Character data structure
Character.identifier = User.getIdentifier()
Character.money = User.getMoney()
Character.removeCurrency = User.removeMoney
Character.addCurrency = User.addMoney
```

### Standalone Mode
```lua
-- No framework - basic functionality only
Character.identifier = tostring(source)
Character.money = 999999 -- No economy
```

## Benefits

1. **No More Hard Dependency**: Script works even if vorp_core is not installed
2. **Primary Framework Support**: lxr-core and rsg-core are now first-class citizens
3. **Backward Compatible**: Existing vorp_core servers continue to work
4. **Flexible**: Servers can choose their preferred framework
5. **Extensible**: Easy to add support for new frameworks in the future

## Testing Scenarios

### Scenario 1: LXR-Core Server
- **Setup**: lxr-core installed and started
- **Expected**: Framework detects lxrcore, uses LXRCore API
- **Console Output**: `[lxr-balloon] Framework detected: LXRCore (Primary)`

### Scenario 2: RSG-Core Server
- **Setup**: rsg-core installed and started
- **Expected**: Framework detects rsg-core, uses RSG API
- **Console Output**: `[lxr-balloon] Framework detected: RSG-Core (Primary)`

### Scenario 3: VORP Core Server (Legacy)
- **Setup**: vorp_core installed and started
- **Expected**: Framework detects vorp, uses VORP API
- **Console Output**: `[lxr-balloon] Framework detected: VORP Core (Legacy)`

### Scenario 4: Mixed Frameworks
- **Setup**: Multiple frameworks installed
- **Expected**: Uses highest priority framework (lxr-core > rsg-core > vorp)
- **Console Output**: Shows detected primary framework

### Scenario 5: No Framework
- **Setup**: No framework installed
- **Expected**: Runs in standalone mode with basic functionality
- **Console Output**: `[lxr-balloon] Framework: Standalone mode (No framework detected)`

## Migration Guide

### For Existing VORP Servers
No changes required! The script maintains full backward compatibility:
- VORP Core detection works automatically
- All existing functionality preserved
- No configuration changes needed

### For New LXR-Core/RSG-Core Servers
Simply install lxr-balloon:
1. Ensure your framework (lxr-core or rsg-core) is started
2. Install lxr-balloon resource
3. Script automatically detects and uses your framework
4. No additional configuration needed

### For Mixed/Test Environments
Set manual override in `config.lua` if needed:
```lua
Config.Framework = 'lxrcore'  -- Force specific framework
-- Options: 'lxrcore', 'rsg-core', 'vorp', 'redemrp', 'standalone'
```

## Error Handling

The implementation includes comprehensive error handling:
- Graceful fallback if framework exports fail
- Console warnings for missing character data
- Prevents script crashes from framework issues
- Detailed error messages for debugging

## Performance Impact

- **Minimal**: Framework detection happens once at startup
- **Efficient**: Cached framework reference used for all operations
- **No polling**: Uses direct export calls, no resource state checking during runtime

## Future Enhancements

The framework abstraction layer makes it easy to:
- Add new framework support
- Implement framework-specific optimizations
- Extend functionality per framework
- Maintain separate feature sets

## Verification Checklist

- [x] Removed hardcoded vorp_core dependency
- [x] Implemented auto-detection for all frameworks
- [x] Added lxr-core as primary framework
- [x] Added rsg-core as primary framework
- [x] Maintained vorp_core legacy support
- [x] Added redemrp legacy support
- [x] Implemented standalone mode
- [x] Refactored server-side character data handling
- [x] Updated client-side initialization
- [x] Made dependencies optional
- [x] Added comprehensive error handling
- [x] Maintained backward compatibility

## Console Output Examples

### Successful Load with LXRCore
```
[    c-scripting-core] Creating script environments for lxr-core
[           resources] Started resource lxr-core
[    c-scripting-core] Creating script environments for lxr-balloon
[         lxr-balloon] Framework detected: LXRCore (Primary)
[           resources] Started resource lxr-balloon
```

### Successful Load with VORP (Legacy)
```
[    c-scripting-core] Creating script environments for vorp_core
[           resources] Started resource vorp_core
[    c-scripting-core] Creating script environments for lxr-balloon
[         lxr-balloon] Framework detected: VORP Core (Legacy)
[           resources] Started resource lxr-balloon
```

### Standalone Mode
```
[    c-scripting-core] Creating script environments for lxr-balloon
[         lxr-balloon] Framework: Standalone mode (No framework detected)
[           resources] Started resource lxr-balloon
```

## Conclusion

The lxr-balloon script now offers true multi-framework compatibility while maintaining its original functionality. Servers using lxr-core and rsg-core are treated as first-class platforms, while vorp_core users maintain full backward compatibility.
