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
  float rotationAmtHalf = rotationAmount * 0.5;
  float rotationCoefficient = getCos(rotationAmtHalf);
    
  if(rotationDirection == 'x'){
    PVector xAxis = new PVector(1, 0, 0).mult(getSin(rotationAmtHalf));
    returnVal = rotateQ(rotationCoefficient, xAxis, returnVal);
  }
  
  if(rotationDirection == 'y'){
    PVector yAxis = new PVector(0, 1, 0).mult(getSin(rotationAmtHalf));
    returnVal = rotateQ(rotationCoefficient, yAxis, returnVal);
  }
 
 if(rotationDirection == 'z'){
    PVector zAxis = new PVector(0, 0, 1).mult(getSin(rotationAmtHalf));
    returnVal = rotateQ(rotationCoefficient, zAxis, returnVal);
  }
 
  return returnVal;
}

PVector rotateAroundCustomAxis(float rotationAmount, PVector axisOfRotation, PVector pointToRotate){
  PVector returnVal = pointToRotate.copy();
  float rotationAmtHalf = rotationAmount * 0.5;
  float rotationCoefficient = getCos(rotationAmtHalf);
 
  PVector customAxis = axisOfRotation.copy().mult(getSin(rotationAmtHalf));
  returnVal = rotateQ(rotationCoefficient, customAxis, returnVal);
 
  return returnVal;
}

float get2DLength(PVector p){
  return p.x*p.x + p.y*p.y;
}

void swapBlocks(Block[] arr, int a, int b){
  if(a < 0 || b < 0 || a >= arr.length || b >= arr.length){
    return;
  }
  Block temp = arr[a];
  arr[a] = arr[b];
  arr[b] = temp;
}

float getCos(float angle){
  return cosTable[(int)(angle*2 + 360) % 360];
}

float getSin(float angle){
  return sinTable[(int)(angle*2 + 360) % 360];
}
