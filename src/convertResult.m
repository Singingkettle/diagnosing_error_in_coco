function convertResult(detector_name, model_input_type, set_name, categories, im_format, img_void, coco_dt)
% 
%  The result format of coco is json. For evalution, it should be converted
%  to txt format.
%  
%  -detector_name          eg:ssd
%  -model_input            eg:300X300
%  -set_name               eg:coco val2014
%  -categories             detection output classes
%  -im_format              
%  -coco_dt                information about detection result

im_format = im_format(1:end-4);
% =========================================================================
% Build the directories to save the converted results..
% =========================================================================
result_dir = '../detections/%s';
result_dir = sprintf(result_dir, detector_name);
if ~exist(result_dir, 'file')
    mkdir(result_dir); 
end

dir_output=dir(fullfile(result_dir,'*.txt'));
if numel(dir_output) == numel(categories)
    return;
end

% =========================================================================
% Extract results from json file, and save as *.txt 
% =========================================================================

res_file_path = [result_dir '/%s_%s_coco_%s_%s.txt'];

for idx = 1:numel(categories)
    
    % save current category's detections in the same txt file, 
    % format-> every line in this file should be like:
    % im_id, conf, x1, y1, x2, y2
    cat_file_path = sprintf(res_file_path, detector_name, ...
                            model_input_type, set_name, categories{idx});
                        
    % delete the old version
    if exist(cat_file_path, 'file')
        delete(cat_file_path);
    end
    
    cat_id  = coco_dt.getCatIds('catNms', categories{idx});
    ann_ids = coco_dt.getAnnIds('catIds', cat_id);
    anns    = coco_dt.loadAnns(ann_ids);
    
    fid  = fopen(cat_file_path, 'a');
    line = [im_format ' %.6f %.6f %.6f %.6f %.6f'];
    for idy = 1:numel(anns)
        
        flag = find(anns(idy).image_id == img_void);
        if isempty(flag)
            im_name =  anns(idy).image_id;
            score   = anns(idy).score;
            x1      = anns(idy).bbox(1);
            y1      = anns(idy).bbox(2);
            x2      = anns(idy).bbox(3) + anns(idy).bbox(1);
            y2      = anns(idy).bbox(4) + anns(idy).bbox(2);
            str     = sprintf(line, im_name, score, x1, y1, x2, y2);
            fprintf(fid, '%s\n', str);
        end
    end
    fclose(fid);   
end