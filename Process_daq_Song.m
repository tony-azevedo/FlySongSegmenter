function Process_daq_Song(song_daq_file,channel_num,song_range,params_path,pulse_model_path)

%Perform Process_Song on multiple channels from a single daq file
%e.g. Process_daq_Song('/misc/public/Troy/20120302081902.daq',3,[1 1000000],'./params.m');
%processes the first million tics of channel #3
%
%e.g. Process_daq_Song('20120302081902.daq',[],[],'./params.m');
%processes all of the tics of all of the channels.
%w/o a full path the file must be in the current directory.

song_daqinfo = daqread(song_daq_file,'info');
nchannels_song = length(song_daqinfo.ObjInfo.Channel);

if(~isempty(channel_num) && (numel(channel_num)<1 || (numel(channel_num)>nchannels_song)))
  warning('channel_num out of range');
end

%make directory for output
sep = filesep;
[pathstr, name, ext] = fileparts(song_daq_file); 
new_dir = [pathstr sep name '_out'];
mkdir(new_dir);


if(isempty(channel_num))  yy=1:nchannels_song;  else  yy=channel_num;  end
for y = yy
    outfile  = [new_dir sep 'PS_' name '_ch' num2str(y) '.mat'];
    file_exist = exist(outfile,'file');
    if file_exist == 0;%if file exists, skip
        %grab song and noise from each channel
        
        fprintf(['Grabbing song from daq file channel %s.\n'], num2str(y))
        if ~isempty(song_range)
            song = daqread(song_daq_file,'Channels',y,'Samples',song_range);
        else
            song = daqread(song_daq_file,'Channels',y);
        end
 
        %run Process_Song on selected channel
        fprintf('Processing song.\n')
        [data, winnowed_sine, pulseInfo, pulseInfo2, pcndInfo] = Process_Song(song,[],params_path,pulse_model_path);
        %save data
        
        save(outfile, 'data','winnowed_sine', 'pcndInfo','pulseInfo2','pulseInfo','-v7.3')
        %clear workspace
        clear song data winnowed_sine pulseInfo2 pulseInfo
    else
        fprintf(['File %s exists. Skipping.\n'], outfile)
    end
end
