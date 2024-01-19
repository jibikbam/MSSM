# MSSM
Multiscale Structural Mapping (MSSM) is a method for imaging biomarkers of neurological diseases such as Alzheimer's disease. It leverages both macrostructural and microstructural properties throughout the cerebral cortex using a single structural MRI. 

Microstructural properties (or indirect index of tissue microstructure) are captured by multiple ratios between cortical gray matter and subcortical white matter intensity at each vertex. 

Microstructural feature map generation using a structural T1-weighted image. We expanded the intensity/contrast metrics (GWR) to include tissue sampling from multiple points through the thickness of the cortical ribbon and subjacent white matter to obtain an array of intensity-linked features.

Morphometry measures are 

## Environment
- Linux (or Mac)
- [Freesurfer](https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall) (>=7.0 recommended)

## How to run
1. Prepare your subjects' or participants' brain images (e.g. 3D T1w, 3D T2w)
2. Run `recon-all -s <subjid> --all` in shell
3. Run `mssm -s <subjid>` in shell (WIP)

## Papers
Cite these papers if you use it
- Jang, I., Li, B., Riphagen, J.M., Dickerson, B.C., Salat, D.H. and Alzheimer’s Disease Neuroimaging Initiative, 2022. Multiscale structural mapping of Alzheimer’s disease neurodegeneration. NeuroImage: Clinical, 33, p.102948.
- Jang, I., Li, B., Rashid, B., Jacoby, J., Huang S.Y., Dickerson, B.C., Salat, D.H. and Alzheimer’s Disease Neuroimaging Initiative, 2024. Brain structural indicators of β-amyloid neuropathology. Neurobiology of Aging, ??, p.??.
