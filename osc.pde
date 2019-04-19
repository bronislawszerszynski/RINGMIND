import netP5.*;
import oscP5.*;

NetAddress soundEngine;
//as we never listen for osc coming back we can save half the comp power by niot using the oscp5 listener function
int portNum = 6448;

void setupOSC() {
  // tony to have correct port listening
  // follow ethernet hookup guide
  soundEngine = new NetAddress("localhost", portNum);
  println("comms connected on port "+portNum);
}


//-----------------------------------------------------------------------------------------------------------------------------------------------------------------

void transmitRingOSC(Ring r) {
  //create a new bundle that can store more than one addresstag and data and then the entire lot can be sent in one go quickly and tony can parse out
  OscBundle bundle = new OscBundle();

  //first bit of data is the ring id
  OscMessage msg = new OscMessage("/RingNumber");
  msg.add(r.ringID);
  bundle.add(msg);
  //clear the message for next data (dont worry its still in the bundle ready to go) 
  msg.clear();
  

  // next bit of data 
  msg.setAddrPattern("/RingDensity");
  msg.add(r.particles.size());
  bundle.add(msg);
  msg.clear();


  // next bit of data 
  msg.setAddrPattern("/RingRotationRate");
  msg.add(r.Omega0);
  bundle.add(msg);
  msg.clear();

  
  

  //send the bundle in one go

  bundle.setTimetag(bundle.now() + 1000);
  // flush the message out
  OscP5.flush(bundle, soundEngine); 
  println("osc ring data sent to sound");
}



void transmitAllRingsOSC(){
  //first data blast to setup all rings data for the sound engine
  println("sending ring data to sound engine");
  for (Ring rr : Saturn.rings){
    transmitRingOSC(rr);
  } 
}


void transmitRingCountOSC(){
  OscBundle bundle = new OscBundle();
  OscMessage msg = new OscMessage("/RingCount");
  msg.add(Saturn.rings.size());
  bundle.add(msg);
  bundle.setTimetag(bundle.now() + 1000);
  OscP5.flush(bundle, soundEngine); 
}

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------

void transmitMoonOSC(Moon m){
  OscBundle bundle = new OscBundle();

  //first bit of data is the ring id
  OscMessage msg = new OscMessage("/MoonNumber");
  msg.add(m.moonID);
  bundle.add(msg);
  //clear the message for next data (dont worry its still in the bundle ready to go) 
  msg.clear();
  

  // next bit of data 
  msg.setAddrPattern("/MoonDensity");
  msg.add(m.GM);
  bundle.add(msg);
  msg.clear();

  //send the bundle in one go

  bundle.setTimetag(bundle.now() + 1000);
  // flush the message out
  OscP5.flush(bundle, soundEngine); 
  println("osc moon data sent to sound");
  
}


void transmitAllMoonsOSC(){
    println("sending moon data to sound engine");
  for (Moon mm : Saturn.moons){
    transmitMoonOSC(mm);
  } 
  
}
