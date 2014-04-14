function [output] = stitching_multiple_images(input1, input2, input3)
    input_rgb_1 = imread(input1, 'jpg');
    input_rgb_2 = imread(input2, 'jpg');
    input_rgb_3 = imread(input3, 'jpg');
    width1 = size(input_rgb_1, 2);
    width2 = size(input_rgb_2, 2);
    width3 = size(input_rgb_3, 2);
    [inlier_num_12, inliers_12] = calculate_inliers(input1, input2);
    [inlier_num_23, inliers_23] = calculate_inliers(input2, input3);
    [inlier_num_31, inliers_31] = calculate_inliers(input1, input3);
    
    if(inlier_num_12 > inlier_num_23 && inlier_num_31 > inlier_num_23)%input1 is mid
        relative2 = calculate_rel(inliers_12(:,2), width2);% 0:input2 is left of input1, 1: input2 is right of input1
        if(relative2 == 0)
            disp('order: 2-1-3');
            output = stitching_pair_of_images(input2, input1, 2);
            imwrite(output, 'output.jpg', 'jpg');
            output = stitching_pair_of_images(input3,'output.jpg', 2);
        else
            disp('order: 3-1-2');
            output = stitching_pair_of_images(input3, input1, 2);
            imwrite(output, 'output.jpg', 'jpg');
            output = stitching_pair_of_images(input2,'output.jpg', 2);
        end
    elseif(inlier_num_23 > inlier_num_12 && inlier_num_31 > inlier_num_12)%input3 is mid
        relative1 = calculate_rel(inliers_31(:,2), width1);% 0:input1 is left of input3, 1: input1 is right of input3
        if(relative1 == 0)
            disp('order: 1-3-2');
            output = stitching_pair_of_images(input1, input3, 2);
            imwrite(output, 'output.jpg', 'jpg');
            output = stitching_pair_of_images(input2,'output.jpg', 2);
        else
            disp('order: 2-3-1');
            output = stitching_pair_of_images(input2, input3, 2);
            imwrite(output, 'output.jpg', 'jpg');
            output = stitching_pair_of_images(input1,'output.jpg', 2);
        end
    elseif(inlier_num_23 > inlier_num_31 && inlier_num_12 > inlier_num_31)%input2 is mid
        relative3 = calculate_rel(inliers_23(:,2), width3);% 0:input3 is left of input2, 1: input3 is right of input2
        if(relative3 == 0)
            disp('order: 3-2-1');
            output = stitching_pair_of_images(input3, input2, 2);
            imwrite(output, 'output.jpg', 'jpg');
            output = stitching_pair_of_images(input1,'output.jpg', 2);
        else
            disp('order: 1-2-3');
            output = stitching_pair_of_images(input1, input2, 2);
            imwrite(output, 'output.jpg', 'jpg');
            output = stitching_pair_of_images(input3,'output.jpg', 2);
        end
    end
    figure();
    imshow(output);
end