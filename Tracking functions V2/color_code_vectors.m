clear; clc; close all
% Arrows in the following
% red = 0 to 90 degrees (counterclockwise)
% green = 91 to 180 degrees
% blue = 181 to 270 degrees
% cyan = 271 to 360 degrees
% Data is organize as (x, y, theta in degrees)
data = [1 1 120
       2 2 190
       3 3 220
       4 5 60
       6 2 150
       7 4 280
       8 1 310];
% Plot to figure 1
figure(1);
% Identify data from 1st quadrant and store in q1, identify data from 2nd quadrant
% goes to q2, and so on. A value of 1 indicates it is in the quadrant, 0 otherwise
q1 = (data(:,3) <= 90);
q2 = (data(:,3) > 90)  .* (data(:,3) <= 180);
q3 = (data(:,3) > 180) .* (data(:,3) <= 270);
q4 = (data(:,3) > 271) .* (data(:,3) <= 360);
hold on; 
% See DOC QUIVER
% Use QUIVER to specify the start point (tail of the arrow) and direction based on angle
% q1, q2, q3, and q4 are used to generate four different QUIVER handles (h1, h2, h3, and h4)
% This is necessary for varying colors based on direction
% Based on equations: x = x0 + r*cos(theta), y = y0 + r*sin(theta)
% In the usage below, x0 = data(:,1), y0 = data(:,2), theta = data(:,3) * pi / 180
% Can also specify a scale factor as the last argument to quiver (not specified below)
h1 = quiver(data(q1 == 1,1), data(q1 == 1,2), cos(data(q1 == 1,3) * pi/180), sin(data(q1 == 1,3) * pi/180));
h2 = quiver(data(q2 == 1,1), data(q2 == 1,2), cos(data(q2 == 1,3) * pi/180), sin(data(q2 == 1,3) * pi/180)); % sin is negative in 2nd quadrant
h3 = quiver(data(q3 == 1,1), data(q3 == 1,2), cos(data(q3 == 1,3) * pi/180), sin(data(q3 == 1,3) * pi/180));
h4 = quiver(data(q4 == 1,1), data(q4 == 1,2), cos(data(q4 == 1,3) * pi/180), sin(data(q4 == 1,3) * pi/180)); % cos is negative in 4th quadrant
% Set colors to red for 1st quadrant, blue for 2nd, green for 3rd, cyan for 4th
% Also, turn scaling off. get(h1) will return additional property-value pairs
set(h1, 'Color', [1 0 0], 'AutoScale', 'off')
set(h2, 'Color', [0 1 0], 'AutoScale', 'off')
set(h3, 'Color', [0 0 1], 'AutoScale', 'off')
set(h4, 'Color', [0 1 1], 'AutoScale', 'off')
% Done plotting
hold off;