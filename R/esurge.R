esrg_open <- function(rslt,data,ngrps,nicov,nstates,nevents,nage,factopt='',
                      slow=NA,dlay=NA,verb=F,esrg=""){
  #'\code{esrg_open} opens E-SURGE, reads data
  #'
  #'Opens E-Surge window and automates the entry of the results filename (rslt),
  #'input data filename, number of groups,...
  #'
  #'@param rslt filename for result AIC table
  #'@param data filename for input data file
  #'@param ngrps number of groups in data
  #'@param nicov number of individual covariates in data
  #'@param nstates number of states in data
  #'@param nevents number of events in data
  #'@param nage number of age-classes in data
  #'@param factopt factorization option (="init" for init/trans/event, "noinit" for trans/event)
  #'@param slow determines how fast characters are sent to E-SURGE (eg. slow=500 -> 1/2 sec per char)
  #'@param dlay time between send actions (eg., 500 -> 1/2 sec delay between each send)
  #'@param verb verbose output (F=very little output, T=lots of output)
  #'@param esrg location of e-surge program (eg., "C:/Program Files/E-SURGE 2.1.0/E_SURGE_V2_1_0_M9x64.exe")
  #'
  #'@export
  #'@return returns nothing.  Output for the model is saved in 2 files (*.out, *.xls).
  #'
  #'@seealso \code{\link{esrg_run}}, \code{\link{esrg_close}}
  #'
  #'@examples
  #'rslt="dipper.mod"; data="ed.rh";
  #'ngrps=1; nicov=0; nstates=2; nevents=2; nage=1
  #'f=c(list.files('.','^pi.+'),list.files('.','.+.mod$'),'tabdev.mat','shortcuts.out');
  #'  #  assuming new analysis, so delete old model and/or output files
  #'   supressWarnings(i=file.remove(f))
  #'v=esrg_open(rslt,data,ngrps,nicov,nstates,nevents,nage,'noinit')
  #'v=esrg_run('i','t','firste+nexte.t')     #   run model phi(t)p(t)    (init is ignored for this model.)
  #'esrg_close()
  #'
  #'\dontrun{
  #'v=esrg_open(rslt,data,ngrps,nicov,nstates,nevents,nage,'noinit')
  #'}
  #'
  s=system.file(package='R2Esurge','executables','win64','esrg_ai.exe')
  u=paste0(s," open rname=",rslt," dname=",data," ng=",ngrps," ni=",nicov," ns=",nstates,
                 " ne=",nevents," na=",nage," factopt=",factopt)
  if (verb) u=gsub('open rname','open verb=1 rname',u)
  if (!is.na(slow)) u=paste(u,paste0('slow=',slow))
  if (!is.na(dlay)) u=paste(u,paste0('dlay=',dlay))
  if (nchar(esrg)>0) u=paste(u,paste0('esrg=',esrg))
  cat(u,'\n'); i=system(u)
}

esrg_run <- function(rslt,init,trans,event,CI="no",ivt="",ive="",slow=NA,dlay=NA,verb=F,suff=""){
  #'\code{esrg_run} activates E-SURGE, enters input and runs model
  #'
  #'@param rslt filename for result AIC table
  #'@param init char string with GEMACO code for initial state probability (eg., "i","from",...)
  #'@param trans char string(s) with GEMACO code for transition probs (eg., "from.to","from.to.t"...)
  #'@param event char string with GEMACO code for capture event probs (eg., "firste+nexte",...)
  #'@param CI "no" or "yes" for computation of 95\% conf. limits
  #'@param ivt initial value string for transitions (eg., "1:1,9,.5" -> 1st parm fixed to 1, 9th param fixed to .5)
  #'@param ive initial value string for events
  #'@param slow determines how fast characters are sent to E-SURGE (eg. slow=500 -> 1/2 sec per char)
  #'@param dlay time between send actions (eg., 500 -> 1/2 sec delay between each send)
  #'@param verb verbose output (F=very little output, T=lots of output)
  #'@param suff chars to append to model name (eg., "lastp")
  #'
  #'@export
  #'@return returns table of real parameter estimates.
  #'
  #'@seealso \code{\link{esrg_open}},
  #' \code{\link{esrg_close}}
  #'
  #'@examples
  #'    rslt='dipper.mod'; data='ed.rh'
  #'    ngrps=1; nicov=0; nstates=2; nevents=2; nage=1
  #'    v=esrg_open(rslt,data,ngrps,nicov,nstates,nevents,nage,'noinit')
  #'    v=esrg_run(rslt,'i','t','firste+nexte.t')     #   run model phi(t)p(t)    (init is ignored for this model.)
  #'
  #'   \dontrun{
  #'    v=esrg_run(rslt,'i','t','firste+nexte')
  #'   }
  #'
  s=system.file(package='R2Esurge','executables','win64','esrg_ai.exe')
  u=paste0(s," run rname=",rslt," is=",init," tr=",trans[1]," ev=",event," CI=",CI)
  if (nchar(ivt)>1) u=paste0(u," ivt=",ivt)
  if (nchar(ive)>1) u=paste0(u," ive=",ive)
  if (length(trans)>1) u=paste0(u," t2=",trans[2])
  if (verb) u=gsub('run rname','run verb=1 rname',u)
  if (!is.na(slow)) u=paste(u,paste0('slow=',slow))
  if (!is.na(dlay)) u=paste(u,paste0('dlay=',dlay))
  if (nchar(suff)>0) u=paste(u,paste0('suff=',suff))
  cat(u,'\n')
  v=unlist(strsplit(u,' '))
  i=system2(v[1],v[-1])
}

esrg_close <- function() {
  #' \code{esrg_close} closes E-SURGE window
  #'
  #'@export
  #'@return returns nothing.
  #'
  #'@seealso \code{\link{esrg_run}},
  #' \code{\link{esrg_open}}
  #'
  #'@examples
  #'    rslt='dipper.mod'; data='ed.rh';
  #'    ngrps=1; nicov=0; nstates=2; nevents=2; nage=1
  #'    v=esrg_open(rslt,data,ngrps,nicov,nstates,nevents,nage,'noinit')
  #'    v=esrg_run(rslt,'i','t','t')     #   run model phi(t)p(t)    (init is ignored for this model.)
  #'    esrg_close()
  #'
  #'   \dontrun{
  #'    v=esrg_close()
  #'   }
  #'
  s=system.file(package='R2Esurge','executables','win64','esrg_ai.exe')
  i=system(paste(s,"close"))
}

esrg_make_gepat_trans <- function(nstates,nevents,steps=2,JMV=F) {
  #' \code{esrg_make_gepat_trans} creates GEPAT pattern file for 2-step transitions
  #'
  #'@param nstates number of states
  #'@param nevents number of events
  #'@param steps number of steps for transition matrix (default=2)
  #'@param JMV =T if JMV model (p(from.to.?)), =F if CAS model
  #'
  #'@export
  #'@return returns nothing, but saves patterns to file, trans.pat and prints
  #'
  #'@seealso \code{\link{esrg_run}},
  #' \code{\link{esrg_open}}
  #'
  #'@examples
  #'    esrg_make_gepat_trans(nstates=4, nevents=4)
  #'
  #'   \dontrun{
  #'    v=esrg_make_gepat_trans(4,4)
  #'   }
  #'
  s=c('%%%% VERSION 2.0 %%%%%%','3')
  istate=c(rep('p',nstates-2),'*')
  s=c(s,'%%%% Initial state %%%%%%','1',paste(1,nstates-1,'IS'),paste(istate,collapse=' '))
  if (steps==1) {
    s=c(s,'%%%% Transition %%%%%%',steps,paste(nstates,nstates,'PHI'))
    trans=matrix('y',nstates,nstates); trans[nstates,]='-'; trans[,nstates]='*'
    for (i in 1:nstates) s=c(s,paste(trans[i,],collapse=' '))
  }  else {
    s=c(s,'%%%% Transition %%%%%%',steps,paste(nstates,nstates,'SRV'))
    trans=matrix('-',nstates,nstates); diag(trans)='y'; trans[,nstates]='*'
    trans2=matrix('y',nstates,nstates); diag(trans2)='*'
    trans2[nstates,-nstates]='-'; trans2[-nstates,nstates]='-'
    for (i in 1:nstates) s=c(s,paste(trans[i,],collapse=' '))
    s=c(s,paste(nstates,nstates,'MOV'))
    for (i in 1:nstates) s=c(s,paste(trans2[i,],collapse=' '))
  }
  event=matrix('-',nstates,nevents); event[,1]='*'
  i=1:(nevents-1); i=cbind(i,i+1); event[i]='b'
  if (JMV) event[-nevents,-1]='b'

  #   kludge fix for heterogeneity model... not sure how to generalize
  if (sum(event[nstates-1,]!=event[nstates,])==0) event[nstates-1,]=event[1,]

  s=c(s,'%%%% Event  %%%%%%','1',paste(nstates,nevents,'E'))
  for (i in 1:nstates) s=c(s,paste(event[i,],collapse=' '))
  write(s,file='trans.pat')
  write(s,file='')
}
esrg_aictbl <- function(rname) {
  #' \code{esrg_aictbl} creates AIC table of model results
  #'
  #'@param rname name of results model summary file (eg., dipper.mod)
  #'
  #'@export
  #'@return returns AIC table.
  #'
  #'@seealso \code{\link{esrg_run}},
  #' \code{\link{esrg_open}}
  #'
  #'@examples
  #'    esrg_aictbl(nstates=4, nevents=4)
  #'
  #'   \dontrun{
  #'    v=esrg_aictbl()
  #'   }
  #'
  #'
  tbl=readLines(rname); n=as.numeric(tbl[3]);
  aictbl=matrix(tbl[3+1:(n*7)],ncol=7,byrow=T)[,c(1,2,5)];
  QAIC=as.numeric(aictbl[,2])+2*as.numeric(aictbl[,3]); aictbl=cbind(aictbl,QAIC,QAIC)
  colnames(aictbl)=c("Model","Deviance","NPar","QAIC","QAICc")
  return(aictbl)
}
