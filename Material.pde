
Material RingMat1, RingMat2, RingMat3;

Material ShearMat1;

void createMaterials() {
  //----------- Materials per ring

  // first ring material is teh deafult material fully showing
  RingMat1 =  new Material();
  RingMat1.strokeColor = color(255, 255, 255);
  RingMat1.spriteTexture = loadImage("partsmall.png");
  RingMat1.diffTexture = pg;
  RingMat1.strokeWeight = 1; //.1;
  RingMat1.partWeight = 10;
  RingMat1.partAlpha=255;


  // second ring material to be different just as proof of concept
  RingMat2 =  new Material();
  RingMat2.strokeColor = color(203, 62, 117);
  RingMat2.spriteTexture = loadImage("partsmall.png");
  RingMat2.diffTexture = pg;
  RingMat2.strokeWeight = 2.1;//.1
  RingMat2.partWeight = 10;
  //RingMat2.partAlpha=255;


  // second ring material to be different just as proof of concept
  RingMat3 =  new Material();
  RingMat3.strokeColor = color(54, 73, 232);
  RingMat3.spriteTexture = loadImage("partsmall.png");
  RingMat3.diffTexture = pg;
  RingMat3.strokeWeight = 2.1;//.1
  RingMat3.partWeight = 10;
  //RingMat2.partAlpha=255;
  
  
  ShearMat1 =  new Material();
  ShearMat1.strokeColor = color(255, 255, 255);
  ShearMat1.spriteTexture = loadImage("partsmall.png");
  ShearMat1.diffTexture = pg;
  ShearMat1.strokeWeight = 20.1;//.1
  ShearMat1.partWeight = 1;
  ShearMat1.partAlpha=255;
  
}


void applyBasicMaterials() {
 
  //apply the new material to each ring required 
  Saturn.rings.get(0).material = RingMat1;
  //Saturn.rings.get(2).material = RingMat2;
  //Saturn.rings.get(5).material = RingMat;
}
