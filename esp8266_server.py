#!/usr/bin/python


import socket, time


def calcData(data):
	D1 = -39.7  # for 14 Bit @ 3.3V
	D2 =  0.01 # for 14 Bit DEGC

	C1 = -2.0468       # for 12 Bit
	C2 =  0.0367       # for 12 Bit
	C3 = -0.0000015955 # for 12 Bit
	T1 =  0.01      # for 14 Bit @ 3.3V
	T2 =  0.00008   # for 14 Bit @ 3.3V

	rawTemp, rawHum = data
	rawTemp = float(rawTemp)
	rawHum = float(rawHum)

	temp = rawTemp * D2 + D1

	linHum = C1 + C2 * rawHum + C3 * rawHum * rawHum
	hum = (temp - 25.0) * (T1 + T2 * rawHum) + linHum

	return (temp, hum)


addr = ('192.168.0.66', 8266)

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(addr)

DEEP_SLEEP_TIME = 3
MAX_CONNECTION_ATTEMPTS = 20


cnt = 0
while True:
	s, addr = sock.recvfrom(1024)

	data = s.split(',')
	if len(data) != 4:
		print 'Incorrect data: "%s"' % (s)
		continue

	temp, hum, ds_time, max_conn = data
	temp, hum = calcData((temp, hum))
	ds_time, max_conn = int(ds_time), int(max_conn)

	print '%d) %s T=%.2f, H=%.2f%% (ds=%d, mc=%d)' % (cnt, time.strftime("%H:%M:%S"), temp, hum, ds_time, max_conn)

	if ds_time != DEEP_SLEEP_TIME or max_conn != MAX_CONNECTION_ATTEMPTS:
		sock.sendto('%d,%d' % (DEEP_SLEEP_TIME, MAX_CONNECTION_ATTEMPTS), addr)
		print '\tSent new settings: ds=%d, mc=%d' % (DEEP_SLEEP_TIME, MAX_CONNECTION_ATTEMPTS)

	cnt += 1


