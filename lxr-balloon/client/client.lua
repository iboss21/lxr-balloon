-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 LXR Balloon System - Client Script
-- ═══════════════════════════════════════════════════════════════════════════════
-- Multi-framework support: lxr-core (primary), rsg-core (primary), vorp (legacy), standalone
-- ═══════════════════════════════════════════════════════════════════════════════

local Core = nil
local T = Translation.Langs[Config.Lang]

-- Initialize framework on client start
Citizen.CreateThread(function()
    Core = Framework.InitClient()
end)
local NPCss = {}
local balloon
local lockZ = false
local useCameraRelativeControls = true
local spawn_balloon = nil
local current_balloon_id = nil

-- ═══════════════════════════════════════════════════════════════════════════════
-- Passenger System Variables
-- ═══════════════════════════════════════════════════════════════════════════════
local balloonOwnerSource = nil
local passengerCount = 0
local pendingInvite = nil
local invitePromptGroup = nil
local acceptInvitePrompt = nil
local declineInvitePrompt = nil
local currentBalloonNetId = nil

-- ═══════════════════════════════════════════════════════════════════════════════
-- Damage System Variables
-- ═══════════════════════════════════════════════════════════════════════════════
local isBalloonCrashing = false
local balloonDamaged = false
local lastPlayerHealth = nil

-- Resolve keybinds with backward-compatible fallback
local Keys = Config.Keybinds or {}
local KEY_FORWARD      = Keys.moveForward   or `INPUT_VEH_MOVE_UP_ONLY`
local KEY_BACKWARD     = Keys.moveBackward  or `INPUT_VEH_MOVE_DOWN_ONLY`
local KEY_LEFT         = Keys.moveLeft      or `INPUT_VEH_MOVE_LEFT_ONLY`
local KEY_RIGHT        = Keys.moveRight     or `INPUT_VEH_MOVE_RIGHT_ONLY`
local KEY_ASCEND       = Keys.ascend        or `INPUT_VEH_FLY_THROTTLE_UP`
local KEY_BRAKE        = Keys.brake         or `INPUT_CONTEXT_X`
local KEY_LOCK_ALT     = Keys.lockAltitude  or `INPUT_CONTEXT_A`
local KEY_STORE        = Keys.storeBalloon  or `INPUT_VEH_HORN`
local KEY_ACCEPT_INV   = Keys.acceptInvite  or `INPUT_FRONTEND_ACCEPT`
local KEY_DECLINE_INV  = Keys.declineInvite or `INPUT_FRONTEND_CANCEL`

local balloonPrompts = UipromptGroup:new(T.Prompts.Ballon)
local nsPrompt = Uiprompt:new({KEY_FORWARD, KEY_BACKWARD}, T.Prompts.NorthSouth, balloonPrompts)
local wePrompt = Uiprompt:new({KEY_LEFT, KEY_RIGHT}, T.Prompts.WestEast, balloonPrompts)
local brakePrompt = Uiprompt:new(KEY_BRAKE, T.Prompts.DownBalloon, balloonPrompts)
local lockZPrompt = Uiprompt:new(KEY_LOCK_ALT, T.Prompts.LockInAltitude, balloonPrompts)
local throttlePrompt = Uiprompt:new(KEY_ASCEND, T.Prompts.UpBalloon, balloonPrompts)
local deleteBalloonPrompt = Uiprompt:new(KEY_STORE, T.Prompts.RemoveBalloon, balloonPrompts)

-- Invite System Prompts
local function CreateInvitePrompts()
    invitePromptGroup = UipromptGroup:new("Balloon Invite")
    acceptInvitePrompt = Uiprompt:new(KEY_ACCEPT_INV, "Accept Invite (ENTER)", invitePromptGroup)
    declineInvitePrompt = Uiprompt:new(KEY_DECLINE_INV, "Decline Invite (BACKSPACE)", invitePromptGroup)
end

CreateInvitePrompts()

Citizen.CreateThread(function()
    while true do
        if balloon and deleteBalloonPrompt then
            local isRental = (balloon == spawn_balloon)
            deleteBalloonPrompt:setEnabledAndVisible(not isRental)
        end
        Citizen.Wait(100)
    end
end)

Citizen.CreateThread(function()
    while true do
        if balloon == spawn_balloon then
            DisableControlAction(0, KEY_STORE, true)
        end
        Citizen.Wait(0)
    end
end)

local function GetCameraRelativeVectors()
    local camRot = GetGameplayCamRot(2)
    local camHeading = math.rad(camRot.z)
    local forwardVector = vector3(-math.sin(camHeading), math.cos(camHeading), 0.0)
    local rightVector = vector3(math.cos(camHeading), math.sin(camHeading), 0.0)
    return forwardVector, rightVector
end

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local vehiclePedIsIn = GetVehiclePedIsIn(playerPed, false)

        if vehiclePedIsIn ~= 0 and GetEntityModel(vehiclePedIsIn) == `hotairballoon01` then
            if not balloon then
                balloon = vehiclePedIsIn
            end
        else
            if balloon then
                balloon = nil
            end
        end

        Citizen.Wait(500)
    end
end)

-- Ensure players in balloons can be damaged (no invincibility)
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local vehiclePedIsIn = GetVehiclePedIsIn(playerPed, false)
        
        if vehiclePedIsIn ~= 0 and GetEntityModel(vehiclePedIsIn) == `hotairballoon01` then
            -- Make sure player can be damaged
            SetEntityCanBeDamaged(playerPed, true)
            SetEntityInvincible(playerPed, false)
            SetPlayerInvincible(PlayerId(), false)
            
            -- Make sure balloon vehicle doesn't block damage to player
            SetEntityCanBeDamaged(vehiclePedIsIn, true)
            SetEntityProofs(vehiclePedIsIn, false, false, false, false, false, false, false, false)
        end
        
        Citizen.Wait(500)
    end
end)

Citizen.CreateThread(function()
    local bv
    while true do
        if balloon then
            local isOwner = (balloonOwnerSource == GetPlayerServerId(PlayerId()))
            
            if isOwner then
                balloonPrompts:handleEvents()
            end

            -- Check if player tries to control as non-owner
            if not isOwner then
                local tryingControl = IsControlPressed(0, KEY_FORWARD) or 
                                    IsControlPressed(0, KEY_BACKWARD) or
                                    IsControlPressed(0, KEY_LEFT) or
                                    IsControlPressed(0, KEY_RIGHT) or
                                    IsControlPressed(0, KEY_BRAKE) or
                                    IsControlPressed(0, KEY_LOCK_ALT) or
                                    IsControlPressed(0, KEY_ASCEND)
                
                if tryingControl then
                    Framework.ClientNotify("Balloon", "Only the owner can control this balloon", "menu_textures", "cross", 2000, "COLOR_RED")
                    Citizen.Wait(2000)
                end
                Citizen.Wait(100)
            else
                -- Owner controls - existing control logic
                local speed = IsControlPressed(0, `INPUT_VEH_TRAVERSAL`) and 0.15 or 0.05
                local v1 = GetEntityVelocity(balloon)
                local v2 = v1

                -- Apply crash effect if balloon is crashing
                if isBalloonCrashing then
                    local crashSpeed = Config.DamageSystem.crashDescentSpeed or 0.5
                    v2 = vector3(v2.x * 0.9, v2.y * 0.9, -crashSpeed)
                    SetEntityVelocity(balloon, v2)
                    Citizen.Wait(0)
                else
                    if useCameraRelativeControls then
                        local forwardVec, rightVec = GetCameraRelativeVectors()
                        if IsControlPressed(0, KEY_FORWARD) then
                            v2 = v2 + forwardVec * speed
                        end
                        if IsControlPressed(0, KEY_BACKWARD) then
                            v2 = v2 - forwardVec * speed
                        end
                        if IsControlPressed(0, KEY_LEFT) then
                            v2 = v2 - rightVec * speed
                        end
                        if IsControlPressed(0, KEY_RIGHT) then
                            v2 = v2 + rightVec * speed
                        end
                    else
                        if IsControlPressed(0, KEY_FORWARD) then
                            v2 = v2 + vector3(0, speed, 0)
                        end
                        if IsControlPressed(0, KEY_BACKWARD) then
                            v2 = v2 - vector3(0, speed, 0)
                        end
                        if IsControlPressed(0, KEY_LEFT) then
                            v2 = v2 - vector3(speed, 0, 0)
                        end
                        if IsControlPressed(0, KEY_RIGHT) then
                            v2 = v2 + vector3(speed, 0, 0)
                        end
                    end

                    if IsControlPressed(0, KEY_BRAKE) then
                        if bv then
                            local x = bv.x > 0 and bv.x - speed or bv.x + speed
                            local y = bv.y > 0 and bv.y - speed or bv.y + speed
                            v2 = vector3(x, y, v2.z)
                        end
                        bv = v2.xy
                    else
                        bv = nil
                    end

                    if IsControlJustPressed(0, KEY_LOCK_ALT) then
                        lockZ = not lockZ
                        if lockZ then
                            lockZPrompt:setText(T.Prompts.UnlockInAltitude)
                        else
                            lockZPrompt:setText(T.Prompts.LockInAltitude)
                        end
                    end

                    if lockZ and not IsControlPressed(0, KEY_ASCEND) then
                        SetEntityVelocity(balloon, vector3(v2.x, v2.y, 0.0))
                    elseif v2 ~= v1 then
                        SetEntityVelocity(balloon, v2)
                    end

                    if IsControlJustPressed(0, KEY_STORE) then
                        if DoesEntityExist(balloon) then
                            local balloonHeight = GetEntityHeightAboveGround(balloon)
                            if balloonHeight <= 0.5 then
                                DeleteEntity(balloon)
                                balloon = nil
                                balloonOwnerSource = nil
                            end
                        end
                    end
                end

                Citizen.Wait(0)
            end
        else
            Citizen.Wait(500)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local balloonHeight = GetEntityHeightAboveGround(balloon)

        if balloonHeight > 0.5 then
            DisableControlAction(0, `INPUT_VEH_EXIT`, true)
        end
    end
end)

local BalloonGroup = GetRandomIntInRange(0, 0xffffff)
local OwnedBallons = {}
local near = 1000
local stand = { x = 0, y = 0, z = 0 }
local T = Translation.Langs[Config.Lang]
local _BalloonPrompt

-- ═══════════════════════════════════════════════════════════════════════════════
-- Dedicated Dealer Prompt (Config.DealerLocation)
-- ═══════════════════════════════════════════════════════════════════════════════

local DealerGroup = GetRandomIntInRange(0, 0xffffff)
local _DealerPrompt

local function SetupDealerPrompt()
    Citizen.CreateThread(function()
        local str = T.DealerPrompt or "Balloon Dealer (Purchase Only)"
        _DealerPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(_DealerPrompt, (Config.Keybinds and Config.Keybinds.shopInteract) or 0x760A9C6F)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(_DealerPrompt, str)
        PromptSetEnabled(_DealerPrompt, true)
        PromptSetVisible(_DealerPrompt, true)
        PromptSetStandardMode(_DealerPrompt, true)
        PromptSetGroup(_DealerPrompt, DealerGroup)
        PromptRegisterEnd(_DealerPrompt)
        PromptSetPriority(_DealerPrompt, true)
    end)
end

-- Dealer zone detection & interaction
Citizen.CreateThread(function()
    if not Config.DealerLocation or #Config.DealerLocation == 0 then return end

    SetupDealerPrompt()

    -- Create blips and NPCs for each dealer location
    for _, dealer in ipairs(Config.DealerLocation) do
        local blip = N_0x554d9d53f696d002(1664425300, dealer.coords.x, dealer.coords.y, dealer.coords.z)
        SetBlipSprite(blip, dealer.sprite, 1)
        SetBlipScale(blip, 0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, dealer.name)

        if dealer.npcCoords then
            TriggerEvent("rs_balloon:CreateNPC", dealer.npcCoords)
        end
    end

    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local inDealerZone = false

        for _, dealer in ipairs(Config.DealerLocation) do
            local dist = GetDistanceBetweenCoords(dealer.coords.x, dealer.coords.y, dealer.coords.z, playerCoords, false)
            if dist < 2.0 then
                inDealerZone = true

                local groupLabel = CreateVarString(10, 'LITERAL_STRING', T.DealerShop or "Balloon Dealer")
                PromptSetActiveGroupThisFrame(DealerGroup, groupLabel)
                PromptSetEnabled(_DealerPrompt, true)
                PromptSetVisible(_DealerPrompt, true)

                if PromptHasStandardModeCompleted(_DealerPrompt) then
                    PromptSetEnabled(_DealerPrompt, false)
                    PromptSetVisible(_DealerPrompt, false)
                    TriggerServerEvent('rs_balloon:checkOwnedDealer')
                    Citizen.Wait(500)
                end
                break
            end
        end

        if not inDealerZone then
            PromptSetEnabled(_DealerPrompt, false)
            PromptSetVisible(_DealerPrompt, false)
        end

        Citizen.Wait(inDealerZone and 5 or 500)
    end
end)

-- Dealer menu event – purchase only
RegisterNetEvent('rs_balloon:openDealerMenu')
AddEventHandler('rs_balloon:openDealerMenu', function(hasBalloon)
    MenuData.CloseAll()
    local elements = {}

    if not hasBalloon then
        table.insert(elements, { label = T.Buyballon, value = 'buy', desc = T.Desc1 })
    else
        table.insert(elements, { label = T.Property, value = 'info', desc = T.DealerAlreadyOwned or "You already own a hot air balloon" })
    end

    MenuData.Open('default', GetCurrentResourceName(), 'vorp_menu',
    {
        title    = T.DealerShop or "Balloon Dealer",
        subtext  = T.DealerBuyOnly or "Purchase only",
        align    = 'top-right',
        elements = elements,
    },
    function(data, menu)
        if data.current.value == "buy" then
            OpenBuyBallonsMenu()
        end
        menu.close()
    end,
    function(data, menu)
        menu.close()
    end)
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- Maximum Altitude Enforcement (Config.MaxAltitude)
-- ═══════════════════════════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    if not Config.MaxAltitude or Config.MaxAltitude <= 0 then return end

    local lastNotifyTime = 0

    while true do
        if balloon and DoesEntityExist(balloon) then
            local pos = GetEntityCoords(balloon)
            if pos.z >= Config.MaxAltitude then
                local vel = GetEntityVelocity(balloon)
                if vel.z > 0 then
                    SetEntityVelocity(balloon, vel.x, vel.y, -0.1)
                end
                -- Notify at most once every 3 seconds
                local now = GetGameTimer()
                if (now - lastNotifyTime) >= 3000 then
                    Framework.ClientNotify(T.Tittle, T.AltitudeLimit or "Maximum altitude reached!", "menu_textures", "cross", 3000, "COLOR_ORANGE")
                    lastNotifyTime = now
                end
            end
            Citizen.Wait(250)
        else
            Citizen.Wait(1000)
        end
    end
end)

function BalloonPrompt()
    Citizen.CreateThread(function()
        local str = T.Shop
        _BalloonPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(_BalloonPrompt, (Config.Keybinds and Config.Keybinds.shopInteract) or 0x760A9C6F)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(_BalloonPrompt, str)
        PromptSetEnabled(_BalloonPrompt, true)
        PromptSetVisible(_BalloonPrompt, true)
        PromptSetStandardMode(_BalloonPrompt, true)
        PromptSetGroup(_BalloonPrompt, BalloonGroup)
        PromptRegisterEnd(_BalloonPrompt)
        PromptSetPriority(_BalloonPrompt , true)
    end)
end

TriggerEvent("vorp_menu:getData",function(call)
    MenuData = call
end)

local balloons = Config.Globo

Citizen.CreateThread(function()
	BalloonPrompt()

	while true do
		local playerCoords = GetEntityCoords(PlayerPedId())
		local inZone = false

		for i, zone in pairs(Config.Marker) do
			local dist = GetDistanceBetweenCoords(zone.x, zone.y, zone.z, playerCoords, false)
			if dist < 2 then
				inZone = true
				stand = zone
				near = 5

				local BalloonGroupName  = CreateVarString(10, 'LITERAL_STRING', T.Shop7)
				PromptSetActiveGroupThisFrame(BalloonGroup, BalloonGroupName)
				PromptSetEnabled(_BalloonPrompt, true)
				PromptSetVisible(_BalloonPrompt, true)

				if PromptHasStandardModeCompleted(_BalloonPrompt) then
					PromptSetEnabled(_BalloonPrompt, false)
					PromptSetVisible(_BalloonPrompt, false)
					TriggerServerEvent('rs_balloon:checkOwned')
					Citizen.Wait(500)
				end
			end
		end

		if not inZone and stand then
			MenuData.Close('default', GetCurrentResourceName(), 'vorp_menu')
			PromptSetEnabled(_BalloonPrompt, false)
			PromptSetVisible(_BalloonPrompt, false)
			stand = nil
			near = 1000
		end

		Citizen.Wait(near)
	end
end)

local datosVenta = {
    Model = "hotairballoon01"
}

RegisterNetEvent('rs_balloon:openMenu')
AddEventHandler('rs_balloon:openMenu', function(hasBalloon, damageStatus)
    MenuData.CloseAll()

    local elements = {}
    local playerPed = PlayerPedId()
    local vehiclePedIsIn = GetVehiclePedIsIn(playerPed, false)
    local isInBalloon = vehiclePedIsIn ~= 0 and GetEntityModel(vehiclePedIsIn) == `hotairballoon01`
    local isOwner = balloonOwnerSource == GetPlayerServerId(PlayerId())

    if not hasBalloon then
        table.insert(elements, { label = T.Buyballon, value = 'buy', desc = T.Desc1 })
    else
        table.insert(elements, { label = T.Property, value = 'own', desc = T.Property1 })
        table.insert(elements, { label = T.SellBalloon, value = 'sell', desc = T.Sell })
        table.insert(elements, { label = T.TransferBalloon, value = 'transfer', desc = T.TransferDesc })
        
        -- Add repair option if balloon is damaged
        if damageStatus and damageStatus.isDamaged then
            local repairCost = damageStatus.repairCost or 50
            table.insert(elements, { 
                label = "Repair Balloon", 
                value = 'repair', 
                desc = 'Repair your damaged balloon ($' .. repairCost .. ')'
            })
        end
        
        -- Add invite option if owner is in balloon
        if isInBalloon and isOwner then
            table.insert(elements, { 
                label = "Invite Passenger", 
                value = 'invite', 
                desc = 'Invite a nearby player to your balloon'
            })
        end
    end

    MenuData.Open('default', GetCurrentResourceName(), 'vorp_menu',
    {
        title    = T.Shop1,
        subtext  = T.Shop2 .. (isOwner and passengerCount > 0 and " | Passengers: " .. passengerCount or ""),
        align    = 'top-right',
        elements = elements,
    },
    function(data, menu)
        if data.current.value == "buy" then
            OpenBuyBallonsMenu()

        elseif data.current.value == "own" then
            TriggerServerEvent('rs_balloon:loadownedBallons')
            menu.close()

        elseif data.current.value == "sell" then
            TriggerServerEvent('rs_balloon:sellballoon', datosVenta)
            menu.close()

        elseif data.current.value == "repair" then
            if currentBalloonNetId then
                TriggerServerEvent('rs_balloon:repairBalloon', currentBalloonNetId)
            end
            menu.close()

        elseif data.current.value == "invite" then
            menu.close()
            if currentBalloonNetId then
                OpenInviteMenu()
            end

        elseif data.current.value == "transfer" then
            if not hasBalloon then
                Framework.ClientNotify(T.Tittle, T.Youdonthave, "menu_textures", "cross", 4000, "COLOR_RED")
                return
            end

            local myInput = {
                type = "enableinput",
                inputType = "input",
                button = "Confirm",
                placeholder = "PLAYER ID",
                style = "block",
                attributes = {
                    inputHeader = "TRANSFER BALLOON",
                    type = "text",
                    pattern = "[0-9]+",
                    title = "Only numbers allowed",
                    style = "border-radius: 10px; background-color: ; border:none;"
                }
            }

            local result = exports.vorp_inputs:advancedInput(myInput)
            if result and result ~= "" then
                local playerId = tonumber(result)
                if playerId then
                    TriggerServerEvent('rs_balloon:transferBalloon', playerId)
                    menu.close()
                else
                    Framework.ClientNotify(T.Tittle, T.Invalid, "menu_textures", "cross", 4000, "COLOR_RED")
                end
            end
        end
    end,
    function(data, menu)
        menu.close()
    end)
end)

function OpenInviteMenu()
    local nearbyPlayers = {}
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local inviteDistance = Config.PassengerSystem and Config.PassengerSystem.inviteDistance or 10.0
    
    for _, player in ipairs(GetActivePlayers()) do
        if player ~= PlayerId() then
            local targetPed = GetPlayerPed(player)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            
            if distance < inviteDistance then
                local serverId = GetPlayerServerId(player)
                local playerName = GetPlayerName(player)
                table.insert(nearbyPlayers, {
                    label = playerName .. " (ID: " .. serverId .. ")",
                    value = serverId,
                    desc = "Distance: " .. math.floor(distance) .. "m"
                })
            end
        end
    end
    
    if #nearbyPlayers == 0 then
        Framework.ClientNotify("Balloon", "No nearby players to invite", "menu_textures", "cross", 3000, "COLOR_RED")
        return
    end
    
    MenuData.Open('default', GetCurrentResourceName(), 'invite_menu',
    {
        title    = "Invite Player",
        subtext  = "Select a player to invite",
        align    = 'top-right',
        elements = nearbyPlayers,
    },
    function(data, menu)
        if data.current.value and currentBalloonNetId then
            local targetServerId = tonumber(data.current.value)
            if targetServerId then
                TriggerServerEvent('rs_balloon:invitePassenger', currentBalloonNetId, targetServerId)
            end
            menu.close()
        end
    end,
    function(data, menu)
        menu.close()
    end)
end

function OpenOwnBallonMenu()
    MenuData.CloseAll()
    local elements = {}

    local playerCoords = GetEntityCoords(PlayerPedId())

    for k, boot in pairs(OwnedBallons) do
        local closestLocation = nil

        for locName, locData in pairs(Config.Marker) do
            if #(playerCoords - vector3(locData.x, locData.y, locData.z)) < 2.0 then
                closestLocation = locName
                break
            end
        end

        elements[#elements + 1] = {
            label = boot['name'],
            value = k,
            desc  = boot['name'],
            info  = closestLocation
        }
    end

    MenuData.Open('default', GetCurrentResourceName(), 'vorp_menu',
    {
        title    = T.Shop3,
        subtext  = T.Shop4,
        align    = 'top-right',
        elements = elements,
    },
    function(data, menu)
        if data.current.value then
            if spawn_ballon and DoesEntityExist(spawn_ballon) then
                menu.close()
                return
            end

            local locationName = data.current.info
            TriggerEvent('rs_balloon:spawnBalloon', locationName)
            menu.close()
        end
    end,
    function(data, menu)
        menu.close()
    end)
end

function OpenBuyBallonsMenu()
    MenuData.CloseAll()
	local elements = {}
	for k, boot in pairs(balloons) do
		elements[#elements + 1] = {
			label = balloons[k]['Text'],
            value = k,
			desc = '<span style=color:MediumSeaGreen;>'..balloons[k]['Param']['Price']..'$</span>',
			info = balloons[k]['Param']
		}
	end
    MenuData.Open('default', GetCurrentResourceName(), 'vorp_menu',
	{
		title    = T.Shop5,
		subtext  = T.Shop6,
		align    = 'top-right',
		elements = elements,
	},
	function(data, menu)
		if data.current.value then
			local balloonbuy = data.current.info
			TriggerServerEvent('rs_balloon:buyballoon', balloonbuy)
			menu.close()
		end
	end,
	function(data, menu)
		menu.close()
	end)
end

RegisterNetEvent("rs_balloon:loadBallonMenu")
AddEventHandler("rs_balloon:loadBallonMenu", function(result)
	OwnedBallons = result
	OpenOwnBallonMenu()
end)

Citizen.CreateThread(function()
    for _,marker in pairs(Config.Marker) do
        local blip = N_0x554d9d53f696d002(1664425300, marker.x, marker.y, marker.z)
        SetBlipSprite(blip, marker.sprite, 1)
        SetBlipScale(blip, 0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, marker.name)
    end  
end)

Citizen.CreateThread(function()
    for _, coords in pairs(Config.NPC.coords) do
        TriggerEvent("rs_balloon:CreateNPC", coords)
    end
end)

RegisterNetEvent("rs_balloon:CreateNPC")
AddEventHandler("rs_balloon:CreateNPC", function(zone)
    if not zone then return end

    local model = GetHashKey(Config.NPC.model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(500) end

    local npc = CreatePed(model, zone.x, zone.y, zone.z, zone.w, false, true)
    Citizen.InvokeNative(0x283978A15512B2FE , npc, true)
    SetEntityNoCollisionEntity(PlayerPedId(), npc, true)
    SetEntityCanBeDamaged(npc, false)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetModelAsNoLongerNeeded(model)

    table.insert(NPCss, npc)
end)

RegisterNetEvent('rs_balloon:spawnBalloon1')
AddEventHandler('rs_balloon:spawnBalloon1', function(balloonId, locationIndex)
    if not Config.BalloonLocations[locationIndex] then
        return
    end

    local balloonModel = GetHashKey('hotAirBalloon01')

    RequestModel(balloonModel)
    while not HasModelLoaded(balloonModel) do
        Wait(10)
    end

    if spawn_balloon and DoesEntityExist(spawn_balloon) then
        SetEntityAsMissionEntity(spawn_balloon, true, true)
        DeleteVehicle(spawn_balloon)
        spawn_balloon = nil
        current_balloon_id = nil
        currentBalloonNetId = nil
    end
   
    local spawnCoords = Config.BalloonLocations[locationIndex].spawn
    spawn_balloon = CreateVehicle(balloonModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, false)
    if not DoesEntityExist(spawn_balloon) then return end

    local netId = NetworkGetNetworkIdFromEntity(spawn_balloon)
    SetNetworkIdExistsOnAllMachines(netId, true)
    SetEntityAsMissionEntity(spawn_balloon, true, true)
    SetModelAsNoLongerNeeded(balloonModel)

    current_balloon_id = balloonId
    currentBalloonNetId = netId
    
    -- Register as owner
    TriggerServerEvent('rs_balloon:trackBalloonOwner', netId)
    balloonOwnerSource = GetPlayerServerId(PlayerId())
end)

RegisterNetEvent("rs_balloon:deleteTemporaryBalloon")
AddEventHandler("rs_balloon:deleteTemporaryBalloon", function()
    if spawn_balloon ~= nil and DoesEntityExist(spawn_balloon) then
        SetEntityAsMissionEntity(spawn_balloon, true, true)
        DeleteVehicle(spawn_balloon)
        spawn_balloon = nil
        TriggerServerEvent("rs_balloon:removeBalloonFromSQL")
    end
end)

RegisterNetEvent("rs_balloon:balloonWarning")
AddEventHandler("rs_balloon:balloonWarning", function(secondsLeft)
    local message = ""

    if secondsLeft == 0 then
        Framework.ClientNotify(T.Tittle, T.BalloonExpired, "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end

    if secondsLeft >= 60 then
        local minutes = math.floor(secondsLeft / 60)
        local seconds = secondsLeft % 60

        if seconds > 0 then
            message = T.BalloonExpiresPrefix .. minutes .. (minutes > 1 and T.Minutes or T.Minute) .. T.And .. seconds .. T.Seconds
        else
            message = T.BalloonExpiresPrefix .. minutes .. (minutes > 1 and T.Minutes or T.Minute)
        end
    else
        message = T.BalloonExpiresPrefix .. secondsLeft .. T.Seconds
    end

    Framework.ClientNotify(T.Tittle, message, "generic_textures", "tick", 4000, "COLOR_GREEN")
end)

local spawn_ballon = nil
local current_ballon_id = nil

RegisterNetEvent('rs_balloon:spawnBalloon')
AddEventHandler('rs_balloon:spawnBalloon', function(locationName)
    if not locationName then
        return
    end

    if spawn_ballon and DoesEntityExist(spawn_ballon) then
        Framework.ClientNotify(T.Tittle, T.Youhave, "menu_textures", "cross", 4000, "COLOR_RED")
        return
    end

    local markerData = Config.Marker[locationName]
    if not markerData or not markerData.spawn then
        return
    end

    local spawnCoords = markerData.spawn
    local ballonModel = GetHashKey('hotAirBalloon01')

    RequestModel(ballonModel)
    while not HasModelLoaded(ballonModel) do
        Wait(10)
    end

    spawn_ballon = CreateVehicle(ballonModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, false)
    if not DoesEntityExist(spawn_ballon) then return end

    local netId = NetworkGetNetworkIdFromEntity(spawn_ballon)
    SetNetworkIdExistsOnAllMachines(netId, true)
    SetEntityAsMissionEntity(spawn_ballon, true, true)

    SetModelAsNoLongerNeeded(ballonModel)

    current_ballon_id = locationName
    currentBalloonNetId = netId
    
    -- Register as owner
    TriggerServerEvent('rs_balloon:trackBalloonOwner', netId)
    balloonOwnerSource = GetPlayerServerId(PlayerId())
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    for _, npc in pairs(NPCss) do
        if DoesEntityExist(npc) then
            DeleteEntity(npc)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- Passenger System Events
-- ═══════════════════════════════════════════════════════════════════════════════

local BALLOON_MODEL_HASH = GetHashKey("hotairballoon01")

--- RDR3 SET_PED_INTO_VEHICLE (fallback if global fails)
local N_SET_PED_INTO_VEHICLE_4 = 0xEAE60E6940938AB8
local N_SET_PED_INTO_VEHICLE_3 = 0xBC40F4F9E0E2E2BC

local function isHotAirBalloonEntity(entity)
    return entity and entity ~= 0 and DoesEntityExist(entity) and GetEntityModel(entity) == BALLOON_MODEL_HASH
end

local function isVehicleSeatFreeSafe(vehicle, seatIndex)
    local ok, free = pcall(function()
        return IsVehicleSeatFree(vehicle, seatIndex)
    end)
    if ok then
        return free
    end
    return true
end

local function putPedIntoBalloonSeat(ped, vehicle, seatIndex)
    if type(SetPedIntoVehicle) == "function" then
        pcall(function()
            SetPedIntoVehicle(ped, vehicle, seatIndex)
        end)
        Citizen.Wait(150)
        if GetVehiclePedIsIn(ped, false) == vehicle then
            return true
        end
    end
    pcall(function()
        Citizen.InvokeNative(N_SET_PED_INTO_VEHICLE_4, ped, vehicle, seatIndex, false)
    end)
    Citizen.Wait(80)
    if GetVehiclePedIsIn(ped, false) == vehicle then
        return true
    end
    pcall(function()
        Citizen.InvokeNative(N_SET_PED_INTO_VEHICLE_3, ped, vehicle, seatIndex)
    end)
    Citizen.Wait(80)
    return GetVehiclePedIsIn(ped, false) == vehicle
end

--- Resolve preferred seat index from server slot key (Config.PassengerSystem.seatForSlot).
local function getPreferredSeatIndex(slotKey)
    local ps = Config.PassengerSystem
    local map = ps and ps.seatForSlot
    if map and slotKey and map[slotKey] ~= nil then
        return map[slotKey]
    end
    if slotKey == "passenger2" then
        return 1
    end
    return 0
end

local function networkIdExists(netId)
    local ok, exists = pcall(function()
        return NetworkDoesNetworkIdExist(netId)
    end)
    return ok and exists
end

--- Wait for networked balloon entity, then warp local ped into passenger seat.
local function WarpPassengerIntoBalloon(balloonNetId, slotKey)
    local ps = Config.PassengerSystem
    if ps and ps.warpIntoVehicle == false then
        return
    end

    balloonNetId = tonumber(balloonNetId) or balloonNetId
    local ped = PlayerPedId()
    local timeout = (ps and ps.warpTimeoutMs) or 15000
    local deadline = GetGameTimer() + timeout
    local vehicle = 0

    while GetGameTimer() < deadline do
        if networkIdExists(balloonNetId) then
            local ent = NetworkGetEntityFromNetworkId(balloonNetId)
            if ent and ent ~= 0 and isHotAirBalloonEntity(ent) then
                vehicle = ent
                break
            end
        end
        Citizen.Wait(100)
    end

    if vehicle == 0 then
        Framework.ClientNotify("Balloon", "Could not find the balloon — stay nearby and try again.", "menu_textures", "cross", 4000, "COLOR_ORANGE")
        return
    end

    NetworkRequestControlOfEntity(vehicle)
    local ctrlUntil = GetGameTimer() + 2500
    while not NetworkHasControlOfEntity(vehicle) and GetGameTimer() < ctrlUntil do
        NetworkRequestControlOfEntity(vehicle)
        Citizen.Wait(0)
    end

    local vx, vy, vz = table.unpack(GetEntityCoords(vehicle))
    pcall(function()
        RequestCollisionAtCoord(vx, vy, vz)
    end)
    ClearPedTasksImmediately(ped)

    local preferred = getPreferredSeatIndex(slotKey)
    local alt = (preferred == 0) and 1 or 0
    local trySeats = {}
    local function addSeat(seat)
        if seat == nil then return end
        for _, v in ipairs(trySeats) do
            if v == seat then return end
        end
        trySeats[#trySeats + 1] = seat
    end
    addSeat(preferred)
    addSeat(alt)
    for s = 0, 3 do
        addSeat(s)
    end

    for _, seatIndex in ipairs(trySeats) do
        if isVehicleSeatFreeSafe(vehicle, seatIndex) then
            if putPedIntoBalloonSeat(ped, vehicle, seatIndex) then
                return
            end
        end
    end

    Framework.ClientNotify("Balloon", "Could not enter a seat — the balloon may be full.", "menu_textures", "cross", 4000, "COLOR_RED")
end

RegisterNetEvent('rs_balloon:setOwner')
AddEventHandler('rs_balloon:setOwner', function(ownerSource)
    balloonOwnerSource = ownerSource
end)

RegisterNetEvent('rs_balloon:receiveInvite')
AddEventHandler('rs_balloon:receiveInvite', function(fromPlayerId, fromPlayerName, balloonNetId)
    pendingInvite = {
        fromName = fromPlayerName,
        fromId = fromPlayerId,
        balloonNetId = balloonNetId
    }
    Framework.ClientNotify("Balloon Invite", "You received an invite from " .. fromPlayerName, "generic_textures", "tick", 5000, "COLOR_BLUE")
end)

RegisterNetEvent('rs_balloon:inviteExpired')
AddEventHandler('rs_balloon:inviteExpired', function()
    pendingInvite = nil
    Framework.ClientNotify("Balloon Invite", "Invite expired", "menu_textures", "cross", 3000, "COLOR_RED")
end)

RegisterNetEvent('rs_balloon:passengerJoined')
AddEventHandler('rs_balloon:passengerJoined', function(passengerName)
    Framework.ClientNotify("Balloon", passengerName .. " joined your balloon", "generic_textures", "tick", 3000, "COLOR_GREEN")
end)

RegisterNetEvent('rs_balloon:passengerLeft')
AddEventHandler('rs_balloon:passengerLeft', function(passengerName)
    Framework.ClientNotify("Balloon", passengerName .. " left your balloon", "menu_textures", "cross", 3000, "COLOR_YELLOW")
end)

RegisterNetEvent('rs_balloon:updatePassengerCount')
AddEventHandler('rs_balloon:updatePassengerCount', function(count)
    passengerCount = count
end)

RegisterNetEvent('rs_balloon:notOwnerControl')
AddEventHandler('rs_balloon:notOwnerControl', function()
    Framework.ClientNotify("Balloon", "Only the owner can control this balloon", "menu_textures", "cross", 3000, "COLOR_RED")
end)

-- Passenger added notification (for owner)
RegisterNetEvent('rs_balloon:passengerAdded')
AddEventHandler('rs_balloon:passengerAdded', function(passengerSrc, balloonNetId)
    passengerCount = passengerCount + 1
    Framework.ClientNotify("Balloon", "Passenger added to your balloon", "generic_textures", "tick", 3000, "COLOR_GREEN")
end)

-- Notify passenger they joined
RegisterNetEvent('rs_balloon:youArePassenger')
AddEventHandler('rs_balloon:youArePassenger', function(ownerSrc, balloonNetId, slotKey)
    balloonOwnerSource = tonumber(ownerSrc) or ownerSrc
    currentBalloonNetId = tonumber(balloonNetId) or balloonNetId
    Framework.ClientNotify("Balloon", T.InviteAccepted, "generic_textures", "tick", 3000, "COLOR_GREEN")
    Citizen.CreateThread(function()
        WarpPassengerIntoBalloon(currentBalloonNetId, slotKey)
    end)
end)

-- Passenger removed from balloon
RegisterNetEvent('rs_balloon:removedFromBalloon')
AddEventHandler('rs_balloon:removedFromBalloon', function(balloonNetId)
    local nid = tonumber(balloonNetId) or balloonNetId
    local cur = tonumber(currentBalloonNetId) or currentBalloonNetId
    if cur == nid then
        balloonOwnerSource = nil
        currentBalloonNetId = nil
        Framework.ClientNotify("Balloon", "You were removed from the balloon", "menu_textures", "cross", 3000, "COLOR_RED")
    end
end)

-- Balloon destroyed notification
RegisterNetEvent('rs_balloon:balloonDestroyed')
AddEventHandler('rs_balloon:balloonDestroyed', function(balloonNetId)
    if currentBalloonNetId == balloonNetId then
        Framework.ClientNotify("Balloon", "The balloon has been destroyed!", "menu_textures", "cross", 5000, "COLOR_RED")
        if balloon and DoesEntityExist(balloon) then
            SetEntityAsNoLongerNeeded(balloon)
            DeleteEntity(balloon)
        end
        balloon = nil
        spawn_balloon = nil
        currentBalloonNetId = nil
        balloonOwnerSource = nil
        isBalloonCrashing = false
        balloonDamaged = false
    end
end)

-- Trigger crash mechanics
RegisterNetEvent('rs_balloon:triggerCrash')
AddEventHandler('rs_balloon:triggerCrash', function(balloonNetId)
    if currentBalloonNetId == balloonNetId or (balloon and NetworkGetNetworkIdFromEntity(balloon) == balloonNetId) then
        isBalloonCrashing = true
        balloonDamaged = true
        Framework.ClientNotify("Balloon", T.BalloonCrashing, "menu_textures", "cross", 5000, "COLOR_RED")
        
        -- Play crash sound
        PlaySoundFrontend("CHECKPOINT_MISSED", "HUD_MINI_GAME_SOUNDSET", true, 1)
        
        -- Apply crash descent
        Citizen.CreateThread(function()
            while isBalloonCrashing and balloon and DoesEntityExist(balloon) do
                local velocity = GetEntityVelocity(balloon)
                local crashSpeed = Config.DamageSystem.crashDescentSpeed or 0.5
                SetEntityVelocity(balloon, velocity.x * 0.9, velocity.y * 0.9, -crashSpeed)
                Citizen.Wait(100)
            end
        end)
    end
end)

-- Update damage status
RegisterNetEvent('rs_balloon:updateDamage')
AddEventHandler('rs_balloon:updateDamage', function(balloonNetId, hitCount, maxHits, isDamaged)
    if currentBalloonNetId == balloonNetId then
        balloonDamaged = isDamaged
        if isDamaged then
            Framework.ClientNotify("Balloon", string.format("%s (%d/%d)", T.BalloonHit, hitCount, maxHits), "menu_textures", "cross", 3000, "COLOR_ORANGE")
        end
    end
end)

-- Receive damage status
RegisterNetEvent('rs_balloon:receiveDamageStatus')
AddEventHandler('rs_balloon:receiveDamageStatus', function(damageInfo)
    if damageInfo then
        local statusMsg = damageInfo.isDamaged and T.DamageStatusDamaged or T.DamageStatusHealthy
        local maxHitsValue = damageInfo.maxHits or Config.DamageSystem.arrowHitsToDestroyMax or 15
        local hitMsg = string.format("%s %d/%d", T.HitCounter, damageInfo.hits or 0, maxHitsValue)
        Framework.ClientNotify("Balloon Status", statusMsg .. "\n" .. hitMsg, "generic_textures", "tick", 5000, "COLOR_BLUE")
    end
end)

-- Balloon repaired notification
RegisterNetEvent('rs_balloon:balloonRepaired')
AddEventHandler('rs_balloon:balloonRepaired', function(balloonNetId)
    if currentBalloonNetId == balloonNetId then
        balloonDamaged = false
        isBalloonCrashing = false
        Framework.ClientNotify("Balloon", T.BalloonRepaired, "generic_textures", "tick", 3000, "COLOR_GREEN")
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- Visual Effects for Damaged Balloons
-- ═══════════════════════════════════════════════════════════════════════════════

-- Particle effect thread for damaged balloons
Citizen.CreateThread(function()
    local activeParticle = nil
    local lastDamageState = nil
    
    while true do
        if balloon and DoesEntityExist(balloon) and (balloonDamaged or isBalloonCrashing) then
            local currentState = isBalloonCrashing and "crashing" or (balloonDamaged and "damaged" or nil)
            
            -- Only update particles if state changed
            if currentState ~= lastDamageState then
                -- Clean up old particle
                if activeParticle then
                    StopParticleFxLooped(activeParticle, false)
                    activeParticle = nil
                end
                
                -- Request particle effect dictionary
                if not HasNamedPtfxAssetLoaded("core") then
                    RequestNamedPtfxAsset("core")
                    while not HasNamedPtfxAssetLoaded("core") do
                        Citizen.Wait(0)
                    end
                end
                
                UseParticleFxAsset("core")
                
                -- Get balloon position
                local balloonPos = GetEntityCoords(balloon)
                
                -- Create appropriate smoke effect
                if currentState == "crashing" then
                    -- Heavy smoke when crashing
                    activeParticle = StartParticleFxLoopedAtCoord("ent_amb_smoke_foundry", balloonPos.x, balloonPos.y, balloonPos.z + 2.0, 0.0, 0.0, 0.0, 2.0, false, false, false, false)
                    SetParticleFxLoopedAlpha(activeParticle, 0.8)
                elseif currentState == "damaged" then
                    -- Light smoke when damaged
                    activeParticle = StartParticleFxLoopedAtCoord("ent_amb_smoke_foundry", balloonPos.x, balloonPos.y, balloonPos.z + 2.0, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
                    SetParticleFxLoopedAlpha(activeParticle, 0.4)
                end
                
                lastDamageState = currentState
            end
            
            Citizen.Wait(500)
        else
            -- Clean up particle when balloon is no longer damaged
            if activeParticle then
                StopParticleFxLooped(activeParticle, false)
                activeParticle = nil
            end
            lastDamageState = nil
            Citizen.Wait(1000)
        end
    end
end)

-- Invite prompt handling
Citizen.CreateThread(function()
    while true do
        if pendingInvite then
            invitePromptGroup:handleEvents()
            
            local groupName = CreateVarString(10, 'LITERAL_STRING', "Balloon Invite from " .. pendingInvite.fromName)
            PromptSetActiveGroupThisFrame(invitePromptGroup.group, groupName)
            
            if IsControlJustPressed(0, KEY_ACCEPT_INV) then
                TriggerServerEvent('rs_balloon:acceptInvite', pendingInvite.fromId)
                pendingInvite = nil
                Citizen.Wait(500)
            elseif IsControlJustPressed(0, KEY_DECLINE_INV) then
                TriggerServerEvent('rs_balloon:declineInvite', pendingInvite.fromId)
                pendingInvite = nil
                Framework.ClientNotify("Balloon Invite", "Invite declined", "menu_textures", "cross", 3000, "COLOR_RED")
                Citizen.Wait(500)
            end
            
            Citizen.Wait(0)
        else
            Citizen.Wait(500)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- Damage System
-- ═══════════════════════════════════════════════════════════════════════════════

-- Detect balloon damage
AddEventHandler('gameEventTriggered', function(eventName, eventData)
    if not balloon or not DoesEntityExist(balloon) then return end
    
    -- CEventNetworkEntityDamage structure: [victim, attacker, weaponInfoIndex, isDead, weaponInfoIndex2, hitComponent, weaponHash]
    if eventName == 'CEventNetworkEntityDamage' then
        local victim = eventData[1]
        local attacker = eventData[2]
        local isDead = eventData[4]
        local weaponHash = eventData[7]
        
        if victim == balloon and currentBalloonNetId then
            local damageAmount = 1
            
            TriggerServerEvent('rs_balloon:balloonDamaged', currentBalloonNetId, damageAmount)
            balloonDamaged = true
        end
    end
end)

RegisterNetEvent('rs_balloon:balloonCrashing')
AddEventHandler('rs_balloon:balloonCrashing', function()
    isBalloonCrashing = true
    Framework.ClientNotify("Balloon", "Balloon is damaged! Crashing!", "menu_textures", "cross", 5000, "COLOR_RED")
    
    PlaySoundFrontend("CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", true, 1)
    
    Citizen.CreateThread(function()
        while isBalloonCrashing and balloon and DoesEntityExist(balloon) do
            Citizen.Wait(0)
        end
        isBalloonCrashing = false
    end)
end)

RegisterNetEvent('rs_balloon:damageStatusUpdated')
AddEventHandler('rs_balloon:damageStatusUpdated', function(isDamaged)
    balloonDamaged = isDamaged
    if not isDamaged then
        isBalloonCrashing = false
        Framework.ClientNotify("Balloon", "Balloon repaired successfully!", "generic_textures", "tick", 3000, "COLOR_GREEN")
    end
end)

-- Monitor owner death
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        if balloon and DoesEntityExist(balloon) then
            local playerPed = PlayerPedId()
            local currentHealth = GetEntityHealth(playerPed)
            
            if balloonOwnerSource == GetPlayerServerId(PlayerId()) and currentBalloonNetId then
                if lastPlayerHealth and currentHealth <= 0 and lastPlayerHealth > 0 then
                    TriggerServerEvent('rs_balloon:ownerDied', currentBalloonNetId)
                end
                lastPlayerHealth = currentHealth
            end
        else
            lastPlayerHealth = nil
        end
    end
end)
