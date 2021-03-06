function FitPulseModelMulti(folder,pulseInfo_name,pulse_model)
%USAGE FitPulseModelMulti(folder,pulseInfo_name,pulse_model)
%e.g.
%folder = 'full_path_2_folder'
%pulseInfo_name = 'pulseInfo' or 'pulseInfo2'
%pulse_model = './pulse_model'

pI_name = char(pulseInfo_name);
pM_name = char(pulse_model);

%is user feeds path to pulse model, then load mat file.
TG = strncmp(pM_name,'.mat',-4);
if TG ==1
    pMData = load(pM_name);
    a = fieldnames(pMData);
    pM = getfield(pMData,char(a));
else
    pM = pulse_model;
end
TG =0;

[poolavail,isOpen] = check_open_pool;

if strcmp(folder(end),'/') == 0
    folder = [folder '/'];
end
dir_list = dir(folder);
file_num = length(dir_list);

for y = 1:file_num
    file = dir_list(y).name; %pull out the file name
    [~,root,ext] = fileparts(file);
    path_file = [folder file];
    TG = strcmp(ext,'.mat');
    
    
    if TG == 1
        
        fprintf([file '\n']);
        
        W = who('-file',path_file);
        varstruc =struct;
        load(path_file);
    
        for ii = 1:numel(W)
            varstruc.(W{ii}) = eval(W{ii});
        end
        
%         pIData = load(path_file,pI_name);
        pI_data = varstruc.(pI_name);
        [pulse_model,Lik_pulse] = FitPulseModel(pM,pI_data.x);
        
        %will automatically replace pulse_model and Lik_pulse if they exist
        %already
        varstruc.pulse_model = pulse_model;       
        varstruc.pulse_model.variables.pulseInfo_ver = pI_name;
        varstruc.pulse_model.variables.pulseName_ver = pM_name;
        varstruc.pulse_model.variables.date = date;
        varstruc.pulse_model.variables.time = clock;

        if strcmp(pI_name,'pulseInfo') == 1
            
            varstruc.Lik_pulseInfo = Lik_pulse;
            varstruc.Lik_pulseInfo.variables.pulseInfo_ver = pI_name;
            varstruc.Lik_pulseInfo.variables.pulseName_ver = pM_name;
            varstruc.Lik_pulseInfo.variables.date = date;
            varstruc.Lik_pulseInfo.variables.time = clock;
            
        elseif strcmp(pI_name,'pulseInfo2') == 1
            varstruc.Lik_pulseInfo2 = Lik_pulse;
            varstruc.Lik_pulseInfo2.variables.pulseInfo_ver = pI_name;
            varstruc.Lik_pulseInfo2.variables.pulseName_ver = pM_name;
            varstruc.Lik_pulseInfo2.variables.date = date;
            varstruc.Lik_pulseInfo2.variables.time = clock;
            
        end
        
        save(path_file,'-struct','varstruc','-mat')%save all variables in original file
       
    end
end

check_close_pool(poolavail,isOpen)


