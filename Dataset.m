classdef Dataset
    methods
        function createDataset(~,imagesFolder,saveFolder)
            trainingSet = imageDatastore(imagesFolder,'LabelSource', 'foldernames', 'IncludeSubfolders',true);
            %[trainingSet , testingSet] = splitEachLabel(trainingSet , 0.8 , 'randomize');
            trainingSet = shuffle(trainingSet);
            %testingSet = shuffle(testingSet);
            feature = FeatureExtractor;
            data = [];
            classes = unique(trainingSet.Labels(:));
            labels = [];
            cedd(1:44) = 0;
            %f = waitbar(0,'Creating Dataset ');
            f = waitbar(0,'1','Name','Creating dataset ...',...
                    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
            totalFiles = size(trainingSet.Files);
            for i=1:totalFiles
                try
                    image = readimage(trainingSet,i);   
                catch e
                    disp(e);  
                end
                cedd = feature.CEDD(image);
                zerosCount = 0 ;
                for j=1:144
                    if cedd(j) == 0
                        zerosCount=zerosCount + 1;
                    end
                end
                if zerosCount ~= 144
                    data(i , :) = cedd;
                    labels = [labels ; trainingSet.Labels(i)];
                end
                flag_cancel = getappdata(f, 'canceling');
                if flag_cancel
                    waitbar(1,f,'Canceled');
                    F = findall(0,'type','figure','tag','TMWWaitbar');
                    delete(F);
                    return
                end
                value = i/totalFiles(1,1);
                waitbar(value,f, sprintf('%3.1f percent completed ',value*100));
            end
            fullFile = fullfile(saveFolder , 'train.mat');
            save(fullFile , 'data' , 'labels');
            metaFile = fullfile(saveFolder , 'meta.mat');
            save(metaFile ,'classes');
            pause(1);
            clear data labels;
            waitbar(1,f,'Completed');
            F = findall(0,'type','figure','tag','TMWWaitbar');
            delete(F);
        end
    end
end