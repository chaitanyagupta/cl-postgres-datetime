(defpackage #:cl-postgres-datetime
  (:use #:cl #:cl-postgres)
  (:export #:update-sql-readtable))

(in-package #:cl-postgres-datetime)

(defmethod cl-postgres:to-sql-string ((timestamp local-time:timestamp))
  (values (local-time:format-timestring nil
                                        timestamp
                                        :format local-time:+iso-8601-format+
                                        :timezone local-time:+utc-zone+)
          "timestamp with time zone"))

(defconstant +postgres-day-offset+ -60)
(defconstant +usecs-in-one-day+ (* 1000 1000 3600 24))
(defconstant +usecs-in-one-sec+ (* 1000 1000))

(defmethod cl-postgres:to-sql-string ((arg simple-date:timestamp))
  (multiple-value-bind (year month day hour min sec ms)
      (simple-date:decode-timestamp arg)
    (values
     (format nil "~4,'0d-~2,'0d-~2,'0d ~2,'0d:~2,'0d:~2,'0d~@[.~3,'0d~]"
             year month day hour min sec (if (zerop ms) nil ms))
     "timestamp")))

(defmethod cl-postgres:to-sql-string ((arg simple-date:date))
  (multiple-value-bind (year month day) (simple-date:decode-date arg)
    (values (format nil "~4,'0d-~2,'0d-~2,'0d" year month day) "date")))

(defmethod cl-postgres:to-sql-string ((arg simple-date:time-of-day))
  (with-accessors ((hours simple-date:hours)
                   (minutes simple-date:minutes)
                   (seconds simple-date:seconds)
                   (microseconds simple-date:microseconds))
      arg
    (values
     (format nil "~2,'0d:~2,'0d:~2,'0d~@[.~6,'0d~]"
             hours minutes seconds (if (zerop microseconds) nil microseconds))
     "time")))

(defmethod cl-postgres:to-sql-string ((arg simple-date:interval))
  (multiple-value-bind (year month day hour min sec ms)
      (simple-date:decode-interval arg)
    (if (= year month day hour min sec ms 0)
        (values "0 milliseconds" "interval")
        (flet ((not-zero (x) (if (zerop x) nil x)))
          (values
           (format nil "~@[~d years ~]~@[~d months ~]~@[~d days ~]~@[~d hours ~]~@[~d minutes ~]~@[~d seconds ~]~@[~d milliseconds~]"
                   (not-zero year) (not-zero month) (not-zero day)
                   (not-zero hour) (not-zero min) (not-zero sec) (not-zero ms))
           "interval")))))

(defun update-sql-readtable (readtable)
  (cl-postgres:set-sql-datetime-readers
   :date (lambda (days)
           (make-instance 'simple-date:date :days (+ days +postgres-day-offset+)))
   :timestamp (lambda (usecs)
               (multiple-value-bind (days usecs) (floor usecs +usecs-in-one-day+)
                 (make-instance 'simple-date:timestamp :days (+ days +postgres-day-offset+)
                                :ms (floor usecs 1000))))
   :timestamp-with-timezone (lambda (usecs)
                              (multiple-value-bind (days usecs)
                                  (floor usecs +usecs-in-one-day+)
                                (multiple-value-bind (secs usecs)
                                    (floor usecs +usecs-in-one-sec+)
                                  (local-time:make-timestamp :day (+ days +postgres-day-offset+)
                                                             :sec secs
                                                             :nsec (* usecs 1000)))))
   :time (lambda (usecs)
           (multiple-value-bind (seconds usecs)
               (floor usecs 1000000)
             (multiple-value-bind (minutes seconds)
                 (floor seconds 60)
               (multiple-value-bind (hours minutes)
                   (floor minutes 60)
                 (make-instance 'simple-date:time-of-day
                                :hours hours
                                :minutes minutes
                                :seconds seconds
                                :microseconds usecs)))))
   :interval (lambda (months days usecs)
               (make-instance 'simple-date:interval :months months
                              :ms (floor (+ (* days +usecs-in-one-day+) usecs) 1000)))
   :table readtable))
