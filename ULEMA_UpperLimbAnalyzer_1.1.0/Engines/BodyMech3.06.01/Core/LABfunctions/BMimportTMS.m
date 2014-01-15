%
% License:  This  program  is  free software; you can redistribute it and/or
% modify  it  under the terms of the GNU General Public License as published
% by  the  Free Software Foundation; either version 3 of the License, or (at
% your  option)  any  later version. This program is distributed in the hope
% that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
% warranty  of  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%

function [datafile,datapath]=BMimportTMS(filename,datapath);
% BMIMPORTTMS [ BodyMech 3.06.01 ]: Function used in BODYMECH to load analog data from a dar-file
% for  electrophysiological data generated by PORTI hardware
% INPUT:  (optional) Filename of TMSFile to be assigned
% PROCESS:  - read data from TMS datafiles (using ReadTMS)
%           - select a synchronized part with associated OptoTrakFile
% OUTPUT:  GLOBAL ANSIGNAL

% AUTHOR(S) AND VERSION-HISTORY
% $ Ver 1.0 Creation (Jaap Harlaar, VUmc, Amsterdam, October 2000)
% $ Ver 3.06.01 VUmc, Amsterdam, May 2006 (Jaap Harlaar en Caroline Doorenbosch) 

% Copyright 2000-2006 This program is free software under the terms of the
% GNU General Public License (www.gnu.org) 

BodyMechFuncHeader

% invoke the windows-file-browser when no input is given:
if nargin==1
   [datafile,datapath] = uigetfile(filename, 'open PORTI file', 40, 40);
else
   [datafile,datapath] = uigetfile('*.S??', 'open PORTI file', 40, 40);
end

if datafile ~= 0
   [Signal,Sfreq,SignalName] = ReadTMS([datapath,datafile]);
   eval(['cd ',datapath]);
else 
   return
end

ANSIGNAL_DATA=Signal;
ANSIGNAL_TIME_OFFSET=0.;  % see remark below
ANSIGNAL_TIME_GAIN=1/Sfreq;

% ============================================================
% ==== selection synchronized part (with associated OT file)===
%
str=SignalName;
[SyncChannel,ok] = listdlg('PromptString','Select SYNC channel, if any...:',...
   'SelectionMode','single',...
   'ListString',str);
   
if ok==1,
    OTactive=ANSIGNAL_DATA(:,SyncChannel);
    
    % check when OptoTrak acquisition was active 
    OTactiveIndices=find(OTactive==0); % NB this can also be >= 0 dependent
                                       % on Sync before and after OT is active

    if ~isempty(OTactiveIndices),
        Start=OTactiveIndices(1);
        Stop=OTactiveIndices(end);
    else
        Start=1; % no SYNC info, take all the data
        Stop=length(ANSIGNAL_DATA);   
    end
end
if Stop>=Start,
    ANSIGNAL_DATA=ANSIGNAL_DATA(Start:Stop,:);
    % NB this selection does not affect ANSIGNAL_TIME_OFFSET
    % since this is ZERO per definition at start 
end

return
% ============================================ 
% END ### BMimportTMS ###
