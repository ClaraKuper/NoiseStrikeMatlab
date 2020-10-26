function blockData = runBlock(b, b_i, el)

    global visual design settings
    
    % print some messages at the beginning
    messageStart = sprintf('This is block no. %i', b_i);
    DrawFormattedText(visual.window, messageStart, 'center', 200, visual.textColor);
    DrawFormattedText(visual.window, 'Press any key to start', 'center', 'center', visual.textColor);
    Screen('Flip',visual.window);
    
    % prepare block info
    trials_total = design.nTrialsPB;
    if b == 1
        trials_total = length(design.b(b).trial); 
    end
    t            = 1;
    
    % wait for participant
    KbPressWait;    
    
    Eyelink('Message', sprintf('BLOCK_START, %i', b));
   
    % gro through trials
    while t <=  trials_total
        
        trial = design.b(b).trial(t); 
        if b > 1
            trial.difficulty = design.b(b).difficulty;
        end
        blockData.trial(t) = runSingleTrial(trial, design, visual, settings, t, el);
       
        % repeat the trial, if needed
        if ~ blockData.trial(t).success
            
            trials_total                    = trials_total + 1;
            design.b(b).trial(trials_total) = trial;
        
        end
        
        t = t+1;        
    end
    
    % end of the block
    Eyelink('Message', sprintf('BLOCK_END, %i', b));
    Screen('Flip', visual.window);
    WaitSecs(2);
end
