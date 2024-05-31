class Block{
  PVector[] pointDisps = new PVector[8]; //TLB, TRB, BLB, BRB, TLF, TRF, BLF, BRF
  PVector[] points = new PVector[8];
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
  PVector distToCenter = new PVector(0, 0, 0);
  PVector rotation = new PVector(0, 0, 0);
  String coloringState = "frame"; //frame state draws skeleton, full state draws cube
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
                              
      points[i] = center.copy().add(pointDisps[i].copy().mult(l/2));
    }
    
    neighbors.add("F");
    neighbors.add("B");
    neighbors.add("U");
    neighbors.add("D");
    neighbors.add("L");
    neighbors.add("R");
    
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
  }
  
  void removeNeighbor(String direction){
    if(!"FBUDLR".contains(direction)){
      return;
    }
    neighbors.remove(direction);
  }
  
  void setDistanceFromCenter(PVector v){
    distToCenter = v.copy();
  }
  
  void setType(String type){
    if(!type.equals("frame") && !type.equals("full")){
      return;
    }
    coloringState = type;
  }
  
  void show(){
    int[] order = {0, 1, 4, 5};
    if(coloringState.equals("frame")){
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
    }
    if(coloringState.equals("full")){
      strokeWeight(1);
      stroke(60);
      fill(30);
      if(sideColors[5] >= 0){
        //4576, Z- face (B)
        quad(points[0].x, points[0].y, points[1].x, points[1].y, points[3].x, points[3].y, points[2].x, points[2].y);
      }
      if(sideColors[4] >= 0){
        //0132, Z+ face (F)
        quad(points[4].x, points[4].y, points[5].x, points[5].y, points[7].x, points[7].y, points[6].x, points[6].y);
      }
      if(sideColors[0] >= 0){
        //0154, Y- Face (U)
        quad(points[0].x, points[0].y, points[1].x, points[1].y, points[5].x, points[5].y, points[4].x, points[4].y);
      }
      if(sideColors[1] >= 0){
        //2376, Y+ Face (D)
        quad(points[2].x, points[2].y, points[3].x, points[3].y, points[7].x, points[7].y, points[6].x, points[6].y);
      }
      if(sideColors[3] >= 0){
        //0264, X- Face (L)
        quad(points[0].x, points[0].y, points[2].x, points[2].y, points[6].x, points[6].y, points[4].x, points[4].y);
      }
      if(sideColors[2] >= 0){
        //1375, X+ Face (R)
        quad(points[1].x, points[1].y, points[3].x, points[3].y, points[7].x, points[7].y, points[5].x, points[5].y);
      }
    }
  }
  
  void showColors(){
    noStroke();
    if(sideColors[5] >= 1){
      //3.0.6.9, Z- Face (B)
      fill(0, 0, 240);
      quad(interiorPoints[3].x, interiorPoints[3].y, 
           interiorPoints[0].x, interiorPoints[0].y,
           interiorPoints[6].x, interiorPoints[6].y,
           interiorPoints[9].x, interiorPoints[9].y);
    }
    if(sideColors[4] >= 1){
      //12.15.21.18, Z+ Face (F)
      fill(0, 240, 0);
      quad(interiorPoints[12].x, interiorPoints[12].y, 
           interiorPoints[15].x, interiorPoints[15].y,
           interiorPoints[21].x, interiorPoints[21].y,
           interiorPoints[18].x, interiorPoints[18].y);
    }
    if(sideColors[0] >= 1){
      //1.4.16.13, Y- Face (U)
      fill(250, 250, 250);
      quad(interiorPoints[1].x, interiorPoints[1].y, 
           interiorPoints[4].x, interiorPoints[4].y,
           interiorPoints[16].x, interiorPoints[16].y,
           interiorPoints[13].x, interiorPoints[13].y);
    }
    if(sideColors[1] >= 1){
      //19.22.10.7, Y+ Face (D)
      fill(240, 240, 0);
      quad(interiorPoints[19].x, interiorPoints[19].y, 
           interiorPoints[22].x, interiorPoints[22].y,
           interiorPoints[10].x, interiorPoints[10].y,
           interiorPoints[7].x, interiorPoints[7].y);
    }
    if(sideColors[3] >= 1){
      //2.14.20.8, X- Face (L)
      fill(240, 120, 0);
      quad(interiorPoints[2].x, interiorPoints[2].y, 
           interiorPoints[14].x, interiorPoints[14].y,
           interiorPoints[20].x, interiorPoints[20].y,
           interiorPoints[8].x, interiorPoints[8].y);
    }
    if(sideColors[2] >= 1){
      //17.5.11.23, X+ Face (R)
      fill(240, 0, 0);
      quad(interiorPoints[17].x, interiorPoints[17].y, 
           interiorPoints[5].x, interiorPoints[5].y,
           interiorPoints[11].x, interiorPoints[11].y,
           interiorPoints[23].x, interiorPoints[23].y);
    }
  }
  
  void resetFacesToShow(){
    for(int i = 0; i < sideColors.length; i++){
      sideColors[i] = -1;
    }
  }
  
  void toggleFacesToShow(String faceToChange, int status){
    if(!"FBUDLR".contains(faceToChange)){
      return;
    }
    
    if(neighbors.contains(faceToChange)){
      return;
    }
    
    if(status < -1 || status > 1){
      return;
    }
    
    sideColors[Moves.valueOf(faceToChange).ordinal()] = status;
  }
  
  String[] findFacesToShow(){
    HashMap<Moves, Float>zValues = new HashMap<Moves, Float>();
    
    zValues.put(Moves.B, points[0].z + points[1].z + points[3].z + points[2].z);
    zValues.put(Moves.F, points[4].z + points[5].z + points[7].z + points[6].z);
    zValues.put(Moves.U, points[0].z + points[1].z + points[5].z + points[4].z);
    zValues.put(Moves.D, points[2].z + points[3].z + points[7].z + points[6].z);
    zValues.put(Moves.L, points[0].z + points[2].z + points[6].z + points[4].z);
    zValues.put(Moves.R, points[1].z + points[3].z + points[7].z + points[5].z);
    
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
    PVector centerDisps = generateRotationVectors(rotation, new PVector[] {distToCenter})[0];
    
    currCenter = center.copy().add(centerDisps);
    
    for(int i = 0; i < pointDisps.length; i++){
      points[i] = center.copy().add(resultDisps[i].mult(sideLength/2)).add(centerDisps);
    }
    
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
  }
  
  PVector getCenter(){
    return currCenter.copy();
  }
}
