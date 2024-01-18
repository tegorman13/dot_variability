Data variable order, from left to right:

1. Phase type (1 Training, 2 Test)
2. Block number (1-10 Training, 1 Test)
3. Trial number (1-27 Training, 1-84 Test)
4. Pattern type (1 = old*, 2 = prototype, 3 = new low, 4 = new medium, 5 = new high)
5. Category number (1-3)
6. Pattern token* (1-90 old, 1 prototype, 1-3 new low, 1-6 new med, 1-9 new high)
7. distortion level (1 = low, 2 = med, 3 = high)
8. Category response (1-3)
9. Correct/Incorrect (0 = Incorrect, 1 = Correct)
10. Reaction time (in milliseconds)
11-28. Coordinates of nine dots* (-25 through 24)

*Pattern type: All training patterns (including old patterns in the test phase) are coded as 1 regardless of the distortion levels
*Pattern token: index of unique tokens for each category of each type of pattern. 
*Coordinates of nine dots: every two columns represent the x and y coordinates of a dot on a 50 x 50 grid

The conditions are indicated in the file names: 
file names with "cond1", "cond2", "cond3" and "cond4" contain data from the low, medium, high and mixed-distortion training conditions respectively. 