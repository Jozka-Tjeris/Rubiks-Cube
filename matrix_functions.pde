float[][] vectorToMatrix(PVector v){
  float[][] res = {{v.x}, {v.y}, {v.z}};
  return res;
}

PVector matrixToVector(float[][] m){
  PVector res = new PVector(m[0][0], m[1][0], m[2][0]);
  return res;
}

float[][] matrixMult(float[][] a, float[][] b){
  if(a == null || b == null || a.length <= 0 || b.length <= 0 || a[0].length <= 0 || b[0].length <= 0){
    println("Invalid matrices or invalid matrix dimentions");
    return null;
  }
  
  if(a[0].length != b.length){
    println("Incompatible matrices, unequal column and rows");
    return null;
  }
    
  float[][] result = new float[a.length][b[0].length];
  
  for(int r = 0; r < result.length; r++){
    for(int c = 0; c < result[0].length; c++){
      for(int entry = 0; entry < result.length; entry++) result[r][c] += a[r][entry] * b[entry][c];
    }
  }
  
  return result;
}

PVector[] generateRotationVectors(PVector rotation, PVector[] pointDisps){
  float[][] rotateX = {
    {     1     ,           0           ,           0            },
    {     0     ,getCos((int)rotation.x),-getSin((int)rotation.x)},
    {     0     ,getSin((int)rotation.x), getCos((int)rotation.x)}
  };
  
  float[][] rotateY = {
    { getCos((int)rotation.y),     0     ,getSin((int)rotation.y)},
    {          0             ,     1     ,           0           },
    {-getSin((int)rotation.y),     0     ,getCos((int)rotation.y)}
  };
  
  float[][] rotateZ = {
    {getCos((int)rotation.z),-getSin((int)rotation.z),    0      },
    {getSin((int)rotation.z), getCos((int)rotation.z),    0      },
    {           0           ,           0            ,    1      }
  };
  
  PVector[] resultDisps = new PVector[pointDisps.length];
  
  for(int i = 0; i < pointDisps.length; i++){
    resultDisps[i] = matrixToVector(
                                matrixMult(rotateX, 
                                matrixMult(rotateY, 
                                matrixMult(rotateZ, 
                                vectorToMatrix(pointDisps[i])
                                ))));
  }
  return resultDisps;
}

PVector[] applyPerspectiveProjection(PVector[] initialDisps, PVector distToCenter){
  PVector[] resultDisps = new PVector[initialDisps.length];
  
  for(int i = 0; i < initialDisps.length; i++){
    PVector normalizedVector = initialDisps[i].copy().add(distToCenter.copy().mult(2));
    float z = 1 / (cameraDistanceFactors[size - 1] - normalizedVector.z);

    resultDisps[i] = normalizedVector.mult(z).mult(blockLengths[size - 1]*scalingFactors[size - 1]);
    resultDisps[i].x += center.x;
    resultDisps[i].y += center.y;
  } 
  return resultDisps;
}
