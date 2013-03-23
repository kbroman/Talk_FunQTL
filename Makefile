mainstuff: js presentation.html Figs/riself.png Figs/geno_pheno.png Figs/perm_hist.png

presentation.html: index.html js css/kbroman_talk.css css/kbroman_presentation.css
	Perl/create_presentation.pl

R/spal.RData: R/prep_rep1_data.R RawData/rep1_rev.csv
	cd R;R CMD BATCH prep_rep1_data.R

R/out.RData: R/prep_rep1_data.R RawData/rep1_rev.csv
	cd R;R CMD BATCH prep_rep1_data.R

Data/pheno.json: R/spal.RData R/phe2json.R
	cd R;R CMD BATCH phe2json.R

Data/onetime.json: R/spal.RData R/out.RData R/grab_lod_one_time.R
	cd R;R CMD BATCH grab_lod_one_time.R

Data/onetime_random.json: R/spal.RData R/out.RData R/grab_lod_one_time_random.R
	cd R;R CMD BATCH grab_lod_one_time_random.R

js: JS/pheno.js JS/lod_onetime.js JS/lod_onetime_random.js JS/lod_alltimes.js

JS/pheno.js: Coffee/pheno.coffee
	coffee -co JS Coffee/pheno.coffee

JS/lod_onetime.js: Coffee/lod_onetime.coffee Data/onetime.json
	coffee -co JS Coffee/lod_onetime.coffee

JS/lod_onetime_random.js: Coffee/lod_onetime_random.coffee Data/onetime_random.json
	coffee -co JS Coffee/lod_onetime_random.coffee

JS/lod_alltimes.js: Coffee/lod_alltimes.coffee
	coffee -co JS Coffee/lod_alltimes.coffee

Figs/riself.png: R/riself_fig.R R/meiosis_func.R R/colors.R
	cd R;R CMD BATCH --no-save riself_fig.R

Figs/geno_pheno.png: R/geno_pheno_fig.R R/colors.R R/spal.RData R/my_geno_image.R
	cd R;R CMD BATCH --no-save geno_pheno_fig.R

Figs/perm_hist.png: R/perm_hist.R R/colors.R R/spal.RData
	cd R;R CMD BATCH --no-save perm_hist.R

webhtml:
	scp *.html broman-7:public_html/presentations/FunQTL/

webcss:
	scp CSS/*.css broman-7:public_html/presentations/FunQTL/CSS/

webcode:
	scp JS/*.js broman-7:public_html/presentations/FunQTL/JS/
	scp Coffee/*.coffee broman-7:public_html/presentations/FunQTL/Coffee/

webdata:
	scp Data/*.json broman-7:public_html/presentations/FunQTL/Data/

webfig:
	scp Figs/*.jpg Figs/*.png broman-7:public_html/presentations/FunQTL/Figs/

web: webhtml webcss webcode webfig webdata

all: js web presentation.html
