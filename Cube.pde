class Cube{
  int cubeSize;
  Block[] blocks;
  Axis axis;
  HashMap<String, PieceGroup> blockGroups = new HashMap<String, PieceGroup>();
  ArrayList<PieceGroup> displayOrder = new ArrayList<PieceGroup>();

  
  Cube(int size, int blockLength){
    cubeSize = size;
    axis = new Axis(center, size*blockLength + 80);
    
    blocks = new Block[size*size*size];
    PVector[] disps = getNumbers(size);
    
    for(int i = 0; i < disps.length; i++){
      blocks[i] = new Block(center, blockLength, disps[i], i + 1);
      removeNeighbors(blocks[i], disps[i], size);
      
      String facesToShow = getFacesToShow(blocks[i]);
      if(!blockGroups.containsKey(facesToShow)){
        String[] faceArray = new String[0];
        if(facesToShow != ""){
          faceArray = facesToShow.split("");
        }
        blockGroups.put(facesToShow, new PieceGroup(PieceType.getType(facesToShow), faceArray));
      }
      blockGroups.get(facesToShow).addBlock(blocks[i]);
    }
    
    for(String s: blockGroups.keySet()){
      blockGroups.get(s).setPosition();
    }
    
    generateDisplayOrder();
  }
  
  String getFacesToShow(Block b){
    String res = "";
    ArrayList<String> faces = new ArrayList<String>();
    faces.addAll(Arrays.asList("F", "B", "U", "D", "L", "R"));
    for(String s: b.neighbors){
      faces.remove(s);
    }
    
    for(String s: faces){
      res += s;
    }
    
    return res;
  }
  
  void removeNeighbors(Block block, PVector disps, int size){
    float offset = size/2;
    if(size % 2 == 0) offset -= 0.5;
        
    //X+ Face (R)
    if(disps.x == offset) block.removeNeighbor("R");
    //X- Face(L)
    if(disps.x == -1*offset) block.removeNeighbor("L");
    //Y+ Face (D)
    if(disps.y == offset) block.removeNeighbor("D");
    //Y- Face (U)
    if(disps.y == -1*offset) block.removeNeighbor("U");
    //Z+ Face (F)
    if(disps.z == offset) block.removeNeighbor("F");
    //Z- Face (B)
    if(disps.z == -1*offset) block.removeNeighbor("B");
  }
  
  void show(){
    //ArrayList<Block> stationaryBlocks = new ArrayList<Block>();
    //ArrayList<Block> movingBlocks = new ArrayList<Block>();
    
    //for(Block b: blocks){
    //  if(!b.isMoving) stationaryBlocks.add(b);
    //  else movingBlocks.add(b);
    //}
    
    
    //if(stationaryBlocks.size() > 0){
    //  String[] stationaryFaces = stationaryBlocks.get(0).findFacesToShow();
    //  //stationaryFaces = new String[] {"F", "B", "U", "L", "R", "D"};
    //  for(int i = stationaryFaces.length - 1; i > -1; i--){
    //    for(Block b: stationaryBlocks){
    //      if(b.toggleFacesToShow(stationaryFaces[i], 1)){
    //        b.showFace(Moves.valueOf(stationaryFaces[i]));
    //        //b.showColor(Moves.valueOf(stationaryFaces[i]));
    //      }
    //      //b.drawFrame(true);
    //    }
    // }
    //}

    //if(movingBlocks.size() > 0){
    //  String[] movingFaces = movingBlocks.get(0).findFacesToShow();
    //  for(int i = movingFaces.length - 1; i > -1; i--){
    //    for(Block b: movingBlocks){
    //      if(b.toggleFacesToShow(movingFaces[i], 1)){
    //        b.showFace(Moves.valueOf(movingFaces[i]));
    //        b.showColor(Moves.valueOf(movingFaces[i]));
    //      }
    //      //b.drawFrame(true);
    //    }
    //  }
    //}
    
    for(PieceGroup g: displayOrder){ 
      g.drawBlocks();
    }
    axis.show();
  }
  
  void transform(char direction, int amount){
    for(Block b: blocks){
      b.transform(direction, amount);
    }
    
    axis.transform(direction, amount);
  }
  
  void update(){
    for(Block b: blocks){
      b.update();
    }
    axis.update();
  }
  
  void updateState(char direction, int amount){
    for(Block b: blocks){
      b.transform(direction, amount);
      b.updateQXYZ(direction, amount);
    }
    axis.updateQ(direction, amount);
  }
    
  void reset(){
    for(Block b: blocks){
      b.reset();
    }
    
    axis.reset();
  }
  
  PVector[] getNumbers(int base){
    if(base < 1){
      return null;
    }
    ArrayList<PVector> disps = new ArrayList<PVector>();
    int offset = (int)Math.floor(base/2.0f);
    int adjustedBase = base + ((base + 1) % 2);
    for(int i = 0; i < adjustedBase; i++){
      for(int j = 0; j < adjustedBase; j++){
        for(int k = 0; k < adjustedBase; k++){
          disps.add(new PVector(k - offset, j - offset, i - offset));
        }
      }
    }
    
    PVector[] result = new PVector[base*base*base];
    int counter = 0;
    for(int i = 0; i < disps.size(); i++){
      if((disps.get(i).x == 0.0 || disps.get(i).y == 0.0 || disps.get(i).z == 0.0) && base % 2 == 0){
        continue;
      }
      result[counter] = disps.get(i);
      if(base % 2 == 0){
        PVector translationFactor = disps.get(i).copy();
        //Scale everything down to either 0.5 or -0.5
        translationFactor.x /= -2*abs(translationFactor.x);
        translationFactor.y /= -2*abs(translationFactor.y);
        translationFactor.z /= -2*abs(translationFactor.z);
        //add translationFactor to result
        result[counter].add(translationFactor);
      }
      counter++;
    }
    return result;
  }
  
  void toggleMovingBlock(int index, boolean state){
    if(index < 0 || index > blocks.length){
      return;
    }
    
    blocks[index].isMoving = state;
  }
  
  void resetMovingBlocks(){
    for(Block b: blocks){
      b.isMoving = false;
    }
  }
  
  void turnFace(){
    PVector xAxisOfRotation = axis.points[1].copy().sub(axis.points[0].copy()).normalize();
    PVector yAxisOfRotation = axis.points[3].copy().sub(axis.points[2].copy()).normalize();
    PVector zAxisOfRotation = axis.points[5].copy().sub(axis.points[4].copy()).normalize();

    for(int i = 0; i < 9; i++){
      blocks[i].updateQAroundAxis(zAxisOfRotation, 1);
      blocks[i].toggleFacesToShow("F", 0);
      blocks[i].showFace(Moves.F);
      blocks[i + 9].toggleFacesToShow("B", 0);
      blocks[i + 9].showFace(Moves.B);
    }
  }
  
  void shuffleBlocks(){
    int[] order1 = {2, 0, 6, 8};
    int[] order2 = {1, 3, 7, 5};
    
    for(int i = 0; i < order1.length - 1; i++){
      swapBlocks(blocks, order1[i], order1[(i + 1) % order1.length]);
      swapBlocks(blocks, order2[i], order2[(i + 1) % order2.length]);
    }
  }
  
  void generateDisplayOrder(){
    HashMap<String, PieceGroup> blockGroupsCopy = new HashMap<String, PieceGroup>();
    for(PieceGroup g: blockGroups.values()){
      //g.flipAll(false);
      g.setPosition();
      blockGroupsCopy.put(g.getFacesAsString(), g);
    }
    ArrayList<PieceGroup> res = new ArrayList<PieceGroup>();
    
    while(blockGroupsCopy.size() > 0){
      PieceGroup currGroup = new PieceGroup(PieceType.Internal, null);
      for(String s: blockGroupsCopy.keySet()){
        if(abs(blockGroupsCopy.get(s).position.z - currGroup.position.z) < marginOfErrors[cubeSize - 1]){
          float len1 = get2DLength(blockGroupsCopy.get(s).position);     
          float len2 = get2DLength(currGroup.position);
                       
          if(len1 > len2){
            currGroup = blockGroupsCopy.get(s);
          }
        }
        else if(blockGroupsCopy.get(s).position.z < currGroup.position.z){
          currGroup = blockGroupsCopy.get(s);
        }
      }
      res.add(currGroup);
      blockGroupsCopy.remove(currGroup.getFacesAsString());
      if(cubeSize > 3 && currGroup.groupType == PieceType.Edge){
        if(currGroup.pieces.get(0).distToCenter.z > 
           currGroup.pieces.get(currGroup.pieces.size() - 1).distToCenter.z){
          currGroup.reverseList();
        }
      }
    }
    
    displayOrder = res;
  }
}

float get2DLength(PVector p){
  return p.x*p.x + p.y*p.y;
}
