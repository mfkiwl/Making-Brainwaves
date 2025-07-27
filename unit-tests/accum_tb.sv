`timescale 1ns / 1ps

module accum_tb();

    // Parameters
    parameter DATAW = 19;
    parameter ACCUMW = 32;
    parameter CLK_PERIOD = 10; // 10ns clock period (100MHz)
    
    // Testbench signals
    logic clk;
    logic rst;
    logic signed [DATAW-1:0] data;
    logic ivalid;
    logic first;
    logic last;
    logic signed [ACCUMW-1:0] result;
    logic ovalid;
    
    // Test tracking
    integer test_count;
    integer error_count;
    integer cycle_count;
    integer result_count;
    
    // Expected results array
    logic signed [ACCUMW-1:0] expected_results [0:19];
    integer expected_index;
    integer result_index;
    
    // DUT instantiation
    accum #(
        .DATAW(DATAW),
        .ACCUMW(ACCUMW)
    ) dut (
        .clk(clk),
        .rst(rst),
        .data(data),
        .ivalid(ivalid),
        .first(first),
        .last(last),
        .result(result),
        .ovalid(ovalid)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Check results when they come out
    always @(posedge clk) begin
        cycle_count++;
        
        if (ovalid && !rst) begin
            if (result_index < expected_index) begin
                if (result === expected_results[result_index]) begin
                    $display("  ? PASS: Test %0d result = %0d (cycle %0d)", 
                             result_index, result, cycle_count);
                end else begin
                    $display("  ? FAIL: Test %0d expected %0d, got %0d (cycle %0d)", 
                             result_index, expected_results[result_index], result, cycle_count);
                    error_count++;
                end
                result_index++;
            end else begin
                $display("  ? FAIL: Unexpected result %0d (cycle %0d)", result, cycle_count);
                error_count++;
            end
        end
    end
    
    // Main test sequence
    initial begin
        // Initialize
        test_count = 0;
        error_count = 0;
        cycle_count = 0;
        expected_index = 0;
        result_index = 0;
        data = 0;
        ivalid = 0;
        first = 0;
        last = 0;
        
        $display("=== Starting Accumulator Module Testbench ===");
        $display("DATAW = %0d, ACCUMW = %0d", DATAW, ACCUMW);
        
        // Reset sequence
        rst = 1;
        repeat(3) @(posedge clk);
        rst = 0;
        $display("Reset complete");
        
        // Test 0: Single element
        $display("Test %0d: Single element", test_count);
        expected_results[expected_index] = 100;
        expected_index++;
        data = 100;
        ivalid = 1;
        first = 1;
        last = 1;
        @(posedge clk);
        data = 0;
        ivalid = 0;
        first = 0;
        last = 0;
        test_count++;
        
        // Test 1: Two elements
        $display("Test %0d: Two elements (50 + 75)", test_count);
        expected_results[expected_index] = 125;
        expected_index++;
        // First element
        data = 50;
        ivalid = 1;
        first = 1;
        last = 0;
        @(posedge clk);
        // Second element
        data = 75;
        ivalid = 1;
        first = 0;
        last = 1;
        @(posedge clk);
        data = 0;
        ivalid = 0;
        first = 0;
        last = 0;
        test_count++;
        
        // Test 2: Three elements
        $display("Test %0d: Three elements (10 + 20 + 30)", test_count);
        expected_results[expected_index] = 60;
        expected_index++;
        // First element
        data = 10;
        ivalid = 1;
        first = 1;
        last = 0;
        @(posedge clk);
        // Second element
        data = 20;
        ivalid = 1;
        first = 0;
        last = 0;
        @(posedge clk);
        // Third element
        data = 30;
        ivalid = 1;
        first = 0;
        last = 1;
        @(posedge clk);
        data = 0;
        ivalid = 0;
        first = 0;
        last = 0;
        test_count++;
        
        // Test 3: Mixed signs
        $display("Test %0d: Mixed signs (100 - 50 + 25 - 10)", test_count);
        expected_results[expected_index] = 65;
        expected_index++;
        // First element
        data = 100;
        ivalid = 1;
        first = 1;
        last = 0;
        @(posedge clk);
        // Second element
        data = -50;
        ivalid = 1;
        first = 0;
        last = 0;
        @(posedge clk);
        // Third element
        data = 25;
        ivalid = 1;
        first = 0;
        last = 0;
        @(posedge clk);
        // Fourth element
        data = -10;
        ivalid = 1;
        first = 0;
        last = 1;
        @(posedge clk);
        data = 0;
        ivalid = 0;
        first = 0;
        last = 0;
        test_count++;
        
        // Test 4: All negative
        $display("Test %0d: All negative (-10 - 20 - 30)", test_count);
        expected_results[expected_index] = -60;
        expected_index++;
        // First element
        data = -10;
        ivalid = 1;
        first = 1;
        last = 0;
        @(posedge clk);
        // Second element
        data = -20;
        ivalid = 1;
        first = 0;
        last = 0;
        @(posedge clk);
        // Third element
        data = -30;
        ivalid = 1;
        first = 0;
        last = 1;
        @(posedge clk);
        data = 0;
        ivalid = 0;
        first = 0;
        last = 0;
        test_count++;
        
        // Test 5: All zeros
        $display("Test %0d: All zeros (0 + 0 + 0)", test_count);
        expected_results[expected_index] = 0;
        expected_index++;
        // First element
        data = 0;
        ivalid = 1;
        first = 1;
        last = 0;
        @(posedge clk);
        // Second element
        data = 0;
        ivalid = 1;
        first = 0;
        last = 0;
        @(posedge clk);
        // Third element
        data = 0;
        ivalid = 1;
        first = 0;
        last = 1;
        @(posedge clk);
        data = 0;
        ivalid = 0;
        first = 0;
        last = 0;
        test_count++;
        
        // Test 6: Large values
        $display("Test %0d: Large values (32767 - 32768 + 16384)", test_count);
        expected_results[expected_index] = 16383;
        expected_index++;
        // First element
        data = 32767;
        ivalid = 1;
        first = 1;
        last = 0;
        @(posedge clk);
        // Second element
        data = -32768;
        ivalid = 1;
        first = 0;
        last = 0;
        @(posedge clk);
        // Third element
        data = 16384;
        ivalid = 1;
        first = 0;
        last = 1;
        @(posedge clk);
        data = 0;
        ivalid = 0;
        first = 0;
        last = 0;
        test_count++;
        
        // Test 7: Back-to-back sequences
        $display("Test %0d: Back-to-back sequence 1 (1 + 2 + 3)", test_count);
        expected_results[expected_index] = 6;
        expected_index++;
        // First sequence
        data = 1;
        ivalid = 1;
        first = 1;
        last = 0;
        @(posedge clk);
        data = 2;
        ivalid = 1;
        first = 0;
        last = 0;
        @(posedge clk);
        data = 3;
        ivalid = 1;
        first = 0;
        last = 1;
        @(posedge clk);
        test_count++;
        
        $display("Test %0d: Back-to-back sequence 2 (10 + 20)", test_count);
        expected_results[expected_index] = 30;
        expected_index++;
        // Second sequence (immediately after first)
        data = 10;
        ivalid = 1;
        first = 1;
        last = 0;
        @(posedge clk);
        data = 20;
        ivalid = 1;
        first = 0;
        last = 1;
        @(posedge clk);
        data = 0;
        ivalid = 0;
        first = 0;
        last = 0;
        test_count++;
        
        // Test 8: Invalid data test (should be ignored)
        $display("Test %0d: With invalid data (5 + invalid + 15)", test_count);
        expected_results[expected_index] = 20;
        expected_index++;
        // First element
        data = 5;
        ivalid = 1;
        first = 1;
        last = 0;
        @(posedge clk);
        // Invalid data (should be ignored)
        data = 999;
        ivalid = 0;
        first = 0;
        last = 0;
        @(posedge clk);
        // Second element
        data = 15;
        ivalid = 1;
        first = 0;
        last = 1;
        @(posedge clk);
        data = 0;
        ivalid = 0;
        first = 0;
        last = 0;
        test_count++;
        
        // Wait for all results to propagate
        repeat(10) @(posedge clk);
        
        // Final summary
        $display("\n=== Test Summary ===");
        $display("Total tests: %0d", test_count);
        $display("Results received: %0d", result_index);
        $display("Errors: %0d", error_count);
        
        if (error_count == 0 && result_index == expected_index) begin
            $display("? ALL TESTS PASSED!");
        end else begin
            if (error_count > 0) $display("? %0d TESTS FAILED!", error_count);
            if (result_index != expected_index) $display("? Missing results: expected %0d, got %0d", expected_index, result_index);
        end
        
        $display("Simulation complete at cycle %0d", cycle_count);
        $finish;
    end
    
    // Optional: Generate waveform dump
    initial begin
        $dumpfile("accum_tb.vcd");
        $dumpvars(0, accum_tb);
    end
    
endmodule
