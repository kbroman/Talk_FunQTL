
To run permutations with each phenotype individually:

  create_Rsub.pl: perl script to split job into 16 pieces
  perm.R:         basic R script, with "SUB" to be replaced by the
                  integers 1, 2, ..., 16
  setupPerm.sh    shell script to run create_Rsub.pl to create
                  in01.R, ..., in16.R, plus allin (shell script)
  combinePerms.R  combine permutation results
  operm.RData     The combined permutation results

Analysis with multiple-QTL models:

  analysis.R      R code to do various things
  out_with_combined.RData  Results of scanone including mean and max
                           LOD across times
  outsq.RData     Stepwise qtl analysis on each time point individually
  meanqtl.RData   Crude forward selection using mean_t { LOD(t) }
  maxqtl.RData    Crude forward selection using max_t { LOD(t) }

The .RData files aren't included in the repository at this point,
because they're big and subject to change
