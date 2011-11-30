#include <MemoryFree.h>

#include <NewSoftSerial.h>
#include <Streaming.h>
#include <WiFlySerial.h>


int request = 0;
char bufRequest[80];
/*
 * Replace with your pins on the arduino.
 * This was tested with an Arduino Uno connected to
 * the digital pins 2 and 3.
*/
WiFlySerial WiFly(2,3); // ( rx, tx) 


/*
 * initSettings
 * Replace with your passphrase and your network SSID
 * Referr to your WiFly command manual to set your
 * configurations as needed.
 *
 * Once you run this and makes your device work, you can
 * comment or remove the call to this function in the
 * setup function.
*/
int initSettings(){
	Serial.println("stablishing setting commands...");
    WiFly.SendCommand("set wlan auth 3","AOK");
    WiFly.SendCommand("set wlan channel 5","AOK");
    WiFly.SendCommand("set wlan ext_antenna 1","AOK");
	WiFly.SendCommand("set wlan phrase yourpassphrase","AOK"); // your passphrase
    WiFly.SendCommand("set wlan ssid yourssid","AOK"); // your ssid
    WiFly.SendCommand("set ip localport 80","AOK");
    WiFly.SendCommand("set wlan join 1","AOK");
    WiFly.SendCommand("save","AOK");
}

void setup(){
    Serial.begin(9600);
	Serial.println("setting up the sensors...");
	/*
	* Tested with an ADXL335 accelerometer connected as follows:
	* A0: Vcc
	* A1: Gnd
	* A2: X
	* A3: Y
	* A4: Z
	* A5: Self Test (ST)
	*/
	pinMode(14, OUTPUT);
	pinMode(15, OUTPUT);
	digitalWrite(14, HIGH);
	digitalWrite(15, LOW);
    Serial.println("starting wireless device...");
    WiFly.begin();
    delay(1000);
    initSettings(); // you can comment this once your device is configured
    delay(1000);
    // hacer join
    //WiFly.join("gate-uno");
    
    //lets try the command mode better
    Serial.println("joining gate-uno...");
    WiFly.SendCommand("join gate-uno","AOK");
    delay(5000);
    if(WiFly.isConnected()){
        Serial.print("Connected.");
        Serial.println();
        Serial.print("IP: ");
        Serial.print(WiFly.GetIP(bufRequest, 80));
        Serial.println();
        Serial.print("Netmask: ");
        Serial.print(WiFly.GetNetMask(bufRequest, 80));
        Serial.println();
        Serial.print("Gateway: ");
        Serial.print(WiFly.GetGateway(bufRequest, 80));
        Serial.println();
        Serial.print("DNS: ");
        Serial.print(WiFly.GetDNS(bufRequest, 80));
        Serial.println();   
    }
    else
        Serial.print("Not connected. Will enter loop without connection.");
    Serial.println();
    WiFly.exitCommandMode();
    WiFly.uart.flush();
}

void loop(){
    Serial.println("listening to port 80");
    request = WiFly.ScanForPattern(bufRequest, 80, "*OPEN*", false, 20000);
    if((request & PROMPT_EXPECTED_TOKEN_FOUND) == PROMPT_EXPECTED_TOKEN_FOUND ) {
        WiFly.bWiFlyInCommandMode = false;
        WiFly.ScanForPattern( bufRequest, 80, " HTTP/1.1", 1000 );
        Serial.print("GET request of ");
        Serial.print(strlen(bufRequest));
        Serial.print(" bytes with the following content: ");
        Serial.println();
        Serial.println(bufRequest);
		Serial.println();
		Serial.println("reading accelerometer...");
		int[3] accel = {analogRead(A2), analogRead(A3), analogRead(A4)};
		Serial.print("x: ");
		Serial.print(accel[0]);
		Serial.print("\t y: ");
		Serial.print(accel[1]);
		Serial.print("\t z: ");
		Serial.println(accel[2]);
		/*
		 * HTTP Headers
		*/
        WiFly.uart.print("HTTP/1.1 200 OK\r");
		// instead of text/html we use application/json so it can be
		// parsed in a better way by the client handler
        WiFly.uart.print("Content-Type: application/json;charset=UTF-8\r");
        WiFly.uart.print("Connection: close \r\n\r\n");
		/*
		 * Content
		 * Will be somethink like this:
		 * {success:true,accel:{x:123,y:456,z:789}}
		*/
		WiFly.uart.print("{success:true,accel:{x:");
		WiFly.uart.print(accel[0]);	
		WiFly.uart.print(",y:");
		WiFly.uart.print(accel[1]);
		WiFly.uart.print(",z:");
		WiFly.uart.print(accel[2]);
		WiFly.uart.print("}}");
        WiFly.uart.flush();
    }
    else{
       Serial.println("No request found.");
       
       //TODO: Improve the still connected method... the built in command
       // reinitialices the whole arduino... better test with a get command
/*       if(WiFly.isConnected()){
         Serial.println("Still connected."); 
        }
        else{
          Serial.println("Not connected. Will attempt to reconnect now...");
          WiFly.SendCommand("join gate-uno","AOK");
        }
*/

    }
    delay(1000);
}
