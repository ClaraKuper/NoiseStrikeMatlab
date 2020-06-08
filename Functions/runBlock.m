function [blockData,dataLog] = runBlock(b)

    global visual design
    messageStart = sprintf('This is block no. %i', b);
    DrawFormattedText(visual.window, messageStart, 'center', 200, visual.textColor);
    trials_total = design.nTrialsPB;
    t            = 1;
    score        = 0;
    
    Screen('Flip',visual.window);
    WaitSecs(2);
    
    while t <=  trials_total
        
        trial = design.b(b).trial(t); 
        
        [blockData.trial(t),dataLog.trial(t), trialScore] = runSingleTrial(trial, design, visual);
        
        score = score + trialScore;
        
        if blockData.trial(t).success
            
            trials_total                    = trials_total + 1;
            design.b(b).trial(trials_total) = trial;
        
        end
        
        t = t+1;
        
    end
    
    messageEnd = sprintf('You gained %i points in this block.', score);
    DrawFormattedText(visual.window, messageEnd, 'center', 200, visual.textColor);
    
    Screen('Flip', visual.window);
    WaitSecs(2);
end
