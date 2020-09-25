local function execute(domoticz, on, id)
    if (on) then domoticz.helpers.cmdDetached('python "/scripts/sp1.py" '..id..' On', 'sp1Control', 'sp1Control.json')
    else domoticz.helpers.cmdDetached('python "/scripts/sp1.py" '..id..' Off', 'sp1Control', 'sp1Control.json')
    end
end

return {
    on = {
        devices = {
            'SP1 Plug 1',
            'SP1 Plug 2',
            'SP1 Plug 3',
            'SP1 Plug 4',
            'SP1 All'
        }
    },
	logging = {
	    -- level = domoticz.LOG_DEBUG,
        level = domoticz.LOG_FORCE,
        marker = "SP1 Control"
    },
    execute = function(domoticz, device)
        
        local on = device.state == 'On'
        
        if (device.name == 'SP1 Plug 1') then
            execute(domoticz, on, '1')
        elseif (device.name == 'SP1 Plug 2') then
            execute(domoticz, on, '2')
        elseif (device.name == 'SP1 Plug 3') then
            execute(domoticz, on, '3')
        elseif (device.name == 'SP1 Plug 4') then
            execute(domoticz, on, '4')
        elseif (device.name == 'SP1 All') then
            if (not on) then 
                domoticz.helpers.cmdDetached('python "/scripts/sp1Off.py"', 'sp1Control', 'sp1Control.json')
                domoticz.devices('SP1 Plug 1').switchOff().silent().checkFirst()
                domoticz.devices('SP1 Plug 2').switchOff().silent().checkFirst()
                domoticz.devices('SP1 Plug 3').switchOff().silent().checkFirst()
                domoticz.devices('SP1 Plug 4').switchOff().silent().checkFirst()
            end
        end
    end
}