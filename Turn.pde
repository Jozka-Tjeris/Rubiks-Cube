class Turn{
  int cr = 0;    //row coefficient
  int ci = 0;    //index coefficient
  int cd = 0;    //depth coefficient
  int d = 0;     //depth value
  int diff = 0;  //difference between two layers
  String faceToTurn;
  String oppFace;
  PVector axisOfRotation = new PVector(0, 0, 0);
  boolean iInv = false;
  boolean rInv = false;
  
  public Turn(int size, int layer, Moves move){
    switch(move.name().charAt(0)){
      case 'B':
        cd = size*size;
        cr = size;
        ci = 1;
        d = layer;
        diff = size*size;
        iInv = true;
        break;
      case 'F':
        cd = size*size;
        cr = size;
        ci = 1;
        d = (size - layer - 1);
        diff = -1*size*size;
        break;
      case 'U':
        cd = size;
        cr = size*size;
        ci = 1;
        d = layer;
        diff = size;
        break;
      case 'D':
        cd = size;
        cr = size*size;
        ci = 1;
        d = (size - layer - 1);
        diff = -1*size;
        rInv = true;
        break;
      case 'L':
        cd = 1;
        cr = size;
        ci = size*size;
        d = layer;
        diff = 1;
        break;
      case 'R':
        cd = 1;
        cr = size;
        ci = size*size;
        d = (size - layer - 1);
        diff = -1;
        iInv = true;
        break;
    }
    faceToTurn = move.name();
    oppFace = Moves.getOppositeFace(move.name());
  }
    
  public void setAxis(Moves move, Axis axis){
    switch(move.name().charAt(0)){
      case 'B':
        axisOfRotation = axis.getAxisOfRotation('z', true);
        break;
      case 'F':
        axisOfRotation = axis.getAxisOfRotation('z', false);
        break;
      case 'U':
        axisOfRotation = axis.getAxisOfRotation('y', true);
        break;
      case 'D':
        axisOfRotation = axis.getAxisOfRotation('y', false);
        break;
      case 'L':
        axisOfRotation = axis.getAxisOfRotation('x', true);
        break;
      case 'R':
        axisOfRotation = axis.getAxisOfRotation('x', false);
        break;
    }
  }
}
