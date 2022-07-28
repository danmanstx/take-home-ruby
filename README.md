# take-home-ruby
Take home ruby challenge, slightly unsure on wording to handle bad phones numbers.
Currently, they are reported in error report and excluded if nil or number cant be formatted (ie. 11 digits already).
Would like to have kept adding tests but ran out of time.
Also would like to have added more detail to report about which field(s) caused the error.


## how to run

`ruby Etl.rb`

should end up with an `output.csv` and a `report.txt`

## how to run test

`rspec`


## From Spec Sheet

### Transform Rules

- Trim extra white space for all fields
- Transform phone_numbers to E.164 format (Please assume all numbers to be US e.g. +1)
- Transform ALL dates to ISO8601 format (YYYY-MM-DD)

### Validation Rules

- Phone Numbers must be E.164 compliant (country code + 10 numeric digits)
- first_name, last_name, dob, member_id, effective_date are ALL required for each patient
