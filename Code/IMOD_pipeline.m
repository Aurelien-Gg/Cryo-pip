% This script can be run from anywhere as long as full paths are provided
% !! Stack file "<stack_name>.mrc", Metadata file "<stack_name>.mdoc", and Gain file <gain_flipx.dm4>  need to be in same folder as frames !! Currently uses the first .mdoc file it finds in folder (should be changed)

%% MODIFY PATHS TO FIT YOUR CONFIG
% Enter required filepaths:
template_filepath = '/mnt/nas/FAC/FBM/DMF/pnavarr1/default/D2c/CL31/Testing/AwesomeComs/AurelienTemplate241024.adoc';  % Path of template file
cryo_path         = '/mnt/nas/FAC/FBM/DMF/pnavarr1/default/D2c/CL31/Testing/AwesomeComs/CryoCarefulComs/';               % Path of cryocare json files
frame_dirpath     = '/mnt/nas/FAC/FBM/DMF/pnavarr1/default/D2c/cryoCARE/Boston_Paula/test/';                             % Path of Stack/Metadata/Gain file
gain_path         = ''; % Optional gain path. If left empty it will take the one in 'frame_dirpath'.
% Choose output names:
stack_name        = 'stack_AF';           % Choose name for .mrc stack output
output_dirpath    = frame_dirpath;        % Choose directory path to output files. Usually same as frame_directory
imod_folder       = 'imod';               % Choose directory that will be created to output results of Alignframes







%% DON'T MODIFIY THE FOLLOWING:
%% OPTIONAL EXCLUDING BAD SUBFRAMES % This creates new .tiff files where certain subframes (here 0 and 1) have been removed. Should probably always remove even number of frames since will be split in odd and even
% status = system(['mkdir ',frame_dirpath,'/Backup/ && cp ',frame_dirpath,'/*_fractions.tiff ',frame_dirpath,'/Backup/'])
% status = system(['for file in ',frame_dirpath,'/*_fractions.tiff; do newstack -exclude 0,1 "$file" temp_output.tiff && mv temp_output.tiff "$file"; done']);

%% PROCESSING PART
% Run ALIGN FRAMES using  AF_imod.sh
status = system(['./AF_IMOD.sh -input ', frame_dirpath, ' -output ',output_dirpath,' -name ', imod_folder, ' -stack ', stack_name, '-gain ', gain_path]), if status ~= 0,    error('1Command failed with status %d', status), end

% Run Processing using  BATCHRUNTOMO
status = system(['batchruntomo -di ', template_filepath,' -ro ', stack_name ,' -current ' output_dirpath, imod_folder, ' -deliver ' , output_dirpath,imod_folder,' -gpu 1']), if status ~= 0,    error('3Command failed with status %d', status), end

%%  VALIDATION PART
% Plot CTF defocus found in CTFcorrection.log
[status, defocus_str] = system(['grep -oP "defocus\[\d+\] = \K[0-9\.]+" ',output_dirpath,imod_folder,'/',stack_name,'/ctfcorrection.log']); % ADD GRAB RATIO OF KNOWNS
if status ~= 0,    error('3Command failed with status %d', status), else
    defocus_values = str2double(strsplit(defocus_str));
    titleCTF = strsplit(frame_dirpath,"/");
    figure,     plot(defocus_values),    xlabel('Slice Number'),    ylabel('Defocus (microns)'),    ylim([min(defocus_values)-0.1,max(defocus_values)+0.1]), title(['Defocus values across slices for ',[titleCTF{end-3},'/',titleCTF{end-2},'/',titleCTF{end-1}]],'Interpreter','none');
end
% Plot residuals per frame and ratio of measured/unknowns from Align.log
[~, data]  = system(['awk ''/resid-nm/{flag=1; next} flag && NF==0 {flag=0; exit} flag {print $NF}'' ', output_dirpath, imod_folder, '/', stack_name, '/align.log | tr ''\n'' '' ''']);
[~, data2] = system(['grep "Ratio of total measured values to all unknowns =" ', output_dirpath, '/', imod_folder, '/', stack_name, '/align.log | sed ''s/^[^=]*= //''']);
resid = str2double(strsplit(strtrim(data)));
figure, plot(resid), xlabel('Frame'), ylabel('Residual (nm)'), title('Residuals from Align.log for each frames');
text(mean(xlim), max(ylim), ['Ratio of measured to unknowns =',data2], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 70);

%% Open reconstructed tomogram
system(['3dmod ',output_dirpath,imod_folder,'/',stack_name,'/',stack_name,'_rec.mrc'])