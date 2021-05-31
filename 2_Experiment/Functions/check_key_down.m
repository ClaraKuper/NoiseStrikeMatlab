function dur = check_key_down(down_code)
    key_down = true;
    start = 0;
    WaitSecs(3);
    sprintf('start counting')
    while key_down
        [~, secs, keyCode] = KbCheck;
        key_down = keyCode(down_code);
        if start == 0
            start = secs;
        end
    end
    stop = secs;
    dur = stop - start;
end

