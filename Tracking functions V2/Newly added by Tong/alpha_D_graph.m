function [Total_traj_length, Total_D_inst, Total_alpha] = alpha_D_graph(dt)
% Plot alpha value vs effective diffusion constants (time averaging) of 
% each single particle trajectory for characterizing probe particle properties. 
% Based on the reference: "Non-specific interactions govern cytosolic 
% diffusion of nanosized objects in mammalian cells.

%Navigate to a directory with tracked_*.mat results files, which is the
%direct extract without linear fitting from trajectory csv files

disp('Select tracked*.mat files for plotting alpha-D graph')
[filename,path] = uigetfile('multiselect','on','tracked*.mat','Select the tracked files to convert');
 cd(path)

Total_traj_length = [];
Total_D_inst = [];
Total_alpha = [];

f_power = fittype('b*x^a','dependent',{'y'},'independent',{'x'},'coefficients',{'a','b'});
L_cutoff = 10; % Cutoff length for trajectory, only consider trajectories (MSD) with length>=L_cutoff+1, default value is 9;
Fit_cutoff = 10; % Fitting cutoff length for selected trajectories, default value is 10;
dn = 2; % Effective diffusion constant is calculated using dn*dt=dn*0.01s, default value is 2;

for i = 1:length(filename) % Loop through different files
    disp(filename{i})
    result = importdata(filename{i});
    for j = 1:length(result) % Loop through different trajectories within the file
        time_traj = result(j).tracking.time;
        MSD_traj = result(j).tracking.MSD;
        Total_traj_length = [Total_traj_length; length(time_traj)];
        if length(time_traj) <= L_cutoff
            continue
        else
            D_inst = MSD_traj(dn)/4/(dn*dt); %<MSD_{dn*dt}>=4*D*(dn*dt)
            [power_fit,gof] = fit(time_traj(1:Fit_cutoff),MSD_traj(1:Fit_cutoff),f_power,'display','off','StartPoint',[0,0]);
            alpha = power_fit.a;
            
            Total_D_inst = [Total_D_inst; D_inst];
            Total_alpha = [Total_alpha; alpha];
        end
    end
end

