function encoded_bits = polar_encoder(data_bits, N)
% read reliability sequence from attached file 
Q = csvread('reliablity_seq');

n = log2(N);       % depth of the binary tree
K = length(data_bits);            % length of message 

Q1 = Q(Q <= N);   %Reliablity sequence of N

% Frozen bits indeces: Q1(1:N-K)
% Message indeces: Q1(N-K:end)
encoded_bits = zeros(1,N);           % Channel block
encoded_bits(Q1(N-K+1:end)) = data_bits;   % assign message bits

m = 1;   %number of bits combined at each step

for i = 1:n                % loop for the depth of the binary tree
    for j = 1:2*m:N
        a = encoded_bits(j:j+m-1);                  % first part
        b = encoded_bits(j+m:j+2*m-1);              % second part
        encoded_bits(j:j+2*m-1) = [mod(a+b,2) b];   % combined (modulo 2 addition)
    end
    m = m*2;
end
end