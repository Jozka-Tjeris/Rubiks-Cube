enum PieceType{
  Corner,
  Edge,
  Center,
  Internal;
  
  static PieceType getType(String facesToShow){
    switch(facesToShow.length()){
      case 3:
        return Corner;
      case 2:
        return Edge;
      case 1:
        return Center;
      default:
        return Internal;
    }
  }
}
