PVector[] applyPerspectiveProjection(PVector[] initialDisps, PVector distToCenter){
  PVector[] resultDisps = new PVector[initialDisps.length];
  
  for(int i = 0; i < initialDisps.length; i++){
    PVector totalDistanceVector = initialDisps[i].copy();
    totalDistanceVector.add(distToCenter.copy().mult(2));
    float z = 1 / (cameraDistanceFactors[size - 1] - totalDistanceVector.z);

    resultDisps[i] = totalDistanceVector.mult(z).mult(blockLengths[size - 1]*scalingFactors[size - 1]);
    resultDisps[i].x += center.x;
    resultDisps[i].y += center.y;
  } 
  return resultDisps;
}

PVector applyPerspectiveProjection(PVector initialDisp, PVector distToCenter){
  PVector resultDisp = new PVector(0, 0, 0);
  
  PVector totalDistanceVector = initialDisp.copy();
  totalDistanceVector.add(distToCenter.copy().mult(2));
  float z = 1 / (cameraDistanceFactors[size - 1] - totalDistanceVector.z);

  resultDisp = totalDistanceVector.mult(z).mult(blockLengths[size - 1]*scalingFactors[size - 1]);
  resultDisp.x += center.x;
  resultDisp.y += center.y;

  return resultDisp;
}

/*
Source: http://people.csail.mit.edu/bkph/articles/Quaternions.pdf
V' = V + 2w(Q x V) + (2Q x (Q x V))
V' = V + w(2(Q x V)) + (Q x (2(Q x V))
T = 2(Q x V)
V' = V + w*(T) + (Q x T)

w = qReal
Q = qImaginary (axis of rotation)
V = vImaginary (point to rotate)
*/

PVector rotateQ(float qRe, PVector qIm, PVector vIm){
  PVector result = new PVector(0, 0, 0);
  PVector T = (crossProduct(qIm, vIm)).mult(2);
  result = vIm.copy().add(T.copy().mult(qRe)).add(crossProduct(qIm, T));
  
  return result;
}

PVector crossProduct(PVector v1, PVector v2){
  PVector result = new PVector(0, 0, 0);
  result.x = v1.y * v2.z - v1.z * v2.y;
  result.y = v1.z * v2.x - v1.x * v2.z;
  result.z = v1.x * v2.y - v1.y * v2.x;
  
  return result;
}

PVector rotateAroundAxis(float rotationAmount, char rotationDirection, PVector pointToRotate){
  PVector returnVal = pointToRotate.copy();
  float rotationCoefficient = 0;
    
  if(rotationDirection == 'x'){
    rotationCoefficient = getCos((int)rotationAmount);
    PVector xAxis = new PVector(1, 0, 0).mult(getSin((int)rotationAmount));
    returnVal = rotateQ(rotationCoefficient, xAxis, returnVal);
  }
  
  if(rotationDirection == 'y'){
    rotationCoefficient = getCos((int)rotationAmount);
    PVector yAxis = new PVector(0, 1, 0).mult(getSin((int)rotationAmount));
    returnVal = rotateQ(rotationCoefficient, yAxis, returnVal);
  }
 
 if(rotationDirection == 'z'){
    rotationCoefficient = getCos((int)rotationAmount);
    PVector zAxis = new PVector(0, 0, 1).mult(getSin((int)rotationAmount));
    returnVal = rotateQ(rotationCoefficient, zAxis, returnVal);
  }
 
  return returnVal;
}
