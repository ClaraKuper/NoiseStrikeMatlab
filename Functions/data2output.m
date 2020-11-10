function out_table=data2output(data)

out_table = [];

for b = 1:length(data.block)
    bl = data.block(b);
    table_full = struct2table(bl.trial);    
    out_table = [out_table; table_full];
end