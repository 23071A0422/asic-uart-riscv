class uart_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uart_scoreboard)
    function void check_match(logic [7:0] a, logic [7:0] b);
        if (a !== b) `uvm_error("FAIL", "Data Mismatch!")
        else `uvm_info("PASS", "Data Match", UVM_LOW)
    endfunction
endclass