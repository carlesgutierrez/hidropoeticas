/** //<>// //<>// //<>// //<>// //<>//
 Hidropoeticas
 by Carles Gutierrez
 Toolset createt for Santiago Morilla.
 It use the FFT class to analyze a stream of sound.
 Find higest dominant Freq and share sound visualizer with spout.
 */

import processing.sound.*;
import spout.*;
import controlP5.*;
import oscP5.*;
import netP5.*;

//interactive videos Controler
int numVideoCtrl = 7;

// Declare the sound source and FFT analyzer variables
AudioIn in;
Sound s;
SoundFile sample;
FFT fft;
ControlP5 cp5;

//OSC vars
OscP5 oscP5;
NetAddress myRemoteLocation;

// Define how many FFT bands to use (this needs to be a power of two)
int bands = 512;//128;

// Define a smoothing factor which determines how much the spectrums of consecutive
// points in time should be combined to create a smoother visualisation of the spectrum.
// A smoothing factor of 1.0 means no smoothing (only the data from the newest analysis
// is rendered), decrease the factor down towards 0.0 to have the visualisation update
// more slowly, which is easier on the eye.
float smoothingFactor = 0.2;

// Create a vector to store the smoothed spectrum data in
float[] sum = new float[bands];

///////////////////////////////
//GUI VARS
public int modeDrawing=2;
public Boolean bLoadedData = false;
public RadioButton r1;
public int scaleRectH = 3;//10;
public float barWidth;
public int gapX = 10;
public int rectW = 3;
public int fftPosX, fftPosY = 0;
public float thresholdMinimInteractionFFT = 0.0003;
public boolean bSumMode = false;
public int bandsThreshold = 51;//300;

public boolean bCircleDrawer = false; //<>//
public int sizeCircle = 100;
//Colors
public int cBackground = color(0, 0, 0);
public int cBars = color(255, 255, 255);
public int lineWidth = 10;//TODO line mode more thought

//OSC
public boolean bOSCActive = false;
public int typeOSCMode = 0;

//videos
public int heightPerVideo = 32;
float sizeWPerVideo = 1;
//Video interaction
int idVid = 0;
int last_idVid = -1;
float pctAux= 1;
int last_maxIndex = 0;

//Sound vars
float scaleX = 1;

// DECLARE A SPOUT OBJECT
Spout spout;

public void createCUSTOMGUI(int _x, int _y) {
  cp5.addColorWheel("cBackground", 350, 10, 100 ).setRGB(color(0, 0, 0));
  cp5.addColorWheel("cBars", 450, 10, 100 ).setRGB(color(255, 255, 255));

  cp5 = new ControlP5(this);

  /* ERROR AT LOADING PARAMETERS
   r1 = cp5.addRadioButton("modeDrawing")
   .setPosition(40, 170)
   .setSize(40, 20)
   .setColorForeground(color(120))
   .setColorActive(color(255))
   .setColorLabel(color(255))
   .setItemsPerRow(5)
   .setSpacingColumn(50)
   .addItem("Rects", 1)
   .addItem("Lines", 2)
   ;
   */

  // add a vertical slider
  cp5.addSlider("modeDrawing")
    .setPosition(_x, _y+20)
    .setSize(100, 10)
    .setRange(1, 2)
    .setNumberOfTickMarks(2)
    ;

  // create a toggle and change the default look to a (on/off) switch look
  cp5.addToggle("bSumMode")
    .setPosition(_x, _y+40)
    .setSize(50, 10)
    ;

  // add a vertical slider
  cp5.addSlider("rectW")
    .setPosition(_x, _y+100)
    .setSize(100, 10)
    .setRange(1, 10)
    ;

  // add a vertical slider
  cp5.addSlider("sizeCircle")
    .setPosition(_x, _y+80)
    .setSize(100, 10)
    .setRange(10, 100)
    ;

  // add a vertical slider
  cp5.addSlider("lineWidth")
    .setPosition(_x + 170, _y+80)
    .setSize(100, 10)
    .setRange(1, 20)
    ;

  // add a vertical slider
  cp5.addSlider("thresholdMinimInteractionFFT")
    .setPosition(_x + 400, _y+80)
    .setSize(100, 10)
    .setRange(0.00000001, 0.1)
    ;



  // add a vertical slider
  cp5.addSlider("scaleRectH")
    .setPosition(_x, _y+130)
    .setSize(100, 10)
    .setRange(1, 100)
    ;

  // add a vertical slider
  cp5.addSlider("gapX")
    .setPosition(_x, _y+160)
    .setSize(100, 10)
    .setRange(0, 100)
    ;


  // add a vertical slider
  cp5.addSlider("fftPosX")
    .setPosition(_x, _y+190)
    .setSize(100, 10)
    .setRange(0, width*.5)
    ;

  // add a vertical slider
  cp5.addSlider("fftPosY")
    .setPosition(_x+300, _y+190)
    .setSize(100, 10)
    .setRange(0, -height*.9)
    ;

  // add a vertical slider
  cp5.addSlider("bandsThreshold")
    .setPosition(_x, _y+210)
    .setSize(100, 10)
    .setRange(0, bands)
    ;

  cp5.addButton("b3", 0, 200, 350, 80, 12).setCaptionLabel("save default");
  cp5.addButton("b4", 0, 281, 350, 80, 12).setCaptionLabel("load default").setColorBackground(color(0, 100, 50));


  //OSC
  // create a toggle and change the default look to a (on/off) switch look
  cp5.addToggle("bOSCActive")
    .setPosition(_x+width*.5, _y+40)
    .setSize(50, 10)
    ;

  // add a vertical slider
  cp5.addSlider("typeOSCMode")
    .setPosition(_x+width*.55, _y+40)
    .setSize(100, 10)
    .setRange(1, 2)
    .setNumberOfTickMarks(2)
    ;

  //Interaction UX 
  // create a toggle and change the default look to a (on/off) switch look
  cp5.addToggle("bCircleDrawer")
    .setPosition(_x+width*0.8, _y+0)
    .setSize(50, 50)
    ;
  
  /*
  // add a vertical slider
  cp5.addSlider("heightPerVideo")
    .setPosition(_x+width*0.9, _y+0)
    .setSize(20, 100)
    .setRange(0, height);
  ;
  */
  
 
}

public void setupDimensionsSoundBar() {
  scaleX = width/bands;
  println("scaleX = "+scaleX);
}

public void setup() {

  size(1920, 1080, P3D); //640, 360
  // Pulling the display's density dynamically
  pixelDensity(displayDensity());

  setupDimensionsSoundBar();

  //surface.setLocation(-width, 0);

  textureMode(NORMAL);
  background(255);

  cp5 = new ControlP5(this);
  createCUSTOMGUI(40, 100);

  //Mode lines active
  //r1.activate(1);

  sizeWPerVideo = width / numVideoCtrl;

  //AUDIO
  Sound.list();
  s = new Sound(this);
  s.inputDevice(1);
  in = new AudioIn(this, 9);
  // start the Audio Input
  in.start();

  // Create the FFT analyzer and connect the playing soundfile to it.
  fft = new FFT(this, bands);
  fft.input(in);


  //SPOUT
  spout = new Spout(this);
  spout.setSenderName("Spout Processing Sender");

  //LOAD SAVED GUI
  //cp5.loadProperties(("default.json"));//Take care and release at the end of GUI DESIGN

  //OSC
  oscP5 = new OscP5(this, 7001);
  myRemoteLocation = new NetAddress("127.0.0.1", 7000); //  //172.18.144.1
}

//----------------------------------------------------
public void draw() {

  background(cBackground);

  //UPdate Calculate the width of the rects depending on how many bands we have
  barWidth = rectW;//width/float(bands);

  // Perform the analysis
  fft.analyze();
  int maxFId = updateMAXFFTValue();//float

  //SEND osc DATA
  sendOSCFreqData(maxFId);

  push();
  translate(fftPosX, fftPosY);
  drawCustomFFTMode(modeDrawing, maxFId);//int(r1.getValue())
  pop();

  //Draw Videos interaction
  drawMainRectArea();
  drawSelectedRectInteractionArea(maxFId);
  sendOSCVideoData(maxFId);

  // Send at the size of the window
  spout.sendTexture();

  // Display info
  /* text("Sending as : "
   + spout.getSenderName() + " ("
   + spout.getSenderWidth() + "x"
   + spout.getSenderHeight() + ") - fps : "
   + spout.getSenderFps() + " : frame "
   + spout.getSenderFrame(), 15, 30);
   */

  //draw Calcs
  float auxFreq = int(map(maxFId, 0, bandsThreshold, 0, 1920));//Map into FULLHD width
  float auxFreqAmplitude = int(map(getMaxValueFFT(maxFId), 0, 0.2, 0, 100));
  text("Dominant FREQ ID Band is "+ maxFId+ " -> [0, 1920] ->"+auxFreq, 15, 50);
  text("Dominant FREQ is "+ nf(getMaxValueFFT(maxFId), 1, 8)+ " -> [0, 100] -> "+auxFreqAmplitude, 15, 70);
}

//----------------------------------------------------
public int findIdInteraction(int _maxFId) {
  return int(map(_maxFId, 0, bandsThreshold, 0, numVideoCtrl));
}

//----------------------------------------------------
public void updatePctInteraction(int _maxFId) {

  float auxFreq = int(map(_maxFId, 0, bandsThreshold, 0, 1920));
  //idVid = findIdInteraction(_maxFId);
  pctAux = map(auxFreq%sizeWPerVideo, 0, sizeWPerVideo, 0, 1);
  //print("idVid->"+idVid);//TODO
  //println("pctAux->"+pctAux);
}


//----------------------------------------------------
public void drawSelectedRectInteractionArea(int _maxFId) {

  //find id interaction
  int idVideoSelected = findIdInteraction(_maxFId);//int(map(_maxFId, 0, bandsThreshold, 0, numVideoCtrl));

  push();
  //stroke(77,222,225, 10);
  //strokeWeight(3);
  noFill();
  stroke(77, 222, 225, 255);

  for (int i=0; i < numVideoCtrl; i++) {
    if (i == idVideoSelected) {
      rect(i*sizeWPerVideo, 0, sizeWPerVideo, height);//heightPerVideo
    }
  }

  pop();
}


//----------------------------------------------------
public void drawMainRectArea() {


  push();
  stroke(77, 222, 225);
  strokeWeight(3);
  noFill();
  rect(0, 0, width, height);

  for (int i=0; i < numVideoCtrl; i++) {
    line(i*sizeWPerVideo, 0, i*sizeWPerVideo, heightPerVideo);//heightPerVideo
  }

  pop();
}

//----------------------------------------------------
public void sendOSCFreqData(int _idBandMaxFr) {
  OscMessage myMessage = new OscMessage("/maxFreq");

  if (_idBandMaxFr >0 && _idBandMaxFr < bands) {

    float auxFreqAmplitude = int(map(getMaxValueFFT(_idBandMaxFr), 0, 0.2, 0, 100));//Map into [0, 100]
    float auxFreq = int(map(_idBandMaxFr, 0, bandsThreshold, 0, 1920));//Map into width of FULLHD [0, 1920]
    myMessage.add(auxFreq);
    myMessage.add(auxFreqAmplitude);

    /* send the message */
    oscP5.send(myMessage, myRemoteLocation);
  }
}

//----------------------------------------------------
public void sendOSCVideoData(int _idBandMaxFr) {

  /*
  
   /composition/layers/3/clips/1/transport/position
   /composition/layers/3/clips/2/transport/position
   /composition/layers/3/clips/3/transport/position
   ...
   
   /composition/columns/1/connect
   /composition/columns/2/connect
   /composition/columns/3/connect
   ...
   
   */

  if (_idBandMaxFr >0 && _idBandMaxFr < bands) {

    //update Id Video and pct
    idVid = findIdInteraction(_idBandMaxFr);
    updatePctInteraction(_idBandMaxFr);

    if (last_idVid != idVid) {
      if (bOSCActive) {
        //OSC id Vídeo
        String pathOSCVid_Id = "/composition/columns/"+(idVid+1)+"/connect";
        //println(pathOSCVid);
        OscMessage myMessage_id = new OscMessage(pathOSCVid_Id);
        myMessage_id.add(1); //"send 0 or 1"
        oscP5.send(myMessage_id, myRemoteLocation);

        if (typeOSCMode == 1) {//Todo check last and do not repeat  
          //OSC pct Vídeo
          String pathOSCVid_PCT = "/composition/layers/3/clips/"+(idVid+1)+"/transport/position";
          //println(pathOSCVid);
          OscMessage myMessage_pct = new OscMessage(pathOSCVid_PCT);
          myMessage_pct.add(pctAux);
          oscP5.send(myMessage_pct, myRemoteLocation);
        } else {
          //TODO check if other modes are required
        }
      }
    }
    
    //save last value
    last_idVid = idVid;
  }
  //TODO ELSE disconnect all ? another column in black mode?
}


//----------------------------------------
public void drawCustomFFTMode(int _mode, int _maxFreqIdBand) {

  fill(cBars);

  if (_mode == 2) {
    beginShape();
    noFill();
    stroke(cBars);
    strokeWeight(lineWidth);
    curveVertex(0, height);

    //rect(0, height-50, 100, 100);
  } else if (_mode == 1) {
    noStroke();
    strokeWeight(0);
  }

  for (int i = 0; i < bands; i++) {
    if (i<bandsThreshold) {//bands/2
      float valueFFT = 0;
      if (bSumMode) {
        // Smooth the FFT spectrum data by smoothing factor
        sum[i] += (fft.spectrum[i]*height/30 - sum[i]) * smoothingFactor;
        valueFFT = sum[i];
      } else {
        valueFFT = fft.spectrum[i];
      }

      float auxPosX = (gapX*i + i*barWidth);
      float auxPosY = (valueFFT*height*scaleRectH);

      if (_mode == 1) {
        // Draw the rectangles, adjust their height using the scaleRectH factor
        rect(auxPosX*scaleX, height, barWidth, -auxPosY);
      } else if (_mode == 2) {
        curveVertex(auxPosX*scaleX, height-auxPosY);
      }
    }
  }

  if (_mode == 2) {
    curveVertex(width, height);
    endShape();//CLOSE
  }

  if (_maxFreqIdBand >0 && _maxFreqIdBand < bands && bCircleDrawer) {

    int auxPosX = int(gapX*_maxFreqIdBand + _maxFreqIdBand*barWidth);
    int auxPosY = int(getMaxValueFFT(_maxFreqIdBand)*height*scaleRectH);

    //draw maxFreq
    push();
    stroke(255);
    noFill();
    strokeWeight(lineWidth);
    circle(auxPosX*scaleX, height-auxPosY, sizeCircle);
    pop();
  }
}


public float getMaxValueFFT(int _maxFreqIdBand) {

  float auxMaxValueFFT = 0;

  if (_maxFreqIdBand > -1) {

    if (bSumMode) {
      auxMaxValueFFT = sum[_maxFreqIdBand];
    } else {
      auxMaxValueFFT = fft.spectrum[_maxFreqIdBand];
    }
  }

  return auxMaxValueFFT;
}

//----------------------------------------
public int updateMAXFFTValue() {
  float maxValue = Float.MIN_VALUE;
  int maxIndex = -1;
  for (int i = 0; i < bands; i++) {
    if (i<bandsThreshold) {
      if (fft.spectrum[i] > maxValue)
      {
        maxValue = fft.spectrum[i];
        maxIndex = i;
      }
    }
  }

  if (maxIndex > -1) {
    if (fft.spectrum[maxIndex] < thresholdMinimInteractionFFT) {
      maxIndex = last_maxIndex;
    }
  }
  last_maxIndex = maxIndex;
  
  return maxIndex; //fft.spectrum[maxIndex]
}

//--------------------------------------------
//GUI
void b3() {
  cp5.saveProperties("default", "default");
}

void b4() {
  cp5.loadProperties(("default.json"));
}

//--------------------------------------------
/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}
