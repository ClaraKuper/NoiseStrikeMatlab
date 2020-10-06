function trialData  = runSingleTrial(trial, design, visual, settings, t, el)

    Datapixx('SetTouchpixxLog');                                    % Configure TOUCHPixx logging with default buffer
    Datapixx('EnableTouchpixxLogContinuousMode');                   % Continuous logging during a touch. This also gives you long output from buffer reads
    Datapixx('StartTouchpixxLog');
    
    t_initPixx = Datapixx('GetTime');  % Save when the DataPixx Log was initiated
    
    Eyelink('StartRecording');

    % prepare the trial
    % set stimuli
    goalypost = trial.goalPos * visual.ppd + visual.yCenter;
    
    %travelyDist = trial.yDist * visual.ppd;  
    ySpeed      = 0; %travelyDist/visual.hz;    
    xSpeed      = visual.xSpeed;
    goalPos     = [visual.goalxPos, goalypost];
    visual.goalxPos
    
    attackerPos = [visual.attackerPos(1), trial.yPosAttacker*visual.ppd + visual.yCenter]; %visual.attackerPos;
    visual.attackerPos(1)
    attackerSize = visual.attackerRad;
    attackerColor = visual.attackerColor;
    attackerVisible = visual.attackerVisible;

    posSet = trial.posSet * visual.ppd + visual.yCenter;
    posId = 1;

    targetPos = [visual.targetxPos, posSet(posId)];
    targetSize = visual.targetRad;
    targetColor = visual.targetColor;
    
%     fixPos = visual.fixPos;
%     fixSize = visual.fixRad;
%     fixColor = visual.fixColor;

    % events and responses
    if 2 < trial.trajectory && trial.trajectory < 7
        hitgoal = 1;
    else
        hitgoal = 0;
    end
    
    % Draw stuff on Eyelink:
    Eyelink('command',sprintf('draw_box %d %d %d %d 15', attackerPos(1)-visual.rangeAccept, attackerPos(2)-visual.rangeAccept, attackerPos(1)+visual.rangeAccept, attackerPos(2)+visual.rangeAccept));
    Eyelink('command',sprintf('draw_box %d %d %d %d 15', goalPos(1)-visual.rangeAccept, goalPos(2)-visual.rangeAccept, goalPos(1)+visual.goalHeight, goalPos(2)+visual.goalHeight));
    
    
    % Initialize timing and monitoring parameters
    on_fix_hand    = false;
    on_fix_eye     = false;
    kb_released    = false;
    goresp         = 0;
    fixation_break = false;
    response       = 'NONE';
    
    tar_pos_movStart = 0;
    tar_pos_movEnd   = 0;

    % timing
    t_draw     = NaN;  % the stimulus was on screen
    t_kbdown   = NaN;  % the fixation was touched
    t_eyesfixed= NaN;  % the observer looked at the start
    t_go       = NaN;  % the attacker started moving
    t_disap    = NaN;  % the attacker disappeared
    t_movStart = NaN;  % the movement started
    t_cross    = NaN;  % the attacker crossed the x position of the goal
    t_movEnd   = NaN;  % the movements ended
    t_end      = NaN;  % the trial is over
    
    % screen flips
    flip_count = 0;
    
    % per default, the trial is a success :)
    trial_succ = 1;
    
    % Run the trial. Display the goal and a moving ball
	Eyelink('Message', sprintf('TRIAL_START, %i', t));
    Eyelink('Message', 'TRIAL_SYNCTIME');
	
    Screen('DrawDots', visual.window, attackerPos, attackerSize, attackerColor, [], 2); % attacker
%    Screen('DrawDots', visual.window, targetPos, targetSize, targetColor, [], 2); % target
    
    Screen('Flip', visual.window);
    Datapixx('RegWrRd');
    t_draw = Datapixx('GetTime');
    Eyelink('Message', 'STIM_ON_SCREEN');
    flip_count = flip_count +1;

    % while the finger is not yet on the starting position, monitor for that
    while ~ on_fix_hand || ~on_fix_eye 
        Datapixx('RegWrRd');
      
        % are there any keykeyboard presses detected?
        [~, ~ , keyCode] = KbCheck;
        if keyCode(design.response) && ~ on_fix_hand
            on_fix_hand  = true;
            Eyelink('Message', 'KEYBOARD_DOWN');
            t_kbdown = Datapixx('GetTime');
        end
        if Eyelink('NewFloatSampleAvailable') > 0
            % get the sample in the form of an event structure
            evt = Eyelink('NewestFloatSample');
            % if we do, get current gaze position from sample
            x = evt.gx(settings.eye_used+1); % +1 as we're accessing MATLAB array
            y = evt.gy(settings.eye_used+1);
            % do we have valid data and is the pupil visible?
            if  attackerPos(1) - visual.rangeAccept < x && x < attackerPos(1) + visual.rangeAccept &&...
                attackerPos(2) - visual.rangeAccept < y && y < attackerPos(2) + visual.rangeAccept && ~ on_fix_eye
                on_fix_eye = true;
                Eyelink('Message', 'EYES_FIXATED');
                t_eyesfixed = Datapixx('GetTime');
            end
%        else
%            sprintf('Sth is wrong with the eyelink');
%            Eyelink('Message', sprintf('TRIAL_STOPPED %i',t));
%            calibrate = true;
%            break
        end
        
        Screen('DrawDots', visual.window, attackerPos, attackerSize, attackerColor, [], 2); % attacker
        %Screen('DrawDots', visual.window, targetPos, targetSize, targetColor, [], 2); % target
        Screen('Flip', visual.window);
        flip_count = flip_count +1;
    end
    Eyelink('Message', 'BOTH_FIX');
    
    WaitSecs(design.fixDur);
    % move the attacker
    % most crucial timing in this loop
    while on_fix_hand && isnan(t_cross)
        Datapixx('RegWrRd');
        if isnan(t_go) % set time stamp the first time this is executed
            Eyelink('Message', 'ATTACKER_MOVED');
            t_go = Datapixx('GetTime');
        end
        
        % this block updates the attacker position. 
        attackerPos = attackerPos+[xSpeed, ySpeed];
        % on every xth flip as definined by design, the target position is
        % updated
        if mod(flip_count, design.targetDur) == 0
            posId       = posId+1;
            targetPos = [visual.targetxPos, posSet(posId)];
            Eyelink('Message', 'NEW_TARGET, x: %i, y: %i', round(targetPos(1)), round(targetPos(2)));
        end
        
        if Datapixx('GetTime')-t_go < attackerVisible % this is when we draw the attacker
            Screen('DrawDots', visual.window, attackerPos, attackerSize, attackerColor, [], 2); % attacker
        elseif isnan(t_disap)
            Eyelink('Message', 'ATTACKER_DISAPPEARED');
            t_disap = Datapixx('GetTime');
        end
        
        %Draw everything on the screen and show
        Screen('DrawDots', visual.window, targetPos, targetSize, targetColor, [], 2); % target        
        Screen('Flip', visual.window);
        
        % Get the touchpixx status
        Datapixx('RegWrRd');
        status = Datapixx('GetTouchpixxStatus');
        flip_count = flip_count +1;
        
        % check if keyboard has been released
        [~, ~, keyCode] = KbCheck;
        if ~ keyCode(design.response) &&  ~kb_released
            Eyelink('Message', 'START_HAND_MOVEMENT');
            t_movStart      = Datapixx('GetTime');
            kb_released     = true;
%             dataLog.message = [dataLog.message, sprintf('The hand moved at %f\n', t_movStartPixx)];f
            tar_pos_movStart = posId;
        end
        
        % Check for events
        if status.newLogFrames                                              % something new happened
            [touches, ~] = Datapixx('ReadTouchpixxLog');
            touch_X = visual.mx*touches(1,status.newLogFrames)+visual.bx;   % Convert touch to screen coordinates
            touch_Y = visual.my*touches(2,status.newLogFrames)+visual.by;   % We use the one-before-last available touch information
            
            % check if movement started (touch not within box around window)
            Datapixx('RegWrRd');
            
            % check if movement reached the target box
            if ~ goresp && ...
                    goalPos(1) - visual.rangeAccept < touch_X && touch_X < goalPos(1) + visual.rangeAccept &&...
                    goalPos(2) - visual.rangeAccept < touch_Y && touch_Y < goalPos(2) + visual.rangeAccept
               Eyelink('Message', 'END_HAND_MOVEMENT');
               t_movEnd    = Datapixx('GetTime');                    % we want a time tag when the target was touched for the first time
               goresp          = 1;
               tar_pos_movEnd = posId;
            end
        end
        if attackerPos(1) >= goalPos(1)
            Datapixx('RegWrRd');
            Eyelink('Message', 'ATTACKER_REACHED_GOAL');
            t_cross   = Datapixx('GetTime');
            if isnan(t_movEnd)
                % set a time for the movement end
                t_movEnd = t_cross;
                goresp  = 0;
            end
        end
        
        % get gaze position to check if it's on screen
        evt = Eyelink('NewestFloatSample');
        if evt.pa(settings.eye_used+1) < 1 % is the pupil visible?
            fixation_break = true;
            Eyelink('Message', 'FIXATION_BREAK');
        end
    end
    
    Datapixx('RegWrRd');
    t_end           = Datapixx('GetTime');
%     dataLog.message = [dataLog.message, sprintf('Trial End at %f \n', t_end)];
    Datapixx('StopTouchpixxLog');  
	
   

    rea_time = t_movStart - t_go;
    mov_time = t_movEnd - t_movStart; 
    
    % present feedback
    if fixation_break
        DrawFormattedText(visual.window, 'Fixation Break', 'center', 'center', visual.textColor);
        response = 'FIXATION_BREAK';
        trial_succ = 0;
        EyelinkDoTrackerSetup(el);
    elseif goresp && hitgoal 
        DrawFormattedText(visual.window, 'Well done!', 'center', 'center', visual.textColor);
        response = 'HIT';
    elseif goresp && ~hitgoal 
        DrawFormattedText(visual.window, 'False Alarm', 'center', 'center', visual.textColor);
        response = 'FALSE ALARM';
    elseif ~goresp 
        if kb_released
            DrawFormattedText(visual.window, 'Too slow', 'center', 'center', visual.textColor);
            trial_succ = 0;
        elseif hitgoal 
            DrawFormattedText(visual.window, 'Missed!', 'center', 'center', visual.textColor);
            response = 'MISS';
        elseif ~hitgoal 
            DrawFormattedText(visual.window, 'Correct!', 'center', 'center', visual.textColor);
            response = 'CORRECT REJECTION';
        end
    else
        DrawFormattedText(visual.window, 'Unknown Error', 'center', 'center', visual.textColor);
        trial_succ = 0;
    end
    
    Eyelink('Message', 'FEEDBACK_PRESENTED');
    
    Screen('Flip', visual.window);
    
    Eyelink('Message', 'RESPONSE_TRIAL %i, %s', t, response);
    Eyelink('Message', sprintf('TRIAL_END, %i', t));
    Eyelink('StopRecording');
    
    trialData.success         = trial_succ;                                 % 1 = success 
                                                                            % 0 = unknown error
    trialData.rea_time        = rea_time;
    trialData.mov_time        = mov_time;
    trialData.initPixx        = t_initPixx;
    trialData.t_draw          = t_draw;
    trialData.t_kbdown        = t_kbdown;
    trialData.t_eyesfixed     = t_eyesfixed;
    trialData.t_go            = t_go;
    trialData.t_disap         = t_disap;
    trialData.t_movStart      = t_movStart;
    trialData.t_movEnd        = t_movEnd;
    trialData.t_cross         = t_cross;
    trialData.t_end           = t_end;
    
    trialData.goResp          = goresp;
    trialData.hitGoal         = hitgoal;
    
    %trialData.yDist           = abs(travelyDist) - abs(goalypost);
    trialData.goalY           = goalypost;
    trialData.trajectory      = trial.trajectory;
    trialData.posSet          = posSet;
    trialData.posMovStart     = tar_pos_movStart;
    trialData.posMovEnd       = tar_pos_movEnd;
    
    Eyelink('command', 'clear_screen 0');
    WaitSecs(design.iti);
end