function yTar=getytar(ypos, height, difficulty, in_out, up_down)
    % ypos = the middle point of the goal
    % height = helf the size of the goal
    % difficulty = by how much to miss (or to hit)
    % in_out = if the target is inside or outside of the goal
    % 

    % define an upper and a lower bound:
    border = ypos + (height * up_down);
    tra = difficulty * in_out * up_down;
    yTar = border + tra;  

