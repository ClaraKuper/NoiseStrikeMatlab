function [trialData,dataLog, trialScore]  = runSingleTrial(trial, design, visual)

    Datapixx('SetTouchpixxLog');                                    % Configure TOUCHPixx logging with default buffer
    Datapixx('EnableTouchpixxLogContinuousMode');                   % Continuous logging during a touch. This also gives you long output from buffer reads
    Datapixx('StartTouchpixxLog');


    % Prepare the trial
    jumpPos     = visual.ballPos + [0,trial.jumpPos*visual.ppd];    % the position when the ball jumps to it's attackPos
    attackPos   = [visual.goals(trial.goalPos,1),jumpPos(2)+visual.speed];       % the attack position, now the target is revealed

    % Assign ball position to be at start
    ballPos = visual.ballPos;
    keeperPos  = visual.keeperPos;
    
    % some other information
    goalPos = trial.goalPos;
    if goalPos == 1
        disPos  = 2;
    else
        disPos  = 1;
    end

    % Initialize timing and monitoring parameters
    on_fix         = false;
    jumped         = false;
    hit_target     = false;
    hit_distractor = false;
    no_hit         = false;
    early_rea      = false;

    % timing
    t_initPixx = NaN;  % initialize the DataPixx Log
    t_draw     = NaN;  % the stimulus was on screen
    t_touched  = NaN;  % the ball was touched
    t_go       = NaN;  % the ball started moving
    t_movStart = NaN;  % the movement started
    t_jump     = NaN;  % the ball has jumped
    t_movEnd   = NaN;  % the movements ended
    t_goal     = NaN;  % the ball reached the goal
    t_end      = NaN;  % the trial is over
    
    % position logging
    resPos     = NaN;
    trial_succ = NaN;
    
    % score
    trialScore = 0;
    
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
    Screen('DrawDots', visual.window, visual.goals(1,:), visual.goalSize, visual.goalColor, [], 2);
    Screen('DrawDots', visual.window, visual.goals(2,:), visual.goalSize, visual.goalColor, [], 2);
    Screen('DrawDots', visual.window, ballPos, visual.ballSize, visual.ballColor, [], 2);
    Screen('DrawLine', visual.window, visual.goalColor, keeperPos(1)- visual.keeperSize , keeperPos(2), keeperPos(1) + visual.keeperSize, keeperPos(2));
    Screen('Flip', visual.window);
    Datapixx('RegWrRd');
    t_draw = Datapixx('GetTime');

    % while the finger is not yet on the starting position, monitor for that
    while ~ on_fix
        Datapixx('RegWrRd');
        status = Datapixx('GetTouchpixxStatus');
        
        % are there any touches detected?
        if isfield(status, 'newLogFrames') && status.newLogFrames > 0  % We have new TOUCHPixx logged data to read?
            [touches, timetag] = Datapixx('ReadTouchpixxLog');              % load new information
            dataLog.touches    = [dataLog.touches,touches];                 % write them to LogFile
            dataLog.timetag    = [dataLog.timetag, timetag];  
            dataLog.frames     = [dataLog.frames, status.newLogFrames];
            touch_X = visual.mx*touches(1,status.newLogFrames)+visual.bx;   % convert touch to screen coordinates
            touch_Y = visual.my*touches(2,status.newLogFrames)+visual.by;
            if touch_X > keeperPos(1) - visual.rangeAccept && touch_X < keeperPos(1) + visual.rangeAccept && ...
                    touch_Y > keeperPos(2) - visual.rangeAccept && ...
                    touch_Y < keeperPos(2) + visual.rangeAccept
                on_fix = true;
                t_touched     = timetag(status.newLogFrames);
                t_touchedPixx = Datapixx('GetTime');
                dataLog.message = [dataLog.message, sprintf('The fixation point was touched at %f \n', t_touchedPixx)];
                WaitSecs(trial.fixT);
            end
            Screen('DrawDots', visual.window, visual.goals(1,:), visual.goalSize, visual.goalColor, [], 2);
            Screen('DrawDots', visual.window, visual.goals(2,:), visual.goalSize, visual.goalColor, [], 2);
            Screen('DrawDots', visual.window, ballPos, visual.ballSize, visual.ballColor, [], 2);
            Screen('DrawLine', visual.window, visual.goalColor, keeperPos(1)-visual.keeperSize , keeperPos(2), keeperPos(1) + visual.keeperSize, keeperPos(2));
            Screen('Flip', visual.window);
        end
    end;

    % move the ball downwards
    % most crucial timing in this loop
    while on_fix && isnan(t_goal)
        Datapixx('RegWrRd');
        if isnan(t_go) % set time stamp the first time this is executed
            t_go = Datapixx('GetTime');
            dataLog.message = [dataLog.message, sprintf('The motion started at %f \n', t_go)];
        end
        
        % this block updates the ball position. The default is a downward motion with the velocity defined by visual.speed
        
        if Datapixx('GetTime')-t_go < trial.jumpTim || jumped % check if jump location has been reached or jump already occured
            ballPos = ballPos+[0,visual.speed];
        else
            ballPos      = attackPos; % update ball location to after-jump position
            t_jump       = Datapixx('GetTime');
            jumped       = true;
            dataLog.message = [dataLog.message, sprintf('The ball jumped at %f \n',t_jump)];
        end
        
        %Draw everything on the screen and show
        Screen('DrawDots', visual.window, visual.goals(1,:), visual.goalSize, visual.goalColor, [], 2);
        Screen('DrawDots', visual.window, visual.goals(2,:), visual.goalSize, visual.goalColor, [], 2);
        Screen('DrawDots', visual.window, ballPos, visual.ballSize, visual.ballColor, [], 2);
        Screen('DrawLine', visual.window, visual.goalColor, keeperPos(1)-visual.keeperSize , keeperPos(2), keeperPos(1) + visual.keeperSize, keeperPos(2));
        Screen('Flip', visual.window);
        
        % Get the touchpixx status
        Datapixx('RegWrRd');
        status = Datapixx('GetTouchpixxStatus');
        
        % Check for events
        if status.newLogFrames                                              % something new happened
            [touches, timetag] = Datapixx('ReadTouchpixxLog');
            dataLog.touches    = [dataLog.touches,touches];                 % write new information to log file
            dataLog.timetag    = [dataLog.timetag, timetag];
            dataLog.frames     = status.newLogFrames;
            touch_X = visual.mx*touches(1,status.newLogFrames)+visual.bx;   % Convert touch to screen coordinates
            touch_Y = visual.my*touches(2,status.newLogFrames)+visual.by;   % We use the one-before-last available touch information
            
                                                                    % on frame is discarded to account for no-touch-recoding (coordinates 0,0)
            
            if touch_X > 0 & touch_Y > 0
              keeperPos  = [touch_X,touch_Y];                                        % we set the position of the bar to the current touch coordinates 
            end
            
            % check if movement started (touch not within box around window)
            Datapixx('RegWrRd');
            if isnan(t_movStart) && touch_X < visual.keeperPos(1) - visual.rangeAccept || ...
                    isnan(t_movStart) && touch_X > visual.keeperPos(1) + visual.rangeAccept ||...
                    isnan(t_movStart) && touch_Y < visual.keeperPos(2) - visual.rangeAccept ||...
                    isnan(t_movStart) && touch_Y > visual.keeperPos(2) + visual.rangeAccept
                t_movStart      = timetag(status.newLogFrames);
                t_movStartPixx  = Datapixx('GetTime');
                dataLog.message = [dataLog.message, sprintf('The hand moved at %f\n', t_movStartPixx)];
                if t_movStart - t_go < 0
                    early_rea   = true;
                    break
                end
            % check if movement reached the target box
            elseif ~ hit_target && touch_X > visual.goals(trial.goalPos,1) - visual.rangeAccept && ...
                    touch_X < visual.goals(trial.goalPos,1) + visual.rangeAccept &&...
                    touch_Y > visual.goals(trial.goalPos,2) - visual.rangeAccept &&...
                    touch_Y < visual.goals(trial.goalPos,2) + visual.rangeAccept
               t_movEnd        = timetag(status.newLogFrames);                    % we want a time tag when the target was touched for the first time
               t_movEndPixx    = Datapixx('GetTime');
               dataLog.message = [dataLog.message, sprintf('The hand reached the target at %f\n',t_movEndPixx)];
               hit_target      = true;
               trial_succ      = 0;
            elseif ~ hit_distractor && touch_X > visual.goals(disPos,1) - visual.rangeAccept && ...
                    touch_X < visual.goals(disPos,1) + visual.rangeAccept &&...
                    touch_Y > visual.goals(disPos,2) - visual.rangeAccept &&...
                    touch_Y < visual.goals(disPos,2) + visual.rangeAccept
                t_movEnd        = timetag(status.newLogFrames);                    % we want a time tag when the target was touched for the first time
                t_movEndPixx    = Datapixx('GetTime');
                dataLog.message = [dataLog.message, sprintf('The hand reached the distractor at %f\n',t_movEndPixx)];
                hit_distractor  = true;
                trial_succ      = 0;
            end
        end
        if ballPos(2) >= visual.goals(goalPos,2)
            Datapixx('RegWrRd');
            t_goal   = Datapixx('GetTime');
            dataLog.message = [dataLog.message, sprintf('The ball hit the target at %f\n', t_goal)];
            if isnan(t_movEnd)
                % set a time for the movement end
                t_movEnd = t_goal;
                no_hit   = true;
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

    if isnan(t_movStart)
        DrawFormattedText(visual.window, 'Movement not executed.', 'center', 'center', visual.textColor);
        trial_succ = 1;
    elseif rea_time > design.alResT
        DrawFormattedText(visual.window, 'Reaction to slow!', 'center', 'center', visual.textColor);
        trial_succ = 6;
    elseif mov_time > design.alMovT
        trial_succ = 2;
        DrawFormattedText(visual.window, 'Move faster!', 'center', 'center', visual.textColor);
    elseif hit_target 
        DrawFormattedText(visual.window, 'Well done!', 'center', 'center', visual.textColor);
        resPos = goalPos;
        trialScore = trialScore + 200 + (400 - round(rea_time*1000));
    elseif hit_distractor
        DrawFormattedText(visual.window, 'Wrong target!', 'center', 'center', visual.textColor);
        resPos = disPos;
        trialScore = trialScore + (400 - round(rea_time*1000));
    elseif no_hit
        DrawFormattedText(visual.window, 'End point not reached!', 'center', 'center', visual.textColor);
        trial_succ = 3;
    elseif early_rea
        DrawFormattedText(visual.window, 'Wait till go signal!', 'center', 'center', visual.textColor);
        trial_succ = 4;
    else
        DrawFormattedText(visual.window, 'Unknown Error', 'center', 'center', visual.textColor);
        trial_succ = 5;
    end

    Screen('Flip', visual.window);
    
    trialData.resPos          = resPos;
    trialData.success         = trial_succ;                                 % 0 = success 
                                                                            % 1 = no movement 
                                                                            % 2 = reaction too slow 
                                                                            % 3 = long time "in flight" 
                                                                            % 4 = reaction too soon
                                                                            % 5 = unknown error
                                                                            % 6 = reaction too slow
    trialData.rea_time        = rea_time;
    trialData.mov_time        = mov_time;
    trialData.t_draw          = t_draw;
    trialData.t_touched       = t_touched;
    trialData.t_go            = t_go;
    trialData.t_movStart      = t_movStart;
    trialData.t_jump          = t_jump;
    trialData.t_movEnd        = t_movEnd;
    trialData.t_goal          = t_goal;
    trialData.t_end           = t_end;
    
    if trialScore > 0
      message = sprintf('+ %i points!', trialScore);
      DrawFormattedText(visual.window, message , 'center', 'center', visual.textColor);
      Screen('Flip', visual.window);
      WaitSecs(0.5);
   end
    
    WaitSecs(design.iti);
end