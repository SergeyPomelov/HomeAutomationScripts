return {
    on = {
        devices = {
            'Node Mcu Lamp Control'
        }
    },
	logging = {
        level = domoticz.LOG_FORCE,
        marker = "Node Mcu Lamp Control"
    },
    execute = function(domoticz, device)
        
        local on = device.state == 'On'

        if (on) then
            domoticz.helpers.lampCmd("P_ON")
        else 
            domoticz.helpers.lampCmd("P_OFF")
        end
    end
}