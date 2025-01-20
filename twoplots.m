% simulate membrane dynamics
% initialize variables

num_lipids = 2000;
num_steps = 2000;
small_size = 5;
large_size = 20;

% for small
colors = repmat([0, 0, 1], num_lipids, 1);
interaction_vectors = zeros(num_lipids,2);
speed = zeros(num_steps, 1);
avg_speed = NaN(num_steps,1);
interaction = NaN(num_steps,1);
distance_traveled = NaN(num_steps,1);
max_distance = NaN(num_steps,1);
avg_speed_over_steps = NaN(num_steps,1);
speed_over_steps = NaN(num_steps,1);
avg_num_interactions = NaN(num_steps,1);

% for large
colors_large = repmat([0, 0, 1], num_lipids, 1);
interaction_vectors_large = zeros(num_lipids,2);
speed_large = zeros(num_steps, 1);
avg_speed_large = NaN(num_steps,1);
interaction_large = NaN(num_steps,1);
distance_traveled_large = NaN(num_steps,1);
max_distance_large = NaN(num_steps,1);
avg_speed_over_steps_large = NaN(num_steps,1);
speed_over_steps_large = NaN(num_steps,1);
avg_num_interactions_large = NaN(num_steps,1);


friction_coefficient = 0;

% create matrix for particle of interest 
% store current and previous position

focal_pos = zeros(1,4);
focal_pos_large = zeros(1,4);

% create matrix for lipids
% store current and previous position
pos_lipids = zeros(num_lipids,4);
pos_lipids_large = zeros(num_lipids,4);

% initialize positions of particle of interest and lipids

focal_pos(1,1:2) = [50 50];
focal_pos(1,3:4) = focal_pos(1,1:2) + randi([-100 100], 1,2)/1000;

focal_pos_large(1,1:2) = [50 50];
focal_pos_large(1,3:4) = focal_pos_large(1,1:2) + randi([-100 100], 1,2)/1000;

for i = 1:num_lipids
    pos_lipids(i, 1:2) = randi([0 100], 1,2);
    pos_lipids(i, 3:4) = pos_lipids(i, 1:2);
    pos_lipids_large(i, 1:2) = randi([0 100], 1,2);
    pos_lipids_large(i, 3:4) = pos_lipids_large(i, 1:2);
end
% set up graphs for first particle

figure
layout = tiledlayout(4,4);
nexttile(1,[2,2])
hold on;
lipid_scatter = scatter(pos_lipids(:,3), pos_lipids(:,4), 50, colors, 'filled');
focal_scatter = scatter(focal_pos(:,3), focal_pos(:,4), focal_size, 'red', 'filled');
theta = linspace(0, 2*pi, 100); 
circle_x = focal_size * cos(theta) + focal_pos(1,3);
circle_y = focal_size * sin(theta) + focal_pos(1,4);
circle_plot = fill(circle_x, circle_y, [1, 0, 0], 'EdgeColor', 'none');
xlim([0 100]);
ylim([0 100]);
axis equal
hold off;


nexttile
hold on;
xlabel('Time')
ylabel('Distance per Time Step')
title('Average Speed')
xlim([0 num_steps])
ylim([0 1])
speed_plot = plot(avg_speed,'b', 'LineWidth',2);
hold off;

nexttile
hold on;
xlabel('Time')
ylabel('Number of Interactions')
title('Number of Interactions')
xlim([0 num_steps])
ylim([0 15])
interaction_plot = plot(interaction, 'Color', [0.75 0.75 0.75], 'LineWidth',1);
hold on;
avg_interaction_plot = plot(avg_num_interactions, 'r', 'LineWidth', 2);
hold off;

nexttile
hold on;
title('Max Distance Traveled')
xlabel('Time')
ylabel('Distance')
xlim([0 num_steps])
distance_plot = plot(max_distance, 'b', LineWidth=2);
hold off;

nexttile
hold on;
title('Average Speed Without Vibrations')
xlabel('time')
ylabel('Average Speed')
xlim([0 num_steps])
ylim([0 10])
speed_over_steps_plot = plot(avg_speed_over_steps, 'b', 'LineWidth', 2);
hold off;

% set up graphs for second particle

figure
layout = tiledlayout(4,4);
nexttile(1,[2,2])
hold on;
lipid_scatter_large = scatter(pos_lipids_large(:,3), pos_lipids_large(:,4), 50, colors_large, 'filled');
focal_scatter_large = scatter(focal_pos_large(:,3), focal_pos_large(:,4), large_size, 'red', 'filled');
theta_large = linspace(0, 2*pi, 100); 
circle_x_large = large_size * cos(theta) + focal_pos_large(1,3);
circle_y_large = large_size * sin(theta) + focal_pos_large(1,4);
circle_plot_large = fill(circle_x_large, circle_y_large, [1, 0, 0], 'EdgeColor', 'none');
xlim([0 100]);
ylim([0 100]);
axis equal
hold off;


nexttile
hold on;
xlabel('Time')
ylabel('Distance per Time Step')
title('Average Speed Large')
xlim([0 num_steps])
ylim([0 1])
speed_plot_large = plot(avg_speed_large,'b', 'LineWidth',2);
hold off;

nexttile
hold on;
xlabel('Time')
ylabel('Number of Interactions')
title('Number of Interactions Large')
xlim([0 num_steps])
ylim([0 15])
interaction_plot_large = plot(interaction_large, 'Color', [0.75 0.75 0.75], 'LineWidth',1);
hold on;
avg_interaction_plot_large = plot(avg_num_interactions_large, 'r', 'LineWidth', 2);
hold off;

nexttile
hold on;
title('Max Distance Traveled Large')
xlabel('Time')
ylabel('Distance')
xlim([0 num_steps])
distance_plot_large = plot(max_distance_large, 'b', LineWidth=2);
hold off;

nexttile
hold on;
title('Average Speed Without Vibrations Large')
xlabel('time')
ylabel('Average Speed')
xlim([0 num_steps])
ylim([0 10])
speed_over_steps_plot_large = plot(avg_speed_over_steps_large, 'b', 'LineWidth', 2);
hold off;

% simulate movement
focal_pos_init = focal_pos(1,3:4);
focal_pos_minus_100 = focal_pos(1,3:4);
focal_pos_init_large = focal_pos_large(1,3:4);
focal_pos_minus_100_large = focal_pos_large(1,3:4);
for i = 1:num_steps
    friction_lipids = [0 0];
    friction_lipids_large = [0 0];
    for j = 1:num_lipids
        lipid_movement = pos_lipids(j,3:4) - pos_lipids(j,1:2);
        pos_lipids(j, 1:2) = pos_lipids(j, 3:4); %store previous position
        pos_lipids(j, 3:4) = pos_lipids(j, 1:2) + 0.5*lipid_movement + randi([-100 100], 1,2)/300;
        pos_lipids(j,:) = max(min(pos_lipids(j,:), 100), 1);
        lipid_movement_large = pos_lipids_large(j,3:4) - pos_lipids_large(j,1:2);
        pos_lipids_large(j, 1:2) = pos_lipids_large(j, 3:4); %store previous position
        pos_lipids_large(j, 3:4) = pos_lipids_large(j, 1:2) + 0.5*lipid_movement_large + randi([-100 100], 1,2)/300;
        pos_lipids_large(j,:) = max(min(pos_lipids_large(j,:), 100), 1);
    end
    % movement of focal particle
    % check for touching lipids
    num_interactions = 0;
    num_interactions_large = 0;
    for k = 1:num_lipids
        distance = norm(pos_lipids(k,3:4) - focal_pos(1,3:4));
        lipid_direction = pos_lipids(k, 3:4) - pos_lipids(k,1:2);
        focal_direction = (focal_pos(1,3:4) - focal_pos(1,1:2));
        cos_theta = dot(lipid_direction, focal_direction)/(norm(lipid_direction)*norm(focal_direction));
        angle = acosd(cos_theta);
        distance_large = norm(pos_lipids_large(k,3:4) - focal_pos_large(1,3:4));
        lipid_direction_large = pos_lipids_large(k, 3:4) - pos_lipids_large(k,1:2);
        focal_direction_large = (focal_pos_large(1,3:4) - focal_pos_large(1,1:2));
        cos_theta_large = dot(lipid_direction_large, focal_direction_large)/(norm(lipid_direction_large)*norm(focal_direction_large));
        angle_large = acosd(cos_theta_large);
        if angle < 90 % exclude lipids that are in radius of interaction but wouldn't realistically apply force
            if distance <= focal_size + 1 && distance >= focal_size - 1
                colors(k,:) = [0, 1, 0];
                interaction_vectors(k, 1:2) = pos_lipids(k,3:4) - pos_lipids(k,1:2);
                num_interactions = num_interactions + 1;
            else
                interaction_vectors(k,:) = [0 0];
                colors(k,:) = [0, 0, 1];
            end
            if distance_large <= large_size + 1 && distance_large >= large_size - 1
                colors_large(k,:) = [0, 1, 0];
                interaction_vectors_large(k, 1:2) = pos_lipids_large(k,3:4) - pos_lipids_large(k,1:2);
                num_interactions_large = num_interactions_large + 1;
            else
                interaction_vectors_large(k,:) = [0 0];
                colors_large(k,:) = [0, 0, 1];
            end
        end
        
    end
    for l = 1:num_lipids
    distance = norm(pos_lipids(l,3:4) - focal_pos(1,3:4));
    distance_large = norm(pos_lipids_large(l,3:4) - focal_pos_large(1,3:4));
    if distance <= focal_size + 1 && distance >= focal_size - 1
            focal_lipid_vector = focal_pos(1,3:4) - pos_lipids(l,3:4);
            focal_lipid_angle = acosd(dot(focal_lipid_vector, focal_direction)/(norm(focal_lipid_vector)*norm(focal_direction)));
            if focal_lipid_angle <= 90
                friction_lipids = [friction_lipids; pos_lipids(l,3:4)];
            end
    end
    if distance_large <= large_size + 1 && distance_large >= large_size - 1
            focal_lipid_vector_large = focal_pos_large(1,3:4) - pos_lipids_large(l,3:4);
            focal_lipid_angle_large = acosd(dot(focal_lipid_vector_large, focal_direction_large)/(norm(focal_lipid_vector)*norm(focal_direction_large)));
            if focal_lipid_angle_large <= 90
                friction_lipids_large = [friction_lipids_large; pos_lipids_large(l,3:4)];
            end
    end
    end
    %move focal particle based on lipid movement
    force = -sum(interaction_vectors);
    direction = (focal_pos(1,3:4) - focal_pos(1,1:2));
    direction = direction/norm(direction);
    force_large = -sum(interaction_vectors_large);
    direction_large = (focal_pos_large(1,3:4) - focal_pos_large(1,1:2));
    direction_large = direction_large/norm(direction_large);
    for xy = 3:4
            if focal_pos(1,xy) <= 1 || focal_pos(1,xy) >= 100
                direction = -direction;
            end
            if focal_pos_large(1,xy) <= 1 || focal_pos_large(1,xy) >= 100
                direction_large = -direction_large;
            end
    end
    focal_pos(1,1:2) = focal_pos(1,3:4);
    friction_coefficient = 1/size(friction_lipids,1);
    friction_coefficient = friction_coefficient - 1;
    focal_pos(1,3:4) = focal_pos(1,1:2) + (0.1*force + 0.3*direction) + friction_coefficient*(0.1* force + 0.3*direction)/3;

    focal_pos_large(1,1:2) = focal_pos_large(1,3:4);
    friction_coefficient_large = 1/size(friction_lipids_large,1);
    friction_coefficient_large = friction_coefficient_large - 1;
    focal_pos_large(1,3:4) = focal_pos_large(1,1:2) + (0.1*force_large + 0.3*direction_large) + friction_coefficient_large*(0.1* force_large + 0.3*direction_large)/3;
    
    speed(i,1) = norm(focal_pos(1,3:4) - focal_pos(1,1:2));
    speed_large(i,1) = norm(focal_pos_large(1,3:4) - focal_pos_large(1,1:2));
    if mod(i-1, 20) == 0 % update speed after 100 steps (vibration and more constant movement treated differently)
        distance_traveled_in20 = focal_pos(1,3:4) - focal_pos_minus_100;
        speed_over_steps(i:i+19,1) = repmat(norm(distance_traveled_in20),20,1);
        focal_pos_minus_100 = focal_pos(1,3:4);
        distance_traveled_in20_large = focal_pos_large(1,3:4) - focal_pos_minus_100_large;
        speed_over_steps_large(i:i+19,1) = repmat(norm(distance_traveled_in20_large),20,1);
        focal_pos_minus_100_large = focal_pos_large(1,3:4);
    end
    avg_speed_over_steps(i,1) = sum(speed_over_steps(1:i,1))/i;
    avg_speed(i,1) = sum(speed(1:i,1))/i;
    distance_traveled(i,1) = norm(focal_pos(1,3:4) - focal_pos_init);
    max_distance(i,1) = max(distance_traveled);
    interaction(i,1) = num_interactions;
    avg_num_interactions(i,1) = sum(interaction(1:i))/i;

    avg_speed_over_steps_large(i,1) = sum(speed_over_steps_large(1:i,1))/i;
    avg_speed_large(i,1) = sum(speed_large(1:i,1))/i;
    distance_traveled_large(i,1) = norm(focal_pos_large(1,3:4) - focal_pos_init_large);
    max_distance_large(i,1) = max(distance_traveled_large);
    interaction_large(i,1) = num_interactions_large;
    avg_num_interactions_large(i,1) = sum(interaction_large(1:i))/i;
    % update plots
    set(lipid_scatter, 'XData', pos_lipids(:,3), 'YData', pos_lipids(:,4), 'CData', colors)
    set(focal_scatter, 'XData', focal_pos(1,3), 'YData', focal_pos(1,4))
    circle_x = focal_size * cos(theta) + focal_pos(1,3);
    circle_y = focal_size * sin(theta) + focal_pos(1,4);
    set(circle_plot, 'XData', circle_x, 'YData', circle_y);
    set(interaction_plot, 'YData', interaction)
    set(speed_plot, 'YData', avg_speed)
    set(distance_plot, 'YData', max_distance)
    set(speed_over_steps_plot, 'YData', avg_speed_over_steps)
    set(avg_interaction_plot, 'YData', avg_num_interactions)
    set(lipid_scatter_large, 'XData', pos_lipids_large(:,3), 'YData', pos_lipids_large(:,4), 'CData', colors_large)
    set(focal_scatter_large, 'XData', focal_pos_large(1,3), 'YData', focal_pos_large(1,4))
    circle_x_large = large_size * cos(theta_large) + focal_pos_large(1,3);
    circle_y_large = large_size * sin(theta_large) + focal_pos_large(1,4);
    set(circle_plot_large, 'XData', circle_x_large, 'YData', circle_y_large);
    set(interaction_plot_large, 'YData', interaction_large)
    set(speed_plot_large, 'YData', avg_speed_large)
    set(distance_plot_large, 'YData', max_distance_large)
    set(speed_over_steps_plot_large, 'YData', avg_speed_over_steps_large)
    set(avg_interaction_plot_large, 'YData', avg_num_interactions_large)
    drawnow;
end


