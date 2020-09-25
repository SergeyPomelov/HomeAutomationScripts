return {
	on = {
	    timer = { 'every minute' }
	},
	logging = {
        level = domoticz.LOG_FORCE,
        marker = "Sunrise"
    },
    data = {
        sunriseLevel = { initial = 0 }
    },
    execute = function(domoticz, timer)
       
        local switch = domoticz.devices('Start Sunrise')
        local light = domoticz.devices('YeeLight LED (Stripe)')
        domoticz.data.sunriseLevel = domoticz.data.sunriseLevel + 5
        
        domoticz.log('Tick '..tostring(switch.active).." "..tostring(light.active).." "..tostring(light.level), LOG_DEBUG)
         
        if (switch.active) then
            domoticz.log('brightnes is '..domoticz.data.sunriseLevel, LOG_DEBUG)
            domoticz.data.sunriseLevel = domoticz.data.sunriseLevel + 5
            
            if (not light.active and domoticz.data.sunriseLevel == 0) then
                domoticz.log('Wake UP Light', LOG_FORCE)
                light.switchOn()
            end 
            
            if (domoticz.data.sunriseLevel <= 255) then
                light.setColor(domoticz.data.sunriseLevel, domoticz.data.sunriseLevel / 2, 0)
            elseif (domoticz.data.sunriseLevel <= 500) then
                light.setColor(255, 125 + domoticz.data.sunriseLevel / 4, domoticz.data.sunriseLevel - 255)
            else
                switch.switchOff().checkFirst()
                domoticz.data.sunriseLevel = 0
            end 
        else
            domoticz.data.sunriseLevel = 0
        end
    end
}