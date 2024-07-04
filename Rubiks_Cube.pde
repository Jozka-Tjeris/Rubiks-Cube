import java.util.Arrays;
import java.util.LinkedList;
import java.util.Collections;

boolean rotateX = false;
boolean rotateY = false;
boolean rotateZ = false;
boolean isClockwise = true;
boolean upKeyPressed = false;
boolean downKeyPressed = false;
boolean leftKeyPressed = false;
boolean rightKeyPressed = false;
boolean lessThanKeyPressed = false;
boolean moreThanKeyPressed = false;
boolean spacebarPressed = false;
boolean mouseHeldDown = false;
PFont f;

Cube cube;
int size = 3;
int currentDepth = 0;
PVector rotation = new PVector(0, 0, 0);
PVector center = new PVector(400, 400, 0);
int[] blockLengths = {106, 204/2, 222/3, 240/4, 240/5, 240/6, 280/7, 320/8, 324/9, 400/10};
float[] marginOfErrors = {0, 0, 0.1, 0.1, 0.1, 0.1, 0.3, 0.3, 0.3, 0.3};

//f = (s - n)/2
float[] cameraDistanceFactors = {9, 16, 19, 20, 25, 30, 35, 48, 55, 60};
float[] scalingFactors =        {4, 7 , 8 , 8 , 10, 12, 14, 20, 23, 25};

float[] cosTable = new float[720];
float[] sinTable = new float[720];

PVector prevPos = new PVector(400, 400, 0);
PVector currPos = new PVector(400, 400, 0);
float scaleFactor = 0.9;

int idx = 0;
int movingCounter = 0;
boolean fillBlocks = true;
boolean doubleTurn = false;

final color RFace = color(240, 0, 0);
final color LFace = color(240, 120, 0);
final color FFace = color(0, 240, 0);
final color BFace = color(0, 0, 240);
final color UFace = color(250);
final color DFace = color(240, 240, 0);
final color blockFill = color(30);
final color blockStroke = color(50);

public void setup(){
  size(800, 800);
  f = createFont("TimesNewRomanPSMT", 20);
  textFont(f);
  
  for(int i = 0; i < 720; i++){
    cosTable[i] = cos((float)Math.toRadians(i * 0.5));
    sinTable[i] = sin((float)Math.toRadians(i * 0.5));
  }
  
  //clamp size number
  if(size < 1) size = 1;
  if(size > 10) size = 10;
  
  //Note: For frame cube, anything over size 7 will cause lag
  
  //create new cube
  cube = new Cube(size, blockLengths[size - 1], fillBlocks);
}

public void draw(){
  background(200);
  
  cube.show();
  updateCubeRotationState();
  showMetrics();
  cube.updateMoves();
  
  if(mouseHeldDown){
    strokeWeight(8);
    stroke(0);
    point(mouseX, mouseY);
  }
  findAxis(mouseHeldDown);
}

public void keyPressed(){
  if(key == 'i') isClockwise = !isClockwise;
  if(keyCode == SHIFT) isClockwise = false;
  
  if(keyCode == '\t') doubleTurn = true;
  
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
  
  if(key == '\n'){
    spacebarPressed = false;
    rotateX = false;
    rotateY = false;
    rotateZ = false;
    cube.reset();
  }

  if(key == 'u' || key == 'U') cube.addMove(Moves.U, currentDepth, isClockwise, (doubleTurn ? 2 : 1));
  if(key == 'd' || key == 'D') cube.addMove(Moves.D, currentDepth, isClockwise, (doubleTurn ? 2 : 1));
  if(key == 'f' || key == 'F') cube.addMove(Moves.F, currentDepth, isClockwise, (doubleTurn ? 2 : 1));
  if(key == 'b' || key == 'B') cube.addMove(Moves.B, currentDepth, isClockwise, (doubleTurn ? 2 : 1));
  if(key == 'l' || key == 'L') cube.addMove(Moves.L, currentDepth, isClockwise, (doubleTurn ? 2 : 1));
  if(key == 'r' || key == 'R') cube.addMove(Moves.R, currentDepth, isClockwise, (doubleTurn ? 2 : 1));
  
  if(key == 'q'){
    idx = (idx + 1) % cube.displayOrder.size();
  }
  
  if(key == 'e'){
    idx = 0;
    cube.generateDisplayOrder(cube.blockGroups);
  }
  
  if(keyCode == BACKSPACE && cube.turnQueue.size() > 0) cube.turnQueue.removeLast();
  
  if('1' <= key && key <= '9') setDepth(key - '0');
}

public void keyReleased(){
  if(keyCode == SHIFT) isClockwise = true;
  if(keyCode == '\t') doubleTurn = false;
  if(keyCode == UP) upKeyPressed = false;
  if(keyCode == DOWN) downKeyPressed = false;
  if(keyCode == RIGHT) rightKeyPressed = false;
  if(keyCode == LEFT) leftKeyPressed = false;
  if(key == ',') lessThanKeyPressed = false;
  if(key == '.') moreThanKeyPressed = false;
}

public void showMetrics(){
  textFont(f);
  fill(0);
  text("x: " + cube.blocks[0].rotation.x + (char)0x00B0, 10, 30);
  text("y: " + cube.blocks[0].rotation.y + (char)0x00B0, 10, 60);
  text("z: " + cube.blocks[0].rotation.z + (char)0x00B0, 10, 90);
  String direction = (isClockwise) ? "Clockwise" : "Counter-Clockwise";
  text("Direction: " + direction, 10, 120);
  text("Current Layer: " + (currentDepth + 1), 10, 150);
  text("Turn mode: " + (doubleTurn ? "Double" : "Single"), 10, 180);
  text("Moves List:", 10, 210);
  String s = (cube.currentTurn != null) ? cube.currentTurn.getInformation() + " " : "";
  for(Turn t: cube.turnQueue){
    s += t.getInformation() + " ";
  }
  text(s, 10, 240);
}

public void updateCubeRotationState(){  
  int amount = 1;
  if(isClockwise) amount = -1;
  int rotationSpeed = 2;
  
  if(upKeyPressed) cube.updateState('x', 1*rotationSpeed);
  if(downKeyPressed) cube.updateState('x', -1*rotationSpeed);
  if(rightKeyPressed) cube.updateState('y', 1*rotationSpeed);
  if(leftKeyPressed) cube.updateState('y', -1*rotationSpeed);
  if(lessThanKeyPressed) cube.updateState('z', -1*rotationSpeed);
  if(moreThanKeyPressed) cube.updateState('z', 1*rotationSpeed);
  
  if(spacebarPressed){
    cube.updateState('x', amount*rotationSpeed);
    cube.updateState('y', amount*rotationSpeed);
    cube.updateState('z', amount*rotationSpeed);
  }else{
    if(rotateX) cube.updateState('x', amount*rotationSpeed);
    if(rotateY) cube.updateState('y', amount*rotationSpeed);
    if(rotateZ) cube.updateState('z', amount*rotationSpeed);
  }
}

public void mousePressed(){
  mouseHeldDown = true;
}

public void mouseReleased(){
  mouseHeldDown = false;
}

public void findAxis(boolean hasNewPos){
  currPos.x = mouseX;
  currPos.y = mouseY;
  
  if(!hasNewPos){
    prevPos.x = mouseX;
    prevPos.y = mouseY;
  }

  int xDisp = (int)(currPos.x - prevPos.x)/2;
  int yDisp = (int)(currPos.y - prevPos.y)/2;
  
  cube.updateState('x', -yDisp);
  cube.updateState('y', xDisp);
  
  prevPos.x = currPos.x;
  prevPos.y = currPos.y;
}

//This project uses the CubeRotation Sketch as the foundation
//Main video used as source: https://www.youtube.com/watch?v=p4Iz0XJY-Qk
//CubeRotation notes:
//27 May: Added graphics for points
//28 May: Added lines to make box, added rotations, added directional axes, added the ability to offset the block
//
//Rubiks_Cube notes: 
//28 May: Added displacement generator
//29 May: Added Cube class to consolidate the blocks and axis, created a 3D space of cubes
//30 May: Corrected the display of the cube (selective face-rendering), removing unneccessary shapes
//31 May: Added coloured tiles
//1 Jun: Started to add weak perspective projection
//2 Jun: Added weak perspective projection
//3 Jun: Applied colored tiles using new weak perspective projection method
//7 Jun: Learning how proper 3D rotations work
//9 Jun: Added proper 3D rotations
//14 & 15 Jun: Overhauled the cube display algorithm to facilitate turns
//16 Jun: Added surface-level turns (without reference switching)
//17 Jun: Added Turn class (Cleaned up code)
//18 Jun: Added reference switching (allowing turns on multiple faces)
//19 Jun: Refactored some code (reference switching)
//20-21 Jun: Added slices (turns on inner layers)
//22 Jun: Fixed the reset button, removed old code (matrix transformation-based rotations)
//26-27 Jun: Improved the rendering process when doing slice turns
//28-29 Jun: Tweaked the rendering process to reduce computations and increase reliability
//1-2 Jul: Fixed the rendering process to handle surface and slice turns, added option to change depth and direction of turns
//2 Jul: Fixed the turn input system, added list to store multiple moves at once, added a way to delete turns, 
//2 Jul: added hotfix for rendering odd-layered cubes (incorrect indexing) and layer switching
//3 Jul: Started adding solid block colors to the cube, attempting to fix turn rendering to accomodate the new feature
//4 Jul: Fixed the face-rendering system to accomodate for extra faces (solid-blocks setting only), added double turns
