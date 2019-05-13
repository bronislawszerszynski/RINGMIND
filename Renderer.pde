//Render System
RingSystemRenderer rsRenderer;
RenderContext rsRenderContext;
PGraphics pg;
PShader offscreenShader;

// render global variables
boolean drawMoons = true;
boolean useAdditiveBlend = false;
boolean useTrace = false;
boolean useFilters = false;
int traceAmount=70;
int ringCnt = 10; // how many rings to render

//----------------------------------------------------------------------------------------------------------------------------------------

void renderSetup() {
    // --------------renderer setup------------------
  rsRenderer = new RingSystemRenderer();
  rsRenderer.withMoon = false;
  rsRenderContext = new RenderContext();
  rsRenderContext.pgfx = this;
  rsRenderContext.shader = loadShader("texfrag.glsl", "texvert.glsl");
  rsRenderContext.mat.spriteTexture = loadImage("partsmall.png");
  pg = createGraphics(1024, 1024, P3D);
  rsRenderContext.mat.diffTexture = pg;
  rsRenderContext.mat.strokeColor = 255;
  offscreenShader = loadShader("cloudy.glsl");
  
  loadFilters();    //LOAD CUSTOM FILTERS
}

// default overlay render using shader
void renderOffScreenOnPGraphics() {
  pg.beginDraw();
  pg.shader(offscreenShader);
  offscreenShader.set("resolution", float(pg.width), float(pg.height));
  offscreenShader.set("time", float(millis()));
  pg.rect(0, 0, pg.width, pg.height);
  pg.endDraw();
}

//a little keyhole example
void renderOffScreenOnPGraphics2() {
  pg.beginDraw();
  pg.background(0, 0, 0);
  //pg.stroke(255);
  //pg.fill(255);
  //pg.strokeWeight(100);
  //pg. line(0,0,pg.wdith,pg.height);

  pg.ellipse(mouseX, mouseY, 200, 200);
  pg.endDraw();
}

void renderOffScreenOnPGraphicsClean() {
  pg.beginDraw();
  pg.background(255, 255, 255); //no shader diffuse texture over the top
  pg.endDraw();
}

//-----------------------------------------------------------------------------------------

class RenderContext {
  RenderContext() {
    mat = new Material();
  }
  PShader shader;
  Material mat;
  PApplet pgfx;
}

//-----------------------------------------------------------------------------------------

class RingSystemRenderer {
  boolean withMoon = true;

  int ringNumber = 1;

  void render(RingSystem rs, RenderContext ctx, int renderType) {
    PGraphicsOpenGL pg = (PGraphicsOpenGL) ctx.pgfx.g;

    push();
    shader(ctx.shader, POINTS);

    //quick hack to show we can render each ring as and when
    ringNumber = min(ringNumber, rs.rings.size());
    for (int i = 0; i < ringNumber; i++) {
      Ring r = rs.rings.get(i);
      Material mat = r.material;
      if (mat == null) {
        mat = ctx.mat;
      }
      stroke(mat.strokeColor, mat.partAlpha);
      strokeWeight(mat.strokeWeight);

      ctx.shader.set("weight", mat.partWeight);
      ctx.shader.set("sprite", mat.spriteTexture);
      ctx.shader.set("diffTex", mat.diffTexture);
      ctx.shader.set("view", pg.camera); //don't touch that :-)


      if (renderType==1) {
        beginShape(POINTS);
      } else {
        beginShape(LINES);
      }
      for (int ringI = 0; ringI < r.getMaxRenderedParticle(); ringI++) {
        RingParticle p = r.particles.get(ringI);
        vertex(SCALE*p.position.x, SCALE*p.position.y, SCALE*p.position.z);
      }
      endShape();
    }
    pop();

    if (withMoon) {
      ellipseMode(CENTER);
      push();
      for (Moon m : rs.moons) {
        pushMatrix();
        //translate(width/2, height/2);
        fill(m.c);
        stroke(m.c);
        //strokeWeight(m.radius*SCALE);
        strokeWeight(1);

        //beginShape(POINTS);
        translate(SCALE*m.position.x, SCALE*m.position.y, 0);
        sphere(m.radius*SCALE);
        //vertex(SCALE*m.position.x, SCALE*m.position.y, 2*m.radius*SCALE);
        //endShape();
        // circle(scale*position.x, scale*position.y, 2*radius*scale);
        popMatrix();
      }
      pop();
    }
  }

  //-----------------------------------------------------------------------------------------

  void renderShear(ShearingBox ss, RenderContext ctx, int renderType) {
    PGraphicsOpenGL pg = (PGraphicsOpenGL) ctx.pgfx.g;

    push();
    shader(ctx.shader, POINTS);

    // Ring r = rs.rings.get(i);
    Material mat = ss.material;
    if (mat == null) {
      mat = ctx.mat;
    }

    stroke(mat.strokeColor, mat.partAlpha);
    strokeWeight(mat.strokeWeight);

    ctx.shader.set("weight", mat.partWeight);
    ctx.shader.set("sprite", mat.spriteTexture);
    ctx.shader.set("diffTex", mat.diffTexture);
    ctx.shader.set("view", pg.camera); //don't touch that :-)

    beginShape(POINTS);
    for (int PP = 0; PP < num_particles; PP++) {
      ShearParticle sp = ss.Sparticles.get(PP);
      vertex(-sp.position.y*width/Ly, -sp.position.x*height/Lx, 2*scale*sp.radius*width/Ly, 2*scale*sp.radius*height/Lx);
    }
    endShape();
    pop();

    //moonlet
    if (Moonlet) {
      //ellipseMode(CENTER);
      //push();
      // translate(0, 0);
      // fill(0);
      // sphere(moonlet_r/8);
      //  pop();
    }
  }

  void renderTilt(RingSystem rs, RenderContext ctx, int renderType) {
    PGraphicsOpenGL pg = (PGraphicsOpenGL) ctx.pgfx.g;

    push();
    shader(ctx.shader, POINTS);

    Ring r = rs.rings.get(0);
    // Ring r = rs.rings.get(i);

    Material mat = r.material;
    if (mat == null) {
      mat = ctx.mat;
    }

    stroke(mat.strokeColor, mat.partAlpha);
    strokeWeight(mat.strokeWeight);

    ctx.shader.set("weight", mat.partWeight);
    ctx.shader.set("sprite", mat.spriteTexture);
    ctx.shader.set("diffTex", mat.diffTexture);
    ctx.shader.set("view", pg.camera); //don't touch that :-)

    beginShape(POINTS);
    for (int ringI = 0; ringI < r.Tparticles.size(); ringI++) {
      TiltParticle tp = r.Tparticles.get(ringI);
      PVector position1 = displayRotate(tp);
      vertex(SCALE*position1.x, SCALE*position1.y, SCALE*position1.z);
    }
    endShape();

    pop();
  }

  //----------------------------------

  void renderComms(RingSystem rs, RenderContext ctx, int renderType) {

    // this is just when we have one ring.


    PGraphicsOpenGL pg = (PGraphicsOpenGL) ctx.pgfx.g;

    push();
    shader(ctx.shader, POINTS);

    Ring r = rs.rings.get(0);
    // Ring r = rs.rings.get(i);

    Material mat = r.material;
    if (mat == null) {
      mat = ctx.mat;
    }

    stroke(mat.strokeColor, mat.partAlpha);
    strokeWeight(mat.strokeWeight);

    ctx.shader.set("weight", mat.partWeight);
    ctx.shader.set("sprite", mat.spriteTexture);
    ctx.shader.set("diffTex", mat.diffTexture);
    ctx.shader.set("view", pg.camera); //don't touch that :-)


    //now lets go through all those particles and see if they are near to another and draw lines between them

    //for (int i=0; i <1000; i++){
    //  RingParticle rp = (RingParticle) r.particles.get(i);
    //  float distance=0;
    //   for (int j=0; j <1000; j++){
    //     RingParticle rpj = (RingParticle) r.particles.get(j);
    //     distance = dist(SCALE*rp.position.x,SCALE*rp.position.y, SCALE*rpj.position.x, SCALE*rpj.position.y);
    //     if (distance < 10){
    //       stroke(255);
    //       strokeWeight(1);
    //       line(SCALE*rp.position.x,SCALE*rp.position.y, SCALE*rpj.position.x, SCALE*rpj.position.y);
    //     }
    //   }
    //}
    beginShape(LINES);
    for (int i=0; i <1000; i++) {
      RingParticle rp = (RingParticle) r.particles.get(i);
      float distance=0;
      for (int j=0; j <3000; j++) {
        RingParticle rpj = (RingParticle) r.particles.get(j);
        distance = dist(SCALE*rp.position.x, SCALE*rp.position.y, SCALE*rpj.position.x, SCALE*rpj.position.y);
        if (distance < 20) {
          //stroke(255);
          //strokeWeight(10);
          //beginShape(LINES);
          vertex(SCALE*rp.position.x, SCALE*rp.position.y);
          vertex(SCALE*rpj.position.x, SCALE*rpj.position.y);
          //endShape();
        }
      }
    }
    endShape();

    pop();
  }
}

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------

//custom shaders for filter effects

PShader gaussianBlur, metaBallThreshold;

void loadFilters(){
  
   // Load and configure the filters
  gaussianBlur = loadShader("gaussianBlur.glsl");
  gaussianBlur.set("kernelSize", 32); // How big is the sampling kernel?
  gaussianBlur.set("strength", 7.0); // How strong is the blur?
  
  //maybe? gives a kind of metaball effect but only at certain angles
  metaBallThreshold = loadShader("threshold.glsl");
  metaBallThreshold.set("threshold", 0.5);
  metaBallThreshold.set("antialiasing", 0.05); // values between 0.00 and 0.10 work best
}

void applyFilters(){
   // Vertical blur pass
  gaussianBlur.set("horizontalPass", 0);
  filter(gaussianBlur);
  
  // Horizontal blur pass
  gaussianBlur.set("horizontalPass", 1);
  filter(gaussianBlur);
  
  //remove this for just a blurry thing without going to black and white but when backgroudn trails work could be glorious overly bright for teh abstract part
 // filter(metaBallThreshold); //this desnt work too well with depth rendering.
  }
