;;;; cl-postgres-datetime.asd

(asdf:defsystem #:cl-postgres-datetime
  :description "Date/time integration for cl-postgres that uses LOCAL-TIME for types that use time zones and SIMPLE-DATE for those that don't"
  :author "Chaitanya Gupta <mail@chaitanyagupta.com>"
  :license "BSD-3-Clause"
  :version "0.1.0"
  :serial t
  :depends-on (#:cl-postgres #:local-time #:simple-date)
  :components ((:file "cl-postgres-datetime")))
