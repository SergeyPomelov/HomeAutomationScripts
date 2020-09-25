return {
	on = {
		devices = { 'Xiaomi Wall Switch 2' }
	},
	logging = {
        level = domoticz.LOG_FORCE,
        marker = "Wall Switch"
    },
	execute = function(domoticz, device)
	    domoticz.log('Xiaomi Wall Switch 2 start', domoticz.LOG_DEBUG)
	    domoticz.scenes('Away').switchOn()
	    domoticz.log('Xiaomi Wall Switch 2 end', domoticz.LOG_DEBUG)
	end
}
