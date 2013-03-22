mainstuff: js presentation.html

presentation.html: index.html js css/kbroman_talk.css css/kbroman_presentation.css
	Perl/create_presentation.pl

R/spal.RData: R/prep_rep1_data.R RawData/rep1_rev.csv
	cd R;R CMD BATCH prep_rep1_data.R

R/out.RData: R/prep_rep1_data.R RawData/rep1_rev.csv
	cd R;R CMD BATCH prep_rep1_data.R

Data/spalding_pheno.json: R/spal.RData R/phe2json.R
	cd R;R CMD BATCH phe2json.R

Data/spalding_onetime.json: R/spal.RData R/out.RData R/grab_lod_one_time.R
	cd R;R CMD BATCH grab_lod_one_time.R

js: JS/pheno.js JS/lod_onetime.js JS/lod_alltimes.js

JS/pheno.js: Coffee/pheno.coffee
	coffee -co JS Coffee/pheno.coffee

JS/lod_onetime.js: Coffee/lod_onetime.coffee
	coffee -co JS Coffee/lod_onetime.coffee

JS/lod_alltimes.js: Coffee/lod_alltimes.coffee
	coffee -co JS Coffee/lod_alltimes.coffee
