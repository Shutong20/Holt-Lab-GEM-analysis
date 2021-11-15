function [Total_D_inst, Total_D_ens_inst] = Ensemble_vs_time_D(dt,conv)
% dt=0.01;
% conv=0.0928571 (100x TIRF without Spindle);or conv=0.065 (100x TIRF with Spindle);
% or conv=0.1342 (60x CONFOCAL)
% Example of using as "[Total_D_inst, Total_D_ens_inst] =
% Ensemble_vs_time_D(0.01,~)"

% Check the ergodicity of particle trajectories by calculating time
% averaging effective diffusion constants (space information) and ensemble 
% averaging effective diffusion constants (time information)
 
% Based on the reference: "Non-specific interactions govern cytosolic 
% diffusion of nanosized objects in mammalian cells".

%Navigate to a directory with tracked_*.mat results files, which is the
%direct extract without linear fitting from trajectory csv files

disp('Select tracked*.mat files for calculating Ensemble vs time average D')
[filename,path] = uigetfile('multiselect','on','tracked*.mat','Select the tracked files to convert');
 cd(path)

Total_traj_length = [];
Total_D_inst = [];
Total_D_ens_inst = [];

% Fitting function choosen below:
% f_power = fittype('c+b*x^a','dependent',{'y'},'independent',{'x'},'coefficients',{'a','b','c'});
f_power = fittype('b*x^a','dependent',{'y'},'independent',{'x'},'coefficients',{'a','b'});

L_cutoff = 10; % Cutoff length for trajectory, only consider trajectories with length>L_cutoff
Fit_cutoff = 10; % Fitting cutoff length for selected trajectories
dn = 2; % Effective diffusion constant is calculated using dn*dt=dn*0.01s

for i = 1:length(filename) % Loop through different files
    disp(filename{i})
    result = importdata(filename{i});
%     result = importdata(filename);
    for j = 1:length(result) % Loop through different trajectories within the file
        time_traj = result(j).tracking.time;
        MSD_traj = result(j).tracking.MSD;
        Total_traj_length = [Total_traj_length; length(time_traj)];
        if length(time_traj) <= L_cutoff
            continue
        else
            D_inst = MSD_traj(dn)/4/(dn*dt); %<MSD_{dn*dt}>=4*D*(dn*dt)
            Total_D_inst = [Total_D_inst; D_inst];
        end
    end
end

max_track = max(Total_traj_length); % Extract the maximum length of trajectory, which probably won't be 400.
N_ensemble_traj = length(nonzeros(Total_traj_length > L_cutoff)); % Number of trajectories with length > L_cutoff
x_ens = zeros(N_ensemble_traj, max_track);
y_ens = zeros(N_ensemble_traj, max_track);
MSD_ensemble_time_traj = zeros(N_ensemble_traj, max_track);

index = 0;
for i = 1:length(filename) % Loop through different files
    disp(filename{i})
    result = importdata(filename{i});
%     result = importdata(filename);
    for j = 1:length(result) % Loop through different trajectories within the file
        time_traj = result(j).tracking.time;
        if length(time_traj) <= L_cutoff
            continue
        else
            index = index+1;
            MSD_ensemble_time_traj(index, 1:length(time_traj)) = result(j).tracking.MSD;
            
            fillin_index = result(j).tracking.frame; % frame information starts from 0
            x_ens(index, fillin_index+1) = result(j).tracking.x;
            y_ens(index, fillin_index+1) = result(j).tracking.y;
        end
    end
end

% Ensemble average of MSD information at different time points
for i = 1:max_track-dn
    idx = find(x_ens(:,i) > 0 & x_ens(:,i+dn) > 0);
    MSD_ens = conv^2*mean(((x_ens(idx,i+dn) - x_ens(idx,i)).^2 + (y_ens(idx,i+dn) - y_ens(idx,i)).^2));
    D_ens_inst = MSD_ens/4/(dn*dt); %<MSD_{dn*dt}>=4*D*(dn*dt)
    Total_D_ens_inst = [Total_D_ens_inst; D_ens_inst];
end

% Ensemble-time average of MSD of all trajectories
MSD_TE = zeros(1,max_track);
for i = 1:max_track
    temp = MSD_ensemble_time_traj(:,i);
    MSD_TE(i) = mean(temp(temp>0));
end
% Fitting function choosen below:
% [power_fit,gof] = fit((1:Fit_cutoff)'*dt,MSD_TE(1:Fit_cutoff)',f_power,'display','off','StartPoint',[0,0,0]);
[power_fit,gof] = fit((1:Fit_cutoff)'*dt,MSD_TE(1:Fit_cutoff)',f_power,'display','off','StartPoint',[0,0]);

alpha = power_fit.a;
D_ens = power_fit.b/4;

figure
hold on
plot((1:L_cutoff)*dt,MSD_TE(1:L_cutoff),'o')
plot(power_fit,'--')
% text(0.05,0.009,['\alpha = ',num2str(alpha)],'fontSize',15)
% text(0.05,0.008,['D_{ens} = ',num2str(D_ens),'\mum^2/s'],'fontSize',15)
text(0.005,0.1,['\alpha = ',num2str(alpha)],'fontSize',15)
text(0.005,0.05,['D_{ens} = ',num2str(D_ens),'\mum^2/s'],'fontSize',15)
xlabel('Time / s')
ylabel(['$<MSD_{T\ge ',num2str(L_cutoff+1),'\Delta t}>_E$'],'Interpreter','latex')
box on
set(gca,'FontSize',15)
set(gca,'xScale','log')
set(gca,'yScale','log')
% xlim([0.01,1])

end





