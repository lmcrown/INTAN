% Intan settings file read to XLS
function ISF = INTAN_Read_ISF_file(data_file)

% Partially adapted from "read_Intan_RHD2000_file Version 1.3, 10 December 2013"
%
% Reads Intan Technologies .isf settings file generated by evaluation board
% GUI and copies to an excel spreadsheet.

% Get Filenames

ISF = struct;

if nargin == 0
    data_file = 'Test.isf';
end

fid = fopen(data_file, 'r');
s = dir(data_file);
filesize = s.bytes;

% Check 'magic number' at beginning of file to make sure this is an Intan
% Technologies RHD2000 data file.
magic_number = fread(fid, 1, 'uint32');
if magic_number ~= hex2dec('45ab12cd')
    error('Unrecognized file type.');
end

% Get Versioning
data_file_main_version_number = fread(fid, 1, 'int16');
data_file_secondary_version_number = fread(fid, 1, 'int16');

ISF.versionMain = data_file_main_version_number;
ISF.versionSecondary = data_file_secondary_version_number;

fprintf(1, '\n');
fprintf(1, 'Reading *.isf Settings File, Version %d.%d\n', ...
    data_file_main_version_number, data_file_secondary_version_number);

% Get signal sources
% Define data structure for data channels.
channel_struct = struct( ...
    'native_channel_name', {}, ...
    'custom_channel_name', {}, ...
    'native_order', {}, ...
    'custom_order', {}, ...
    'signal_type', {}, ...
    'channel_enabled', {}, ...
    'board_stream', {}, ...
    'chip_channel', {}, ...
    'port_name', {}, ...
    'port_prefix', {}, ...
    'port_number', {}, ...
    'electrode_impedance_magnitude', {}, ...
    'electrode_impedance_phase', {} );

ISF.channels = struct(channel_struct);

% Make a big stupid data structure out of the channel data. It's not
% necessarily convenient to perform operations on this but it's easier to
% spit it back out. Just make sure you don't mix up AUX/VDD channels with
% amplifier channels if you perform any operations on it.
ISF.number_of_signal_groups = fread(fid, 1, 'int16');
for signal_group = 1:ISF.number_of_signal_groups
    ISF.signal_group_name{signal_group} = fread_QString(fid);
    ISF.signal_group_prefix{signal_group} = fread_QString(fid);
    ISF.signal_group_enabled(signal_group) = fread(fid, 1, 'int16');
    ISF.signal_group_num_channels(signal_group) = fread(fid, 1, 'int16');
    ISF.signal_group_num_amp_channels(signal_group) = fread(fid, 1, 'int16');

    if (ISF.signal_group_num_channels(signal_group) > 0 && ISF.signal_group_enabled(signal_group) > 0)
            for signal_channel = 1:ISF.signal_group_num_channels(signal_group)
                ISF.channels(signal_group,signal_channel).port_name = ISF.signal_group_name;
                ISF.channels(signal_group,signal_channel).port_prefix = ISF.signal_group_prefix;
                ISF.channels(signal_group,signal_channel).port_number = signal_group;
                ISF.channels(signal_group,signal_channel).native_channel_name = fread_QString(fid);
                ISF.channels(signal_group,signal_channel).custom_channel_name = fread_QString(fid);
                ISF.channels(signal_group,signal_channel).native_order = fread(fid, 1, 'int16');
                ISF.channels(signal_group,signal_channel).custom_order = fread(fid, 1, 'int16');
                ISF.channels(signal_group,signal_channel).signal_type = fread(fid, 1, 'int16');
                ISF.channels(signal_group,signal_channel).channel_enabled = fread(fid, 1, 'int16');
                ISF.channels(signal_group,signal_channel).chip_channel = fread(fid, 1, 'int16');
                ISF.channels(signal_group,signal_channel).board_stream = fread(fid, 1, 'int16');
                ISF.new_trigger_channel(signal_group,signal_channel).voltage_trigger_mode = fread(fid, 1, 'int16');
                ISF.new_trigger_channel(signal_group,signal_channel).voltage_threshold = fread(fid, 1, 'int16');
                ISF.new_trigger_channel(signal_group,signal_channel).digital_trigger_channel = fread(fid, 1, 'int16');
                ISF.new_trigger_channel(signal_group,signal_channel).digital_edge_polarity = fread(fid, 1, 'int16');
                ISF.channels(signal_group,signal_channel).electrode_impedance_magnitude = fread(fid, 1, 'single');
                ISF.channels(signal_group,signal_channel).electrode_impedance_phase = fread(fid, 1, 'single');
            end
     end
end

% Get user settings
ISF.sample_rate_combo_box = fread(fid, 1, 'int16');
ISF.yScale_combo_box = fread(fid, 1, 'int16');
ISF.tScale_combo_box = fread(fid, 1, 'int16');

% Obtain Notch Filter Setting
ISF.notch_filter_mode = fread(fid, 1, 'int16');

% Obtain Base Filename for Recorded Data
ISF.save_base_filename = fread_QString(fid);

% Obtain Recording Period (minutes) Before Starting New Data File
ISF.new_save_file_period = fread(fid, 1, 'int16');

% Get DSP Settings
ISF.dspEnabled = fread(fid, 1, 'int16');
ISF.desiredDspCutoffFreq = fread(fid, 1, 'single');
ISF.desiredLowerBandwidth = fread(fid, 1, 'single');
ISF.desiredUpperBandwidth = fread(fid, 1, 'single');
ISF.desiredImpedanceFreq = fread(fid, 1, 'single');
ISF.actualImpedanceFreq = fread(fid, 1, 'single');
ISF.impedanceFreqValid = fread(fid, 1, 'int16');

% DAC Settings
ISF.dacGainSlider = fread(fid, 1, 'int16');
ISF.dacNoiseSuppressSlider = fread(fid, 1, 'int16');

% DAC Channels thing.
ISF.dacnames = cell(8,1);
for ix = 1:8
    ISF.dacenabled(ix) = fread(fid, 1, 'int16');
    ISF.dacnames{ix} = fread_QString(fid);
end

% Fast Settle
ISF.fastSettleEnabled = fread(fid, 1, 'int16');

% PlotPointsMode
ISF.plotPointsCheckBox = fread(fid, 1, 'int16');

% Notes
 ISF.notes.note1 = fread_QString(fid);
 ISF.notes.note2 = fread_QString(fid);
 ISF.notes.note3 = fread_QString(fid);
 

%  Ports enabled thing.
ISF.portenabled1 = [];
ISF.portenabled2 = [];
for i=1:6
     ISF.portenabled1(i) = fread(fid, 1, 'int16');
     ISF.portenabled2(i) = fread(fid, 1, 'int16');
end

%Version-Specific Stuff
if ((data_file_main_version_number == 1 && data_file_secondary_version_number >= 1) || (data_file_main_version_number > 1))
        ISF.saveTemp = fread(fid, 1, 'int16');
end

if ((data_file_main_version_number == 1 && data_file_secondary_version_number >= 2) || (data_file_main_version_number > 1))
        ISF.recordTriggerChannel = fread(fid, 1, 'int16');
        ISF.recordTriggerPolarity = fread(fid, 1, 'int16');
        ISF.recordTriggerBuffer = fread(fid, 1, 'int16');
        
        ISF.saveFormat = fread(fid, 1, 'int16');
        ISF.dacLockToSelectedBox = fread(fid, 1, 'int16');
end


if ((data_file_main_version_number == 1 && data_file_secondary_version_number >= 3) || (data_file_main_version_number > 1))
    ISF.dacThresholdSpinBox = [];
    for i = 1:8    
        ISF.dacThresholdSpinBox(i) = fread(fid, 1, 'int32');
    end
    ISF.saveTtlOut = fread(fid, 1, 'int16');
    ISF.enableHighpassFilter  = fread(fid, 1, 'int16');
    ISF.highpassFilterLine = fread(fid, 1, 'single');
end

if ((data_file_main_version_number == 1 && data_file_secondary_version_number >= 4) || (data_file_main_version_number > 1))
    ISF.externalFastSettleCheckBox = fread(fid, 1, 'int16');
    ISF.externalFastSettleSpinBox = fread(fid, 1, 'int16');
    ISF.auxDigOutEnabled = [];
    ISF.auxDigOutChannel = [];
    ISF.manualDelayEnabled = [];
    ISF.manualDelay = [];
    for i = 1:4
        for ii = 1:4
            switch i
                case 1
                    ISF.auxDigOutEnabled(ii) = fread(fid, 1, 'int16');
                case 2
                    ISF.auxDigOutChannel(ii) = fread(fid, 1, 'int16');
                case 3
                    ISF.manualDelayEnabled(ii) = fread(fid, 1, 'int16');
                case 4
                    ISF.manualDelay(ii) = fread(fid, 1, 'int16');
            end
        end
    end
end

fclose(fid);
fprintf(1, '     ...done\n');

function a = fread_QString(fid)

% a = read_QString(fid)
%
% Read Qt style QString.  The first 32-bit unsigned number indicates
% the length of the string (in bytes).  If this number equals 0xFFFFFFFF,
% the string is null.

a = '';
length = fread(fid, 1, 'uint32');
if length == hex2num('41efffffffe00000')
    return;
end
% convert length from bytes to 16-bit Unicode words
length = length / 2;

for j=1:length
    a(j) = fread(fid, 1, 'uint16');
end

end

end