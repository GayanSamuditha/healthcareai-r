% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pivot.R
\name{pivot}
\alias{pivot}
\title{Pivot multiple rows per observation to one row with multiple columns}
\usage{
pivot(d, grain, spread, fill, fun = sum, missing_fill = NA, extra_cols)
}
\arguments{
\item{d}{data frame}

\item{grain}{Column that defines rows. Unquoted.}

\item{spread}{Column that will become multiple columns. Unquoted.}

\item{fill}{Column to be used to fill the values of cells in the output,
perhaps after aggregation by \code{fun}. If \code{fill} is not provided,
counts will be used, as though a fill column of 1s had been provided.}

\item{fun}{Function for aggregation, defaults to \code{sum}. Custom functions
can be used with the same syntax as the apply family of functions, e.g.
\code{fun = function(x) some_function(another_fun(x))}.}

\item{missing_fill}{Value to fill for combinations of grain and spread that
are not present. Defaults to NA, but 0 may be useful as well.}

\item{extra_cols}{Values of \code{spread} to create all-\code{missing_fill}
columns, for e.g. if you want to add levels that were observed in training
but are not present in deployment.}
}
\value{
A tibble data frame with one row for each unique value of
  \code{grain}, and one column for each unique value of \code{spread} plus
  one column for the entries in grain.

  Entries in the tibble are defined by the fill column. Combinations of
  \code{grain} x \code{spread} that are not present in \code{d} will be
  filled in with \code{missing_fill}. If there are \code{grain} x
  \code{spread} pairs that appear more than once in d, they will be
  aggregated by \code{fun}.
}
\description{
Pivot multiple rows per observation to one row with multiple columns
}
\details{
\code{pivot} is useful when you want to change the grain of your
  data, for example from the procedure grain to the patient grain. In that
  example, each patient might have 0, 1, or more medications. To make a
  patient-level table, we need a column for each medication, which is what it
  means to make a wide table. The \code{fill} argument dictates what to put
  in each of the medication columns, e.g. the dose the patient got.
  \code{fill} defaults to "1", as an indicator variable. If any patients have
  multiple rows for the same medication (say they recieved a med more than
  once), we need a way to deal with that, which is what the \code{fun}
  argument handles. By default it uses \code{sum}, so if \code{fill} is left
  as its default, the count of instances for each patient will be used.
}
\examples{
meds <-
  tibble::tibble(
    patient_id = c("A", "A", "A", "B"),
    medication = c("zoloft", "asprin", "lipitor", "asprin"),
    pills_per_day = c(1, 8, 2, 4)
  )
meds

# Number of pills of each medication each patient gets:
pivot(
  d = meds,
  grain = patient_id,
  spread = medication,
  fill = pills_per_day,
  missing_fill = 0
)

bills <-
  tibble::tibble(
    patient_id = rep(c("A", "B"), each = 4),
    dept_id = rep(c("ED", "ICU"), times = 4),
    charge = runif(8, 0, 1e4),
    date = as.Date("2024-12-25") - sample(0:2, 8, TRUE)
  )
bills

# Total charges per patient x department:
pivot(bills, patient_id, dept_id, charge, sum)

# Count of charges per patient x day:
pivot(bills, patient_id, date)

# Can provide a custom function to fun, which will take fill as input.
# Get the difference between the greatest and smallest charge in each
# department for each patient and format it as currency.
pivot(d = bills,
      grain = patient_id,
      spread = dept_id,
      fill = charge,
      fun = function(x) paste0("$", round(max(x) - min(x), 2))
)
}
