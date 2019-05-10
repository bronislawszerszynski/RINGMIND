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
