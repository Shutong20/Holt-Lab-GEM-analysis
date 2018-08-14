function [filenames_all_conditions] = results_tracking_V4(dt,conv, filenames_this_condition)


for m = 1:length(filenames_this_condition)

filename = filenames_this_condition{m};
% import csv using this amazing importer
[Trajectory, Frame, x, y, z] = csvimport(filename , 'columns', {'Trajectory', 'Frame', 'x', 'y', 'z'} ) ;
%%
% delimiter = ',';    
% formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
% fileID = fopen(filename,'r');
% %If loading your files is failing it may mean that you are using an older
% %version of mosaic to track your files - it seems that the older version
% %left an empty column at the start and the newer version does not do this.
% dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
% fclose(fileID);    
% raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
% for col=1:length(dataArray)-1
%     raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
% end
% numericData = NaN(size(dataArray{1},1),size(dataArray,2));
% 
% for col=[1,2,3,4,5,6,7,8,9,10,11]
%     % Converts text in the input cell array to numbers. Replaced non-numeric
%     % text with NaN.
%     rawData = dataArray{col};
%     for row=1:size(rawData, 1)
%         % Create a regular expression to detect and remove non-numeric prefixes and
%         % suffixes.
%         regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
%         try
%             result = regexp(rawData(row), regexstr, 'names');
%             numbers = result.numbers;
%             
%             % Detected commas in non-thousand locations.
%             invalidThousandsSeparator = false;
%             if numbers.contains(',')
%                 thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
%                 if isempty(regexp(numbers, thousandsRegExp, 'once'))
%                     numbers = NaN;
%                     invalidThousandsSeparator = true;
%                 end
%             end
%             % Convert numeric text to numbers.
%             if ~invalidThousandsSeparator
%                 numbers = textscan(char(strrep(numbers, ',', '')), '%f');
%                 numericData(row, col) = numbers{1};
%                 raw{row, col} = numbers{1};
%             end
%         catch
%             raw{row, col} = rawData{row};
%         end
%     end
% end
% 
% 
% %% Replace non-numeric cells with NaN
% R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
% raw(R) = {NaN}; % Replace non-numeric cells
% 
% %% Assign variables
% 
% Trajectory = cell2mat(raw(2:length(raw), 1));
% Frame = cell2mat(raw(2:length(raw), 2));
% x = cell2mat(raw(2:length(raw), 3));
% y = cell2mat(raw(2:length(raw), 4));
% z = cell2mat(raw(2:length(raw), 5));
% m0 = cell2mat(raw(2:length(raw), 6));
% m1 = cell2mat(raw(2:length(raw), 7));
% m2 = cell2mat(raw(2:length(raw), 8));
% m3 = cell2mat(raw(2:length(raw), 9));
% m4 = cell2mat(raw(2:length(raw), 10));
% NPscore = cell2mat(raw(2:length(raw), 11));
% 
% %% Clear temporary variables
% clearvars filename delimiter formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp R;    
%     % comment down to here when you have extra first column 
   %%
   % Above is the old import for when you results tracking has the extra first column
%% 


idx = find(diff(Trajectory) > 0);
if isempty(idx)
    continue
end
    
S = [];
for i = 1:length(idx)
    if i < 10
        S = [S;strcat('part0000',num2str(i))];
    elseif i >= 10 && i < 100
        S = [S;strcat('part000',num2str(i))];
    elseif i >= 100 && i < 999
        S = [S;strcat('part00',num2str(i))];
    elseif i >=1000 && i < 9999
        S = [S;strcat('part0',num2str(i))];
    elseif i >= 10000 && i < 99999
        S = [S;strcat('part',num2str(i))];
    end
end

field = cellstr(S);

result = cell2struct(field','tracking',1);

MSD = zeros(1,length(idx));
time = zeros(1,length(idx));
x_res = zeros(1,length(idx));
y_res = zeros(1,length(idx));
frame_res = zeros(1,length(idx));

for i = 1:length(idx)
    
    if i == 1
        x_res(1:idx(i),i) = x(1:idx(i));
        y_res(1:idx(i),i) = y(1:idx(i));
        frame_res(1:idx(i),i) = Frame(1:idx(i));
        time(1:idx(i),i) = 0:dt:dt*(idx(i)-1);
        MSD(1:idx(i),i) = calculate_MSD(x(1:idx(i)),y(1:idx(i)),0,dt,conv);
      
    elseif i > 1
        x_res(1:(idx(i)-idx(i-1)),i) = x((idx(i-1)+1):idx(i));
        y_res(1:(idx(i)-idx(i-1)),i) = y((idx(i-1)+1):idx(i));
        frame_res(1:(idx(i)-idx(i-1)),i) = Frame((idx(i-1)+1):idx(i));
        time(1:(idx(i)-idx(i-1)),i) = 0:dt:dt*(idx(i)-idx(i-1)-1);
        MSD(1:(idx(i)-idx(i-1)),i) = calculate_MSD(x((idx(i-1)+1):idx(i)),y((idx(i-1)+1):idx(i)),0,dt,conv);
        
    end 
    
    result(i).tracking = struct('time',time(find(MSD(:,i))>0,i),...
        'x',x_res(find(MSD(:,i))>0,i),...
        'y',y_res(find(MSD(:,i))>0,i),...
        'MSD',MSD(find(MSD(:,i))>0,i),...
        'frame',frame_res(find(MSD(:,i))>0,i));
    
    
end

filename_int = filenames_this_condition{m};
name_file = filename_int(1:strfind(filename_int,'.csv')-1);

saving_name = strcat('tracked_',name_file,'.mat');
save(saving_name,'result')

end

% uisave('result')
% save P=8_bis.mat result 

end

