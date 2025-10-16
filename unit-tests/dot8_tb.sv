/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 4 - Simplified Testbench for 8-Lane Dot Product */
/***************************************************/

`timescale 1ns / 1ps

module dot8_tb();

    // Parameters
    parameter IWIDTH = 8;
    parameter OWIDTH = 32;
    parameter CLK_PERIOD = 10; // 10ns clock period (100MHz)
    parameter PIPELINE_DEPTH = 4; // 4-stage pipeline
    
    // Testbench signals
    logic clk;
    logic rst;
    logic signed [8*IWIDTH-1:0] vec0;
    logic signed [8*IWIDTH-1:0] vec1;
    logic ivalid;
    logic signed [OWIDTH-1:0] result;
    logic ovalid;
    
    // Test tracking
    integer test_count;
    integer error_count;
    integer cycle_count;
    
    // Expected results array (simpler than queue)
    logic signed [OWIDTH-1:0] expected_results [0:19]; // Enough for all tests
    integer expected_index;
    integer result_index;
    
    // Test cases
    logic signed [IWIDTH-1:0] test_vec0 [0:7];
    logic signed [IWIDTH-1:0] test_vec1 [0:7];

    // DUT instantiation
    dot8 #(
        .IWIDTH(IWIDTH),
        .OWIDTH(OWIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .vec0(vec0),
        .vec1(vec1),
        .ivalid(ivalid),
        .result(result),
        .ovalid(ovalid)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Helper function to calculate expected dot product
    function logic signed [OWIDTH-1:0] calc_dot_product(
        input logic signed [IWIDTH-1:0] a [0:7],
        input logic signed [IWIDTH-1:0] b [0:7]
    );
        logic signed [OWIDTH-1:0] sum;
        sum = 0;
        for (int i = 0; i < 8; i++) begin
            sum += a[i] * b[i];
        end
        return sum;
    endfunction
    
    // Helper function to pack vector array into concatenated format
    function logic signed [8*IWIDTH-1:0] pack_vector(
        input logic signed [IWIDTH-1:0] vec [0:7]
    );
        return {vec[0], vec[1], vec[2], vec[3], vec[4], vec[5], vec[6], vec[7]};
    endfunction
    
    // Task to apply test vectors and store expected result
    task apply_test_vectors(
        input logic signed [IWIDTH-1:0] a [0:7],
        input logic signed [IWIDTH-1:0] b [0:7],
        input string test_name
    );
        logic signed [OWIDTH-1:0] expected;
        
        // Calculate expected result
        expected = calc_dot_product(a, b);
        expected_results[expected_index] = expected;
        expected_index++;
        
        // Apply inputs
        vec0 = pack_vector(a);
        vec1 = pack_vector(b);
        ivalid = 1;
        
        $display("Test %0d: %s", test_count, test_name);
        $display("  vec0 = [%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d]", 
                 a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]);
        $display("  vec1 = [%0d, %0d, %0d, %0d, %0d, %0d, %0d, %0d]", 
                 b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7]);
        $display("  Expected result = %0d", expected);
        
        test_count++;
        
        @(posedge clk);
        ivalid = 0; // Single cycle pulse
    endtask
    
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
        vec0 = 0;
        vec1 = 0;
        ivalid = 0;
        
        $display("=== Starting Dot Product Module Testbench ===");
        $display("IWIDTH = %0d, OWIDTH = %0d", IWIDTH, OWIDTH);
        
        // Reset sequence
        rst = 1;
        repeat(3) @(posedge clk);
        rst = 0;
        $display("Reset complete");
        

        
        // Test 1: All zeros
        test_vec0 = '{0, 0, 0, 0, 0, 0, 0, 0};
        test_vec1 = '{0, 0, 0, 0, 0, 0, 0, 0};
        apply_test_vectors(test_vec0, test_vec1, "All zeros");
        
        // Test 2: All ones
        test_vec0 = '{1, 1, 1, 1, 1, 1, 1, 1};
        test_vec1 = '{1, 1, 1, 1, 1, 1, 1, 1};
        apply_test_vectors(test_vec0, test_vec1, "All ones");
        
        // Test 3: Identity test (orthogonal vectors)
        test_vec0 = '{1, 0, 0, 0, 0, 0, 0, 0};
        test_vec1 = '{0, 1, 0, 0, 0, 0, 0, 0};
        apply_test_vectors(test_vec0, test_vec1, "Orthogonal vectors");
        
        // Test 4: Maximum positive values
        test_vec0 = '{127, 127, 127, 127, 127, 127, 127, 127};
        test_vec1 = '{127, 127, 127, 127, 127, 127, 127, 127};
        apply_test_vectors(test_vec0, test_vec1, "Maximum positive");
        
        // Test 5: Maximum negative values
        test_vec0 = '{-128, -128, -128, -128, -128, -128, -128, -128};
        test_vec1 = '{-128, -128, -128, -128, -128, -128, -128, -128};
        apply_test_vectors(test_vec0, test_vec1, "Maximum negative");
        
        // Test 6: Mixed positive/negative
        test_vec0 = '{127, -128, 64, -32, 16, -8, 4, -2};
        test_vec1 = '{1, 1, 1, 1, 1, 1, 1, 1};
        apply_test_vectors(test_vec0, test_vec1, "Mixed signs");
        
        // Test 7: Sequential values
        test_vec0 = '{1, 2, 3, 4, 5, 6, 7, 8};
        test_vec1 = '{8, 7, 6, 5, 4, 3, 2, 1};
        apply_test_vectors(test_vec0, test_vec1, "Sequential values");
        
        // Test 8: Simple computation check
        test_vec0 = '{2, 3, 4, 5, 6, 7, 8, 9};
        test_vec1 = '{1, 1, 1, 1, 1, 1, 1, 1};
        apply_test_vectors(test_vec0, test_vec1, "Simple sum check");
        
        // Test 9: Pipeline test 1
        test_vec0 = '{0, 1, 2, 3, 4, 5, 6, 7};
        test_vec1 = '{1, 2, 3, 4, 5, 6, 7, 8};
        apply_test_vectors(test_vec0, test_vec1, "Pipeline test 1");
        
        // Test 10: Pipeline test 2
        test_vec0 = '{1, 2, 3, 4, 5, 6, 7, 8};
        test_vec1 = '{2, 4, 6, 8, 10, 12, 14, 16};
        apply_test_vectors(test_vec0, test_vec1, "Pipeline test 2");
        
        // Test 11: Pipeline test 3
        test_vec0 = '{2, 3, 4, 5, 6, 7, 8, 9};
        test_vec1 = '{3, 6, 9, 12, 15, 18, 21, 24};
        apply_test_vectors(test_vec0, test_vec1, "Pipeline test 3");
        
        // Wait for all results to propagate through pipeline
        repeat(15) @(posedge clk);
        
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
        $dumpfile("dot8_tb.vcd");
        $dumpvars(0, dot8_tb);
    end
    
endmodule
