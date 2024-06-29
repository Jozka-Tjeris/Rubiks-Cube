enum Moves{
  U, 
  D, 
  R, 
  L, 
  F, 
  B;
  
  public static String getOppositeFace(String face){
    switch(face.charAt(0)){
      case 'F':
        return "B";
      case 'B':
        return "F";
      case 'U':
        return "D";
      case 'D':
        return "U";
      case 'L':
        return "R";
      case 'R':
        return "L";
    }
    println("Invalid face specified");
    return "";
  }
  
  public static String getAllFaces(){
    return "FBUDLR";
  }
}
