function posSet = drawposset(ypos, posrange, n)
    
    a = posrange(1) + ypos;
    b = posrange(2) + ypos;
    posSet = (b-a).*rand(n,1) + a;