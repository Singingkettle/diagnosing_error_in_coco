function rec = PASreadAllRecords(dataset_params)


data_dir         = dataset_params.datadir;
im_set           = dataset_params.imset;
set_name         = dataset_params.COCOset;
im_format        = dataset_params.imnameformat;
im_format        = [im_set '_' set_name '_' im_format];
detector_name    = dataset_params.detectorname;
model_input_type = dataset_params.modelinputtype;
categories       = dataset_params.objnames_all;


ann_file = [data_dir '/annotations/instances_%s.json'];
ann_file = sprintf(ann_file, set_name);
coco_gt  = CocoApi(ann_file);

res_file = [data_dir '/results/SSD_300x300_score/detections_val_ssd300_results.json'];
coco_dt  = coco_gt.loadRes(res_file);

img_ids = coco_gt.getImgIds();

rec_id       = 0;
void_id      = 0;
img_void     = [];
rec_dir      = './tmp/rec.mat';
img_void_dir = './tmp/img_void.mat';

if exist(rec_dir, 'file') && exist(img_void_dir, 'file')
    load(rec_dir);
    load(img_void_dir);
else
    for i = 1:numel(img_ids)
        [tmp, flag] = extractAnnotations(img_ids(i), coco_gt, im_set, set_name, im_format);
        if flag
            rec_id      = rec_id + 1;
            rec(rec_id) = tmp;
        else
            void_id           = void_id + 1;
            img_void(void_id) = img_ids(i);
        end
        if i == 1
            rec(numel(img_ids)) = rec(i);
        end
    end
    rec = rec(1:rec_id);
    save(rec_dir, 'rec');
    save(img_void_dir, 'img_void');
end


convertResult(detector_name, model_input_type, set_name, categories, im_format, img_void, coco_dt)





