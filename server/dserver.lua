local RSGCore = exports['rsg-core']:GetCoreObject()

-- List of jobs allowed to issue charges
local AuthorizedJobs = {
    ['medic'] = true,  -- Added doctor job
}

-- Command to issue a charge
RSGCore.Commands.Add('charge', 'Issue a medical charge to a player (Authorized Personnel Only)', {}, true, function(source, args)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check if player has authorized job
    if not AuthorizedJobs[Player.PlayerData.job.name] then
        TriggerClientEvent('RSGCore:Notify', src, 'You are not authorized to issue charges!', 'error')
        return
    end
    
    -- Trigger client event to show charge input dialog
    TriggerClientEvent('rsg-charges:client:ShowChargeInputs', src)
end)

-- Server event to process the charge
RegisterNetEvent('rsg-charges:server:IssueCharge', function(targetId, amount, reason)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local Target = RSGCore.Functions.GetPlayer(targetId)
    
    if not Player or not Target then return end
    
    -- Check if player has authorized job
    if not AuthorizedJobs[Player.PlayerData.job.name] then
        TriggerClientEvent('RSGCore:Notify', src, 'You are not authorized to issue charges!', 'error')
        return
    end
    
    -- Validate amount
    if not amount or amount <= 0 then
        TriggerClientEvent('RSGCore:Notify', src, 'Invalid charge amount!', 'error')
        return
    end
    
    -- Check if target has enough money
    if Target.PlayerData.money['bank'] < amount then
        TriggerClientEvent('RSGCore:Notify', src, 'Target does not have enough money!', 'error')
        return
    end
    
    -- Remove money from target
    Target.Functions.RemoveMoney('bank', amount, 'medical-charge-payment')   

    -- Add money to the issuing doctor's job management fund
    local issuerJobName = Player.PlayerData.job.name
    exports['rsg-bossmenu']:AddMoney(issuerJobName, amount)

    -- Notify the charged player
    TriggerClientEvent('rNotify:NotifyLeft', targetId, "Medical Charge Received", "Amount: $" .. amount .. "\nReason: " .. reason, "generic_textures", "tick", 4000)
    
    -- Notify the officer/doctor who issued the charge
    TriggerClientEvent('RSGCore:Notify', src, 'Charge of $' .. amount .. ' issued successfully! Added to ' .. issuerJobName .. ' management funds.', 'success')

    -- Log the charge
    TriggerEvent('rsg-log:server:CreateLog', 'charges', 'Charge Issued', 'red', 
        Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. 
        ' issued a charge of $' .. amount .. 
        ' to ' .. Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname .. 
        ' for: ' .. reason .. 
        ' (Added to ' .. issuerJobName .. ' management funds)'
    )
end)