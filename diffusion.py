import numpy as np
import matplotlib as plt
import random
# initialize variables

num_lipids = 2000
num_steps = 2000
focal_size = 2

interaction_vectors = np.zeros((num_lipids,2))
speed = np.zeros((num_steps, 1))
avg_speed = np.full((num_steps,1),np.nan)
interaction = np.full((num_steps,1),np.nan)
distance_traveled = np.full((num_steps,1),np.nan)
max_distance = np.full((num_steps,1),np.nan)
avg_speed_over_steps = np.full((num_steps,1),np.nan)
speed_over_steps = np.full((num_steps,1),np.nan)
avg_num_interactions = np.full((num_steps,1),np.nan)

focal_pos = np.zeros((1,4))

pos_lipids = np.zeros((num_lipids,4))

# initialize positions of focal particle and lipids

focal_pos[0,:2] = [50, 50]
focal_pos[0, 2:4] = focal_pos[0,:2] + np.random.randint(-100,100,size = (1,2))/100

print(focal_pos)
