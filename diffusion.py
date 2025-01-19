import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle

# Simulation parameters
num_lipids = 1000
num_steps = 2000
focal_size = 1

# Initialize variables
colors = np.zeros((num_lipids, 3))  # RGB color array
colors[:, 2] = 1  # Set initial color to blue (0, 0, 1)
interaction_vectors = np.zeros((num_lipids, 2))
speed = np.zeros(num_steps)
avg_speed = np.zeros(num_steps)
interaction = np.zeros(num_steps)

# Initialize positions of the focal particle and lipids
focal_pos = np.zeros((1, 4))  # [prev_x, prev_y, curr_x, curr_y]
pos_lipids = np.zeros((num_lipids, 4))  # [prev_x, prev_y, curr_x, curr_y]

focal_pos[0, :2] = [50, 50]
focal_pos[0, 2:] = focal_pos[0, :2] + np.random.uniform(-0.1, 0.1, size=2)

for i in range(num_lipids):
    pos_lipids[i, :2] = np.random.uniform(0, 100, size=2)
    pos_lipids[i, 2:] = pos_lipids[i, :2]

# Set up the plot
fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(18, 6))

# Main scatter plot
ax1.set_xlim(0, 100)
ax1.set_ylim(0, 100)
ax1.set_aspect('equal')
ax1.set_title("Membrane Dynamics")
ax1.set_xlabel("X")
ax1.set_ylabel("Y")
lipid_scatter = ax1.scatter(pos_lipids[:, 2], pos_lipids[:, 3], s=50, color=colors, edgecolor='k')
focal_circle = Circle(focal_pos[0, 2:], focal_size, color='red')
ax1.add_patch(focal_circle)

# Speed plot
ax2.set_xlim(0, num_steps)
ax2.set_ylim(0, 0.3)
ax2.set_title("Average Speed Over Time")
ax2.set_xlabel("Time")
ax2.set_ylabel("Average Speed")
speed_plot, = ax2.plot([], [], 'b', linewidth=2)

# Interaction plot
ax3.set_xlim(0, num_steps)
ax3.set_ylim(0, num_lipids // 10)
ax3.set_title("Number of Interactions Over Time")
ax3.set_xlabel("Time")
ax3.set_ylabel("Number of Interactions")
interaction_plot, = ax3.plot([], [], 'g', linewidth=2)

# Simulation loop
for step in range(num_steps):
    # Update lipid positions
    for j in range(num_lipids):
        lipid_movement = pos_lipids[j, 2:4] - pos_lipids[j, :2]
        pos_lipids[j, :2] = pos_lipids[j, 2:4]
        pos_lipids[j, 2:4] += 0.5 * lipid_movement + np.random.uniform(-0.3, 0.3, size=2)
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
    distance_traveled = np.linalg.norm(focal_pos[0, 2:4] - focal_pos[0, :2])
    speed[step] = distance_traveled
    avg_speed[step] = np.mean(speed[:step + 1])
    interaction[step] = num_interactions

    # Update plots
    lipid_scatter.set_offsets(pos_lipids[:, 2:4])
    lipid_scatter.set_facecolor(colors)
    focal_circle.set_center(focal_pos[0, 2:4])
    speed_plot.set_data(range(step + 1), avg_speed[:step + 1])
    interaction_plot.set_data(range(step + 1), interaction[:step + 1])
    ax2.set_ylim(0, max(avg_speed) * 1.1)  # Adjust y-limits dynamically
    plt.pause(0.01)

plt.show()
