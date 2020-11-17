function genDesign(vpcode)
%
% 2017 by Martin Rolfs
% 2019 mod by Clara Kuper

global design scr

% randomize random
rand('state',sum(100*clock));

design.vpcode    = vpcode;

% Timing %
design.fixDur_fix   = 0.5; % Fixation duration till trial starts [s]
design.fixDurJ      = 0.25; % Additional jitter to fixation
design.fixDur       = design.fixDur_fix + rand * design.fixDurJ;

design.iti         = 0.2; % Inter stimulus interval
design.wait_to_fix = 1.0;

% response key
design.response = KbName('space');

% conditions
design.nGoalPos   = 5;
design.nyDist_b1  = 5;  % trajectories to be tested in the first block

% position and size variables, in dva     
% Fixation
design.fixWidth = 1;
design.fixHeight = 1;
design.fixRad = 0.2;
design.fixPos = [0,0];

% Attacker
design.attackerRad = 1;
design.attackerxPos= -10;
design.attackeryPos= 0;
design.travelDur   = 0.8; % time in sec
design.difficulty_b1= linspace(0.05,2,design.nyDist_b1); % the postion of the attacker, varies only in the first block
design.up_down     = [1, -1]; % 1 is up, -1 is down
design.in_out      = [1, -1]; % 1 is out, -1 is in (follows from the maths in function getyTar)
design.xSpeed      = 0;  % initialize only, change later
design.attackerVisible =  0.6;


% Goal
design.goalHeight = 4;
design.goalxPos   = 10;
design.goalShift  = 5;
design.goalyPos   = linspace(-design.goalShift, design.goalShift, design.nGoalPos);

% Target

design.targetRad        = 1;
design.targetxPos       = design.goalxPos;
design.targetyPos_range = [design.goalHeight, -design.goalHeight];
design.targetDur        = 6; % target duration in frames

design.rangeAccept = 2;
design.rangeCalib  = 1;

% speed variables, in dva/s
design.travelxDist = abs(design.attackerxPos)+abs(design.targetxPos);
design.travelFrames = design.travelxDist * scr.refRate;

% overall information %
% number of blocks and trials in the first round
design.nBlocks = 5;
design.nTrials = 2;%5; 

% build block 1 - test block
for b = 1
    t = 0;
    for goal = design.goalyPos
        for in_out = design.in_out
            for up_down = design.up_down
                for difficulty = design.difficulty_b1
                    t = t+1;
                    % define goal position
                    trial(t).goalPos = goal;
                    % define the y position of the attacker
                    trial(t).difficulty = difficulty;
                    % define in_out
                    trial(t).in_out = in_out;
                    % define up_down
                    trial(t).up_down = up_down;
                    % define target positions
                    trial(t).posSet = drawposset(goal,design.targetyPos_range,60);
                    % define fixation duration
                    trial(t).fixT    = design.fixDur + rand(1)*design.fixDurJ;
                end
            end
        end
    end
    
    % randomize trials
    r = randperm(t);
    design.b(b).trial = trial(r);
end
    
% build experimental blocks
for b = 2:design.nBlocks
    t = 0;
    for triali = 1:design.nTrials
        for goal = design.goalyPos
            for in_out = design.in_out
                for up_down = design.up_down
                    t = t+1;
                    % define goal position
                    trial(t).goalPos = goal;
                    % define the y position of the attacker
                    % trial(t).yPosAttacker = 0; % will be changed later, this is just here for testing reasons
                    % define in_out
                    trial(t).in_out = in_out;
                    % define up_down
                    trial(t).up_down = up_down;
                    % define target positions
                    trial(t).posSet = drawposset(goal,design.targetyPos_range,60);
                    % define fixation duration
                    trial(t).fixT    = design.fixDur + rand(1)*design.fixDurJ;
                end
            end
        end
    end

    
    % randomize trials
    r = randperm(t);
    design.b(b).trial = trial(r);
end

blockOrder = [2:b];

design.blockOrder = blockOrder(randperm(length(blockOrder)));
design.nTrialsPB  = t;

% save 
save(sprintf('./Design/%s.mat',vpcode),'design');

end

