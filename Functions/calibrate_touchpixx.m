function calibrate_touchpixx(reps)
  
  if nargin < 1
    reps = 3;
  end
  %% Calibration with validation
  % set the points, get a calibration on the same screen, ask if calibration was accepted or not  
  %% Calibration as in VPixx Demo 17
  % Put up first touch calibration target near top-left corner, and acquire TOUCHPixx coordinates
  global visual
  
  % define locations for touch targets
  % upper left
  calDispX1 = 100;
  calDispY1 = 100;
  % lower right 
  calDispX2 = visual.winWidth - 100;
  calDispY2 = visual.winHeight - 100;
  
  % settings for text display 
  Screen('TextFont',visual.window, 'Courier New');
  Screen('TextSize',visual.window, floor(50 * visual.winWidth/1920));
  
  % color of calibration targets like color of stimuli
  calCol  = visual.white;
  textCol = visual.white;
  
  DrawFormattedText(visual.window, 'Calibration: Touch center of first calibration square', 'center', 'center', textCol);
  Screen('Flip', visual.window);
  WaitSecs(1);
  
  calibration_done = false;
  
  while ~calibration_done  
    for rep = 1:reps
      
      Screen('FillRect', visual.window, calCol, [calDispX1-visual.rangeCalib calDispY1-visual.rangeCalib calDispX1+visual.rangeCalib calDispY1+visual.rangeCalib]);
      Screen('Flip', visual.window);
      touchPt = [0 0];                        % Wait for press
      
      while touchPt == [0 0]
          Datapixx('RegWrRd');
          touchPt = Datapixx('GetTouchpixxCoordinates');
      end;
      calTouch.leftup.X(rep) = touchPt(1);
      calTouch.leftup.Y(rep) = touchPt(2);
      Screen('Flip', visual.window);

      isPressed = 1;        % Wait until panel release
      
      while isPressed
          Datapixx('RegWrRd');
          status =  Datapixx('GetTouchpixxStatus');
          isPressed = status.isPressed;
      end;

      % Do same for a second calibration target near bottom-right corner of display
      
      Screen('FillRect', visual.window, calCol, [calDispX2-visual.rangeCalib calDispY2-visual.rangeCalib calDispX2+visual.rangeCalib calDispY2+visual.rangeCalib]);
      Screen('Flip', visual.window);
      touchPt = [0 0];         % Wait for press
      
      while touchPt == [0 0]
          Datapixx('RegWrRd');
          touchPt = Datapixx('GetTouchpixxCoordinates');
      end;
      
      calTouch.lowright.X(rep) = touchPt(1);
      calTouch.lowright.Y(rep) = touchPt(2);
      Screen('Flip', visual.window);
      isPressed = 1;                          % Wait until panel release
      
      while isPressed
          Datapixx('RegWrRd');
          status =  Datapixx('GetTouchpixxStatus');
          isPressed = status.isPressed;
      end;
    end
    if std(calTouch.lowright.X) < visual.rangeCalib/100 &&...
      std(calTouch.lowright.Y) < visual.rangeCalib/100 &&...
     std(calTouch.leftup.X) < visual.rangeCalib/100 && ...
     std(calTouch.leftup.Y) < visual.rangeCalib/100
     calibration_done = true;
     
     DrawFormattedText(visual.window, 'Calibration successful', textCol);
     Screen('Flip', visual.window);
     WaitSecs(1)
  
     
     calTouchX1 = mean(calTouch.leftup.X);
     calTouchY1 = mean(calTouch.leftup.Y);
     calTouchX2 = mean(calTouch.lowright.X);
     calTouchY2 = mean(calTouch.lowright.Y);
    else
     DrawFormattedText(visual.window, 'Calibration failed, will repeat', textCol);
     Screen('Flip', visual.window);
     WaitSecs(1)

    end 
  end
  % Calculate linear mapping between touch coordinates and display coordinates
  visual.mx = (calDispX2 - calDispX1) / (calTouchX2 - calTouchX1);
  visual.my = (calDispY2 - calDispY1) / (calTouchY2 - calTouchY1);
  visual.bx = (calTouchX1 * calDispX2 - calTouchX2 * calDispX1) / (calTouchX1 - calTouchX2);
  visual.by = (calTouchY1 * calDispY2 - calTouchY2 * calDispY1) / (calTouchY1 - calTouchY2);
end
