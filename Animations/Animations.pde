 /*
 * Demonstrate how to drive high frame rates using turbo_mode.
 *
 * Won't do anything until a PixelPusher is detected.
 */

import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;
import java.util.*;

DeviceRegistry registry;

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

// Global Animation State
String state = "default";

String getState() {
 String animationState = "default";
 
 try {
    // Hit API for state data
    String lines[] = loadStrings("http://localhost:3000/state");
    
    if(lines.length > 0){
      // Parse Data from server
      JSONObject json = parseJSONObject(lines[0]);

      // Get the Objects containing cap and stem colors
      JSONObject state = json.getJSONObject("state");
      
      // Resturn the state value
      animationState = state.toString();
    }
    
  } catch(Exception e){
     println("Unable to reach server.");
  }
  
  return animationState;
}

Default df;
Green gr;

void setup() {
  registry = new DeviceRegistry();
  testObserver = new TestObserver();
  registry.addObserver(testObserver);
  colorMode(HSB, 100);
  size(480, 64);
  frameRate(300);
  
  
   df = new Default();
   gr = new Green();
}

void draw() {
  if (testObserver.hasStrips) {
        registry.setFrameLimit(1000);   
        registry.startPushing();
        registry.setExtraDelay(10);
        registry.setAutoThrottle(false);    
       
        int stripy = 0;
        List<Strip> strips = registry.getStrips();
        int numStrips = strips.size();
        //println("Strips total = "+numStrips);
        if (numStrips == 0)
          return;
        
        // Every 1000 frames request new data 
        if(frameCount % 1000 == 0){
          thread("getState");
          println(state);
        }
        
        // Determine which state the animations should
        // be in.
        switch(state) {
          case "default":
            // Run default script
            fill(255, 0, 0);
            rect(0, 0, 100, 100);
            //gr.display();
          default:
            // Run default script
            //df.display();
            
        }
       
        // Apply the color value to the pixels in the strips
        //for(Strip strip : strips) {
        //  for (int stripx = 0; stripx < strip.getLength(); stripx++) {
        //      color c = color(255, 255, 255);
        //      strip.setPixel(c, stripx);
        //   }
        //  stripy++;
        //}

      }
}