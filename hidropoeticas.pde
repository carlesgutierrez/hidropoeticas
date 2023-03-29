/** //<>//
  Hidropoeticas
  by Carles Gutierrez
  Toolset createt for Santiago Morilla. 
  IT use the FFT class to analyze a stream of sound.
  Find higest dominant Freq and share sound visualizer with spout. 
 */

import processing.sound.*;
import spout.*;
import controlP5.*;

// Declare the sound source and FFT analyzer variables
AudioIn in;
SoundFile sample;
FFT fft;
ControlP5 cp5;

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
public int strokeWeigthCircle = 2;
public int sizeCircle = 100;
//Colors
public int cBackground = color(0, 0, 0);
public int cBars = color(255, 255, 255);


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
  cp5.addSlider("strokeWeigthCircle")
    .setPosition(_x + 170, _y+80)
    .setSize(100, 10)
    .setRange(1, 100)
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
}

public void setup() {
  size(640, 360, P3D);
  textureMode(NORMAL);
  background(255);

  cp5 = new ControlP5(this);
  createCUSTOMGUI(40, 100);

  //Mode lines active
  //r1.activate(1);


  //AUDIO
  in = new AudioIn(this, 1);
  // start the Audio Input
  in.start();

  // Create the FFT analyzer and connect the playing soundfile to it.
  fft = new FFT(this, bands);
  fft.input(in);


  //SPOUT
  spout = new Spout(this);
  spout.setSenderName("Spout Processing Sender");

  //LOAD SAVED GUI
  cp5.loadProperties(("default.json"));
}


public void draw() {

  background(cBackground);

  //UPdate Calculate the width of the rects depending on how many bands we have
  barWidth = rectW;//width/float(bands);

  // Perform the analysis
  fft.analyze();
  int maxFId = updateMAXFFTValue();//float

  push();
  translate(fftPosX, fftPosY);
  drawCustomFFTMode(modeDrawing, maxFId);//int(r1.getValue())
  pop();


  // Send at the size of the window
  spout.sendTexture();

  // Display info
  text("Sending as : "
    + spout.getSenderName() + " ("
    + spout.getSenderWidth() + "x"
    + spout.getSenderHeight() + ") - fps : "
    + spout.getSenderFps() + " : frame "
    + spout.getSenderFrame(), 15, 30);


  //Calcs
  text("Max FREQ ID Band is "+ maxFId, 15, 50);
  text("Max FREQ is "+ nf(getMaxValueFFT(maxFId), 1, 8), 15, 70);
}




//----------------------------------------
public void drawCustomFFTMode(int _mode, int _maxFreqIdBand) {

  fill(cBars);

  if (_mode == 2) {
    beginShape();
    noFill();
    stroke(cBars);
    strokeWeight(1);
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
        rect(auxPosX, height, barWidth, -auxPosY); //<>//
      } else if (_mode == 2) {
        curveVertex(auxPosX, height-auxPosY);
      }
    }
  }

  if (_mode == 2) {
    curveVertex(width, height);
    endShape();//CLOSE
  }

  if (_maxFreqIdBand >0 && _maxFreqIdBand < bands) {

    int auxPosX = int(gapX*_maxFreqIdBand + _maxFreqIdBand*barWidth);
    int auxPosY = int(getMaxValueFFT(_maxFreqIdBand)*height*scaleRectH);

    //draw maxFreq
    push();
    stroke(255);
    noFill();
    strokeWeight(strokeWeigthCircle);
    circle(auxPosX, height-auxPosY, sizeCircle);
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
      maxIndex = 0;
    }
  }
  return maxIndex; //fft.spectrum[maxIndex]
}


void b3() {
  cp5.saveProperties("default", "default");
}

void b4() {
  cp5.loadProperties(("default.json"));
}
