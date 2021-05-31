% prepare stimuli for presentation

function prepStim
  global design scr visual

  
  % define stimulus properties as visuals
  % parameters for stimuli in pix
  % parameters that differ on a trial-by-trial basis are set on each trial 
  % Fixation
%  visual.fixRad = design.fixRad * visual.ppd;
%  visual.fixPos = design.fixPos * visual.ppd + [visual.xCenter, visual.yCenter];

  % Attacker
  visual.attackerRad = design.attackerRad * visual.ppd;
  visual.attackerxPos = design.attackerxPos * visual.ppd;
  visual.attackeryPos = design.attackeryPos * visual.ppd;
  visual.attackerPos  = [visual.xCenter, visual.yCenter] + [visual.attackerxPos, visual.attackeryPos];
  
  visual.travelxDist = design.travelxDist * visual.ppd; 
  visual.travelFlips = design.travelDur * scr.hz; 
  visual.xSpeed  = visual.travelxDist/visual.travelFlips;
  visual.attackerVisible = design.travelDur * design.attackerVisible;
  visual.targetDur = round(visual.travelFlips/design.nTar);
    
  % Goal
  visual.goalHeight = design.goalHeight * visual.ppd;
  visual.goalxPos   = design.goalxPos * visual.ppd + visual.xCenter;
  visual.exampleGoal= design.exampleGoal * visual.ppd + [visual.xCenter, visual.yCenter, visual.xCenter, visual.yCenter];
    
  % Target
  visual.targetRad = design.targetRad * visual.ppd;
  visual.targetxPos = design.targetxPos * visual.ppd + visual.xCenter; 
    
  % area in which a response is accepted
  visual.rangeAccept = design.rangeAccept * visual.ppd; 
  visual.rangeCalib = design.rangeCalib * visual.ppd; 

  % color definitions
  visual.goalColor = visual.white * [0, 0.2, 0.8];
  visual.textColor   = visual.white; 
  visual.attackerColor = visual.white;
  visual.targetColor = visual.white;
  visual.fixColor = visual.white;
  
end
