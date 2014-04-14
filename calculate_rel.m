function [relative] = calculate_rel(inliers, width)
    if(mean(inliers) < width/2)
        relative = 1;
    else
        relative = 0;
    end
end