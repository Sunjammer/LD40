1. Seed algo with X initial points
2. K-means the points, find a cluster
3. Find the convex hull of that cluster, making a polygon
4. Remove those points from data set
5. Go back to step 2
6. Once fully converged, choose a polygon, fill w/ points & go back to step 2