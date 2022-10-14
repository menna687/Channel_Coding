function decoded_bits = viterbi_decoder(y, G)
[n m] = size(G);    % n -> number of output bits (generator polynomials)
                    % m -> number of memory registers

states_num = 2^(m-1);
states = 1:states_num;

% Generate output matrix and next states matrix for all possible states and inputs
for ip = 0:1
    enc_mem = [];
    for state = 1:states_num
        output_bits = [];
        enc_mem = [ip de2bi(state-1, m-1,'left-msb')];
        h = repmat(enc_mem, n, 1) .*G;
        for p = 1:n 
            xor_op = h(p, 1);
            for j = 2:m
                x2 = h(p, j); 
                xor_op = bitxor(xor_op,x2);
            end
            output_bits =[output_bits xor_op];
        end
        outputs(state, ip+1) = bi2de(output_bits, 'left-msb');
        next_states(state, ip+1) = bi2de(enc_mem(1:m-1), 'left-msb');
    end
end
% -------------------------------------------------------------------------------------
% Predecessor states for all states 
for k = 1:states_num
    for x = 1:n
        [row, col] = find(next_states == k-1);
        alpha(k) = row(1)-1;
        beta(k) = row(2)-1;
    end
end 
% -------------------------------------------------------------------------------------
decoded_bits = [];
path_metric = zeros(states_num, (length(y)/n)+1);    % array af acumulative hamming distances
path_metric(2:end) = Inf; 

% loop for all received codeword
for i = 1:size(path_metric, 2)-1
    % get input encoded bits
    for h = 1:n
        encoded_bits(h) = y(h+2*(i-1));
    end
    
    % Calculate branch metric 
    % (hamming distance between received sequenceand all possible sequences)
    for c = 1:states_num
        for m = 1:n
            branch_metric(c, m) = biterr(encoded_bits, de2bi(outputs(c, m), n,'left-msb'));
        end
    end
    
    input_bits = [];
    for j = 1:length(states)
        % Estimated input bit for each predecessor state of the current state
        est_bit1 = find(next_states(alpha(j)+1, :) == j-1);
        est_bit2 = find(next_states(beta(j)+1, :) == j-1);
        
        % Calculate path metric between current state and possible predecessor states  
        path_1 = path_metric(alpha(j)+1, i) + branch_metric(alpha(j)+1, est_bit1); 
        path_2 = path_metric(beta(j)+1, i) + branch_metric(beta(j)+1, est_bit2);  
        path_metric(j, i+1) = min(path_1, path_2);
        
        % Get estimates decoded bits for current state
        if(path_1 <= path_2)
            input_bits = [input_bits est_bit1-1];
        else
            input_bits = [input_bits est_bit2-1];
        end
    end
    [row, col] = min(path_metric(:, i+1)); 
    decoded_bits = [decoded_bits input_bits(col)]; 
end
end 