function [rec, flag] = extractAnnotations(img_id, coco_gt, im_set, set_name, im_format)

rec.folder            = 'val2014';
rec.filename          = sprintf(im_format, img_id);
rec.source.database   = im_set;
rec.source.annotation = set_name;
rec.source.image      = 'flickr';
rec.source.flickrid   = '0';
rec.owner.flickrid    = 'MS';
rec.owner.name        = 'MS';

for i = 1:numel(coco_gt.data.images)
    if coco_gt.data.images(i).id == img_id
        index = i;
        break;
    end
end
rec.size.width(1)  = coco_gt.data.images(index).width;
rec.size.height(1) = coco_gt.data.images(index).height;
rec.size.depth(1)  = 3;
rec.segmented      = false;
rec.imgname        = sprintf(im_format, img_id);
rec.imgsize        = [rec.size.width(1), rec.size.height(1), rec.size.depth(1)];
rec.database       = [im_set set_name];

ann_ids = coco_gt.getAnnIds('imgIds', img_id);
anns    = coco_gt.loadAnns(ann_ids);

if numel(ann_ids) == 0
    flag = false;
end 

for i = 1:numel(ann_ids)
    
    flag                              = true;
    class                             = coco_gt.loadCats(anns(i).category_id);
    rec.objects(i).class              = class.name;
    rec.objects(i).view               = 'left';
    rec.objects(i).truncated          = false;
    rec.objects(i).occluded           = false;
    rec.objects(i).difficult          = false;
    rec.objects(i).label              = rec.objects(i).class;
    rec.objects(i).orglabel           = rec.objects(i).class;
    rec.objects(i).bbox               = anns(i).bbox;
    rec.objects(i).bbox(3)            = rec.objects(i).bbox(3) + rec.objects(i).bbox(1);
    rec.objects(i).bbox(4)            = rec.objects(i).bbox(4) + rec.objects(i).bbox(2);
    rec.objects(i).bndbox.xmin(1)     = anns(i).bbox(1);
    rec.objects(i).bndbox.ymin(1)     = anns(i).bbox(2);
    rec.objects(i).bndbox.xmax(1)     = anns(i).bbox(3) + anns(i).bbox(1);
    rec.objects(i).bndbox.ymax(1)     = anns(i).bbox(4) + anns(i).bbox(1);
    rec.objects(i).polygon            = [];
    rec.objects(i).mask               = [];
    rec.objects(i).hasparts           = false;
    rec.objects(i).part               = [];
    rec.objects(i).details            = [];
    rec.objects(i).detailedannotation = false;  
end