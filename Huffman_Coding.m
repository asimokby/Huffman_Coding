%opening and reading from the text file.
FileId = fopen('A1_data.txt' ,'r');
input_array = fscanf(FileId, '%f');

%creating an empty map.
dict = containers.Map('KeyType','double' ,'ValueType','double');

%creating a set of unique elements in the give input.
set_unique = unique(input_array,'first');
set_unique = reshape(set_unique, [1,10]);

%filling the map with all unique elements with values 0.
for i = set_unique
    if isa(i, 'double')
        dict(i) = 0;
    end
end

%counting the frequency of each element and incrementing the values accordingly.
reshaped_A = reshape(input_array,[1,60]);
for j = reshaped_A
    if isKey(dict, j)
        val = values(dict, {j});
        dict(j) = (cell2mat(val) + 1);
    end
end

%dividing the values by the number of elements in the given input
%to calculate the probabilites.
probabilities = cell2mat(values(dict))/ numel(input_array);
disp(sort(probabilities));
%sorting the probabilities and assigning the array to a variable called b
b = sort(probabilities);

%Getting all the unique probabilities and the frequency of each in an array and assinging it to a variable called un_b
un_b = unique(b,'first');
zeros_v = zeros(numel(un_b), 1);
un_b = reshape(un_b, [numel(un_b),1]);
un_b = [un_b zeros_v];

%a copy of the sorted probabilites array that will be used inside the for loop since the actual b will change
temp = b(:,:);

%An array that will have all the probabilities in the even indicies and the assinged numbers(0 or 1) in the odd indiceis
big_b = [];
for i = b
    big_b = [big_b; i];
end

%Getting the size of b and big_b
[y,u] = size(b);
[c,v] = size(big_b);

%getting all keys in the dict and converting them from cell type to mat type
ks = keys(dict) ;
symbols = cell2mat(ks);
%an array of the symbols and the probabilities
symb_prob = [reshape(symbols, [10,1]) reshape(probabilities, [10,1])];

%a for loop that will iterate sum the probabilities and keep sorting the array
for i = 1 : numel(b)-1
    %the smallest two numbers and their sum
    chosen_2 = b(1,1:2);
    sum_sm = sum(chosen_2);
    %deciding which is the bigger one
    if chosen_2(1,1) > chosen_2(1,2)
        chosen_big = chosen_2(1,1);
        chosen_small = chosen_2(1,2);
    else
        chosen_big = chosen_2(1,2);
        chosen_small = chosen_2(1,1);
    end
    
    %since there might be similar probabilities, this will make sure to assign the sum to ONLY the summed
    %probability and not all the similar probabilities.
    %and chack if the chosen probabilities exist in the unique variables
    %the variables pass and sass, will decide if the one that exists is the small one or the big one
    pass = 0;
    sass = 0;
    for z = 1 : numel(un_b)
        q = un_b(z);
        if q == chosen_big
            pass = pass +  1;
            [raw, co] = find(un_b ==chosen_big, 1);
            v = un_b(raw,2);
            un_b(raw,2) = v + 1;
        end
        if q == chosen_small
            sass =  sass + 1;
            [raw, co] = find(un_b ==chosen_small, 1);
            v = un_b(raw,2);
            un_b(raw,2) = v + 1;
        end
    end
    
    %finding the indicies of that summed probability from the un_b (the current frequency)
    [raw, co] = find(un_b ==chosen_big, 1);
    v_big = un_b(raw,2);
    [raw, co] = find(un_b ==chosen_small, 1);
    v_small = un_b(raw,2);
    
    %To prevent the frequency of each to increase more than what it is, check_lim will take care of this
    %and prevent that probability to access a condition
    check_lim_b = sum(temp(:) == chosen_big);
    check_lim_s = sum(temp(:) == chosen_small);
    prevent = 3;
    if (v_small > check_lim_s)
        prevent = 1;
    elseif (v_big > check_lim_b)
        prevent = 0;
    end
    %if the the probabilities are the same, and it is not exceeding the limit
    %The probabilities will have 1 or 0, then their sum in the third column
    if pass + sass == 2 && chosen_big == chosen_small && prevent ~=0 && prevent ~= 1
        f = v_big -1 ;
        [raw, co] = find(big_b ==chosen_big, v_big);
        
        big_b(raw(f,1), co+1) = 90;
        big_b(raw(f,1), co+2) = sum_sm;
        
        big_b(raw(v_small,1), co(1,1)+1) = 80;
        big_b(raw(v_small,1), co(1,1)+2) = sum_sm;
    %if pass and sass equal to 1, this means that only one of the chosen probabilities are in the unique probs
    elseif pass + sass == 1
        %if pass == 1, means the big one is the one that exists in our unique probabilities
        %so we get its index and place a 0 in its next column and the sum in the following column
        %then deal with the smaller by just going through the whole big_b and looking for similar probs
        if pass == 1
            [raw, co] = find(big_b == chosen_big, v_big);
            big_b(raw(v_big,1), co+1) = 90;
            big_b(raw(v_big,1), co+2) = sum_sm;
            for r = 1: u
                [m,n] = size(big_b);
                for k = 1:n
                    if  big_b(r, k) == chosen_small
                        big_b(r, k+1) = 80;
                        big_b(r, k+2) = sum_sm;
                    end
                end
            end
        %if sass == 1, means the small one is the one that exists in our unique probabilities
        %so we get its index and place a 0 in its next column and the sum in the following column
        %then deal with the bigger by just going through the whole big_b and looking for similar probs
        elseif sass == 1
            [raw, co] = find(big_b == chosen_small, v_small);
            big_b(raw(v_small,1), co+1) = 80;
            big_b(raw(v_small,1), co+2) = sum_sm;
            for r = 1: u
                [m,n] = size(big_b);
                for k = 2:n
                    if  big_b(r, k) == chosen_big
                        big_b(r, k+1) = 90;
                        big_b(r, k+2) = sum_sm;
                    end
                end
            end
        end
    %if they both have exist in the uniqe table and not equal to each other
    elseif pass + sass == 2 && chosen_big ~= chosen_small
        %do this if the bigger one is passing the limit of its frequency
        if prevent == 0
            [raw, co] = find(big_b ==chosen_small, v_small);
            big_b(raw(v_small,1), co+1) = 80;
            big_b(raw(v_small,1), co+2) = sum_sm;
            for r = 1: u
                [m,n] = size(big_b);
                for k = 2:n
                    if  big_b(r, k) == chosen_big
                        big_b(r, k+1) = 90;
                        big_b(r, k+2) = sum_sm;
                    end
                end
            end
         %do this if the smaller one is passing the limit of its frequency
        elseif prevent == 1
            [raw, co] = find(big_b ==chosen_big, v_big);
            big_b(raw(v_big,1), co+1) = 90;
            big_b(raw(v_big,1), co+2) = sum_sm;
            for r = 1: u
                [m,n] = size(big_b);
                for k = 3:n
                    if  big_b(r, k) == chosen_small
                        big_b(r, k+1) = 80;
                        big_b(r, k+2) = sum_sm;
                    end
                end
            end
        else
            %if none of them is passing the limit, I just place them according to each one's index
            [raw, co] = find(big_b ==chosen_big, v_big);
            big_b(raw(v_big,1), co+1) = 90;
            big_b(raw(v_big,1), co+2) = sum_sm;
            [raw, co] = find(big_b ==chosen_small, v_small);
            big_b(raw(v_small,1), co+1) = 80;
            big_b(raw(v_small,1), co+2) = sum_sm;
        end
    else
        %if none if the above is the case, I just go through the whole array and look for similar probs to 
        %place the assigned number and next to it the sum.
        for r = 1: u
            [m,n] = size(big_b);
            for k = 1:n
                if big_b(r, k) == chosen_big || big_b(r, k) == chosen_small
                    if big_b(r,k) == chosen_big
                        big_b(r, k+1) = 90;
                        big_b(r, k+2) = sum_sm;
                    elseif big_b(r, k) == chosen_small
                        big_b(r, k+1) = 80;
                        big_b(r, k+2) = sum_sm;
                    end
                end
            end
        end
    end
    %keep sorting the array each iteration
    b = sort([sum_sm b(1,3:end)]);
end
%getting the size of big_b
[c,v] = size(big_b);

try
    assg = [big_b(1:end, 1)];
    for i = 1:v
        i = i .* 2;
        assg = [assg big_b(1:end,i)];
    end
catch m
end
%in the following lines of code, I convert the big_b array to huff dict, by getting the symbols and their code words
%from the big_b and putting them in a cell array.
numbers = symb_prob(1:end,1);
probs = symb_prob(1:end,2);
[sorted_a, a_order] = sort(probs);
newB = symb_prob(a_order,:);
assg = [newB(1:end, 1) assg];
assg_strs = fliplr(assg(1:end, 3:end));
[c,v] = size(assg_strs);
symbols_final = assg(1:end, 1);
last_assg = [];
manually_huff_dict = {};
for i = 1 : c
    raw = assg_strs(i,:);
    raw = raw(raw ~= 0);
    raw(raw == 90) = 0;
    raw(raw == 80) = 1;
    str_raw = num2str(raw);
    BBB = reshape( horzcat(str_raw(:)), size(str_raw,1), []);
    BBB =  BBB(find(~isspace(BBB)));
    BBB = num2str(BBB)-'0';
    manually_huff_dict(i,1) = {symbols_final(i,1)};
    manually_huff_dict(i,2) = {BBB};
    
end
%final sorted manually huffman dict
manually_huff_dict = sortrows(manually_huff_dict,1);




%Example%

%encoding the data
encoded_array = [];
for i =1 : length(input_array)
    elem = input_array(i,1);
    val = manually_huff_dict{elem+1,2};
    encoded_array = [encoded_array val];
end

%decoding the data
decoded_array = [];
s = [];
for i = 1 : length(encoded_array)
    ka = encoded_array(1,i);
    s = [s ka];
    for j = 1: length(manually_huff_dict)
        arr_asg = manually_huff_dict{j,2};
        if isequal(s,arr_asg)
            decoded_array = [decoded_array manually_huff_dict{j,1}];
            s = [];
        end
    end
end

%printing the huffman dict and the encoded and decoded data
disp('Huffman dict: ');
celldisp(manually_huff_dict);
