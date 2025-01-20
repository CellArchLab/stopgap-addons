function halfobjecthalfsets(starFilePath)
    %% A function for assigning half-sets for each object (filament) split in half

    %% Load the input STAR file
    % Adjust this path to the location of your STAR file
    % starFilePath = 'TZ_MTD_all_motl_8cl_20211011_15.star';
    data = sg_motl_read2(starFilePath); % Assume `readStarFile` is a custom STAR parser

    %% Extract relevant columns
    % Assuming column names match the user-provided description
    tomoNums = data.tomo_num;
    objectIds = data.object; % Replace with the actual column name for objects

    uniqueTomoNums = unique(tomoNums);
    halfset = cell(size(tomoNums)); % Initialize halfset assignment

    %% Seed the random number generator for true randomness
    rng('shuffle');

    %% Assign 'A' and 'B' halfsets per tomo_num
    for i = 1:length(uniqueTomoNums)
        tomoId = uniqueTomoNums(i);
        tomoIndices = find(tomoNums == tomoId);

        % Group by object within the current tomo_num
        uniqueObjects = unique(objectIds(tomoIndices));
        for j = 1:length(uniqueObjects)
            objectId = uniqueObjects(j);
            objectIndices = tomoIndices(objectIds(tomoIndices) == objectId);

            % Split into two halves for the current object
            nRows = length(objectIndices);
            firstHalf = objectIndices(1:ceil(nRows/2));
            secondHalf = objectIndices(ceil(nRows/2)+1:end);

            % Randomly assign 'A' or 'B' to the first half
            if rand() > 0.5
                halfset(firstHalf) = {'A'};
                halfset(secondHalf) = {'B'};
            else
                halfset(firstHalf) = {'B'};
                halfset(secondHalf) = {'A'};
            end
        end
    end

    %% Save the modified data
    % Append the new `halfset` column to the data structure
    data.halfset = halfset;

    % Write back to a STAR file
    outputFilePath = 'TZ_MTD_all_motl_8cl_20211011_15_halftomohalfsets.star';
    sg_motl_write2(outputFilePath, data); % Assume `writeStarFile` is a custom STAR writer

    disp(['Updated STAR file saved to: ', outputFilePath]);