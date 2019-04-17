//unlikley ti use as its almost idnetial to the timer class inside the proscene libray

//will trigger live - dont worry about timed events

SceneTimer initDone;



void initTimers(){
  
 // set timers for the length of each scenario so they are automated. 
  
}



//class and timer methods

class SceneTimer {
  float time;
  float firstTime = 0;
  boolean isFirst = true;
  float posInTime;
  
  SceneTimer(float l) {
    this.time = l;
  }
  
  void update(float t) {
    if (isFirst) {
      isFirst = false;
      firstTime = t;
    }
    posInTime = (t - firstTime)/time;
  }

  void reset(){
    posInTime = 0;
    isFirst = true;
  }
  
  float getTime() {
    return posInTime;
  }

  boolean done() {
    if (posInTime >= 1.0) {
      reset();
      return true;
    }
    {
      return false;
    }
  }
}
