function [vp_id] = getID(expCode)
    
    if nargin == 1
        FlushEvents('keyDown');

        ID      = input('\nType participant ID:  ','s');
        session = input('\nType session  number: ','s');
        while length(session) <= 1
            session = sprintf('0%i',session);
        end
        if ~ischar(expCode) || isempty(ID)
            vp_id   = sprintf('%s%i_%s','test',0,expCode);
        else
            vp_id   = sprintf('%s%s_%s', ID,session,expCode);
        end
        
    else
        fprintf(1, 'pass a string argument to call this function\n');
        vp_id=NaN;
    end
    
end