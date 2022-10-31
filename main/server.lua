if not supv and lib then return end
local pairs <const> = pairs

local arrayGroup = {}


if ESX and (Config.Framework == 'ESX' or Config.Framework == 'esx') then
    for k,v in pairs(Config.Access.group) do
        if v then arrayGroup[#arrayGroup+1] = ("%s"):format(k) end
    end
    ESX.RegisterCommand('openToolMenu', arrayGroup, function(xPlayer, args, showError)
        TriggerClientEvent('supv_entityTool:client:openMenu', xPlayer.source)
    end, false)
elseif QB and (Config.Framework == 'QB' or Config.Framework == 'qb-core') then
    print('make your own code')
else
    for k,v in pairs(Config.Access.group) do
        if v then arrayGroup[#arrayGroup+1] = ("group.%s"):format(k) end
    end
    lib.addCommand(arrayGroup, 'openToolMenu', function(source, args)
        TriggerClientEvent('supv_entityTool:client:openMenu', source)
    end, {})
end

supv.version.check("https://raw.githubusercontent.com/SUP2Ak/supv_entitytool/main/fxmanifest.lua", nil, nil, 'lua', 'https://github.com/SUP2Ak/supv_entitytool', Config.SelectedLanguage)