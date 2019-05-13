
//----------Palette-----------------
//#FEB60A,#FF740A,#D62B00,#A30000,#640100,#FEB60A,#FF740A,#D62B00
//fire
//153,21,245
//----------------------------------

//-----------------------------------------------------------------------------------------

class Material {
  PImage diffTexture;
  PImage spriteTexture;
  float partWeight = 1;  //do not change or sprite texture wont show unles its 1
  color strokeColor = 255;
  float partAlpha = 0; //trick t fade out to black
  float strokeWeight = 1; //usually 1 so we can see our texture but if we turn off we can make a smaller particle point as liong as the weight above is bigger than 1
}

//-----------------------------------------------------------------------------------------

Material RingMat1, RingMat2, RingMat3, RingMat4, RingMat5, RingMat6;

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


  //pink
  // second ring material to be different just as proof of concept
  RingMat2 =  new Material();
  RingMat2.strokeColor = color(203, 62, 117);
  RingMat2.spriteTexture = loadImage("partsmall.png");
  RingMat2.diffTexture = pg;
  RingMat2.strokeWeight = 2.1;//.1
  RingMat2.partWeight = 10;
  RingMat2.partAlpha=255;


  // second ring material to be different just as proof of concept
  //more blue
  RingMat3 =  new Material();
  RingMat3.strokeColor = color(54, 73, 232);
  RingMat3.spriteTexture = loadImage("partsmall.png");
  RingMat3.diffTexture = pg;
  RingMat3.strokeWeight = 2.1;//.1
  RingMat3.partWeight = 10;
  RingMat3.partAlpha=255;

  //white
  ShearMat1 =  new Material();
  ShearMat1.strokeColor = color(255, 255, 255);
  ShearMat1.spriteTexture = loadImage("partsmall.png");
  ShearMat1.diffTexture = pg;
  ShearMat1.strokeWeight = 2.1;//.1
  ShearMat1.partWeight = 10;
  ShearMat1.partAlpha=255;

  RingMat4 =  new Material();
  RingMat4.strokeColor = color(204, 206, 153);
  RingMat4.spriteTexture = loadImage("partsmall.png");
  RingMat4.diffTexture = pg;
  RingMat4.strokeWeight = 2.1;//.1
  RingMat4.partWeight = 10;
  RingMat4.partAlpha=255;

  RingMat5 =  new Material();
  RingMat5.strokeColor = color(153, 21, 245);
  RingMat5.spriteTexture = loadImage("partsmall.png");
  RingMat5.diffTexture = pg;
  RingMat5.strokeWeight = 2.1;//.1
  RingMat5.partWeight = 10;
  RingMat5.partAlpha=255;

  RingMat6 =  new Material();
  RingMat6.strokeColor = color(24, 229, 234);
  RingMat6.spriteTexture = loadImage("partsmall.png");
  RingMat6.diffTexture = pg;
  RingMat6.strokeWeight = 2.1;//.1
  RingMat6.partWeight = 10;
  RingMat6.partAlpha=255;
}

void applyBasicMaterials() {

  for (Ring r : Saturn.rings) {
    r.material = RingMat1;
  }
}
