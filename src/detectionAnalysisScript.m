% detectionAnalysisScript (main script)

DO_TP_ANALYSIS = 0;  % initial TP analysis; run first
DO_TP_DISPLAY = 1;   % display TP analysis
DO_TEX = 0;

SKIP_SAVED_FILES = 0; % set true to not overwrite any analysis results

NORM_FRACT = 0.15; % parameter for setting normalized precision (default = 0.15)

% type of dataset
%   use 'voc' for any VOC dataset
%   use 'voc_compatible' if readDatasetAnnotations/readDetections produce
%      structures that are the same as those produced for VOC
dataset = 'coco';  

% specify which detectors to evaluate
full_set = {'ssd'}; % for reference
detectors = {'ssd'};  % detectors that will be analyzed

dataset_params = setDatasetParameters(dataset);
objnames_all = dataset_params.objnames_all;
objnames_extra = dataset_params.objnames_extra;

objnames_selected  = objnames_all;  % objects to analyze (could be a subset)    

tp_display_localization = 'strong'; % set to 'weak' to do analysis ignoring localization error

%%%%%%%%%%%%% Below this line should not require editing %%%%%%%%%%%%%%%%%

for d = 1:numel(detectors)  % loops through each detector and performs analysis
  
  detector = detectors{d};
  fprintf('\nevaluating detector %s\n\n', detector);
  
  % sets detector paths, may need to be modified for your detector
  [dataset_params.detpath, resultdir, detname] = setDetectorInfo(detector); 
  if ~exist(resultdir, 'file'), mkdir(resultdir); end;
    
  % reads the records, attaches annotations: requires modification if not using VOC2007
  ann = readDatasetAnnotations(dataset, dataset_params);
  outdir = resultdir;

  %% Analyze true positives and their detection confidences
  % Get overall and individual AP and PR curves for: occlusion, part visible,
  % side visible, aspect ratio, and size.  For aspect ratio, split into
  % bottom 10%, 10-30%, middle 40%, 70-90%, and top 10%.  Same for size
  % (measured in terms of height).  For AP, compute confidence interval (it
  % is a mean of confidence).
  if DO_TP_ANALYSIS
    
    for o = 1:numel(objnames_selected)
      
      objname = objnames_selected{o};
      outfile_weak = fullfile(outdir, sprintf('results_%s_weak.mat', objname));
      outfile_strong = fullfile(outdir, sprintf('results_%s_strong.mat', objname));
      if ~exist(outfile_weak, 'file') || ~exist(outfile_strong, 'file') || ~SKIP_SAVED_FILES
         
        disp(objname)
        % read ground truth and detections, needs to be modified if not using VOC
  
        det = readDetections(dataset, dataset_params, ann, objname);


        outdir = resultdir;
        if ~exist(outdir, 'file'), mkdir(outdir); end;  

        nposNorm = NORM_FRACT*det.nimages;

        % Creates precision-recall curves for various subsets of objects:
        % may need to be modified for new datasets or criteria
        if ~exist(outfile_weak, 'file') || ~SKIP_SAVED_FILES
          result = analyzeTrueDetections(dataset, dataset_params, objname, det, ann, nposNorm, 'weak');
          save(fullfile(outdir, sprintf('results_%s_weak.mat', objname)), 'result', '-v7.3');  
        end

        if ~exist(outfile_strong, 'file') || ~SKIP_SAVED_FILES
          result = analyzeTrueDetections(dataset, dataset_params, objname, det, ann, nposNorm, 'strong');
          save(fullfile(outdir, sprintf('results_%s_strong.mat', objname)), 'result', '-v7.3');
        end
      end
    end
  end  


   
 
  %% Create plots and .txt files for true positive analysis
  if DO_TP_DISPLAY
    
    localization = tp_display_localization; 
    outfile = fullfile(resultdir, sprintf('missed_object_characteristics_%s_%s.txt', detector, localization));
    if ~exist(outfile, 'file') || ~SKIP_SAVED_FILES
      detail_subset = [1 4 5 6]; % objects for which to create per-object detailed plots 
      plotnames = {'area', 'height', 'aspect'}; 

      
      clear result;
      for o = 1:numel(objnames_extra)
        tmp = load(fullfile(resultdir, sprintf('results_%s_%s.mat', objnames_extra{o}, localization)));
        result(o) = tmp.result;
      end
      % Create plots for all objects and write out the first five plots
      displayPerCharacteristicPlots(result, detname)
      for f = 1:3
        set(f, 'PaperUnits', 'inches'); set(f, 'PaperSize', [8.5 11]); set(f, 'PaperPosition', [0 11-3 8.5 2.5]);
        print('-dpdf', ['-f' num2str(f)], fullfile(resultdir, sprintf('plots_%s_%s.pdf', plotnames{f}, localization)));
      end
    end 
  end
  
end

  
