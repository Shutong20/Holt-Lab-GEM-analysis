x = result.lin.Dlin_centroid_x{:};
y = result.lin.Dlin_centroid_y{:};



%quiver(x,y,u,v)

    for i = 1:length(result.lin.Dlin_centroid_y{1,1}) % loop through each cell then loop through all values within cell
        for k = 1:length(x{i})
            Direction_array(round(x{1,i}(k)),round(y{1,i}(k))) = Averaging_array(round(x{1,i}(k)),round(y{1,i}(k))) + result.lin.D_lin{1,1}(i);
            Counting_array(round(x{1,i}(k)),round(y{1,i}(k))) = Counting_array(round(x{1,i}(k)),round(y{1,i}(k))) + 1;
        end

    end
    
    
    
    round(x{1,i}(k)) round(y{1,i}(k))
    %need to get these values for first and last k then calculate dist
    
    sqrt((round(x{1,i}(length(x{1})) - round(x{1,i}(1)).^2 + (round(y{1,i}(length(y{1})) - round(y{1,i}(1)).^2))); % gives you euclidean distance
    
    