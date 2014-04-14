

Usage:
> stitching_pair_of_images('images/pair/uttower_left', 'images/pair/uttower_right', 2);
> stitching_multiple_images('images/multiple/pier/1.jpg', 'images/multiple/pier/2.jpg', 'images/multiple/pier/3.jpg');
> stitching_multiple_images('images/multiple/ledge/1.jpg', 'images/multiple/ledge/2.jpg', 'images/multiple/ledge/3.jpg');
> stitching_multiple_images('images/multiple/hill/1.jpg', 'images/multiple/hill/2.jpg', 'images/multiple/hill/3.jpg');

Algorithms
1.  The two input images are fed into Harris corner detector, get two set of corners.
2.  Build descriptors for every corners with size = (2*neighbor_size+1)* (2*neighbor_size+1)
3.  Build distance matrix for Euclidean distances of every possible pair of two descriptors
4.  Find top 200 descriptor pairs with the smallest distance
5.  Matched descriptors fed into RANSAC



Order of input images is not important because I can automatically decide to order of stitching

1.  Decide which image is middle image 
1)  Compute number of inliers for every pair (inliers_12, inliers_23, inliers_31)
2)  The common input for the largest number of inliers and second largest number of inliers is the middle input. (inliers_12: 30, inliers_23: 25, inliers_31: 10, then input2 is the middle image)
2.  Decide which one is left, which one is right    
3)  Since we know which one is middle image, compute the avarege x-coordinate of inliers (say, middle image is input2, compute the x-coordinate of inliers_12)
4)  If the average x-coordinate is on the left part of the image, then it is the right image compare to the middle image and vice versa.
3.  After deciding left, middle and right images, first stitch the left image and middle image into an output image. Then, stitch the right image into final output image. By doing so, the middle image will have to distortion or affine effect, which I think is better for three images stitching.

