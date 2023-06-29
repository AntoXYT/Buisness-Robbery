exports['es_extended']:getSharedObject()

local giocatoriRapinati = {}
local luoghiRapinati = {}

function rapina(xPlayer, societa)
    local balance = 0


    if giocatoriRapinati[xPlayer.identifier] then
        xPlayer.showNotification('Hai già completato una rapina.')
        return
    end


    if giocatoriRapinati[xPlayer.identifier] and os.time() - giocatoriRapinati[xPlayer.identifier] < 86400 then
        local timeLeft = 86400 - (os.time() - giocatoriRapinati[xPlayer.identifier])
        xPlayer.showNotification('Devi aspettare ancora ' .. timeLeft .. ' secondi prima di poter compiere un\'altra rapina.')
        return
    end


    if luoghiRapinati[societa] then
        xPlayer.showNotification('Questa società è già stata rapinata.')
        return
    end

    MySQL.query("SELECT * FROM addon_account_data WHERE account_name = @account", {
        ['@account'] = societa
    }, function(result)
        if result and result[1] then
            balance = tonumber(result[1].money)

            if balance == nil then
                balance = 0
            end

            if balance > 0 then

                local policeOnline = 0
                local players = ESX.GetPlayers()

                for i = 1, #players do
                    local player = ESX.GetPlayerFromId(players[i])
                    if player ~= nil and player.getJob().name == 'police' then
                        policeOnline = policeOnline + 1
                    end
                end

                if policeOnline < Config.police then
                    xPlayer.showNotification('La rapina non può iniziare: ci devono essere almeno due poliziotti online.')
                    return
                end

        
                xPlayer.set('isRobbing', true)
                xPlayer.showNotification('Hai iniziato una rapina alla società ' .. societa .. '.')
                luoghiRapinati[societa] = true

                local randomAmount = balance

                if randomAmount < 1000 then
                    randomAmount = balance
                else 
                    randomAmount = math.random(1000, balance)
                end

          
                MySQL.execute('UPDATE addon_account_data SET money = money - @amount WHERE account_name = @account', {
                    ['@amount'] = randomAmount,
                    ['@account'] = societa
                })

                SetTimeout(Config.RapinaTimer * 1000, function()
                    if xPlayer.get('isRobbing') then
                        xPlayer.addMoney(randomAmount)
                        xPlayer.set('isRobbing', false)
                        xPlayer.showNotification('Hai rubato ' .. randomAmount .. ' dalla società ' .. societa .. '.')
                        giocatoriRapinati[xPlayer.identifier] = os.time()
                    end
                end)
            else
                xPlayer.showNotification('Rapina fallita: non sono stati trovati soldi nella società ' .. societa)
            end
        end
    end)
end

RegisterNetEvent('rob:societa')
AddEventHandler('rob:societa', function(societa)
    local xPlayer = ESX.GetPlayerFromId(source)
    rapina(xPlayer, societa)
end)

RegisterNetEvent('rob:annulla')
AddEventHandler('rob:annulla', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.set('isRobbing', false)
    xPlayer.showNotification('Ti sei allontanato. La Rapian è stata annullata')
    giocatoriRapinati[xPlayer.identifier] = os.time()
end)
