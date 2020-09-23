function out_table=data2output(data)

out_table = [];

for b = 1:length(data.block)
    bl = data.block(b);
    table_full = struct2table(bl.trial);
    table_reduced = table_full;
    table_reduced(:,'posSet') = [];
    for t = 1:length(bl.trial)
        posSet_t = table_full(t,'posSet');
        posSet_val = posSet_t.posSet{1,1};
    end
    
    out_table = [out_table; table_reduced];
end