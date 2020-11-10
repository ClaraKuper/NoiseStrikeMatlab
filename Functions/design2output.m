function design_table = design2output(design)

design_table = [];
    
for b = 1:length(design.b)
    bl = design.b(b);
    table_full = struct2table(bl.trial);
    table_full(:,'travelDur') = table(bl.travelDur);
    design_table = [design_table; table_full];    
end