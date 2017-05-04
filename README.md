# Welcome to the Glucose Insulin model
## The physiologically-based whole-body model of the glucose-insulin-glucagon regulatory system

Within this repository, we distribute the physiologically-based whole-body model of glucose-insulin-glucagon regulation based on the model developed at Bayer and first published in [[1](#references)]. The model (referred to as the Glucose Insulin Model or GIM in following) includes physiologically-based pharmacokinetics/pharmacodynamics (PBPK/PD) models of glucose, insulin, and glucagon, coupled by complex regulatory interactions on various mechanistic levels. The model was updated to reflect software development over the years. The general description of implemented process provided in [[1](#references)] is still valid and the user is encouraged to read the publication to get insight into model structure. Selected publications addressing the application of GIM are [[2,3,4](#references)].

Extensions and updates are worked on.

## Repository files
* The model is provided as a ready-to-use MoBi project “**GlucoseInsulinModel.mbp3**”. By default, the model describes glucose metabolism typical for a healthy population. A type 1 diabetes mellitus (T1DM) patient can be simulated by applying the respective parametrization, which is implemented as the parameter start values building block “GIM_PSV_T1DM”. The concept of working with building blocks is described in the [manual](https://github.com/Open-Systems-Pharmacology/OSPSuite.Documentation/blob/master/Open%20Systems%20Pharmacology%20Suite.pdf) of the Open Systems Pharmacology Suite (_OSPS_).
The distributed project file includes six exemplary simulations of different perturbation experiments. Experimental conditions and data are reported in [[5,6](#references)]. Following protocols are simulated:

  * _Intravenous glucose tolerance test (IVGTT)_: 500 mg/kg body weight glucose infused intravenously over 3 minutes [[5](#references)]
  * _Intravenous insulin tolerance test (IVITT)_: 0.04 IU/kg body weight insulin infused intravenously over 3 minutes [[5](#references)]
  * _Continuous insulin infusion (CIVII)_: 0.25 mIU/kg body weight/min insulin infusion for 150 minutes [[5](#references)]
  * _Oral glucose tolerance test (OGTT)_: Ingestion of 100 g glucose solution[[5](#references)]
  * _IVGTT with constant insulin infusion in T1DM patients_: 250 mg/kg body weight glucose infused intravenously over 1 minute accompanied by constant subcutaneous insulin infusion [[6](#references)]. Insulin infusion rates were provided by the Medical University of Graz
  * _IVGTT with insulin infusion mimicking healthy insulin response_: 250 mg/kg body weight glucose infused intravenously over 1 minute accompanied by variable subcutaneous insulin infusion [[6](#references)]. Insulin infusion rates were provided by the Medical University of Graz
  
  To simulate the experiments, some standard application protocols are implemented in the Events-Building Block. By default, all events are disabled. To enable an event, the value of the parameter “_Active_”, located in the “_ProtocolSchemaItem_”-container of the respective application, must be set to 1.
The presented cases should be treated as examples of how to create simulations of certain protocols and may not describe the best possible model performance.

* Parametrization of the model can be performed by changing the values of the selected parameters. Sets of parameters can be easily imported into an existing parameters start values building block from an Excel-file. Example of such a file is provided as “**ParSets_OSPS.xls**”. The file includes three sheets – “_Global_”, “_Healthy_”, and “_T1DM_”. The sheet “_Global_” is empty and can be utilized to store parameter sets valid for all populations. The sheets “_Healthy_” and “_T1DM_” store parameter sets describing healthy and T1DM populations, respectively.

* Batch simulations can be performed in Matlab. The script file “**GIM_simulations.m**” shows how to simulate the above mentioned protocols from a single generic simulation file. The simulation file “**GIM_Healthy.xml**” was created from the respective simulation in the MoBi-project. When executing the script, be sure that the MoBi-toolbox for Matlab is included into Matlab path. The Toolbox can be found under **_Program Files (x86)/Open Systems Pharmacology/MoBi Toolbox for Matlab X.Y_**.
The script generates a figure comparing simulation results with experimental data as in “**GIM_simulations.png**”. Experimental data (obtained by data extraction software from [[5](#references)] or provided by the authors of [[6](#references)]) is located in the folder “**Data**”.
Note that the script applies parameter values defined in “**ParSets_OSPS.xls**”. By changing values in the Excel-file (or addressing alternative files), new parameter sets can be tested out without altering the model itself.
The exemplary output figure generated is the following:

![gim_simulations](https://github.com/Open-Systems-Pharmacology/Glucose-Insulin-Model/blob/master/GIM_simulations.png)

## Version information
The physiology is based on the PBPK model implemented in PK-Sim version 5.6. The MoBi project file was created in version 7.0.

## Code of conduct
Everyone interacting in the Open Systems Pharmacology community (codebases, issue trackers, chat rooms, mailing lists etc...) is expected to follow the Open Systems Pharmacology [code of conduct](https://github.com/Open-Systems-Pharmacology/Suite/blob/master/CODE_OF_CONDUCT.md).

## Contribution
We encourage contribution to the Open Systems Pharmacology community. Before getting started please read the [contribution guidelines](https://github.com/Open-Systems-Pharmacology/Suite/blob/master/CONTRIBUTING.md). If you are contributing code, please be familiar with the [coding standard](https://github.com/Open-Systems-Pharmacology/Suite/blob/master/CODING_STANDARDS.md).

## License
The GIM model code is distributed under the [GPLv2 License](https://gitprint.com/Open-Systems-Pharmacology/Suite/blob/develop/LICENSE).

## References
[1] [Schaller S, Willmann S, Lippert J, Schaupp L, Pieber TR, Schuppert A, Eissing T. A generic integrated physiologically based whole-body model of the glucose-insulin-glucagon regulatory system. CPT: Pharmacometrics & Systems Pharmacology (2013) 2:e65; doi:10.1038/psp.2013.40.](http://onlinelibrary.wiley.com/doi/10.1038/psp.2013.40/abstract)

[2] [Schaller S, Willmann S, Schaupp L, Pieber TR, Schuppert A, Lippert J, Eissing T. A new Perspective on Closed-Loop Glucose Control using a Physiology-Based Pharmacokinetic/Pharmacodynamic Model Kernel. IFAC Proceedings Volumes (2012), 45(18):420-425.](http://www.sciencedirect.com/science/article/pii/S1474667016321358)

[3] [Schaller S, Lippert J, Schaupp L, Pieber T, Schuppert A, Eissing T. Robust PBPK/PD-Based Model Predictive Control of Blood Glucose. IEEE Transactions on Biomedical Engineering  (2016), 63(7):1492-1504.](http://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=7315018)

[4] [Lahoz-Beneytez J, Schaller S, Macallan D, Eissing T, Niederalt C, Asquith B. Physiologically Based Simulations of Deuterated Glucose for Quantifying Cell Turnover in Humans. Frontiers in  Immunology (2017), 8:474. doi: 10.3389/fimmu.2017.00474](http://journal.frontiersin.org/article/10.3389/fimmu.2017.00474/abstract)

[5] [Sorensen JT. A physiologic model of glucose metabolism in man and its use to design and assess improved insulin therapies for diabetes. Thesis (Sc. D.). Massachusetts Institute of Technology (1985).](https://dspace.mit.edu/handle/1721.1/15234)

[6] [Regittnig W, Trajanoski Z, Leis HJ, Ellmerer M, Wutte A, Sendlhofer G, Schaupp L, Brunner G A, Wach P, Pieber TR. Plasma and interstitial glucose dynamics after intravenous glucose injection: evaluation of the single-compartment glucose distribution assumption in the minimal models. Diabetes (1999), 48(5), 1070-1081.](https://www.ncbi.nlm.nih.gov/pubmed/10331412)
