clear;
clc;
B = 1000;
p = 0.5;
% generate bit sequence
data_bits = randsrc(1, B, [0 1]);

% ------------------ Transmitter
% Repetition encoder 
r = 1/5; 
L = 1/r;
encoded_bits_rep = repitition_encoder(data_bits, L);

% Convolutional encoder
G = [1 1 1; 1 0 1];    % generator matrix
encoded_bits_conv = conv_encoder(data_bits, G);

% Polar encoder
N = 1024;    % block length after adding redundancy (output length)
encoded_bits_polar = polar_encoder(data_bits, N);

% Plot BER for different values of p
p_vect = 0:0.1:0.5;              
BER_rep = zeros(size(p_vect));
BER_conv = zeros(size(p_vect));
BER_polar = zeros(size(p_vect));

for p_ind = 1:length(p_vect)
    
    % -------------- BSC channel 
    channel_effect_rep = rand(size(encoded_bits_rep)) <= p_vect(p_ind);
    rec_bits_rep = xor(encoded_bits_rep, channel_effect_rep);

    channel_effect_conv = rand(size(encoded_bits_conv)) <= p_vect(p_ind);
    rec_bits_conv = xor(encoded_bits_conv, channel_effect_conv);
    
    channel_effect_polar = rand(size(encoded_bits_polar)) <= p_vect(p_ind);
    rec_bits_polar = xor(encoded_bits_polar, channel_effect_polar);
    
    % -------------- Receiver
    decoded_bits_rep = repitition_decoder(rec_bits_rep, L);
    decoded_bits_conv = viterbi_decoder(rec_bits_conv, G);
    decoded_bits_polar = polar_decoder(rec_bits_polar, B);
    
    % -------------- Compute BER
    error_bits_rep = biterr(data_bits , decoded_bits_rep);
    BER_rep(p_ind) = error_bits_rep/(length(data_bits));
    
    error_bits_conv = biterr(data_bits , decoded_bits_conv);
    BER_conv(p_ind) = error_bits_conv/(length(data_bits));
    
    error_bits_polar = biterr(data_bits , decoded_bits_polar);
    BER_polar(p_ind) = error_bits_polar/(length(data_bits));
end

figure
plot(p_vect,BER_rep,'x-k','linewidth',2); hold on;
plot(p_vect,BER_conv,'o-r','linewidth',2); hold on;
plot(p_vect,BER_polar,'d-b','linewidth',2); hold on;

xlabel('Values of p','fontsize',10)
ylabel('BER','fontsize',10)
legend('Repetition', 'convolutional', 'polar', 'fontsize',10)