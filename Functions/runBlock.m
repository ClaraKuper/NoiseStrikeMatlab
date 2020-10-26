function blockData = runBlock(b, b_i, el)

    global visual design settings
    
    messageStart = sprintf('This is block no. %i', b_i);
    DrawFormattedText(visual.window, messageStart, 'center', 200, visual.textColor);
    trials_total = design.nTrialsPB;
    if b == 1
        trials_total = length(design.b(b).trial); 
    end
    t            = 1;
    
    Screen('Flip',visual.window);
    WaitSecs(2);
    
    Eyelink('Message', sprintf('BLOCK_START, %i', b));
    while t <=  trials_total
        
        trial = design.b(b).trial(t); 
        if b > 1
            trial.difficulty = design.b(b).difficulty;
        end
        blockData.trial(t) = runSingleTrial(trial, design, visual, settings, t, el);
       
        
        if ~ blockData.trial(t).success
            
            trials_total                    = trials_total + 1;
            design.b(b).trial(trials_total) = trial;
        
        end
        
        t = t+1;        
    end
    
    Eyelink('Message', sprintf('BLOCK_END, %i', b));
    Screen('Flip', visual.window);
    WaitSecs(2);
end
