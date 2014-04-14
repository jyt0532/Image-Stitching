function [output] = stiching_pair_of_images(input1, input2, threshold)
    %input1 = 'uttower_left.jpg';
    %input2= 'uttower_right.jpg';
    neighbor_size = 5; % (2x+1)*(2x+1) pixels total
    top = 200;
    iterations = 200;

    input_rgb_left = imread(input1, 'jpg');
    input_rgb_left = remove_border(input_rgb_left);
    input_rgb_right = imread(input2, 'jpg');
    input_rgb_right = remove_border(input_rgb_right);
    input_left = rgb2gray(input_rgb_left);
    input_right = rgb2gray(input_rgb_right);
    input_left = im2double(input_left);
    input_right = im2double(input_right);
    [left_height, left_width] = size(input_left);
    [right_height, right_width] = size(input_right);

    [output_left, row_left, col_left] = harris(input_left, 3, 0.05, 3, 1); 
    [output_right, row_right, col_right] = harris(input_right, 3, 0.05, 3, 1);

    [num_of_corners_left, tmp] = size(row_left);
    [num_of_corners_right, tmp] = size(row_right);

    new_row_left = [];
    new_col_left = [];
    for i = 1:num_of_corners_left
        if((row_left(i) > neighbor_size) && (col_left(i) > neighbor_size) && (row_left(i) < left_height-neighbor_size-1) && (col_left(i) < left_width-neighbor_size-1))
            new_row_left = [new_row_left; row_left(i)];
            new_col_left = [new_col_left; col_left(i)];
        end
    end
    row_left = new_row_left;
    col_left = new_col_left;

    new_row_right = [];
    new_col_right = [];
    for i = 1:num_of_corners_right
        if((row_right(i) > neighbor_size) && (col_right(i) > neighbor_size) && (row_right(i) < right_height-neighbor_size-1) && (col_right(i) < right_width-neighbor_size-1))
            new_row_right = [new_row_right; row_right(i)];
            new_col_right = [new_col_right; col_right(i)];
        end
    end
    row_right = new_row_right;
    col_right = new_col_right;
    [number_of_corners_left, tmp] = size(row_left);
    [number_of_corners_right, tmp] = size(row_right);

    descriptor_left = zeros(number_of_corners_left, (2*neighbor_size+1)^2);
    descriptor_right = zeros(number_of_corners_right, (2*neighbor_size+1)^2);

    for i = 1:number_of_corners_left
        descriptor_left(i,:) = reshape(input_left(row_left(i)-neighbor_size:row_left(i)+neighbor_size, col_left(i)-neighbor_size:col_left(i)+neighbor_size), 1, (2*neighbor_size+1)^2);
        %descriptor_left(i,:) = zscore(descriptor_left(i,:));
    end
    
    for i = 1:number_of_corners_right
        descriptor_right(i,:) = reshape(input_right(row_right(i)-neighbor_size:row_right(i)+neighbor_size, col_right(i)-neighbor_size:col_right(i)+neighbor_size), 1, (2*neighbor_size+1)^2);
        %descriptor_right(i,:) = zscore(descriptor_right(i,:));
    end

    distance = zeros(number_of_corners_left, number_of_corners_right);

    for i = 1:number_of_corners_left
        for j = 1:number_of_corners_right
            distance(i, j) = dist2(descriptor_left(i, :), descriptor_right(j, :));
            %distance(i, j) = normalized_corr(descriptor_left(i, :), descriptor_right(j, :));
        end
    end

    top = min([top, num_of_corners_left, num_of_corners_right]);
    matches = [];%index_left, row_left, col_left, index_right, row_right, col_right, distance
    
    for i = 1:top
        [r, c] = find(distance == min(min(distance)));
        if(length(r) == 1)
            matches = [matches; r, row_left(r), col_left(r), c, row_right(c), col_right(c), min(min(distance))];
            distance(r,:) = 100;
            distance(:,c) = 100;
        end
    end
    %{
    
    for i = 1:top
        [r, c] = find(distance == max(max(distance)));
        if(length(r) == 1)
            matches = [matches; r, row_left(r), col_left(r), c, row_right(c), col_right(c), min(min(distance))];
            distance(r,:) = -2;
            distance(:,c) = -2;
        end
    end
    %}
    top = size(matches, 1);
    current_match_num = 4;
    n = 1;
    while(n < iterations)
        if current_match_num == 4
            inliers = randsample(top, current_match_num);
        end
        A = [];
        for i = 1:current_match_num
            current_match = matches(inliers(i), :);
            xT = [current_match(3), current_match(2), 1];
            A = [A; xT*0, xT, xT*(-current_match(5))];
            A = [A; xT, xT*0, xT*(-current_match(6))];
        end
        [U, S, V] = svd(A);
        H = V(:, end);
        H1 = reshape(H, 3, 3);
        num_of_inliers = 0;
        inliers = [];
        residual = [];
        for i = 1:top
            X =  H1'* [matches(i, 3); matches(i, 2); 1];
            x = X(1)/X(3);
            y = X(2)/X(3);
            if(dist2([x,y], [matches(i, 6),matches(i, 5)]) < threshold)
                inliers = [inliers; i];
                residual = [residual; dist2([x,y], [matches(i, 6),matches(i, 5)])];
                num_of_inliers = num_of_inliers+1;
            end
        end
        %num_of_inliers
        if(num_of_inliers < 10)
            current_match_num = 4;
        else
           current_match_num = num_of_inliers;
           n = n+1;
        end
    end
    
    mean_of_residual = mean(residual);
    
    
    final_matches = [];
    for i = 1:num_of_inliers
        final_matches = [final_matches; matches(inliers(i), :)];
    end
    
    figure();
    imshow(input_left);
    hold on;
    scatter(matches(:, 3),matches(:, 2), 'r');
    scatter(final_matches(:, 3),final_matches(:, 2), 'b', '*');
    figure();
    imshow(input_right);
    hold on;
    scatter(matches(:, 6),matches(:, 5), 'r');
    scatter(final_matches(:, 6),final_matches(:, 5), 'b', '*');
 
    T = maketform('projective', H1);
    [img_left,xdata_range,ydata_range]=imtransform(input_rgb_left,T, 'nearest');
    xdataout=[min(1,xdata_range(1)) max(size(input_rgb_right,2),xdata_range(2))];
    ydataout=[min(1,ydata_range(1)) max(size(input_rgb_right,1),ydata_range(2))];
    img_left=imtransform(input_rgb_left,T,'nearest','XData',xdataout,'YData',ydataout);
    img_right=imtransform(input_rgb_right,maketform('affine',eye(3)),'nearest','XData',xdataout,'YData',ydataout);
    [new_height, new_width, tmp] = size(img_left);
    output = img_left;
    for i = 1:new_height*new_width*tmp
            if(output(i) == 0)
                output(i) = img_right(i);
            elseif(output(i) ~= 0 && img_right(i) ~= 0)
                output(i) = img_left(i)/2 + img_right(i)/2;
            end
    end
  
    figure();
    imshow(output);
    figure();
    showMatchedFeatures(input_rgb_left, input_rgb_right, final_matches(:, 3:-1:2), final_matches(:, 6:-1:5),'montage', 'PlotOptions', {'b*', 'b*', 'r-'});
    
    %{
    figure();
   output1 = output;
   output1(:,:,1) = ordfilt2(output(:,:,1),5,true(3));
   output1(:,:,2) = ordfilt2(output(:,:,2),5,true(3));
   output1(:,:,3) = ordfilt2(output(:,:,3),5,true(3));
   imshow(output1);
   figure; showMatchedFeatures(I1,I2,matched_pts1,matched_pts2,'montage');
%}
    
end