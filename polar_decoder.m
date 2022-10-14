function decoded_bits = polar_decoder(rec_bits, K)
Q = csvread('reliablity_seq');
N = length(rec_bits);
n = log2(N); 

Q1 = Q(Q<=N);    % reliability squence for N

% freezing prevents error propagation
Frozen_bits = Q1(1:N-K);   %frozen bits indeces

r = 1-2*rec_bits;  % BPSK bit to symbol conversion

beleif = zeros(n+1,N);        % beliefs
decision = zeros(n+1,N);      % Decision 
node_state = zeros(1,2*N-1);  % node state vector

f  = @(a,b) (1-2*(a<0)).*(1-2*(b<0)).*min(abs(a),abs(b));  % minsum
g = @(a,b,c) b+(1-2*c).*a;
beleif(1,:) = r;     % belief of root node is the received sequence

node = 0; depth = 0; % start from tree root
done = 0;

% Perform binary tree search for successive cancellation decoding
while done == 0
    % leaf nodes
    if depth == n
        if any(Frozen_bits == (node+1))  % node is frozen--> set to zero 
            decision(n+1, node+1) = 0;
        else
            if beleif(n+1, node+1) >= 0
                decision(n+1, node+1) = 0;
            else
                decision(n+1, node+1) = 1;
            end
        end
            if node == (N-1)
                done = 1;
            else
                node = floor(node/2);  % parent index
                depth = depth -1;
            end
    % nonleaf nodes        
    else
        node_pos = (2^depth-1)+node+1;  % positon of node 
        if node_state(node_pos) == 0    % first visit to this node --> go to left child
           % incoming beleif
           len = 2^(n-depth); 
           next_beleif = beleif(depth+1, len*node+1:len*(node+1)); 
           a = next_beleif(1:len/2);         
           b = next_beleif(len/2+1:end);
           
           % update node and depth (go to left child) 
           node = node*2;    
           depth = depth+1;                         
           len = len/2;         % incoming beleif length
           
           % left child message
           beleif(depth+1, len*node+1:len*(node+1)) = f(a,b); 
           node_state(node_pos) = 1;
        
        else
            if node_state(node_pos) == 1  % Second visit to this node--> go to right child
               % incoming beleif
               len = 2^(n-depth); 
               next_beleif = beleif(depth+1, len*node+1:len*(node+1));  %incoming beliefs
               a = next_beleif(1:len/2);             
               b = next_beleif(len/2+1:end);        
               % Left child decision
               left_node = node*2;
               left_depth = depth+1;
               left_temp = len/2;
               n_decision = decision(left_depth+1, left_temp*left_node+1:left_temp*(left_node+1));
               
               % update node and depth (go to right child)
               node = node*2 + 1;
               depth=  depth + 1;                         
               len = len/2;    %incoming beleif length 
               
               % right child message based on left child decision
               beleif(depth+1, len*node+1:len*(node+1)) = g(a,b, n_decision); 
               node_state(node_pos) = 2;
           
            else   % Third visit to this node--> go to parent
               % get children nodes and depth
               len = 2^(n-depth);
               left_node = 2*node;
               right_node = 2*node + 1;
               cdepth = depth+1;
               left_depth = depth+1;
               ctemp = len/2;
               
               % right and left children decisions
               left_decision = decision(cdepth+1, ctemp*left_node+1:ctemp*(left_node+1));
               right_decision = decision(cdepth+1, ctemp*right_node+1:ctemp*(right_node+1));
               
               % parent decision based on right and left decisions
               decision(depth+1, len*node+1:len*(node+1)) = [mod(left_decision+right_decision,2) right_decision];
               node = floor(node/2);
               depth = depth-1;
            end
        end
    end 
end
% Extract decoded message
decoded_bits = decision(n+1, Q1(N-K+1:end));
end