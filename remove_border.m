function [input] = remove_border(input)
    [height, width, tmp] = size(input);
    
        input(:, 1, 1) = input(:, 2, 1);
        input(:, 1, 2) = input(:, 2, 2);
        input(:, 1, 3) = input(:, 2, 3);
        
        input(:, width, 1) = input(:, width-1, 1);
        input(:, width, 2) = input(:, width-1, 2);
        input(:, width, 3) = input(:, width-1, 3);
        
        input(1, :, 1) = input(2, :, 1);
        input(1, :, 2) = input(2, :, 2);
        input(1, :, 3) = input(2, :, 3);
        
        input(height, :, 1) = input(height-1, :, 1);
        input(height, :, 2) = input(height-1, :, 2);
        input(height, :, 3) = input(height-1, :, 3);
end