import java.util.Arrays;

class Block{
  PVector[] originalPointDisps = new PVector[8]; //TLB, TRB, BLB, BRB, TLF, TRF, BLF, BRF
  PVector[] pointDisps = new PVector[8]; //Points before perspective projection
  PVector[] perspectivePoints = new PVector[8]; //Points after perspective projection
  PVector[] originalInteriorPoints = new PVector[8*3]; //Stores points for colored faces (default position)
  PVector[] interiorPoints = new PVector[8*3]; //Interior points before perspective projection
  PVector[] projectedInteriorPoints = new PVector[8*3]; //Interior points after perspective projection
  //Each point has 3 different interior points: xy, xz, yz
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
  ArrayList<String> facesToShow = new ArrayList<String>();
  boolean isMoving = false;
  boolean flipped = false;
      
  Block(PVector v, float l, PVector distanceToCenter){
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
      PVector XYColors = new PVector(pointDisps[i].x * scaleFactor, pointDisps[i].y * scaleFactor, pointDisps[i].z);
      PVector XZColors = new PVector(pointDisps[i].x * scaleFactor, pointDisps[i].y, pointDisps[i].z * scaleFactor);
      PVector YZColors = new PVector(pointDisps[i].x, pointDisps[i].y * scaleFactor, pointDisps[i].z * scaleFactor);
            
      originalInteriorPoints[i*3] = XYColors;
      interiorPoints[i*3] = XYColors.copy();

      originalInteriorPoints[i*3 + 1] = XZColors;
      interiorPoints[i*3 + 1] = XZColors.copy();

      originalInteriorPoints[i*3 + 2] = YZColors;
      interiorPoints[i*3 + 2] = YZColors.copy();
    }
    
    projectedInteriorPoints = applyPerspectiveProjection(interiorPoints, distToCenter);
  }
  
  public void removeNeighbor(String direction){
    if(!Moves.getAllFaces().contains(direction)) return;
    neighbors.remove(direction);
    facesToShow.add(direction);
  }
  
  public void setDistanceFactorFromCenter(PVector v){
    distToCenter = v.copy();
  }
  
  public void showFace(Moves move){
    strokeWeight(1);
    stroke(50);
    fill(30);
    if(!flipped) noFill();
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
  
  public void showColor(Moves move){
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
  
  public void resetFacesToShow(){
    for(int i = 0; i < sideColors.length; i++) sideColors[i] = -1;
  }
  
  public boolean toggleFacesToShow(String faceToChange, int status){
    if(status < -1 || status > 1) return false;
    
    for(Moves s: Moves.values()){
      if(s.name().equals(faceToChange)){
        if(neighbors.contains(faceToChange) && status == 1) return false;

        sideColors[Moves.valueOf(faceToChange).ordinal()] = status;
        return true;
      }
    }
    return false;
  }
  
  public String[] findFacesToShow(){
    HashMap<Moves, Float>zValues = new HashMap<Moves, Float>();
    for(String s: facesToShow) zValues.put(Moves.valueOf(s), getZDepth(s));
    
    String[] resultFaces = new String[zValues.size()];
    for(int counter = 0; counter < resultFaces.length; counter++){
      float currDepth = Integer.MAX_VALUE;
      String frontMostFace = "_";

      for(Moves currFace: zValues.keySet()){
        if(currDepth > zValues.get(currFace)){
          currDepth = zValues.get(currFace);
          frontMostFace = currFace.name();
        }
      }
      
      resultFaces[counter] = frontMostFace;
      zValues.remove(Moves.valueOf(frontMostFace));
    }
    return resultFaces;
  }
  
  public float getZDepth(String faceToFind){
    switch(faceToFind.charAt(0)){
      case 'U':
        return perspectivePoints[0].z + perspectivePoints[1].z + 
               perspectivePoints[5].z + perspectivePoints[4].z;
      case 'D':
        return perspectivePoints[2].z + perspectivePoints[3].z + 
               perspectivePoints[7].z + perspectivePoints[6].z;
      case 'R':
        return perspectivePoints[1].z + perspectivePoints[3].z + 
               perspectivePoints[7].z + perspectivePoints[5].z;
      case 'L':
        return perspectivePoints[0].z + perspectivePoints[2].z + 
               perspectivePoints[6].z + perspectivePoints[4].z;
      case 'F':
        return perspectivePoints[4].z + perspectivePoints[5].z + 
               perspectivePoints[7].z + perspectivePoints[6].z;
      case 'B':
        return perspectivePoints[0].z + perspectivePoints[1].z + 
               perspectivePoints[3].z + perspectivePoints[2].z;
    }
    return 0;
  }
  
  public void transform(char direction, int amount){
    if(direction == 'x') rotation.x = (rotation.x + amount) % 360;
    if(direction == 'y') rotation.y = (rotation.y + amount) % 360;
    if(direction == 'z') rotation.z = (rotation.z + amount) % 360;
    
    while(rotation.x < 0) rotation.x += 360;
    while(rotation.y < 0) rotation.y += 360;
    while(rotation.z < 0) rotation.z += 360;
  }
  
  public void updateQXYZ(char direction, int amt){
    distToCenter = rotateAroundAxis(amt, direction, distToCenter);
    for(int i = 0; i < pointDisps.length; i++) pointDisps[i] = rotateAroundAxis(amt, direction, pointDisps[i]);
    for(int i = 0; i < interiorPoints.length; i++) interiorPoints[i] = rotateAroundAxis(amt, direction, interiorPoints[i]);

    perspectivePoints = applyPerspectiveProjection(pointDisps, distToCenter);
    projectedInteriorPoints = applyPerspectiveProjection(interiorPoints, distToCenter);
  }
  
  public void updateQAroundAxis(PVector axis, int amt){
    distToCenter = rotateAroundCustomAxis(amt, axis, distToCenter);
    for(int i = 0; i < pointDisps.length; i++) pointDisps[i] = rotateAroundCustomAxis(amt, axis, pointDisps[i]);
    for(int i = 0; i < interiorPoints.length; i++) interiorPoints[i] = rotateAroundCustomAxis(amt, axis, interiorPoints[i]);

    perspectivePoints = applyPerspectiveProjection(pointDisps, distToCenter);
    projectedInteriorPoints = applyPerspectiveProjection(interiorPoints, distToCenter);
  }
  
  public PVector getCenter(){
    return currCenter.copy();
  }
}
