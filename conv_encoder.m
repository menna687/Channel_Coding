function encoded_bits = conv_encoder(data, G)
% Encoder parameters
k = 1;    % information bits fed into encoder at one time
[n m] = size(G);    % n -> number of output bits (generator polynomials)
                    % m -> number of memory registers

enc_mem = zeros(1, m);     % encoder memory
encoded_bits = [];

for i = 1:length(data)
    % shift memory array to the left
    enc_mem(2:end) = enc_mem(1:end-1);
    enc_mem(1) = data(i);
    h = repmat(enc_mem, n, 1) .*G;

    % xor m with n polynomials
    for p = 1:n 
        xor_op = h(p, 1);
        for j = 2:m
            x2 = h(p, j); 
            xor_op = bitxor(xor_op,x2);
        end
        encoded_bits(end+1) = xor_op;
    end
end
end