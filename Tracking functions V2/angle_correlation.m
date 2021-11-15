function [Mean_cos_angle, sem_cos_angle, cos_angle_t_total] = angle_correlation(dt)
% dt=0.01;
% Example of using as "
% angle_correlation(0.01)"

% Check angle correlation by calculating averaged cos(theat) at different
% time intervals
 
% Based on the reference: "Modes of correlated angular motion in
% live cells across three distinct time scales", <cos(theta)>.

%Navigate to a directory with tracked_*.mat results files, which is the
%direct extract without linear fitting from trajectory csv files

disp('Select tracked*.mat files for calculating angle correlation functions')
[filename,path] = uigetfile('multiselect','on','tracked*.mat','Select the tracked files to convert');
 cd(path)

Total_traj_length = [];

L_cutoff = 2; % Cutoff length for trajectory, only consider trajectories with length>L_cutoff
angle_plot_cutoff = 50; % Angle correlation figure up to 'angle_plot_cutoff' length

for i = 1:length(filename) % Loop through different files
    disp(filename{i})
    result = importdata(filename{i});
    for j = 1:length(result) % Loop through different trajectories within the file
        time_traj = result(j).tracking.time;
        Total_traj_length = [Total_traj_length; length(time_traj)];
    end
end

max_track = max(Total_traj_length); % Extract the maximum length of trajectory, which probably won't be 400.
N_angle_traj = length(nonzeros(Total_traj_length > L_cutoff)); % Number of trajectories with length > L_cutoff
x_angle = zeros(N_angle_traj, max_track);
y_angle = zeros(N_angle_traj, max_track);

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
            x_angle(index, 1:length(time_traj)) = result(j).tracking.x;
            y_angle(index, 1:length(time_traj)) = result(j).tracking.y;
        end
    end
end

% Angle correlation information at different time points from x,y positions
% stored above
cos_angle_t_total = cell(angle_plot_cutoff,1);
for i = 1:angle_plot_cutoff
    tic
    cos_angle_t_temp = [];
    for j = 1:N_angle_traj
        % Extract non-zero position information
        x_temp = x_angle(j,:);
        y_temp = y_angle(j,:);
        x_temp = x_temp(x_temp~=0);
        y_temp = y_temp(y_temp~=0);
        % Extract vector (delta_x, delta_y) information under different
        % time intervals (i)
        delta_x = x_temp(1+i:end)-x_temp(1:end-i);
        delta_y = y_temp(1+i:end)-y_temp(1:end-i);
        
        cos_angle_t_temp_j = zeros(1,length(delta_x)-i);
        for k = 1:length(delta_x)-i
            cos_angle = (delta_x(k) * delta_x(k+i) + delta_y(k) * delta_y(k+i))/sqrt(delta_x(k)^2+delta_y(k)^2)/sqrt(delta_x(k+i)^2+delta_y(k+i)^2);
            cos_angle_t_temp_j(k) = cos_angle;
        end
        
        cos_angle_t_temp = [cos_angle_t_temp,cos_angle_t_temp_j];
    end
    cos_angle_t_total{i} = cos_angle_t_temp;
    toc
end

% Calculate average cos(theta(tau)) at different interval tau
Mean_cos_angle = zeros(1, angle_plot_cutoff);
sem_cos_angle = zeros(1, angle_plot_cutoff);
for i = 1:angle_plot_cutoff
    temp = cos_angle_t_total{i};
    if find(isnan(temp))
        temp = temp(~isnan(temp));
    end
    Mean_cos_angle(i) = mean(temp);
    sem_cos_angle(i) = std(temp)/sqrt(length(temp));
end

% Calculate the time point at which <cos(theta)> is 0 based on linear
% extrapolation
index_temp = find(Mean_cos_angle<0);
x2 = index_temp(1);
if x2 >=2 
    x1 = x2-1;
    y2 = Mean_cos_angle(x2);
    y1 = Mean_cos_angle(x1);
    t_cross = (x1*y2-x2*y1)*dt/(y2-y1);
else
    y2 = Mean_cos_angle(2);
    y1 = Mean_cos_angle(1);
    t_cross = (y2-2*y1)*dt/(y2-y1);
    if t_cross<0
        error('There is no angle cross timepoint.')
    end
end
    
% figure
hold on
errorbar((1:angle_plot_cutoff)*dt,Mean_cos_angle,sem_cos_angle,'.-')
text(t_cross,0,['\leftarrow t_{cross} = ',num2str(t_cross),' s'],'FontSize',15)
xlabel('Time / s')
ylabel('$<cos\ \theta(t)>_{TE}$','Interpreter','latex')
box on
set(gca,'FontSize',15)

end