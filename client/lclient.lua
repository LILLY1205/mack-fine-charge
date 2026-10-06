-- client.lua
local RSGCore = exports['rsg-core']:GetCoreObject()

-- New event to show fine inputs
RegisterNetEvent('rsg-fines:client:ShowFineInputs', function()
    local dialog = exports['rsg-input']:ShowInput({
        header = "Issue Fine",
        submitText = "Issue Fine",
        inputs = {
            {
                text = "Player ID", 
                name = "targetId", 
                type = "number", 
                isRequired = true
            },
            {
                text = "Amount ($)", 
                name = "amount", 
                type = "number", 
                isRequired = true
            },
            {
                text = "Reason", 
                name = "reason", 
                type = "text", 
                isRequired = true
            }
        }
    })

    if dialog ~= nil then
        -- Validate inputs
        local targetId = tonumber(dialog.targetId)
        local amount = tonumber(dialog.amount)
        local reason = dialog.reason

        if not targetId or not amount or not reason then 
            TriggerEvent('RSGCore:Notify', 'Please fill in all fields correctly', 'error')
            return 
        end

        -- Trigger server event to process the fine
        TriggerServerEvent('rsg-fines:server:IssueFine', targetId, amount, reason)
    end
end)