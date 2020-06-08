function posSet = drawposset(ypos, posrange, n):
    
    a = posrange[1] + ypos
    b = posrang[2] + ypos
    posSet = (b-a).*rand(1000,n) + a;