local function bright(domoticz, hue, brightness)
    domoticz.openURL('https://localhost:443/json.htm?type=command&param=setcolbrightnessvalue&idx=28&hue='..hue..'&brightness='..brightness..'&iswhite=false')
end

return {
	on = {
		devices = { 'Xiaomy Gateway Color', 'Xiaomy Gateway Brightness' }
	},
	logging = {
        level = domoticz.LOG_FORCE,
        marker = "Light Control"
    },
	execute = function(domoticz, device)

        if (device.name =='Xiaomy Gateway Color') then
            local color = device.state
            local gateway = domoticz.devices('Xiaomi RGB Gateway')
            local brightness = gateway.level
            
            domoticz.log("color "..tostring(color)..' brightness '..tostring(brightness), domoticz.LOG_DEBUG)
            
            if (brightness == nil or brightness <= 0) then 
                brightness = 1
                domoticz.devices('Xiaomy Gateway Brightness').switchSelector(10).silent()
            end
            
	        	if color == 'Red'       then bright(domoticz, 1, brightness)
            elseif color == 'Orange'    then bright(domoticz, 10, brightness)
            elseif color == 'Yellow'    then bright(domoticz, 40, brightness)
            elseif color == 'Lime'      then bright(domoticz, 100, brightness)
            elseif color == 'Green'     then bright(domoticz, 120, brightness)
            elseif color == 'Sky'       then bright(domoticz, 200, brightness)
            elseif color == 'Blue'      then bright(domoticz, 240, brightness)
            elseif color == 'Violet'    then bright(domoticz, 250, brightness)
            elseif color == 'Purple'    then bright(domoticz, 260, brightness)
            elseif color == 'White'     then 
                domoticz.openURL('https://localhost:443/json.htm?type=command&param=switchlight&idx=28&switchcmd=On&level=0')
            end
         end
    
        if (device.name == 'Xiaomy Gateway Brightness') then
    
            domoticz.log("newBrightnes "..tostring(device.levelName:gsub('%%', '')), domoticz.LOG_DEBUG)
    
            local newBrightnessLevel = device.levelName:gsub('%%', '')
            
            domoticz.log("newBrightnes "..tostring(newBrightnessLevel), domoticz.LOG_DEBUG)
    
            if (device.state == 'Off') then 
                domoticz.openURL('https://localhost:443/json.htm?type=command&param=switchlight&idx=28&switchcmd=Off&level=0&passcode=')
            end
    
            if (device.state ~= 'Off') 
            then 
                if (newBrightnessLevel == nil) then 
                    newBrightnessLevel = 1
                    domoticz.devices('Xiaomy Gateway Brightness').switchSelector(10).silent()
                end
    
	            domoticz.openURL('https://localhost:443/json.htm?type=command&param=switchlight&idx=28&switchcmd=Set%20Level&level='..tostring(newBrightnessLevel))
            end
        end
    end
} 