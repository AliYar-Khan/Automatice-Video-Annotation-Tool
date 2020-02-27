classdef Controller
    methods
        
        function annotations = annotateVideo(~,videoFile)
            videoObj = Video;
            annotations = videoObj.getAnnotations(videoFile);
        end
        
        function createDataset(~,pathToFolder, pathToSave)
            datasetObj = Dataset;
            datasetObj.createDataset(pathToFolder,pathToSave);
        end
        
        function accuracy = trainNet(~,datasetFolder)
            classifier = Classifier;
            [classifier , accuracy] = classifier.trainClassifier(datasetFolder);
        end
        
        function saveClassifier(~,name,classifier)
            classifier = Classifier;
            classifier.saveModal(name,classifer);
        end
        
        function saveModal(~,path)
            f = figure;
            tf = isappdata(f,'modal');
            if tf == 0
                modal = load('modal.mat');
                save(path,'modal');   
            else
                modal = getappdata(f,'modal');
            end
            delete(f);
        end
        
        function loadClassifier(~,classifierPath)
            classifier = Classifier;
            Modal = classifier.loadModal(classifierPath);
            f = figure ;
            setappdata(f,'modal',Modal);
            delete(f);
        end
    end
end