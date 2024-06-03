import java.util.Arrays;

class Block{
  PVector[] pointDisps = new PVector[8]; //TLB, TRB, BLB, BRB, TLF, TRF, BLF, BRF
  PVector[] perspectivePoints = new PVector[8]; //Points after perspective projection
  PVector[] interiorPoints = new PVector[8*3]; //Stores points for colored faces 
  //Each points has 3 different interior points: xy, xz, yz
  /*  
    Index to letter key:
    1  = White; A  2  = Orange; E  12 = Green; I  17 = Red; M  3  = Blue; Q  19 = Yellow; U
    4  = White; B  14 = Orange; F  15 = Green; J  5  = Red: N  0  = Blue; R  22 = Yellow; V
    16 = White; C  20 = Orange; G  18 = Green; L  11 = Red; O  6  = Blue; S  10 = Yellow; W
    13 = White; D  8  = Orange; H  21 = Green; K  23 = Red; P  9  = Blue; T  7  = Yellow; X
  */
  PVector center = new PVector(0, 0, 0);
  PVector currCenter = new PVector(0, 0, 0);
  float sideLength = 0;
  PVector distToCenter = new PVector(0, 0, 0); //stores it as a multiple of sideLength, not absolute distance
  PVector rotation = new PVector(0, 0, 0);
  int[] sideColors = {-1, -1, -1, -1, -1, -1}; //U, D, R, L, F, B
                    //-1 = draw nothing, 0 = black square, 1 = black square with color inside
  ArrayList<String> neighbors = new ArrayList<String>();
  
    
  Block(PVector v, float l){
    center = v.copy();
    sideLength = l;
    
    for(int i = 0; i < pointDisps.length; i++){
      pointDisps[i] = new PVector(2*(i & 1) - 1, 
                                  2*((i & 2) >> 1) - 1, 
                                  2*((i & 4) >> 2) - 1);
    }
    
    neighbors.addAll(Arrays.asList("F", "B", "U", "D", "L", "R"));
    
    PVector[] resultDisps = generateRotationVectors(rotation, pointDisps);
    PVector centerDisps = generateRotationVectors(rotation, new PVector[] {distToCenter})[0];
    perspectivePoints = applyPerspectiveProjection(resultDisps, centerDisps);
    
    for(int i = 0; i < pointDisps.length; i++){
      PVector smallerXY = pointDisps[i].copy();
      smallerXY.x *= 0.9;
      smallerXY.y *= 0.9;
      PVector XYcolors = applyPerspectiveProjection(
                            generateRotationVectors(rotation, new PVector[] {smallerXY}), centerDisps)[0];
      
      PVector smallerXZ = pointDisps[i].copy();
      smallerXZ.x *= 0.9;
      smallerXZ.z *= 0.9;
      PVector XZcolors = applyPerspectiveProjection(
                            generateRotationVectors(rotation, new PVector[] {smallerXZ}), centerDisps)[0];
      
      PVector smallerYZ = pointDisps[i].copy();
      smallerYZ.y *= 0.9;
      smallerYZ.z *= 0.9;
      PVector YZcolors = applyPerspectiveProjection(
                            generateRotationVectors(rotation, new PVector[] {smallerYZ}), centerDisps)[0];
            
      interiorPoints[i*3] = XYcolors;
      interiorPoints[i*3 + 1] = XZcolors;
      interiorPoints[i*3 + 2] = YZcolors;
    }
  }
  
  void removeNeighbor(String direction){
    if(!"FBUDLR".contains(direction)){
      return;
    }
    neighbors.remove(direction);
  }
  
  void setDistanceFactorFromCenter(PVector v){
    distToCenter = v.copy();
  }
  
  void showFace(Moves move){
    //stroke(60);
    noStroke();
    fill(30);
    if(sideColors[5] >= 0 && move == Moves.B){
      //4576, Z- face (B)
      quad(perspectivePoints[0].x, perspectivePoints[0].y, 
           perspectivePoints[1].x, perspectivePoints[1].y, 
           perspectivePoints[3].x, perspectivePoints[3].y, 
           perspectivePoints[2].x, perspectivePoints[2].y);
    }
    if(sideColors[4] >= 0 && move == Moves.F){
      //0132, Z+ face (F)
      quad(perspectivePoints[4].x, perspectivePoints[4].y, 
           perspectivePoints[5].x, perspectivePoints[5].y, 
           perspectivePoints[7].x, perspectivePoints[7].y, 
           perspectivePoints[6].x, perspectivePoints[6].y);
    }
    if(sideColors[0] >= 0 && move == Moves.U){
      //0154, Y- Face (U)
      quad(perspectivePoints[0].x, perspectivePoints[0].y,
           perspectivePoints[1].x, perspectivePoints[1].y, 
           perspectivePoints[5].x, perspectivePoints[5].y, 
           perspectivePoints[4].x, perspectivePoints[4].y);
    }
    if(sideColors[1] >= 0 && move == Moves.D){
      //2376, Y+ Face (D)
      quad(perspectivePoints[2].x, perspectivePoints[2].y, 
           perspectivePoints[3].x, perspectivePoints[3].y, 
           perspectivePoints[7].x, perspectivePoints[7].y, 
           perspectivePoints[6].x, perspectivePoints[6].y);
    }
    if(sideColors[3] >= 0 && move == Moves.L){
      //0264, X- Face (L)
      quad(perspectivePoints[0].x, perspectivePoints[0].y, 
           perspectivePoints[2].x, perspectivePoints[2].y, 
           perspectivePoints[6].x, perspectivePoints[6].y, 
           perspectivePoints[4].x, perspectivePoints[4].y);
    }
    if(sideColors[2] >= 0 && move == Moves.R){
      //1375, X+ Face (R)
      quad(perspectivePoints[1].x, perspectivePoints[1].y, 
           perspectivePoints[3].x, perspectivePoints[3].y, 
           perspectivePoints[7].x, perspectivePoints[7].y, 
           perspectivePoints[5].x, perspectivePoints[5].y);
    }
  }
  
  void showColor(Moves move){
    noStroke();
    if(sideColors[5] >= 1 && move == Moves.B){
      //3.0.6.9, Z- Face (B)
      fill(0, 0, 240);
      quad(interiorPoints[3].x, interiorPoints[3].y, 
           interiorPoints[0].x, interiorPoints[0].y,
           interiorPoints[6].x, interiorPoints[6].y,
           interiorPoints[9].x, interiorPoints[9].y);
    }
    if(sideColors[4] >= 1 && move == Moves.F){
      //12.15.21.18, Z+ Face (F)
      fill(0, 240, 0);
      quad(interiorPoints[12].x, interiorPoints[12].y, 
           interiorPoints[15].x, interiorPoints[15].y,
           interiorPoints[21].x, interiorPoints[21].y,
           interiorPoints[18].x, interiorPoints[18].y);
    }
    if(sideColors[0] >= 1 && move == Moves.U){
      //1.4.16.13, Y- Face (U)
      fill(250, 250, 250);
      quad(interiorPoints[1].x, interiorPoints[1].y, 
           interiorPoints[4].x, interiorPoints[4].y,
           interiorPoints[16].x, interiorPoints[16].y,
           interiorPoints[13].x, interiorPoints[13].y);
    }
    if(sideColors[1] >= 1 && move == Moves.D){
      //19.22.10.7, Y+ Face (D)
      fill(240, 240, 0);
      quad(interiorPoints[19].x, interiorPoints[19].y, 
           interiorPoints[22].x, interiorPoints[22].y,
           interiorPoints[10].x, interiorPoints[10].y,
           interiorPoints[7].x, interiorPoints[7].y);
    }
    if(sideColors[3] >= 1 && move == Moves.L){
      //2.14.20.8, X- Face (L)
      fill(240, 120, 0);
      quad(interiorPoints[2].x, interiorPoints[2].y, 
           interiorPoints[14].x, interiorPoints[14].y,
           interiorPoints[20].x, interiorPoints[20].y,
           interiorPoints[8].x, interiorPoints[8].y);
    }
    if(sideColors[2] >= 1 && move == Moves.R){
      //17.5.11.23, X+ Face (R)
      fill(240, 0, 0);
      quad(interiorPoints[17].x, interiorPoints[17].y, 
           interiorPoints[5].x, interiorPoints[5].y,
           interiorPoints[11].x, interiorPoints[11].y,
           interiorPoints[23].x, interiorPoints[23].y);
    }
  }
  
  void drawFrame(boolean showTilePoints){
    PVector[] tempDisps = generateRotationVectors(rotation, pointDisps.clone());
    PVector centerDisps = generateRotationVectors(rotation, new PVector[] {distToCenter.copy().mult(sideLength)})[0];
    PVector[] points = new PVector[8];
    for(int i = 0; i < pointDisps.length; i++){
      points[i] = center.copy().add(tempDisps[i].copy().mult(sideLength/2)).add(centerDisps);
    }
    
    int[] order = {0, 1, 4, 5};      
    stroke(20);
    strokeWeight(16);
    for(PVector p: points) point(p.x, p.y);
    strokeWeight(2);
    for(int i = 0; i < 4; i++){
      stroke(0, 0, 255);
      line(points[2*i].x, points[2*i].y, points[(2*i + 1) % 8].x, points[(2*i + 1) % 8].y);
      stroke(0, 255, 0);
      line(points[order[i]].x, points[order[i]].y, points[order[i] + 2].x, points[order[i] + 2].y);
      stroke(255, 0, 0);
      line(points[i].x, points[i].y, points[(i + 4) % 8].x, points[(i + 4) % 8].y);
    }
    
    if(showTilePoints){
      int margin = 10;
      for(int i = 0; i < points.length; i++){      
        PVector noZ = pointDisps[i].copy();
        noZ.z = 0;
        PVector zDisabled = generateRotationVectors(rotation, new PVector[] {noZ})[0].mult(margin);
        
        PVector noY = pointDisps[i].copy();
        noY.y = 0;
        PVector yDisabled = generateRotationVectors(rotation, new PVector[] {noY})[0].mult(margin);
        
        PVector noX = pointDisps[i].copy();
        noX.x = 0;
        PVector xDisabled = generateRotationVectors(rotation, new PVector[] {noX})[0].mult(margin);
              
        interiorPoints[i*3] = points[i].copy().sub(zDisabled);
        interiorPoints[i*3 + 1] = points[i].copy().sub(yDisabled);
        interiorPoints[i*3 + 2] = points[i].copy().sub(xDisabled);
      }
      
      stroke(255, 0, 0);
      strokeWeight(4);
      for(PVector p: interiorPoints){
        point(p.x, p.y);
      }
    }
  }
  
  void resetFacesToShow(){
    for(int i = 0; i < sideColors.length; i++){
      sideColors[i] = -1;
    }
  }
  
  boolean toggleFacesToShow(String faceToChange, int status){
    if(status < -1 || status > 1){
      return false;
    }
    
    for(Moves s: Moves.values()){
      if(s.name().equals(faceToChange)){
        if(neighbors.contains(faceToChange)){
          return false;
        }
        sideColors[Moves.valueOf(faceToChange).ordinal()] = status;
        return true;
      }
    }
    return false;
  }
  
  String[] findFacesToShow(){
    HashMap<Moves, Float>zValues = new HashMap<Moves, Float>();
    
    zValues.put(Moves.B, perspectivePoints[0].z + perspectivePoints[1].z + 
                         perspectivePoints[3].z + perspectivePoints[2].z);
    zValues.put(Moves.F, perspectivePoints[4].z + perspectivePoints[5].z + 
                         perspectivePoints[7].z + perspectivePoints[6].z);
    zValues.put(Moves.U, perspectivePoints[0].z + perspectivePoints[1].z + 
                         perspectivePoints[5].z + perspectivePoints[4].z);
    zValues.put(Moves.D, perspectivePoints[2].z + perspectivePoints[3].z + 
                         perspectivePoints[7].z + perspectivePoints[6].z);
    zValues.put(Moves.L, perspectivePoints[0].z + perspectivePoints[2].z + 
                         perspectivePoints[6].z + perspectivePoints[4].z);
    zValues.put(Moves.R, perspectivePoints[1].z + perspectivePoints[3].z + 
                         perspectivePoints[7].z + perspectivePoints[5].z);
    
    String[] resultFaces = new String[3];
    
    for(int counter = 0; counter < 3; counter++){
      float highestValue = Integer.MIN_VALUE;
      Moves usedFace = Moves.R;
      for(Moves face: zValues.keySet()){
        if(highestValue < zValues.get(face)){
          highestValue = zValues.get(face);
          usedFace = face;
        }
      }
      resultFaces[counter] = usedFace.name();
      zValues.remove(usedFace);
    }
    
    return resultFaces;
  }
  
  void resetDisplacement(){
    rotation.x = 0;
    rotation.y = 0;
    rotation.z = 0;
  }
  
  void transform(char direction, float amount){
    if(direction == 'x') rotation.x = (rotation.x + amount) % 360;
    if(direction == 'y') rotation.y = (rotation.y + amount) % 360;
    if(direction == 'z') rotation.z = (rotation.z + amount) % 360;
    
    while(rotation.x < 0) rotation.x += 360;
    while(rotation.y < 0) rotation.y += 360;
    while(rotation.z < 0) rotation.z += 360;
  }
  
  void update(){
    PVector[] resultDisps = generateRotationVectors(rotation, pointDisps);
    PVector centerDisps = generateRotationVectors(rotation, new PVector[] {distToCenter.copy()})[0];
    perspectivePoints = applyPerspectiveProjection(resultDisps, centerDisps);
    
    currCenter = center.copy().add(centerDisps).mult(sideLength);
    
    for(int i = 0; i < pointDisps.length; i++){
      PVector smallerXY = pointDisps[i].copy();
      smallerXY.x *= 0.9;
      smallerXY.y *= 0.9;
      PVector XYcolors = applyPerspectiveProjection(
                            generateRotationVectors(rotation, new PVector[] {smallerXY}), centerDisps)[0];
      
      PVector smallerXZ = pointDisps[i].copy();
      smallerXZ.x *= 0.9;
      smallerXZ.z *= 0.9;
      PVector XZcolors = applyPerspectiveProjection(
                            generateRotationVectors(rotation, new PVector[] {smallerXZ}), centerDisps)[0];
      
      PVector smallerYZ = pointDisps[i].copy();
      smallerYZ.y *= 0.9;
      smallerYZ.z *= 0.9;
      PVector YZcolors = applyPerspectiveProjection(
                            generateRotationVectors(rotation, new PVector[] {smallerYZ}), centerDisps)[0];
            
      interiorPoints[i*3] = XYcolors;
      interiorPoints[i*3 + 1] = XZcolors;
      interiorPoints[i*3 + 2] = YZcolors;
    }
  }
  
  PVector getCenter(){
    return currCenter.copy();
  }
}
