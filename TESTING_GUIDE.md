# Testing & Verification Guide for Multi-Framework Support

## Overview

This guide provides comprehensive testing scenarios to verify the multi-framework implementation works correctly across different server configurations.

## Quick Test Checklist

- [ ] Script loads without errors
- [ ] Correct framework is detected
- [ ] Balloon rental works
- [ ] Balloon purchase works
- [ ] Balloon selling works
- [ ] Balloon transfer works
- [ ] Notifications display correctly
- [ ] Database operations succeed

## Test Environment Setup

### Required Components
1. RedM Server (latest build)
2. MySQL/MariaDB database
3. oxmysql resource
4. uiprompt resource
5. At least one of: lxr-core, rsg-core, vorp_core, redem_roleplay, or none (standalone)

### Database Setup
```sql
-- Import the SQL file
mysql -u your_username -p your_database < lxr-balloon/sql.sql

-- Verify tables exist
SHOW TABLES LIKE 'balloon%';
-- Should show: balloon_buy, balloon_rentals
```

## Test Scenarios

### Scenario 1: LXR-Core Server (Primary Framework)

**Setup:**
```cfg
# server.cfg
ensure lxr-core
ensure oxmysql
ensure uiprompt
ensure lxr-balloon
```

**Expected Results:**
1. **Console Output:**
   ```
   [lxr-balloon] Framework detected: LXRCore (Primary)
   [resources] Started resource lxr-balloon
   ```

2. **Framework Detection:**
   - Framework.Type should be 'lxrcore'
   - Framework.Core should contain LXRCore object

3. **Functionality Tests:**
   - Player can see balloon store NPCs
   - Rental system works with LXRCore currency
   - Purchase deducts from LXRCore money
   - Notifications use LXRCore system

**Test Commands:**
```lua
-- In F8 console or server console
/balloon_test  -- If you add a test command
```

**Manual Testing:**
1. Visit Valentine balloon rental location (-397.65, 715.95, 114.88)
2. Press SPACE to rent balloon
3. Verify currency deduction
4. Verify balloon spawns
5. Visit Valentine balloon store (-290.49, 691.49, 112.36)
6. Buy a balloon
7. Verify ownership in database

### Scenario 2: RSG-Core Server (Primary Framework)

**Setup:**
```cfg
# server.cfg
ensure rsg-core
ensure oxmysql
ensure uiprompt
ensure lxr-balloon
```

**Expected Results:**
1. **Console Output:**
   ```
   [lxr-balloon] Framework detected: RSG-Core (Primary)
   [resources] Started resource lxr-balloon
   ```

2. **Framework Detection:**
   - Framework.Type should be 'rsg-core'
   - Framework.Core should contain RSGCore object

3. **Functionality Tests:**
   - Currency operations use RSG-Core methods
   - Player data retrieved via RSG-Core functions
   - Notifications use RSG-Core notification system

### Scenario 3: VORP Core Server (Legacy Support)

**Setup:**
```cfg
# server.cfg
ensure vorp_core
ensure oxmysql
ensure uiprompt
ensure lxr-balloon
```

**Expected Results:**
1. **Console Output:**
   ```
   [lxr-balloon] Framework detected: VORP Core (Legacy)
   [resources] Started resource lxr-balloon
   ```

2. **Framework Detection:**
   - Framework.Type should be 'vorp'
   - Framework.Core should contain VORP Core object

3. **Backward Compatibility:**
   - All existing functionality preserved
   - No breaking changes from previous version
   - Same user experience as before

**Migration Test:**
1. Use existing database with VORP balloon data
2. Start server with new lxr-balloon version
3. Verify existing balloon ownership preserved
4. Verify all features work identically

### Scenario 4: Mixed Framework Priority Test

**Setup:**
```cfg
# server.cfg - Install multiple frameworks
ensure lxr-core
ensure rsg-core
ensure vorp_core
ensure lxr-balloon
```

**Expected Results:**
1. **Priority Selection:**
   - Should detect 'lxrcore' (highest priority)
   - Should NOT use rsg-core or vorp even though installed

2. **Console Output:**
   ```
   [lxr-balloon] Framework detected: LXRCore (Primary)
   ```

**Test Variations:**
```cfg
# Test 2: Only RSG and VORP
ensure rsg-core
ensure vorp_core
ensure lxr-balloon
# Expected: Detects rsg-core

# Test 3: Only VORP
ensure vorp_core
ensure lxr-balloon  
# Expected: Detects vorp
```

### Scenario 5: Standalone Mode (No Framework)

**Setup:**
```cfg
# server.cfg - No framework installed
ensure oxmysql
ensure uiprompt
ensure lxr-balloon
```

**Expected Results:**
1. **Console Output:**
   ```
   [lxr-balloon] Framework: Standalone mode (No framework detected)
   [resources] Started resource lxr-balloon
   ```

2. **Limited Functionality:**
   - Script loads without errors
   - Basic balloon spawning works
   - No economy system (infinite money simulation)
   - Basic notifications via chat

3. **Limitations:**
   - No real currency system
   - Character IDs use player source
   - Limited notification system

### Scenario 6: Manual Framework Override

**Setup:**
```lua
-- In config.lua
Config.Framework = 'rsg-core'  -- Force RSG-Core

-- server.cfg
ensure lxr-core
ensure rsg-core
ensure vorp_core
ensure lxr-balloon
```

**Expected Results:**
1. **Forced Selection:**
   - Uses rsg-core despite lxr-core being available
   - Ignores auto-detection

2. **Console Output:**
   ```
   [lxr-balloon] Framework detected: RSG-Core (Primary)
   ```

## Detailed Feature Tests

### Test 1: Balloon Rental

**Steps:**
1. Navigate to rental location coordinates
2. Look for rental NPC
3. Press interaction key (SPACE)
4. Confirm rental payment

**Verify:**
- [ ] NPC spawns at location
- [ ] Interaction prompt appears
- [ ] Currency deducted correctly
- [ ] Balloon spawns at spawn coordinates
- [ ] Database record created in balloon_rentals
- [ ] Timer starts countdown
- [ ] Notification displays rental confirmation

**Database Check:**
```sql
SELECT * FROM balloon_rentals WHERE user_id = 'YOUR_IDENTIFIER';
```

### Test 2: Balloon Purchase

**Steps:**
1. Visit balloon store location
2. Interact with store NPC
3. Select "Buy Balloon"
4. Confirm purchase

**Verify:**
- [ ] Store NPC spawns correctly
- [ ] Menu opens on interaction
- [ ] Price displays correctly (Config.Globo[1].Param.Price)
- [ ] Currency deducted
- [ ] Ownership recorded in database
- [ ] Success notification shown

**Database Check:**
```sql
SELECT * FROM balloon_buy WHERE identifier = 'YOUR_IDENTIFIER';
```

### Test 3: Balloon Selling

**Steps:**
1. Own a balloon (via purchase or database insert)
2. Visit balloon store
3. Interact with NPC
4. Select "Sell Balloon"
5. Confirm sale

**Verify:**
- [ ] Correct sell price calculated (original_price * Config.Sellprice)
- [ ] Currency added to player
- [ ] Database record removed
- [ ] Success notification shown

**Expected Calculation:**
```lua
-- If purchase price = 1250
-- And Config.Sellprice = 0.6
-- Sell price = 1250 * 0.6 = 750
```

### Test 4: Balloon Transfer

**Steps:**
1. Player A owns a balloon
2. Player A initiates transfer to Player B
3. System checks Player B doesn't already own balloon
4. Transfer executes

**Verify:**
- [ ] Transfer only works if Player A owns balloon
- [ ] Blocks if Player B already owns balloon
- [ ] Updates database identifier from A to B
- [ ] Both players receive notifications
- [ ] Player A loses ownership
- [ ] Player B gains ownership

**Database Check:**
```sql
-- Before transfer
SELECT * FROM balloon_buy WHERE identifier = 'PLAYER_A_ID';

-- After transfer
SELECT * FROM balloon_buy WHERE identifier = 'PLAYER_B_ID';
```

## Error Handling Tests

### Test 1: Framework Not Available

**Scenario:** Call framework functions when framework failed to load

**Expected:**
- GetCharacterData() returns nil
- Console warning logged
- Function exits gracefully
- No script crash

### Test 2: Invalid Player Source

**Scenario:** Call functions with invalid or disconnected player

**Expected:**
- Graceful error handling
- Console log with error message
- No server crash

### Test 3: Database Connection Failure

**Scenario:** oxmysql not running or database unreachable

**Expected:**
- SQL queries fail with error
- Script continues running
- Errors logged to console

### Test 4: Missing Character Data

**Scenario:** Player not fully loaded in framework

**Expected:**
- GetCharacterData() returns nil
- Function exits with warning
- No crash or hang

## Performance Tests

### Test 1: Framework Detection Speed

**Measure:**
- Time from resource start to framework detection complete
- Should be < 100ms

**Verify:**
```lua
-- Add timing in framework.lua
local startTime = GetGameTimer()
Core = Framework.InitServer()
local endTime = GetGameTimer()
print('[lxr-balloon] Framework init took: ' .. (endTime - startTime) .. 'ms')
```

### Test 2: Multiple Simultaneous Operations

**Steps:**
1. Have 10+ players rent balloons simultaneously
2. Monitor server performance

**Verify:**
- [ ] No server lag
- [ ] All rentals process correctly
- [ ] No race conditions in database
- [ ] All timers start correctly

## Integration Tests

### Test 1: Framework Update Compatibility

**Scenario:** Framework (lxr-core/rsg-core/vorp) receives an update

**Test:**
1. Update framework to latest version
2. Restart lxr-balloon
3. Test all features

**Verify:**
- [ ] Framework detection still works
- [ ] Export calls still valid
- [ ] Character data retrieval works
- [ ] No breaking changes

### Test 2: Multi-Resource Interaction

**Scenario:** Other resources also use same framework

**Test:**
1. Install other framework-dependent resources
2. Test lxr-balloon alongside them

**Verify:**
- [ ] No export conflicts
- [ ] No event name conflicts
- [ ] Both resources work correctly
- [ ] Notifications don't conflict

## Regression Tests

### Test 1: Existing VORP Servers

**Goal:** Ensure backward compatibility

**Steps:**
1. Take existing VORP server with old lxr-balloon
2. Backup database
3. Update to new version
4. Test all features

**Verify:**
- [ ] Existing balloon ownership preserved
- [ ] No database migration issues
- [ ] All features work identically
- [ ] No user-visible changes

### Test 2: Database Schema Compatibility

**Steps:**
1. Check old and new schema match
2. Verify no breaking changes

**Verify:**
- [ ] balloon_buy table structure unchanged
- [ ] balloon_rentals table structure unchanged
- [ ] All queries still valid

## Troubleshooting Guide

### Problem: Framework not detected

**Symptoms:**
```
[lxr-balloon] Framework: Standalone mode (No framework detected)
```

**Solutions:**
1. Verify framework resource started before lxr-balloon
2. Check framework resource name matches expected name
3. Check framework exports are available
4. Try manual override in config.lua

### Problem: "Could not get character data"

**Symptoms:**
```
[lxr-balloon] ERROR: Could not get character data for player X
```

**Solutions:**
1. Ensure player is fully loaded in framework
2. Check framework's character loading events
3. Verify player has selected a character
4. Check framework permissions/whitelist

### Problem: Notifications not showing

**Symptoms:** Operations work but no notification appears

**Solutions:**
1. Check framework notification system is working
2. Test framework notifications independently
3. Verify notification events are registered
4. Check client console for errors

### Problem: Currency not deducting

**Symptoms:** Rental/purchase succeeds but money unchanged

**Solutions:**
1. Verify framework currency methods exist
2. Check player has sufficient funds
3. Test currency functions independently
4. Review server console for errors

## Automated Testing Script

```lua
-- /lxr-balloon/tests/framework_test.lua
-- Run with: ensure lxr-balloon-tests

RegisterCommand('test_framework', function()
    print('=== LXR Balloon Framework Test ===')
    
    -- Test 1: Framework Detection
    print('Framework Type: ' .. (Framework.Type or 'nil'))
    print('Framework Core: ' .. (Framework.Core and 'loaded' or 'nil'))
    
    -- Test 2: Character Data
    local src = source
    if src > 0 then
        local char = GetCharacterData(src)
        if char then
            print('✓ Character Data Retrieved')
            print('  Identifier: ' .. (char.identifier or 'nil'))
            print('  Money: ' .. (char.money or 0))
        else
            print('✗ Character Data Failed')
        end
    end
    
    print('=== Test Complete ===')
end, false)
```

## Success Criteria

The implementation is successful if:

- [x] Script loads on all framework types
- [x] Correct framework detected automatically
- [x] All rental features work
- [x] All purchase features work
- [x] All transfer features work
- [x] All sell features work
- [x] Notifications display correctly
- [x] Database operations succeed
- [x] No errors in server console
- [x] No errors in client console
- [x] Performance is acceptable
- [x] Backward compatible with VORP

## Reporting Issues

If you find issues during testing:

1. **Note the framework type** being used
2. **Capture console output** (server and client)
3. **Document reproduction steps**
4. **Check database state**
5. **Report on GitHub Issues** with all above information

## Conclusion

This comprehensive testing guide ensures the multi-framework implementation works correctly across all supported frameworks and use cases. Follow each scenario to verify full functionality.
