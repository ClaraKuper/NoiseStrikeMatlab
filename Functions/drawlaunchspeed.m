function ySpeed=drawlaunchspeed(ypos, tra, height, frames)
    %%%tra in range from 1 - 8 is one of 8 possible trajectories:
    %1: far, up, out: 1 dva above upper border
    %2: close, up, out: 0.5 dva above upper border
    %3: close, up, in: 0.5 dva below upper border
    %4: far, up, in: 1 dva below upper border
    %5: far, down, in: 1 dva above lower border
    %6: close, down, in: 0.5 dva above lower border
    %7: close, down, out: 0.5 dva below lower border
    %8: far, down, out: 1 dva below lower border
    %%%
    % define an upper and a lower bound:
    upper = ypos + height;
    lower = ypos - height;
    if tra == 1
        pos = upper + 2;
    elseif tra == 2
        pos = upper + 1;
    elseif tra == 3
        pos = upper - 1;
    elseif tra == 4
        pos = upper - 2;
    elseif tra == 5
        pos = lower + 2;
    elseif tra == 6
        pos = lower + 1;
    elseif tra == 7
        pos = lower - 1;
    elseif tra == 8
        pos = lower - 2;
    end
        

    ySpeed = pos/frames;
