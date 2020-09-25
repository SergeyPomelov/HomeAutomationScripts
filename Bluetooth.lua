local function check(domoticz, result, mac, device)
    if string.find(result, mac) then
	    domoticz.devices(device).switchOn().checkFirst() 
    else 
        domoticz.devices(device).switchOff().checkFirst() 
    end 
end

return {
	on = {
		timer = { 'every minute' } 
	},
	logging = {
        level = domoticz.LOG_FORCE,
        marker = "Bluetooth"
    },
	execute = function(domoticz, timer)
	    domoticz.helpers.cmdDetached('btdiscovery -i45', 'btdiscovery', 'btdiscovery.txt')
	    local result = domoticz.helpers.readLocalFile('btdiscovery.txt')

        if (result == nil)  then
            domoticz.log("No file.", LOG_ERROR)
        end
    
        check(domoticz, result, "MAC1", 'Device1')
        check(domoticz, result, "MAC2", 'Device2')
        check(domoticz, result, "MAC3", 'Device3')
	end
}