import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap

# Simulation parameters
num_lipids = 1000
num_steps = 2000
focal_size = 1

# Initialize variables
colors = np.zeros((num_lipids, 3))  # RGB color array
colors[:, 2] = 1  # Set initial color to blue (0, 0, 1)
interaction_vectors = np.zeros((num_lipids, 2))
speed = np.full(num_steps, np.nan)
avg_speed = np.full(num_steps, np.nan)
interaction = np.full(num_steps, np.nan)

# Initialize positions of the focal particle and lipids
focal_pos = np.zeros((1, 4))  # [prev_x, prev_y, curr_x, curr_y]
pos_lipids = np.zeros((num_lipids, 4))  # [prev_x, prev_y, curr_x, curr_y]

focal_pos[0, :2] = [50, 50]
focal_pos[0, 2:] = focal_pos[0, :2] + np.random.randint(-100, 101, size=2) / 1000

for i in range(num_lipids):
    pos_lipids[i, :2] = np.random.randint(0, 101, size=2)
    pos_lipids[i, 2:] = pos_lipids[i, :2]

# Set up the plot
fig, ax = plt.subplots(figsize=(8, 8))
lipid_scatter = ax.scatter(pos_lipids[:, 2], pos_lipids[:, 3], s=50, color=colors, edgecolor='k')
focal_scatter = ax.scatter(focal_pos[0, 2], focal_pos[0, 3], s=focal_size * 100, color='red')
theta = np.linspace(0, 2 * np.pi, 100)
circle_x = focal_size * np.cos(theta) + focal_pos[0, 2]
circle_y = focal_size * np.sin(theta) + focal_pos[0, 3]
circle_plot, = ax.plot(circle_x, circle_y, color='red')
ax.set_xlim(0, 100)
ax.set_ylim(0, 100)
ax.set_aspect('equal')

# Simulation loop
focal_pos_minus_100 = focal_pos[0, 2:].copy()
for i in range(num_steps):
    # Update lipid positions
    for j in range(num_lipids):
        lipid_movement = pos_lipids[j, 2:4] - pos_lipids[j, :2]
        pos_lipids[j, :2] = pos_lipids[j, 2:4]
        pos_lipids[j, 2:4] += 0.5 * lipid_movement + np.random.randint(-100, 101, size=2) / 300
        pos_lipids[j, :] = np.clip(pos_lipids[j, :], 1, 100)

    # Check for interactions
    num_interactions = 0
    for k in range(num_lipids):
        distance = np.linalg.norm(pos_lipids[k, 2:4] - focal_pos[0, 2:4])
        if focal_size - 1 <= distance <= focal_size + 1:
            colors[k] = [0, 1, 0]  # Green for interaction
            interaction_vectors[k] = pos_lipids[k, 2:4] - pos_lipids[k, :2]
            num_interactions += 1
        else:
            colors[k] = [0, 0, 1]  # Blue otherwise
            interaction_vectors[k] = [0, 0]

    # Move focal particle
    force = -np.sum(interaction_vectors, axis=0)
    direction = focal_pos[0, 2:4] - focal_pos[0, :2]
    direction = direction / np.linalg.norm(direction) if np.linalg.norm(direction) > 0 else np.zeros(2)
    for xy in range(2, 4):
        if focal_pos[0, xy] <= 1 or focal_pos[0, xy] >= 100:
            direction[xy - 2] = -direction[xy - 2]
    focal_pos[0, :2] = focal_pos[0, 2:4]
    focal_pos[0, 2:4] += 0.2 * force + 0.2 * direction

    # Update speed
    if (i + 1) % 100 == 0:
        distance_traveled = focal_pos[0, 2:4] - focal_pos_minus_100
        speed[i - 99:i + 1] = np.linalg.norm(distance_traveled) / 100
        focal_pos_minus_100 = focal_pos[0, 2:4]
    avg_speed[i] = np.nanmean(speed[:i + 1])
    interaction[i] = num_interactions

    # Update plots
    lipid_scatter.set_offsets(pos_lipids[:, 2:4])
    lipid_scatter.set_facecolor(colors)
    focal_scatter.set_offsets(focal_pos[0, 2:4])
    circle_x = focal_size * np.cos(theta) + focal_pos[0, 2]
    circle_y = focal_size * np.sin(theta) + focal_pos[0, 3]
    circle_plot.set_data(circle_x, circle_y)
    plt.pause(0.01)

plt.show()
