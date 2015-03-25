#!/usr/bin/python


import socket, time


addr = ('192.168.0.115', 8266)

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(addr)

DEEP_SLEEP_TIME = 60
MAX_CONNECTION_ATTEMPTS = 20


cnt = 0
while True:
	s, addr = sock.recvfrom(1024)

	data = s.split(',')
	if len(data) != 7:
		print 'Incorrect data: "%s"' % (s)
		continue

	temp, hum, btemp, battery, ds_time, max_conn, conn_time = data
	if not temp:
		temp = -666
	if not hum:
		hum = -666
	if not btemp:
		btemp = -666
	temp, hum, btemp = float(temp), float(hum), float(btemp)
	battery, ds_time, max_conn, conn_time = int(battery), int(ds_time), int(max_conn), int(conn_time)

	print '%d) %s T=%.2f, H=%.2f%%, BT=%.2f (bat=%d, ds=%d, mc=%d, ct=%d)' % (cnt, time.strftime("%H:%M:%S"), temp, hum, btemp, battery, ds_time, max_conn, conn_time)

	#if ds_time != DEEP_SLEEP_TIME or max_conn != MAX_CONNECTION_ATTEMPTS:
		#sock.sendto('%d,%d' % (DEEP_SLEEP_TIME, MAX_CONNECTION_ATTEMPTS), addr)
		#print '\tSent new settings: ds=%d, mc=%d' % (DEEP_SLEEP_TIME, MAX_CONNECTION_ATTEMPTS)

	cnt += 1


