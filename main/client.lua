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

-- script
local inTool, entity, model, name = {}, nil, nil, nil

-- Second menu
local function OpenWaySettingMenu()
    lib.registerMenu({
        id = 'way_menu',
        title = 'supv_entityTool',
        position = 'top-left',
        onSideScroll = function(selected, scrollIndex, args)
            print("Scroll: ", selected, scrollIndex, args)
        end,
        onSelected = function(selected, secondary, args)
            if not secondary then
                print("Normal button")
            else
                if args.isCheck then
                    print("Check button")
                end
    
                if args.isScroll then
                    print("Scroll button")
                end
            end
            print(selected, secondary, json.encode(args, {indent=true}))
        end,
        onCheck = function(selected, checked, args)
            print("Check: ", selected, checked, args)
        end,
        onClose = function(keyPressed)
            print('Menu closed')
            if keyPressed then
                print(('Pressed %s to close the menu'):format(keyPressed))
            end
        end,
        options = {
            --{label = ''}
        }

    }, function(selected, scrollIndex, args)
        
    end)
end

local function SelectedByLaser() -- entity & PlayerPedId : number
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
        -- check part
        if input[1] == input[2] then
            print('Vous ne pouvez pas selectionner les même paramètre')
            SelectedByLaser() -- restart dialog
        elseif not input[1] or not input[2] then
            print('Les deux paramètre doivent avoir une valeur')
            SelectedByLaser() -- restart dialog
        end

        -- next
        inTool[1], inTool[2] = {}, {}
        if input[1] ~= 'other' and input[2] ~= 'other' then
            inTool[1].entity = tonumber(input[1])
            inTool[1].label = PlayerPedId() == tonumber(input[1]) and 'PlayerPedId()' or name
            inTool[1].name = PlayerPedId() == tonumber(input[1]) and 'PlayerPedId()' or name
            inTool[2].entity = tonumber(input[2])
            inTool[2].label = PlayerPedId() == tonumber(input[2]) and 'PlayerPedId()' or name
            inTool[2].name = PlayerPedId() == tonumber(input[2]) and 'PlayerPedId()' or name
        else
            if input[1] ~= 'other' then
                inTool[1].entity = tonumber(input[1])
                inTool[1].label = PlayerPedId() == tonumber(input[1]) and 'PlayerPedId()' or name
                inTool[1].name = PlayerPedId() == tonumber(input[1]) and 'PlayerPedId()' or name
                LaserSelect('other', 2)
            elseif input[2] ~= 'other' then
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
                    --if IsEntityAnObject(Entity) then
                        SetEntityAsMissionEntity(Entity, true, true)
                        Citizen.InvokeNative(0xAE3CBE5BF394C9C9, Citizen.PointerValueIntInitialized(Entity))
                    --else
                        --DeleteEntity(Entity)
                    --end
                elseif mode == 'select' then
                    entity, model, name = Entity, Model, Name
                    laser = false
                    lib.hideTextUI()
                    SelectedByLaser()
                elseif mode == 'other' then
                    inTool[index].entity = Entity
                    inTool[index].label = Name
                    inTool[index].name = Name
                    lib.hideTextUI()
                    print(json.encode(inTool, {indent = true}))
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
lib.registerMenu({
    id = 'main_menu',
    title = 'supv_entityTool',
    position = 'top-left',
    onSideScroll = function(selected, scrollIndex, args)
        print("Scroll: ", selected, scrollIndex, args)
    end,
    onSelected = function(selected, secondary, args)
        if not secondary then
            print("Normal button")
        else
            if args.isCheck then
                print("Check button")
            end

            if args.isScroll then
                print("Scroll button")
            end
        end
        print(selected, secondary, json.encode(args, {indent=true}))
    end,
    onCheck = function(selected, checked, args)
        print("Check: ", selected, checked, args)
    end,
    onClose = function(keyPressed)
        print('Menu closed')
        if keyPressed then
            print(('Pressed %s to close the menu'):format(keyPressed))
        end
    end,
    options = {
        -- Setting tool
        {label = 'Select in map', description = 'Select what you want setting on map'}, --1
        {label = 'Select your player', description = 'Setting on your player'}, --2
        -- Command tool
        {label = 'Delete Entity', description = 'Delete entity in the map'}, --3
        {label = 'Spawn', values = {'car', 'ped', 'object'}, description = 'Spawn Car, Ped or Object', defaultIndex = 1} --4       

        --{label = 'Checkbox button', checked = true},
        --{label = 'Scroll button with icon', icon = 'arrows-up-down-left-right', values={'hello', 'there'}},
        --{label = 'Button with args', args = {someArg = 'nice_button'}},
        --{label = 'List button', values = {'You', 'can', 'side', 'scroll', 'this'}, description = 'It also has a description!'},
        --{label = 'List button with default index', values = {'You', 'can', 'side', 'scroll', 'this'}, defaultIndex = 5},
        --{label = 'List button with args', values = {'You', 'can', 'side', 'scroll', 'this'}, args = {someValue = 3, otherValue = 'value'}},
    },
}, function(selected, scrollIndex, args)
    print(selected, scrollIndex, args)
    inTool, entity, model, name = {}, nil, nil, nil
    if selected == 1 then
        LaserSelect('select')
    elseif selected == 2 then
        
    elseif selected == 3 then
        LaserSelect('delete')
    elseif selected == 4 then
        if scrollIndex == 1 then -- car
            local input = lib.inputDialog('Spawn car', {
                {type = 'input', label = 'String of car', placeholder = 't20'},
            })
    
            if input then
                local coords = GetEntityCoords(PlayerPedId())
                local heading = GetEntityHeading(PlayerPedId())
                local newCoords = vec4(coords.x, coords.y, coords.z, heading)
                supv.vehicle.spawnLocal(input[1], newCoords, function(vehicle)
                    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
                end)
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
                {type = 'checkbox', label = 'Freeze', checked = true} --8
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
            else
                lib.showMenu('main_menu') 
            end
        elseif scrollIndex == 3 then -- object
            local input = lib.inputDialog('Spawn object', {
                {type = 'input', label = 'String of object', placeholder = ''},
                {type = 'checkbox', label = 'zGround', checked = true},
                {type = 'checkbox', label = 'Freeze', checked = true}
            })
    
            if input then
                local coords = GetEntityCoords(PlayerPedId())
                supv.object.createLocal(input[1], coords - vec3(1.0,1.0,1.0), function(obj)
                    if input[2] then FreezeEntityPosition(obj, true) end
                    if input[3] then PlaceObjectOnGroundProperly(obj) end
                end)
            else
                lib.showMenu('main_menu')
            end
        end
    end
end)

RegisterNetEvent('supv_entityTool:client:openMenu', function()
    lib.showMenu('main_menu') 
end)