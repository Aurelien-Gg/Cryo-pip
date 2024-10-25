% This script can be run from anywhere as long as full paths are provided
% Position and "Resolution" (in exportgraphics command) might be User dependent so change as you see fit

%% MODIFY PATHS TO FIT YOUR CONFIG

search_dirpath  = '/mnt/nas/FAC/FBM/DMF/pnavarr1/default/D2c/CL31/raw/PaulaNavarro_20231129_NAR_3/'; % Directory to search in
save_images     = 'YfdfdES';                   % 'YES' : Choose if images are to be saved (in same folder as where the align.log and CTFcorrection.log files are) 

figPosition     = [997   653   966   552]; % Just to resize the figures so the title fit.
Resolution      = 70;                      % DPI of images to be saved

%% DON'T MODIFIY THE FOLLOWING:
% Plot CTF defocus found in CTFcorrection.log
[status, defocus_str] = system(['find ', search_dirpath ' -type f -name "ctfcorrection.log" -exec sh -c ''echo {}; grep -oP "^defocus\[\d+\] = \K[0-9\.]+" {}'' \;']);
if status ~= 0,    error('3Command failed with status %d', status), else
    lines = regexp(defocus_str, '\r?\n', 'split');
    filepaths = {};
    defocus_values = {};
    for i = 1:length(lines)
        line = strtrim(lines{i});    
        if endsWith(line, 'ctfcorrection.log')
            filepaths{end+1} = line;
            defocus_values{end+1} = []; 
        else
            defocus_values{end}(end+1) = str2double(line);
        end
    end
    for i = 1:length(filepaths)
        fighand = figure('Name', filepaths{i}, 'NumberTitle', 'off');
        plot(defocus_values{i}, '-o','MarkerSize',12, 'LineWidth',2), hold on, grid on;
        set(fighand, 'Position', figPosition);
        titleCTF = strsplit(filepaths{i},"/");
        title(['Defocus from CTFcorrection.log for each frames for ',[titleCTF{end-5},'/',titleCTF{end-4},'/',titleCTF{end-3},'/',titleCTF{end-2},'/',titleCTF{end-1}]],'Interpreter','none')
        xlabel('Index'),     ylabel('Defocus Value (micron)');
        drawnow
        if strcmp(save_images,'YES')
            output_plot_dir = fullfile(fileparts(filepaths{i}), 'Validate_plots');
            if ~exist(output_plot_dir, 'dir'), mkdir(output_plot_dir), end
            exportgraphics(fighand, fullfile(output_plot_dir,'defocus_values.png'),"Resolution",Resolution);
        end
    end
end

% Plot residuals per frame from Align.log
[status, residnm] = system(['find ', search_dirpath, ' -type f -name "align.log" -exec sh -c ''echo "{}"; awk "/resid-nm/ {flag=1; next} flag && /^[[:space:]]*[0-9]/ {print \$NF} flag && !/^[[:space:]]*[0-9]/ {exit}" "{}"'' \;']);
[status2, data2] = system(['find ', search_dirpath, ' -type f -name "align.log" -exec sh -c ''grep "Ratio of total measured values to all unknowns =" "{}" | sed "s/^[^=]*= //"'' \;']);
tokens = regexp(data2, '(\d+)/\s*(\d+)\s*=\s*([\d.]+)', 'tokens');

if status ~= 0,    error('3Command failed with status %d', status), else
    linesnm = regexp(residnm, '\r?\n', 'split');
    filepathsnm = {};
    residual_values = {};
    for i = 1:length(linesnm)
        line = strtrim(linesnm{i});    
        if endsWith(line, 'align.log')
            filepathsnm{end+1} = line;
            residual_values{end+1} = []; 
        else
            residual_values{end}(end+1) = str2double(line);
        end
    end
    for i = 1:length(filepathsnm)
        fighandnm = figure('Name', filepathsnm{i}, 'NumberTitle', 'off');
        plot(residual_values{i}, '-o','MarkerSize',12, 'LineWidth',2), hold on, grid on;
        set(fighandnm, 'Position', figPosition);
        titleAlign = strsplit(filepathsnm{i},"/");
        title(['Residuals from Align.log for each frames for ',[titleAlign{end-5},'/',titleAlign{end-4},'/',titleAlign{end-3},'/',titleAlign{end-2},'/',titleAlign{end-1}]],'Interpreter','none')
        text(mean(xlim), max(ylim), ['Ratio of measured to unknowns =',tokens{i}{1},'/',tokens{i}{2},' = ',tokens{1}{3}], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 70);
        xlabel('Index'),     ylabel('Residual Value (nm)');
        drawnow
        if strcmp(save_images,'YES')
            output_plot_dir = fullfile(fileparts(filepathsnm{i}), 'Validate_plots');
            if ~exist(output_plot_dir, 'dir'), mkdir(output_plot_dir), end
            exportgraphics(fighandnm, fullfile(output_plot_dir,'residual_values.png'),"Resolution",Resolution);
        end
    end
end


