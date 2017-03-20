function dataset_params = setDatasetParameters(dataset)
% dataset_params = setDatasetParameters(dataset)
%
% Sets machine-specific and datset-specific parameters such as image paths.
%
% Required parameters: 
%   imdir: directory containing images
%   objnames_all{nclasses}: names for each object class, order specifies
%     index for each class
%   objnames_extra{nclasses}: names of classes for more detailed analysis
%     (may only be relevant for VOC2007); if not available, set to {}
%   similar_classes{ngroups}: set of equivalence sets such that any pair of
%     classes in an equivalence set is considered similar (symmetric binary
%     confusion matrix can be encoded as a set of pairs); sets consist of
%     indices into classes given by objnames_all
%  summary_sets{nsets}: sets of indices that will be used to summarize 
%     stastics 
%  summary_setnames{nsets}: names of each set (e.g., animal)

switch lower(dataset)
    case 'coco'
        dataset_params.imset = 'COCO';
        dataset_params.datadir = '/home/citybuster/data/coco'; % needs to be set for your computer
        dataset_params.COCOsourcepath = './COCOAPI/';  % change this for later VOC versions
        dataset_params.COCOset = 'val2014';
        dataset_params.detectorname = 'ssd';
        dataset_params.modelinputtype = '300X300';
        dataset_params.imnameformat = '%012d.jpg';
        addpath(dataset_params.COCOsourcepath);
        dataset_params.annotationdir = '../annotations';
        dataset_params.objnames_extra = {'person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train'}; % required parameter: specify objects with extra annotation -- set to empty set if not using VOC2007
        dataset_params.confidence_threshold = 0; % minimum confidence to be included in analysis (e.g., set to 0.01 to improve speed)

        % all object names
        dataset_params.objnames_all = ... 
            {'person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train', 'truck', ...
            'boat', 'traffic light', 'fire hydrant', 'stop sign', 'parking meter', 'bench', ...
            'bird', 'cat', 'dog', 'horse', 'sheep', 'cow', 'elephant', 'bear', 'zebra', 'giraffe', ...
            'backpack', 'umbrella', 'handbag', 'tie', 'suitcase', 'frisbee', 'skis', 'snowboard', ...
            'sports ball', 'kite', 'baseball bat', 'baseball glove', 'skateboard', 'surfboard', ...
            'tennis racket', 'bottle', 'wine glass', 'cup', 'fork', 'knife', 'spoon', 'bowl', ...
            'banana', 'apple', 'sandwich', 'orange', 'broccoli', 'carrot', 'hot dog', 'pizza', ...
            'donut', 'cake', 'chair', 'couch', 'potted plant', 'bed', 'dining table', 'toilet', ...
            'tv', 'laptop', 'mouse', 'remote', 'keyboard', 'cell phone', 'microwave', 'oven', ...
            'toaster', 'sink', 'refrigerator', 'book', 'clock', 'vase', 'scissors', 'teddy bear', 'hair drier', 'toothbrush'};
        
        % localization criteria
        dataset_params.iuthresh_weak = 0.1;  % intersection/union threshold
        dataset_params.idthresh_weak = 0;    % intersection/det_area threshold   
        dataset_params.iuthresh_strong = 0.5;  % intersection/union threshold
        dataset_params.idthresh_strong = 0;    % intersection/det_area threshold   
end

