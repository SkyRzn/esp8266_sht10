local server_ip = "192.168.0.147"
local server_port = 8266

local conn = net.createConnection(net.UDP)
conn:connect(server_port, server_ip)
conn:send(temp..","..hum..","..btemp..","..battery..","..deep_sleep_time..","..max_connection_attempts..","..run_cnt)
conn:close()
conn = nil
