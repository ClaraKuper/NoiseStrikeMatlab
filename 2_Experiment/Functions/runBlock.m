function blockData = runBlock(b, b_i, el)

    global visual design settings
    
    % print some messages at the beginning
    messageStart = sprintf('This is block no. %i', b_i);
    DrawFormattedText(visual.window, messageStart, 'center', 200, visual.textColor);
    DrawFormattedText(visual.window, 'Press any key to start', 'center', 'center', visual.textColor);
    Screen('DrawLine', visual.window, visual.targetColor, visual.exampleGoal(1), visual.exampleGoal(2), visual.exampleGoal(3), visual.exampleGoal(4), 5);
    Screen('Flip',visual.window);
    
    % prepare block info
    trials_total = design.nTrialsPB;
    t            = 1;
    
    % wait for participant
    KbPressWait;    
    
    Eyelink('Message', sprintf('BLOCK_START, %i, DESIGN %i', b_i, b));
    % go through trials
    while t <=  trials_total
                
        settings.id = settings.id+1;
        Eyelink('Message', 'TRIAL_ID, %i', settings.id);
        trial = design.b(b).trial(t);
        blockData.trial(t) = runSingleTrial(trial, design, visual, settings, t, el);
        %blockData.trial(t) = runStaircase(trial, design, visual, settings, t, el);
              
        
        % repeat the trial, if needed
        if ~ blockData.trial(t).success
            
            trials_total                    = trials_total + 1;
            design.b(b).trial(trials_total) = trial;
       
        end
        
        design.b(b).trial(t).id = settings.id;
        t = t+1;        
    end
    
    % end of the block
    Eyelink('Message', sprintf('BLOCK_END, %i, DESIGN, %i', b_i, b));
    Screen('Flip', visual.window);
    WaitSecs(2);
end
