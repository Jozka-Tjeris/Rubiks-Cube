import java.util.Arrays;

class Block{
  PVector[] originalPointDisps = new PVector[8]; //TLB, TRB, BLB, BRB, TLF, TRF, BLF, BRF
  PVector[] pointDisps = new PVector[8]; //Points before perspective projection
  PVector[] perspectivePoints = new PVector[8]; //Points after perspective projection
  PVector[] originalInteriorPoints = new PVector[8*3]; //Stores points for colored faces (default position)
  PVector[] interiorPoints = new PVector[8*3]; //Interior points before perspective projection
  PVector[] projectedInteriorPoints = new PVector[8*3]; //Interior points after perspective projection
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
  PVector originalDistToCenter = new PVector(0, 0, 0);
  PVector distToCenter = new PVector(0, 0, 0); //stores it as a multiple of sideLength, not absolute distance
  PVector rotation = new PVector(0, 0, 0);
  int[] sideColors = {-1, -1, -1, -1, -1, -1}; //U, D, R, L, F, B
                    //-1 = draw nothing, 0 = black square, 1 = black square with color inside
  ArrayList<String> neighbors = new ArrayList<String>();
  
  void reset(){
    pointDisps = originalPointDisps.clone();
    interiorPoints = originalInteriorPoints.clone();
    rotation = new PVector(0, 0, 0);
    distToCenter = originalDistToCenter.copy();
  }
    
  Block(PVector v, float l, PVector distanceToCenter){
    reset();
    setDistanceFactorFromCenter(distanceToCenter);
    center = v.copy();
    sideLength = l;
    
    for(int i = 0; i < pointDisps.length; i++){
      originalPointDisps[i] = new PVector(2*(i & 1) - 1, 
                                          2*((i & 2) >> 1) - 1, 
                                          2*((i & 4) >> 2) - 1);
      pointDisps[i] = originalPointDisps[i].copy();
    }
    
    neighbors.addAll(Arrays.asList("F", "B", "U", "D", "L", "R"));
    
    perspectivePoints = applyPerspectiveProjection(pointDisps, distToCenter);
    
    for(int i = 0; i < pointDisps.length; i++){
      PVector XYColors = new PVector(pointDisps[i].x * 0.9, pointDisps[i].y * 0.9, pointDisps[i].z);
      PVector XZColors = new PVector(pointDisps[i].x * 0.9, pointDisps[i].y, pointDisps[i].z * 0.9);
      PVector YZColors = new PVector(pointDisps[i].x, pointDisps[i].y * 0.9, pointDisps[i].z * 0.9);
            
      originalInteriorPoints[i*3] = XYColors;
      interiorPoints[i*3] = XYColors.copy();

      originalInteriorPoints[i*3 + 1] = XZColors;
      interiorPoints[i*3 + 1] = XZColors.copy();

      originalInteriorPoints[i*3 + 2] = YZColors;
      interiorPoints[i*3 + 2] = YZColors.copy();
    }
    
    projectedInteriorPoints = applyPerspectiveProjection(interiorPoints, distToCenter);
  }
  
  void removeNeighbor(String direction){
    if(!"FBUDLR".contains(direction)){
      return;
    }
    neighbors.remove(direction);
  }
  
  void setDistanceFactorFromCenter(PVector v){
    originalDistToCenter = v.copy();
    distToCenter = originalDistToCenter.copy();
  }
  
  void showFace(Moves move){
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
      quad(projectedInteriorPoints[3].x, projectedInteriorPoints[3].y, 
           projectedInteriorPoints[0].x, projectedInteriorPoints[0].y,
           projectedInteriorPoints[6].x, projectedInteriorPoints[6].y,
           projectedInteriorPoints[9].x, projectedInteriorPoints[9].y);
    }
    if(sideColors[4] >= 1 && move == Moves.F){
      //12.15.21.18, Z+ Face (F)
      fill(0, 240, 0);
      quad(projectedInteriorPoints[12].x, projectedInteriorPoints[12].y, 
           projectedInteriorPoints[15].x, projectedInteriorPoints[15].y,
           projectedInteriorPoints[21].x, projectedInteriorPoints[21].y,
           projectedInteriorPoints[18].x, projectedInteriorPoints[18].y);
    }
    if(sideColors[0] >= 1 && move == Moves.U){
      //1.4.16.13, Y- Face (U)
      fill(250, 250, 250);
      quad(projectedInteriorPoints[1].x, projectedInteriorPoints[1].y, 
           projectedInteriorPoints[4].x, projectedInteriorPoints[4].y,
           projectedInteriorPoints[16].x, projectedInteriorPoints[16].y,
           projectedInteriorPoints[13].x, projectedInteriorPoints[13].y);
    }
    if(sideColors[1] >= 1 && move == Moves.D){
      //19.22.10.7, Y+ Face (D)
      fill(240, 240, 0);
      quad(projectedInteriorPoints[19].x, projectedInteriorPoints[19].y, 
           projectedInteriorPoints[22].x, projectedInteriorPoints[22].y,
           projectedInteriorPoints[10].x, projectedInteriorPoints[10].y,
           projectedInteriorPoints[7].x, projectedInteriorPoints[7].y);
    }
    if(sideColors[3] >= 1 && move == Moves.L){
      //2.14.20.8, X- Face (L)
      fill(240, 120, 0);
      quad(projectedInteriorPoints[2].x, projectedInteriorPoints[2].y, 
           projectedInteriorPoints[14].x, projectedInteriorPoints[14].y,
           projectedInteriorPoints[20].x, projectedInteriorPoints[20].y,
           projectedInteriorPoints[8].x, projectedInteriorPoints[8].y);
    }
    if(sideColors[2] >= 1 && move == Moves.R){
      //17.5.11.23, X+ Face (R)
      fill(240, 0, 0);
      quad(projectedInteriorPoints[17].x, projectedInteriorPoints[17].y, 
           projectedInteriorPoints[5].x, projectedInteriorPoints[5].y,
           projectedInteriorPoints[11].x, projectedInteriorPoints[11].y,
           projectedInteriorPoints[23].x, projectedInteriorPoints[23].y);
    }
  }
  
  void drawFrame(boolean showTilePoints){
    PVector[] tempDisps = generateRotationVectors(rotation, originalPointDisps.clone());
    PVector centerDisps = generateRotationVectors(rotation, new PVector[] {originalDistToCenter.copy().mult(sideLength)})[0];
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
              
        projectedInteriorPoints[i*3] = points[i].copy().sub(zDisabled);
        projectedInteriorPoints[i*3 + 1] = points[i].copy().sub(yDisabled);
        projectedInteriorPoints[i*3 + 2] = points[i].copy().sub(xDisabled);
      }
      
      stroke(255, 0, 0);
      strokeWeight(4);
      for(PVector p: projectedInteriorPoints){
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
  
  void transform(char direction, int amount){
    if(direction == 'x') rotation.x = (rotation.x + amount) % 360;
    if(direction == 'y') rotation.y = (rotation.y + amount) % 360;
    if(direction == 'z') rotation.z = (rotation.z + amount) % 360;
    
    while(rotation.x < 0) rotation.x += 360;
    while(rotation.y < 0) rotation.y += 360;
    while(rotation.z < 0) rotation.z += 360;
  }
  
  void update(){
    PVector[] resultDisps = generateRotationVectors(rotation, originalPointDisps);
    PVector centerDisps = generateRotationVectors(rotation, new PVector[] {originalDistToCenter.copy()})[0];
    perspectivePoints = applyPerspectiveProjection(resultDisps, centerDisps);
    
    currCenter = center.copy().add(centerDisps).mult(sideLength);
    
    for(int i = 0; i < pointDisps.length; i++){
      PVector smallerXY = originalPointDisps[i].copy();
      smallerXY.x *= 0.9;
      smallerXY.y *= 0.9;
      PVector XYcolors = applyPerspectiveProjection(
                            generateRotationVectors(rotation, new PVector[] {smallerXY}), centerDisps)[0];
      
      PVector smallerXZ = originalPointDisps[i].copy();
      smallerXZ.x *= 0.9;
      smallerXZ.z *= 0.9;
      PVector XZcolors = applyPerspectiveProjection(
                            generateRotationVectors(rotation, new PVector[] {smallerXZ}), centerDisps)[0];
      
      PVector smallerYZ = originalPointDisps[i].copy();
      smallerYZ.y *= 0.9;
      smallerYZ.z *= 0.9;
      PVector YZcolors = applyPerspectiveProjection(
                            generateRotationVectors(rotation, new PVector[] {smallerYZ}), centerDisps)[0];
            
      projectedInteriorPoints[i*3] = XYcolors;
      projectedInteriorPoints[i*3 + 1] = XZcolors;
      projectedInteriorPoints[i*3 + 2] = YZcolors;
    }
  }
  
  void updateQ(char direction, int amount){
    distToCenter = rotateAroundAxis(amount, direction, distToCenter);
    
    for(int i = 0; i < pointDisps.length; i++){
      pointDisps[i] = rotateAroundAxis(amount, direction, pointDisps[i]);
    }
    
    for(int i = 0; i < interiorPoints.length; i++){
      interiorPoints[i] = rotateAroundAxis(amount, direction, interiorPoints[i]);
    }

    perspectivePoints = applyPerspectiveProjection(pointDisps, distToCenter);
    projectedInteriorPoints = applyPerspectiveProjection(interiorPoints, distToCenter);
  }
  
  PVector getCenter(){
    return currCenter.copy();
  }
}
