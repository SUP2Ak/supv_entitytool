if not supv and lib then return end
-- lua ref
local print <const> = print
local json <const> = json
local pairs <const> = pairs
local ipairs <const> = ipairs
local math <const> = math
local string <const> = string
local tonumber <const> = tonumber
-- native ref
local PlayerPedId <const> = PlayerPedId
local SetPedIntoVehicle <const> = SetPedIntoVehicle
local GetEntityCoords <const> = GetEntityCoords
local GetEntityHeading <const> = GetEntityHeading
local vec4 <const> = vec4
local vec3 <const> = vec3
local SetEntityAsMissionEntity <const> = SetEntityAsMissionEntity
local IsControlJustPressed <const> = IsControlJustPressed
local FreezeEntityPosition <const> = FreezeEntityPosition
local PlaceObjectOnGroundProperly <const> = PlaceObjectOnGroundProperly
local IsControlPressed <const> = IsControlPressed

-- script
local inTool, entity, model, name, WebhookUrl = {}, nil, nil, nil, nil
local entityObj1, entityObj2 = nil, nil
local _coord, _rot, _on = {0.0,0.0,0.0}, {0.0,0.0,0.0}, 0
local _indexRot, _indexCoord, inIteration, _speed, _boneIndex = 1, 1, false, 1, 1

local function SendToWebhook(title, desc)
    if WebhookUrl then supv.webhook.embed(WebhookUrl, {title = title, description = desc}, 'supv_entitytool', nil) end
end

local function Iteration()
    inIteration = true
    local sleep
    CreateThread(function()
        while inIteration do
            sleep = 10
            if IsControlPressed(0, 190) then -- right
                sleep = 5
                if _on == 6 then -- coords
                    _coord[_indexCoord] += (0.001*_speed)
                elseif _on == 8 then -- rot
                    _rot[_indexRot] += (0.1*_speed)
                end
                entityObj1:attach(entityObj2.entity, {coords = _coord, rot = _rot})
            elseif IsControlPressed(0, 189) then -- left
                sleep = 5
                if _on == 6 then -- coords
                    _coord[_indexCoord] -= (0.001*_speed)                    
                elseif _on == 8 then -- rot
                    _rot[_indexRot] -= (0.1*_speed)
                end
                entityObj1:attach(entityObj2.entity, {coords = _coord, rot = _rot})
            end
            Wait(sleep)
        end
    end)
end

-- Attach menu
local function AttachEntityMenu(alreadyOpen, ...)
    local canSkip = alreadyOpen or false
    lib.hideTextUI()
    if not canSkip then 
        local boneList, BoneValue, BoneArgs, canReset = entityObj1.boneList, {}, {}, true
        _coord, _rot, _on, _speed = {0.0,0.0,0.0}, {0.0,0.0,0.0}, 0, 1

        for i = 1, #boneList do
            BoneValue[i] = boneList[i].label
            BoneArgs[i] = boneList[i].index
        end

        local buttons = { -- a faire re agencer les boutons
            {label = 'AttachEntity', checked = true}, --1 ok
            {label = 'SwapEntity'}, --2 ok
            {label = 'Speed', values = {'1', '2', '3', '5', '10', '100'}, args = {1, 2, 3, 5, 10, 100}, close = false}, --3
            {label = 'Bone List', values = BoneValue, args = BoneArgs}, --4
            {label = 'Coords', values = {'x', 'y', 'z'}, args = {1, 2, 3}, close = false}, --5
            {label = 'Iter coords', icon = 'arrows-left-right', values = {'-/+'}, close = false}, --6
            {label = 'Rot', values = {'x', 'y', 'z'}, args = {1, 2, 3}, close = false}, --7
            {label = 'Iter rot', icon = 'arrows-left-right', values = {'-/+'}, close = false}, --8
            {label = 'Reset', description = 'Reset all setting after settings', checked = canReset}, --9
            {label = 'Copy to clipboard', close = true}, --10
        }
        if WebhookUrl then lib.setMenuOptions('attach_menu', {label = 'Copy to discord'}, 11) end
    
        lib.registerMenu({
            id = 'attach_menu',
            title = 'supv_entityTool',
            position = 'top-left',
            onSideScroll = function(selected, scrollIndex, args)
                if selected == 5 then
                    _indexCoord = args[scrollIndex]
                elseif selected == 7 then
                    _indexRot = args[scrollIndex]
                elseif selected == 4 then
                    entityObj1:attach(entityObj2.entity, {bone = args[scrollIndex]})
                    _boneIndex = scrollIndex
                elseif selected == 3 then
                    _speed = args[scrollIndex]
                end
            end,
            onSelected = function(selected, secondary, args)
                if not secondary then else
                    if args.isCheck then entityObj1:attach(entityObj2.entity, {coords = _coord, rot = _rot}) end
                    if args.isScroll then end
                end
                _on = selected
            end,
            onCheck = function(selected, checked, args)
                if selected == 1 then
                    if checked then entityObj1:attach(entityObj2.entity, {coords = _coord, rot = _rot}) else entityObj1:detach() entityObj2:detach() end
                elseif selected == 9 then canReset = checked
                end
            end,
            onClose = function(keyPressed)
                inIteration = false
                entityObj1:detach() entityObj2:detach()
                Wait(250)
                if canReset then entityObj1:reset() entityObj2:reset() end
                entityObj1, entityObj2 = entityObj1:unSelect(), entityObj2:unSelect()
            end,
            options = buttons
        }, function(selected, scrollIndex, args)
            if selected == 2 then
                if entityObj1.entity == inTool[1].entity then
                    entityObj1, entityObj2 = entityObj1:unSelect(), entityObj2:unSelect()
                    entityObj1, entityObj2 = supv.tool.selectEntity(inTool[2].entity), supv.tool.selectEntity(inTool[1].entity)
                    AttachEntityMenu()
                else
                    entityObj1, entityObj2 = entityObj1:unSelect(), entityObj2:unSelect()
                    entityObj1, entityObj2 = supv.tool.selectEntity(inTool[1].entity), supv.tool.selectEntity(inTool[2].entity)
                    AttachEntityMenu()
                end
            elseif selected == 4 then
                local options = {} for i = 1, #boneList do options[i] = {value = boneList[i].index, label = boneList[i].label} end
                local input = lib.inputDialog('Bone List', {
                    {type = 'select', label = 'Select bone', options = options}
                })

                if input then
                    local value = tonumber(input[1]) or input[1]
                    entityObj1:attach(entityObj2.entity, {bone = value})
                    Wait(250)
                    AttachEntityMenu('bone', value)
                else
                    Wait(250)
                    AttachEntityMenu(true)
                end
            elseif selected == 10 then -- clipboard
                local message = ("--[[\nEntity 1: %s - %s\nEntity 2: %s - %s\nBone: %s - %s\nCoords: {%s,%s,%s}\nRot: {%s,%s,%s}\n%s\n--]]"):format(GetEntityArchetypeName(entityObj1.entity), entityObj1.model, GetEntityArchetypeName(entityObj2.entity), entityObj2.model, BoneValue[_boneIndex], BoneArgs[_boneIndex], _coord[1], _coord[2], _coord[3], _rot[1], _rot[2], _rot[3], entityObj1.native)
                SendNUIMessage({
                    type = 'copy',
                    data = message
                })
                Wait(250)
                AttachEntityMenu(true)
            elseif selected == 11 then -- discord
                local input = lib.inputDialog('Webhook', {
                    {type = 'input', label = 'Title'}
                })
                if input then
                    local message = ("Entity 1: %s - %s\nEntity 2: %s - %s\nBone: %s - %s\nCoords: {%s,%s,%s}\nRot: {%s,%s,%s}\n%s"):format(GetEntityArchetypeName(entityObj1.entity), entityObj1.model, GetEntityArchetypeName(entityObj2.entity), entityObj2.model, BoneValue[_boneIndex], BoneArgs[_boneIndex], _coord[1], _coord[2], _coord[3], _rot[1], _rot[2], _rot[3], entityObj1.native)
                    SendToWebhook(input[1] or 'Your settings', message)
                    AttachEntityMenu(true)
                else 
                    AttachEntityMenu(true)
                end
            end
        end)
    elseif canSkip == 'bone' then
        local boneList, BoneValue, BoneArgs = entityObj1.boneList, {}, {}
        for i = 1, #boneList do
            BoneValue[i] = boneList[i].label
            BoneArgs[i] = boneList[i].index
            if boneList[i].index == ... then _boneIndex = i end
        end
        lib.setMenuOptions('attach_menu', {label = 'Bone List', values = BoneValue, args = BoneArgs, defaultIndex = _boneIndex}, 4)
    end
    lib.showMenu('attach_menu')
    Iteration()
end

local function SelectedByLaser() -- entity & PlayerPedId : number
    lib.hideTextUI()
    entityObj1, entityObj2 = nil, nil
    local input = lib.inputDialog('Settings', {
        {type = 'select', label = 'Attach1', options = {
            {value = PlayerPedId(), label = 'My player'},
            {value = entity, label = 'Entity selected : '..name},
            {value = 'other', label = 'Select with laser'}
        }},
        {type = 'select', label = 'Attach2', options = {
            {value = PlayerPedId(), label = 'My player'},
            {value = entity, label = 'Entity selected : '..name},
            {value = 'other', label = 'Select with laser'}
        }}
    })

    if input then
        -- error
        if input[1] == input[2] then
            lib.closeInputDialog()
            Wait(250)
            print('Vous ne pouvez pas selectionner les même paramètre')
            SelectedByLaser() -- restart dialog
        elseif not input[1] or not input[2] then
            lib.closeInputDialog()
            Wait(250)
            print('Les deux paramètre doivent avoir une valeur')
            SelectedByLaser() -- restart dialog
        end

        -- success
        inTool[1], inTool[2] = {}, {}
        if input[1] ~= 'other' and input[2] ~= 'other' then
            inTool[1].entity = tonumber(input[1])
            inTool[1].label = PlayerPedId() == tonumber(input[1]) and 'PlayerPedId()' or name
            inTool[1].name = PlayerPedId() == tonumber(input[1]) and 'PlayerPedId()' or name
            inTool[2].entity = tonumber(input[2])
            inTool[2].label = PlayerPedId() == tonumber(input[2]) and 'PlayerPedId()' or name
            inTool[2].name = PlayerPedId() == tonumber(input[2]) and 'PlayerPedId()' or name
            entityObj1, entityObj2 = supv.tool.selectEntity(inTool[1].entity), supv.tool.selectEntity(inTool[2].entity)
            AttachEntityMenu()
        else
            if input[1] ~= 'other' and input[2] then
                inTool[1].entity = tonumber(input[1])
                inTool[1].label = PlayerPedId() == tonumber(input[1]) and 'PlayerPedId()' or name
                inTool[1].name = PlayerPedId() == tonumber(input[1]) and 'PlayerPedId()' or name
                LaserSelect('other', 2)
            elseif input[2] ~= 'other' and input[1] then
                inTool[2].entity = tonumber(input[2])
                inTool[2].label = PlayerPedId() == tonumber(input[2]) and 'PlayerPedId()' or name
                inTool[2].name = PlayerPedId() == tonumber(input[2]) and 'PlayerPedId()' or name
                LaserSelect('other', 1)
            end
        end
    else
        print('null come back to laser')
        LaserSelect('select')
    end
end

-- Laser
function LaserSelect(mode, index)
    local text = mode == 'select' and '[E] - Select / [BACKSPACE] - Quit' or mode == 'delete' and '[E] - Delete / [BACKSPACE] - Quit' or mode == 'other' and '[E] Select (other) / [BACKSPACE] - Return'
    local icon = mode == 'select' and 'barcode' or mode == 'delete' and 'trash' or mode == 'other' and 'hammer'
    local bgColor = mode == 'select' and '#48BB78' or mode == 'delete' and '#670000' or mode == 'other' and '#d37200'
    lib.showTextUI(text, {
        position = "top-center",
        icon = icon,
        style = {
            borderRadius = 1,
            backgroundColor = bgColor,
            color = 'white'
        }
    })

    local laser = true

    CreateThread(function()
        while laser do
            Wait(0)

            supv.tool.laser(function(Entity, Model, Name)
                if mode == 'delete' then
                    SetEntityAsMissionEntity(Entity, true, true)
                    Citizen.InvokeNative(0xAE3CBE5BF394C9C9, Citizen.PointerValueIntInitialized(Entity))
                elseif mode == 'select' then
                    entity, model, name = Entity, Model, Name
                    laser = false
                    SelectedByLaser()
                elseif mode == 'other' then
                    inTool[index].entity = Entity
                    inTool[index].label = Name
                    inTool[index].name = Name
                    entityObj1, entityObj2 = supv.tool.selectEntity(inTool[1].entity), supv.tool.selectEntity(inTool[2].entity)
                    AttachEntityMenu()
                    --print(json.encode(inTool, {indent = true}))
                    laser = false
                end
            end)

            if IsControlJustPressed(0, 194) then
                if mode ~= 'other' then lib.showMenu('main_menu') else SelectedByLaser() end
                lib.hideTextUI()
                laser = false
            end
        end
    end)
end

-- Main part
lib.registerMenu(
    {
        id = 'main_menu',
        title = 'supv_entityTool',
        position = 'top-left',
        onSideScroll = function(selected, scrollIndex, args) end,
        onSelected = function(selected, secondary, args) end,
        onCheck = function(selected, checked, args) end,
        onClose = function(keyPressed) end,
        options = {
            -- Setting tool
            {label = 'Mode: AttachEntityToEntity', description = 'Select what you want setting on map'}, --1
            {label = 'wip', description = 'Setting on your player'}, --2
            -- Command tool
            {label = 'Delete Entity', description = 'Delete entity in the map'}, --3
            {label = 'Spawn', values = {'car', 'ped', 'object'}, description = 'Spawn Car, Ped or Object', defaultIndex = 1}, --4 
            {label = 'ClearArea'} --5
        }
    }, 
    function(selected, scrollIndex, args)
        inTool, entity, model, name = {}, nil, nil, nil
        if selected == 1 then
            LaserSelect('select')
        elseif selected == 2 then
            -- wip
        elseif selected == 3 then
            LaserSelect('delete')
        elseif selected == 4 then
            if scrollIndex == 1 then -- car
                local input = lib.inputDialog('Spawn car', {
                    {type = 'input', label = 'String of car', placeholder = 't20'},
                    {type = 'checkbox', label = 'Re-open menu', checked = false},
                })
        
                if input then
                    local coords = GetEntityCoords(PlayerPedId())
                    local heading = GetEntityHeading(PlayerPedId())
                    local newCoords = vec4(coords.x, coords.y, coords.z, heading)
                    supv.vehicle.spawnLocal(input[1], newCoords, function(vehicle)
                        SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
                    end)
                    if input[2] then
                        Wait(250)
                        lib.showMenu('main_menu')
                    end
                else
                    lib.showMenu('main_menu') 
                end
            elseif scrollIndex == 2 then -- ped
                local input = lib.inputDialog('Spawn ped', {
                    {type = 'input', label = 'String of ped', placeholder = 'a_f_m_beach_01'}, --1
                    {type = 'input', label = 'Variation (number)', placeholder = 'nil'}, --2
                    {type = 'checkbox', label = 'Weapon?', checked = false}, --3
                    {type = 'input', label = 'String of weapon', placeholder = 'weapon_pistol'}, --4
                    {type = 'input', label = 'Ammo (number)', placeholder = '200'}, --5
                    {type = 'checkbox', label = 'BlockEvent', checked = true}, --6
                    {type = 'checkbox', label = 'GodMode', checked = true}, --7
                    {type = 'checkbox', label = 'Freeze', checked = true}, --8
                    {type = 'checkbox', label = 'Re-open menu', checked = false},
                })
        
                if input then
                    local coords, heading = GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId())*0.25
                    local newCoords = vec4(coords.x, coords.y, coords.z - 1, heading)
                    local weapon, var = input[3] == true and string.upper(input[4]) or nil, tonumber(input[2]) or nil
                    supv.npc.unNet(input[1], newCoords, {
                        blockevent = input[6],
                        freeze = input[8],
                        godmode = input[7],
                        variation = var,
                    }, {hash = weapon or ``, ammo = tonumber(input[5]) or 0, visible = weapon ~= nil and true or false})
                    if input[9] then
                        Wait(250)
                        lib.showMenu('main_menu')
                    end
                else
                    lib.showMenu('main_menu') 
                end
            elseif scrollIndex == 3 then -- object
                local input = lib.inputDialog('Spawn object', {
                    {type = 'input', label = 'String of object', placeholder = 'prop_cs_burger_01'},
                    {type = 'checkbox', label = 'zGround', checked = true},
                    {type = 'checkbox', label = 'Freeze', checked = true},
                    {type = 'checkbox', label = 'Re-open menu', checked = false},
                })
        
                if input then
                    local coords = GetEntityCoords(PlayerPedId())
                    supv.object.createLocal(input[1], coords - vec3(1.0,1.0,1.0), function(obj)
                        if input[2] then FreezeEntityPosition(obj, true) end
                        if input[3] then PlaceObjectOnGroundProperly(obj) end
                    end)
                    if input[4] then
                        Wait(250)
                        lib.showMenu('main_menu')
                    end
                else
                    lib.showMenu('main_menu')
                end
            end
        elseif selected == 5 then
            local input = lib.inputDialog('Clear area', {
                {type = 'checkbox', label = 'Re-open menu', checked = true},
                {type = 'input', label = 'Radius', placeholder = '1.0'},
                {type = 'checkbox', label = 'Ignore cop cars', checked = false},
                {type = 'checkbox', label = 'Ignore object', checked = false},
            })

            if input then
                local playerCoords = GetEntityCoords(PlayerPedId())
                local radius = tonumber(input[2])
                if math.type(radius) == 'integer' then radius = tonumber(tostring(radius..'.0')) end
                ClearArea(playerCoords.xyz, radius, true, input[3], input[4], false)
                if input[1] then
                    Wait(250)
                    lib.showMenu('main_menu')
                end
            else
                lib.showMenu('main_menu')
            end
        end
    end
)

RegisterNetEvent('supv_entityTool:client:openMenu', function(url)
    WebhookUrl = url
    lib.showMenu('main_menu') 
end)