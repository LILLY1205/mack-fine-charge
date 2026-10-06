local RSGCore = exports['rsg-core']:GetCoreObject()

-- List of jobs allowed to issue fines
local AuthorizedJobs = {
    ['police'] = true,
    ['vallaw'] = true,
    ['rholaw'] = true,
    ['blklaw'] = true,
    ['strlaw'] = true,
    ['stdenlaw'] = true,
    ['governor'] = true,
    ['marshal'] = true,
    -- Add more jobs as needed
}

-- Command to issue a fine
RSGCore.Commands.Add('fine', 'Issue a fine to a player (Law Enforcement Only)', {}, true, function(source, args)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check if player has authorized job
    if not AuthorizedJobs[Player.PlayerData.job.name] then
        TriggerClientEvent('RSGCore:Notify', src, 'You are not authorized to issue fines!', 'error')
        return
    end
    
    -- Trigger client event to show fine input dialog
    TriggerClientEvent('rsg-fines:client:ShowFineInputs', src)
end)

-- Server event to process the fine
RegisterNetEvent('rsg-fines:server:IssueFine', function(targetId, amount, reason)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local Target = RSGCore.Functions.GetPlayer(targetId)
    
    if not Player or not Target then return end
    
    -- Check if player has authorized job
    if not AuthorizedJobs[Player.PlayerData.job.name] then
        TriggerClientEvent('RSGCore:Notify', src, 'You are not authorized to issue fines!', 'error')
        return
    end
    
    -- Validate amount
    if not amount or amount <= 0 then
        TriggerClientEvent('RSGCore:Notify', src, 'Invalid fine amount!', 'error')
        return
    end
    
    -- Check if target has enough money
    if Target.PlayerData.money['bank'] < amount then
        TriggerClientEvent('RSGCore:Notify', src, 'Target does not have enough money!', 'error')
        return
    end
    
    -- Remove money from target
    Target.Functions.RemoveMoney('bank', amount, 'fine-payment')   

    -- Add money to the issuing officer's job management fund
    local issuerJobName = Player.PlayerData.job.name
	exports['rsg-bossmenu']:AddMoney(issuerJobName, amount)

    -- Notify the fined player
    TriggerClientEvent('rNotify:NotifyLeft', targetId, "Fine Received", "Amount: $" .. amount .. "\nReason: " .. reason, "generic_textures", "tick", 4000)
    
    -- Notify the officer who issued the fine
    TriggerClientEvent('RSGCore:Notify', src, 'Fine of $' .. amount .. ' issued successfully! Added to ' .. issuerJobName .. ' management funds.', 'success')

    -- Log the fine
    TriggerEvent('rsg-log:server:CreateLog', 'fines', 'Fine Issued', 'red', 
        Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. 
        ' issued a fine of $' .. amount .. 
        ' to ' .. Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname .. 
        ' for: ' .. reason .. 
        ' (Added to ' .. issuerJobName .. ' management funds)'
    )
end)