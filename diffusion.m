% simulate membrane dynamics
% initialize variables

num_lipids = 2000;
num_steps = 2000;
colors = repmat([0, 0, 1], num_lipids, 1);
focal_size = 20;

interaction_vectors = zeros(num_lipids,2);
speed = zeros(num_steps, 1);
avg_speed = NaN(num_steps,1);
interaction = NaN(num_steps,1);
distance_traveled = NaN(num_steps,1);
max_distance = NaN(num_steps,1);

friction_coefficient = 0;

% create matrix for particle of interest 
% store current and previous position

focal_pos = zeros(1,4);

% create matrix for lipids
% store current and previous position
pos_lipids = zeros(num_lipids,4);

% initialize positions of particle of interest and lipids

focal_pos(1,1:2) = [50 50];
focal_pos(1,3:4) = focal_pos(1,1:2) + randi([-100 100], 1,2)/1000;

focal_pos_init = focal_pos(1,1:2);

for i = 1:num_lipids
    pos_lipids(i, 1:2) = randi([0 100], 1,2);
    pos_lipids(i, 3:4) = pos_lipids(i, 1:2);
end
% set up graphs

figure;
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

figure
layout = tiledlayout(2,2);
nexttile
hold on;
xlabel('time')
ylabel('Average Speed (distance traveled per simulation time step)')
xlim([0 num_steps])
ylim([0 1])
speed_plot = plot(avg_speed,'b', 'LineWidth',2);
hold off;

nexttile
hold on;
xlabel('time')
ylabel('Number of interaction_vectors')
interaction_plot = plot(interaction);
hold on;
%avg_interaction_plot = plot(avg_interaction_vectors);
hold off;

nexttile
hold on;
title('max distance traveled')
xlabel('time')
ylabel('max distance traveled')
distance_plot = plot(max_distance);
hold off;

% simulate movement

focal_pos_minus_100 = focal_pos(1,3:4);
for i = 1:num_steps
    friction_lipids = [0 0];
    for j = 1:num_lipids
        lipid_movement = pos_lipids(j,3:4) - pos_lipids(j,1:2);
        pos_lipids(j, 1:2) = pos_lipids(j, 3:4); %store previous position
        pos_lipids(j, 3:4) = pos_lipids(j, 1:2) + 0.5*lipid_movement + randi([-100 100], 1,2)/300;
        pos_lipids(j,:) = max(min(pos_lipids(j,:), 100), 1);
    end
    % movement of focal particle
    % check for touching lipids
    num_interactions = 0;
    for k = 1:num_lipids
        distance = norm(pos_lipids(k,3:4) - focal_pos(1,3:4));
        lipid_direction = pos_lipids(k, 3:4) - pos_lipids(k,1:2);
        focal_direction = (focal_pos(1,3:4) - focal_pos(1,1:2));
        cos_theta = dot(lipid_direction, focal_direction)/(norm(lipid_direction)*norm(focal_direction));
        angle = acosd(cos_theta);
        if angle < 90 % exclude lipids that are in radius of interaction but wouldn't realistically apply force
            if distance <= focal_size + 1 && distance >= focal_size - 1
                colors(k,:) = [0, 1, 0];
                interaction_vectors(k, 1:2) = pos_lipids(k,3:4) - pos_lipids(k,1:2);
                num_interactions = num_interactions + 1;
            else
                interaction_vectors(k,:) = [0 0];
                colors(k,:) = [0, 0, 1];
            end
        end
        
    end
    for l = 1:num_lipids
    distance = norm(pos_lipids(l,3:4) - focal_pos(1,3:4));
    if distance <= focal_size + 1 && distance >= focal_size - 1
            focal_lipid_vector = focal_pos(1,3:4) - pos_lipids(l,3:4);
            focal_lipid_angle = acosd(dot(focal_lipid_vector, focal_direction)/(norm(focal_lipid_vector)*norm(focal_direction)));
            if focal_lipid_angle <= 90
                friction_lipids = [friction_lipids; pos_lipids(l,3:4)];
            end
    end
    end
    %move focal particle based on lipid movement
    force = -sum(interaction_vectors);
    direction = (focal_pos(1,3:4) - focal_pos(1,1:2));
    direction = direction/norm(direction);
    for xy = 3:4
            if focal_pos(1,xy) <= 1 || focal_pos(1,xy) >= 100
                direction = -direction;
            end
    end
    focal_pos(1,1:2) = focal_pos(1,3:4);
    friction_coefficient = 1/size(friction_lipids,1);
    friction_coefficient = friction_coefficient - 1;
    focal_pos(1,3:4) = focal_pos(1,1:2) + (0.1*force + 0.3*direction) + friction_coefficient*(0.1* force + 0.3*direction)/2;
    
    speed(i,1) = norm(focal_pos(1,3:4) - focal_pos(1,1:2));
    % if mod(i-1, 100) == 0 % update speed after 100 steps (vibration and more constant movement treated differently)
    %     distance_traveled_in100 = focal_pos(1,3:4) - focal_pos_minus_100;
    %     speed(i:i+99,1) = repmat(norm(distance_traveled_in100)/100,100,1);
    %     focal_pos_minus_100 = focal_pos(1,3:4);
    % end
    avg_speed(i,1) = sum(speed(1:i,1))/i;
    distance_traveled(i,1) = norm(focal_pos(1,3:4) - focal_pos_init);
    max_distance(i,1) = max(distance_traveled);
    interaction(i,1) = num_interactions;
    set(lipid_scatter, 'XData', pos_lipids(:,3), 'YData', pos_lipids(:,4), 'CData', colors)
    set(focal_scatter, 'XData', focal_pos(1,3), 'YData', focal_pos(1,4))
    circle_x = focal_size * cos(theta) + focal_pos(1,3);
    circle_y = focal_size * sin(theta) + focal_pos(1,4);
    set(circle_plot, 'XData', circle_x, 'YData', circle_y);
    set(interaction_plot, 'YData', interaction)
    set(speed_plot, 'YData', avg_speed)
    set(distance_plot, 'YData', max_distance)
    drawnow;
end