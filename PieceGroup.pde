class PieceGroup{
  ArrayList<Integer> indexList = new ArrayList<Integer>();
  PieceType groupType;
  String[] facesToShow;
  boolean reverseOrder = false;
  PVector position = new PVector(Integer.MAX_VALUE, Integer.MAX_VALUE, Integer.MAX_VALUE);
  
  PieceGroup(PieceType type, String[] faces){
    groupType = type;
    facesToShow = faces;
  }
  
  void addBlockIdx(int b){
    indexList.add(b);
  }
    
  String getFacesAsString(){
    String s = "";
    for(String c: facesToShow) s += c;
    return s;
  }
  
  void setPosition(Cube c){
    PVector sumPos = new PVector(0, 0, 0);
    for(int idx: indexList) sumPos.add(c.blocks[idx].distToCenter.copy());
    
    position = sumPos.div(indexList.size()).copy();
  }
  
  void flipAll(Cube c, boolean state){
    for(int idx: indexList){
      c.blocks[idx].flipped = state;
    }
  }
  
  void drawBlocks(Cube c){    
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
}

/*
keep an array of indexes that represent the block array's original indexes (their true IDs / reference numbers)
after switching the references, look up the blocks array using those indices
and replace the list of blocks with the new IDs.

Note: improve efficiency by only changing pieceGroups that were affected during the turn.
Maybe ignore the internal pieces, as their display rules don't change when turning
*/
