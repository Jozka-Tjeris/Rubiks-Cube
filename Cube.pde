import java.util.LinkedList;

class Cube{
  int cubeSize;
  Block[] blocks;
  Axis axis;
  HashMap<String, PieceGroup> blockGroups = new HashMap<String, PieceGroup>();
  ArrayList<PieceGroup> displayOrder = new ArrayList<PieceGroup>();
  LinkedList<Moves> moveQueue = new LinkedList<Moves>();
  int moveAnimationCounter = 0;
  String currMove = " ";
  
  Cube(int size, int blockLength){
    cubeSize = size;
    axis = new Axis(center, size*blockLength + 80);
    
    blocks = new Block[size*size*size];
    PVector[] disps = getNumbers(size);
    
    for(int i = 0; i < disps.length; i++){
      blocks[i] = new Block(center, blockLength, disps[i]);
      removeNeighbors(blocks[i], disps[i], size);
      
      String facesToShow = getFacesToShow(blocks[i]);
      if(!blockGroups.containsKey(facesToShow)){
        String[] faceArray = new String[0];
        if(facesToShow != ""){
          faceArray = facesToShow.split("");
        }
        blockGroups.put(facesToShow, new PieceGroup(PieceType.getType(facesToShow), faceArray));
      }
      blockGroups.get(facesToShow).addBlockIdx(i);
    }
    
    for(String s: blockGroups.keySet()){
      blockGroups.get(s).setPosition(this);
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
    for(PieceGroup g: displayOrder){ 
      g.drawBlocks(this);
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
  
  void updateMoves(){
    if(!Moves.getAllFaces().contains(currMove) && moveQueue.size() > 0){
      currMove = moveQueue.removeFirst().name();
    }
    if(Moves.getAllFaces().contains(currMove)){
      if(moveAnimationCounter < 90){
        moveAnimationCounter++;
        turnFace(Moves.valueOf(currMove), 1);
      }else{
        moveAnimationCounter = 0;
        shuffleBlocks(Moves.valueOf(currMove), 1);
        currMove = " ";
      }
    }
  }
  
  void updateState(char direction, int amount){
    for(Block b: blocks){
      b.transform(direction, amount);
      b.updateQXYZ(direction, amount);
    }
    axis.updateQXYZ(direction, amount);
    generateDisplayOrder();
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
    if(index < 0 || index >= blocks.length){
      return;
    }
    
    blocks[index].isMoving = state;
  }
  
  void turnFace(Moves faceToTurn, int layer){
    if(layer < 0) layer = 0;
    if(layer >= cubeSize) layer = cubeSize - 1;

    Turn turn = new Turn(cubeSize, layer, faceToTurn);
    turn.setAxis(faceToTurn, axis);
  
    for(int r = 0; r < cubeSize; r++){
      for(int i = 0; i < cubeSize; i++){
        int index = turn.d*turn.cd + r*turn.cr + i*turn.ci;
        toggleMovingBlock(index, true);
        blocks[index].updateQAroundAxis(turn.axisOfRotation, 1);
        //blocks[index].toggleFacesToShow(turn.oppFace, 0);
        //blocks[index].showFace(Moves.valueOf(turn.oppFace));
        //blocks[index + turn.diff].toggleFacesToShow(turn.faceToTurn, 0);
        //blocks[index + turn.diff].showFace(Moves.valueOf(turn.faceToTurn));
      }
    }
  }
  
  /*
  Faces to target: (d is depth layer), Start by directly facing the center of the face to rotate
  Note: d can be anywhere from 0 to n - 1,
  Note: i and r starts at 0 (i0 and r0), goes to n - 1 (i1 and r1)
  Note: var' = n - var - 1
  
  B: (Blue)
  [d*n*n + r0*n + i0', d*n*n + r0*n + i1']
  ...
  [d*n*n + r1*n + i0', d*n*n + r1*n + i1']
  
  Ex: (d = 0)
  [04, 03, 02, 01, 00]
  [09, 08, 07, 06, 05]
  [14, 13, 12, 11, 10]
  [19, 18, 17, 16, 15]
  [24, 23, 22, 21, 20]
  
  F: (Green)
  [d'*n*n + r0*n + i0, d'*n*n + r0*n + i1]
  ...
  [d'*n*n + r1*n + i0, d'*n*n + r1*n + i1]
  
  Ex: (d = 0)
  [100, 101, 102, 103, 104]
  [105, 106, 107, 108, 109]
  [110, 111, 112, 113, 114]
  [115, 116, 117, 118, 119]
  [120, 121, 122, 123, 124]
  
  R: (Red)
  [d' + r0*n + i0'*n*n, d' + r0*n + i1'*n*n]
  ...
  [d' + r1*n + i1'*n*n, d' + r1*n + i1'*n*n]
  
  Ex: (d = 0)
  [104, 79, 54, 29, 04]
  [109, 84, 59, 34, 09]
  [114, 89, 64, 39, 14]
  [119, 94, 69, 44, 19]
  [124, 99, 74, 49, 24]
  
  L: (Orange)
  [d + r0*n + i0*n*n, d + r0*n + i1*n*n]
  ...
  [d + r1*n + i0*n*n, d + r1*n + i1*n*n]
  
  Ex: (d = 0)
  [00, 25, 50, 75, 100]
  [05, 30, 55, 80, 105]
  [10, 35, 60, 85, 110]
  [15, 40, 65, 90, 115]
  [20, 45, 70, 95, 120]
  
  U: (White)
  [d*n + r0*n*n + i0, d + r0*n*n + i1]
  ...
  [d*n + r1*n*n + i0, d + r1*n*n + i1]
  
  Ex: (d = 0)
  [000, 001, 002, 003, 004]
  [025, 026, 027, 028, 029]
  [050, 051, 052, 053, 054]
  [075, 076, 077, 078, 079]
  [100, 101, 102, 103, 104]
  
  D: (Yellow)
  [d'*n + r0'*n*n + i0, d'*n + r0'*n*n + i1]
  ...
  [d'*n + r1'*n*n + i0, d'*n + r1'*n*n + i1]
  
  Ex: (d = 0)
  [120, 121 ,122, 123, 124]
  [095, 096, 097, 098, 099]
  [070, 071, 072, 073, 074]
  [045, 046, 047, 048, 049]
  [020, 021, 022, 023, 024]
  */
  
  void shuffleBlocks(Moves face, int layer){
    int[][] initPosArr = new int[cubeSize][cubeSize];
    Turn turn = new Turn(cubeSize, layer, face);
    
    for(int r = 0; r < cubeSize; r++){
      for(int i = 0; i < cubeSize; i++){
        initPosArr[r][i] = turn.d* turn.cd;
        
        if(turn.rInv) initPosArr[r][i] += (cubeSize - r - 1)* turn.cr;
        else initPosArr[r][i] += r* turn.cr;
        
        if(turn.iInv) initPosArr[r][i] += (cubeSize - i - 1)* turn.ci;
        else initPosArr[r][i] += i* turn.ci;
      }
    }
    
    int[][] arrTranspose = new int[cubeSize][cubeSize];
    int[][] arrVFlipped = new int[cubeSize][cubeSize];
    
    for(int i = 0; i < cubeSize; i++){
      for(int j = 0; j < cubeSize; j++){
        arrTranspose[i][j] = initPosArr[j][i];
      }
    }
    
    for(int i = 0; i < cubeSize; i++){
      for(int j = 0; j < cubeSize; j++){
        arrVFlipped[i][j] = arrTranspose[i][cubeSize - j - 1];
      }
    }
    
    Block[][] blockArr = new Block[cubeSize][cubeSize];
    
    for(int i = 0; i < cubeSize; i++){
      for(int j = 0; j < cubeSize; j++){
        int idx = arrVFlipped[i][j];
        blockArr[i][j] = blocks[idx];
        toggleMovingBlock(idx, false);
      }
    }
    
    for(int i = 0; i < cubeSize; i++){
      for(int j = 0; j < cubeSize; j++){
        blocks[initPosArr[i][j]] = blockArr[i][j];
      }
    }
  }
  
  void addMove(Moves m){
    moveQueue.add(m);
    println(moveQueue);
  }
  
  void generateDisplayOrder(){
    HashMap<String, PieceGroup> blockGroupsCopy = new HashMap<String, PieceGroup>();
    for(PieceGroup g: blockGroups.values()){
      //g.flipAll(false);
      g.setPosition(this);
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
    }
    
    displayOrder = res;
  }
}
