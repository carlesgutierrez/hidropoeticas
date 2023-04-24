import spout.*;

// DECLARE A SPOUT OBJECT
Spout spout;

Boolean bGetData = false;
PFont font;

//Raw Data gathered
 String fulldate ="";String fullTime ="";float feelslike = 0;float preciptype = 0;float windspeed = 0;int pressure = 0;int cloudcover = 0;int solarradiation = 0;

//Data to show
String dateBase = "DATE: ";
String dateFinal = "";
String timeBase = " - TIME: ";
String timeFinal = "";
String tempBase = " - TEMP FEELSLIKE: ";
String tempFinal = "";
String precipBase = " - PRECIP: ";
String precipFinal = "";
String windBase = " - WIND SPEED: ";
String windFinal = "";
String pressureBase = " - PRESSURE: ";
String pressureFinal = "";
String cloudBase = " - CLOUD COVER: ";
String cloudFinal = "";
String solarBase = " - SOLAR RADIATION: ";
String solarFinal = "";
String text2ShowBase = "";
String text2ShowFinal = "";
//text2Show= dateBase+dateFinal+timeBase+timeFinal+tempBase+tempFinal+precipBase+precipFinal+windBase+windFinal+pressureBase+pressureFinal+cloudBase+cloudFinal+solarBase+solarFinal;

//JSON data
JSONObject json;
JSONObject currentConditions;
String locationName = "MUSEO VOSTELL";
String url = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/" +
  locationName +
  "+?unitGroup=us&key=KDFY7MV54B8TUHRJTLDF5KPUA&contentType=json";

//----------------------------------------------------
public void setup() {
  size(1920, 1080, P3D);

  font = createFont("Helvetica", 14);//loadFont("Helvetica.ttf");
  
  //SPOUT
  spout = new Spout(this);
  spout.setSenderName("Spout weather");
}
//----------------------------------------------------
public void draw() {

  background(0);//#46797e);

  //sendOSCWeatherData();

  //DATA UPDATE
  if (minute() % 2 == 0 && !bGetData) {
    thread("getWeatherData");
  } else {
    if (minute() % 2 != 0) bGetData = false;
  }

  textFont(font);
  textAlign(LEFT, TOP);
 drawSuperiorTextLine();
  
  
  //INFERIOR TEXT LINE
  drawInferiorTextLine();
  
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
}

//----------------------------------------------------
public void drawSuperiorTextLine(){
  int initPosX = round(width*0.224);//initial position
  int posX = initPosX; 
  int posY = 10;
  
  //all in one line 
  //text2ShowBase = dateBase+dateFinal+timeBase+timeFinal+tempBase+tempFinal+precipBase+precipFinal+windBase+windFinal+pressureBase+pressureFinal+cloudBase+cloudFinal+solarBase+solarFinal;
  //text(text2ShowFinal, width*0.5, 10);
  
  //SUPERIOR TEXT LINE
  
  fill(#00FFFF);
  text(dateBase, posX, posY);
  posX = posX+round(textWidth(dateBase));
  fill(#FFFFFF);
  text(dateFinal, posX, posY);
  posX = posX+round(textWidth(dateFinal));
  
  fill(#00FFFF);
  text(timeBase, posX, posY);
  posX = posX+round(textWidth(timeBase));
  fill(#FFFFFF);
  text(timeFinal, posX, posY);
  posX = posX+round(textWidth(timeFinal));
  
  fill(#00FFFF);
  text(tempBase, posX, posY);
  posX = posX+round(textWidth(tempBase));
  fill(#FFFFFF);
  text(tempFinal, posX, posY);
  posX = posX+round(textWidth(tempFinal));
  
  fill(#00FFFF);
  text(precipBase, posX, posY);
  posX = posX+round(textWidth(precipBase));
  fill(#FFFFFF);
  text(precipFinal, posX, posY);
  posX = posX+round(textWidth(precipFinal));
  
  fill(#00FFFF);
  text(windBase, posX, posY);
  posX = posX+round(textWidth(windBase));
  fill(#FFFFFF);
  text(windFinal, posX, posY);
  posX = posX+round(textWidth(windFinal));
  
  fill(#00FFFF);
  text(pressureBase, posX, posY);
  posX = posX+round(textWidth(pressureBase));
  fill(#FFFFFF);
  text(pressureFinal, posX, posY);
  posX = posX+round(textWidth(pressureFinal));
  
  fill(#00FFFF);
  text(cloudBase, posX, posY);
  posX = posX+round(textWidth(cloudBase));
  fill(#FFFFFF);
  text(cloudFinal, posX, posY);
  posX = posX+round(textWidth(cloudFinal));
  
  fill(#00FFFF);
  text(solarBase, posX, posY);
  posX = posX+round(textWidth(solarBase));
  fill(#FFFFFF);
  text(solarFinal, posX, posY);
  //posX = posX+round(textWidth(solarFinal));
}

//----------------------------------------------------
public void  drawInferiorTextLine(){
  int posX = round(width*0.425);
  int posY = height - 10;
  textAlign(LEFT, BOTTOM);
  fill(#00FFFF);
  text("HIDROPOETICS: ", posX, posY);//Title
  posX = posX+round(textWidth("HIDROPOETICS: "));
  fill(#FFFFFF);
  text("39º25'18.2\"N+6º30'10.5\"W", posX, posY);//locationName
}

/*
//----------------------------------------------------
 public void sendOSCWeatherData() {
 OscMessage myMessage = new OscMessage("/composition/layers/3/clips/8/video/source/blocktextgenerator/text/params/lines");
 
 if (bDataAvailable) {
 String dataRandom = nf(random(10, 100), 2, 2);
 myMessage.add(dataRandom);
 oscP5.send(myMessage, myRemoteLocation);
 
 //reset
 bDataAvailable = false;
 println("OSC Data sent = "+dataRandom);
 }
 }
 */

void keyPressed() {
  //bGetData = !bGetData;
  thread("getWeatherData");
}

void updateURL() {
  //locationName = locationName;//random(locations);

  url =
    "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/" +
    locationName +
    "+?unitGroup=us&key=KDFY7MV54B8TUHRJTLDF5KPUA&contentType=json";
}

void getWeatherData() {
  println("getWeatherData().....");

  bGetData = true;

  updateURL();

  JSONObject auxJson = loadJSONObject(url);
  
  JSONObject currentConditionsJson = auxJson.getJSONObject("currentConditions");
  println(currentConditionsJson);
  getNewData(currentConditionsJson);
}

void getNewData(JSONObject _data) {
  //currentConditions = _data.getString("time");.currentConditions;

  if (_data.isNull("feelslike")==false)feelslike = _data.getFloat("feelslike");
  
  if (_data.isNull("preciptype")==false)preciptype = _data.getFloat("preciptype");
  
  if (_data.isNull("windspeed")==false)windspeed = _data.getFloat("windspeed");
  
  if (_data.isNull("pressure")==false)pressure = _data.getInt("pressure");
  
  if (_data.isNull("cloudcover")==false)cloudcover = _data.getInt("cloudcover");
  
  if (_data.isNull("solarradiation")==false)solarradiation = _data.getInt("solarradiation");

  int d = day();    // Values from 1 - 31
  int m = month();  // Values from 1 - 12
  int y = year();   // 2003, 2004, 2005, etc.
  fulldate = String.valueOf(d)+"/"+String.valueOf(m)+"/"+String.valueOf(y);
  
  int hour = hour();    // Values from 1 - 31
  int min = minute();  // Values from 1 - 12
  int sec = second();   // 2003, 2004, 2005, etc.
  fullTime = String.valueOf(hour)+":"+String.valueOf(min)+":"+String.valueOf(sec);

  println("fulldate -> "+fulldate);
  println("fullTime -> "+fullTime);
  println("currentConditions feelslike  -> " + feelslike);
  println("preciptype  -> " + preciptype);
  println("windspeed  -> " + windspeed);
  println("pressure  -> " + pressure);
  println("cloudcover  -> " + cloudcover);
  println("solarradiation  -> " + solarradiation);

  //Data to show
  dateFinal = fulldate;
  timeFinal = fullTime;
  tempFinal = String.valueOf(feelslike)+"ºC";
  precipFinal = String.valueOf(preciptype)+"%";
  windFinal = String.valueOf(windspeed)+" kph";
  pressureFinal = String.valueOf(pressure);
  cloudFinal = String.valueOf(cloudcover)+"%";
  solarFinal = String.valueOf(solarradiation);

  //Update final text line
  //text2ShowBase = dateBase+dateFinal+timeBase+timeFinal+tempBase+tempFinal+precipBase+precipFinal+windBase+windFinal+pressureBase+pressureFinal+cloudBase+cloudFinal+solarBase+solarFinal;

}
