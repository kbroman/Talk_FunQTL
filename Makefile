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

js: JS/pheno.js JS/lod_onetime.js

JS/pheno.js: Coffee/pheno.coffee
	coffee -bco JS Coffee

JS/lod_onetime.js: Coffee/lod_onetime.coffee
	coffee -bco JS Coffee

#figs/manyboxplots.png: R/hypo_boxplot.R
#	cd R;R CMD BATCH hypo_boxplot.R

#webmain:
#	scp index.html presentation.html broman-2:public_html/presentations/FunQTL/

#webcss:
#	scp css/*.css broman-2:public_html/presentations/FunQTL/css/

#webcode:
#	scp js/*.js broman-2:public_html/presentations/FunQTL/js/
#	scp coffee/*.coffee broman-2:public_html/presentations/FunQTL/coffee/

#webdata:
#	scp data/hypo.json data/insulinlod.json broman-2:public_html/presentations/FunQTL/data/

#webfigs:
#	scp figs/*.png broman-2:public_html/presentations/FunQTL/figs/
#	scp figs/*.jpg broman-2:public_html/presentations/FunQTL/figs/

#web: webmain webcss webcode webfigs webdata

#tar: mainstuff
#	cd ..;tar czvf FunQTL.tgz FunQTL/*.html FunQTL/css FunQTL/coffee FunQTL/js FunQTL/data FunQTL/figs;mv FunQTL.tgz FunQTL/

#all: js web presentation.html tar
