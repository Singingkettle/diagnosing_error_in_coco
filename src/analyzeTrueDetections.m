function result = analyzeTrueDetections(dataset, dataset_params, objname, det, ann, normalizedCount, localization)
% result = analyzeTrueDetections(dataset, dataset_params, objname, det, ann, normalizedCount, localization)
%
% Analyzes the performance for various subsets of the objects
%
% Input:
%   dataset: name of the dataset (e.g., VOC)
%   dataset_params: parameters of the dataset
%   objname: name of the object class 
%   det.(bbox, conf, rnum): object detection results
%   ann: dataset annotations
%   normalizeCount: the pseudo-number of objects for normalized precision
%   localization: 'weak' or 'strong' to specify localization criteria
%
% Output:
%   result: set of precision-recall statistics


switch lower(dataset)
  case {'coco'}
                         
    result = analyzeTrueDetections_COCO(dataset, dataset_params, objname, ann, det, normalizedCount, localization);
        
  otherwise
    error('dataset %s is unknown\n', dataset);
end  

result.name = objname;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = analyzeTrueDetections_COCO(dataset, dataset_params, objname, ann, det, normalizedCount, localization)

rec = ann.rec;

[det.conf, si] = sort(det.conf, 'descend');
det.bbox = det.bbox(si, :);
det.rnum = det.rnum(si);

[det, gt] = matchDetectionsWithGroundTruth(dataset, dataset_params, objname, ann, det, localization);

result.localization = localization;

result.gt = gt;
result.gt.bbox_conf = zeros(gt.N, 4);
result.gt.bbox_conf(gt.detnum>0, 1:4) = det.bbox(gt.detnum(gt.detnum>0), :); 
result.gt.bbox_ov = zeros(gt.N, 4);
result.gt.bbox_ov(gt.detnum_ov>0, 1:4) = det.bbox(gt.detnum_ov(gt.detnum_ov>0), :); 

result.det.bbox = det.bbox;

result.det.conf = det.conf;

%% Precision-recall curves

% Overall
npos = sum(~[gt.isdiff]);
result.all = averagePrecisionNormalized(det.conf, det.label, npos, normalizedCount);

result.gt.pn = zeros(gt.N, 1);
result.gt.pn(gt.detnum>0) = result.all.pni(gt.detnum(gt.detnum>0));
result.gt.pn_ov = zeros(gt.N, 1);
result.gt.pn_ov(gt.detnum_ov>0) = result.all.pni(gt.detnum_ov(gt.detnum_ov>0));

% BBox Area
bb = gt.bbox(~[gt.isdiff], :);
gtarea = (bb(:, 3)-bb(:, 1)+1).*(bb(:, 4)-bb(:, 2)+1);
[sa, si] = sort(gtarea, 'ascend');
athresh = [0 sa(round([1/10 3/10 7/10 9/10]*size(bb,1)))'];
alabel(~[gt.isdiff]) = sum(repmat(gtarea, [1 5])>repmat(athresh, [size(bb, 1) 1]), 2);
alabel(logical([gt.isdiff])) = 0;
result.gt.area = alabel;
for a = 1:5  
  deto = det;
  npos = sum(alabel==a &~ [gt.isdiff]');
  ind = find(deto.label==1);
  gti = deto.gtnum(ind);
  ind = ind(alabel(gti)~=a);
  deto.label(ind) = 0;
  result.area(a) = averagePrecisionNormalized(deto.conf, deto.label, npos, normalizedCount);
end
areathresh = athresh;

% BBox Height
bb = gt.bbox(~[gt.isdiff], :);
gtheight = (bb(:, 4)-bb(:, 2)+1);
%gtarea = (bb(:, 3)-bb(:, 1)+1).*(bb(:, 4)-bb(:, 2)+1);
[sa, si] = sort(gtheight, 'ascend');
athresh = [0 sa(round([1/10 3/10 7/10 9/10]*size(bb,1)))'];
alabel(~[gt.isdiff]) = sum(repmat(gtheight, [1 5])>repmat(athresh, [size(bb, 1) 1]), 2);
alabel(logical([gt.isdiff])) = 0;
for a = 1:5  
  deto = det;
  npos = sum(alabel==a &~ [gt.isdiff]');
  ind = find(deto.label==1);
  gti = deto.gtnum(ind);
  ind = ind(alabel(gti)~=a);
  deto.label(ind) = 0;
  result.height(a) = averagePrecisionNormalized(deto.conf, deto.label, npos, normalizedCount);
end
result.gt.height = alabel;
heightthresh = athresh;


% Aspect Ratio
bb = gt.bbox(~[gt.isdiff], :);
gtaspect = (bb(:, 3)-bb(:, 1)+1)./(bb(:, 4)-bb(:, 2)+1);
[sa, si] = sort(gtaspect, 'ascend');
athresh = [0 sa(round([1/10 3/10 7/10 9/10]*size(bb,1)))'];
alabel(~[gt.isdiff]) = sum(repmat(gtaspect, [1 5])>repmat(athresh, [size(bb, 1) 1]), 2);
alabel(logical([gt.isdiff])) = 0;
for a = 1:5  
  deto = det;
  npos = sum(alabel==a &~ [gt.isdiff]');
  ind = find(deto.label==1);
  gti = deto.gtnum(ind);
  ind = ind(alabel(gti)~=a);
  deto.label(ind) = 0;
  result.aspect(a) = averagePrecisionNormalized(deto.conf, deto.label, npos, normalizedCount);
end
result.gt.aspect = alabel;
aspectthresh = athresh;


%% Statistics of missed vs. detected
% result.counts stores counts of properties of all and missed objects
% result.overlap stores maximum overlap of different kinds of objects
missedthresh = 0.05;

missed = true(gt.N, 1);
missed(det.gtnum(result.all.pni>=missedthresh & det.label==1)) = false;
missed(gt.isdiff) = false;
found = ~missed;
found(gt.isdiff) = false;

% area
alabel = result.gt.area(:);
alabel(logical([gt.isdiff])) = 0;
result.counts.missed.area = hist(alabel(missed & alabel>0), 1:5);
result.counts.all.area = hist(alabel(alabel>0), 1:5);

for k = 1:5
  ind = det.gtnum>0;
  ind(ind) = alabel(det.gtnum(ind))==k;
  result.overlap.detected.area(k) = mean(gt.ov(det.gtnum(ind)));
  result.overlap.all.area(k) = mean(gt.ov(alabel==k));
end

% aspect
alabel = result.gt.aspect(:);
alabel(logical([gt.isdiff])) = 0;
result.counts.all.aspectratio = hist(alabel(alabel>0), 1:5);
result.counts.missed.aspectratio = hist(alabel(missed  & alabel>0), 1:5);

for k = 1:5
  ind = det.gtnum>0;
  ind(ind) = alabel(det.gtnum(ind))==k;
  result.overlap.detected.aspectratio(k) = mean(gt.ov(det.gtnum(ind)));
  result.overlap.all.aspectratio(k) = mean(gt.ov(alabel==k));
end



