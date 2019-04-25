// new render class
// do not modify


class RenderContext {
  RenderContext() {
    mat = new Material();
  }
  PShader shader;
  Material mat;
  PApplet pgfx;
}


class Material {
  PImage diffTexture;
  PImage spriteTexture;
  float partWeight = 1;  //do not change or sprite texture wont show unles its 1
  color strokeColor = 255;
  float partAlpha = 0; //trick t fade out to black
  float strokeWeight = 1; //usually 1 so we can see our texture but if we turn off we can make a smaller particle point as liong as the weight above is bigger than 1
}

//-------------------------------------------------

class RingSystemRenderer {
  boolean withMoon = true;

  int ringNumber = 1;

  //----------------------------------------------------------------

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
        strokeWeight(5);
        beginShape(POINTS);
        //translate(scale*m.position.x, scale*m.position.y, 2*m.radius*scale);
        //sphere(1);
        vertex(SCALE*m.position.x, SCALE*m.position.y, 2*m.radius*SCALE);
        endShape();
        //circle(scale*position.x, scale*position.y, 2*radius*scale);
        popMatrix();
      }
      pop();
    }
  }



  //----------------------------------------------------------------------------------------------------------
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
      ellipseMode(CENTER);
      push();
      translate(0, 0);
      fill(255);
      sphere(moonlet_r/4);
      pop();
    }
  }
  
  //-----------------------------------------------------------------------------------------------------

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
    for (int i=0; i <1000; i++){
      RingParticle rp = (RingParticle) r.particles.get(i);
      float distance=0;
       for (int j=0; j <3000; j++){
         RingParticle rpj = (RingParticle) r.particles.get(j);
         distance = dist(SCALE*rp.position.x,SCALE*rp.position.y, SCALE*rpj.position.x, SCALE*rpj.position.y);
         if (distance < 20){
           //stroke(255);
           //strokeWeight(10);
           //beginShape(LINES);
           vertex(SCALE*rp.position.x,SCALE*rp.position.y);
           vertex(SCALE*rpj.position.x, SCALE*rpj.position.y);
           //endShape();
         }
       }
    }
    endShape();

    pop();
  }
}
