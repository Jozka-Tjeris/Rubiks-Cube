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
      c.blocks[idx].flipped = state;
    }
  }
  
  public void drawBlocks(Cube c){    
    ArrayList<String[]> faces = new ArrayList<String[]>();
    ArrayList<Integer> indexes = new ArrayList<Integer>();
    
    for(int idx: indexList){
      faces.add(c.blocks[idx].findFacesToShow());
      indexes.add(idx);
    }
    
    for(int i = 0; i < faces.get(0).length; i++){
      for(int j = 0; j < faces.size(); j++){
        String f = faces.get(j)[i];
        if(c.blocks[indexes.get(j)].toggleFacesToShow(f, 1)){
          c.blocks[indexes.get(j)].showFace(Moves.valueOf(f));
          c.blocks[indexes.get(j)].showColor(Moves.valueOf(f));
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
