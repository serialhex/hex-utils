(in-package :cl-user)

(defpackage :hex-utils
  (:use :common-lisp)
  (:export  ; utils
            #:last1
            #:single
            #:append1
            #:conc1
            #:mklist
            #:mkstr
            #:symb
            #:group
            #:flatten

            ; macro-bang
            #:defmacro!

            ; list-builders
            #:build-list

            ; misc
            #:conditional

            ; closures
            #:dlambda
            #:alet-hotpatch
            #:let-hotpatch

            ; sub-scope
            #:let-binding-transform

            ; pandoric
            #:pandoriclet
            #:pandoriclet-get
            #:pandoriclet-set
            #:get-pandoric

            ; lazy
            #:lazy
            #:force
            #:lazy-cons
            #:lazy-car
            #:lazy-cdr
            #:lazy-nil
            #:lazy-null
            #:make-lazy
            #:take
            #:take-all
            #:lazy-mapcar
            #:lazy-mapcar
            #:lazy-mapcan
            #:lazy-find-if
            #:lazy-nth

            ; anaphora
            #:aif
            #:awhen
            #:awhile
            #:aand
            #:acond
            #:alambda
            #:ablock
            #:alet
            #:aif2
            #:awhen2
            #:awhile2
            #:acond2
            #:do-file
            #:#\`))
