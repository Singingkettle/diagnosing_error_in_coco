function [detpath, resultdir, detname] = setDetectorInfo(detector)
% [detpath, resultdir, detname] = setDetectorInfo(detector)
%
% sets path etc for given detector

  switch detector
    case 'ssd'
        detpath   = '../detections/ssd/ssd_300X300_coco_val2014_%s.txt';
        resultdir = '../results/ssd';
        detname   = 'SSD';
    otherwise
      error('unknown detector')
  end