%% Dependencies 
addpath C:\Users\ortizo\Documents\MATLAB\eeglab2021.1 % change the path depending on where your eeglab dependencies are
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

cd Z:\30_Oscar_Ortiz\tutorials\full_gamma_extraction_example\scripts % path to your main folder
addpath Z:\30_Oscar_Ortiz\tutorials\full_gamma_extraction_example\scripts % where the scripts and funcitons are


%% Do yourpre processing and epoching in brainvision and then export as a matrix.

%% Step 1 - Converting your BV output to .set files 

% select the folder where you have the output of brainvision and where you
% want your data to save

inputFolder =  'Z:\30_Oscar_Ortiz\tutorials\full_gamma_extraction_example\0_BV_output_data\'; % your Brain vision Export directory 
outputFolder = 'Z:\30_Oscar_Ortiz\tutorials\full_gamma_extraction_example\1_set_data\'; % where you want your .set files

d = dir([inputFolder '\*.mat']); 

% loop through the file directory, open and save files as .set

for k=1:length(d)
    % get filename and make loadname
    info=d(k);
    fname=info.name;
    loadname=horzcat(inputFolder,fname);
    fname=fname(1:end-4);
    
    % load EEG data
    EEG = pop_loadbva(loadname); % use pop_loadbva to import brainvision export into EEGlab
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',fname,'gui','off'); % load file, using the filename as setname, gui off
    EEG = eeg_checkset( EEG );
    % save EEG data
    EEG = pop_saveset( EEG, 'filename',fname,'filepath',outputFolder); % Save the EEG data 
    % clear dataset
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[]; % clear all datasets
    
    clear info fname loadname  % clear temporary variables in loop. 
end



%% tf extraction per .set file
pathname = 'Z:\30_Oscar_Ortiz\tutorials\full_gamma_extraction_example\1_set_data\'; 
output_path = 'Z:\30_Oscar_Ortiz\tutorials\full_gamma_extraction_example\2_time_frequency_data\';
%files_not_processed = gamma_detection(pathname);
epoch_length = [-500 1000];
freqs_in = [1 100];
baseline_in = [-450 -50];
n_times_out = [];
pads = 4 ;% can be 2^n 
win_size = 150;
NF = [];
c_lims = [-4 4];

files_not_processed  = gamma_detection_hannah(pathname,output_path,epoch_length,freqs_in,baseline_in,n_times_out,pads,win_size,NF,c_lims);



%% Grouping data by condition 
my_chans_in = {'c3','cz','c4','fz','pz'}; % list of the channels for analysis 
my_extension = '*tf_extracted_V2.set'; % extension of the file names to be grouped
pathname = 'Z:\30_Oscar_Ortiz\tutorials\full_gamma_extraction_example\2_time_frequency_data';
cond_1 = grouping_data_specify_chans(pathname,my_extension,my_chans_in); % this data should be saved 


%% Plotting and visualizing


% Figure Cc - All conditions
my_clims = [-2 2];
x = cond_1.times;
y = cond_1.my_frex;
my_ylims = [1 100];
figure 
hold on
data_index = 2; % Change for the channel you want to see based on line 62
data2plot = squeeze(cond_1.tf_mean(data_index,:,:));
contourf(x,y,data2plot,40,'linecolor','none');
title(cond_1.chan_names_stored(data_index));
caxis(my_clims);
ylim(my_ylims);
hcb=cbar;
colorTitleHandle = get(hcb,'Title');
titleString = '% change';
set(colorTitleHandle ,'String',titleString);






