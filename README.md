# TIE-toolbox

PURPOSE:

The TIEtoolbox is a set of functions that performs the Trace Information Extraction (TIE) algorithm 
on traces (bedrock interface traces and fault traces) in a geological map. The TIEtoolbox allows to 
load the geological spatial data, extract the traces, perform the TIE and visualise the results.For more
information concerning the TIE, see Rauch et al. (2019): https://doi.org/10.1016/j.jsg.2019.06.007.


-----
TECHNICAL REQUIREMENTS:

- The algorithm is written in Matlab, therefore Matlab must be installed
  to run the algorithm. The code has been tested with version R2018a. 
- In order to load map data into Matlab, the Matlab Mapping Toolbox 
  is required (https://ch.mathworks.com/products/mapping.html)
  (if this is missing, see under 'ADVICE' below)

-----
INPUT REQUIREMENTS:

- The map input data must be set in a projected coordinate system (typically a national projected system),
  where the units are expressed in meters.
- All input data must be part of the same projected coordinate system.

Three different data sets are required as input:
	- 1. Digital Elevation Model of the region in geotif format.
	- 2. Bedrock Data in polygon shapefile format, where one attribute field distinguishes 
	     between different bedrock types. The attribute field must be numeric.
	- 3. Fault Data in polyline shapefile format, where one attribute field distinguishes 
	     between different fault types. The attribute field must be numeric.

A shapefile containing orientation measurements (e.g. bedding orientation) can be added in order
to visualize them at the same time. Orientation measurements are not part of the TIE, yet are
useful to be compared to.
		
- Make sure all your data is in the current Matlab path or that it is registered in a Matlab search path.

-----
CONTENT:

The TIEtoolbox contains four folders and one master running script.

The folders are:
	- LOADfunctions
		-> contains all functions that are needed to load the data and put the data in 
		   the TIE compatible format.
	- TRACEfuntions
		-> contains all functions that are related to traces (and thus to the TIE)
		   to add/analyse information in a structural array
	- GENERALfunctions
		-> contains all functions that are per se independent from trace or mapping
		   information -> mostly linear algebra functions
	- TRACEvisualize
		-> contains all functions that are needed to visualise trace data

The script master.m allows to:
	-> define the personal input data
	-> load the data and perform the TIE
	-> visualize results
		-> figure(1): map in 3d with traces and trace numbers
		-> figure(2): map in 3d with classified traces and chord plane bars
		-> figure(3): signals of alpha, beta and dist of a specific trace
		-> figure(4): chords and chord plane evolution of a specific trace in a stereonet
		-> figure(5): signal height diagram
- Make sure the TIEtoolbox with all its subfolders is registered as a Matlab search path.


-----
EXAMPLE:

In the "Example Data" folder we propose a practical example in order to get used to TIE. 

The data are presented and discussed in detail in Rauch et al. (2019): 
https://doi.org/10.1016/j.jsg.2019.06.007

The example data are already set as initial data set of the TIE-toolbox. Run the master in order to see
the TIE results. If you wish to run your own data, just change the INPUT data in the master file.

-----
ADVICE:

- Do not analyse a great zone at once. Firstly, the rasterizing function is not set up for a big amount of data
  and thus might be time consuming. In addition, the TIE is conceived for the detailed understanding of each 
  individual trace. A large view of hundreds of traces is usually confusing and not helpful. We suggest to 
  subdivide a bigger zone in smaller subzones containing 10 to 30 traces in a trace set.
- Save the loaded data (including the TRACE and FAULT structures) in a mat-file after the first run in order to 
  avoid potentially time-consuming data-loading. The loading section in the master script can thereafter be skipped
  or commented.
- The TIE algorithm itself does not require the Mapping Toolbox. So if you do not have the Mapping Toolbox and do
  not want to purchase it, but would like to try out the TIE method on your data, there is the possibility to find 
  somebody who has it, load the data and save them in a mat-file. If this somebody does not exist around you, 
  contact me.

-----
CONTACT:

Anna Rauch //
University of Geneva //
anna.rauch@unige.ch
