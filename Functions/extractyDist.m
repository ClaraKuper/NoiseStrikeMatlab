function yDist_table = extractyDist(design)
  
  yDist_table = []
  
  for block = 1:length(design.b)
    bl = design.b(block);
    for t = 1:length(bl.trial)
        yDist = bl.trial(t).yDist;
        yDist_table = [yDist_table; yDist];;
    end
  end  
    
  #writetable(yDist_table, '../Data/ck02yDist_table.csv');
endfunction
//