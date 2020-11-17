% Experiment with TouchScreen
% 2020 by Clara Kuper
% check timing

% System setup
% Clear the workspace and the screen
sca;
clear all;
clear mex;
clear functions;
% cursor goes home, command window scrolled up
home;

% Which experiment are we running?
expCode = 'NS';
sprintf('Now running experiment %s',expCode);

% add the functions folder to searchpath and define storage paths
addpath('Functions/','Data/', 'edf/');

% Unify keys in case sb codes with a different system
KbName('UnifyKeyNames');

% Here we call some default settings for setting up Psychtoolbox

PsychDefaultSetup(2);

% Init random
rand('seed', sum(100 * clock));

%start a timer for the experiment
tic;

% define some settings for the experiment
global settings visual design

settings.TEST   = 1; % Track or no Track
settings.SYNCTEST = 1; % run synchtest or not
settings.eye_used = str2double(input('\nWhich eye do we track (0 = left, 1 = right):  ','s'));
 
%% start the experiment loop, errors in this loop will be caught
try
    % get participant ID:
    [datFile, subCode, subPath] = getSubjectCode(expCode);
    
    % prepare the screens    
    setScreens;
                                                                                
    % generate design 
    genDesign(subCode);
    
    % prepare the stimuli
    prepStim;

    % Add experiment Info after OpenWindow so it's under the text generated by Screen
    fprintf('\nNoiseStrike\n');
    HideCursor;
    
    % Configure DATAPixx/TOUCHPixx
    Datapixx('SetVideoMode', 0);                        % Normal passthrough
    Datapixx('EnableTouchpixx');                        % Turn on TOUCHPixx hardware driver
    Datapixx('SetTouchpixxStabilizeDuration', 0.01);    % stable coordinates in secs before recognising touch
    Datapixx('RegWrRd');

    calibrate_touchpixx();
    
    % initialize EyeLink
    [el, error] = initEyelink(subCode);
    
    % first calibration
    eye_available = Eyelink('EyeAvailable'); % get eye that's tracked
    
    if ~ settings.eye_used == eye_available
        disp('The eye set for tracking does not match the tracked eye.')
        WaitSecs(3);
        ListenChar(1);
        Eyelink('Shutdown');

        ShowCursor;
        Screen('CloseAll')
        expEnd = toc;

        sprintf('This experiment lasted %i minutes', round(expEnd/60,1));
    end
    
    disp([num2str(GetSecs) ' Eyelink initialized.']);
    
    %% run the setup block
    % calibrate
    calibresult = EyelinkDoTrackerSetup(el);
    
    % Display Instructions:
    ListenChar(0);
    Eyelink('Message', 'EXPERIMENT STARTED');
    DrawFormattedText(visual.window, 'Block the goal when the attacker hits', 'center', 200, visual.textColor);
    DrawFormattedText(visual.window, 'Press any key to start', 'center', 'center', visual.textColor);
    Screen('Flip',visual.window);
    KbPressWait;
    
    % run the first block to adjust difficulty
    b_i = 1;
    b = 1;
  
    %% run normal blocks
    
    for b = design.blockOrder
        
        data.block(b) = runBlock(b, b_i, el);
        b_i = b_i+1;
        
    end   
    
    Eyelink('Message', 'EXPERIMENT ENDED');
    DrawFormattedText(visual.window, 'Thanks for your participation', 'center', 'center', visual.textColor);
    Screen('Flip',visual.window);
    
catch me
    rethrow(me);
    reddUp; %#ok<UNRCH>
end
    
% save all the data
data_table = data2output(data);
writetable(data_table, sprintf('./Data/%s_dat.csv',design.vpcode));
save(datFile,'data');

% save the design
design_table = design2output(design);
writetable(design_table, sprintf('./Design/%s_des.csv',design.vpcode));
save(sprintf('./Design/%s_design.mat',design.vpcode),'design'); %

Datapixx('DisableTouchpixx');
Datapixx('Close'); %call the close command after closing the screens

Eyelink('CloseFile');
% download data file
WaitSecs(2);
try
    fprintf('Receiving data file ''%s''\n', settings.edffilename);
    status=Eyelink('ReceiveFile',settings.edffilename, 'edf/', 1);
    WaitSecs(2)
    if status > 0
        fprintf('ReceiveFile status %d\n', status);
    end
    if 2==exist(settings.edffilename, 'file')
        fprintf('Data file ''%s'' can be found in ''%s''\n', settings.edffilename, pwd );
        [sucMov,mesMov,messMov] = movefile(settings.edffilename,'edf/','f');

        if ~sucMov
            fprintf('File successfully moved into edf folder.\n');
        end
    end
catch rdf
    fprintf('Problem receiving data file ''%s''\n', settings.edffilename);
    rdf;
end

WaitSecs(1);
ListenChar(1);
Eyelink('Shutdown');

ShowCursor;
expEnd = toc;

fprintf('This experiment lasted %i minutes', round(expEnd/60,0));
sca;
Screen('CloseAll');
