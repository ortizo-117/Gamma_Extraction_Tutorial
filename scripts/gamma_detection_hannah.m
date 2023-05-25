
function files_not_processed  = gamma_detection_hannah(pathname,output_path,epoch_length,freqs_in,baseline_in,n_times_out,pads,win_size,NF,c_lims)
%Author: Cassie Choles
%Date: Oct 29/21 
%Description: This function is to plot gamma activity
%The input of this function is the directory where the .set files are,
%that have already been decomposed by ICA.
fnp_i = 1;
problem_v = [];
file_struct_list = dir([pathname filesep() '*.set']);  %% get list of .set files in the pathname specified

 filename_cell_list = {file_struct_list.name};  %% extract the filenames into a cellarray

 filename_list=deblank(char(filename_cell_list));

 endout=regexp(pathname,filesep,'split');
 saving_name = [char(endout(end-1)) '_' char(endout(end))];

 length_filename=size(filename_list);
 
 [ALLEEG EEG CURRENTSET ALLCOM] = eeglab  
 
 
  for k = 1:length_filename(1)
     %% load file
     filename=deblank(filename_list(k, :));   
     [~,filename_text,~]= fileparts(strcat(pathname,'\',filename));   
%      EEG.etc.eeglabvers = '14.1.1'; % this tracks which version of EEGLAB is being used, you may ignore it
     EEG = pop_loadset('filename',filename,'filepath',pathname); %loads the specified file into eeglab
     
 
     
     %%  extracting tf for each channel
     num_chan=EEG.nbchan; % get number of channels
     for i = 1:num_chan
         if i ==1
             try
                 fh1 = figure;
%                  n_times_out = 1000;
%                  pads = 4 ;% can be 2^n 
%                  win_size = 150;
%                  NF = [];
%                  c_lims = [-4 4];
%                  epoch_length = [-500 999]
%                  freqs_in = [1 100]
%                  baseline_in = [-400 0]
                 [ersp, ~, ~, times, frequencies, erspboot, ~, ~] = pop_newtimef( EEG, 1, i,epoch_length, [0] , 'topovec', i, 'elocs', EEG.chanlocs, 'chaninfo', ...
                 EEG.chaninfo, 'caption', char(EEG.chanlocs(i).labels), ...
                 'baseline',baseline_in,'freqs',freqs_in, 'plotphase', 'on', ...
                 'ntimesout', n_times_out, 'padratio', pads,'winsize', win_size,'nfreqs', NF,...
                 'erspmax', c_lims);
                 m_sizes = size(ersp);
                 out_mat = zeros(num_chan,m_sizes(1),m_sizes(2));
                 out_mat(i,:,:) = ersp;
                 pause(1)
                 close(fh1)
             catch
                  disp(['Problem with channel '  char(EEG.chanlocs(i).labels) '. Potentially all zeros. This is the first channel. Pressing on...'])
                  problem_v = [problem_v , i];
                  fprintf([filename 'not processed. Please check file']);
                  if fnp_i == 1
                         files_not_processed = {string(filename)};
                         fnp_i = fnp_i+1;
                  else
                        files_not_processed =vertcat(files_not_processed,{string(filename)});
                        fnp_i = fnp_i+1;
                  end
             end
         else
             try
                 fh1 = figure;
                 [ersp, ~, ~, times, frequencies, erspboot, ~, ~] = pop_newtimef( EEG, 1, i,epoch_length, [0] , 'topovec', i, 'elocs', EEG.chanlocs, 'chaninfo', ...
                 EEG.chaninfo, 'caption', char(EEG.chanlocs(i).labels), ...
                 'baseline',baseline_in,'freqs',freqs_in, 'plotphase', 'on', ...
                 'ntimesout', n_times_out, 'padratio', pads,'winsize', win_size,'nfreqs', NF,...
                 'erspmax', c_lims);
                 out_mat(i,:,:) = ersp;
                 pause(1)
                 close(fh1)
             catch
                  disp(['Problem with channel '  char(EEG.chanlocs(i).labels) '. Potentially all zeros. Pressing on...'])
                  problem_v = [problem_v , i];
                   if fnp_i == 1
                          files_not_processed = {string(filename)};
                         fnp_i = fnp_i+1;
                  else
                        files_not_processed =vertcat(files_not_processed,{string(filename)});
                        fnp_i = fnp_i+1;
                  end
             end
         end  
     end
     
     %% put it into EEG structure 
     
     EEG.tf_data = out_mat;
     EEG.tf_frex = frequencies;
     EEG.tf_time = times;
     EEG.chans_with_problems = problem_v;
     
     
     %% Save file
     saving_name = [filename_text '_tf_extracted_V2'];
     EEG = pop_saveset( EEG, 'filename',saving_name,'filepath', output_path);
     EEG = eeg_checkset( EEG );
     [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
     eeglab redraw;
     fprintf('\n\n\n %i percent processing folder \n\n\n',k/length_filename(1)*100); 
         fprintf([filename 'not processed. Please check file']);
         if fnp_i == 1
             files_not_processed = string(filename);
             fnp_i = fnp_i+1;
         else
             files_not_processed =vertcat(files_not_processed,string(filename));
             fnp_i = fnp_i+1;
         end
  end  
         
  end
  