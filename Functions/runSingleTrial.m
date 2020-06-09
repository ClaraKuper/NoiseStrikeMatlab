function [trialData,dataLog]  = runSingleTrial(trial, design, visual)

    Datapixx('SetTouchpixxLog');                                    % Configure TOUCHPixx logging with default buffer
    Datapixx('EnableTouchpixxLogContinuousMode');                   % Continuous logging during a touch. This also gives you long output from buffer reads
    Datapixx('StartTouchpixxLog');
    
    t_initPixx = Datapixx('GetTime');  % Save when the DataPixx Log was initiated


    % prepare the trial
    % set stimuli
    goalypost = trial.goalPos * visual.ppd + visual.yCenter;
    
    travelyDist = trial.yDist * visual.ppd;  
    ySpeed      = travelyDist/visual.hz;    
    xSpeed      = visual.xSpeed;
    goalPos     = [visual.goalxPos, goalypost];
    
    attackerPos = visual.attackerPos;
    attackerSize = visual.attackerRad;
    attackerColor = visual.attackerColor;
    attackerVisible = visual.attackerVisible;

    posSet = trial.posSet * visual.ppd + visual.yCenter;
    posId = 1;

    targetPos = [visual.targetxPos, posSet(posId)];
    targetSize = visual.targetRad;
    targetColor = visual.targetColor;
    
    fixPos = visual.fixPos;
    fixSize = visual.fixRad;
    fixColor = visual.fixColor;

    % events and responses
    if 2 < trial.trajectory && trial.trajectory < 7
        hitgoal = 1;
    else
        hitgoal = 0;
    end
    
    % Initialize timing and monitoring parameters
    on_fix         = false;
    goresp         = 0;
    
    tar_pos_movStart = 0;
    tar_pos_movEnd   = 0;

    % timing
    t_draw     = NaN;  % the stimulus was on screen
    t_touched  = NaN;  % the fixation was touched
    t_go       = NaN;  % the attacker started moving
    t_disap     = NaN;  % the attacker disappeared
    t_movStart = NaN;  % the movement started
    t_cross    = NaN;  % the attacker crossed the x position of the goal
    t_movEnd   = NaN;  % the movements ended
    t_end      = NaN;  % the trial is over
    
    % screen flips
    flip_count = 0;
    % per default, the trial is a success :)
    trial_succ = 1;
    
    % dataLog - write all the available logging data here
    Datapixx('RegWrRd');
    status             = Datapixx('GetTouchpixxStatus');
    [touches,timetag]  = Datapixx('ReadTouchpixxLog');
    dataLog.timetag    = timetag;
    dataLog.touches    = touches;
    t_initPixx         = Datapixx('GetTime');
    dataLog.message    = sprintf('Data Log initiated at %f \n', t_initPixx);
    dataLog.frames     = status.newLogFrames;


    % Run the trial. Display the goal and a moving ball
    Screen('DrawDots', visual.window, attackerPos, attackerSize, attackerColor, [], 2); % attacker
    Screen('DrawDots', visual.window, targetPos, targetSize, targetColor, [], 2); % target
    Screen('DrawDots', visual.window, fixPos, fixSize, fixColor, [], 2); % fixation
    
    Screen('Flip', visual.window);
    Datapixx('RegWrRd');
    t_draw = Datapixx('GetTime');
    flip_count = flip_count +1;

    % while the finger is not yet on the starting position, monitor for that
    while ~ on_fix
        Datapixx('RegWrRd');
        status = Datapixx('GetTouchpixxStatus');
        
        % are there any touches detected?
        if isfield(status, 'newLogFrames') && status.newLogFrames > 0       % We have new TOUCHPixx logged data to read?
            [touches, timetag] = Datapixx('ReadTouchpixxLog');              % load new information
            dataLog.touches    = [dataLog.touches,touches];                 % write them to LogFile
            dataLog.timetag    = [dataLog.timetag, timetag];  
            dataLog.frames     = [dataLog.frames, status.newLogFrames];
            touch_X = visual.mx*touches(1,status.newLogFrames)+visual.bx;   % convert touch to screen coordinates
            touch_Y = visual.my*touches(2,status.newLogFrames)+visual.by;
            if fixPos(1) - visual.rangeAccept < touch_X && touch_X < fixPos(1) + visual.rangeAccept && ...
                    fixPos(2) - visual.rangeAccept < touch_Y && touch_Y < fixPos(2) + visual.rangeAccept
                on_fix = true;
                t_touched     = timetag(status.newLogFrames);
                t_touchedPixx = Datapixx('GetTime');
                dataLog.message = [dataLog.message, sprintf('The fixation point was touched at %f \n', t_touchedPixx)];
                WaitSecs(trial.fixT);
            end
            Screen('DrawDots', visual.window, attackerPos, attackerSize, attackerColor, [], 2); % attacker
            Screen('DrawDots', visual.window, targetPos, targetSize, targetColor, [], 2); % target
            Screen('DrawDots', visual.window, fixPos, fixSize, fixColor, [], 2); % fixation
            Screen('Flip', visual.window);
            flip_count = flip_count +1;
        end
    end;

    % move the attacker
    % most crucial timing in this loop
    while on_fix && isnan(t_cross)
        Datapixx('RegWrRd');
        while isnan(t_go) % set time stamp the first time this is executed
            t_go = Datapixx('GetTime');
            dataLog.message = [dataLog.message, sprintf('The motion started at %f \n', t_go)];
        end
        
        % this block updates the attacker position. 
        attackerPos = attackerPos+[xSpeed, ySpeed];
        % on every xth flip as definined by design, the target position is
        % updated
        if mod(flip_count, design.targetDur) == 0
            posId       = posId+1;
            dataLog.message = [dataLog.message, sprintf('The screen was updated to position %i at time %f \n', posId, Datapixx('GetTime'))];
            targetPos = [visual.targetxPos, posSet(posId)];
        end
        
        if Datapixx('GetTime')-t_go < attackerVisible % this is when we draw the attacker
            Screen('DrawDots', visual.window, attackerPos, attackerSize, attackerColor, [], 2); % attacker
        elseif isnan(t_disap)
            t_disap = Datapixx('GetTime');
            dataLog.message = [dataLog.message, sprintf('The attacker disappeared at %f \n', t_disap)];
        end
        
        %Draw everything on the screen and show
        Screen('DrawDots', visual.window, targetPos, targetSize, targetColor, [], 2); % target
        Screen('DrawDots', visual.window, fixPos, fixSize, fixColor, [], 2); % fixation
        
        Screen('Flip', visual.window);
        
        % Get the touchpixx status
        Datapixx('RegWrRd');
        status = Datapixx('GetTouchpixxStatus');
        flip_count = flip_count +1;
        
        % Check for events
        if status.newLogFrames                                              % something new happened
            [touches, timetag] = Datapixx('ReadTouchpixxLog');
            dataLog.touches    = [dataLog.touches,touches];                 % write new information to log file
            dataLog.timetag    = [dataLog.timetag, timetag];
            dataLog.frames     = status.newLogFrames;
            touch_X = visual.mx*touches(1,status.newLogFrames)+visual.bx;   % Convert touch to screen coordinates
            touch_Y = visual.my*touches(2,status.newLogFrames)+visual.by;   % We use the one-before-last available touch information
            
            % check if movement started (touch not within box around window)
            Datapixx('RegWrRd');
            
            if isnan(t_movStart) && touch_X < fixPos(1) - visual.rangeAccept || ...
                    isnan(t_movStart) && touch_X > fixPos(1) + visual.rangeAccept ||...
                    isnan(t_movStart) && touch_Y < fixPos(2) - visual.rangeAccept ||...
                    isnan(t_movStart) && touch_Y > fixPos(2) + visual.rangeAccept
                t_movStart      = timetag(status.newLogFrames);
                t_movStartPixx  = Datapixx('GetTime');
                dataLog.message = [dataLog.message, sprintf('The hand moved at %f\n', t_movStartPixx)];
                tar_pos_movStart = posId;
            % check if movement reached the target box
            elseif ~ goresp && ...
                    goalPos(1) - visual.rangeAccept < touch_X && touch_X < goalPos(1) + visual.rangeAccept &&...
                    goalPos(2) - visual.rangeAccept < touch_Y && touch_Y < goalPos(2) + visual.rangeAccept
               t_movEnd        = timetag(status.newLogFrames);                    % we want a time tag when the target was touched for the first time
               t_movEndPixx    = Datapixx('GetTime');
               dataLog.message = [dataLog.message, sprintf('The hand reached the target at %f\n',t_movEndPixx)];
               goresp          = 1;
               tar_pos_movEnd = posId;
            end
        end
        if attackerPos(1) >= goalPos(1)
            Datapixx('RegWrRd');
            t_cross   = Datapixx('GetTime');
            dataLog.message = [dataLog.message, sprintf('The ball hit the target at %f\n', t_cross)];
            if isnan(t_movEnd)
                % set a time for the movement end
                t_movEnd = t_cross;
                goresp  = 0;
            end
        end
    end
    
    Datapixx('RegWrRd');
    t_end           = Datapixx('GetTime');
    dataLog.message = [dataLog.message, sprintf('Trial End at %f \n', t_end)];
    Datapixx('StopTouchpixxLog');  

    rea_time = t_movStart - t_go;
    mov_time = t_movEnd - t_movStart; 
    
    % present feedback

    if goresp && hitgoal 
        DrawFormattedText(visual.window, 'Well done!', 'center', 'center', visual.textColor);
    elseif goresp && ~hitgoal 
        DrawFormattedText(visual.window, 'False Alarm', 'center', 'center', visual.textColor);
    elseif ~goresp && hitgoal 
        DrawFormattedText(visual.window, 'Missed!', 'center', 'center', visual.textColor);
    elseif ~goresp && ~hitgoal 
        DrawFormattedText(visual.window, 'Correct!', 'center', 'center', visual.textColor);
    else
        DrawFormattedText(visual.window, 'Unknown Error', 'center', 'center', visual.textColor);
        trial_succ = 0;
    end

    Screen('Flip', visual.window);
    
    trialData.success         = trial_succ;                                 % 1 = success 
                                                                            % 0 = unknown error
    trialData.rea_time        = rea_time;
    trialData.mov_time        = mov_time;
    trialData.initPixx        = t_initPixx;
    trialData.t_draw          = t_draw;
    trialData.t_touched       = t_touched;
    trialData.t_go            = t_go;
    trialData.t_disap         = t_disap;
    trialData.t_movStart      = t_movStart;
    trialData.t_movEnd        = t_movEnd;
    trialData.t_cross         = t_cross;
    trialData.t_end           = t_end;
    
    trialData.goResp          = goresp;
    trialData.hitGoal         = hitgoal;
    
    trialData.yDist           = abs(travelyDist) - abs(goalypost);
    trialData.goalY           = goalypost;
    trialData.trajectory      = trial.trajectory;
    trialData.posSet          = trial.posSet;
    trialData.posMovStart     = tar_pos_movStart;
    trialData.posMovEnd       = tar_pos_movEnd;
    
    
    WaitSecs(design.iti);
end