import processing.video.*;
import oscP5.*;
import netP5.*;

int CURRENT_CATENARY_END = 768;

/********************************************************
 EDIT HERE TO ADD OWN VARIABLES
 *********************************************************/
int redValue = 255;
int greenValue = 200;
int blueValue = 20;
/******************************************************************************
 CUSTOM VARIABLES SECTION END
 *******************************************************************************/


class AnimationSequenceCustom extends AnimationSequence {
  int catenaryMovieWidth;
  int catenaryMovieHeight;
  int speed = 5;

  public AnimationSequenceCustom() {
    catenaryMovieWidth = Integer.parseInt(Settings.getInstance().getProperty("catenaryMovieWidth"));
    catenaryMovieHeight = Integer.parseInt(Settings.getInstance().getProperty("catenaryMovieHeight"));
    canvas = createGraphics(catenaryMovieWidth, catenaryMovieHeight);
  }

  public void render() {
    canvas.beginDraw();

    /********************************************************
     EDIT HERE TO CUSTOMISE IT TO YOUR OWN ANIMATION
     *********************************************************/
    //canvas.background(100, 100, 200);
    canvas.background(floor(100+sh), floor(100+sm), floor(200+sl));
    //int xpos = int((5*frameCount)%CURRENT_CATENARY_END);

    if ( beat.isOnset() ) speed = 24;

    redValue = floor(230+sl);
    greenValue = floor(200+sm);
    blueValue = floor(20+sh);

    int xpos = int(((speed)*frameCount)%CURRENT_CATENARY_END);
    //canvas.fill(255, 200, 20);
    canvas.fill(redValue, greenValue, blueValue);
    canvas.rectMode(CENTER);
    canvas.rect(xpos, canvas.height/2, canvas.height, canvas.height);

    speed--;
    if (speed<5) {
      speed = 5;
    }

    /******************************************************************************
     CUSTOM SECTION END
     *******************************************************************************/

    canvas.endDraw();
  }

  /******************************************************************************
   CUSTOM SECTION END
   *******************************************************************************/
}

/////////////////////////////////////////////
// MQTT EVENT
/////////////////////////////////////////////
void messageReceived(String topic, byte[] payload) {
  //void messageReceived(String topic, String payload) {
  if (topic.equals("catenaryColourSelection")) {
    println("new MQTT message: " + topic + " - " + new String(payload));

    // ADD YOUR OWN CODE HERE TO PARSE THE MQTT MESSAGE
    String[] payloadArray = (new String(payload)).split(",");
    redValue = new Integer(payloadArray[0].trim());
    greenValue = new Integer (payloadArray[1].trim());
    blueValue = new Integer(payloadArray[2].trim());

    println("### Colour: " + redValue + ":" + greenValue + ":" + blueValue);
  }
}
