function struct_out = grouping_data_specify_chans(pathname,extension_to_look_for,my_chans_in)

% Groups all gamma data in the folder in one condition
%my_chans_in = {'c3','cz','c4','fz','pz'};


 my_chans_in = lower(my_chans_in);

 n_chans_out = length(my_chans_in);
 
 file_struct_list = dir([pathname filesep() extension_to_look_for]);  %% get list of .set files in the pathname specified
 filename_cell_list = {file_struct_list.name};  %% extract the filenames into a cellarray
 filename_list=deblank(char(filename_cell_list));
 %endout=regexp(pathname,filesep,'split');
 length_filename=size(filename_list);
 
 
 [ALLEEG EEG CURRENTSET ALLCOM] = eeglab ; 
 
 for k = 1:length_filename(1)
     filename=deblank(filename_list(k, :));   
     [~,filename_text,~]= fileparts(strcat(pathname,'\',filename));   
     EEG = pop_loadset('filename',filename,'filepath',pathname); %loads the specified file into eeglab
     
     my_chanlocs = EEG.chanlocs;
     chan_idx_vector = zeros(1,n_chans_out);
     for m = 1:n_chans_out
        for i = 1:length(my_chanlocs)
            c_chan = string(lower(my_chanlocs(i).labels));
            if any(strcmp(my_chans_in(m),c_chan))
                chan_idx_vector(m) = i;
            end  
         end
     end
     chan_idx_vector_2 = chan_idx_vector([3 2 1 4 5]); % switching the c3 and c4 electrode for one par

     
     
     % on the first iteration, create output mat with appropriate dimensions
     if k == 1
         output_gamma_dims = size(EEG.tf_data);
         gamma_output = zeros(length_filename(1),n_chans_out,output_gamma_dims(2),output_gamma_dims(3));         
     end
    
     gamma_output(k,:,:,:) =  EEG.tf_data(chan_idx_vector,:,:); 
 end
 
 struct_out.tf_data = gamma_output;
 struct_out.tf_mean = squeeze(mean(gamma_output));
 struct_out.times = EEG.tf_time;
 struct_out.my_frex = EEG.tf_frex;
 struct_out.filenamelist = filename_list;
 struct_out.chanlocs = EEG.chanlocs;
 struct_out.chan_names_stored = my_chans_in;
     
 end
