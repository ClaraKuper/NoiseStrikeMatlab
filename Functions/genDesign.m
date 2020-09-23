function genDesign(vpcode)
%
% 2017 by Martin Rolfs
% 2019 mod by Clara Kuper

global design scr

% randomize random
rand('state',sum(100*clock));

design.vpcode    = vpcode;

% hand movement required?
% 1 = move, 0 = don't move
design.sacReq = 1;
design.fixReq = 0;

% include fixation point?
% 1 = include, 0 = ommit
design.InclFix = 1;

% Timing %
design.fixDur_fix   = 0.5; % Fixation duration till trial starts [s]
design.fixDurJ      = 0.25; % Additional jitter to fixation
design.fixDur       = design.fixDur_fix + rand * design.fixDurJ;

design.iti       = 0.2; % Inter stimulus interval

% response key
design.response = KbName('space');

% conditions
design.nGoalPos   = 5;
design.nyDist     = 8;  % 8 different possible trajectories

% position and size variables, in dva     
% Fixation
design.fixWidth = 1;
design.fixHeight = 1;
design.fixRad = 0.2;
design.fixPos = [0,0];

% Attacker
design.attackerRad = 1;
design.attackerxPos= -25;
design.attackeryPos= 0;
design.travelDur   = 0.7; % time in sec
design.yDist       = linspace(1,design.nyDist,design.nyDist);
design.xSpeed      = 0;  % initialize only, change later
design.attackerVisible =  0.6;


% Goal
design.goalHeight = 4;
design.goalxPos   = 25;
design.goalShift  = 5;
design.goalyPos   = linspace(-design.goalShift, design.goalShift, design.nGoalPos);

% Target

design.targetRad        = 1;
design.targetxPos       = design.goalxPos;
design.targetyPos_range = [design.goalHeight*0.9, -design.goalHeight*0.9];
design.targetDur        = 5; % target duration in frames

design.rangeAccept = 2;
design.rangeCalib  = 1;

% speed variables, in dva/s
design.travelxDist = abs(design.attackerxPos)+abs(design.targetxPos);
design.travelFrames = design.travelxDist * scr.refRate;

% overall information %
% number of blocks and trials in the first round
design.nBlocks = 5;
design.nTrials = 5; 

% build
for b = 1:design.nBlocks
    t = 0;
    for triali = 1:design.nTrials
        for goal = design.goalyPos
            for yDist = design.yDist
                t = t+1;
                % define goal position
                trial(t).goalPos = goal;
                % define yDist
                % instead of a distance, this becomes the starting point
                trial(t).yPosAttacker = getytar(goal, yDist, design.goalHeight);
                %trial(t).yDist = getytar(goal, yDist, design.goalHeight);
                % define target positions
                trial(t).posSet = drawposset(goal,design.targetyPos_range,60);
                % define fixation duration
                trial(t).fixT    = design.fixDur + rand(1)*design.fixDurJ;
                % define the trajectory
                trial(t).trajectory = yDist;
            end
        end
    end
    % randomize
    r = randperm(t);
    design.b(b).trial = trial(r);
end

blockOrder = [1:b];

design.blockOrder = blockOrder(randperm(length(blockOrder)));
design.nTrialsPB  = t;

% save 
save(sprintf('./Design/%s.mat',vpcode),'design');

end

