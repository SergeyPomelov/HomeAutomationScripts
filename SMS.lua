local function notify(domoticz, message) 
	domoticz.helpers.sendSms(domoticz, message)
    domoticz.helpers.pushB("Critical Alert!", message, "IDEN_1")
	domoticz.devices('Cam Shot').switchOn().repeatAfterSec(60, 3)
    domoticz.log(message, domoticz.LOG_ERROR)
end

return {
	on = {
		devices = {
			'Xiaomi Temperature',
			'Xiaomi Smart Plug Usage',
			'Xiaomi Smart Plug 2 Usage',
			'Xiaomi Water Leak Detector'
		}
	},
	logging = {
        level = domoticz.LOG_WARN,
        marker = "SMS"
    },
	execute = function(domoticz, device)
	    
	    if (device.name == 'Xiaomi Temperature' and device.temperature >= 35) then
	        notify(domoticz, 'Room temp '..device.temperature)
	        domoticz.scenes('Sleep').switchOn()
        end
        
        if (device.name == 'Xiaomi Smart Plug Usage' and device.WhActual >= 1500) then
            notify(domoticz, 'Plug Usage '..device.WhActual)
            domoticz.devices('Xiaomi Smart Plug').switchOff()
        end

        if (device.name == 'Xiaomi Smart Plug 2 Usage' and device.WhActual >= 1500) then
            notify(domoticz, 'Plug2 Usage '..device.WhActual)
            domoticz.devices('Xiaomi Smart Plug 2').switchOff()
        end
        
        if (device.name == 'Xiaomi Water Leak Detector') then
            notify(domoticz, 'Water Leak '..tostring(device.active))
        end
	end
}