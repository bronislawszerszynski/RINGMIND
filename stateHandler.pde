/**
 *  Different Display States - to be decided as go along. 
 */
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
    resonanceState,

    ringmindStableState, 
    ringmindUnstableState, 
    connectedState, 
    saturnState, 
    ringboarderState, 
    addAlienLettersState, 


    fadetoblack, 
    fadeup, 
    nocamlock
};

/*
  Brons scenarios from script
 
 intro - distant view of ring
 ringmind - move in clsoer to view moon and ring
 
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

Boolean Running;
Boolean Add, clear; // for when we switch from ringsystem to shearsystem5
Boolean Tilting, Shearing; // for when we switch to titl system
Boolean Connecting = false;
Boolean MoonAlignment = false; // for when we want to send moon alignment info to tony and we need to not thread the system.
Boolean Threading = false;
Boolean Finale=false;

/**
 * Method that called at the start of the state. 
 */
void setupStates() {
  Running = true;
  Add=false;
  clear=false;
  Shearing=false;
  Tilting=false; 
  Connecting=false;
  Threading=false;
  useTrace=false;
  useAdditiveBlend=false;
  useFilters=false;
  drawMoons=true;

  G=6.67408E-11;
  simToRealTimeRatio = 3600.0/1.0;  



  switch(systemState) {
  case initState:

    setupOSC();
    renderSetup();
    initScene();   //setup proscene camera and eye viewports etc
    createMaterials();       //extra materials we can apply to the rings

    //init with = rings 10,  moons 4, rendering normal =true (titl would be false);
    Saturn = new RingSystem(10, 4, true);  
    applyBasicMaterials();
    sendOSC(Saturn); //osc sound engine init data

    break;

  case introState:

    initCamera();
    Saturn = new RingSystem(2, 2, true); //ringtpe, moon type, tilt/nottilt
    applyBasicMaterials();
    for (Ring r : Saturn.rings) {
      r.material = RingMat3;
    }

    sendOSC(Saturn);

    break;

  case ringmindStableState:

    useAdditiveBlend=true;
    closerCamera();
    Saturn = new RingSystem(10, 4, true);
    applyBasicMaterials();
    for (Ring r : Saturn.rings) {
      r.material = RingMat3;
    }
    Saturn.rings.get(0).material = RingMat4;
    Saturn.rings.get(1).material = RingMat2;
    Saturn.rings.get(2).material = RingMat2;
    Saturn.rings.get(3).material = RingMat6;
    Saturn.rings.get(4).material = RingMat6;
    Saturn.rings.get(5).material = RingMat5;
    sendOSC(Saturn);
    break;

  case ringmindUnstableState:

    closerCamera();
    useAdditiveBlend=true;
    G=6.67408E-9;
    Saturn = new RingSystem(11, 4, true);
    applyBasicMaterials();
    for (Ring r : Saturn.rings) {
      r.material = RingMat3;
    }
    Saturn.rings.get(0).material = RingMat4;
    Saturn.rings.get(1).material = RingMat2;
    Saturn.rings.get(2).material = RingMat2;
    Saturn.rings.get(3).material = RingMat6;
    Saturn.rings.get(4).material = RingMat6;
    Saturn.rings.get(5).material = RingMat5;
    break;

  case connectedState:

    useAdditiveBlend=true;
    Connecting=true; 
    //simToRealTimeRatio = 360.0/1.0; //slow it down
    zoomedCamera();
    Saturn = new RingSystem(1, 2, true);
    Saturn.rings.get(0).material = RingMat2;
    break;

  case saturnState:

    Saturn = new RingSystem(2, 4, true);
    applyBasicMaterials();
    for (Ring r : Saturn.rings) {
      r.material = RingMat1;
    }
    break;

  case ringboarderState:

    //zoomedCamera();
    initCamera();
    Saturn = new RingSystem(13, 0, true);
    applyBasicMaterials();
    for (Ring r : Saturn.rings) {
      r.material = RingMat5;
    }

    break;
  case addAlienLettersState:

    Saturn.rings.add(new Ring(1, 1, 3, 0));
    Saturn.addParticlesFromTable("outputParticles.csv");
    Saturn.rings.get(1).setMaxRenderedParticle(Saturn.rings.get(1).particles.size());
    applyBasicMaterials();
    for (Ring r : Saturn.rings) {
      r.material = RingMat5;
    }
    break;

    //case makingState:
    //  break;

  case chaosState:

    Tilting=true; 
    useAdditiveBlend=true;
    //zoomedCamera();
    Saturn = new RingSystem(9, 2, false); //ring type 9 as its a tilt type, moon type2 and tilt type2 //new materials for every ring
    for (Ring r : Saturn.rings) {
      r.material = RingMat1;
    }
    break;

  case orbitalState:

    drawMoons=false;
    Threading=true;
    toptiltCamera();
    G=6.67408E-13;
    Saturn = new RingSystem(1, 2, true);
    applyBasicMaterials();
    for (Ring r : Saturn.rings) {
      r.material = RingMat5;
    }
    for (Moon m : Saturn.moons) {
      m.radius = 1;
    }

    Saturn.moons.get(2).GM =4.529477495e13;
    Saturn.moons.get(0).GM =2.529477495e13;

    break;

  case shearState:
    simToRealTimeRatio = 2000.0/1.0;  
    Shearing=true;
    useAdditiveBlend=true;
    zoomedCamera();
    s = new ShearingBox();

    break;
    
  case resonanceState:
    Saturn = new RingSystem(1, 5, true);
    applyBasicMaterials();
    
    break;

    //  case followState:
    //    break;

    //  case posiedState:
    //    break;

    //  case ringmoonState:
    //    break;

    //  case tuningState:
    //    break;

    //  case outroState:
    //    break;

    //  case fadetoblack:
    //    break;

    //  case fadeup:
    //    break;

    //  case nocamlock:
    //    break;
  }
}


//---------------------------------------------------------------------------------------------------




void updateCurrentScene(int t) {

  //*************time step******************

  if (simToRealTimeRatio/frameRate < maxTimeStep) {
    dt= simToRealTimeRatio/frameRate;
  } else {
    dt= maxTimeStep;
    println("At Maximum Time Step");
  }


  // now regardless of scene do this
  if (Running) {
    if (Threading) {
      thread("update");
    } else if (Tilting) {
      Saturn.tiltupdate();
    } else if (Shearing) {
      s.update();
    } else {
      //thread("update"); //my imac needs this threading or it all slows down computing the physics
      Saturn.update();
    }
  }


  if (useTrace) {
    scene.beginScreenDrawing();
    fill(0, traceAmount);
    rect(0, 0, width, height);
    scene.endScreenDrawing();
  } else {
    background(0);
  }



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

  totalSimTime += dt;

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

  titleText(); //debug info on frame title

  // test for something funky
  if (useFilters) {
    applyFilters();
  }
}

//--------------------------------------------------------------------------------------------------------

//    //reinit plus some options
//    G=6.67408E-9;
//    Saturn = new RingSystem(11, 4, true);
//    applyBasicMaterials();

//    //new materials for every ring
//    for (Ring r : Saturn.rings) {
//      r.material = RingMat3;
//    }

//    for (Moon m : Saturn.moons) {
//      m.radius = 5;
//    }

//    camera10();
//    useAdditiveBlend=true;
//    useTrace=false;
//    Threading=false;
//    Shearing=false;
//    Tilting=false;
//    //fade us back up or press x to do it manually
//    systemState= State.fadeup;

//------------------------------------

//Removes Inner Most Ring
//Saturn.rings.remove(0);

//--------------------------------------------------------------------------

//Saturn.rings.get(0).material = RingMat1;
//Saturn.rings.get(1).material = RingMat3; //same as below
//Saturn.rings.get(2).material = RingMat3;
//Saturn.rings.get(3).material = RingMat1;
//Saturn.rings.get(4).material = RingMat1;
//Saturn.rings.get(5).material = RingMat5;

//closerCamera();

//// useAdditiveBlend=true;
//useFilters=false;

//sendOSC(Saturn);

//------------------------------------------------------------------------

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
// evaluate what state determine time and then transition to the next state

void evaluateScenario() {

  int t =millis();
}
