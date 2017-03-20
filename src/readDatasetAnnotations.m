function ann = readDatasetAnnotations(dataset, dataset_params)
% ann = readDatasetAnnotations(dataset, dataset_params)
%
% Dataset-specific function to read and process annotations

switch lower(dataset)
  case 'coco'
    outfn = fullfile(dataset_params.annotationdir, ...
      sprintf('%s_annotations_%s.mat', dataset_params.COCOset, dataset_params.imset));
    if ~exist(outfn, 'file')
      rec = PASreadAllRecords(dataset_params);
      % processes the annotations into a more easily usable form for ground
      % truth
      usediff = true;
      for o = 1:numel(dataset_params.objnames_all)
        objname = dataset_params.objnames_all{o}; 
        [gt(o).ids, gt(o).bbox, gt(o).isdiff, gt(o).istrunc, gt(o).isocc, ...
          gt(o).details, gt(o).rnum, gt(o).onum] = PASgetObjects(rec, objname, usediff);
        gt(o).N = size(gt(o).bbox, 1);
      end   
      
      ann.rec = rec;
      ann.gt = gt;      
      
      save(outfn, 'ann'); 
    else
      load(outfn, 'ann');
    end
  otherwise 
    error('dataset %s is unknown\n', dataset);
end