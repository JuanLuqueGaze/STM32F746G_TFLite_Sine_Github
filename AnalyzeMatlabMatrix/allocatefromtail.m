function new_tail = allocatefromtail(tail, size, alignment)
    % Assume all is correctly aligned
    new_tail= round((tail - size)/alignment)*alignment;    
end
