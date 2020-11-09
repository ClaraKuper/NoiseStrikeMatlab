function design_table = design2output(design)

design_table = [];
    
for b = 1:length(design.b)
    bl = design.b(b);
    table_full = struct2table(bl.trial);
    table_no_pos = table_full;
    table_no_pos(:,'posSet') = [];
    table_no_pos(:,'travelDur') = table(bl.travelDur);
    pos_table = [];
    for t = 1:length(bl.trial)
        pos_t = bl.trial(t).posSet; 
        pos_table = [pos_table pos_t];
    end
    pos_table = table(pos_table.');
    table_pos = [table_no_pos pos_table];
    design_table = [design_table; table_pos];    
end