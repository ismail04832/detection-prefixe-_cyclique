`timescale 1ns/1ps

module tb_corr_symbole;

    parameter int gBits        = 14;
    parameter int gFFT_length  = 256;
    parameter int gGard_length = 32;
    parameter real CLK_PERIOD  = 10.0;

    logic CLK;
    logic Enable;
    logic RSTn;
    logic signed [gBits-1:0] In_re;
    logic [gBits + $clog2(gGard_length) - 1 : 0] Corr_symbole;

    corr_symbole #(
        .gBits(gBits),
        .gFFT_length(gFFT_length),
        .gGard_length(gGard_length)
    ) dut (
        .CLK(CLK),
        .Enable(Enable),
        .RSTn(RSTn),
        .In_re(In_re),
        .Corr_symbole(Corr_symbole)
    );

    // Génération d'horloge
    initial begin
        CLK = 0;
        forever #(CLK_PERIOD / 2) CLK = ~CLK;
    end

    // Stimulus et lecture fichier
    initial begin
        int file_in;
        int status;
        logic signed [gBits-1:0] sample_in;

        // Configuration pour générer le chronogramme sur EDA Playground
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_corr_symbole);

        RSTn   = 0;
        Enable = 0;
        In_re  = 0;

        file_in = $fopen("in_re5_chan2.txt", "r");
        if (file_in == 0) begin
            $display("ERREUR : Fichier in_re5_chan2.txt introuvable !");
            $finish;
        end

        #(CLK_PERIOD * 5);
        RSTn = 1;
        #(CLK_PERIOD * 2);
        Enable = 1;

        while (!$feof(file_in)) begin
            @(posedge CLK);
            status = $fscanf(file_in, "%d\n", sample_in);
            if (status == 1) begin
                In_re <= sample_in;
            end
        end

        #(CLK_PERIOD * 100);
        $fclose(file_in);
        $display("Simulation terminée !");
        $finish;
    end

endmodule
