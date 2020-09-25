return {
	on = {
		timer = { 'every minute' } 
	},
	logging = {
        level = domoticz.LOG_FORCE,
        marker = "Heating"
    },
	execute = function(domoticz, timer)
	    
		if (not domoticz.devices('Heating Automation').active) then return end
    
		local temp = domoticz.devices('Xiaomi Temperature').temperature
        local outsideTemp = domoticz.devices('Weather').temperature

        local time = os.date("*t")
        local plug = domoticz.devices('SP1 Plug 3')
        local isDay = time.hour >= 10 and time.hour <= 21
        local isNight = not isDay
        local temperatureSetPoint = domoticz.devices('Temperature Set').setPoint
        
        local outsideCorrection = 0;
        if (outsideTemp > 25) then
            outsideCorrection = -1.2;
        elseif (outsideTemp > 20) then
            outsideCorrection = -0.8;
        elseif (outsideTemp > 15) then
            outsideCorrection = -0.5;
        elseif (outsideTemp > 10) then
            outsideCorrection = -0.2;
        end

        local tempDeviation = 0.2
        local nightDelta = 1.5
        local dayMaxTemp = temperatureSetPoint + outsideCorrection + tempDeviation
        local nightMaxTemp = dayMaxTemp - nightDelta
        local dayMinTemp = temperatureSetPoint + outsideCorrection - tempDeviation
        local nightMinTemp = dayMinTemp - nightDelta
        
        local maxTemp = dayMaxTemp
        local minTemp = dayMinTemp
        if (isNight) then
            maxTemp = nightMaxTemp 
            minTemp = nightMinTemp
        end

        if (((domoticz.devices('State').state == 'Home') or (domoticz.devices('State').state == 'Sleep'))
            and (temp < minTemp) and not plug.active) then

            domoticz.log('plug.active'..tostring(plug.active), domoticz.LOG_DEBUG)
            plug.switchOn().checkFirst()
            domoticz.log('Heating on, temp '..temp..' C, min '..minTemp..'С max '..maxTemp..'С.', domoticz.LOG_FORCE)
        end

        if ((temp > maxTemp) and plug.active) then
            
            domoticz.log('plug.active'..tostring(plug.active), domoticz.LOG_DEBUG)
            plug.switchOff().checkFirst()
            domoticz.log('Heating off, temp '..temp..' C, min '..minTemp..'С max '..maxTemp..'С.', domoticz.LOG_FORCE)
        end
	end
}