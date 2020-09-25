return {
	on = {
		timer = { 'every minute' } 
	},
	logging = {
        level = domoticz.LOG_FORCE,
        marker = "Humidity Room"
    },
	execute = function(domoticz, timer)

		if (not domoticz.devices('Humidity Automation').active) then return end
		
		local humiditySetPoint = 40
	    	    
	    local time = os.date("*t")
        local plug = domoticz.devices('SP1 Plug 1')
        local lux = domoticz.devices('Xiaomi Gateway Lux').lux
        local humidity = domoticz.devices('Xiaomi Humidity').humidity
        local isAway = domoticz.devices('State').state == 'Away'
        local isSleep = domoticz.devices('State').state == 'Sleep' or lux < 350 
            or time.hour > 22 or time.hour < 11
        
        local deviation = 3
        local awayDelta = 10
        local homeMax = humiditySetPoint + deviation
        local awayMax = homeMax - awayDelta
        local homeMin = humiditySetPoint - deviation
        local awayMin = homeMin - awayDelta
        
        local max = homeMax
        local min = homeMin
        if (isAway) then
            max = awayMax 
            min = awayMin
        end

        if (not isSleep and (humidity < min) and not plug.active) then
            plug.switchOn()
            domoticz.log('Humidifier on, humidity '..humidity..' %.', domoticz.LOG_FORCE)
        end

        if ((isSleep or (humidity > max)) and plug.active) then
            plug.switchOff()
            domoticz.log('Humidifier off, humidity '..humidity..' %.', domoticz.LOG_FORCE)
        end
    end
}
