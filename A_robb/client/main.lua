exports['es_extended']:getSharedObject()


Citizen.CreateThread(function()
    for _, job in ipairs(Config.Lavori) do
        local markerPos = job.pos
        TriggerEvent('gridsystem:registerMarker', {
            name = job.societa,
            pos = markerPos,
            scale = vector3(0.5, 0.5, 0.5),
            msg = 'Premi ~INPUT_CONTEXT~ per rapinare il buisness',
            control = 'E',
            type = 29,
            color = { r = 255, g = 0, b = 0 },
            action = function()
                local societa = job.societa
                    TriggerServerEvent('rob:societa', societa)
            end,
            onExit = function()
                TriggerServerEvent('rob:annulla')
              end
        })
    end
end)