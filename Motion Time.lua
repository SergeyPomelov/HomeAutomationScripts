local function updateWakeThreshold(domoticz, value)
    if domoticz.devices('Wake Threshold').text ~= tostring(value) then domoticz.devices('Wake Threshold').updateText(tostring(value)) end
end


local function allowedToAwake()
    time = os.date("*t")
    allowed = (time.hour >= 9) and (time.hour <= 12)
    return allowed
end


local function allowedToAutoAway(domoticz)
    time = os.date("*t")
    return (time.hour >= 9) and (time.hour <= 21)
    and not domoticz.devices('PERSON_1').active
    and not domoticz.devices('PERSON_2').active
end

local function updatedLongAgo(motion) 
    return motion.lastUpdate.minutesAgo > 30
end


local function wakeThreshold(domoticz, motion, on)
    timeSinceUpdate = motion.lastUpdate.minutesAgo
    if (not on and timeSinceUpdate > 30) then
        updateWakeThreshold(domoticz, 0)
    elseif (on and timeSinceUpdate > 10) then
        return true
    end    
    return false
end


return {
	on = {
		timer = { 'every minute' } 
	},
	logging = {
        level = domoticz.LOG_FORCE,
        marker = "Motion Time"
    },
	execute = function(domoticz, timer)
	    motion = domoticz.devices('Aqara Motion Sensor')
	    on = motion.active 
	    
        if (domoticz.devices('State').state == 'Home' and not on and allowedToAutoAway(domoticz) 
            and updatedLongAgo(motion) and not domoticz.helpers.forcedState(domoticz)) then
            domoticz.log("Away because no motion.", domoticz.LOG_FORCE)
            domoticz.scenes('Away').switchOn() 
        end

        if (domoticz.devices('State').state == 'Sleep' and allowedToAwake() 
            and wakeThreshold(domoticz, motion, on) and not domoticz.helpers.forcedState(domoticz)) then 
            domoticz.log("Wakeup because motion.", domoticz.LOG_FORCE)
            domoticz.scenes('Home').switchOn() 
        end
	end
}