% !! Metadata file ".mdoc" needs to be in same folder as frames !! Currently uses the first .mdoc file it finds in folder (should be changed)

%% MODIFY THE FOLLOWING TO FIT YOUR CONFIG

% Define Path of your data  

frame_dirpath      = '/mnt/nas/FAC/FBM/DMF/pnavarr1/default/D2c/FondationPierreMercier/BostonPaula/Boston_Paula/OldTestAurelien/RawAll';     % FULL PATH of Frames + Metadata file folder:
gain_path          = '/mnt/nas/FAC/FBM/DMF/pnavarr1/default/D2c/FondationPierreMercier/BostonPaula/Boston_Paula/OldTestAurelien/RawAll';     % FULLPATH to specific gain file or folder (if folder, will use first *.dm4 it finds). Usually same as 'frame_dirpath':                    
output_dirpath     = '/mnt/nas/FAC/FBM/DMF/pnavarr1/default/D2c/FondationPierreMercier/BostonPaula/Boston_Paula/OldTestAurelien/RetestCTF2cl';   % FULLPATH to output files folder. Usually same as 'frame_dirpath':

% Choose output names
stack_name         = 'stack_AF';             % Choose rootname for .mrc stack output
imod_folder        = 'imod_4_1';     % Choose directory name that will be created to output results of Alignframes

% IMOD Pre-Processing options
Exclude_Frames     = 'Yes';      % 'Yes' If you want to be prompted to select Frames to exclude from processing
Overwrite_exclude  = 'No';       % 'Yes' If you want to overwrite existing Frames selection that are in Exclude_views.txt (For example if you have already previously selected the Frames to reject and don't want to redo)
User_boundary      = 'Yes';      % 'Yes' If you want to be prompted to build Boundary model for Patch Tracking
User_trim          = 'Yes';      % 'Yes' If you want to be prompted to manually trim volume (this step is performed at end of combined stack processing)

IMOD_bin_coarse    =  4;         %  1 for no binning. Binning amount to be performed when running IMOD coarse-alignment (Binning is performed in X and Y)
IMOD_bin_aligned   =  1;         %  1 for no binning. Binning amount to be performed when running IMOD reconstruction  (Binning is performed isotropically)

% CRYOCARE options
CryoCARE_prepare   = 'es';      % 'Yes' If you want to create Even / Odd Tomogram and prepare .json files for denoising with CryoCARE
CryoCARE_run       = 'es';      % 'Yes' if you want to run CryoCARE denoising. Your CryoCARE needs to be installed in cryocare_11 conda environment (like installed in github)
CryoCARE_bin       =   4;       %  1 for no binning. Binning amount to be performed before running CryoCARE (in addition to previous binning)

Epochs             =  20;       % Number of epochs for CryoCARE training
Steps              =  75;       % Number of steps (per epochs) for CryoCARE training




%% DON'T MODIFIY THE FOLLOWING:
%% PROCESSING PART
disp(datetime('now', 'Format', 'HH:mm:ss'))
NAV
script_dir = fileparts(matlab.desktop.editor.getActiveFilename);
git_root_dir = fileparts(script_dir);
template_filepath = fullfile(git_root_dir, 'ConfigurationFiles', 'AurelienTemplate241024.adoc');
cryo_path = fullfile(git_root_dir, 'CryoCARE');
if isfolder(gain_path), gain_path = [gain_path, '/*dm4']; end
if ~exist(output_dirpath, 'dir'), mkdir(output_dirpath), end
mkdir([output_dirpath,'/',imod_folder])

% Create and write to TimeCapsule.txt
fileID = fopen([output_dirpath,'/TimeCapsule.txt'], 'w');
fprintf(fileID, '--- Template File Contents ---\n');
fprintf(fileID, '%s\n\n', fileread(template_filepath));
fprintf(fileID, '--- Current Script Code ---\n');
fprintf(fileID, '%s\n\n', fileread([mfilename('fullpath'), '.m']));
fclose(fileID);
disp('TimeCapsule.txt created.');

% Template file modifications
system(sprintf('sed -i '''' ''s#^\\(runtime\\.PatchTracking\\.any\\.prealiBoundaryModel=\\).*#\\1#'' "%s"', template_filepath));
system(sprintf('sed -i '''' ''s/^comparam\\.xcorr_pt\\.tiltxcorr\\.SizeOfPatchesXandY=.*/comparam.xcorr_pt.tiltxcorr.SizeOfPatchesXandY=%d,%d/'' "%s"', round(500./IMOD_bin_coarse), round(500./IMOD_bin_coarse), template_filepath));
system(['sed -i '''' ''s/^comparam\.prenewst\.newstack\.BinByFactor=.*/comparam.prenewst.newstack.BinByFactor=' num2str(IMOD_bin_coarse) '/'' ' template_filepath]);
system(['sed -i '''' ''s/^runtime\.AlignedStack\.any\.binByFactor=.*/runtime.AlignedStack.any.binByFactor=' num2str(IMOD_bin_aligned) '/'' ' template_filepath]);

keep_list = 1;
if strcmp(Exclude_Frames,'Yes')
    if exist([output_dirpath,'/temp/Slices/Exclude_views.txt'])
        if strcmp(Overwrite_exclude,'Yes')
            mkdir([output_dirpath,'/temp'])
            system(['cd ',frame_dirpath,' && alignframes -mdoc ',frame_dirpath,'/*mdoc -output ',output_dirpath,'/temp/Temp_AF.mrc -mode 2 -adjust -binning 16,8 -gain ',gain_path]);
            keep_list = Exclude_views([output_dirpath,'/temp/Temp_AF.mrc']);
        else
            keep_list = readmatrix([output_dirpath,'/temp/Slices/Exclude_views.txt']);
        end
    else
        mkdir([output_dirpath,'/temp'])
        system(['cd ',frame_dirpath,' && alignframes -mdoc ',frame_dirpath,'/*mdoc -output ',output_dirpath,'/temp/Temp_AF.mrc -mode 2 -adjust -binning 16,8 -gain ',gain_path]);
        keep_list = Exclude_views([output_dirpath,'/temp/Temp_AF.mrc']);
    end
end
indices = find(keep_list == 0); indices_str = sprintf('%d,', indices); indices_str(end) = [];

if strcmp(CryoCARE_prepare,'Yes')

    % Align Frames and create Even and Odd frames
    system(['cd ',frame_dirpath,' && alignframes -mdoc ',frame_dirpath,'/*mdoc -output ',output_dirpath,'/',imod_folder,'/',stack_name,'.mrc -mode 2 -adjust -binning 8,2 -gain ',gain_path,' -debug 10000']);

    % Get and set Pixel Spacing and Stack Size from combined for Even/Odd
    [a, SizeOut] = system(['header -size ',output_dirpath,'/',imod_folder,'/',stack_name,'.mrc']);
    parts2 = strsplit(SizeOut); 
    SizeOut = (parts2(~cellfun('isempty', strsplit(SizeOut))));
    [~, pix] = system(['header -pixel ',output_dirpath,'/',imod_folder,'/',stack_name,'.mrc']);
    parts = strsplit(pix);
    pix = (parts(~cellfun('isempty', strsplit(pix))));

    % Sort Even and Odd frames into Even and Odd folder
    SortEvenOdd(frame_dirpath,output_dirpath)
    'Creating Even stack'
    system(['newstack -QuietOutput -ModeToOutput 2 -SizeToOutputInXandY ',SizeOut{1},',',SizeOut{2},',',SizeOut{3},' $(ls ',output_dirpath,'/even/faimg-*.mrc | sort -V) ',output_dirpath,'/even/',stack_name,'.mrc']);
    'Creating Odd stack'
    system(['newstack -QuietOutput -ModeToOutput 2 -SizeToOutputInXandY ',SizeOut{1},',',SizeOut{2},',',SizeOut{3},' $(ls ',output_dirpath,'/odd/faimg-*.mrc | sort -V) ', output_dirpath,'/odd/', stack_name,'.mrc']);

    system(['alterheader ',output_dirpath,'/even/',stack_name,'.mrc -PixelSize ',pix{1},',',pix{2},',',pix{3}])
    system(['alterheader ',output_dirpath,'/odd/', stack_name,'.mrc -PixelSize ',pix{1},',',pix{2},',',pix{3}])

    % Remove Excluded Views
    if ~all(keep_list == 1)
        system(['excludeviews -delete -views ', indices_str,' -StackName ', output_dirpath,'/even/',stack_name,'.mrc']);
        system(['excludeviews -delete -views ', indices_str,' -StackName ', output_dirpath,'/odd/', stack_name,'.mrc']) ; 
    end
else
    system(['cd ',frame_dirpath,' && alignframes -mdoc ',frame_dirpath,'/*mdoc -output ',output_dirpath,'/',imod_folder,'/',stack_name,'.mrc -mode 2 -adjust -binning 8,2 -gain ',gain_path]);
end

if ~all(keep_list == 1), system(['excludeviews -delete -views ', indices_str,' -StackName ',output_dirpath,'/',imod_folder,'/',stack_name,'.mrc']); end


if strcmp(User_trim,'Yes') && strcmp(User_boundary,'Yes')

    % Run batchruntomo up to step 3 for boundary point definition
    system(['batchruntomo -di ', template_filepath, ' -ro ', stack_name, ' -current ', output_dirpath, '/', imod_folder, ' -deliver ', output_dirpath, '/', imod_folder, ' -gpu 1 -end 3']);
    
    % Open 3dmod for boundary model creation
    system(['3dmod ', output_dirpath, '/', imod_folder, '/', stack_name, '/', stack_name, '_preali.mrc ', output_dirpath, '/', imod_folder, '/', stack_name, '/', stack_name, '_ptbound.mod']);
    input('Press Enter when you are done with 3dmod...');
    
    % Update the template file with the boundary model path
    string_to_replace = [output_dirpath, '/', imod_folder, '/', stack_name, '/', stack_name, '_ptbound.mod'];
    system(sprintf('sed -i '''' ''s#^\\(runtime\\.PatchTracking\\.any\\.prealiBoundaryModel=\\).*#\\1%s#'' "%s"', string_to_replace, template_filepath));
    
    % Continue batchruntomo from step 4 up to step 12
    system(['batchruntomo -di ', template_filepath, ' -ro ', stack_name, ' -current ', output_dirpath, '/', imod_folder, ' -deliver ', output_dirpath, '/', imod_folder, ' -gpu 1 -start 4 -end 12']);
    command_file = [output_dirpath, '/', imod_folder, '/', stack_name, '/tilt.com']; % THESE TWO LINES WERE IN ELSEIF BELOW BUT NOT HERE SO I ADDED THEM BECAUSE PROB SHOULD BE HERE? REMEMBER TO CHANGE THIS TO BE RELATIVE TO SIZE IN Y AND TAKING BINNING INTO ACCOUNT??
    system(['grep -q "THICKNESS" ',command_file,' && sed -i '''' "/THICKNESS/c\THICKNESS 3000" ',command_file]);   % THIS DOESN'T TAKE BINNING INTO ACCOUNT I BELIEVE

    % Run sample alignment
    system(['cd ', output_dirpath, '/', imod_folder, '/', stack_name, '/ && submfg sample.com']);
    
    % Open 3dmod for tomopitch adjustments
    system(['cd ', output_dirpath, '/', imod_folder, '/', stack_name, '/ && 3dmod top_rec.mrc mid_rec.mrc bot_rec.mrc tomopitch.mod']);
    input('Press Enter when you are done with 3dmod...');
    
    % Run tomopitch
    system(['cd ', output_dirpath, '/', imod_folder, '/', stack_name, '/ && submfg tomopitch.com']);
    
    % Extract parameters from log files
    [status, XaxisA] = system(['grep -m 1 "XAXISTILT" ', output_dirpath, '/', imod_folder, '/', stack_name, '/sample.log | sed ''s/.*XAXISTILT = //''']);
    [status, XaxisB] = system(['sed -n ''/Pitch between samples/ s/.*X-axis tilt of *\([-0-9.]*\)/\1/p'' ', output_dirpath, '/', imod_folder, '/', stack_name, '/tomopitch.log']);
    [status, Thickness] = system(['grep -o "thickness of .* set to *[0-9]*" ', output_dirpath, '/', imod_folder, '/', stack_name, '/tomopitch.log | tail -1 | awk ''{print $NF}''']);
    [status, Zshift] = system(['sed -n ''/Z shift of/ s/.*Z shift of *\([-0-9.]*\);.*/\1/p'' ', output_dirpath, '/', imod_folder, '/', stack_name, '/tomopitch.log | tail -n 1']);
    [status, Offset] = system(['grep "to make level, add" ',output_dirpath,'/',imod_folder,'/',stack_name,'/tomopitch.log | tail -n 1 | sed ''s/.*add  *\(-*[0-9.]*\).*/\1/''']);
    Xaxistilt = str2double(strtrim(XaxisA)) + str2double(strtrim(XaxisB));
    
    % Update tilt.com with new parameters
    system(['grep -q "OutputFile" ',command_file,' && sed -i '''' "/OutputFile/c\OutputFile ',stack_name,'_full_rec.mrc" ',command_file,' || sed -i '''' "/SCALE/a\OutputFile ',stack_name,'_full_rec.mrc" ',command_file]);
    system(['grep -q "THICKNESS" ',command_file, ' && sed -i '''' "/THICKNESS/c\THICKNESS ',strtrim(Thickness), '" ',command_file, ' || sed -i '''' "/SCALE/a\THICKNESS ', strtrim(Thickness), '" ',command_file]);
    system(['grep -q "XAXISTILT" ',command_file, ' && sed -i '''' "/AXISTILT/c\XAXISTILT ',num2str(Xaxistilt), '" ', command_file, ' || sed -i '''' "/SCALE/a\XAXISTILT ', num2str(Xaxistilt), '" ', command_file]);
    system(['grep -q "OFFSET" ',command_file, ' && sed -i '''' "/OFFSET/c\OFFSET ',strtrim(Offset), '" ',command_file, ' || sed -i '''' "/SCALE/a\OFFSET ',strtrim(Offset), '" ',command_file]);
    system(['grep -q "SHIFT" ', command_file, ' && sed -i '''' "/SHIFT/c\SHIFT ',  strtrim(Zshift), '" ',command_file, ' || sed -i '''' "/SCALE/a\SHIFT ', strtrim(Zshift), '" ',command_file]);
    
    % Run tilt reconstruction
    system(['cd ',output_dirpath,'/',imod_folder,'/',stack_name,'/ && submfg tilt.com']);

    % Continue batchruntomo from step 15 onwards
    system(['batchruntomo -di ', template_filepath, ' -ro ', stack_name, ' -current ', output_dirpath, '/', imod_folder, ' -deliver ', output_dirpath, '/', imod_folder, ' -gpu 1 -start 15']);

elseif strcmp(User_trim,'Yes')

    % Run batchruntomo up to step 12 for tilt alignment definition
    system(['batchruntomo -di ',template_filepath,' -ro ',stack_name,' -current ',output_dirpath,'/',imod_folder,' -deliver ' ,output_dirpath,'/',imod_folder,' -gpu 1 -end 12'])
    command_file = [output_dirpath, '/', imod_folder, '/', stack_name, '/tilt.com']; % REMEMBER TO CHANGE THIS TO BE RELATIVE TO SIZE IN Y AND TAKING BINNING INTO ACCOUNT??
    system(['grep -q "THICKNESS" ',command_file,' && sed -i '''' "/THICKNESS/c\THICKNESS 3000" ',command_file]);   % THIS DOESN'T TAKE BINNING INTO ACCOUNT I BELIEVE

    % Run sample alignment
    system(['cd ',output_dirpath,'/',imod_folder,'/',stack_name,'/ && submfg sample.com']);

    % Open 3dmod for tomopitch adjustments
    system(['cd ',output_dirpath,'/',imod_folder,'/',stack_name,'/ && 3dmod top_rec.mrc mid_rec.mrc bot_rec.mrc tomopitch.mod']);
    input('Press Enter when you are done with 3dmod...');

    % Run tomopitch
    system(['cd ',output_dirpath,'/',imod_folder,'/',stack_name,'/ && submfg tomopitch.com']);

    % Extract parameters from log files
    [status, XaxisA] = system(['grep -m 1 "XAXISTILT" ',output_dirpath,'/',imod_folder,'/',stack_name,'/sample.log | sed ''s/.*XAXISTILT = //''']);
    [status, XaxisB] = system(['sed -n ''/Pitch between samples/ s/.*X-axis tilt of *\([-0-9.]*\)/\1/p'' ',output_dirpath,'/',imod_folder,'/',stack_name,'/tomopitch.log']);
    [status, Thickness]      = system(['grep -o "thickness of .* set to *[0-9]*" ',output_dirpath,'/',imod_folder,'/',stack_name,'/tomopitch.log | tail -1 | awk ''{print $NF}''']);
    [status, Zshift] = system(['sed -n ''/Z shift of/ s/.*Z shift of *\([-0-9.]*\);.*/\1/p'' ',output_dirpath,'/',imod_folder,'/',stack_name,'/tomopitch.log | tail -n 1']);
    [status, Offset] = system(['grep "to make level, add" ',output_dirpath,'/',imod_folder,'/',stack_name,'/tomopitch.log | tail -n 1 | sed ''s/.*add  *\(-*[0-9.]*\).*/\1/''']);
    Xaxistilt = str2double(strtrim(XaxisA))+str2double(strtrim(XaxisB));

    % Update tilt.com with new parameters
    system(['grep -q "OutputFile" ',command_file,' && sed -i '''' "/OutputFile/c\OutputFile ',stack_name,'_full_rec.mrc" ',command_file,' || sed -i '''' "/SCALE/a\OutputFile ',stack_name,'_full_rec.mrc" ',command_file]);
    system(['grep -q "THICKNESS" ',command_file,' && sed -i '''' "/THICKNESS/c\THICKNESS ',strtrim(Thickness),'" ',command_file,' || sed -i '''' "/SCALE/a\THICKNESS ',strtrim(Thickness),'" ',command_file]);
    system(['grep -q "XAXISTILT" ',command_file,' && sed -i '''' "/AXISTILT/c\XAXISTILT ',num2str(Xaxistilt),'" ', command_file,' || sed -i '''' "/SCALE/a\XAXISTILT ',num2str(Xaxistilt),'" ', command_file]);
    system(['grep -q "OFFSET" ',command_file,' && sed -i '''' "/OFFSET/c\OFFSET ',strtrim(Offset),'" ',command_file,' || sed -i '''' "/SCALE/a\OFFSET ',strtrim(Offset),'" ',command_file]);
    system(['grep -q "SHIFT" ', command_file,' && sed -i '''' "/SHIFT/c\SHIFT ',strtrim(Zshift),'" ',  command_file,' || sed -i '''' "/SCALE/a\SHIFT ',strtrim(Zshift),'" ', command_file]);

    % Run tilt reconstruction
    system(['cd ',output_dirpath,'/',imod_folder,'/',stack_name,'/ && submfg tilt.com']);

    % Continue batchruntomo from step 15 onwards
    system(['batchruntomo -di ',template_filepath,' -ro ', stack_name ,' -current ' output_dirpath,'/',imod_folder, ' -deliver ' , output_dirpath,'/',imod_folder,' -gpu 1 -start 15']);

elseif strcmp(User_boundary,'Yes')

    % Run batchruntomo up to step 3 for boundary point definition
    system(['batchruntomo -di ',template_filepath,' -ro ', stack_name ,' -current ' output_dirpath,'/',imod_folder, ' -deliver ' , output_dirpath,'/',imod_folder,' -gpu 1 -end 3'])

    % Open 3dmod for boundary model creation
    system(['3dmod ',output_dirpath,'/',imod_folder,'/',stack_name,'/',stack_name,'_preali.mrc ',output_dirpath,'/',imod_folder,'/',stack_name,'/stack_AF_ptbound.mod']);
    input('Press Enter when you are done with 3dmod...');

    % Update the template file with the boundary model path
    string_to_replace = strcat(output_dirpath, '/', imod_folder, '/', stack_name, '/stack_AF_ptbound.mod');
    system(sprintf('sed -i '''' ''s#^\\(runtime\\.PatchTracking\\.any\\.prealiBoundaryModel=\\).*#\\1%s#'' "%s"', string_to_replace, template_filepath));

    % Continue batchruntomo from step 4 onwards
    system(['batchruntomo -di ',template_filepath,' -ro ', stack_name ,' -current ' output_dirpath,'/',imod_folder, ' -deliver ' , output_dirpath,'/',imod_folder,' -gpu 1 -start 4'])
 
else
    system(['batchruntomo -di ',template_filepath,' -ro ', stack_name ,' -current ' output_dirpath,'/',imod_folder, ' -deliver ' , output_dirpath,'/',imod_folder,' -gpu 1'])
end

tic
'Running clip rotx'
system(['cd ',output_dirpath,'/',imod_folder,'/',stack_name,'/ && clip rotx ',stack_name,'_full_rec.mrc ',stack_name,'_rec.mrc']);
toc

% Update TimeCapsule.txt log file
fileID = fopen([output_dirpath,'/TimeCapsule.txt'], 'a');
fprintf(fileID, '--- batchruntomo.log Contents ---\n');
fprintf(fileID, '%s\n', fileread(fullfile(output_dirpath, imod_folder, stack_name, 'batchruntomo.log')));
fclose(fileID);
disp('TimeCapsule.txt finished.');
disp(datetime('now', 'Format', 'HH:mm:ss'))

if strcmp(CryoCARE_prepare,'Yes')

    % Copy Eraser, Newst, Tilt .com files  and   .xf, .tlt, .xtilt   transformation files from Original to Even/Odd folder
    copyfile([output_dirpath,'/',imod_folder,'/',stack_name,'/eraser.com'],[output_dirpath,'/even/eraser.com'])
    copyfile([output_dirpath,'/',imod_folder,'/',stack_name,'/eraser.com'],[output_dirpath,'/odd/eraser.com'])
    copyfile([output_dirpath,'/',imod_folder,'/',stack_name,'/newst.com'], [output_dirpath,'/even/newst.com'])
    copyfile([output_dirpath,'/',imod_folder,'/',stack_name,'/newst.com'], [output_dirpath,'/odd/newst.com'])
    copyfile([output_dirpath,'/',imod_folder,'/',stack_name,'/tilt.com'],  [output_dirpath,'/even/tilt.com'])
    copyfile([output_dirpath,'/',imod_folder,'/',stack_name,'/tilt.com'],  [output_dirpath,'/odd/tilt.com'])
    copyfile([output_dirpath,'/',imod_folder,'/',stack_name,'/',stack_name,'.xf'],   [output_dirpath,'/even/',stack_name,'.xf'])
    copyfile([output_dirpath,'/',imod_folder,'/',stack_name,'/',stack_name,'.xf'],   [output_dirpath,'/odd/',stack_name,'.xf'])
    copyfile([output_dirpath,'/',imod_folder,'/',stack_name,'/',stack_name,'.tlt'],  [output_dirpath,'/even/',stack_name,'.tlt'])
    copyfile([output_dirpath,'/',imod_folder,'/',stack_name,'/',stack_name,'.tlt'],  [output_dirpath,'/odd/',stack_name,'.tlt'])
    copyfile([output_dirpath,'/',imod_folder,'/',stack_name,'/',stack_name,'.xtilt'],[output_dirpath,'/even/',stack_name,'.xtilt'])
    copyfile([output_dirpath,'/',imod_folder,'/',stack_name,'/',stack_name,'.xtilt'],[output_dirpath,'/odd/',stack_name,'.xtilt'])

    % Create Even/Odd tomograms using transformation files from Original reconstruction
                  'Running eraser.com on Even'
                  tic
                  system(['cd ',output_dirpath,'/even/ && submfg eraser.com']);
                  system(['cd ',output_dirpath,'/even/ && mv ',stack_name,'.mrc ',stack_name,'_notfixed.mrc']);
                  system(['cd ',output_dirpath,'/even/ && mv ',stack_name,'_fixed.mrc ',stack_name,'.mrc']);
                  toc
                  tic
                  'Running newst.com on Even'
    [status, ~] = system(['cd ',output_dirpath,'/even/ && submfg newst.com']);
                  toc
                  tic
                  'Running tilt.com on Even'
                  system(['cd ',output_dirpath,'/even/ && submfg tilt.com']);
                  toc
                  tic
                  'Running clip rotx for even stack'
                  disp(datetime('now', 'Format', 'HH:mm:ss'))
                  system(['cd ',output_dirpath,'/even/ && clip rotx ',stack_name,'_full_rec.mrc ',stack_name,'_rec.mrc']);
                  toc
                  % system(['tomocleanup -aligned ',output_dirpath,'/even/']);

                  'Running eraser.com on Odd'
                  tic
                  system(['cd ',output_dirpath,'/odd/ && submfg eraser.com']);
                  system(['cd ',output_dirpath,'/odd/ && mv ',stack_name,'.mrc ',stack_name,'_notfixed.mrc']);
                  system(['cd ',output_dirpath,'/odd/ && mv ',stack_name,'_fixed.mrc ',stack_name,'.mrc']);
                  toc
                  tic
                  'Running newst.com on Odd'
    [status, ~] = system(['cd ',output_dirpath,'/odd/ && submfg newst.com']);
                  toc
                  tic
                  'Running tilt.com on Odd'
                  system(['cd ',output_dirpath,'/odd/ && submfg tilt.com']);
                  toc
                  tic
                  'Running clip rotx for odd stack'
                  disp(datetime('now', 'Format', 'HH:mm:ss'))
                  system(['cd ',output_dirpath,'/odd/ && clip rotx ',stack_name,'_full_rec.mrc ',stack_name,'_rec.mrc']);
                  toc
                  % system(['tomocleanup -aligned ',output_dirpath,'/odd/']);

    % Adjust CryoCARE .json parameter files
    if ~exist([output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/'], 'dir'), mkdir([output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/']), end
    copyfile([cryo_path,'/train_data_config.json'],[output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/'])
    copyfile([cryo_path,'/train_config.json'],     [output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/'])
    copyfile([cryo_path,'/predict_config.json'],   [output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/'])
    system(['sed -i '''' "s|\"path\": \".*\"|\"path\": \"',            output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/\"|" ',output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/train_data_config.json']);
    system(['sed -i '''' "s|\"train_data\": \".*\"|\"train_data\": \"',output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/\"|" ',output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/train_config.json']);
    system(['sed -i '''' "s|\"path\": \".*\"|\"path\": \"',            output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/\"|" ',output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/train_config.json']);
    system(['sed -i '''' "s|\"path\": \".*\"|\"path\": \"',            output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/model_name.tar.gz\"|" ',output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/predict_config.json']);
    system(['sed -i '''' "s|\"output\": \".*\"|\"output\": \"',        output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/denoised.rec\"|" ',output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/predict_config.json']);
    system(sprintf('sed -i '''' "s/\\\"epochs\\\": [0-9]*/\\\"epochs\\\": %d/" %s/CryoCAREful/Bin_%d/train_config.json && sed -i '''' "s/\\\"steps_per_epoch\\\": [0-9]*/\\\"steps_per_epoch\\\": %d/" %s/CryoCAREful/Bin_%d/train_config.json', Epochs, output_dirpath, CryoCARE_bin, Steps, output_dirpath, CryoCARE_bin));
  
    if CryoCARE_bin == 1
        system(['sed -i '''' ''/\"even\": \[/,/],/c\\"even\": ["',     output_dirpath,'/even/',stack_name,'_rec.mrc"],'' ',output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/train_data_config.json']);
        system(['sed -i '''' ''/\"odd\": \[/,/],/c\\"odd\": ["',       output_dirpath,'/odd/', stack_name,'_rec.mrc"],'' ',output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/train_data_config.json']);
        system(['sed -i '''' "s|\"even\": \".*\"|\"even\": \"',        output_dirpath,'/even/',stack_name,'_rec.mrc\"|" ', output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/predict_config.json']);
        system(['sed -i '''' "s|\"odd\": \".*\"|\"odd\": \"',          output_dirpath,'/odd/', stack_name,'_rec.mrc\"|" ', output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/predict_config.json']);
    end 

    if isnumeric(CryoCARE_bin) && mod(CryoCARE_bin, 1) == 0 && CryoCARE_bin > 1
        % Use BinVol to bin Even/Odd tomograms for CryoCARE denoising
        disp(datetime('now', 'Format', 'HH:mm:ss'))
        'Creating Even Binned stack for CryoCARE'
        system(['binvol -binning ',num2str(CryoCARE_bin),' ',output_dirpath,'/even/',stack_name,'_rec.mrc ',output_dirpath,'/even/',stack_name,'_recBin',num2str(CryoCARE_bin),'.mrc']);
        disp(datetime('now', 'Format', 'HH:mm:ss'))  
        'Creating Odd Binned stack for CryoCARE'  
        system(['binvol -binning ',num2str(CryoCARE_bin),' ',output_dirpath,'/odd/', stack_name,'_rec.mrc ',output_dirpath,'/odd/', stack_name,'_recBin',num2str(CryoCARE_bin),'.mrc']);    
        system(['sed -i '''' ''/\"even\": \[/,/],/c\\"even\": ["',     output_dirpath,'/even/',stack_name,'_recBin',num2str(CryoCARE_bin),'.mrc"],'' ',output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/train_data_config.json']);
        system(['sed -i '''' ''/\"odd\": \[/,/],/c\\"odd\": ["',       output_dirpath,'/odd/', stack_name,'_recBin',num2str(CryoCARE_bin),'.mrc"],'' ',output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/train_data_config.json']);
        system(['sed -i '''' "s|\"even\": \".*\"|\"even\": \"',        output_dirpath,'/even/',stack_name,'_recBin',num2str(CryoCARE_bin),'.mrc\"|" ', output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/predict_config.json']);
        system(['sed -i '''' "s|\"odd\": \".*\"|\"odd\": \"',          output_dirpath,'/odd/', stack_name,'_recBin',num2str(CryoCARE_bin),'.mrc\"|" ', output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/predict_config.json']);
    end
    % Run CryoCARE
    if strcmp(CryoCARE_run,'Yes')
        system(['bash -c ''unset LD_LIBRARY_PATH && source ~/.bashrc && conda activate cryocare_11 && cryoCARE_extract_train_data.py --conf ',output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/train_data_config.json''']);
        system(['bash -c ''unset LD_LIBRARY_PATH && source ~/.bashrc && conda activate cryocare_11 && cryoCARE_train.py --conf ',             output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/train_config.json''']);
        system(['bash -c ''unset LD_LIBRARY_PATH && source ~/.bashrc && conda activate cryocare_11 && cryoCARE_predict.py --conf ',           output_dirpath,'/CryoCAREful/Bin_',num2str(CryoCARE_bin),'/predict_config.json''']);
    end
end

%%  VALIDATION PART
% Plot CTF defocus found in CTFcorrection.log
[status, defocus_str] = system(['grep "defocus\[" ', output_dirpath, '/', imod_folder, '/', stack_name, '/ctfcorrection.log | sed -E ''s/.*= ([0-9\.]+) microns/\1/''']);
defocus_values = str2double(strsplit(defocus_str));
titleCTF = strsplit(output_dirpath,"/");
fighandnm = figure; plot(defocus_values), xlabel('Slice Number'), ylabel('Defocus (microns)'), ylim([min(defocus_values)-0.1,max(defocus_values)+0.1]), title(['Defocus values across slices for ',[titleCTF{end-3},'/',titleCTF{end-2},'/',titleCTF{end-1}]],'Interpreter','none');
if ~exist([output_dirpath,'/',imod_folder,'/',stack_name,'/Validate_plots'], 'dir'), mkdir([output_dirpath,'/',imod_folder,'/',stack_name,'/Validate_plots']), end
exportgraphics(fighandnm, fullfile([output_dirpath,'/',imod_folder,'/',stack_name,'/Validate_plots/defocus_values.png']),"Resolution",70);

% Plot residuals per frame and ratio of measured/unknowns from Align.log
[~, data]  = system(['awk ''/resid-nm/{flag=1; next} flag && NF==0 {flag=0; exit} flag {print $NF}'' ',output_dirpath,'/',imod_folder,'/',stack_name,'/align.log | tr ''\n'' '' ''']);
[~, data2] = system(['grep "Ratio of total measured values to all unknowns =" ',output_dirpath,'/',imod_folder,'/',stack_name,'/align.log | sed ''s/^[^=]*= //''']);
resid = str2double(strsplit(strtrim(data)));
fighandnm = figure; plot(resid), xlabel('Frame'), ylabel('Residual (nm)'), title('Residuals from Align.log for each frames');
text(mean(xlim), max(ylim), ['Ratio of measured to unknowns =',data2], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 25);
if ~exist([output_dirpath,'/',imod_folder,'/',stack_name,'/Validate_plots'], 'dir'), mkdir([output_dirpath,'/',imod_folder,'/',stack_name,'/Validate_plots']), end
exportgraphics(fighandnm,fullfile([output_dirpath,'/',imod_folder, '/',stack_name,'/Validate_plots/residual_values.png']),"Resolution",25);


%% FUNCTIONS

% Function for Frame exclusion GUI + writing Exclude_views.txt
function keep_list = Exclude_views(mrc_file)
    [mrc_path, mrcname, mrcext] = fileparts(mrc_file)
    slice_output = [mrc_path,'/Slices/'];
    if exist([slice_output,'/Exclude_views.txt']), system(['rm ',slice_output,'/Exclude_views.txt']), end
    if ~exist(slice_output, 'dir'), mkdir(slice_output), end
    
    % system(['3dmod ',mrc_file])
    system(['mrc2tif -C b,w ',mrc_path,'/',mrcname,mrcext,' ',slice_output,'/slice']) 
    
    files = dir([slice_output,'/*.tif']);
    nFiles = length(files);
    status = zeros(nFiles,1);
    k=1;
    while k < nFiles+1
        img = imread([files(k).folder, '/', files(k).name]);
        img = imadjust(img);
        imshow(img);
        xlabel('Left click: Accept.  Right click: Reject.  Middle click: Return to previous. ''s'' to accept and skip 5 images', 'Color', 'red', 'FontSize', 50, 'FontWeight', 'bold');
        title(['Image ', num2str(k), ' of ', num2str(nFiles), ': ', files(k).name],'FontSize', 50);
        [~,~,button] = ginput(1);
        if button == 1              % Left click to keep
            status(k) = 1;
            ['Image ',num2str(k),' is kept']
            k=k+1;
        elseif button == 3          % Right click to reject
            status(k) = 0;
            ['Image ',num2str(k),' is rejected']
            k=k+1;
        elseif button == 2          % Middle click to go back
            status(k) = 0;
            ['Going back to image ',num2str(k-1)]
            if k>1, k=k-1; end
        elseif button == 115        % 's' key to skip and accept 5 images
            status(k:k+4) = 1;  
            ['Skipping and keeping images ',num2str(k),' up to image ',num2str(min(k+4, nFiles))]
            k=k+5;
        end
    end
    close gcf
    
    keep_list = status(1:nFiles);
    writematrix(keep_list, [slice_output,'/Exclude_views.txt'], 'Delimiter', 'tab');
end

function SortEvenOdd(frame_dirpath,output_dirpath)
    mkdir(fullfile(output_dirpath, 'even'));
    mkdir(fullfile(output_dirpath, 'odd'));
    files = dir(fullfile(frame_dirpath, 'faimg-*.mrc'));
    for i = 1:length(files)
        file = files(i).name;
        num = str2double(regexp(file, '\d+', 'match', 'once'));
        if mod(num, 2) == 0
            movefile(fullfile(frame_dirpath, file), fullfile(output_dirpath, 'even', file));
        else
            movefile(fullfile(frame_dirpath, file), fullfile(output_dirpath, 'odd', file));
        end
    end
    fprintf("Files moved to 'even' and 'odd' folders.\n");
end

function NAV
    if system('test -x ./NAV.sh'), system('chmod +x ./NAV.sh'), end
    system('./NAV.sh ');
end

