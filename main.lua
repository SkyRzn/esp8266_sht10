require "sht1x"


function sendData(data)
	local cu = net.createConnection(net.UDP)
	cu:on("receive", function(cu, c) print(c) end)
	cu:connect(8266, "192.168.0.66")
	str = string.format("%d:%d", data[1], data[2])
	cu:send(str)
     cu:close()
end

for i = 1, 1 do
	data = readRawData()
	print(data[1], data[2])
	sendData(data)
	--tmr.delay(10000000)
end
