pin = 3
m=0
function getTemp()
status,temp,humi,temp_decimial,humi_decimial = dht.read(pin)
if( status == dht.OK ) then
  -- Float firmware using this example
  print(string.format("DHT Temperature:%d.%02d;Humidity:%d.%02d\r\n",temp,temp_decimial,humi,humi_decimial))
  if (temp >25) then
    print ("ALERT: Temperature is out of range")
        if m == 1 then
            conn=net.createConnection(net.TCP, 0)  
            conn:on("receive", function(conn, payload) print(payload)  end) 
            conn:connect(80,"50.116.34.97")  
            conn:send("GET /publicapi/notify?apikey=YOUR_KEY&application=ESP8266&event=TEMP_ALERT&description=Temperature%20is%20more%20than%2025&priority=2\r\n HTTP/1.1\r\n") 
            conn:send("Host: notifymyandroid.com\r\n")  
            conn:send("Accept: */*\r\n") 
            conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n") 
            conn:send("\r\n")
            m = 0
        else m = 1
        end    
  end        
elseif( status == dht.ERROR_CHECKSUM ) then
  print( "DHT Checksum error." );
elseif( status == dht.ERROR_TIMEOUT ) then
  print( "DHT Time out." );
end
end

--- Get temperature and humidity data and send data to thingspeak.com
function sendData()
getTemp()
-- conection to thingspeak.com
print("Sending data to thingspeak.com")
conn=net.createConnection(net.TCP, 0) 
conn:on("receive", function(conn, payload) print(payload) end)
-- api.thingspeak.com 184.106.153.149
conn:connect(80,'184.106.153.149') 
conn:send("GET /update?key=YOUR_KEY&field1="..temp.."&field2="..humi.." HTTP/1.1\r\n") 
conn:send("Host: api.thingspeak.com\r\n") 
conn:send("Accept: */*\r\n") 
conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
conn:send("\r\n")
conn:on("sent",function(conn)
                      print("Closing connection")
                      conn:close()
                  end)
conn:on("disconnection", function(conn)
                      print("Got disconnection...")
  end)
end
-- send data every X ms to thing speak
tmr.alarm(2, 60000, 1, function() sendData() end )