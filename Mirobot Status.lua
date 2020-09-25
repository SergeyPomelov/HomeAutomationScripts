local function forced(domoticz)
    local minutesAgo = domoticz.devices('Last Clean').lastUpdate.minutesAgo
    return minutesAgo <= 7
end


local function needSend(domoticz)
    local minutesDead = domoticz.devices('Last Clean').lastUpdate.minutesAgo
    return domoticz.devices('Mi Robot Status').state == 'Off' 
    and minutesDead >= 15 * 60
    and minutesDead <= 15 * 60 + 3
end


local function mysplit(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
    end
    return t
end



return {
	on = {
		timer = { 'every minute' }
	},
	logging = {
        level = domoticz.LOG_FORCE,
        marker = "Mirobot Status"
    },
	execute = function(domoticz, timer)
	    
        domoticz.helpers.cmdDetached('mirobo --ip IP --token TOKEN',
                'mirobotStatus', 'mirobotStatus.txt')
        local result = domoticz.helpers.readLocalFile('mirobotStatus.txt')
        
        domoticz.log("Mirobot Status: "..result, LOG_DEBUG)
        
        if (needSend(domoticz))  then
            domoticz.helpers.pushB("Mi Robot.", "Mi Robot Offline.", "IDEN")
            domoticz.log("Mirobot Status: offline.", LOG_ERROR)
        end
        
        if (result == nil)  then
            domoticz.log("No file.", LOG_ERROR)
            return
        end
        
        if (domoticz.devices('Mi Robot Status').state ~= 'Off' and string.find(result, "Unable")) then
            domoticz.devices('Mi Robot Status').switchSelector(0)
            return
        end
        
        local splitedResult = mysplit(result, "\n")
        
        --Status
        if(splitedResult[1] ~= nil) then
            local status = string.gsub(splitedResult[1], "State: ", "")
            local statusDevice = domoticz.devices('Mi Robot Status')
                  
            domoticz.log("status  "..tostring(status).." statusDevice.state "..statusDevice.state, LOG_DEBUG)
            
            if (status == "Charging" and statusDevice.state ~= 'Home') then
                domoticz.log("Mirobot State 2: "..status.." otherdevices_svalues['Mi Robot Status']: "..statusDevice.state, LOG_FORCE)
                if (not forced(domoticz)) then
                    if (statusDevice.state == "Clean" or statusDevice.state == "Returning") then
                        domoticz.log("Mirobot Status: cleaning finished, docked.", LOG_FORCE)
                        domoticz.helpers.pushB("Mi Robot.", "Cleaning ended, docked.")
                    end
                    statusDevice.switchSelector(30)
                end
            elseif status == "Cleaning" and statusDevice.state ~= 'Cleaning' then statusDevice.switchSelector(10)
            elseif status == "Paused" and statusDevice.state ~= 'Pause' then statusDevice.switchSelector(20)
            elseif status == "Spot cleaning" and statusDevice.state ~= 'Spot' then statusDevice.switchSelector(40)
            elseif status == "Returning home" and statusDevice.state ~= 'Returning' then  statusDevice.switchSelector(50)
            elseif status == "Charger disconnected" and statusDevice.state ~= 'Charger disconnected' then statusDevice.switchSelector(60)
            elseif status == "Idle" and statusDevice.state ~= 'Idle' then statusDevice.switchSelector(70)
            end   
            
        end
        
        -- Battery
        if(splitedResult[2] ~= nil) then
            local battery= string.gsub(string.gsub(splitedResult[2], "Battery: ", ""), " %%", "") 
            domoticz.devices('Mi Robot Battery').update(0, battery)
        end
            
        --Fanspeed  
        if(splitedResult[3] ~= nil) then
            local fanspeed = string.gsub(string.gsub(splitedResult[3], "Fanspeed: ", ""), " %%", "") + 0
            local fanspeedDevice = domoticz.devices('Mi Robot Fanspeed Control')
            
            domoticz.log("fanspeed  "..tostring(fanspeed).." fanspeedDevice.state "..fanspeedDevice.state, LOG_DEBUG)
            
            if     fanspeed <= 40  and fanspeedDevice.state ~= "Quiet"                      then fanspeedDevice.switchSelector(10).silent()
            elseif fanspeed <= 65  and fanspeed > 40 and fanspeedDevice.state ~= "Balanced" then fanspeedDevice.switchSelector(20).silent()
            elseif fanspeed <= 80  and fanspeed > 65 and fanspeedDevice.state ~= "Turbo"    then fanspeedDevice.switchSelector(30).silent()
            elseif fanspeed <= 100 and fanspeed > 80 and fanspeedDevice.state ~= "Max"      then fanspeedDevice.switchSelector(40).silent()
            end
        end
	end
}
