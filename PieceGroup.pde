class PieceGroup implements Cloneable{
  ArrayList<Integer> indexList = new ArrayList<Integer>();
  PieceType groupType;
  String[] facesToShow;
  PVector position = new PVector(Integer.MAX_VALUE, Integer.MAX_VALUE, Integer.MAX_VALUE);
  
  public PieceGroup(PieceType type, String[] faces){
    groupType = type;
    facesToShow = faces;
  }
  
  public void addBlockIdx(int b){
    indexList.add(b);
  }
    
  public String getFacesAsString(){
    String s = "";
    for(String c: facesToShow) s += c;
    return s;
  }
  
  public PVector setPosition(Cube c){
    PVector sumPos = new PVector(0, 0, 0);
    for(int idx: indexList) sumPos.add(c.blocks[idx].distToCenter.copy());
    
    position = sumPos.div(indexList.size()).copy();
    
    return position;
  }
  
  public PVector getClosestToCenter(Cube c){
    PVector resPos = new PVector(Integer.MAX_VALUE, Integer.MAX_VALUE, Integer.MAX_VALUE);
    for(int idx: indexList){
      if(get2DLength(resPos) > get2DLength(c.blocks[idx].distToCenter.copy())){
        resPos = c.blocks[idx].distToCenter.copy();
      }
    }
    return resPos;
  }
  
  public PVector getSumOfPositions(Cube c){
    PVector resPos = new PVector(0, 0, 0);
    for(int idx: indexList){
      resPos.add(c.blocks[idx].distToCenter.copy());
      //println(idx + " " + c.blocks[idx].distToCenter.copy());
    }
    return resPos;
  }
  
  public void flipAll(Cube c, boolean state){
    for(int idx: indexList){
      c.blocks[idx].fillBlock = state;
    }
  }
  
  public void drawBlocks(Cube c, boolean fillBlock){    
    //block index, faces to show
    HashMap<Integer, ArrayList<String>> facesToShowList = new HashMap<Integer, ArrayList<String>>();
    //number of faces to show, block index
    HashMap<Integer, ArrayList<Integer>> indexGroups = new HashMap<Integer, ArrayList<Integer>>();
    //number of faces to show, closest point
    HashMap<Integer, PVector> closestPoints = new HashMap<Integer, PVector>();
    
    for(int idx: indexList){
      ArrayList<String> facesToShow = new ArrayList<String>();
      if(fillBlock){
        facesToShow = c.blocks[idx].findFacesToShow();
      }else{
        facesToShow = c.blocks[idx].findFacesToShowNoFill();
      }
      int numOfFaces = facesToShow.size();
      
      if(!indexGroups.containsKey(numOfFaces)){
        indexGroups.put(numOfFaces, new ArrayList<Integer>());
      }
      indexGroups.get(numOfFaces).add(idx);
      if(!closestPoints.containsKey(numOfFaces)){
        closestPoints.put(numOfFaces, new PVector(Integer.MAX_VALUE, Integer.MAX_VALUE, Integer.MIN_VALUE));
      }
      if(isVectorFurther(closestPoints.get(numOfFaces), c.blocks[idx].distToCenter.copy(), marginOfErrors[c.cubeSize - 1])){
        closestPoints.put(numOfFaces, c.blocks[idx].distToCenter.copy());
      }
      facesToShowList.put(idx, facesToShow);
    }
    
    ArrayList<Integer> orderToDraw = new ArrayList<Integer>();
    while(closestPoints.size() > 0){
      PVector closestP = new PVector(0, 0, Integer.MAX_VALUE);
      int index = 0;
      for(int i: closestPoints.keySet()){
        if(isVectorFurther(closestPoints.get(i), closestP, marginOfErrors[c.cubeSize - 1])){
          closestP = closestPoints.get(i);
          index = i;
        }
      }
      orderToDraw.add(index);
      closestPoints.remove(index);
    }

    //goes through faces to show groups
    for(int numOfFacesToDraw: orderToDraw){
      //goes through number of faces to show
      for(int faceIdx = 0; faceIdx < numOfFacesToDraw; faceIdx++){
        //goes through all block indexes
        for(int blockIndex : indexGroups.get(numOfFacesToDraw)){
          String f = facesToShowList.get(blockIndex).get(faceIdx);
          c.blocks[blockIndex].showFace(Moves.valueOf(f));
          c.blocks[blockIndex].showColor(Moves.valueOf(f));
        }
      }
    }
  }
  
  public void filterNonMovingBlocks(Cube c, char state, Turn turn){
    ArrayList<Integer> movingIndexList = new ArrayList<Integer>();
    for(int i: indexList) if(c.blocks[i].isMoving == true) movingIndexList.add(i);
    if(movingIndexList.size() == 0) return;
    
    ArrayList<Integer> resultIndexList = new ArrayList<Integer>();
    
    switch(state){
      case '<':
        Collections.reverse(movingIndexList);
        for(int idx: movingIndexList){
          int currIndex = (turn.dInv) ? idx + turn.cd : idx - turn.cd;
          int diff = (turn.dInv) ? turn.cd : -1*turn.cd;
          while(indexList.contains(currIndex)){
            resultIndexList.add(currIndex);
            currIndex += diff;
          }
        }
        Collections.reverse(resultIndexList);
        break;
      case '>':
        for(int idx: movingIndexList){
          int currIndex = (turn.dInv) ? idx - turn.cd : idx + turn.cd;
          int diff = (turn.dInv) ? -1*turn.cd : turn.cd;
          while(indexList.contains(currIndex)){
            resultIndexList.add(currIndex);
            currIndex += diff;
          }
        }
        break;
      case '=':
        resultIndexList = movingIndexList;
    }
    indexList = resultIndexList;
  }
  
  public Object clone(){  
    try{  
        return super.clone();  
    }catch(Exception e){ 
        return null; 
    }
  }
}
