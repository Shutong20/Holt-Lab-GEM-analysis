function result_diffusion(dt,conv) % dt is your time step so if you are taking a 10ms 

% get the number of different conditions
prompt = {'How many conditions would you like to process?'};
title = '# Conditions';
definput = {'1'};
opts.Interpreter = 'tex';
answer = inputdlg(prompt,title,[1 40],definput,opts);
num_conditions = str2num(answer{1});

disp(num_conditions)

for i = 1:num_conditions
    [filename,path] = uigetfile('multiselect','on','.csv','Select the file to convert');
    filenames_all_conditions(i) = {filename};
    cd(path)
end
clear filename



for iterator = 1:num_conditions
    filenames_this_condition = filenames_all_conditions{iterator};
    %disp(iterator)
    %[filename,path] = uigetfile('multiselect','on','.csv','Select the file to convert');
   
    % To access treatment groups from cell array - set to length of array
    %am using this to tell results_tracking which files to load in the loop

%% Trasform .txt files in intermediate .mat files
results_tracking_V4(dt,conv, filenames_this_condition);



for m = 1:length(filenames_this_condition)
    filename_tracked{m} = ['tracked_',filenames_this_condition{m}];    
end

filename_tracked_mat = regexprep(filename_tracked,'.csv','.mat');
disp(filename_tracked_mat)


for m = 1:length(filenames_this_condition)
    filename_analyzed{m} = ['analyzed_',filename_tracked_mat{m}];
    disp(filename_analyzed{m})
end
 
%% Do all the fitting of the intermediate .mat files
fit_lin_gyration_V3(dt,conv,0.2,11,filename_tracked_mat);

%% Pooling similar data together
saved = pool_data_fit_lin_corr_V3(filename_analyzed);
clear('filename', 'filename_analyzed','filename_tracked','filename_tracked_mat','filenames_this_condition')
%% Plot the one result
%plot_results_in(0,dt,saved)
end
















end