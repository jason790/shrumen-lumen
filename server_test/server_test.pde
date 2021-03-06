/*
 * Generate a colour cycle on a PixelPusher array.
 * Won't do anything until a PixelPusher is detected.
 */

import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;
import com.heroicrobot.dropbit.devices.pixelpusher.PixelPusher;
import com.heroicrobot.dropbit.devices.pixelpusher.PusherCommand;


import java.util.*;

private Random random = new Random();

DeviceRegistry registry;

int[][] colors = {
  {
    127, 0, 0
  }
  , 
  {
    0, 127, 0
  }
  , 
  {
    0, 0, 127
  }
};

void spamCommand(PixelPusher p, PusherCommand pc) {
   for (int i=0; i<3; i++) {
    p.sendCommand(pc);
  }
}

public Pixel generateRandomPixel() {
  //return new Pixel((byte)(random.nextInt(scaling)),(byte)(random.nextInt(scaling)),(byte)(random.nextInt(scaling)));
  //return new Pixel((byte)(15), (byte)0, (byte)0);
  int[] colour = colors[random.nextInt(colors.length)];
  return new Pixel((byte)colour[0], (byte)colour[1], (byte)colour[2]);
}

class TestObserver implements Observer {
  public boolean hasStrips = false;
  public void update(Observable registry, Object updatedDevice) {
    println("Registry changed!");
    if (updatedDevice != null) {
      println("Device change: " + updatedDevice);
    }
    this.hasStrips = true;
  }
}

TestObserver testObserver;
int c = 0;

void setup() {
  size(10, 10, P3D);
  registry = new DeviceRegistry();
  testObserver = new TestObserver();
  registry.addObserver(testObserver);
  colorMode(RGB, 100);
  frameRate(60);
  prepareExitHandler();
}

void mousePressed() {
  List<PixelPusher> pushers = registry.getPushers();
  println(mouseY);
    for (PixelPusher p: pushers) {
       PusherCommand pc = new PusherCommand(PusherCommand.GLOBALBRIGHTNESS_SET, (short)((65536.0 * mouseY) / height));
       spamCommand(p,  pc);
    }
 
}

void draw() {
  int x=0;
  int y=0;
  if (testObserver.hasStrips) {   
    registry.startPushing();
    registry.setExtraDelay(15);
    registry.setAutoThrottle(true);
    registry.setAntiLog(true);    
    // int stripy = 0;
    List<Strip> strips = registry.getStrips();
    
    int numStrips = strips.size();
    //println("Strips total = "+numStrips);
    if (numStrips == 0)
      return;
      
    // Get the colors from the server
    //int colors[] = { 0, 0, 0, 0, 0, 0, 0, 0};

    int ledStripsInCap = 6;
    int ledStripsInStem = 2;

    //Instantiate and set a matrix for cap
    String capMatrix[][] = new String[numStrips][90];
    for (String[] row: capMatrix)
      Arrays.fill(row, "000");

    //Instantiate and set a matrix for stem
    String stemMatrix[][] = new String[numStrips][240];
    for (String[] row: stemMatrix)
      Arrays.fill(row, "000");

    try {
      String lines[] = loadStrings("http://localhost:3000");
      if(lines.length > 0){
        JSONObject json = parseJSONObject(lines[0]);

        //Get the Objects containing cap and stem colors
        JSONObject capColors = json.getJSONObject("cap");
        JSONObject stemColors = json.getJSONObject("stem");


        for (int jsonRow = 0; jsonRow < ledStripsInCap; jsonRow++) {
           JSONArray row = capColors.getJSONArray(String.valueOf(jsonRow)); 
           capMatrix[jsonRow] = row.getStringArray();
           //println("Cap Matrix Row: " + jsonRow);
           //println (capMatrix[jsonRow]);
        }

        for (int jsonRow = 0; jsonRow < ledStripsInStem; jsonRow++) {
           JSONArray row = stemColors.getJSONArray(String.valueOf(jsonRow)); 
           stemMatrix[jsonRow] = row.getStringArray();
           //println("Stem Matrix Row: " + jsonRow);
           //println (capMatrix[jsonRow]);
        }
      }
      
    } catch(Exception e){
       println("Unable to reach server.");
    }
   
    int yscale = height / strips.size();
    for (int stripn = 0; stripn < strips.size(); stripn++) {
      Strip strip = strips.get(stripn);

      String colors[] = (stripn < ledStripsInCap) ? capMatrix[stripn % ledStripsInCap] : stemMatrix[stripn % ledStripsInCap];
      //println("Strip: " + stripn + ". Colors Length: " + colors.length);
      
      // int xscale = width / strip.getLength();
      //println("Updating Strip " + stripn + " to color: " + c + "(" + colorraw + ": " + r + "," + g + "," + b + ")");
      for (int stripx = 0; stripx < colors.length; stripx++) {
        // x = stripx*xscale + 1;
        // y = stripy*yscale + 1;
        //println("Strip: " + stripn + ". Strip Length: " +strip.getLength());
        //print("Value: " + colors[stripx]);
        //int colorraw = unhex(colors[stripx]);
        String colorraw = colors[stripx];
        //////println(colorraw);
        //int r = (colorraw >> 16) & 0xFF;
        //int g = (colorraw >> 8) & 0xFF;
        //int b = (colorraw >> 0) & 0xFF;
        //println("r: " + r + ". g: " + g + ". b: " + b);
        
        //color c = color(r, g, b);

        strip.setPixel(Integer.decode("#"+colorraw), stripx);
      }
      // stripy++;
    }
  }
}
private void prepareExitHandler () {

  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {

    public void run () {

      System.out.println("Shutdown hook running");

      List<Strip> strips = registry.getStrips();
      for (Strip strip : strips) {
        for (int i=0; i<strip.getLength(); i++)
          strip.setPixel(#000000, i);
      }
      for (int i=0; i<100000; i++)
        Thread.yield();
    }
  }
  ));
}