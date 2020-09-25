return {
	on = {
	    timer = { 'every minute' },
	},
	logging = {
        level = domoticz.LOG_FORCE,
        marker = "SpeedTest"
    },
	execute = function(domoticz, timer)
                
        if domoticz.time.matchesRule('every 4 hours') then
            domoticz.helpers.cmdDetached("speedtest --json", "speedtest", "speedtest.json")
        end
        
        local json = (loadfile '/scripts/lua\\JSON.lua')()
        local result = domoticz.helpers.readLocalFile('speedtest.json')
        local jsonValeur = json:decode(result)
        
        if (jsonValeur == nil) then 
            return 
        end
        
        local ping  = tonumber(jsonValeur.ping)
        local upload  = tonumber(jsonValeur.upload / 8000000)
        local download = tonumber(jsonValeur.download / 8000000)
                    
        domoticz.log("SpeedTest: ping "..jsonValeur.ping, LOG_DEBUG)
        domoticz.log("SpeedTest: upload "..jsonValeur.upload, LOG_DEBUG)
        domoticz.log("SpeedTest: download "..jsonValeur.download, LOG_DEBUG)
        
        if (ping ~=0 and domoticz.devices('Ping').state ~= ping) then  domoticz.devices('Ping').update(0, ping) end
        if (upload ~= 0 and domoticz.devices('Upload').state ~= upload) then domoticz.devices('Upload').update(0, upload) end
        if (download ~= 0 and domoticz.devices('Download').state ~= download) then domoticz.devices('Download').update(0, download) end
        
    end
}
