function blockData = runBlock(b, b_i)

    global visual design settings
    messageStart = sprintf('This is block no. %i', b_i);
    DrawFormattedText(visual.window, messageStart, 'center', 200, visual.textColor);
    trials_total = design.nTrialsPB;
    t            = 1;
    
    Screen('Flip',visual.window);
    WaitSecs(2);
    
    while t <=  trials_total
        
        trial = design.b(b).trial(t); 
        Eyelink('Message', sprintf('BLOCK_START, %i', b));
        blockData.trial(t) = runSingleTrial(trial, design, visual, settings, t);
       
        
        if ~ blockData.trial(t).success
            
            trials_total                    = trials_total + 1;
            design.b(b).trial(trials_total) = trial;
        
        end
        
        t = t+1;
		Eyelink('Message', sprintf('BLOCK_END, %i', b));
        
    end
    
    Screen('Flip', visual.window);
    WaitSecs(2);
end
