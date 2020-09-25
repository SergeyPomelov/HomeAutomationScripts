local function cmd(domoticz, command)
    local cmdCommand = 'mirobo --ip IP --token TOKEN '..command
    domoticz.helpers.cmdDetached(cmdCommand, 'Mirobot Command', 'mirobotCommand.txt')
    domoticz.log("Mirobot Control: command: "..command, domoticz.LOG_DEBUG)
end


return {
    on = {
        devices = { 'Mi Robot Status Control', 'Mi Robot Fanspeed Control' }
    },
    logging = {
        level = domoticz.LOG_FORCE,
        marker = "Mirobot Control"
    },
    execute = function(domoticz, device)

        local miRobotStatus = domoticz.devices('Mi Robot Status')
        local miRobotStatusControl = domoticz.devices('Mi Robot Status Control').state
      
        if (miRobotStatus == 'Off') then return end
        
        domoticz.log("Mirobot Control: miRobotStatus: "..miRobotStatus.state.." miRobotStatusControl: "..miRobotStatusControl, domoticz.LOG_DEBUG)
        
        if (device.name == 'Mi Robot Status Control') then
            
        	if     miRobotStatusControl == 'Clean' then cmd(domoticz, "start") miRobotStatus.switchSelector(10) domoticz.devices('Last Clean').update(0,1)
            elseif miRobotStatusControl == 'Pause' then cmd(domoticz, "pause") miRobotStatus.switchSelector(20)
            elseif miRobotStatusControl == 'Home'  then cmd(domoticz, "home")  miRobotStatus.switchSelector(30)
            elseif miRobotStatusControl == 'Spot'  then cmd(domoticz, "spot")  miRobotStatus.switchSelector(40)
            else domoticz.log("Mirobot Control: Not supported control command. "..miRobotFanspeedControl, domoticz.LOG_ERROR)
            end
            
            domoticz.devices('Mi Robot Status Control').switchSelector(0).silent()
        end
 
        if (device.name == 'Mi Robot Fanspeed Control') then
            local miRobotFanspeedControl = domoticz.devices('Mi Robot Fanspeed Control').state
        
        	if     miRobotFanspeedControl == 'Quiet'    then cmd(domoticz, "fanspeed 38")
            elseif miRobotFanspeedControl == 'Balanced' then cmd(domoticz, "fanspeed 60")
            elseif miRobotFanspeedControl == 'Turbo'    then cmd(domoticz, "fanspeed 77")
            elseif miRobotFanspeedControl == 'Max'      then cmd(domoticz, "fanspeed 90")
            else domoticz.log("Mirobot Control: Not supported fan command. "..miRobotFanspeedControl, domoticz.LOG_ERROR)
            end
        end
    end
}