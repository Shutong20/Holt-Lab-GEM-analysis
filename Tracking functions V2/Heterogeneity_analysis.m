[filename,path] = uigetfile('multiselect','on','.mat','Select tracked file to find heterogenity ');
 %filename(i) = {filename};
 cd(path)

result = struct();
disp(filename)
result = importdata(filename);


% Demo to very color of scatterpoints depending on their location

x = result.lin.Dlin_centroid_x{:};
y = result.lin.Dlin_centroid_y{:};

% Normalize - divide my sqrt(maxX^2 + maxY^2)
[filename,path] =uigetfile('multiselect','on','.jpg','Select the corresponding BF image');
cd(path)
im = imread(filename);

%im = imread('BF_1.png');
%image(im)
%imshow(im)
%alpha(0.9)
%hold all

%%

% [sortedDiffusion sortIndexes] = sort(result.lin.D_lin{:});
% % Arrange the data so that points close to the center
% % use the blue end of the colormap, and points 
% % close to the edge use the red end of the colormap.
% xs = x(sortIndexes);
% ys = y(sortIndexes);
% cmap = jet(length(x)); % Make 1000 colors.
% s = scatter(xs, ys, 1150, cmap, 'filled')
% s.MarkerFaceAlpha = 0.3;
% grid on;
% % title('Diffusion Coefficient Heatmap', ...
% % 	'FontSize', 30);
% % Enlarge figure to full screen.
% set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% % Give a name to the title bar.
% set(gcf,'name','Diffusion Coefficients by location','numbertitle','off') 
% 
% % in order to accurately smooth/average this data will need to create a
% % matrix with 
%% Ok now I am going to attempt to make cell within cell arrays of the location / diffusion data

x_length = length(im(:,1));
y_length = length(im(1,:));

Averaging_array = zeros(x_length,y_length);
Counting_array = zeros(x_length,y_length);


for i = 1:394 % loop through each cell then loop through all values within cell
    for k = 1:length(x{i})
        Averaging_array(round(x{1,i}(k)),round(y{1,i}(k))) = Averaging_array(round(x{1,i}(k)),round(y{1,i}(k))) + result.lin.D_lin{1,1}(i);
        Counting_array(round(x{1,i}(k)),round(y{1,i}(k))) = Counting_array(round(x{1,i}(k)),round(y{1,i}(k))) + 1;
    end
   
end
% highest = 4 counts
Bigger = Averaging_array * 1000;

avg_array = Bigger./Counting_array;
avg_array_renorm = avg_array ./ 1000;
%im_diffusion = image(avg_array)



% figuring out how to set LUTs for the image - then going to set
% data-driven alpha values

a = avg_array_renorm;


nanMask = isnan(a);
[r, c] = find(~nanMask);
[rNan, cNan] = find(nanMask);
Interpolated = scatteredInterpolant(c, r, a(~nanMask), 'nearest');
interpVals = Interpolated(cNan, rNan);
data = a;
data(nanMask) = interpVals;

% Filter the data, replacing Nans afterward:
% Filter the data, replacing Nans afterward:
filtWidth = 50;% need to make sure I understand this
filtSigma = 5; % need to make sure I understand this

imageFilter=fspecial('gaussian',filtWidth,filtSigma);

dataFiltered = imfilter(data, imageFilter, 'replicate', 'conv');
dataFiltered(nanMask) = nan;

oppNaN = 1- nanMask;

ax1 = axes;
imagesc(im);
colormap(ax1, 'gray');
ax = gca;
ax2 = axes;
im = imagesc(ax2, dataFiltered);
im.AlphaData = (oppNaN );
colormap(ax2, 'jet');caxis([0 1]);
ax2.Visible = 'off';
linkprop([ax1 ax2],'Position');
hold off
colorbar;