# cl-postgres-datetime

cl-postgres-datetime provides date/time integration for [cl-postgres][].

It uses [local-time][] for types that use time zones (i.e. `timestamptz`) and
[simple-date][] for types that don't (i.e. `timestamp`, `date`, `time`, `interval`).

[cl-postgres]: http://marijnhaverbeke.nl/postmodern/cl-postgres.html
[local-time]: https://common-lisp.net/project/local-time/
[simple-date]: http://marijnhaverbeke.nl/postmodern/simple-date.html

## Why?

Neither local-time nor simple-date alone work well with all the date/time
types that Postgres supports.

local-time's `TIMESTAMP` is a natural fit for `timestamptz`, and while
non-timezone types like `timestamp` and `date` could be parsed into it, the user
has to remember to always use `+UTC-ZONE+` when decoding such a timestamp (the
values of decoded components may mismatch with the original if the default time
zone were different from UTC).

simple-date has no concept of time zones, so while it works well for every type
that doesn't need a timezone, it fails badly when it comes to `timestamptz`.

## Installation

As of now, the library is not available in Quicklisp, so you will need to clone
the repository and load it manually.

## Usage

Once the library is loaded in your image, just use `update-sql-readtable` to
update the readtable in cl-postgres.

```cl
(setf cl-postgres:*sql-readtable* (cl-postgres-datetime:update-sql-readtable cl-postgres:*sql-readtable*))
```
