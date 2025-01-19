% simulate membrane dynamics

num_lipids = 1500;
num_steps = 2000;

% create matrix for particle of interest 
% store current and previous position

pos_interest = NaN(1,4);

% create matrix for lipids
% store current and previous position
pos_lipids = NaN(num_lipids,4);

% initialize positions of particle of interest and lipids

pos_interest(1,1:2) = randi([0 100], 1,2);

for i = 1:num_lipids
    pos_lipids(i, 1:2) = randi([0 100], 1,2);
end

% set up graphs

figure;
hold on;
lipid_scatter = scatter(pos_lipids(:,1), pos_lipids(:,2), lipid_colors, 'filled');
focal_scatter = scatter(pos_int(:,1), pos_int(:,2), size, 'red', 'filled');
theta = linspace(0, 2*pi, 100);  % Generate points for the circle     % Define the focal particle radius
circle_x = size * cos(theta) + pos_int(1,1);
circle_y = size * sin(theta) + pos_int(1,2);
circle_plot = fill(circle_x, circle_y, [1, 0, 0], 'EdgeColor', 'none');
xlim([0 grid_size]);
ylim([0 grid_size]);
axis equal
hold off;