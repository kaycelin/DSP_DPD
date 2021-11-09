%% PA1, 2021-05-27
%% PA2, 2021-06-15
%% PA3, 2021-10-18
%% PA4, 2021-10-22, Add Ripple to ORX

clear all
close all
clc
%% input: signal type ofdm/cw
signalType = 'ofdm' % ofdm/cw
flag_carriers = '1C'
% signalType = 'cw'

switch signalType
    case 'ofdm'
        switch flag_carriers
            case '1C'
                load('waveform_OFDM_20MHz_122p88MHz.mat') % 1C
                bwInband = 9e6*[-1 1] % 1C
                gain = 1;
                
            case '2C'
                load('waveform_OFDM_20MHz_2C_122p88MHz.mat') % 1C
                %         load('waveform_OFDM_20MHz_2C_245p76MHz.mat') % 2C
                % load('waveform_OFDM_20MHz_2C_491p52MHz.mat') % 2C
                bwInband(1,:) = 9e6*[-1 1]+20e6 % 2C-1
                bwInband(2,:) = 9e6*[-1 1]-20e6 % 2C-2
                gain = 0.707;
        end
        
        NUps = 1
        fs = 122.88e6*NUps
        x = signal*gain;
        Nsamps = numel(x)
        
        
    case 'cw'
        tx_length = 2^17;
        ts_tx = 1/40e6;
        t = [0:ts_tx:((tx_length - 1) * ts_tx)].';   % Create time vector (Sample Frequency is ts_tx (Hz))
        tx_Data = 0.6 * exp(1i*2*pi * 2e6 * t) + 0.2 * exp(1i*2*pi * -3e6 * t);
        fs = 1/ts_tx;
        x = tx_Data;
        Nsamps = numel(x);
end

%% input: pa model
PA_board = 'Memoryless' % ILA-DPD-master: WARP/webRF/none and Memoryless: offline PA model for DPD

%% output: pa model(webRF(online) or Memoryless(offline))
switch PA_board
    case 'WARP'
        warp_params.nBoards = 1;         % Number of boards
        warp_params.RF_port  = 'A2B';    % Broadcast from RF A to RF B. Can also do 'B2A'
        pa = WARP(warp_params);
        Fs = 40e6;    % WARP board sampling rate.
    case 'none'
        pa = PowerAmplifier(7, 4);
        Fs = 40e6;    % WARP board sampling rate.
    case 'webRF'
        dbm_power = -30;
        pa = webRF_g(dbm_power, fs);
    case 'Memoryless'
        paIIP3dBm = 40
        paAMPMdeg = 1
        paLinearGaindB = 20
        paPowerUpperLimit = 45
        paRippledB = 0 %% 2021-10-22, Add Ripple to ORX
        paSNRdBin = [] %% 2021-11-08, Add AWGN before pa
        
        pa = DPD_PA_MemorylessNonlinearity_g('IIP3dBm',paIIP3dBm,'AMPMdeg',paAMPMdeg,...
            'LinearGaindB',paLinearGaindB,'PwrdBmLimitUpper',paPowerUpperLimit,...
            'Ripple',paRippledB,'SNRdB',paSNRdBin);
end

dipsLegend = [];
if exist('paRippledB','var')&&(paRippledB~=0)
    dispRipple = [', paRippledB:',num2str(paRippledB),'dB'];
else
    dispRipple = [];
end
fnum = 101901
%% input:
PdBm_x = 10*log10(mean(abs(x).^2))+30

%% output: pa output signal
y = pa(x);
PdBm_y = 10*log10(mean(abs(y).^2))+30
[PAR_x] = CCDF_g(x, Nsamps, fnum, 'x')
[PAR_y] = CCDF_g(y, Nsamps, fnum, 'y')

% %% input: Add Ripple to ORX
% RippleORX = 2
% [y, evmRippleORX, ~] = SYM_MagRippleEQApp(y, RippleORX, fs, bwInband, bwInband, [], [], []);

%% plot: ACLR
aclr_offset = 20e6;
ACLR_calc_g(x, fs, bwInband, aclr_offset, [fnum+1], [], [], [], ['x'], [], flag_carriers)
ACLR_calc_g(y, fs, bwInband, aclr_offset, [fnum+1], [], [], [], ['y'], [], flag_carriers)

evm_y = dsp_evm_timexcorr_inband_g(x, y, fs, bwInband, [], []);

%% input: learning parameters
dpdparams.order_poly = 3+2*1
dpdparams.depth_memory = 1+2*2
dpdparams.depth_lag = 2
dpdparams.depth_memory_lag = 2
dpdparams.order_poly_lag = 2
dpdparams.Niterations = 30
dpdparams.learning_rate = 0.8
dpdparams.learning_method = []
dpdparams.flag_even_order_poly = 1
dpdparams.flag_conj = 0;   % Conjugate branch. Currently only set up for MP (lag = 0)
dpdparams.flag_dc_term = 0; % Adds an additional term for DC
dpdparams.flag_LS_exclude_zero_second = 0
dpdparams.modelfit = 'WIN' % 'GMP'/'HAM'/'WIN'
% dpdparams.modelfit = 'HAM' % 'GMP'/'HAM'/'WIN'
% dpdparams.modelfit = 'GMP' % 'GMP'/'HAM'/'WIN'

% dpdparams.CFR.flag = 1;
% dpdparams.CFR.fs = fs;
% dpdparams.CFR.bwInband = bwInband;
% dpdparams.paprdB_limit = [];
% dpdparams.paprdB_limit = 7.5;
% dpdparams.evm = 9.5e6*[-1,1];
dpdparams.evm = bwInband;
dpdparams.learning_arc = 'DLA'; % better!
% dpdparams.learning_arc = 'ILA'; % worse!!
dpdparams.fnum = 0721;

dpdparams.flag_Multicarrier = flag_carriers;

plt.fs = fs
% plt.bwInband = 9.5e6*[-1,1];
plt.bwInband = bwInband
plt.offset = 20e6;

dpdparams.ORX_RippledB = 0;
dpdparams.ORX_SNRdB = 10;
Sweep_ORX_SNRdB = []
Sweep_ORX_RippledB = 0:2:10
for k=1:numel(Sweep_ORX_RippledB)
    dpdparams.ORX_RippledB = Sweep_ORX_RippledB(k);
    
    if isempty(Sweep_ORX_SNRdB)
        Ni = 1
    else
        Ni = numel(Sweep_ORX_SNRdB)
    end
    for i=1:Ni
        try
            dpdparams.ORX_SNRdB = Sweep_ORX_SNRdB(i);
            catach
            dpdparams.ORX_SNRdB = Sweep_ORX_SNRdB;
        end
        %% output: dpd learning
        dpd = DPD_ILA_g(dpdparams);
        [y_DPD, u_paIn_DPD] = dpd.DPD_learning(x, pa, plt, []);
    end
end
dipsLegend = [dipsLegend, dispRipple]
ACLRdB_y = ACLR_calc_g(y_DPD, fs, bwInband, aclr_offset, [fnum+1], [], [], [], ['y+DPD',dipsLegend], [], flag_carriers)
[PAR_yDPD] = CCDF_g(y_DPD, Nsamps, fnum, 'y+DPD')

%% export
plt_win.RBW = 1000*fs/numel(x);
plt_win.winType = 'brickwall';
PLOT_FFT_dB_WIN_g(x, fs, length(x), ['pa in,',flag_carriers], 'df', plt_win, 'pwr', fnum+2); hold on
PLOT_FFT_dB_WIN_g(y, fs, length(x), ['pa out,',flag_carriers], 'df', plt_win, 'pwr', fnum+2); hold on
PLOT_FFT_dB_WIN_g(y_DPD, fs, length(x), ['pa out+DPD,',flag_carriers], 'df', plt_win, 'pwr', fnum+2); hold on

%% DPD coef.
xDPD = dpd.sigOut_u_predistort;
yDPD2 = pa(xDPD);
PLOT_FFT_dB_WIN_g(yDPD2, fs, length(x), ['pa out+DPD,',flag_carriers], 'df', plt_win, 'pwr', fnum+2); hold on


flag_debug = 1
if flag_debug
    try
        k
    catch
        k=1
    end
    x1(k) = dpdparams.ORX_SNRdB
    y1(k) = min(ACLRdB_y.ACLRdBLeft, ACLRdB_y.ACLRdBRight)
    k=k+1
end