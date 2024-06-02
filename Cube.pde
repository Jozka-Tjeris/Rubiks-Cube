class Cube{
  Block[] blocks;
  PVector[] disps;
  Axis axis;
  
  Cube(int size, int blockLength){
    axis = new Axis(center, size*blockLength + 80);
    
    blocks = new Block[size*size*size];
    disps = getNumbers(size);
    
    for(int i = 0; i < disps.length; i++){
      blocks[i] = new Block(center, blockLength);
      removeNeighbors(blocks[i], disps[i], size);
      blocks[i].setDistanceFactorFromCenter(disps[i]);
    }
  }
  
  void removeNeighbors(Block block, PVector disps, int size){
    float offset = size/2;
    if(size % 2 == 0) offset -= 0.5;
        
    if(disps.x == offset){
      //X+ Face (R)
      block.removeNeighbor("R");
    }
    if(disps.x == -1*offset){
      //X- Face(L)
      block.removeNeighbor("L");
    }
    if(disps.y == offset){
      //Y+ Face (D)
      block.removeNeighbor("D");
    }
    if(disps.y == -1*offset){
      //Y- Face (U)
      block.removeNeighbor("U");
    }
    if(disps.z == offset){
      //Z+ Face (F)
      block.removeNeighbor("F");
    }
    if(disps.z == -1*offset){
      //Z- Face (B)
      block.removeNeighbor("B");
    }
  }
  
  void show(){
    String[] faces = blocks[0].findFacesToShow();
    
    for(Block b: blocks){
      b.resetFacesToShow();
      for(String f: faces){
        b.toggleFacesToShow(f, 0);
      }
      int i = 9;
      b.setType("frame");
      if(i == 9) b.setType("pers");
      b.show();
      //b.showColors();
    }
    blocks[0].show();
    
    axis.show();
    stroke(180, 0, 180);
    strokeWeight(10);
  }
  
  void transform(char direction, float amount){
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
    
  void resetDisplacement(){
    for(Block b: blocks){
      b.resetDisplacement();
    }
    
    axis.resetDisplacement();
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
}
