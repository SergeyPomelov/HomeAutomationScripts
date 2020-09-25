return {
	on = {
		timer = { 'every minute' }
	},
	logging = {
	    -- level = domoticz.LOG_DEBUG,
        level = domoticz.LOG_FORCE,
        marker = "Air Status"
    },
	execute = function(domoticz, timer)
	    
        domoticz.helpers.cmdDetached('py -3 "/scripts/air.py"', 'airStatus', 'airStatus.json')
        local result = domoticz.helpers.readLocalFile('airStatus.json')
        
        if (result == nil)  then
            domoticz.log("No file.", LOG_ERROR)
            return
        end
               
        domoticz.log("raw: "..result, LOG_DEBUG)
        
        local jsonValeur = domoticz.utils.fromJSON(result)
        if (jsonValeur == nil)  then
            domoticz.log("No valid json.", LOG_ERROR)
            return
        end
        
        local battery = jsonValeur.battery
        local temperature = jsonValeur.temperature
        local humidity = jsonValeur.humidity
        local co2 = jsonValeur.co2
        local pm25 = jsonValeur.pm25
        local tvoc = jsonValeur.tvoc
        
        if domoticz.devices('CO2').svalues ~= co2 then domoticz.devices('CO2').update(0, co2) end
        if domoticz.devices('PM25').svalues ~= pm25 then domoticz.devices('PM25').update(0, pm25) end
        if domoticz.devices('TVOC').svalues ~= tvoc then domoticz.devices('TVOC').update(0, tvoc) end
	end
}
