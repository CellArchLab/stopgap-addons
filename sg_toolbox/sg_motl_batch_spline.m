%% sg_motl_batch_spline
% A function to batch generate motivelists for a set of splines. 
%
% The input folder should contain a subfolder for each tomogram; each
% folder should be named after the tomogram number. Within each folder
% there should be a set of .cmm file containing tube centers, as picked
% from chimera's volume tracer. Each .cmm file should be named
% [root_name]_[tomo_num]_[obj_number].cmm. Radii can be supplied as a 
% single value or using a three column text file with columns tomo number,
% tube number and radius.
% 
% Points can also be thresholded with respect to tomogram boundaries.
%
% WW 11-2020

%% Inputs

% Input folder
metadata_folder = 'Manualpicks_IFT';

% Center root name
tracer_root = 'IFT';
tracer_type = 'txt';    % txt or cmm

% Reconstruction list
rlist_name = 'recons_file.txt';

% Distances
dist = 3;    % Distance along filament axis

% Order in Z
order_z = 0;

% Phi angle assignment ('rand' = random, or [offset,rotation] in degrees)
phi_angle_type = 'rand';


% Tomogram dir
% tomo_dir = '/fs/pool/pool-engel/righetto/mito_florent/Position_16_rdr/stopgap_subtomo/bin4_tomo/';
tomo_dir = 'bin4_phaseflip_tomonums/';
tomo_ext = '.mrc';
digits = 1;
padding = 10;    % Size of the edge boundary for thresholding; any centers within the boundary are removed.

% Output name
output_name = 'IFT_bin4_motl_1.star';


%% Initialize

% Read reconstructin list
rlist = dlmread(rlist_name);
n_tomos = numel(rlist);


% Initialize cell array
motl_cell = cell(n_tomos,1);

      
% Parse numeric format for tomogram names
nfmt = ['%0',num2str(digits),'i'];


%% Generate motls for each tube
subtomo_num = 1;

for i = 1:n_tomos
    
    % Determine number of tracer files
    tr_dir = dir([metadata_folder,'/',num2str(rlist(i),['%0',num2str(digits),'i']),'/',tracer_root,'_*.',tracer_type]);
    
    % Read tracer
    switch tracer_type
        case 'txt'
            tr = dlmread([metadata_folder,'/',num2str(rlist(i),['%0',num2str(digits),'i']),'/',tr_dir.name]);
            tr_idx = unique(tr(:,1));
            n_tr = numel(tr_idx);
        case 'cmm'
            tr = sg_cmm_read([metadata_folder,'/',tracer_root,'_',num2str(rad_array(j,1)),'_',num2str(rad_array(j,2)),'.cmm']);
    end    

    tomo_cell = cell(n_tr,1);
    
    for j = 1:n_tr

        % Parse points
        switch tracer_type
            case 'txt'
                p_idx = tr(:,1) == tr_idx(j);
                points = tr(p_idx,2:4);
        end

        % Order in Z
        if order_z == 1
            points = sortrows(points,3);
        end
        
        % Add a check for single points clicked by accident in IMOD:
        if size(points,1) <= 1
            continue
        end

        % Get spline positions
        [positions,eulers] = sg_motl_generate_spline_function(points',dist,phi_angle_type);
        n_pos = size(positions,2);
        
        % Parse positions
        x = round(positions(1,:));
        y = round(positions(2,:));
        z = round(positions(3,:));
        x_shift = positions(1,:) - x;
        y_shift = positions(2,:) - y;
        z_shift = positions(3,:) - z;
        
        
        % Initialize motivelist
        temp_motl = sg_initialize_motl2(n_pos);

        % Store eulers
        temp_motl.phi = single(eulers(1,:))';
        temp_motl.psi = single(eulers(2,:))';
        temp_motl.the = single(eulers(3,:))';

        % Store coordinates
        temp_motl.orig_x = single(x');
        temp_motl.orig_y = single(y');
        temp_motl.orig_z = single(z');
        temp_motl.x_shift = single(x_shift');
        temp_motl.y_shift = single(y_shift');
        temp_motl.z_shift = single(z_shift');
                
        % Fill subtomo_num
        temp_motl.subtomo_num = int32(subtomo_num:(subtomo_num + n_pos-1))';
        % Increment counter
        subtomo_num = subtomo_num + n_pos;
        % Fill object number
        temp_motl.object = ones(size(temp_motl.object),'int32').*j;
        

        % Store motl
        tomo_cell{j} = temp_motl;
    end
    
    
    % Concatenate and fill other fields
    motl_cell{i} = sg_motl_concatenate(false,tomo_cell);
    total_pos = numel(motl_cell{i}.tomo_num);
    motl_cell{i}.tomo_num = ones(total_pos,1,'int32').*rlist(i);
    
    % Threshold list
    tomo_name = [tomo_dir,'/',num2str(rlist(i),nfmt),tomo_ext];
    motl_cell{i} = sg_motl_check_tomo_edges(tomo_name,motl_cell{i},padding);
    
end

%% Generate complete motl

% Concatenate all tomos
allmotl = sg_motl_concatenate(false,motl_cell);
n_motls = numel(allmotl.motl_idx);

% Fill remaining fields
allmotl.motl_idx = int32(1:n_motls)';
allmotl.subtomo_num = int32(1:n_motls)';
allmotl.class = ones(n_motls,1,'int32');

% Write motl
disp([num2str(n_motls),' motivelist entries generated...']);
sg_motl_write2(output_name,allmotl);









