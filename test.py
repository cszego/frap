import numpy as np
import matplotlib.pyplot as plt

# simulate membrane dynamics
# initialize variables

num_lipids = 1000
num_steps = 2000
colors = np.tile([0, 0, 1], (num_lipids, 1))
focal_size = 1

interaction_vectors = np.zeros((num_lipids, 2))
speed = np.full((num_steps,), np.nan)
avg_speed = np.full((num_steps,), np.nan)
interaction = np.full((num_steps,), np.nan)

# create matrix for particle of interest 
# store current and previous position

focal_pos = np.zeros((1, 4))

# create matrix for lipids
# store current and previous position
pos_lipids = np.zeros((num_lipids, 4))

# initialize positions of particle of interest and lipids

focal_pos[0, 0:2] = [50, 50]
focal_pos[0, 2:4] = focal_pos[0, 0:2] + np.random.randint(-100, 101, size=2) / 1000

for i in range(num_lipids):
    pos_lipids[i, 0:2] = np.random.randint(0, 101, size=2)
    pos_lipids[i, 2:4] = pos_lipids[i, 0:2]

# set up graphs

plt.figure()
plt.hold(True)
lipid_scatter = plt.scatter(pos_lipids[:, 2], pos_lipids[:, 3], s=50, c=colors, marker='o')
focal_scatter = plt.scatter(focal_pos[0, 2], focal_pos[0, 3], s=focal_size, c='red', marker='o')
theta = np.linspace(0, 2 * np.pi, 100)
circle_x = focal_size * np.cos(theta) + focal_pos[0, 2]
circle_y = focal_size * np.sin(theta) + focal_pos[0, 3]
circle_plot = plt.fill(circle_x, circle_y, color=[1, 0, 0], edgecolor='none')
plt.xlim([0, 100])
plt.ylim([0, 100])
plt.axis('equal')
plt.hold(False)

plt.figure()
layout = plt.subplot(1, 2, 1)
plt.hold(True)
plt.xlabel('time')
plt.ylabel('Average Speed (distance traveled per simulation time step)')
plt.xlim([0, num_steps])
plt.ylim([0, 1])
speed_plot = plt.plot(avg_speed, 'b', linewidth=2)
plt.hold(False)

layout = plt.subplot(1, 2, 2)
plt.hold(True)
plt.xlabel('time')
plt.ylabel('Number of interaction_vectors')
interaction_plot = plt.plot(interaction)
plt.hold(False)


focal_pos_minus_100 = focal_pos[0, 2:4]
for i in range(num_steps):
    for j in range(num_lipids):
        lipid_movement = pos_lipids[j, 2:4] - pos_lipids[j, 0:2]
        pos_lipids[j, 0:2] = pos_lipids[j, 2:4]  # store previous position
        pos_lipids[j, 2:4] = pos_lipids[j, 0:2] + 0.5 * lipid_movement + np.random.randint(-100, 101, size=2) / 300
        pos_lipids[j, :] = np.clip(pos_lipids[j, :], 1, 100)

    # movement of focal particle
    # check for touching lipids
    num_interactions = 0
    for k in range(num_lipids):
        distance = np.linalg.norm(pos_lipids[k, 2:4] - focal_pos[0, 2:4])
        lipid_direction = pos_lipids[k, 2:4] - pos_lipids[k, 0:2]
        focal_direction = (focal_pos[0, 2:4] - focal_pos[0, 0:2])
        cos_theta = np.dot(lipid_direction, focal_direction) / (np.linalg.norm(lipid_direction) * np.linalg.norm(focal_direction))
        angle = np.degrees(np.arccos(cos_theta))

        if focal_size - 1 <= distance <= focal_size + 1:
            colors[k, :] = [0, 1, 0]
            interaction_vectors[k, 0:2] = pos_lipids[k, 2:4] - pos_lipids[k, 0:2]
            num_interactions += 1
        else:
            interaction_vectors[k, :] = [0, 0]
            colors[k, :] = [0, 0, 1]

    # move focal particle based on lipid movement
    force = -np.sum(interaction_vectors, axis=0)
    direction = (focal_pos[0, 2:4] - focal_pos[0, 0:2])
    direction = direction / np.linalg.norm(direction)
    for xy in range(2, 4):
        if focal_pos[0, xy] <= 1 or focal_pos[0, xy] >= 100:
            direction = -direction

    focal_pos[0, 0:2] = focal_pos[0, 2:4]
    focal_pos[0, 2:4] = focal_pos[0, 0:2] + 0.2 * force + 0.2 * direction

    if (i % 100) == 0:  # update speed after 100 steps
        distance_traveled = focal_pos[0, 2:4] - focal_pos_minus_100
        speed[i:i + 100, 0] = np.full((100,), np.linalg.norm(distance_traveled) / 100)
        focal_pos_minus_100 = focal_pos[0, 2:4]

    avg_speed[i, 0] = np.sum(speed[0:i + 1, 0]) / (i + 1)
    interaction[i, 0] = num_interactions

    lipid_scatter.set_offsets(pos_lipids[:, 2:4])
    lipid_scatter.set_array(colors)
    focal_scatter.set_offsets(focal_pos[0, 2:4])
    
    circle_x = focal_size * np.cos(theta) + focal_pos[0, 2]
    circle_y = focal_size * np.sin(theta) + focal_pos[0, 3]
    circle_plot.set_data(circle_x, circle_y)
    interaction_plot.set_ydata(interaction)
    speed_plot.set_ydata(avg_speed)
    
    plt.draw()
    plt.pause(0.001)