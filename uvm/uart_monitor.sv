class uart_monitor extends uvm_monitor;
    `uvm_component_utils(uart_monitor)
    virtual uart_if vif;
    uvm_analysis_port #(logic [7:0]) ap;

    task run_phase(uvm_phase phase);
        forever begin
            @(negedge vif.tx); // Start bit
            # (BIT_PERIOD * 1.5);
            // Sample 8 bits...
            ap.write(sampled_data);
        end
    endtask
endclass