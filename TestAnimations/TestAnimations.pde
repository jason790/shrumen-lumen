import java.util.*;
import gifAnimation.*;

// Make a variable for your class here.
Green gr;
LoopingGif loopingGif;

void setup() {
  colorMode(RGB, 255);
  size(750, 100);
  frameRate(100);
  
  //Instantiate your class object here
  gr = new Green();
  
  //An example of how to add a Gif class
  //loopingGif = new LoopingGif(this);
}

void draw() {
  
  //Call your display function here
  gr.display();
  
  //An example of using a GIF
  //loopingGif.display();
}