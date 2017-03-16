function [x,y] = slot(n)
    %
    % Return the coordinates for slot number n. Each slot has
    % 4 parts, i.e. half-tooth, slot and half-tooth. 
    % 
    % --|  |--
    %   |  |
    %   |  |
    %   |--|
    % 0 1  3 4
    %
    %
    offset = 1.75;
    x = [0,1,1,3,3,4]+(n-1)*4;
    y = [1.05,1.05,0,0,1.05,1.05]*0.5-offset;
end