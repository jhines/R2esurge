% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/esurge.R
\name{esrg_run}
\alias{esrg_run}
\title{\code{esrg_run} activates E-SURGE, enters input and runs model}
\usage{
esrg_run(rslt, init, trans, event, CI = "no", ivt = "", ive = "",
  slow = NA, dlay = NA, verb = F, suff = "")
}
\arguments{
\item{rslt}{filename for result AIC table}

\item{init}{char string with GEMACO code for initial state probability (eg., "i","from",...)}

\item{trans}{char string(s) with GEMACO code for transition probs (eg., "from.to","from.to.t"...)}

\item{event}{char string with GEMACO code for capture event probs (eg., "firste+nexte",...)}

\item{CI}{"no" or "yes" for computation of 95\% conf. limits}

\item{ivt}{initial value string for transitions (eg., "1:1,9,.5" -> 1st parm fixed to 1, 9th param fixed to .5)}

\item{ive}{initial value string for events}

\item{slow}{determines how fast characters are sent to E-SURGE (eg. slow=500 -> 1/2 sec per char)}

\item{dlay}{time between send actions (eg., 500 -> 1/2 sec delay between each send)}

\item{verb}{verbose output (F=very little output, T=lots of output)}

\item{suff}{chars to append to model name (eg., "lastp")}
}
\value{
returns table of real parameter estimates.
}
\description{
\code{esrg_run} activates E-SURGE, enters input and runs model
}
\examples{
   rslt='dipper.mod'; data='ed.rh'
   ngrps=1; nicov=0; nstates=2; nevents=2; nage=1
   v=esrg_open(rslt,data,ngrps,nicov,nstates,nevents,nage,'noinit')
   v=esrg_run(rslt,'i','t','firste+nexte.t')     #   run model phi(t)p(t)    (init is ignored for this model.)

  \dontrun{
   v=esrg_run(rslt,'i','t','firste+nexte')
  }

}
\seealso{
\code{\link{esrg_open}},
\code{\link{esrg_close}}
}

