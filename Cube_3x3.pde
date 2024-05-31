boolean rotateX = false;
boolean rotateY = false;
boolean rotateZ = false;
boolean reversed = false;
boolean upKeyPressed = false;
boolean downKeyPressed = false;
boolean leftKeyPressed = false;
boolean rightKeyPressed = false;
boolean lessThanKeyPressed = false;
boolean moreThanKeyPressed = false;
boolean spacebarPressed = false;
PFont f;

Cube cube;
int size = 3;
PVector rotation = new PVector(0, 0, 0);
PVector center = new PVector(400, 400, 0);
int[] blockLengths = {106, 204/2, 222/3, 240/4, 240/5, 240/6, 280/7, 320/8, 324/9, 400/10};
int margin = 4;

float[] cosTable = new float[360];
float[] sinTable = new float[360];

void setup(){
  size(800, 800);
  f = createFont("TimesNewRomanPSMT", 20);
  textFont(f);
  
  for(int i = 0; i < 360; i++){
    cosTable[i] = cos((float)Math.toRadians(i));
    sinTable[i] = sin((float)Math.toRadians(i));
  }
  
  //clamp size number
  if(size < 1) size = 1;
  if(size > 10) size = 10;
  
  //Note: For frame cube, anything over size 7 will cause lag
  
  //create new cube
  cube = new Cube(size, blockLengths[size - 1]);
}

void draw(){
  background(250);
  
  cube.show();
  updateCubeRotationState();
  cube.update();
  
  showRotations();
}

void keyPressed(){
  if(key == 'i') reversed = !reversed;
  
  if(key == ' '){
    spacebarPressed = !spacebarPressed;
    rotateX = false;
    rotateY = false;
    rotateZ = false;
  }else{
    if(key == 'x') rotateX = !rotateX;
    if(key == 'y') rotateY = !rotateY;
    if(key == 'z') rotateZ = !rotateZ;
  }
  
  if(keyCode == UP) upKeyPressed = true;
  if(keyCode == DOWN) downKeyPressed = true;
  if(keyCode == RIGHT) rightKeyPressed = true;
  if(keyCode == LEFT) leftKeyPressed = true;
  if(key == ',') lessThanKeyPressed = true;
  if(key == '.') moreThanKeyPressed = true;
  
  if(key == 'r'){
    spacebarPressed = false;
    rotateX = false;
    rotateY = false;
    rotateZ = false;
    cube.resetDisplacement();
  }
}

void keyReleased(){
  if(keyCode == UP) upKeyPressed = false;
  if(keyCode == DOWN) downKeyPressed = false;
  if(keyCode == RIGHT) rightKeyPressed = false;
  if(keyCode == LEFT) leftKeyPressed = false;
  if(key == ',') lessThanKeyPressed = false;
  if(key == '.') moreThanKeyPressed = false;
}

void showRotations(){
  textFont(f);
  fill(0);
  text("x: " + cube.blocks[0].rotation.x + (char)0x00B0, 10, 30);
  text("y: " + cube.blocks[0].rotation.y + (char)0x00B0, 10, 60);
  text("z: " + cube.blocks[0].rotation.z + (char)0x00B0, 10, 90);
  String direction = "Clockwise";
  if(reversed) direction = "Counter-Clockwise";
  text("Direction: " + direction, 10, 120);
}

void updateCubeRotationState(){  
  float amount = 1;
  if(reversed) amount = -1;
  
  if(upKeyPressed) cube.transform('x', 1);
  if(downKeyPressed) cube.transform('x', -1);
  if(rightKeyPressed) cube.transform('y', 1);
  if(leftKeyPressed) cube.transform('y', -1);
  if(lessThanKeyPressed) cube.transform('z', -1);
  if(moreThanKeyPressed) cube.transform('z', 1);
  
  if(spacebarPressed){
    cube.transform('x', amount);
    cube.transform('y', amount);
    cube.transform('z', amount);
  }else{
    if(rotateX) cube.transform('x', amount);
    if(rotateY) cube.transform('y', amount);
    if(rotateZ) cube.transform('z', amount);
  }
}

float getCos(int angle){
  return cosTable[(angle + 360) % 360];
}

float getSin(int angle){
  return sinTable[(angle + 360) % 360];
}

//This project uses the CubeRotation Sketch as the foundation
//CubeRotation notes:
//27 May: Added graphics for points
//28 May: Added lines to make box, added rotations, added directional axes, added the ability to offset the block
//
//Cube_3x3 notes:
//28 May: Added displacement generator
//29 May: Added Cube class to consolidate the blocks and axis, created a 3D space of cubes
//30 May: Corrected the display of the cube (selective face-rendering), removing unneccessary shapes
//31 May: Added coloured tiles
