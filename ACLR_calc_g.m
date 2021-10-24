function [ACLRdBOutput, IpwrdBOutput] = ACLR_calc_g(waveform, fs, bwInband, offset, fnum, disp_title, fnum_save_dir, fnum_xlimit, disp_legend, flag_dBm, flag_MultiCarrier)
%% 2020-04-23, flag_half = 'full', default
%% 2021-06-14, flag_dBm = 0, default
%% 2021-08-04, flag_MultiCarrier = '1C', default
%% 2021-10-20, add window plot, winType:brickwall, RBW:1000df

if ~exist('flag_dBm','var')||isempty(flag_dBm)
    flag_dBm = 0;
end
% if ~exist('disp_legend','var')||isempty(disp_legend)
%     disp_legend=[];
%     newline=[];
% end
disp_legend_ACLR = [];
if size(waveform,2)>size(waveform,1)
    waveform = waveform.'; % column
end
DIMFFT = 1;
NBr = size(waveform,2);
Nsamps = size(waveform,1);
df = fs/Nsamps;
f = df*(-Nsamps/2:Nsamps/2-1);
% if size(waveform,1)>NBr
%     DIMFFT=1;
% else
%     DIMFFT=2;
% end

%% 2020-04-23, MultiCarier input from bwInband
if isempty(bwInband)
    error('input of bwInband?!')
else
    NCarriers = size(bwInband,1);
end

if ~exist('flag_MultiCarrier','var')||isempty(flag_MultiCarrier)||strcmpi(flag_MultiCarrier,'1C')
    flag_MultiCarrier = '1C'; % default 1C
elseif strcmp(flag_MultiCarrier,'2C')||(NCarriers==2 && ~any(bwInband(1,:)==bwInband(2,:)))
    flag_MultiCarrier = '2C';
else
    error('Multi Carrier ?')
end

% initial parameters
ACLR_MASK = zeros(1,Nsamps);

if length(offset)==1&length(offset)<NCarriers % the same bw
    offset = repmat(offset,1,NCarriers);
end

% for idBR = 1:NBr
for idC = 1:NCarriers
    % tableInput and display
    if exist('disp_title','var')&&~isempty(disp_title)
        NCarriersOfTitle=size(disp_title,1);
        if iscell(disp_title)
            if NCarriersOfTitle~=1
                disp_title_idC = cell2mat(disp_title(idC,:));
            else
                disp_title_idC = cell2mat(disp_title);
            end
        elseif ischar(disp_title)
            if NCarriersOfTitle~=1
                disp_title_idC = (disp_title(idC,:));
            else
                disp_title_idC = (disp_title);
            end
        end
    else
        disp_title_idC=[];
    end
    
    % display title
    if NCarriers>1
        display_title = [disp_title_idC, ' ACLR of Carrier',num2str(idC)];
    else
        display_title = [disp_title_idC, ' ACLR'];
    end
    if NBr>1
        display_title = [display_title, ' of ', num2str(NBr),' branches'];
    end
    
    bwInband_idC = bwInband(idC,:);
    offset_idC = offset(idC);
    fc = mean(bwInband_idC);
    
    flag_half = 'full';
    if ~exist('offset','var')||isempty(offset_idC)
        offset_idC = bwInband_idC;
    elseif offset_idC > bwInband_idC
        bw_tolerance = 0;
    end
    
    % Pwr calculation
    bw_tolerance = 0e6;
    ind_Inband = [];
    [IpwrdB_Inband, ind_Inband, ~] = Pwr_Inband_g(fft(waveform(:,:), [], DIMFFT), fs, bwInband_idC, bw_tolerance, flag_half, [], flag_dBm);
    
    %% 2020-04-23, bwOffsetLeft<0
    ind_OffsetLeft = [];
    ind_OffsetRight = [];
    bwOffsetLeft = bwInband_idC-offset_idC;
    [IpwrdB_OffsetLeft, ind_OffsetLeft(:,:), ~] = Pwr_Inband_g(fft(waveform), fs, bwOffsetLeft, 0e6, flag_half, 0, flag_dBm);
    bwOffsetRight = bwInband_idC+offset_idC;
    [IpwrdB_OffsetRight, ind_OffsetRight(:,:), ~] = Pwr_Inband_g(fft(waveform), fs, bwOffsetRight, bw_tolerance, flag_half, 0, flag_dBm);
    
    % ACLR calculation
    ACLRdB_Left = IpwrdB_Inband-IpwrdB_OffsetLeft;
    ACLRdB_Right = IpwrdB_Inband-IpwrdB_OffsetRight;
    
    if ~exist('fnum','var')||isempty(fnum)||(any(fnum==0))
        fnum = [];
    else
        figure(fnum(1))
        
        if exist('flag_dBm','var')&&~isempty(flag_dBm)&&(flag_dBm==1)
            %         disp_ACLR = ['IpwrdBm: ', num2str(round(min(IpwrdB_Inband),2)),'\ACLRLdB: ', num2str(round(min(ACLRdB_Left),2)),'\ACLRRdB: ', num2str(round(min(ACLRdB_Right),2))];
            %                 disp_ACLR = ['IpwrdBm: ', num2str(round(min(IpwrdB_Inband),2)),' ACLRLdB: ', num2str(round(min(ACLRdB_Left),2)),' ACLRRdB: ', num2str(round(min(ACLRdB_Right),2))];
            %                 disp_ACLR = ['IpwrdBm: ', sprintf('%0.2f',IpwrdB_Inband),' ACLRLdB: ', sprintf('%0.2f',ACLRdB_Left),' ACLRRdB: ', sprintf('%0.2f',ACLRdB_Right)];
            disp_ACLR_Ipwr = 'IpwrdBm: ';
        else
            %         disp_ACLR = ['IpwrdB: ', num2str(round(min(IpwrdB_Inband),2)),'\ACLRLdB: ', num2str(round(min(ACLRdB_Left),2)),'\ACLRRdB: ', num2str(round(min(ACLRdB_Right),2))];
            %                 disp_ACLR = ['IpwrdB: ', num2str(round(min(IpwrdB_Inband),2)),' ACLRLdB: ', num2str(round(min(ACLRdB_Left),2)),' ACLRRdB: ', num2str(round(min(ACLRdB_Right),2))];
            disp_ACLR_Ipwr = 'IpwrdB: ';
        end
        disp_ACLR = [disp_ACLR_Ipwr, sprintf('%0.2f',IpwrdB_Inband),' ACLRLdB: ', sprintf('%0.2f',ACLRdB_Left),' ACLRRdB: ', sprintf('%0.2f',ACLRdB_Right)];
        
        if strcmp(flag_MultiCarrier,'1C')
            disp_legend_ACLR = [disp_legend, newline, disp_ACLR]
        elseif strcmp(flag_MultiCarrier,'2C')&&(idC~=2)
            disp_legend_ACLR1 = [disp_legend, ', ', disp_ACLR, newline];
            disp_legend_ACLR = [disp_legend_ACLR, disp_legend_ACLR1];
        elseif strcmp(flag_MultiCarrier,'2C')&&(idC==2)
            disp_legend_ACLR1 = [disp_legend, ', ', disp_ACLR, newline];
            disp_legend_ACLR = [disp_legend_ACLR, disp_legend_ACLR1]
        end
        
        if strcmp(flag_MultiCarrier,'1C')||(strcmp(flag_MultiCarrier,'2C')&&idC==2)
            if 0
                PLOT_FFT_dB_g(waveform, fs, length(waveform), [disp_legend_ACLR], 'df', 'full', 'pwr', fnum); hold on
            else %% 2021-10-20, add window plot, winType:brickwall, RBW:1000df
                %             plt_win.RBW = 100e3;
                plt_win.RBW = 1000*df;
                plt_win.winType = 'brickwall';
                %             plt_win.winType = 'gaussian'
                PLOT_FFT_dB_WIN_g(waveform, fs, length(waveform), [disp_legend_ACLR], 'df', plt_win, 'pwr', fnum); hold on
            end
        end
        
        flag_plotlimit = 0;
        if flag_plotlimit
            if isrow(ind_Inband)&&isrow(ind_OffsetLeft)&&isrow(ind_OffsetRight)
                ACLR_MASK([ind_Inband, ind_OffsetLeft, ind_OffsetRight])=1;
            elseif iscolumn(ind_Inband)&&iscolumn(ind_OffsetLeft)&&iscolumn(ind_OffsetRight)
                ACLR_MASK([ind_Inband; ind_OffsetLeft; ind_OffsetRight])=1;
            else
                error('!')
            end
            
            if strcmp(flag_MultiCarrier,'1C')||(strcmp(flag_MultiCarrier,'2C')&&idC==2)
%                 yyaxis right, plot(f,ACLR_MASK,'r--','Linewidth',1, 'displayname', [disp_legend_ACLR]); hold on
                yyaxis right, plot(f,ACLR_MASK,'r--','Linewidth',1, 'displayname', ['aclr mask']); hold on
                ylim([0, 1])
                yyaxis left
            end
        end
        
        if exist('fnum_xlimit','var')&&~isempty(fnum_xlimit)
            xlim([min(fnum_xlimit), max(fnum_xlimit)])
            %             ind_f_xlimit = ismember(f,ind_xlimit);
            %             ind_xlimit = min(fnum_xlimit):max(fnum_xlimit);
        elseif strcmp(flag_MultiCarrier,'1C')
            xlim([min(bwOffsetLeft), max(bwOffsetRight)])
            %             ind_xlimit = min(bwOffsetLeft):max(bwOffsetRight);
        elseif strcmp(flag_MultiCarrier,'2C')&&idC==1
            bwOffsetLeft1 = bwOffsetLeft;
            bwOffsetRight1 = bwOffsetRight;
        elseif strcmp(flag_MultiCarrier,'2C')&&idC==2
            xlim([min([bwOffsetLeft1, bwOffsetLeft]), max([bwOffsetRight1, bwOffsetRight])])
        end
        
        %         title('spectrum')
        title([display_title])
        
        
        %% 2020-10-31, fnum_save_dir: save picture to folder
        if exist('fnum_save_dir')&&~isempty(fnum_save_dir)
            fnum_save_file = [fnum_save_dir,'\',num2str(fnum),'.fig']
            saveas(gcf,[fnum_save_file])
        end
        
    end
    
    % export
    IpwrdB.IpwrdB_Inband = IpwrdB_Inband;
    IpwrdB.IpwrdB_OffsetLeft = IpwrdB_OffsetLeft;
    IpwrdB.IpwrdB_OffsetRight = IpwrdB_OffsetRight;
    
    ACLRdB.ACLRdBLeft = ACLRdB_Left;
    ACLRdB.ACLRdBRight = ACLRdB_Right;
    
    %     indInband_Ouptut(idCarrier,:) = ind_Inband;
    IpwrdBOutput(idC,:) = IpwrdB;
    ACLRdBOutput(idC,:) = ACLRdB;
end

end