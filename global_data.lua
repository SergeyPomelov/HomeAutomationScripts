local function readFile(path)
    local file = io.open(path, "rb")
    if not file then return nil end
    local content = file:read "*a" 
    file:close()
    return content:gsub('\r\n', '\n')
end
        
local function cmd(command)
    local f = assert(io.popen(command, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    s = string.gsub(s, '^%s+', '')
    s = string.gsub(s, '%s+$', '')
    s = string.gsub(s, '[\n\r]+', ' ')
    return s
end

return {
    helpers = {
	    
		cmd = function(command)
            return cmd(command)
		end,
		
		cmdDetached = function(command, name, filename)
		    os.execute('start "'..name..'" cmd /c '.. command..' ^> "/scripts/data/"'..filename)
		end,
		
		ping = function(ip, device)
            ping_result = cmd('ping -n 1 -w 1500 '..ip)
        
            if (string.find(ping_result, "TTL", 1, true) ~= nill) then
                device.switchOn().checkFirst()
            else
                device.switchOff().checkFirst()
            end
		end,
		
		forcedState = function(domoticz)
            forcedState = domoticz.devices('Forced State')
            return forcedState.lastUpdate.minutesAgo < tonumber(forcedState.text)
        end,
        
        readFile = function(path)
            return readFile(path)
        end,
        
        readLocalFile = function(name)
            return readFile('/scripts/data/'..name)
        end,
        
        sendSms = function(domoticz, message)
            smsUrl = 'https://sms.ru/sms/send?api_id=ID&to=PHONE&json=1&msg='
            if (domoticz.devices('Send Sms').active) then
	            domoticz.openURL(smsUrl..message:gsub("%s+", "_"))
	        end   
		end,
		
		pushB = function(topic, message, device)
            deviceJson = "";
            if device ~= nill then 
        		deviceJson = '\\"device_iden\\":\\"'..device..'\\",'
            end 
        	json = '{\\"body\\":\\"'..message..'\\",\\"title\\":\\"'..topic..'\\",'..deviceJson..'\\"type\\":\\"note\\",\\"direction\\":\\"outgoing\\"}'
        	curl = 'curl --header "Access-Token: TOKEN" --header "Content-Type: application/json" --data-binary "'
                    ..json..'" --request POST https://api.pushbullet.com/v2/pushes'
        	os.execute(curl)
		end,
		
		lampCmd = function(cmd)
            os.execute('"/scripts/PacketSender/packetsender" -Au IP PORT '..cmd)
		end
	}
}
