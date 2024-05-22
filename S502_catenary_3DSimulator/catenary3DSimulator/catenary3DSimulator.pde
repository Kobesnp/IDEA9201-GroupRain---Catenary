///////////////////////////////////////////////////
// LAKE MAC - MAP mima's CATENARY LIGHTS 3D VISUALISER
// Concept: A Night in Lake Macquarie
// Authors: Erin Louise Topfer, Emma (Shih Wei) Tsai, Rachel Rodriguez, Yanan Li,  Hespanhol
// Date: August 2021
///////////////////////////////////////////////////

import processing.video.*;
import mqtt.*;

import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer song;
FFT fft;
BeatDetect beat;

// analysis signal params
float sl, sm, sh;  // low, middle, high
float sg = 0;  // score global
float osl, osm, osh;  // old low...
float specLow = 0.05;
float specMid = 0.125;
float sdr = 5;  // score decrease rate

MQTTClient client;

PoleSet poleSet;
LightModuleSet lightModuleSet;
Environment environment;
AnimationSequenceCustom animationSequence;
Settings settings;
SceneManager sceneManager;
Console console;
Scheduler scheduler;

void setup() {
  size(1600, 1000, P2D);
//  size(1280, 800, P2D);
  colorMode(RGB, 255);
  
  setupMinim();

  /////////////////////////////////
  // SETUP MQTT
  /////////////////////////////////
  client = new MQTTClient(this);
  try {
    //client.connect("mqtts://usyddesign:uSydDesign21@11ecbc684a0049599c6962a6bf9c5edc.s1.eu.hivemq.cloud:8883", "mapMimaLuke");
    client.connect("mqtt://public.mqtthq.com:1883");
    //println("Connection to MQTT successful.");
  } catch (Exception e) {
    println("MQTT CONNECTION FAILURE: " + e);
  }
  
  /////////////////////////////////
  // SETUP SETTINGS AND SCHEDULER
  /////////////////////////////////
  settings = new Settings(this);
  settings.loadProperties();

  animationSequence = new AnimationSequenceCustom();
  environment = new Environment(this, animationSequence);
  sceneManager = new SceneManager(this, environment);
  console = new Console(this, environment);
  scheduler = new Scheduler(console);
  background(10);
}

void draw() {
  updateMinim();
  
  scheduler.evaluate();
  sceneManager.setLightsAndCamera();  
  sceneManager.evaluateControlsAndNavigation();
  animationSequence.render();
  environment.display();
  console.display();
  
  if (SceneManager.exitButtonPressed) {
    exit();
  }
}

void mousePressed() {
  console.evaluateMousePress();
}

void mouseReleased() {
  console.evaluateMouseRelease();
}
  
/////////////////////////////////////////////
// MOVIE EVENT
/////////////////////////////////////////////
void movieEvent(Movie m) {
  m.read();
}

/////////////////////////////////////////////
// MQTT
/////////////////////////////////////////////
void clientConnected() {
  println("MQTT client connected");
  client.subscribe("catenaryColourSelection", 0);
}

void connectionLost() {
  println("MQTT connection lost");
}

void setupMinim() {
  minim = new Minim(this);
  song = minim.loadFile("data/2.mp3", 1024);
  song.loop();

  // create an FFT object
  fft = new FFT(song.bufferSize(), song.sampleRate());
  resetScore();

  // beat detect
  beat = new BeatDetect();
}

void resetScore() {
  sl = 0;
  sm = 0;
  sh = 0;
}

void updateMinim() {
  fft.forward(song.mix);
  beat.detect(song.mix);

  osl = sl;
  osm = sm;
  osh = sh;
  resetScore();

  int ss = fft.specSize();
  for (int i = 0; i < ss; i++) {
    if (i < ss * specLow) {
      sl += fft.getBand(i)/5;
    } else if (i < ss * specMid) {
      sm += fft.getBand(i)/5;
    } else {
      sh += fft.getBand(i)/5;
    }
  }

  if (osl > sl) {
    sl = osl - sdr;
  }

  if (osm > sm) {
    sm = osm - sdr;
  }

  if (osh > sh) {
    sh = osh - sdr;
  }

  sg = 0.33*sl + 0.33*sm + 0.33*sh;
}
