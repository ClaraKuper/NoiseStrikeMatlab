no_start = 0
no_end   = 0
include_clean = false;
for b = 1:length(dataLog.block)
  for t = 1:length(dataLog.block(b).trial)
    trial = dataLog.block(b).trial(t);
    if data.block(b).trial(t).success
      t_start   = min(trial.timetag);
      time      = [trial.timetag-t_start];
      touchX    = [trial.touches(1,:)];
      touchY    = [trial.touches(2,:)];
      for idx = 1 : length(touchX)
        if touchX(idx) == 0 && include_clean
          id_low   = max([0, idx-1]);
          id_high  = min([length(touchX),idx+1]);
          repl_val = mean([touchX(id_low),touchX(id_high)]);
          touchX(idx) = repl_val;
        end
        if touchY(idx) == 0 && include_clean
          id_low   = max([0, idx-1]);
          id_high  = min([length(touchX),idx+1]);
          repl_val = mean([touchY(id_low),touchY(id_high)]);
          touchY(idx) = repl_val;
        end
      end
      %t_draw    = data.block(b).trial(t).t_draw - t_start;
      t_touched = data.block(b).trial(t).t_touched - t_start;
      t_go      = data.block(b).trial(t).t_go - t_start;
      t_movStart= data.block(b).trial(t).t_movStart - t_start;
      t_jump    = data.block(b).trial(t).t_jump - t_start;
      t_movEnd  = data.block(b).trial(t).t_movEnd - t_start;
      t_goal    = data.block(b).trial(t).t_goal - t_start;
      t_end     = data.block(b).trial(t).t_end - t_start;
      plot(time,[touchX; touchY]);
      hold on;
      %line([t_draw, t_draw],[0,1],'Color','red');
      line([t_touched, t_touched],[0,1],'Color','black');
      line([t_go, t_go],[0,1],'Color','yellow');
      line([t_movStart, t_movStart],[0,1],'Color','red');
      line([t_jump, t_jump],[0,1],'Color','blue');
      if ~ isnan(t_movEnd)
        line([t_movEnd,t_movEnd],[0,1],'Color','green');
      else
        no_end += 1;
      end
      line([t_goal,t_goal],[0,1],'Color','blue');
      line([t_end, t_end],[0,1],'Color','black');
      pause(1);
      hold off;
    end
  end

end