;; mass export
#|
(export '(; utils
          last1
          single
          append1
          conc1
          mklist
          mkstr
          symb
          group
          flatten

          ; macro-bang
          defmacro!

          ; list-builders
          build-list

          ; misc
          conditional
          whens
          exlambda

          ; closures
          dlambda
          def-dfn
          dfn-closure
          alet-fsm
          alet-hotpatch
          let-hotpatch

          ; sub-scope
          let-binding-transform

          ; pandoric
          pandoriclet
          pandoriclet-get
          pandoriclet-set
          get-pandoric
          with-pandoric
          pandoric-hotpatch
          pandoric-recode
          plambda
          defpan
          pandoric-eval

          ; efficency
          \#\f
          fast-progn
          safe-progn
          fast-keywords-strip
          defun-with-fast-keywords
          ;  fformat
          dis

          ; lazy
          lazy
          force
          lazy-cons
          lazy-car
          lazy-cdr
          lazy-nil
          lazy-null
          make-lazy
          take
          take-all
          lazy-mapcar
          lazy-mapcar
          lazy-mapcan
          lazy-find-if
          lazy-nth

          ; anaphora
          aif
          awhen
          awhile
          aand
          acond
          alambda
          ablock
          alet
          aif2
          awhen2
          awhile2
          acond2
          do-file
          \#\`))
|#
