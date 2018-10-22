        lowCutoff = 0;
        highCutoff = 1;
        pointSelection = 0;
            
        [filenames_tracks,path_tracks] = uigetfile('multiselect','on','.mat','Select tracked file to find heterogenity ');
        [filenames_bf,path_bf] =uigetfile('multiselect','on','.jpg','Select the corresponding BF image');

         singleTrackvsManyTracks  = iscell(filenames_tracks);
         
         cd(path_tracks)

        result = struct();
        disp(filenames_tracks);
        result = importdata(filenames_tracks);

        cd(path_bf)
        im = imread(filenames_bf);
        imageName = filenames_bf;
        
        x = result.lin.Dlin_centroid_x{:};
        y = result.lin.Dlin_centroid_y{:};

        x2 = y;
        y2 = x;

        x = x2;
        y = y2; % somehow I flipped them - will fix this later

        x_length = length(im(:,1));
        y_length = length(im(1,:));
    
        Averaging_array = zeros(x_length,y_length);
        Counting_array = zeros(x_length,y_length);

    

% below this is my progress in trying to put all the magnitude into the x,y
% positions of the tracks. this would need to be paired with the direction.
% Probably not what we want as we have the start and end points of every
% track already
% % % 
% % % %quiver(x,y,u,v)
% % % 
% % %     for i = 1:length(result.lin.Dlin_centroid_y{1,1}) % loop through each cell then loop through all values within cell
% % %         for k = 1:length(x{i})
% % %             Averaging_array(round(x{1,i}(k)),round(y{1,i}(k))) = Averaging_array(round(x{1,i}(k)),round(y{1,i}(k))) +  sqrt((round(x{1,i}(length(x{1,i}))) -  round(x{1,i}(1)))^2 + (round(y{1,i}(length(y{1,i}))) -  round(y{1,i}(1)))^2);% gives you euclidean distance 2nd grade stuff
% % %             Counting_array(round(x{1,i}(k)),round(y{1,i}(k))) = Counting_array(round(x{1,i}(k)),round(y{1,i}(k))) + 1;
% % %         end
% % % 
% % %     end
% % %     
% % %     
% % %     Averaging_array(round(x{1,i}(k)),round(y{1,i}(k))) = Averaging_array(round(x{1,i}(k)),round(y{1,i}(k))) +  sqrt((round(x{1,i}(length(x{1}))) -  round(x{1,i}(1)))^2 + (round(y{1,i}(length(y{1}))) -  round(y{1,i}(1)))^2);
% % % 
% % % %     Another tip for anyone reading this, I wanted to compare my quiver plot to a plot produced by imagesc - 
% % % % imagesc automatically flips imaged matrices (because 0,0 is top left I think instead of bottom right) but you can use "set(gca,'YDir','normal')" 
% % % % to correct this and then they should both line up.
% % %     
% % %     round(x{1,i}(k)) round(y{1,i}(k))
% % %     %need to get these values for first and last k then calculate dist
% % %     
% % %     
    
   cartesian_coords = zeros(length(x),4)
   for i = 1: length(result.lin.Dlin_centroid_y{1,1})
       cartesian_coords(i,1:4) = [round(x{1,i}(1,1)), round(y{1,i}(1)), round(x{1,i}(length(x{1,i})))-round(x{1,i}(1,1)), round(y{1,i}(length(y{1,i})))-round(y{1,i}(1))];
   end
   %x1, y1, x2, y2
   quiver(cartesian_coords(:,1),cartesian_coords(:,2),cartesian_coords(:,3), cartesian_coords(:,4))
   
   % ok now I need to find a way to do some sort of averaging across these
   % data. 
   
   
   
   
   % use this as test data
   % I probably need to convert my data to start_x start_y degree angle and
   % magnitude. I can then color code based on angle and plot that.
   %This doesn't neccesarily solve the problem of averaging/ smoothing my
   %data. However, if I created a 4d matrix with these data. I could set a
   %gaussian filter based on x,y and then calculate new vectors by taking
   %all vectors within a rolling window and adding x's and y's to find a
   %new x and y magnitude (angle and magnitude) 
   
   % Ok, I'll create a matrix the size of my data then pull all data within
   % a given radius for each position and find an average to fill into this
   % new matrix, filling in NA when I have nothing to put there. I can plot
   % this and see how it looks
   
   % Look up downtown NYU chromatin dynamics diffusion woman and figure out
   % how she find bulk chromatin movement. Alekzandra zidovska. 2014 paper.
  
