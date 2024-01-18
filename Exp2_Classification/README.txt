Data variable order, from left to right:

1. Phase type (1 = Training, 2 = Transfer)
2. Block number (1-15 training, 1 transfer)
3. Trial number (1-15 training, 1-63 transfer)
4. Pattern type (1 = old medium, 2 = prototype, 3 = new low, 4 = new medium, 5 = new high)
5. Category number (1-3)
6. Pattern token* 
7. Category response (1-3)
8. Correct/Incorrect (0 = Incorrect, 1 = Correct)
9. Reaction time (in milliseconds)
10-27.Coordinates of nine dots* (-25 through 24)

*Pattern token: index of unique tokens for each category of each type of pattern. The numbering of old medium patterns differs for the two conditions.
*Coordinates of nine dots: every two columns represent the x and y coordinates of a dot on a 50 x 50 grid

file names starting with "polyrep" contain data from repeating condtion.
file names starting with "polynrep" contain data from non-repeating condtion.

