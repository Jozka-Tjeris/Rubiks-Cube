class Axis{
  PVector[] originalPointDisps = new PVector[6];
  PVector[] pointDisps = new PVector[6];
  PVector[] originalPoints = new PVector[6];
  PVector[] points = new PVector[6];
  PVector center = new PVector(0, 0, 0);
  float axisLength = 0;
  PVector rotation = new PVector(0, 0, 0);
  
  public Axis(PVector v, float l){
    center = v.copy();
    axisLength = l;
    
    pointDisps[0] = new PVector(-1, 0, 0);
    pointDisps[1] = new PVector(1, 0, 0);
    pointDisps[2] = new PVector(0, -1, 0);
    pointDisps[3] = new PVector(0, 1, 0);
    pointDisps[4] = new PVector(0, 0, -1);
    pointDisps[5] = new PVector(0, 0, 1);
    
    originalPointDisps = pointDisps.clone();
    
    for(int i = 0; i < pointDisps.length; i++){
      //add distance to points based on the point disps, scaled by half its length
      points[i] = center.copy().add(pointDisps[i].copy().mult(l/2));
    }
    
    originalPoints = points.clone();
  }
  
  public void show(){
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
  
  public void reset(){
    rotation = new PVector(0, 0, 0);
    pointDisps = originalPointDisps.clone();
    points = originalPoints.clone();
  }
  
  public void transform(char direction, float amount){
    if(direction == 'x') rotation.x += amount;
    if(direction == 'y') rotation.y += amount;
    if(direction == 'z') rotation.z += amount;
    
    while(rotation.x < 0) rotation.x += 360;
    while(rotation.y < 0) rotation.y += 360;
    while(rotation.z < 0) rotation.z += 360;
  }
  
  public void setRotation(PVector n){
    rotation = n;
  }
  
  public void updateQXYZ(char direction, int amount){
    for(int i = 0; i < pointDisps.length; i++){
      pointDisps[i] = rotateAroundAxis(amount, direction, pointDisps[i]);
      points[i] = center.copy().add(pointDisps[i].copy().mult(axisLength/2));
    }
  }
  
  public void updateQAroundAxis(PVector axisOfRotation, int amount){
    for(int i = 0; i < pointDisps.length; i++){
      pointDisps[i] = rotateAroundCustomAxis(amount, axisOfRotation, pointDisps[i]);
      points[i] = center.copy().add(pointDisps[i].copy().mult(axisLength/2));
    }
  }
  
  public PVector getAxisOfRotation(char direction, boolean flipped){
    switch(direction){
      case 'x':
        PVector xAxis = points[1].copy().sub(points[0].copy()).normalize();
        if(flipped) xAxis.mult(-1);
        return xAxis;
      case 'y':
        PVector yAxis = points[3].copy().sub(points[2].copy()).normalize();
        if(flipped) yAxis.mult(-1);
        return yAxis;
      case 'z':
        PVector zAxis = points[5].copy().sub(points[4].copy()).normalize();
        if(flipped) zAxis.mult(-1);
        return zAxis;
    }
    return new PVector(0, 0, 0);
  }
}
