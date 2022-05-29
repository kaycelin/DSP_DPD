# Study_DSP_DPD
- offline DPD study
- DPD model reference from https://github.com/ctarver/ILA-DPD

1. x: signal pa in
2. generate pa model(Memoryless): 
- IIP3dBm = 40
- AMPMdeg = 1
- LinearGaindB = 10
- PowerUpperLimit = 45
- Ripple = 0
3. y: signal pa out and aclr polot, evm_y :6.235%
![image](https://user-images.githubusercontent.com/87049112/138379342-52b683ac-06a2-474a-a41d-6bf985b4658a.png)

4. Learning parameters:
- dpdparams.order_poly = 3+2*1
- dpdparams.depth_memory = 1+2*1
- dpdparams.depth_lag = 2
- dpdparams.depth_memory_lag = 2
- dpdparams.order_poly_lag = 2
- dpdparams.Niterations = 20
- dpdparams.learning_rate = 0.8
- dpdparams.learning_method = []
- dpdparams.flag_even_order_poly = 1
- dpdparams.flag_conj = 0;   % Conjugate branch. Currently only set up for MP (lag = 0)
- dpdparams.flag_dc_term = 0; % Adds an additional term for DC
- dpdparams.flag_LS_exclude_zero_second = 0
- dpdparams.modelfit = 'WIN' % 'GMP'/'HAM'/'WIN'
- dpdparams.learning_arc = 'DLA';

5. DPD learning and curvefit iteration
![image](https://user-images.githubusercontent.com/87049112/138372239-15930747-b7b3-4a5e-a36a-acb57c78eed2.png)

6. ACLR upgrade from 32.77 to 46.92, evm upgrade from 6.235% to 0.8789%
![image](https://user-images.githubusercontent.com/87049112/138372478-6201a5f4-5cdc-4d22-879a-660f267869bf.png)
7. PAR results                                                         
![image](https://user-images.githubusercontent.com/87049112/138372742-c06834c2-ec2d-4675-864d-3dacc601905d.png)
8. Model/ Architecture /Iterations comparsion         
![image](https://user-images.githubusercontent.com/87049112/138373658-207e618e-6dd1-4188-9a0f-a57399ff097f.png)
![image](https://user-images.githubusercontent.com/87049112/138375185-99ac0e48-d4e4-41f0-a2c7-6402d142daa1.png)

9. 2C signal

|              | 1C Pwr(dBm) | 2C Pwr(dBm) |
| -------------| ----------- | --------    |
| x            | 14.9        | 11.89, 11.89|
| y            | 34.8        | 31.80, 31.80|
| y+DPD        | 35.0        | 31.92, 31.92|
|              | 1C ACLR(dBm)      | 2C ACLR(dBm), (L1,C,U1) |
| x            | 55.2, 55.1        | 54.6, 52.1, 54.6         |
| y            | 32.7, 32.7        | 32.6, 29.7, 32.6         |
| y+DPD        | 47.9, 46.9        | 50.4, 48.4, 50.5         |
|              | 1C PAR (dB) | 2C PAR (dB)  |
| x            | 10.9        | 13.9         |
| y            | 10.6        | 13.8         |
| y+DPD        | 11.1        | 13.3         |

![image](https://user-images.githubusercontent.com/87049112/138378577-f7c11296-f872-4de7-a206-f58ed3907540.png)
- intermodulation improvement, 2C
![image](https://user-images.githubusercontent.com/87049112/138378911-e7db40a0-4006-417b-977f-a770e5663c38.png)
- PAR, 2C        
![image](https://user-images.githubusercontent.com/87049112/138379029-180d9daf-ed52-4f15-a0b9-d208473f7fb5.png)

10. Add Ripple to ORX full bandwidth
- paRipple = 10 %% 2021-10-22, Add Ripple to ORX
- DPD result: evm:0.7091%, ACLR:49dB, the Ripple will be optimizied by learning

| pa Ripple (dB)   | ACLR L(dB)   | ACLR U(dB)  |
| -------------    | -------------| --------    |
| 0                | 51.7         | 51.5        |
| 10               | 49.25        | 49.9        |

![image](https://user-images.githubusercontent.com/87049112/138404320-60f545aa-bd0a-40fe-9126-7e1b605f4cee.png)

2021-11-09,               
11. Add ORX SNR parameter, sweep SNRdB 50:-10:10
- dpdparams.ORX_SNRdB = 10
- The ORX SNR decrease to 10dB, that impact the DPD ACLR results about 3dB.  

| ORXSNR (dB)   | ACLR (dB)       | EVM (%)     | Inband Pwr (dBm) |
| -------------| -------------    | --------    | --------         |
| 50           | 51.7, 51.5       | 0.38        | 34.95            |
| 40           | 51.7, 51.5       | 0.38        | 34.95            |
| 30           | 51.6, 51.4       | 0.38        | 34.96            |
| 20           | 51.0, 51.2       | 0.40        | 35.11            |
| 10           | 48.1, 48.4       | 0.68        | 36.32            |

![image](https://user-images.githubusercontent.com/87049112/140844716-5812d57f-fbcc-4f98-818d-21b83fd62b6e.png)

12. Add ORX Ripple(Fullband 122.88MHz) parameter, sweep RippledB 0:2:10
- The ACLR will be unbalanced and results worse about 4dB at Low freqs.

| ORX Ripple (dB) | ACLR L(dB) | ACLR U(dB) |EVM (%)   |diff ACLR (dB)|
| ------------    | --------   | --------   | -------- |--------      |
| 0               | 51.7       | 51.5       | 0.38     | 0.2          |
| 2               | 51.0       | 51.9       | 1.06     | 0.9          |
| 4               | 50.3       | 52.1       | 2.01     | 1.8          |
| 6               | 49.5       | 52.0       | 2.99     | 2.5          |
| 8               | 48.7       | 51.7       | 3.97     | 3            |
| 10              | 47.8       | 51.3       | 4.96     | 3.5          |

![image](https://user-images.githubusercontent.com/87049112/140856955-f252a472-4587-4315-a348-f818b64d21e8.png)

## going to do...
13. compare the DPD ACLR performance between differenet ACLR source ? 
 
| ACLR(dB)     | w/o AWGN         | w/ AWGN 40dB|
| -------------| -------------    | --------    |
| x            | 55               | 47          |
| y            | 32               | 32          |
| y+DPD        | 51               | 46          |

![image](https://user-images.githubusercontent.com/87049112/169646757-fdb64a80-17ea-493c-9ba9-082c552eab79.png)

14. compare the ccdf 0.01% between different modulation type?
- PA settings:  

| Parameters | paIIP3dBm | paAMPMdeg | paLinearGaindB | paPowerUpperLimit |
| -----------| ----------| --------  | --------       | --------          |
|            | 31dBm     | 1deg      | 20dB           | 35dBm             |

- x, y, y+DPD, PAR vs ACLR  

|       | w/o CFR _ PAR(dB) | w/ CFR _ PAR(dB) | w/o CFR _ Pwr(dBm) | w/ CFR _ Pwr(dBm) | w/o CFR _ ACLR(dB)  | w/ CFR _ ACLR(dB)  |
| ------| -------------     | --------         | --------           | --------          | --------            | --------           |
| x     | 10.9              | 7.5              | 14.99              | 14.96             | 55.22/ 55.17        | 55.06/ 55.02       |
| y     | 8.1               | 6.6              | 34.54              | 34.52             | 31.46/ 31.44        | 31.63/ 31.65       |
| y+DPD | 8.1               | 7.4              | 34.54              | 34.55             | 44.35/ 44.46        | 50.30/ 50.21       |

![image](https://user-images.githubusercontent.com/87049112/170856426-113587d8-91e5-4948-9ebe-77bd2e47e785.png)
![image](https://user-images.githubusercontent.com/87049112/170856433-b67d7cc0-9d88-4376-b4ab-8a83b9e507ab.png)

- y+DPD, EVM (compare to x, what is the CFR contribute to EVM ?)

| ACLR(dB)     | w/o CFR _ EVM | w/ CFR _ EVM |
| -------------| ------------- | --------     |
| y+DPD        | 1.05          | 0.47         |

![image](https://user-images.githubusercontent.com/87049112/170856403-59d88942-0368-4247-882c-6e26ba9a8719.png)

15. compare the DPD performance between different source IBW ?
16. compare the input source x' = x add dpd coeffiecents at time and freqency domain?    
![image](https://user-images.githubusercontent.com/87049112/169651422-21d86170-7bdb-44c3-8c9d-574a92f34b67.png)
![image](https://user-images.githubusercontent.com/87049112/169651617-a6f053ee-77a2-43db-9da5-6c411692c3e0.png)
![image](https://user-images.githubusercontent.com/87049112/169651497-e560f4d3-aa30-4f6a-8a54-22d3cb8209e1.png)

17. Add PA memory model and run DPD
18. What is the CFR contribute to EVM ?
