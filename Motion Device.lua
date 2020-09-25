local function updateWakeThreshold(domoticz, value)
    if domoticz.devices('Wake Threshold').text ~= tostring(value) then domoticz.devices('Wake Threshold').updateText(tostring(value)) end
end


local function allowedToAwake()
    time = os.date("*t")
    return (time.hour >= 9) and (time.hour <= 12)
end


local function wakeThreshold(domoticz)
    newThreshold = tonumber(domoticz.devices('Wake Threshold').text) + 1
    updateWakeThreshold(domoticz, newThreshold)
    reached = newThreshold >= 3
    if reached then
        updateWakeThreshold(domoticz, 0)
        return true 
    end   
    return false
end


local function nightLightMakesSense(domoticz)
    lux = domoticz.devices('Xiaomi Gateway Lux').lux
    return lux <= 350 and not domoticz.devices('Xiaomy Gateway Brightness').active
end



return {
	on = {
		devices = { 'Aqara Motion Sensor' }
	},
	logging = {
        level = domoticz.LOG_FORCE,
        marker = "Motion Device"
    },
	execute = function(domoticz, device)
	    
	
	    if (device.active)
	    then
            if (domoticz.devices('State').state == 'Away' and not domoticz.helpers.forcedState(domoticz))
	        then 
	            domoticz.log("Home because motion.", domoticz.LOG_FORCE)
	            domoticz.scenes('Home').switchOn() 
	            domoticz.helpers.sendSms(domoticz, 'Motion')
	            domoticz.devices('Cam Shot').switchOn().afterSec(2)
	  	    end
	    
	        if (domoticz.devices('State').state == 'Sleep' and nightLightMakesSense(domoticz))
	        then 
	            domoticz.log("Night light.", domoticz.LOG_FORCE)
	            
	            domoticz.devices('Xiaomy Gateway Color').cancelQueuedCommands()  
	            domoticz.devices('Xiaomy Gateway Brightness').cancelQueuedCommands()  
	            domoticz.devices('Xiaomi RGB Gateway').cancelQueuedCommands()  
	            
	            domoticz.devices('Xiaomy Gateway Color').switchSelector(20)
	            domoticz.devices('Xiaomy Gateway Brightness').switchSelector(20)
	            domoticz.devices('Xiaomy Gateway Color').switchOff().silent().afterSec(120)
	            domoticz.devices('Xiaomy Gateway Brightness').switchOff().silent().afterSec(120)
	            domoticz.devices('Xiaomi RGB Gateway').switchOff().afterSec(120)
	        end
	    
	        if (domoticz.devices('State').state == 'Sleep' and allowedToAwake() and not domoticz.helpers.forcedState(domoticz) and wakeThreshold(domoticz))
            then 
                domoticz.log("Wakeup because motion.", domoticz.LOG_FORCE)
                domoticz.scenes('Home').switchOn() 
            end
        end
    	    
	    
        if (not device.active) then updateWakeThreshold(domoticz, 0) end
	end
}