function genDesign(vpcode)
%
% 2017 by Martin Rolfs
% 2019 mod by Clara Kuper

global design settings scr

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
design.fixDur    = 0.5; % Fixation duration till trial starts [s]
design.fixDurJ   = 0.5; % Additional jitter to fixation

design.iti       = 0.2; % Inter stimulus interval

% conditions
design.nGoalPos   = 10
design.nySpeed    = 8  % 8 different possible trajectories

% position and size variables, in dva     
% Fixation
design.fixWidth = 1;
design.fixHeight = 1;
design.fixCol = [1,1,1];
design.fixPos = (20,0);

% Attacker
design.attackerRad = 0.5;
design.attackerCol = 'black';
design.attackerxPos= -20;
design.attackeryPos= 0;
design.travelDur   = 0.5; # time in sec
design.ySpeed      = linspace(1,design.nySpeed,design.nySpeed);
design.xSpeed      = 0;  #initialize only, change later
design.attackerVisible =  1;


% Goal
design.goalHeight = 3;
design.goalCol    = [0, 0.2, 0.8];
design.goalxPos   = 10;
design.goalyPos   = linspace(-4, 4, design.nGoalPos);

% Target

design.targetrad        = 0.5;
design.targetcol        = [1, 1, 1];
design.targetxPos       = 0;
design.targetyPos_range = [design.goalHeight*0.9, design.goalHeight*0.9];
design.targetDur        = 3; # target duration in frames

design.rangeAccept = 2;
design.rangeCalib  = 1;

% speed variables, in dva/s
design.xSpeed = (abs(design.attackerxPos)+abs(design.targetxPos))/design.travelDur;  % dva/s how much does the ball move in one second?
design.travelFrames = design.travelDur * scr.refRate

% overall information %
% number of blocks and trials in the first round
if settings.TEST == 0
    design.nBlocks = 1;
    design.nTrials = 10;
else
    design.nBlocks = 5;
    design.nTrials = settings.TRIALS;
end

if settings.TEST
    if settings.CODE
        load(sprintf('./Data/%s_timParams.mat',settings.testCode)); % load a matfile with subject name and code
    else
        load(sprintf('./Data/%s_timParams.mat',design.vpcode)); % load a matfile with subject name and code
    end
    design.alResT    = tim.rea + 2*tim.rea_sd;      % Allowed response time
    design.alMovT    = tim.mov + 2*tim.mov_sd;      % Allowed movement time
    design.jumpTim   = design.alResT;               % random time after which target jumps, maximum is the allowed response time 
    if settings.BLOCK
        blockBy    = design.alResT/design.nBlocks;
        jumpBlocks = [0:blockBy:design.alResT];
    end
else
    design.jumpTim   = 0.1;
    design.alResT    = 1.0;      % Allowed response time
    design.alMovT    = 1.0;      % Allowed movement time
end
    

% build
for b = 1:design.nBlocks
    t = 0;
    for triali = 1:design.nTrials
        for goal = design.goalyPos
          for ySpeed = design.ySpeed
            t = t+1;
            % define goal position
            trial(t).goalPos = goal;
            % define ySpeed
            trial(t).ySpeed = drawlaunchspeed(goal, ySpeed, design.goalHeight, design.travelFrames);
            % define target positions
            trial(t).posSet = posSet;
            % define fixation duration
            trial(t).fixT    = design.fixDur + rand(1)*design.fixDurJ;
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

