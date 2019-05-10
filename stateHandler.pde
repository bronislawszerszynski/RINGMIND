// can decide on these as we go along

enum State {
  initState, 
    introState, 
    ringmindState, 
    makingState, 
    chaosState, 
    orbitalState, 
    shearState, 
    followState, 
    posiedState, 
    ringmoonState, 
    tuningState, 
    outroState, 

    ringmindStableState, 
    ringmindUnstableState, 
    connectedState, 
    saturnState, 

    fadetoblack, 
    fadeup, 
    nocamlock
};


// brons scenarios from script


/*

 intro - distant view of ring
 ringmind - move in clsoer to view moon and ring
 making - reinit rindmind with particles not in plane, possibly just one 'ring' where they are all over the place but spinning
 chaos - gravity, chaos, all sorts going on
 orbital - initialised new 
 shear - zoom to aboe top down position to watch teh shear on one ring
 follow - the trickest one to do following a paricle particle in the ring
 poised - above top down zoomed out view
 ringmoon - gaps and waves and zoomed out
 tuning - the ring sound, lets just focus on a ring
 outro - what is a ringmind lets return back to the beginning.
 
 */


State systemState;

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------

// scneario class - aka scene but cant use scene as its inbuilt into proscene

abstract class Scenario {
  void updatePhysics() {
  }

  abstract boolean transitionTo(float t);

  void update(int t) {
  }

  void postRender(int t) {
  }
}

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------



void setupStates() {

  Shearing=false;
  Tilting=false; 
  Connecting=false;
  Threading=false;


  switch(systemState) {
  case initState:
    //init with = rings 10,  moons 4, rendering normal =true (titl would be false);
    Saturn = new RingSystem(10, 4, true);
    break;

  case introState:

    //create a new system.

    Saturn = new RingSystem(2, 2, true); //ringtpe, moon type, tilt/nottilt
    applyBasicMaterials();

    //new materials for every ring
    for (Ring r : Saturn.rings) {
      r.material = RingMat3;
    }


    initCamera();

    sendOSC(Saturn);
    useAdditiveBlend=false;

    break;

  case ringmindStableState:

    Threading=false;
    useTrace=false;

    Saturn = new RingSystem(10, 4, true);

    applyBasicMaterials();
    //new materials for every ring
    for (Ring r : Saturn.rings) {
      r.material = RingMat3;
    }

    Saturn.rings.get(0).material = RingMat4;
    Saturn.rings.get(1).material = RingMat2; //same as below
    Saturn.rings.get(2).material = RingMat2;
    Saturn.rings.get(3).material = RingMat6;
    Saturn.rings.get(4).material = RingMat6;
    Saturn.rings.get(5).material = RingMat5;

    closerCamera();
    Connecting=false; 
    Shearing=false;
    Tilting=false;
    useAdditiveBlend=true;
    useFilters=false;

    sendOSC(Saturn);

    break;

  case ringmindUnstableState:

    G=6.67408E-9;
    //reinit
    Saturn = new RingSystem(11, 4, true);
    applyBasicMaterials();
    //new materials for every ring
    for (Ring r : Saturn.rings) {
      r.material = RingMat3;
    }


    Saturn.rings.get(0).material = RingMat4;
    Saturn.rings.get(1).material = RingMat2; //same as below
    Saturn.rings.get(2).material = RingMat2;
    Saturn.rings.get(3).material = RingMat6;
    Saturn.rings.get(4).material = RingMat6;
    Saturn.rings.get(5).material = RingMat5;

    closerCamera();


    break;

  case connectedState:

    //connected
    Saturn = new RingSystem(1, 2, true);
    Saturn.rings.get(0).material = RingMat2;

    Connecting=true; 
    Shearing=false;
    Tilting=false;
    //simToRealTimeRatio = 360.0/1.0; //slow it down
    zoomedCamera();
    useAdditiveBlend=true;
    useFilters=false;
    oscRingDensity(Saturn);
    oscRingRotationRate(Saturn);

    break;

  case saturnState:

    Threading=false;
    useTrace=false;
    useAdditiveBlend=false;
    //reinit
    Saturn = new RingSystem(2, 4, true);

    applyBasicMaterials();
    //new materials for every ring
    for (Ring r : Saturn.rings) {
      r.material = RingMat1;
    }
    break;

  case makingState:
    break;

  case chaosState:

    //tilting
    zoomedCamera();
    useAdditiveBlend=true;
    Saturn = new RingSystem(9, 2, false); //ring type 9 as its a tilt type, moon type2 and tilt type2
    //new materials for every ring
    for (Ring r : Saturn.rings) {
      r.material = RingMat1;
    }
    println(Saturn.rings.get(0).Tparticles.size());
    Shearing=false;
    Connecting=false;
    Tilting=true; 
    Threading=false;

    break;

  case orbitalState:

    Saturn = new RingSystem(1, 2, true);
    applyBasicMaterials();
    for (Ring r : Saturn.rings) {
      r.material = RingMat5;
    }
    for (Moon m : Saturn.moons) {
      m.radius = 1;
    }
    drawMoons=false;
    Threading=true;
    G=6.67408E-13;
    Saturn.moons.get(2).GM =4.529477495e13;
    Saturn.moons.get(0).GM =2.529477495e13;
    toptiltCamera();
    Connecting =false;
    Shearing=false;
    Tilting=false;
    break;

  case shearState:
    s = new ShearingBox();
    zoomedCamera();
    useAdditiveBlend=true;
    Shearing=!Shearing;
    Tilting=false;
    Connecting=false;
    Threading=false;

    break;

  case followState:
    break;

  case posiedState:
    break;

  case ringmoonState:
    break;

  case tuningState:
    break;

  case outroState:
    break;

  case fadetoblack:
    break;

  case fadeup:
    break;

  case nocamlock:
    break;
  }
}


//---------------------------------------------------------------------------------------------------

// evaluate what state determine time and then transition to the next state


void evaluateScenario() {

  int t =millis();
}



// update scenario method so depending on which scenario do different things and render differently etc
// basically like a void draw for each scneario and we switch to its one depending on what scene we in.

void updateCurrentScene(int t) {

  // now regardless of scene do this

  // Display all of the objects to screen using the renderer.
  if (useAdditiveBlend) {
    blendMode(ADD);
  } else {
    blendMode(NORMAL);
  }



  switch(systemState) {
  case initState:
    for (Ring r : Saturn.rings) {
      r.setMaxRenderedParticle(50000); //per ring max number allowed is default 50,000
    }
    //overwrite default and chose this material to begin with for all rings
    Saturn.rings.get(0).material = RingMat1; 

    
    //when all camerasa are correct lock them to the scene
    //initCamera();

    break;

  case introState:
    break;

  case ringmindState: 



    break;

  case makingState:
    break;

  case chaosState:
    break;

  case orbitalState:
    break;

  case shearState:
  s.material = ShearMat1;
    break;

  case followState:

    ////probably glitch becuase of calling this and making it new eachf rame 
    //// Moon m2 = Saturn.moons.get(0);
    //RingParticle p = Saturn.rings.get(0).particles.get(0);
    ////voyager.updatePos(SCALE*m2.position.x, SCALE*m2.position.y, 2*m2.radius*SCALE);
    //PVector np = new PVector(SCALE*p.position.x, SCALE*p.position.y, SCALE*p.position.z);
    //voyager.updatePos(np);
    break;

  case posiedState:
    break;

  case ringmoonState:
    break;

  case tuningState:
    break;

  case outroState:
    break;

  case fadetoblack:
    // check all rings
    for (Ring r : Saturn.rings) {
      if (r.material !=null) {
        if (r.material.partAlpha>=1) {
          r.material.partAlpha -=0.5;
        }
      }
    }

    break;

  case fadeup:
    // check all rings
    for (Ring r : Saturn.rings) {
      if (r.material !=null) {
        if (r.material.partAlpha<=254) {
          r.material.partAlpha +=0.5;
        }
      }
    }
    //for (Moon m : Saturn.moons){
    //    if (m.material.partAlpha<=255) {
    //     m.material.partAlpha +=0.5;
    //   }
    //}

    break;

  case nocamlock:
    //no camera settings locked down. meaning when we finish our path1-3 we stay where we end ratehr than jump back to where we were before we triggerd it. this depends on brons scenes
    break;
  }




  // renderOffScreenOnPGraphics(); // this fills the diffuse texture
  // renderOffScreenOnPGraphics2(); // this is the keyhole overlay
  renderOffScreenOnPGraphicsClean();


  //default render must stay
  rsRenderer.withMoon = drawMoons;
  rsRenderer.ringNumber = ringCnt;
  rsRenderContext.mat.diffTexture = pg;

  if (Shearing) {
    renderOffScreenOnPGraphics(); //optional shader overlay for effects
    rsRenderer.renderShear(s, rsRenderContext, 1);
  } else if (Tilting) {
    rsRenderer.renderTilt(Saturn, rsRenderContext, 1);
  } else if (Connecting) {
    renderOffScreenOnPGraphics();
    //rsRenderer.render(Saturn, rsRenderContext,2);
    rsRenderer.renderComms(Saturn, rsRenderContext, 1);
  } else if (Finale) {
    renderOffScreenOnPGraphics();
    rsRenderer.renderComms(Saturn, rsRenderContext, 1);
  } else {
    rsRenderer.render(Saturn, rsRenderContext, 1); //1 for points
  }

  // test for something funky
  if (useFilters) {
    applyFilters();
  }
}
