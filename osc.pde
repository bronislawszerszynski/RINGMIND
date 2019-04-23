//as we never listen for osc coming back we can save half the comp power by niot using the oscp5 listener function
//yeh we cant as we dont want a bundle so we have to use it if we have to use msg instead

import netP5.*;
import oscP5.*;

NetAddress soundEngine;
OscP5 osc;
int portNum = 6448; //57120

//------------------------------------------------------------------------------------------------------

void setupOSC() {
  // tony to have correct port listening
  // follow ethernet hookup guide
  osc = new OscP5(this, 12000);
  soundEngine = new NetAddress("127.0.0.1", portNum);
  println("comms connected on port "+portNum);
}


//------------------------------------------------------OSC METHODS------------------------------

void oscMoonAlignment(int moonB, float t){

  OscMessage msg = new OscMessage("/MoonAlign");
  
  msg.add(moonB); // the moon its aligning with
  msg.add(abs(t)); // time to align
  msg.add("moon position"); //moon angle as a map from 0 to 1 but lets do this when we know the front as 0
  
  println("Moon Align: Moon 0 to Moon "+moonB+" happening in t minus " + abs(t));  
  
  osc.send(msg, soundEngine); 


}



void oscRingDensity(RingSystem rs){
  
  OscMessage rmsg = new OscMessage("/RingDensity");
  int count = rs.rings.size();
  for(int i=0; i < count; i++){
   Ring r = rs.rings.get(i);
   rmsg.add(r.density);
  }
  
  println(count+" ring densities sent via osc");
  
  osc.send(rmsg, soundEngine); 
    
}


void oscRingRotationRate(RingSystem rs){
  OscMessage rmsg = new OscMessage("/RingRotationRate");
  int count = rs.rings.size();
  for(int i=0; i < count; i++){
   Ring r = rs.rings.get(i);
   rmsg.add(r.Omega0);
  }
  
  println(count+" ring rotation rates sent via osc");
  
  osc.send(rmsg, soundEngine); 
  
}






//redundant but hold in for now


////-----------------------------------------------------------------------------------------------------------------------------------------------------------------

//void transmitRingOSC(Ring r) {
//  //create a new bundle that can store more than one addresstag and data and then the entire lot can be sent in one go quickly and tony can parse out
//  OscBundle bundle = new OscBundle();

//  //first bit of data is the ring id
//  OscMessage msg = new OscMessage("/RingNumber");
//  msg.add(r.ringID);
//  bundle.add(msg);
//  //clear the message for next data (dont worry its still in the bundle ready to go) 
//  msg.clear();
  

//  // next bit of data 
//  msg.setAddrPattern("/RingDensity");
//  msg.add(r.density);
//  println("ring density is = "+r.density);
//  bundle.add(msg);
//  msg.clear();

//  msg.setAddrPattern("/RingRotationRate");
//  msg.add(r.Omega0);
//  println("ring rotate rate= "+r.Omega0);
//  bundle.add(msg);
//  msg.clear();

  
  

//  //send the bundle in one go

//  bundle.setTimetag(bundle.now() + 1000);
//  // flush the message out
//  OscP5.flush(bundle, soundEngine); 
//  println("osc ring data sent to sound");
//}



//void transmitAllRingsOSC(){
//  //first data blast to setup all rings data for the sound engine
//  println("sending ring data to sound engine");
//  for (Ring rr : Saturn.rings){
//    transmitRingOSC(rr);
//  } 
//}


//void transmitRingCountOSC(){
//  OscBundle bundle = new OscBundle();
//  OscMessage msg = new OscMessage("/RingCount");
//  msg.add(Saturn.rings.size());
//  bundle.add(msg);
//  bundle.setTimetag(bundle.now() + 1000);
//  OscP5.flush(bundle, soundEngine); 
//}

////-----------------------------------------------------------------------------------------------------------------------------------------------------------------

//void transmitMoonOSC(Moon m){
  
// //moon mass
//  OscMessage msg = new OscMessage("/MoonData");
//  msg.add(m.GM);
  
//  osc.send(msg, soundEngine); 
  
//}


//void transmitAllMoonsOSC(){
//    //println("sending moon data to sound engine");
//  for (Moon mm : Saturn.moons){
//    transmitMoonOSC(mm);
//  } 
  
//}
