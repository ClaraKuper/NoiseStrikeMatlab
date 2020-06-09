function pos_table = position2table(design)

    pos_table = [];
    
    for block = 1:length(design.b)
        for t = 1:length(design.b(block).trial)
            pos_t = design.b(block).trial(t).posSet; 
            pos_table = [pos_table pos_t];
        end
    end
    pos_table = table(pos_table.');
end