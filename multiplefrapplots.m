% simulate membrane dynamics
% initialize variables

num_lipids = 2000;
num_steps = 2000;
focal_sizes = [5, 10, 15]; % Multiple particle sizes
num_particles = length(focal_sizes); % Number of different particle sizes

function simulate_frap(num_lipids, num_steps, focal_sizes)
    colors = repmat([0, 0, 1], num_lipids, 1);
    interaction_vectors = zeros(num_lipids, 2);
    speed = zeros(num_steps, num_particles); % Track speed for each particle size
    avg_speed = NaN(num_steps, num_particles);
    interaction = NaN(num_steps, num_particles);
    distance_traveled = NaN(num_steps, num_particles);
    max_distance = NaN(num_steps, num_particles);
    avg_speed_over_steps = NaN(num_steps, num_particles);
    speed_over_steps = NaN(num_steps, num_particles);
    avg_num_interactions = NaN(num_steps, num_particles);

    friction_coefficient = 0;

    % Create matrix for particle of interest (one for each particle size)
    focal_pos = zeros(num_particles, 4);

    % Create matrix for lipids (one for all particles)
    pos_lipids = zeros(num_lipids, 4);

    % Initialize positions of particles of interest and lipids
    for p = 1:num_particles
        focal_pos(p, 1:2) = [50 50];
        focal_pos(p, 3:4) = focal_pos(p, 1:2) + randi([-100 100], 1, 2)/1000;
    end

    for i = 1:num_lipids
        pos_lipids(i, 1:2) = randi([0 100], 1, 2);
        pos_lipids(i, 3:4) = pos_lipids(i, 1:2);
    end

    % Set up graphs
    figure;
    hold on;
    lipid_scatter = scatter(pos_lipids(:, 3), pos_lipids(:, 4), 50, colors, 'filled');
    focal_scatter = gobjects(num_particles, 1); % Handle for multiple focal particles
    circle_plot = gobjects(num_particles, 1); % Circle plot for each particle size

    for p = 1:num_particles
        focal_scatter(p) = scatter(focal_pos(p, 3), focal_pos(p, 4), focal_sizes(p), 'filled', 'MarkerFaceColor', 'red');
        theta = linspace(0, 2*pi, 100);
        circle_x = focal_sizes(p) * cos(theta) + focal_pos(p, 3);
        circle_y = focal_sizes(p) * sin(theta) + focal_pos(p, 4);
        circle_plot(p) = fill(circle_x, circle_y, [1, 0, 0], 'EdgeColor', 'none');
    end

    xlim([0 100]);
    ylim([0 100]);
    axis equal
    hold off;

    figure;
    layout = tiledlayout(2, 2);
    nexttile;
    hold on;
    xlabel('Time');
    ylabel('Distance per Time Step');
    title('Average Speed');
    xlim([0 num_steps]);
    ylim([0 1]);
    speed_plot = plot(avg_speed(:,1), 'LineWidth', 2); % Placeholder for speed
    hold off;

    nexttile;
    hold on;
    xlabel('Time');
    ylabel('Number of Interactions');
    title('Number of Interactions');
    xlim([0 num_steps]);
    ylim([0 15]);
    interaction_plot = plot(interaction(:,1), 'Color', [0.75 0.75 0.75], 'LineWidth', 1); % Placeholder for interaction
    hold on;
    avg_interaction_plot = plot(avg_num_interactions(:,1), 'r', 'LineWidth', 2); % Placeholder
    hold off;

    nexttile;
    hold on;
    title('Max Distance Traveled');
    xlabel('Time');
    ylabel('Distance');
    xlim([0 num_steps]);
    distance_plot = plot(max_distance(:,1), 'LineWidth', 2); % Placeholder
    hold off;

    nexttile;
    hold on;
    title('Average Speed Without Vibrations');
    xlabel('Time');
    ylabel('Average Speed');
    xlim([0 num_steps]);
    ylim([0 10]);
    speed_over_steps_plot = plot(avg_speed_over_steps(:,1), 'LineWidth', 2); % Placeholder
    hold off;

    % Simulate movement
    focal_pos_init = focal_pos(:, 3:4);
    for i = 1:num_steps
        friction_lipids = [0 0];
        for j = 1:num_lipids
            lipid_movement = pos_lipids(j, 3:4) - pos_lipids(j, 1:2);
            pos_lipids(j, 1:2) = pos_lipids(j, 3:4); % Store previous position
            pos_lipids(j, 3:4) = pos_lipids(j, 1:2) + 0.5*lipid_movement + randi([-100 100], 1, 2)/300;
            pos_lipids(j, :) = max(min(pos_lipids(j,:), 100), 1);
        end

        % Movement of focal particles (one for each particle size)
        for p = 1:num_particles
            num_interactions = 0;
            for k = 1:num_lipids
                distance = norm(pos_lipids(k, 3:4) - focal_pos(p, 3:4));
                lipid_direction = pos_lipids(k, 3:4) - pos_lipids(k, 1:2);
                focal_direction = (focal_pos(p, 3:4) - focal_pos(p, 1:2));
                cos_theta = dot(lipid_direction, focal_direction) / (norm(lipid_direction) * norm(focal_direction));
                angle = acosd(cos_theta);
                if angle < 90 && distance <= focal_sizes(p) + 1 && distance >= focal_sizes(p) - 1
                    colors(k, :) = [0, 1, 0];
                    interaction_vectors(k, 1:2) = pos_lipids(k, 3:4) - pos_lipids(k, 1:2);
                    num_interactions = num_interactions + 1;
                else
                    interaction_vectors(k, :) = [0 0];
                    colors(k, :) = [0, 0, 1];
                end
            end

            % Move focal particle based on lipid interaction
            force = -sum(interaction_vectors);
            direction = (focal_pos(p, 3:4) - focal_pos(p, 1:2));
            direction = direction / norm(direction);
            for xy = 3:4
                if focal_pos(p, xy) <= 1 || focal_pos(p, xy) >= 100
                    direction = -direction;
                end
            end
            focal_pos(p, 1:2) = focal_pos(p, 3:4);
            friction_coefficient = 1 / size(friction_lipids, 1);
            friction_coefficient = friction_coefficient - 1;
            focal_pos(p, 3:4) = focal_pos(p, 1:2) + (0.1 * force + 0.3 * direction) + friction_coefficient * (0.1 * force + 0.3 * direction) / 3;

            % Update particle-specific metrics
            speed(i, p) = norm(focal_pos(p, 3:4) - focal_pos(p, 1:2));
            avg_speed(i, p) = sum(speed(1:i, p)) / i;
            distance_traveled(i, p) = norm(focal_pos(p, 3:4) - focal_pos_init(p, :));
            max_distance(i, p) = max(distance_traveled(:, p));
            interaction(i, p) = num_interactions;
            avg_num_interactions(i, p) = sum(interaction(1:i, p)) / i;

            % Update plots
            set(lipid_scatter, 'XData', pos_lipids(:, 3), 'YData', pos_lipids(:, 4), 'CData', colors);
            set(focal_scatter(p), 'XData', focal_pos(p, 3), 'YData', focal_pos(p, 4));
            circle_x = focal_sizes(p) * cos(theta) + focal_pos(p, 3);
            circle_y = focal_sizes(p) * sin(theta) + focal_pos(p, 4);
            set(circle_plot(p), 'XData', circle_x, 'YData', circle_y);
        end

        % Update metrics plots for all particles
        set(speed_plot, 'YData', avg_speed(:, 1)); % You can plot separately for each size
        set(interaction_plot, 'YData', interaction(:, 1)); % Placeholder
        set(distance_plot, 'YData', max_distance(:, 1)); % Placeholder
        set(speed_over_steps_plot, 'YData', avg_speed_over_steps(:, 1)); % Placeholder
        drawnow;
    end
end

simulate_frap(2000, 2000, [2, 5, 20])