class PieceGroup{
  ArrayList<Block> pieces;
  PieceType groupType;
  String[] facesToShow;
  boolean reverseOrder = false;
  PVector position = new PVector(Integer.MAX_VALUE, Integer.MAX_VALUE, Integer.MAX_VALUE);
  
  PieceGroup(PieceType type, String[] faces){
    pieces = new ArrayList<Block>();
    groupType = type;
    facesToShow = faces;
  }
  
  void addBlock(Block b){
    pieces.add(b);
  }
  
  String getFacesAsString(){
    String s = "";
    for(String c: facesToShow) s += c;
    return s;
  }
  
  void setPosition(){
    PVector sumPos = new PVector(0, 0, 0);
    for(Block b: pieces) sumPos.add(b.distToCenter.copy());
    
    position = sumPos.div(pieces.size()).copy();
  }
  
  void flipAll(boolean state){
    for(Block b: pieces){
      b.flipped = state;
    }
  }
  
  void drawBlocks(){
    String[] faces = pieces.get(0).findFacesToShow(facesToShow);

    for(String f: faces){
      for(Block b: pieces){
        if(b.toggleFacesToShow(f, 1)){
          b.showFace(Moves.valueOf(f));
          b.showColor(Moves.valueOf(f));
        }
      }
    }
  }
  
  void reverseList(boolean state){
    reverseOrder = state;
  }
  
  void rotateGroup(PVector axisOfRotation){
    for(Block b: pieces){
      b.updateQAroundAxis(axisOfRotation, 1);
    }
  }
  
  void toggleFacesZero(char face){
    
  }
}
