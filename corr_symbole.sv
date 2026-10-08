module corr_symbole #(
    parameter int gBits        = 14,
    parameter int gFFT_length  = 256,
    parameter int gGard_length = 32
)(
    input  logic CLK,
    input  logic Enable,
    input  logic RSTn,
    input  logic signed [gBits-1:0] In_re,
    output logic [gBits + $clog2(gGard_length) - 1 : 0] Corr_symbole // Non signé
);

    // 1. Déclaration de la FIFO/Shift Register pour N_FFT
    logic signed [gBits-1:0] SF [0:gFFT_length-1];
    logic signed [gBits-1:0] s_in_retard;
    
    // 2. Déclaration des signaux de calcul instantané
    logic signed [gBits:0] diff;
    logic unsigned [gBits-1:0] s_int0;
    logic unsigned [gBits-1:0] s_int1;
    
    // 3. Déclaration des signaux d'accumulation
    logic unsigned [gBits + $clog2(gGard_length)-1:0] s_int2;
    logic unsigned [gBits + $clog2(gGard_length)-1:0] s_int3;
    
    // 4. Déclaration du Shift Register pour la Garde (my_delay_Gard)
    logic unsigned [gBits-1:0] delay_guard [0:gGard_length-1];

    // --- LOGIQUE COMBINATOIRE ---
    assign s_in_retard = SF[gFFT_length-1];
    assign diff        = In_re - s_in_retard;
    assign s_int0      = (diff < 0) ? -diff : diff[gBits-1:0]; // Valeur absolue
    
    assign s_int1      = delay_guard[gGard_length-1]; // Sortie de la garde
    assign s_int2      = s_int3 + s_int0 - s_int1;     // Opération Op.2
    
    assign Corr_symbole = s_int3;                      // Sortie liée à SR2 (s_int3)

    // --- LOGIQUE SÉQUENTIELLE ---

    // Shift Register 1 : FIFO N_FFT (SF)
    always_ff @(posedge CLK or negedge RSTn) begin
        if (!RSTn) begin
            for (int i = 0; i < gFFT_length; i++) begin
                SF[i] <= '0;
            end
        end else if (Enable) begin
            SF[0] <= In_re;
            for (int i = gFFT_length - 1; i > 0; i--) begin
                SF[i] <= SF[i-1];
            end
        end
    end

    // Shift Register 2 : Retard de Garde (my_delay_Gard)
    always_ff @(posedge CLK or negedge RSTn) begin
        if (!RSTn) begin
            for (int i = 0; i < gGard_length; i++) begin
                delay_guard[i] <= '0;
            end
        end else if (Enable) begin
            delay_guard[0] <= s_int0;
            for (int i = gGard_length - 1; i > 0; i--) begin
                delay_guard[i] <= delay_guard[i-1];
            end
        end
    end

    // Registre SR2 : Accumulateur Glissant
    always_ff @(posedge CLK or negedge RSTn) begin
        if (!RSTn) begin
            s_int3 <= '0;
        end else if (Enable) begin
            s_int3 <= s_int2;
        end
    end

endmodule
