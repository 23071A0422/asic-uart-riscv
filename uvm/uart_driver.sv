class uart_driver extends uvm_driver #(uart_transaction);
    `uvm_component_utils(uart_driver)
    virtual axi_if vif;
    
    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            // Drive AXI signals
            vif.wdata <= req.data;
            vif.wvalid <= 1;
            @(posedge vif.clk);
            vif.wvalid <= 0;
            seq_item_port.item_done();
        end
    endtask
endclass