Config, ESX, QB = {}, nil, nil

if GetResourceState('es_extended') == 'started' then
    ESX = exports.es_extended:getSharedObject()
elseif GetResourceState('qb-core') == 'started' then
    -- QB = exports['qb-core']:GetSharedObject() -- ... fuck I don't use this shit, I don't know... but you can pull request on my github for this shit framework if you want
end