
## Demonstration of App
<img width="1824" height="1880" alt="Screenshot 2025-08-29 at 4 41 29 PM" src="https://github.com/user-attachments/assets/58855bc7-0f22-4418-84e9-191f367682a4" />

Note: openJDK 17 may need to be installed for the applications to work properly
  
This project is a step up in difficulty from all of the other projects I have done. 
It stems from my hobbies of solving Rubik's Cubes and also challenging myself even more than before.
5 weeks of coding have been invested into this project to create a working version that I would be happy with, 
and I still want to add more features.
But for now, enjoy this current version of a 3D Rubik's Cube.

This project is based on 2 YouTube videos:
- https://www.youtube.com/watch?v=p4Iz0XJY-Qk (3d object creation, perspective projection)
- https://www.youtube.com/watch?v=aMqeG_0aFd0 (3d rotations)

Manual (rotating the cube): 
- x = rotate cube around x-axis (toggled on/off)
- y = rotate cube around y-axis (toggled on/off)
- z = rotate cube around z-axis (toggled on/off)
- SPACE = rotate cube around all three axes (toggled on/off)
- UP Arrow = manually rotate cube around x-axis upwards
- DOWN Arrow = manually rotate cube around x-axis downwards
- LEFT Arrow = manually rotate cube around y-axis to the left
- RIGHT Arrow = manually rotate cube around y-axis to the right
- , (comma) = manually rotate cube around z-axis anti-clockwise (top symbol is <)
- . (period) = manually rotate cube around z-axis clockwise (top symbol is >)
- i = invert direction manually (toggled on/off)
- Mouse = drag the cube in the direction of the mouse

Manual (turning the cube):
- 1-5 = choose layer on cube (the nth layer from the edge to the center)
- r = turn cube's red face (positive x-axis)
- l = turn cube's orange face (negative x-axis)
- u = turn cube's white face (negative y-axis)
- d = turn cube's yellow face (positive y-axis)
- f = turn cube's green face (positive z-axis)
- b = turn cube's blue face (negative z-axis)
- SHIFT = invert direction based on whether it's being held down
- TAB = doubles the turn amount of a specific turn when held down

Manual (miscellaneous):
- BACKSPACE = delete the most recently typed move if it hasn't been executed yet
- RETURN = reset the cube's properties (position, turn list, etc)

