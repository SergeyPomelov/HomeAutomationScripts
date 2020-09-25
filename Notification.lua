local function canNotify(domoticz, storedTimeData, minutes)
    local Time  = require('Time')
    local currentTime = Time(domoticz.time.raw)
    local storedTime  = storedTimeData
    local deltaMinutes  = domoticz.utils.round(currentTime.compare(storedTime).secs / 60, 2) 
    return deltaMinutes > minutes
end

return {
	on = {
		timer = { 'every minute' } 
	},
	data = {
        previousCPUUsage = { initial = 0 },
        prePreviousCPUUsage = { initial = 0 },
        lastNotificztionCPU = { initial = "1970-1-1 1:1:1.1"  },
        lastNotificztionBattery = { initial = "1970-1-1 1:1:1.1"  }
    },
	logging = {
        level = domoticz.LOG_FORCE,
        marker = "Notification"
    },
	execute = function(domoticz, device)
	    
	    local Time  = require('Time')
	    local percipationChance = domoticz.devices('Percipation Chance').percentage
	    local windSpeed = domoticz.devices('Wind').speed
	    local iSpy = domoticz.devices('iSpy')
	    local weatherUpdatedMin = domoticz.devices('Weather').lastUpdate.minutesAgo
	    local xiaomyHumidity = domoticz.devices('Xiaomi Humidity').humidity
	    local xiaomyTemperature = domoticz.devices('Xiaomi Temperature').temperature
	    local weatherScriptUpdatedMin = domoticz.devices('Apparent Temperature').lastUpdate.minutesAgo
	    local apparentTemperature = domoticz.devices('Apparent Temperature').temperature
	    local ozone = domoticz.devices('Ozone').nValue
	    local cpu = domoticz.devices('CPU Total')
	    local lux = domoticz.devices('Xiaomi Gateway Lux').lux
	    local light = domoticz.devices('Xiaomi Wall Switch 1')
	    local lamp = domoticz.devices('Xiaomi Smart Plug 2')
	    local battery = domoticz.devices('Server Battery')
	    
	    
        local handle = io.popen('WMIC PATH Win32_Battery Get EstimatedChargeRemaining /value')
        local newPercentage = tonumber(string.match(handle:read("*a"), "%d+"))
        handle:close()
        
        battery.updatePercentage(newPercentage)

	    if (cpu.percentage > 95 and domoticz.data.previousCPUUsage > 95 and domoticz.data.prePreviousCPUUsage > 95 and canNotify(domoticz, Time(domoticz.data.lastNotificztionCPU), 15)) then
	        domoticz.helpers.pushB("Server.", "CPU usage is high.", "IDEN_1")
	        domoticz.utils.osExecute('start "cpuDump" cmd /c powershell.exe  -noprofile -executionpolicy bypass -file "/scripts/cpuDump.ps1" ^> "C:\\Share\\Drive\\Logs\\cpuDump.txt"')
	        domoticz.data.lastNotificztionCPU = domoticz.time.raw 
	        domoticz.log("CPU usage is high.", domoticz.LOG_ERROR)
	    end    
	    
	    if (battery.percentage < 80 and canNotify(domoticz, Time(domoticz.data.lastNotificztionBattery),  5)) then
	        domoticz.helpers.pushB("Server.", "Server is on Battery.", "IDEN_1")
	        domoticz.lastNotificztionBattery = domoticz.time.raw 
	        domoticz.log("Sever is on Battery.", domoticz.LOG_ERROR)
	    end 

        domoticz.data.prePreviousCPUUsage = domoticz.data.previousCPUUsage
	    domoticz.data.previousCPUUsage = cpu.percentage
	end
}