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
![image](https://user-images.githubusercontent.com/87049112/138378577-f7c11296-f872-4de7-a206-f58ed3907540.png)
- intermodulation improvement, 2C
![image](https://user-images.githubusercontent.com/87049112/138378911-e7db40a0-4006-417b-977f-a770e5663c38.png)
- PAR, 2C        
![image](https://user-images.githubusercontent.com/87049112/138379029-180d9daf-ed52-4f15-a0b9-d208473f7fb5.png)

10. Add Ripple to ORX full bandwidth
- paRipple = 10 %% 2021-10-22, Add Ripple to ORX
- DPD result: evm:0.7091%, ACLR:49dB, the Ripple will be optimizied by learning
![image](https://user-images.githubusercontent.com/87049112/138404320-60f545aa-bd0a-40fe-9126-7e1b605f4cee.png)

2021-11-09,               
11. Add ORX SNR parameter, sweep SNRdB 50:-10:10
- dpdparams.ORX_SNRdB = 10
- The ORX SNR decrease to 10dB, that impact the DPD ACLR results about 3dB.
![image](https://user-images.githubusercontent.com/87049112/140844716-5812d57f-fbcc-4f98-818d-21b83fd62b6e.png)

12. Add ORX Ripple(Fullband 122.88MHz) parameter, sweep RippledB 0:2:10
- The ACLR will be unbalanced and results worse about 4dB at Low freqs.
![image](https://user-images.githubusercontent.com/87049112/140856955-f252a472-4587-4315-a348-f818b64d21e8.png)

## going to do...
13. compare the DPD ACLR performance between differenet ACLR source ?
14. compare the ccdf 0.01% between different modulation type?
15. compare the DPD performance between different source IBW ?
