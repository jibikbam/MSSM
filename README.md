# MSSM
Multiscale Structural Mapping (MSSM) is a method for imaging biomarkers of neurological diseases such as Alzheimer's disease. It leverages both macrostructural and microstructural properties throughout the cerebral cortex using a single structural MRI.

Microstructural properties (or indirect index of tissue microstructure) are captured by the contrast between cortical gray matter and subcortical white matter intensity at each vertex. We expand the contrast metrics to include tissue sampling from multiple points through the thickness of the cortical ribbon and subjacent white matter to obtain an array of intensity-linked features. The figure below demonstrates the process using a T1-weighted MR image. 

![Alt text](./img/gwr_generate.jpg?raw=true "GWC")

Morphometry measures such as cortical thickness and curvature maps represent macrostructural properties. They are obtained by running [`recon-all`](https://surfer.nmr.mgh.harvard.edu/fswiki/recon-all) with [FreeSurfer](https://surfer.nmr.mgh.harvard.edu) toolbox.

You get multiple features at each vertex of the participants' cortical surface (3D mesh). You can either use all these features or reduce the feature dimensionality. We used the partial least squares (PLS) method to have one metric at each vertex. From there, you either run statistical analyses or make a prediction model as you like. The figure below shows a flowchart.

![Alt text](./img/flowchart.jpg?raw=true "flowchart")


## Environment
- Linux (or Mac)
- [Freesurfer](https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall) (>=7.0 recommended)


## How to run MSSM
1. Prepare your subjects' or participants' brain images (e.g. 3D T1w, 3D T2w)
2. Run `recon-all -s <subjid> --all` in shell
3. Copy or link the script into a directory that is on the $PATH. Usually /usr/bin and /usr/local/bin/ are on the path. So run `ln -s /path/to/mssm-script /usr/local/bin`
4. Run `mssm -s <subjid>` in shell (WIP)


## Papers
Cite these papers if you use it
- Jang, I., Li, B., Riphagen, J.M., Dickerson, B.C., Salat, D.H. and Alzheimer’s Disease Neuroimaging Initiative, 2022. Multiscale structural mapping of Alzheimer’s disease neurodegeneration. NeuroImage: Clinical, 33, p.102948.
- Jang, I., Li, B., Rashid, B., Jacoby, J., Huang S.Y., Dickerson, B.C., Salat, D.H. and Alzheimer’s Disease Neuroimaging Initiative, 2024. Brain structural indicators of β-amyloid neuropathology. Neurobiology of Aging, ??, p.??.
