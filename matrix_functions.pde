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
  PVector angles = rotation.copy();
  
  angles.x = (float)Math.toRadians(angles.x);
  angles.y = (float)Math.toRadians(angles.y);
  angles.z = (float)Math.toRadians(angles.z);
  
  float[][] rotateX = {
    {     1     ,      0      ,      0       },
    {     0     ,cos(angles.x),-sin(angles.x)},
    {     0     ,sin(angles.x), cos(angles.x)}
  };
  
  float[][] rotateY = {
    { cos(angles.y),     0     ,sin(angles.y)},
    {     0        ,     1     ,      0      },
    {-sin(angles.y),     0     ,cos(angles.y)}
  };
  
  float[][] rotateZ = {
    {cos(angles.z),-sin(angles.z),    0      },
    {sin(angles.z), cos(angles.z),    0      },
    {      0      ,      0       ,    1      }
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
