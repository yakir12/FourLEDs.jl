#include <Adafruit_DotStar.h>
#include <PacketSerial.h> // for the COBS

PacketSerial myPacketSerial;
#define NUMPIXELS 4 // Number of LEDs in strip

// Here's how to control the LEDs from any two pins:
#define DATAPIN    4
#define CLOCKPIN   5
Adafruit_DotStar strip(NUMPIXELS, DATAPIN, CLOCKPIN, DOTSTAR_BGR);

void setup() {
  myPacketSerial.begin(115200);
  myPacketSerial.setPacketHandler(&onPacketReceived);

  strip.begin(); // Initialize pins for output
  strip.show();  // Turn all LEDs off ASAP

}

void loop() {
  myPacketSerial.update();
}

void onPacketReceived(const uint8_t* buffer, size_t size)
{
  strip.setPixelColor(buffer[0], 0, buffer[1], 0);
  strip.show();
}
