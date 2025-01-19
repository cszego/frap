% simulate membrane dynamics

num_lipids = 1500;
num_steps = 2000;
colors = repmat([0, 0, 1], num_lipids, 1);
focal_size = 100;

% create matrix for particle of interest 
% store current and previous position

focal_pos = zeros(1,4);

% create matrix for lipids
% store current and previous position
pos_lipids = zeros(num_lipids,4);

% initialize positions of particle of interest and lipids

focal_pos(1,1:2) = randi([0 100], 1,2);
focal_pos(1,3:4) = focal_pos(1,1:2);

for i = 1:num_lipids
    pos_lipids(i, 1:2) = randi([0 100], 1,2);
    pos_lipids(i, 3:4) = pos_lipids(i, 1:2);
end

% set up graphs

figure;
hold on;
lipid_scatter = scatter(pos_lipids(:,3), pos_lipids(:,4), colors, 'filled');
focal_scatter = scatter(focal_pos(:,3), focal_pos(:,4), focal_size, 'red', 'filled');
theta = linspace(0, 2*pi, 100); 
circle_x = focal_size * cos(theta) + focal_pos(1,3);
circle_y = focal_size * sin(theta) + focal_pos(1,4);
circle_plot = fill(circle_x, circle_y, [1, 0, 0], 'EdgeColor', 'none');
xlim([0 100]);
ylim([0 100]);
axis equal
hold off;
% 
% figure
% layout = tiledlayout(1,2);
% nexttile
% hold on;
% xlabel('time')
% ylabel('Average Speed (distance traveled per simulation time step)')
% xlim([0 num_steps])
% ylim([0 1])
% speed_plot = plot(speed,'b', 'LineWidth',2);
% hold off;
% 
% nexttile
% hold on;
% xlabel('time')
% ylabel('Number of Interactions')
% interaction_plot = plot(interactions);
% hold on;
% avg_interaction_plot = plot(avg_interactions);
% hold off;

% simulate movement
disp('here')
for i = 1:num_steps
    for j = 1:num_lipids
        pos_lipids(j, 1:2) = pos_lipids(j, 3:4); %store previous position
        pos_lipids(j, 3:4) = pos_lipids(j, 1:2) + randi([0 100], 1,2)/3;
    end
    set(lipid_scatter, 'XData', pos_lipids(1,3), 'YData', pos_lipids(1,4))
    draw now;
end




        