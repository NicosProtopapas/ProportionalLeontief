# Simulation of Proportional and Conflict DRF Mechanisms

## Overview
This MATLAB project provides a modular framework to simulate the Price of Anarchy (PoA) in:
- **Proportional DRF** with variable exponents
- **Conflict DRF** which caps allocation for high-conflict bidders
- **Greedy** which allocates greadily.

Under quasilinear utilities.

## Folder Structure
```
simulation_project/
├── config.json
├── README.md
├── runSimulation.m
├── compareMechanismsPlot.m
├── DataGen/
│   └── dataGenerator.m
├── Mechanisms/
│   ├── allocateAndPay.m
│   ├── mech_proportionalDRF.m
│   ├── mech_conflictDRF.m
│   ├── pay_payYourBid.m
│   ├── computeUtility.m
│   └── bestResponseDriver.m
├── Sim/
│   ├── findExtremePoA.m
│   └── replotResults.m
└── Utils/
    └── solveOptimalLeontief.m
```

## Usage
1. Configure **`config.json`** (agent counts, distributions, mechanisms, exponents, etc.).
2. Run in MATLAB:
   ```matlab
   runSimulationParallel('config.json');
   ```
3. For side-by-side mechanism comparison:
   ```matlab
   compareMechanismsPlot;
   ```
4. To replot saved results:
   ```matlab
   replotResults('results/<mechanismName>');
   ```

## Requirements
- MATLAB R2020b or later
- Statistics Toolbox (for `mvnrnd`)
- Optimization Toolbox (for `linprog`)
