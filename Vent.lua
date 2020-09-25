local function isAllowed(domoticz)
    
    local time = os.date("*t")
    local lux = domoticz.devices('Xiaomi Gateway Lux').lux
    local windowsOpen = domoticz.devices('Xiaomi Door Sensor').active
    
    return (time.hour >= 11)
        and (time.hour <= 21)
        and windowsOpen
        and lux >= 800
end

return {
	on = {
		timer = { 'every minute' } 
	},
	logging = {
        level = domoticz.LOG_FORCE,
        marker = "Vent"
    },
	execute = function(domoticz, timer)
	    
		if (not domoticz.devices('Vent Automation').active) then
            return
        end
        
        local outsideTemp = domoticz.devices('Xiaomi Temperature 2').temperature
        local roomTemp = domoticz.devices('Xiaomi Temperature').temperature
        local temperatureSetPoint = domoticz.devices('Temperature Set').setPoint
        
        local outsideCorrection = 0;
        if (outsideTemp > 25) then
            outsideCorrection = -0.5;
        elseif (outsideTemp > 20) then
            outsideCorrection = 0.5;
        elseif (outsideTemp > 15) then
            outsideCorrection = 1.0;
         elseif (outsideTemp > 10) then
            outsideCorrection = 1.5;
        end
        
        local tempDeviation = 0.3
        local dayMaxTemp = temperatureSetPoint + outsideCorrection + tempDeviation
        local dayMinTemp = temperatureSetPoint + outsideCorrection - tempDeviation
            
        local roomTempHigh = roomTemp >= dayMaxTemp
        local outdorTempLower = roomTemp >= (outsideTemp + 2)
        local tempHigh = roomTempHigh and outdorTempLower
        local tempLow = roomTemp <= dayMinTemp
        
        local plug = domoticz.devices('SP1 Plug 2')
        local CO2 = tonumber(domoticz.devices('CO2').state)
        local CO2high = CO2 > 800
        local CO2low = CO2 < 600
        
        domoticz.log('Vent, temp '..roomTemp..' C, CO2 '..CO2..' ppm.', domoticz.LOG_DEBUG)
        
                
        if (isAllowed(domoticz)
            and (CO2high or tempHigh)
            and domoticz.devices('State').state == 'Home'
            and not plug.active) then
            
            plug.switchOn()
            domoticz.log('Vent on, temp '..roomTemp..' C, CO2 '..CO2..' ppm, min '..dayMinTemp..'C max '..dayMaxTemp..'C.', domoticz.LOG_FORCE)
        end


        if ((not isAllowed(domoticz) or (CO2low and tempLow))
            and plug.active) then
            
            plug.switchOff()
            domoticz.log('Vent off, temp '..roomTemp..' C, CO2 '..CO2..' ppm, min '..dayMinTemp..'C max '..dayMaxTemp..'C.', domoticz.LOG_FORCE)
        end
    end
}