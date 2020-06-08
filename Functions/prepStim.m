% prepare stimuli for presentation

function prepStim
  global design scr visual
  
  % define stimulus properties as visuals
  % parameters for stimuli in pix
  visual.ballStart   = design.ballStart * visual.ppd; % shift of moving stim from centre, negative values above screen center
  visual.tarPosY     = design.tarPosY * visual.ppd;   % how much are the non-targets moved sideways
  visual.tarPosX     = design.tarPosX * visual.ppd;   % how much is the distractor moved down 
  visual.stimSize    = design.stimSize * visual.ppd;
  
  visual.keeperY     = design.keeperY * visual.ppd;
  visual.keeperSize  = (design.keeperSize * visual.ppd) / 2; % divided by two, because 1/2 of the size is on each side of the position

  % position in [x,y] coding 
  % ball
  visual.ballPos   = [visual.xCenter, visual.yCenter] + [0, visual.ballStart];
  visual.ballSize  = visual.stimSize;

  % position in [x,y] for targets
  visual.goalPos1  = [visual.xCenter, visual.yCenter] + [-visual.tarPosX,visual.tarPosY]; 
  visual.goalPos2  = [visual.xCenter, visual.yCenter] + [visual.tarPosX,visual.tarPosY]; 
  visual.goals     = [visual.goalPos1;visual.goalPos2];
  visual.goalSize  = visual.stimSize;
  visual.rangeAccept = design.rangeAccept * visual.ppd;
  visual.rangeCalib  = design.rangeCalib * visual.ppd;
  
  % position in [x,y] for keeper
  keeperPos           = [0, visual.keeperY];
  visual.keeperPos    = [visual.xCenter, visual.yCenter] + keeperPos;

  % color definitions
  visual.ballColor = visual.white;
  visual.goalColor = visual.white;
  visual.keeperColor = visual.white;
  visual.textColor   = visual.white; 
  
  % speed conversion from dva/sec to pix/flip
  
  visual.speed  = (design.speed*visual.ppd)/scr.hz;
  
end
