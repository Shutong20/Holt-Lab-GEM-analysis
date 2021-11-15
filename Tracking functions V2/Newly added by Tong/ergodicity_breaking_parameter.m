function EB = ergodicity_breaking_parameter(dt)
% This function is to calculate the ergodicity breaking (EB) paramers at
% different time lag. It is defined as the ratio between the varience and
% the squared mean of the time-averaged MSD at any given time lag among all
% trajectories. This is to quantify the level of the non-ergodicity of the
% system. EB(x^2(T)) = Var(<\bar{x^2(T)}>)/<\bar{x^2(T)}>^2

% Based on the reference: "A review of progress in single particle tracking:
% from methods to biophysical insights", section 5.2. & "A toolbox for 
% determining subdiffusive mechanisms, section 5.3.2."

%Navigate to a directory with tracked_*.mat results files, which is the
%direct extract without linear fitting from trajectory csv files

disp('Select tracked*.mat files for calculating EB parameters')
[filename,path] = uigetfile('multiselect','on','tracked*.mat','Select the tracked files to convert');
 cd(path)

Total_traj_length = [];

L_cutoff = 10; % Cutoff length for trajectory, only consider trajectories with length>L_cutoff

for i = 1:length(filename) % Loop through different files
    disp(filename{i})
    result = importdata(filename{i});
    for j = 1:length(result) % Loop through different trajectories within the file
        time_traj = result(j).tracking.time;
        MSD_traj = result(j).tracking.MSD;
        Total_traj_length = [Total_traj_length; length(time_traj)];
    end
end

Max_traj_length = max(Total_traj_length);
N_select_traj = length(nonzeros(Total_traj_length > L_cutoff)); % Number of trajectories with length > L_cutoff
MSD_time_traj = zeros(N_select_traj, Max_traj_length);

index = 0;
for i = 1:length(filename) % Loop through different files
    disp(filename{i})
    result = importdata(filename{i});
    for j = 1:length(result) % Loop through different trajectories within the file
        time_traj = result(j).tracking.time;
        if length(time_traj) <= L_cutoff
            continue
        else
            index = index+1;
            MSD_time_traj(index, 1:length(time_traj)) = result(j).tracking.MSD;
        end
    end
end

% Calculate EB parameters based on the time-averaged MSD among all
% trajectories at different time lag
EB = zeros(1,Max_traj_length);
for i = 1:Max_traj_length
    temp = MSD_time_traj(:,i);
    EB(i) = var(temp(temp>0))/mean(temp(temp>0))^2;
end

% figure
hold on
plot((1:L_cutoff)*dt,EB(1:L_cutoff),'o')
xlabel('Time / s')
ylabel('Ergodicity breaking parameter')
box on
set(gca,'FontSize',15)

end