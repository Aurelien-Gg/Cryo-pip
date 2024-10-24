% This script can be run from anywhere as long as full paths are provided
% !! Stack file "<stack_name>.mrc", Metadata file "<stack_name>.mdoc", and Gain file <gain_flipx.dm4>  need to be in same folder as frames !! Currently uses the first .mdoc file it finds in folder (should be changed)

%% MODIFY PATHS TO FIT YOUR CONFIG
% Enter required filepaths (! don't forget to add '/' at the end for paths):
template_filepath = '/mnt/nas/FAC/FBM/DMF/pnavarr1/default/D2c/CL31/Testing/AwesomeComs/AurelienTemplate241024.adoc';    % Path of template file
cryo_path         = '/mnt/nas/FAC/FBM/DMF/pnavarr1/default/D2c/CL31/Testing/AwesomeComs/CryoCarefulComs/';               % Path of cryocare json files
frame_dirpath     = '/mnt/nas/FAC/FBM/DMF/pnavarr1/default/D2c/cryoCARE/Boston_Paula/test/';                             % Path of Stack/Metadata/Gain file
gain_path         = ''; % Optional gain path. If left empty it will take the one in 'frame_direpath'
% Choose output names:
stack_name        = 'stack_AF';           % Choose name for .mrc stack output
output_dirpath    = frame_dirpath;        % Choose directory path to output files (USE FULL PATH). Usually same as frame_directory
imod_folder       = 'imod';               % Choose directory that will be created to output results of Alignframes







%% DON'T MODIFIY THE FOLLOWING:
%% OPTIONAL EXCLUDING BAD SUBFRAMES % This creates new .tiff files where certain subframes (here 0 and 1) have been removed. Should probably always remove even number of frames since will be split in odd and even
% status = system(['mkdir ',frame_dirpath,'/Backup/ && cp ',frame_dirpath,'/*_fractions.tiff ',frame_dirpath,'/Backup/'])
% status = system(['for file in ',frame_dirpath,'/*_fractions.tiff; do newstack -exclude 0,1 "$file" temp_output.tiff && mv temp_output.tiff "$file"; done']);

%% PROCESSING PART
% Run ALIGN FRAMES using  AF_atoz.sh
status = system(['./AF_IMODCryo.sh -input ', frame_dirpath, ' -output ',output_dirpath,' -name ', imod_folder, ' -stack ', stack_name, '-gain ', gain_path]), if status ~= 0,    error('1Command failed with status %d', status), end

% Sort EVEN / ODD frame-aligned images into /even/ and /odd/ folder
status = system(['/mnt/nas/FAC/FBM/DMF/pnavarr1/default/D2c/CL31/Testing/BestScripts/CryoCareful/SortEvenOdd.sh ', frame_dirpath])                      , if status ~= 0,    error('2Command failed with status %d', status), end

% Run Processing using  BATCHRUNTOMO
status = system(['batchruntomo -di ', template_filepath,' -ro ', stack_name ,' -current ' output_dirpath, imod_folder, ' -deliver ' , output_dirpath,imod_folder,' -gpu 1']), if status ~= 0,    error('3Command failed with status %d', status), end

% Prepare EVEN and ODD files to run CryoCAREful
status = system(['newstack $(ls ',frame_dirpath,'even/faimg-*.mrc | sort -V) ', frame_dirpath,'/even/faimg-even.mrc'])                                  , if status ~= 0,    error('4Command failed with status %d', status), end
status = system(['newstack $(ls ',frame_dirpath,'odd/faimg-*.mrc | sort -V) ',  frame_dirpath,'/odd/faimg-odd.mrc'])                                    , if status ~= 0,    error('5Command failed with status %d', status), end
copyfile([output_dirpath, imod_folder,'/',stack_name,'/',stack_name,'.rawtlt'], [frame_dirpath,'/even/faimg-even.rawtlt'])
copyfile([output_dirpath, imod_folder,'/',stack_name,'/',stack_name,'.rawtlt'], [frame_dirpath,'/odd/faimg-odd.rawtlt'])

% Run BATCHRUNTOMO on EVEN and ODD
status = system(['batchruntomo -di ', template_filepath,' -ro faimg-even -current ' output_dirpath, 'even/ -deliver ' , output_dirpath, 'even/ -gpu 1']), if status ~= 0,    error('6Command failed with status %d', status), end
status = system(['batchruntomo -di ', template_filepath,' -ro faimg-odd  -current ' output_dirpath, 'odd/  -deliver ' , output_dirpath, 'odd/  -gpu 1']), if status ~= 0,    error('7Command failed with status %d', status), end

% Prepare and run CryoCARE prediction
if ~exist([output_dirpath, imod_folder,'/',stack_name,'/CryoCAREful'], 'dir'), mkdir([output_dirpath, imod_folder,'/',stack_name,'/CryoCAREful']), end
copyfile([cryo_path,'/train_data_config.json'], [output_dirpath, imod_folder,'/',stack_name,'/CryoCAREful/'])
copyfile([cryo_path,'/train_config.json'], [output_dirpath, imod_folder,'/',stack_name,'/CryoCAREful/'])
copyfile([cryo_path,'/predict_config.json'], [output_dirpath, imod_folder,'/',stack_name,'/CryoCAREful/'])


status = system(['sed -i "s|\"even\": \".*\"|\"even\": \"',output_dirpath, 'even/faimg-even/faimg-even_rec.mrc\"|" ',output_dirpath, imod_folder,'/',stack_name,'/CryoCAREful/train_data_config.json']);
status = system(['sed -i "s|\"odd\": \".*\"|\"odd\": \"',  output_dirpath, 'odd/faimg-odd/faimg-odd_rec.mrc\"|" ',   output_dirpath, imod_folder,'/',stack_name,'/CryoCAREful/train_data_config.json']);
status = system(['sed -i "s|\"path\": \".*\"|\"path\": \"',output_dirpath,imod_folder,'/',stack_name,'/CryoCAREful/\"|" ',output_dirpath, imod_folder,'/',stack_name,'/CryoCAREful/train_data_config.json']);
status = system(['sed -i "s|\"train_data\": \".*\"|\"train_data\": \"',output_dirpath,imod_folder,'/',stack_name,'/CryoCAREful/\"|" ',output_dirpath, imod_folder,'/',stack_name,'/CryoCAREful/train_config.json']);
status = system(['sed -i "s|\"path\": \".*\"|\"path\": \"',output_dirpath,imod_folder,'/',stack_name,'/CryoCAREful/\"|" ',output_dirpath, imod_folder,'/',stack_name,'/CryoCAREful/train_config.json']);
status = system(['sed -i "s|\"path\": \".*\"|\"path\": \"',output_dirpath,imod_folder,'/',stack_name,'/CryoCAREful/model_name.tar.gz\"|" ',output_dirpath, imod_folder,'/',stack_name,'/CryoCAREful/predict_config.json']);
status = system(['sed -i "s|\"even\": \".*\"|\"even\": \"',output_dirpath, 'even/faimg-even/faimg-even_rec.mrc\"|" ', output_dirpath, imod_folder,'/',stack_name,'/CryoCAREful/predict_config.json']);
status = system(['sed -i "s|\"odd\": \".*\"|\"odd\": \"',  output_dirpath, 'odd/faimg-odd/faimg-odd_rec.mrc\"|" ',    output_dirpath, imod_folder,'/',stack_name,'/CryoCAREful/predict_config.json']);
status = system(['sed -i "s|\"output\": \".*\"|\"output\": \"',output_dirpath,imod_folder,'/',stack_name,'/CryoCAREful/denoised.rec\"|" ',output_dirpath,imod_folder,'/',stack_name,'/CryoCAREful/predict_config.json']);
% status = system(['bash -c ''source ~/.bashrc && conda activate cryocare_11 && cryoCARE_extract_train_data.py --conf ', output_dirpath, imod_folder, '/', stack_name, '/CryoCAREful/train_data_config.json'''])
% status = system(['bash -c ''source ~/.bashrc && conda activate cryocare_11 && cryoCARE_train.py --conf ', output_dirpath, imod_folder, '/', stack_name, '/CryoCAREful/train_config.json'''])
% status = system(['bash -c ''source ~/.bashrc && conda activate cryocare_11 && cryoCARE_predict.py --conf ', output_dirpath, imod_folder, '/', stack_name, '/CryoCAREful/predict_config.json'''])


%%  VALIDATION PART
% Plot CTF defocus found in CTFcorrection.log
[status, defocus_str] = system(['grep -oP "defocus\[\d+\] = \K[0-9\.]+" ',output_dirpath,imod_folder,'/',stack_name,'/ctfcorrection.log']);
if status ~= 0,    error('3Command failed with status %d', status), else
    defocus_values = str2double(strsplit(defocus_str));
    titleCTF = strsplit(frame_dirpath,"/");
    figure,     plot(defocus_values),    xlabel('Slice Number'),    ylabel('Defocus (microns)'),    ylim([min(defocus_values)-0.1,max(defocus_values)+0.1]), title(['Defocus values across slices for ',[titleCTF{end-3},'/',titleCTF{end-2},'/',titleCTF{end-1}]],'Interpreter','none');
    if ~exist([output_dirpath, imod_folder, '/', stack_name, '/Validate_plots'], 'dir'), mkdir([output_dirpath, imod_folder, '/', stack_name, '/Validate_plots']), end
    exportgraphics(fighandnm, fullfile([output_dirpath, imod_folder, '/', stack_name, '/Validate_plots/defocus_values.png']),"Resolution",70);
end
% Plot residuals per frame and ratio of measured/unknowns from Align.log
[~, data]  = system(['awk ''/resid-nm/{flag=1; next} flag && NF==0 {flag=0; exit} flag {print $NF}'' ', output_dirpath, imod_folder, '/', stack_name, '/align.log | tr ''\n'' '' ''']);
[~, data2] = system(['grep "Ratio of total measured values to all unknowns =" ', output_dirpath, '/', imod_folder, '/', stack_name, '/align.log | sed ''s/^[^=]*= //''']);
resid = str2double(strsplit(strtrim(data)));
fighandnm = figure, plot(resid), xlabel('Frame'), ylabel('Residual (nm)'), title('Residuals from Align.log for each frames');
text(mean(xlim), max(ylim), ['Ratio of measured to unknowns =',data2], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 70);
if ~exist([output_dirpath, imod_folder, '/', stack_name, '/Validate_plots'], 'dir'), mkdir([output_dirpath, imod_folder, '/', stack_name, '/Validate_plots']), end
exportgraphics(fighandnm, fullfile([output_dirpath, imod_folder, '/', stack_name, '/Validate_plots/residual_values.png']),"Resolution",70);


%% Open reconstructed tomogram
system(['3dmod ',output_dirpath,imod_folder,'/',stack_name,'/',stack_name,'_rec.mrc'])
% system(['3dmod ',output_dirpath,imod_folder,'/',stack_name,'/',stack_name,'_ali.mrc'])
% system(['3dmod ',output_dirpath,imod_folder,'/',stack_name,'/CryoCAREful/denoised.rec/faimg-even_rec.mrc'])

