class Turn{
  int cr = 0;    //row coefficient
  int ci = 0;    //index coefficient
  int cd = 0;    //depth coefficient
  int d = 0;     //depth value
  int diff = 0;  //difference between two layers
  int cubeSize = 0;
  String faceToTurn;
  String oppFace;
  PVector axisOfRotation = new PVector(0, 0, 0);
  boolean iInv = false;
  boolean rInv = false;
  boolean dInv = false;
  
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
  
  public Turn(int size, int layer, Moves move){
    cubeSize = size;
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
        dInv = true;
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
        dInv = true;
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
        dInv = true;
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
  
  public ArrayList<ArrayList<Integer>> generateGroupList(Cube c){
    ArrayList<ArrayList<Integer>> groups = new ArrayList<ArrayList<Integer>>();
    groups.addAll(Arrays.asList(new ArrayList<Integer>(), new ArrayList<Integer>()));
    if(d > 0) groups.add(new ArrayList<Integer>());
    ArrayList<Integer> currIndexes = new ArrayList<Integer>();
    //adds the center(s) of the cube
    if(cubeSize % 2 == 1){
      currIndexes.add((cubeSize/2)*cr + (cubeSize/2)*ci);
    }else{
      currIndexes.add((cubeSize/2 - 1)*cr + (cubeSize/2 - 1)*ci);
      currIndexes.add((cubeSize/2 - 1)*cr + (cubeSize/2)*ci);
      currIndexes.add((cubeSize/2)*cr + (cubeSize/2 - 1)*ci);
      currIndexes.add((cubeSize/2)*cr + (cubeSize/2)*ci);
    }
        
    int currGroup = (dInv) ? ((d > 0) ? 2 : 1) : 0;
    boolean prevState = false;
    
    for(int i = 0; i < cubeSize; i++){
      for(int idx = 0; idx < currIndexes.size(); idx++){
        if(c.blocks[currIndexes.get(idx)].isMoving != prevState){
          currGroup += (dInv) ? -1 : 1;
          prevState = c.blocks[currIndexes.get(idx)].isMoving;
        }
        groups.get(currGroup).add(currIndexes.get(idx));
        currIndexes.set(idx, currIndexes.get(idx) + cd);
      }
    }
    
    return groups;
  }
}
