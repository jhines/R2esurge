#'
#' R Interface for Program E-SURGE
#'
#' Provide an R interface for running some of the models available in
#  Program E-SURGE (\url{http://www.cefe.cnrs.fr/fr/actus/livres/34-french/recherche/bc/bbp/264-logiciels}),
#' Program E-SURGE (\url{https://mycore.core-cloud.net/public.php?service=files&t=7aa2ac97d3e067698bb3230e4a7b0f8b}),
#' plus some additional helpful routines.  This package includes a Windows
#' scripting tool, written in AutoIt3, to automate data entry and point/clicking.
#'
#' \tabular{ll}{
#' Package: \tab R2Esurge\cr
#' Type: \tab Package\cr
#' Version: \tab 0.1.2\cr
#' Date: \tab 2017-02-17\cr
#' License: \tab GPL-2\cr
#' }
#'
#'@author Jim Hines
#'
#' @examples
#' \dontrun{
#' rslt='geese.mod'; data='geese.inp'              # filenames for results, data
#' ngrps=1; nicov=0; nstates=4; nevents=4; nage=1; # self-explanitory variables
#'
#' #    run E-SURGE and enter input data and input parameters
#' #         (noinit checks the menu, 'Models/if any factorisation/Transition & encounter'
#' #                                            instead of Initial, Transition & encounter)
#' v=esrg_open(rslt,data,ngrps,nicov,nstates,nevents,nage,'noinit')
#'
#' #      create gepat matrices for 2-step movement models (S,Psi,p)
#' v=esrg_make_gepat_trans(nstates=nstates,nevents=nevents,steps=2)
#'
#' #   run model S(from.t)psi(from.to.t)p(to.t) (init is ignored for this model.)
#' v=esrg_run(rslt,'i',c('from.t','from.to.t'),'firste+nexte.to.t')
#'
#' v=esrg_close()  #   close E-SURGE window (maybe not necessary if not changing gepat info?)
#'
#   read estimates from 2-step, S-psi parameterization
#' y=read.xlsx('S(from.t)psi(from.to.t)p(firste+nexte.to.t).xls',8) # 8th sheet contains estimates
#' i=y$Parameters==" T" & y$Step==1 & y$From==y$To & y$To<4  #  i=indices of S's we want to save
#' S=matrix(y$Estimates[i],nrow=3)                           #  create matrix of S's (state X year)
#' i=y$Parameters==" T" & y$Step==2 & y$From<4 & y$To<4      #  indices of psi's we want to save
#' psi=y$Estimates[i]; dim(psi)=c(3,3,5)                     #  array of psi's (from X to X year)
#' phi1=list(); for (i in 1:5) phi1[[i]]=S[,i] * psi[,,i];  #compute combined trans prob, phi from S,psi
#' }
# Maintainer: Jim Hines <jhines@usgs.gov>
"_PACKAGE"
