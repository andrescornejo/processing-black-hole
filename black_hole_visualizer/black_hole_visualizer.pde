/* Proyecto corto 2 - Visualizacion de datos
 * Autor: Andres Cornejo
 */

import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioPlayer song;
AudioMetaData metadata;
FFT fft;

String songFile = "song3.mp3";
String fontName = "SFReg.otf";
int fontSize = 12;
float volume = .5;
boolean showMeta = true;

float circ1;
float circ2;

float songR = 0; //Red will be low spectrum.
float songG = 0; //Green will be mid spectrum.
float songB = 0; //Blue will be high spectrum.

//These are used to be compared with the new values.
float oldR = songR; 
float oldG = songG; 
float oldB = songB; 

//Values to pinpoint spectrum "zones";
float specLow = 0.03; // 3%
float specMid = 0.125;  // 12.5%
float specHi = 0.20;   // 20%

float diff = 25;

void setup()
{
  fullScreen(P3D);
  frameRate(144);// set your framerate here
  //frame timings should be off if the framerate is not set to your monitors refresh rate.
  //I happen to have a 144hz monitor, hence the framerate choice.
  
  minim = new Minim(this);

  textFont( createFont(fontName,fontSize) );
  textMode(SCREEN);
  
  song = minim.loadFile(songFile);
  fft = new FFT(song.bufferSize(), song.sampleRate());
  metadata = song.getMetaData();
  song.play(0);
  song.setVolume(0.6);
}

void draw()
{
  fft.forward(song.mix);
  background(0);
  textAlign(CENTER);
  drawMetadata();
  keyBinds();
  stroke(255);
  //for(int i = 0; i < song.bufferSize() - 1; i++){ 
  //  line(i, 50 + song.left.get(i)*50, i+1, 50 + song.left.get(i+1)*50); 
  //  line(i, 150 + song.right.get(i)*50, i+1, 150 + song.right.get(i+1)*50); 
  //}
  calculateColors();
  SpecAnalyzer();
  
}

void SpecAnalyzer(){
  fill(0,50);  
  noStroke();
  rect(0, 0, width, height);
  translate(width/2, height/2);
 
  for (int i = 0; i < song.bufferSize() - 1; i++) {
 
    float angle = sin(i+circ1)* 200;
    float angle2 = cos(i+circ1)/cos(i+circ2)* 100;
 
    float x = sin(radians(i))*(angle*2);
    float y = cos(radians(i))*(angle2/4);
    
    float x2 = sin(radians(i))*(angle2);
    float y2 = tan(radians(i))*(angle2*15);
 
    float x3 = sin(radians(i))*(200/angle*600);
    float y3 = cos(radians(i))*(200/angle*600);
    
    float x4 = sin(radians(i))*(angle2/4);
    float y4 = cos(radians(i))*(angle2/4);
     
    
    fill (songR,songG,songB, 40);
    rect(x, y, song.left.get(i)*10, song.left.get(i)*10);
    
    fill (songR,songG,songB, 40);
    ellipse(x2, y2, song.left.get(i)*10, song.left.get(i)*10);
 
    fill ( #ffffff, 60);
    ellipse(x3, y3, song.left.get(i)*20, song.left.get(i)*10);
 
    fill (songR,songG,songB, 40);
    ellipse(x, y, song.right.get(i)*10, song.left.get(i)*30);

    fill( #ffffff , 70);
    rect(x3, y3, song.right.get(i)*10, song.right.get(i)*20);
    
    fill (songR,songG,songB, 40);
    rect(x4, y4, song.left.get(i)*10, song.left.get(i)*10);
  }
 
  circ1 += 0.008;
  circ2 += 0.04;
 
}

void drawMetadata(){
  fill(100,70);  
  if (showMeta){
    int y = height - height/10;
    text(metadata.title() + " by " + metadata.author(), width/2, y);
    text("Album: " + metadata.album(), width/2, y+=fontSize*2);
  }
  else
    return;
}

void keyBinds(){
  if(mousePressed){
    if(showMeta)
      showMeta = !showMeta;
    else 
      showMeta = !showMeta;
  }  
}

void calculateColors(){
  //Put old values in the old variable, and reset new ones.
  oldR = songR;
  oldG = songG;
  oldB = songB;
  songR = 0;
  songG = 0;
  songB = 0;
  
  //Calculate the new values
  for(int i = 0; i < fft.specSize()*specLow; i++)
  {
    songR += fft.getBand(i);
  }
  
  for(int i = (int)(fft.specSize()*specLow); i < fft.specSize()*specMid; i++)
  {
    songG += fft.getBand(i);
  }
  
  for(int i = (int)(fft.specSize()*specMid); i < fft.specSize()*specHi; i++)
  {
    songB += fft.getBand(i);
  }
  
  //Compare with old values for guaranteed change.
  if(oldR>songR){
    songR = oldR - diff;
  }
  if(oldG>songG){
    songG = oldG - diff;
  }
  if(oldB>songB){
    songB = oldB - diff;
  }
  
}
