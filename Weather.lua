return {
	on = {
		timer = { 'every 2 minutes' },
        httpResponses = { 'response' }
    },
    logging = {
        level = domoticz.LOG_FORCE,
        marker = "Weather"
    },
	execute = function(domoticz, item)

        if (item.isTimer) then
            local api_key = "API_KEY"
            local coord = "LON,LAT"
            domoticz.openURL({
                url = 'https://api.darksky.net/forecast/'..api_key..'/'..coord..'?lang=en&units=si',
                method = 'GET',
                callback = 'response'
            })
        
        elseif (item.isHTTPResponse) then
            
            if (item.ok) then
                
                local jsonValeur = item.json

                local val_app_temp = jsonValeur.currently.apparentTemperature
                local val_Cloud= jsonValeur.currently.cloudCover*100
                local val_PercipationChance = jsonValeur.currently.precipProbability*100
                local val_CurrentWeatherHours = jsonValeur.hourly.data[1].summary.." - "..jsonValeur.hourly.data[2].summary.." - "..jsonValeur.hourly.data[3].summary
                local val_CurrentWeather = jsonValeur.daily.data[1].summary
                local summary = jsonValeur.daily.data[2].summary
                local forecast = "<b>Now</b>: "..val_CurrentWeatherHours.."<br> <b>Today</b>: "..val_CurrentWeather
                
                local time = os.date("*t")
                local isTime = time.hour >= 9 and time.hour <= 20
                
                if (isTime 
                    and domoticz.devices('Last Forecast Send').lastUpdate.minutesAgo > tonumber(domoticz.devices('Last Forecast Send').text)
                    and string.match(val_CurrentWeatherHours, "Rain")) then
                        
                    domoticz.devices('Last Forecast Send').update(0, 150)
                    local message = "Rain Forecast. 3h forecast: ".. val_CurrentWeatherHours
                    
                    domoticz.helpers.pushB("Weather Forecast", val_CurrentWeatherHours)
                    domoticz.log(message, domoticz.LOG_DEBUG)
                    domoticz.log('Weather is sending '..val_CurrentWeatherHours, domoticz.LOG_DEBUG)
                end
             
        		if domoticz.devices('Forecast').svalues ~= forecast then domoticz.devices('Forecast').update(0, forecast) end
                if domoticz.devices('Clouds').svalues ~= val_Cloud then domoticz.devices('Clouds').update(0, val_Cloud) end
                if domoticz.devices('Apparent Temperature').svalues ~= val_app_temp then domoticz.devices('Apparent Temperature').update(0, val_app_temp) end
                if domoticz.devices('Percipation Chance').svalues ~= val_PercipationChance then domoticz.devices('Percipation Chance').update(0, val_PercipationChance) end
                if domoticz.devices('Current Weather').svalues ~= val_CurrentWeather then domoticz.devices('Current Weather').update(0, val_CurrentWeather) end
                if domoticz.devices('Current Weather Hours').svalues ~= val_CurrentWeatherHours then  domoticz.devices('Current Weather Hours').update(0, val_CurrentWeatherHours) end
            end
        end
		
		domoticz.log('Weather is working ' .. item.trigger, domoticz.LOG_DEBUG)
	end
}
