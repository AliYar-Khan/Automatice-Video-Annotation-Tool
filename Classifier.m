classdef Classifier
    properties
        network
    end
    methods
%         function obj=Classifer(~)
%             if ~exist('net.mat')
%                 obj = NULL;
%             else
%                 obj = load('net.mat');
%             end
%         end
        function annotations = annotate(obj,featuresArray)
            F = figure;
            annotations = [];
            tf = isappdata(F,'modal');
            if tf == 0
                f=waitbar(0,'Loading ...','Name','Loading Modal');
                obj.network = load('modal.mat');
                waitbar(1,f,'Loaded successfully');
                delete(f);
            else
                obj.network = getappdata(F,'modal');
            end
            delete(F);
          
            %table = array2table(featuresArray);
            %variableNames = table.Properties.VariableNames;
            f = waitbar(0,'1','Name','Annotating Frames',...
                    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
            s = length(featuresArray);
            for i=1:s
                flag_cancel = getappdata(f, 'canceling');
                if flag_cancel
                    waitbar(1,f,'Canceled');
                    F = findall(0,'type','figure','tag','TMWWaitbar');
                    delete(F);
                    return
                end
                [label,~] = predict(obj.network.classifier.ClassificationSVM,featuresArray(i,:));
                annotations = [annotations ; label];
                value = i/s;
                waitbar(value,f, sprintf('%3.1f percent completed ',value*100));
            end
            delete(f);
        end
        function [obj,validationAccuracy] = trainClassifier(obj,datasetFolder)
            training = fullfile(datasetFolder,'train.mat');
            f = waitbar(0,'Preparing dataset','Name','Training',...
                    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
            %meta = fullfile(datasetFolder , 'meta.mat');
            %save('meta.mat','meta');
            
            dataset = load(training);
            table = array2table(dataset.data);
            variableNames = table.Properties.VariableNames;
            table.class = dataset.labels;
            classNames = unique(table.class);
            predictorNames = {'data1', 'data2', 'data3', 'data4', 'data5', 'data6', 'data7', 'data8', 'data9', 'data10', 'data11', 'data12', 'data13', 'data14', 'data15', 'data16', 'data17', 'data18', 'data19', 'data20', 'data21', 'data22', 'data23', 'data24', 'data25', 'data26', 'data27', 'data28', 'data29', 'data30', 'data31', 'data32', 'data33', 'data34', 'data35', 'data36', 'data37', 'data38', 'data39', 'data40', 'data41', 'data42', 'data43', 'data44', 'data45', 'data46', 'data47', 'data48', 'data49', 'data50', 'data51', 'data52', 'data53', 'data54', 'data55', 'data56', 'data57', 'data58', 'data59', 'data60', 'data61', 'data62', 'data63', 'data64', 'data65', 'data66', 'data67', 'data68', 'data69', 'data70', 'data71', 'data72', 'data73', 'data74', 'data75', 'data76', 'data77', 'data78', 'data79', 'data80', 'data81', 'data82', 'data83', 'data84', 'data85', 'data86', 'data87', 'data88', 'data89', 'data90', 'data91', 'data92', 'data93', 'data94', 'data95', 'data96', 'data97', 'data98', 'data99', 'data100', 'data101', 'data102', 'data103', 'data104', 'data105', 'data106', 'data107', 'data108', 'data109', 'data110', 'data111', 'data112', 'data113', 'data114', 'data115', 'data116', 'data117', 'data118', 'data119', 'data120', 'data121', 'data122', 'data123', 'data124', 'data125', 'data126', 'data127', 'data128', 'data129', 'data130', 'data131', 'data132', 'data133', 'data134', 'data135', 'data136', 'data137', 'data138', 'data139', 'data140', 'data141', 'data142', 'data143', 'data144'};
            predictors = table(:, variableNames);
            response = table.class;
            isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
            % Train a classifier
            % This code specifies all the classifier options and trains the classifier.
            waitbar(0.1,f,'Training Classifier');
            template = templateSVM(...
                'KernelFunction', 'polynomial', ...
                'PolynomialOrder', 2, ...
                'KernelScale', 'auto', ...
                'BoxConstraint', 1, ...
                'Standardize', true);

            options = statset('UseParallel',true);

            classificationSVM = fitcecoc(...
                predictors, ...
                response, ...
                'Learners', template, ...
                'Coding', 'onevsone', ...
                'Options', options , ...
                'ClassNames', categorical({'airliner'; 'bed'; 'bench'; 'bicycle'; 'birds'; 'bulldozer'; 'bus'; 'car'; 'cats'; 'chair'; 'clouds'; 'dogs'; 'fantasy'; 'fish'; 'flower'; 'hall'; 'helicopter'; 'house'; 'insect'; 'jet'; 'kitchen'; 'lamp'; 'mountains'; 'office'; 'reptile'; 'robot'; 'rocket'; 'ship'; 'stadium'; 'sword'; 'table'; 'tank'; 'temple'; 'tower'; 'train'; 'trees'; 'truck'}) , ...
                'Verbose',2);

            % Create the result struct with predict function
            predictorExtractionFcn = @(t) t(:, predictorNames);
            svmPredictFcn = @(x) predict(classificationSVM, x);
            obj.network.predictFcn = @(x) svmPredictFcn(predictorExtractionFcn(x));
            % Add additional fields to the result struct
            obj.network.RequiredVariables = {'data1', 'data2', 'data3', 'data4', 'data5', 'data6', 'data7', 'data8', 'data9', 'data10', 'data11', 'data12', 'data13', 'data14', 'data15', 'data16', 'data17', 'data18', 'data19', 'data20', 'data21', 'data22', 'data23', 'data24', 'data25', 'data26', 'data27', 'data28', 'data29', 'data30', 'data31', 'data32', 'data33', 'data34', 'data35', 'data36', 'data37', 'data38', 'data39', 'data40', 'data41', 'data42', 'data43', 'data44', 'data45', 'data46', 'data47', 'data48', 'data49', 'data50', 'data51', 'data52', 'data53', 'data54', 'data55', 'data56', 'data57', 'data58', 'data59', 'data60', 'data61', 'data62', 'data63', 'data64', 'data65', 'data66', 'data67', 'data68', 'data69', 'data70', 'data71', 'data72', 'data73', 'data74', 'data75', 'data76', 'data77', 'data78', 'data79', 'data80', 'data81', 'data82', 'data83', 'data84', 'data85', 'data86', 'data87', 'data88', 'data89', 'data90', 'data91', 'data92', 'data93', 'data94', 'data95', 'data96', 'data97', 'data98', 'data99', 'data100', 'data101', 'data102', 'data103', 'data104', 'data105', 'data106', 'data107', 'data108', 'data109', 'data110', 'data111', 'data112', 'data113', 'data114', 'data115', 'data116', 'data117', 'data118', 'data119', 'data120', 'data121', 'data122', 'data123', 'data124', 'data125', 'data126', 'data127', 'data128', 'data129', 'data130', 'data131', 'data132', 'data133', 'data134', 'data135', 'data136', 'data137', 'data138', 'data139', 'data140', 'data141', 'data142', 'data143', 'data144'};
            obj.network.ClassificationSVM = classificationSVM;
            obj.network.About = 'This struct is a trained model exported from Classification Learner R2018a.';
            obj.network.HowToPredict = sprintf('To make predictions on a new table, T, use: \n  yfit = c.predictFcn(T) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedModel''. \n \nThe table, T, must contain the variables returned by: \n  c.RequiredVariables \nVariable formats (e.g. matrix/vector, datatype) must match the original training data. \nAdditional variables are ignored. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appclassification_exportmodeltoworkspace'')">How to predict using an exported model</a>.');
               
            waitbar(0.4,f,'Performing cross validation');
            % Perform cross-validation
            partitionedModel = crossval(obj.network.ClassificationSVM, 'KFold', 10, 'Options',options);
            
            waitbar(0.7,f,'Computing validation predictions');
            % Compute validation predictions
            [validationPredictions, validationScores] = kfoldPredict(partitionedModel,'Options',options);
            % Compute validation accuracy
            
            waitbar(0.7,f,'Computing validation accuracy');
            validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');

            waitbar(0.90,f,'Name','Training',sprintf('Classifier has validation accuracy of %2.2f.',validationAccuracy));
            pause(0.5)
            
            waitbar(0.95,f,'saving modal');
            %set network to use accross tha gui app
            setappdata(f,'modal',obj.network);
            % to save the modal in current directory for later use
            obj.saveModal('modal',obj.network,'-v7.3');
            delete(f);
        end
        
        function saveModal(~,name,classifier)
            save(name,'classifier');
        end
        
        function obj = loadModal(obj,path)
            obj.network = load(path);
        end
    end
end