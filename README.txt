Name: WiFly WebServer
Author: Luis Pulido

WiFly Webserver is a code for Arduino and the WiFly GSX Breakout
module that makes a simple webserver.

When the Arduino receives a GET HTTP/1.1 request, it sends the
headers and body of the request.

In this case, it reads the accelerometer and prints the data as 
a JSON object.

It can print out whatever you want.

This code is in an alpha version so if you want to fork it and 
improve it we will be more than pleased to have your share.

The libraries included in the libraries folder are needed for the 
webserver to work.

To add them to the application just browse the application folder
as follows and paste each folder, then relaunch the Arduino app:

On MAC:

	/Applications/Arduino.app/Contents/Resources/Java/libraries/

	or create a folder and insert them on:
	
	~/Documents/Arduino/libraries/ 

On Windows:

	My Documents\Arduino\libraries\
	

	

	

