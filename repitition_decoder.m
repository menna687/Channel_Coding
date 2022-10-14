function decoded_bits = repitition_decoder(rec_bits, L)
decoded_bits = zeros(1,length(rec_bits)/L);
count1 = 0;
count0 = 0;
k = 1;
                 
for i=1:L:length(rec_bits)
    count1 = nnz(rec_bits(i:i+L-1));
    count0 = L - count1;

    if (count1>count0)
        decoded_bits(k) = 1;
               
    else
        decoded_bits(k) = 0;
    end
           
    k = k+1;
    count1 = 0;
    count0 = 0;
end
end