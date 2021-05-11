This is folder contains the files for the final submision in a MS Word format.
The reproducible files can be found in `/v2_taylor_francis`.

- broadband.speed.covid.docx is the MS word version including the below changes:

  - [x]	figures should not be embedded in the main text, instead they should be submitted as separate high-res image files and labeled as Fig 1, Fig 2, etc. If Figure 5 is part of the Appendix, it should be labeled as Figure A1

  - [x]	label supplemental material file

  - [x]	remove tables embedded in main text file and upload as a separate file.

  - [x]	change footnotes to endnotes

  - [x]	add list of figure captions after the references

  - [x]	Add author biographies after the references, using the following sample biography as an example of what these should look like: “JANE DOE is an Assistant Professor in the Department of Geography at King’s College London, London WC2R 2LS, UK. E-mail: jdoe@kcl.ac.uk. Her research interests include the conditions of homeworkers in developing-world countries and the issue of access to the Internet among teenagers in rural areas.”

- render_word_bw_images.R renders the broadband.speed.covid.Rmd to MS Word and converts images to B&W.
The images can be found in `/figures_for_word_submission`.

- broadband.speed.covid_for_tables.Rmd is used *only* to produce the table files that can be found in `/tables`.
It should be not used for knitting the actual paper.
