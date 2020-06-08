clear all;
# define data folder and design folder
data_path   = '../Data/';
design_path = '../Design/';
# for octave only:
octave_data = [];
log_data    = [];

# create empty vectors for data table
# GENERAL INFO: participant; session; block; trial (saved already)
# DESIGN DATA:
parts    = [];
sessions = [];
blocks   = [];
trials   = [];
IDs      = []; 
ok_rea   = [];
effector = {};
l = 1;
goal_pos = [];
jump_tim = []; 
jump_pos = [];
fix_tim  = [];
#xPos_tar
#yPos_tar
#xPos_start
#yPos_start
# ONLINE DATA:
res_pos    = [];
t_draw     = [];
t_touched  = [];
t_go       = [];
t_movStart = [];
t_jump     = [];
t_movEnd   = [];
t_goal     = [];
t_end      = [];
# OFFLINE DATA
# CALCULATED DATA
rea_t         = [];
gap_t         = [];
proc_t        = [];
correct       = [];

# collect all files in data folder
# go to data folder
cd(data_path);
data_struct   = dir('*CMP_Hand.dat');
# for each file in list (session)
part_list     = [];

#fid = fopen('logFiles.txt', 'w');

part_number = 1;
old_part    = 'nothing';

for k = 1:length(data_struct)
  
  dat_file    = data_struct(k).name;
  
  # grab participant ID and session from name
  participant = dat_file(1:2);
  if !strcmp(participant, old_part)
    part_number = part_number + 1;
  end
  
  old_part    = participant;  
  session     = str2num(dat_file(3:4));
  log_file    = sprintf('%sLog.dat',dat_file(1:end-4));
  
  
  # load data file
  # go to data directory
  cd(data_path);
  load(dat_file);
  load(log_file);
  
  # try load processed log file. if not found:
  # load matched log file
  #try 
  #  load(sprintf('%sLogProc.dat',dat_file(1:end-4)));
  #catch
  #  load(sprintf('%sLog.dat',dat_file(1:end-4)));
    # run the offline detection
    # process log file (write seperate function)
    # deal with messages in log data
  #end   
  # load matched design file
  # go to design folder
  cd(design_path);
  load(sprintf('%s_design.mat',dat_file(1:end-4)));
  
  ok_resT = design.alResT;

  # for each block in file
  for b = 1:length(data.block)
    # asign block data, log data and block design
    b_data = data.block(b);
    b_log  = dataLog.block(b);
    b_des  = design.b(b);
    # for each trial in block 
    for t = 1:length(b_data.trial)
      # data from timing file first
      t_data = b_data.trial(t);
      t_log  = b_log.trial(t);
      t_des  = b_des.trial(t);
      
      if ! isnan(t_data.resPos)
        if t_data.t_movStart - t_data.t_go > 0.1
          # GENERAL INFO: participant; session; block; trial (saved already)
          # DESIGN DATA: 
          parts    = [parts, participant];
          sessions = [sessions, session];
          blocks   = [blocks, b];
          trials   = [trials, t];
          effector(l) = 'H' ;
          l = l+1;
          goal_pos = [goal_pos, t_des.goalPos];
          jump_tim = [jump_tim, t_des.jumpTim]; 
          jump_pos = [jump_pos, t_des.jumpPos];
          fix_tim  = [fix_tim, t_des.fixT];
          ok_rea   = [ok_rea, ok_resT];
          #xPos_tar
          #yPos_tar
          #xPos_start
          #yPos_start
          des_dat = sprintf('%s\t%i\t%i\t%i\t%s\t%i\t%i\t%i\t%i\t%i\t', participant, session, b, t, 'H', t_des.goalPos, t_des.jumpTim, t_des.jumpPos, t_des.fixT, ok_resT);
          # ONLINE DATA:
          res_pos    = [res_pos, t_data.resPos];
          t_draw     = [t_draw, t_data.t_draw];
          t_touched  = [t_touched, t_data.t_touched];
          t_go       = [t_go, t_data.t_go];
          t_movStart = [t_movStart, t_data.t_movStart];
          t_jump     = [t_jump, t_data.t_jump];
          t_movEnd   = [t_movEnd, t_data.t_movEnd];
          t_goal     = [t_goal, t_data.t_goal];
          t_end      = [t_end, t_data.t_end];
          online_dat = sprintf('%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\t', t_data.resPos, t_data.t_draw, t_data.t_touched, t_data.t_go, t_data.t_movStart, t_data.t_jump, t_data.t_movEnd, t_data.t_goal,t_data.t_end);
          # offline data: (check for algorythmic solutions) should include: xPos_res, yPos_res, xt_draw, xt_touched, xt_go, xt_movStart, xt_jump, xt_movEnd, xt_goal, xt_end
          # CALCULATED DATA
          rea_t         = [rea_t, t_data.t_movStart - t_data.t_go];
          gap_t         = [gap_t, t_data.t_jump - t_data.t_go];
          proc_t        = [proc_t, t_data.t_jump - t_data.t_movEnd];
          correct       = [correct, t_des.goalPos == t_data.resPos];
          calc_dat      = sprintf('%i\t%i\t%i\t%i', t_data.t_movStart - t_data.t_go, t_data.t_jump - t_data.t_go,t_data.t_movEnd - t_data.t_jump,t_des.goalPos == t_data.resPos);
          octave_data   = [octave_data; des_dat,online_dat,calc_dat];
          
          # Data from log file second
          touches       = dataLog.block(b).trial(t).touches';
          timetag       = dataLog.block(b).trial(t).timetag';
          reps          = length(timetag);
          long_trial    = repmat(t,reps,1);
          long_block    = repmat(b,reps,1);
          long_part     = repmat(part_number,reps,1);
          long_session  = repmat(session,reps,1);
          
          #preprint      = sprintf('%s%i%s,%s%i%s,%s%i%s,%s%i%s,%s%i%s,%s%i%s','%',reps,'i','%',reps,'i','%',reps,'i','%',reps,'i','%',reps,'i','%',reps,'i');
          #fprintf(fid, preprint,long_part,long_session,long_block,long_trial,timetag,touches);
          log_data      = [log_data;long_session,long_block,long_trial,timetag,touches,long_part];
        end
  
      end
    end  
  end  
end

cd(data_path);
save('offData.txt', 'octave_data') 
save('logData.txt','log_data')
#fclose(fid);
#all_dat       = table(effector,goal_pos,jump_tim,jump_pos,fix_tim,res_pos,t_draw,t_touched,t_go,t_movStart,t_jump,t_movEnd,t_goal,t_end,rea_t,gap_t,proc_t,correct)   ;#[all_dat; des_dat online_dat calc_dat];