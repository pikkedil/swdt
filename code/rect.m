function [x,y] = rect(n,nl,p,yd)
    %
    % Plots the coil side inside the slot.
    %
    X = [1,1,3,3,1];
    Y = [0,1,1,0,0]*0.5;
    offset = 1.75;
    
    if nl == 1
        x = X+(n-1)*4;
        y = Y-offset;
    else
        if yd == 1
            if p == 0
                x = [2,2,3,3,2]+(n-1)*4;
                y = Y-offset;
            else
                x = [1,1,2,2,1]+(n-1)*4;
                y = Y-offset;
            end
        else
            if p == 0
                x = X+(n-1)*4;
                y = Y*0.5-offset;
            else
                x = X+(n-1)*4;
                y = Y*0.5-offset+0.25;
            end
        end        
    end
end