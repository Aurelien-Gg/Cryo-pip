function keep_list = Exclude_views(mrc_file)

% mrc_file = '/mnt/nas/FAC/FBM/DMF/pnavarr1/default/D2c/CL31/Testing/PaulaNavarro_20231129_NAR_3/FullPipe/frames/imod/stack_AF/stack_AF.mrc';
% slice_output = '/mnt/nas/FAC/FBM/DMF/pnavarr1/default/D2c/CLg31/Testing/PaulaNavarro_20231129_NAR_3/FullPipe/frames/imod/stack_AF/Slices';
[mrc_path, mrcname, mrcext] = fileparts(mrc_file)
slice_output = [mrc_path,'/Slices/'];
if exist([slice_output,'/Exclude_views.txt']), system(['rm ',slice_output,'/Exclude_views.txt']), end
if ~exist(slice_output, 'dir'), mkdir(slice_output), end

% system(['newstack -bin 4 ',mrc_file,' ',slice_output,'/',mrcname,'bin4',mrcext])
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
    elseif button == 115          % 's' key to skip and accept 5 images
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