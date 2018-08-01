
%Navigate to a directory with only your .mat results files and nothing
%else then grab the names with the following code

[filename,path] = uigetfile('multiselect','on','.mat','Select the file to convert');
 cd(path)

% Next extract the tracks from these result files with one of the next two loops.

%To include all tracks
for i = 1:length(filename)
    disp(filename{i})
    result = importdata(filename{i});
    med(i) = median(result.lin.D_lin{:});
    SEM(i) = std(result.lin.D_lin{:})/sqrt(length(result.lin.D_lin{:}));
end

% When you want to cut off tracks that don't move
% for i = 1:length(a)
%     disp(a{i})
%     result = importdata(a{i});
%     cut =  result.lin.D_lin{:} > 0.0095 & result.lin.D_lin{:} < 0.08; %result.lin.D_lin{:} > 0.001 &
%     cut_data = result.lin.D_lin{:}(cut)
%     med(i) = median(cut_data);
%     SEM(i) = std(result.lin.D_lin{:})/sqrt(length(result.lin.D_lin{:}));
% end

% run one of the two loops above then create the plot with the
% following code

h = figure
hold on
scatter(1:length(filename),med)
errorbar(1:length(filename),med,SEM,'.')
names = filename;
names = filename'

set(gca, 'XTick', 1:length(names),'XTickLabel',names);
set(gca,'xticklabel',names)
set(gca,'XTickLabelRotation',45)
