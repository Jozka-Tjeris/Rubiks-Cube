class Axis{
  PVector[] pointDisps = new PVector[6];
  PVector[] points = new PVector[6];
  PVector center = new PVector(0, 0, 0);
  float axisLength = 0;
  PVector rotation = new PVector(0, 0, 0);
  
  Axis(PVector v, float l){
    center = v.copy();
    axisLength = l;
    
    pointDisps[0] = new PVector(-1, 0, 0);
    pointDisps[1] = new PVector(1, 0, 0);
    pointDisps[2] = new PVector(0, -1, 0);
    pointDisps[3] = new PVector(0, 1, 0);
    pointDisps[4] = new PVector(0, 0, -1);
    pointDisps[5] = new PVector(0, 0, 1);

    for(int i = 0; i < pointDisps.length; i++){ 
      points[i] = center.copy().add(pointDisps[i].copy().mult(l/2));
    }
  }
  
  void show(){
    stroke(170);
    strokeWeight(16);    
    for(int i = 0; i < 3; i++){
      point(points[2*i + 1].x, points[2*i + 1].y);

      char text = ' ';
      if(i == 0) text = 'x';
      if(i == 1) text = 'y';
      if(i == 2) text = 'z';  
      fill(0);
      text(text, points[2*i + 1].x, points[2*i + 1].y);
    }
    
    strokeWeight(2);    
    for(int i = 0; i < 3; i++){
      stroke(120*i, 120 + 60*i, 200 - (50*i));
      line(points[2*i].x, points[2*i].y, points[2*i + 1].x, points[2*i + 1].y);
    }
  }
  
  void resetDisplacement(){
    rotation.x = 0;
    rotation.y = 0;
    rotation.z = 0;
  }
  
  void transform(char direction, float amount){
    if(direction == 'x') rotation.x += amount;
    if(direction == 'y') rotation.y += amount;
    if(direction == 'z') rotation.z += amount;
  }
  
  void update(){
    PVector[] resultDisps = generateRotationVectors(rotation, pointDisps);
    
    for(int i = 0; i < pointDisps.length; i++){
      points[i] = center.copy().add(resultDisps[i].mult(axisLength/2));
    }
  }
}
