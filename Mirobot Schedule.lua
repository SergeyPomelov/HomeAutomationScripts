local function shoudStartLoudCleaning(domoticz)
    time = os.date("*t")
    lastClean = domoticz.devices('Last Clean')
    return (time.hour >= 13) and (time.hour <= 21)
    and domoticz.devices('State').state == 'Away' 
    and not domoticz.helpers.forcedState(domoticz)
    and lastClean.lastUpdate.hoursAgo > 12
end

local function shoudStartSilentCleaning(domoticz)
    time = os.date("*t")
    lastClean = domoticz.devices('Last Clean')
    return (time.hour >= 14) and (time.hour <= 20)
    and lastClean.lastUpdate.hoursAgo > 72
end


return {
	on = {
		timer = { 'every minute' } 
	},
	logging = {
        level = domoticz.LOG_FORCE,
        marker = "Mirobot Schedule"
    },
	execute = function(domoticz, device)
	    
        if(domoticz.devices('Mi Robot Automation').state == 'Off') then return end 
    
        local status = domoticz.devices('Mi Robot Status').state
        local battery = tonumber(domoticz.devices('Mi Robot Battery').state)
        local miRobotFanspeedControl = domoticz.devices('Mi Robot Fanspeed Control')
        local shoudStartLoudCleaning = shoudStartLoudCleaning(domoticz)
        local shoudStartSilentCleaning = shoudStartSilentCleaning(domoticz)
        
        domoticz.log("Mirobot Schedule: status: "..tostring(status).." battery: "..tostring(battery).." shoudStartLoudCleaning: "..tostring(shoudStartLoudCleaning)..
            " shoudStartSilentCleaning: "..tostring(shoudStartSilentCleaning).." forcedState(): "..tostring(domoticz.helpers.forcedState(domoticz)), domoticz.LOG_DEBUG)
        
        if(status  == 'Home' and battery~=nill and battery > 90 and shoudStartLoudCleaning) then
            domoticz.log("Mirobot Schedule: start cleaning.", domoticz.LOG_FORCE)
            domoticz.devices('Mi Robot Status Control').switchSelector(10)
            miRobotFanspeedControl.switchSelector(30)
        end  
            
        if(status  == 'Home' and battery~=nill and battery > 70 and not shoudStartLoudCleaning and shoudStartSilentCleaning) then
            domoticz.log("Mirobot Schedule: start forced cleaning.", domoticz.LOG_FORCE)
            domoticz.devices('Mi Robot Status Control').switchSelector(10)
            miRobotFanspeedControl.switchSelector(20)
        end 
	end
}