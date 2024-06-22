class PieceGroup{
  ArrayList<Integer> indexList = new ArrayList<Integer>();
  PieceType groupType;
  String[] facesToShow;
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
