return {
	on = {
		devices = {	'Xiaomi Cube' }
	},
	logging = {
        level = domoticz.LOG_FORCE,
        marker = "Cube Control"
    },
	execute = function(domoticz, device)
        
	    if (device.level == 10) then -- flip 90 lamp
	        domoticz.devices('Xiaomi Smart Plug 2').toggleSwitch()
        end

        if (device.level == 20) then -- flip 180 heater
	        domoticz.devices('SP1 Plug 3').toggleSwitch()
        end
        
        if (device.level == 40) then -- tap twice upper light
            domoticz.devices('Xiaomi Wall Switch 1').toggleSwitch()
        end
        
        if (device.level == 50) then -- shake air sleep
            domoticz.scenes('Sleep').switchOn()
        end
        
        if (device.level == 80) then -- free fall vent
	        domoticz.sdevices('SP1 Plug 2').switchOn()
        end
	end
}