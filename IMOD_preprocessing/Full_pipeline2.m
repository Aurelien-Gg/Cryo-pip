% This script can be run from anywhere as long as full paths are provided
% !! Stack file "<stack_name>.mrc", Metadata file "<stack_name>.mdoc", and Gain file <gain_flipx.dm4>  need to be in same folder as frames !! Currently uses the first .mdoc file it finds in folder (should be changed)

%% MODIFY THE FOLLOWING TO FIT YOUR CONFIG
% Enter required filepaths (! don't forget to add '/' at the end for paths):
template_filepath  = '/mnt/nas/FAC/FBM/DMF/pnavarr1/default/D2c/CL31/Testing/BestScripts/Git/ConfigurationFiles/AurelienTemplate241024.adoc';    % FILEPATH of '.adoc' template file
cryo_path          = '/mnt/nas/FAC/FBM/DMF/pnavarr1/default/D2c/CL31/Testing/BestScripts/Git/CryoCARE';               % PATH of the 3 cryocare json files
frame_dirpath      = '/mnt/nas/FAC/FBM/DMF/pnavarr1/default/D2c/cryoCARE/Boston_Paula/TestExclude';                             % PATH of Stack/Metadata/Gain file
gain_path          = '/mnt/nas/FAC/FBM/DMF/pnavarr1/default/D2c/cryoCARE/Boston_Paula/TestExclude';                             % PATH to gain file. Optional, if left empty it will take the one in 'frame_dirpath'

% Choose output names (or leave these default):
stack_name         = 'stack_AF';           % Choose name for .mrc stack output
output_dirpath     = frame_dirpath;        % Choose PATH to output files (USE FULL PATH). Usually same as 'frame_dirpath'
imod_folder        = 'imod';               % Choose directory name that will be created to output results of Alignframes

Exclude            = 'Yes';   % 'Yes' If you want to be prompted to select Frames to exclude from processing
Overwrite_existing = 'Yes';  % 'Yes' If you want to overwrite existing Frames selection that are in Exclude_views.txt

%% DON'T MODIFIY THE FOLLOWING:
%% PROCESSING PART

keep_list = ones(length(10),1); 
if strcmp(Exclude,'Yes')
    mkdir([frame_dirpath,'/temp'])
    tic
    system(['cd ',frame_dirpath,' && alignframes -mdoc ',frame_dirpath,'/*mdoc -output ',output_dirpath,'/temp/Temp_AF.mrc -adjust -binning 16,8 -gain ',gain_path,'/*dm4 -pi 1.35'])
    toc
    if exist([output_dirpath,'/temp/Slices/Exclude_views.txt'])
        if strcmp(Overwrite_existing,'Yes')
            keep_list = Exclude_views([frame_dirpath,'/temp/Temp_AF.mrc']);
        else
            keep_list = readmatrix([frame_dirpath,'/temp/Slices/Exclude_views.txt']);
        end
    end
    if ~exist([output_dirpath,'/temp/Slices/Exclude_views.txt'])
        keep_list = Exclude_views([frame_dirpath,'/temp/Temp_AF.mrc']);
    end
end
indices = find(keep_list == 0); indices_str = sprintf('%d,', indices); indices_str(end) = [];

mkdir([output_dirpath,'/',imod_folder])
system(['cd ',frame_dirpath,' && alignframes -mdoc ',frame_dirpath,'/*mdoc -output ',output_dirpath,'/',imod_folder,'/',stack_name,'.mrc -adjust -binning 8,2 -gain ',gain_path,'/*dm4 -pi 1.35 -debug 10000'])

if ~system('test -x ./SortEvenOdd.sh'), system('chmod +x ./SortEvenOdd.sh'), end
system(['./SortEvenOdd.sh ',frame_dirpath])

system(['newstack $(ls ',output_dirpath,'/even/faimg-*.mrc | sort -V) ',output_dirpath,'/even/',stack_name,'.mrc'])
system(['newstack $(ls ',output_dirpath,'/odd/faimg-*.mrc | sort -V) ', output_dirpath, '/odd/',stack_name,'.mrc']) 
if ~all(keep_list == 1)
system(['excludeviews -delete -views ', indices_str,' -StackName ',output_dirpath,'/',imod_folder,'/',stack_name,'.mrc'])
system(['excludeviews -delete -views ', indices_str,' -StackName ',output_dirpath,'/even/',stack_name,'.mrc'])
system(['excludeviews -delete -views ', indices_str,' -StackName ',output_dirpath,'/odd/',stack_name,'.mrc'])  
end

system(['batchruntomo -di ',template_filepath,' -ro ', stack_name ,' -current ' output_dirpath,'/',imod_folder, ' -deliver ' , output_dirpath,'/',imod_folder,' -gpu 1'])

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

system(['cd ',output_dirpath,'/even/ && submfg eraser.com'])
system(['cd ',output_dirpath,'/even/ && submfg newst.com'])
system(['cd ',output_dirpath,'/even/ && submfg tilt.com'])
system(['cd ',output_dirpath,'/even/ && trimvol -f -rx ',stack_name,'_full_rec.mrc ',stack_name,'_rec.mrc'])
system(['cd ',output_dirpath,'/odd/ && submfg eraser.com'])
system(['cd ',output_dirpath,'/odd/ && submfg newst.com'])
system(['cd ',output_dirpath,'/odd/ && submfg tilt.com'])
system(['cd ',output_dirpath,'/odd/ && trimvol -f -rx ',stack_name,'_full_rec.mrc ',stack_name,'_rec.mrc'])


%% Prepare CryoCARE configuration files
if ~exist([output_dirpath,'/',imod_folder,'/',stack_name,'/CryoCAREful'], 'dir'), mkdir([output_dirpath,'/',imod_folder,'/',stack_name,'/CryoCAREful']), end
copyfile([cryo_path,'/train_data_config.json'],[output_dirpath,'/',imod_folder,'/',stack_name,'/CryoCAREful/'])
copyfile([cryo_path,'/train_config.json'],     [output_dirpath,'/',imod_folder,'/',stack_name,'/CryoCAREful/'])
copyfile([cryo_path,'/predict_config.json'],   [output_dirpath,'/',imod_folder,'/',stack_name,'/CryoCAREful/'])

system(['sed -i ''/\"even\": \[/,/],/c\\"even\": ["',output_dirpath,'/even/',stack_name,'_rec.mrc"],'' ',output_dirpath, '/', imod_folder, '/', stack_name, '/CryoCAREful/train_data_config.json']);
system(['sed -i ''/\"odd\": \[/,/],/c\\"odd\": ["',  output_dirpath,'/odd/',stack_name,'_rec.mrc"],'' ',  output_dirpath, '/', imod_folder, '/', stack_name, '/CryoCAREful/train_data_config.json']);
system(['sed -i "s|\"path\": \".*\"|\"path\": \"',   output_dirpath,'/',imod_folder,'/',stack_name,'/CryoCAREful/\"|" ',output_dirpath,'/', imod_folder,'/',stack_name,'/CryoCAREful/train_data_config.json']);

system(['sed -i "s|\"train_data\": \".*\"|\"train_data\": \"',output_dirpath,'/',imod_folder,'/',stack_name,'/CryoCAREful/\"|" ',output_dirpath,'/', imod_folder,'/',stack_name,'/CryoCAREful/train_config.json']);
system(['sed -i "s|\"path\": \".*\"|\"path\": \"',output_dirpath,'/',imod_folder,'/',stack_name,'/CryoCAREful/\"|" ',output_dirpath,'/', imod_folder,'/',stack_name,'/CryoCAREful/train_config.json']);

system(['sed -i "s|\"path\": \".*\"|\"path\": \"',output_dirpath,'/',imod_folder,'/',stack_name,'/CryoCAREful/model_name.tar.gz\"|" ',output_dirpath,'/', imod_folder,'/',stack_name,'/CryoCAREful/predict_config.json']);
system(['sed -i "s|\"even\": \".*\"|\"even\": \"',output_dirpath, '/even/',stack_name,'_rec.mrc\"|" ',output_dirpath,'/',imod_folder,'/',stack_name,'/CryoCAREful/predict_config.json']);
system(['sed -i "s|\"odd\": \".*\"|\"odd\": \"',  output_dirpath, '/odd/',stack_name,'_rec.mrc\"|" ',  output_dirpath,'/',imod_folder,'/',stack_name,'/CryoCAREful/predict_config.json']);
system(['sed -i "s|\"output\": \".*\"|\"output\": \"',output_dirpath,'/',imod_folder,'/',stack_name,'/CryoCAREful/denoised.rec\"|" ',output_dirpath,'/',imod_folder,'/',stack_name,'/CryoCAREful/predict_config.json']);

%%  VALIDATION PART
% Plot CTF defocus found in CTFcorrection.log
[status, defocus_str] = system(['grep "defocus\[" ', output_dirpath, '/', imod_folder, '/', stack_name, '/ctfcorrection.log | sed -E ''s/.*= ([0-9\.]+) microns/\1/''']);

defocus_values = str2double(strsplit(defocus_str));
titleCTF = strsplit(frame_dirpath,"/");
fighandnm = figure, plot(defocus_values), xlabel('Slice Number'), ylabel('Defocus (microns)'), ylim([min(defocus_values)-0.1,max(defocus_values)+0.1]), title(['Defocus values across slices for ',[titleCTF{end-3},'/',titleCTF{end-2},'/',titleCTF{end-1}]],'Interpreter','none');
if ~exist([output_dirpath,'/',imod_folder,'/',stack_name,'/Validate_plots'], 'dir'), mkdir([output_dirpath,'/',imod_folder,'/',stack_name,'/Validate_plots']), end
exportgraphics(fighandnm, fullfile([output_dirpath,'/',imod_folder,'/',stack_name,'/Validate_plots/defocus_values.png']),"Resolution",70);

% Plot residuals per frame and ratio of measured/unknowns from Align.log
[~, data]  = system(['awk ''/resid-nm/{flag=1; next} flag && NF==0 {flag=0; exit} flag {print $NF}'' ',output_dirpath,'/',imod_folder,'/',stack_name,'/align.log | tr ''\n'' '' ''']);
[~, data2] = system(['grep "Ratio of total measured values to all unknowns =" ',output_dirpath,'/',imod_folder,'/',stack_name,'/align.log | sed ''s/^[^=]*= //''']);
resid = str2double(strsplit(strtrim(data)));
fighandnm = figure, plot(resid), xlabel('Frame'), ylabel('Residual (nm)'), title('Residuals from Align.log for each frames');
text(mean(xlim), max(ylim), ['Ratio of measured to unknowns =',data2], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 70);
if ~exist([output_dirpath,'/',imod_folder,'/',stack_name,'/Validate_plots'], 'dir'), mkdir([output_dirpath,'/',imod_folder,'/',stack_name,'/Validate_plots']), end
exportgraphics(fighandnm,fullfile([output_dirpath,'/',imod_folder, '/',stack_name,'/Validate_plots/residual_values.png']),"Resolution",70);


%% Open reconstructed tomogram
system(['3dmod ',output_dirpath,'/',imod_folder,'/',stack_name,'/',stack_name,'_rec.mrc'])
system(['3dmod ',output_dirpath,'/even/',stack_name,'_rec.mrc'])
system(['3dmod ',output_dirpath,'/odd/',stack_name,'_rec.mrc'])

%% Function for Frame exclusion GUI + writing Exclude_views.txt
function keep_list = Exclude_views(mrc_file)

[mrc_path, mrcname, mrcext] = fileparts(mrc_file)
slice_output = [mrc_path,'/Slices/'];
if exist([slice_output,'/Exclude_views.txt']), system(['rm ',slice_output,'/Exclude_views.txt']), end
if ~exist(slice_output, 'dir'), mkdir(slice_output), end

system(['3dmod ',mrc_file])
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
        ['Skipping and keeping images ',num2str(k),' up to image ',num2str(k+4)]
        k=k+5;
    end
end
close gcf

% Save the status information for later use
keep_list = status(1:nFiles);
writematrix(keep_list, [slice_output,'/Exclude_views.txt'], 'Delimiter', 'tab');
end