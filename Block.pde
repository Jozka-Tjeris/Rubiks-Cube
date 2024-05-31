class Block{
  PVector[] pointDisps = new PVector[8]; //TLB, TRB, BLB, BRB, TLF, TRF, BLF, BRF
  PVector[] points = new PVector[8];
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
      stroke(200);
      
      fill(30);
      if(sideColors[5] == 0){
        //4576, Z- face (B)
        quad(points[0].x, points[0].y, points[1].x, points[1].y, points[3].x, points[3].y, points[2].x, points[2].y);
      }
      if(sideColors[4] == 0){
        //0132, Z+ face (F)
        quad(points[4].x, points[4].y, points[5].x, points[5].y, points[7].x, points[7].y, points[6].x, points[6].y);
      }
      if(sideColors[0] == 0){
        //0154, Y- Face (U)
        quad(points[0].x, points[0].y, points[1].x, points[1].y, points[5].x, points[5].y, points[4].x, points[4].y);
      }
      if(sideColors[1] == 0){
        //2376, Y+ Face (D)
        quad(points[2].x, points[2].y, points[3].x, points[3].y, points[7].x, points[7].y, points[6].x, points[6].y);
      }
      if(sideColors[3] == 0){
        //0264, X- Face (L)
        quad(points[0].x, points[0].y, points[2].x, points[2].y, points[6].x, points[6].y, points[4].x, points[4].y);
      }
      if(sideColors[2] == 0){
        //1375, X+ Face (R)
        quad(points[1].x, points[1].y, points[3].x, points[3].y, points[7].x, points[7].y, points[5].x, points[5].y);
      }
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
    
    if(rotation.x < 0) rotation.x += 360;
    if(rotation.y < 0) rotation.y += 360;
    if(rotation.z < 0) rotation.z += 360;
  }
  
  void update(){
    
    PVector[] resultDisps = generateRotationVectors(rotation, pointDisps);
    PVector centerDisps = generateRotationVectors(rotation, new PVector[] {distToCenter})[0];
    
    currCenter = center.copy().add(centerDisps);
    
    for(int i = 0; i < pointDisps.length; i++){
      points[i] = center.copy().add(resultDisps[i].mult(sideLength/2)).add(centerDisps);
    }
  }
  
  PVector getCenter(){
    return currCenter.copy();
  }
}
