classdef Video
    properties
        video
        frames
        %annotations
    end
    methods
%         function obj = setVideo(obj,videoFile)
%             obj.video = VideoReader(videoFile);
%         end
%         function obj = convertVideoToFrames(obj)
%             numberOfFrames = obj.video.NumberOfFrames;
%             for i = 1 : numberOfFrames
%                 obj.frames = [obj.frames ; read(videoObject, frame)];
%             end
%         end
        function annotationString = getAnnotations(obj,videoFile)
            obj.video = VideoReader(videoFile);
            D = obj.video.Duration;
            f = waitbar(0,'1','Name','Extracting Frames',...
                    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
            for i = 1:1:D
                flag_cancel = getappdata(f, 'canceling');
                if flag_cancel
                    waitbar(1,f,'Canceled');
                    F = findall(0,'type','figure','tag','TMWWaitbar');
                    delete(F);
                    return
                end
                obj.video.CurrentTime = i;
                image = imresize(readFrame(obj.video),[300 300]);
                obj.frames{i} = image;
                value = i/D;
                waitbar(value,f, sprintf('%3.1f percent completed ',value*100));
            end
            delete(f);
            featureObj = FeatureExtractor;
            featuresArray = featureObj.getFeatures(obj.frames);
            modal = Classifier;
            modal = modal.loadModal('modal.mat');
            annotationString = modal.annotate(featuresArray);
        end
    end
end