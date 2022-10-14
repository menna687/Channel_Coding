function encoded_bits = repitition_encoder(data_bits, L)

% add redundancy bits
encoded_bits = repelem(data_bits, L);

end