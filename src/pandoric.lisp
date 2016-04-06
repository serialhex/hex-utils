(in-package :hex-utils)
(eval-when (:execute :compile-toplevel :load-toplevel)

(defmacro pandoriclet (letargs &rest body)
  (let ((letargs (cons
                    '(this)
                    (let-binding-transform
                      letargs))))
    `(let (,@letargs)
      (setq this ,@(last body))
      ,@(butlast body)
      (dlambda
        (:pandoric-get (sym)
          ,(pandoriclet-get letargs))
        (:pandoric-set (sym val)
          ,(pandoriclet-set letargs))
        (t (&rest args)
          (apply this args))))))

(defun pandoriclet-get (letargs)
  `(case sym
    ,@(mapcar #`((,(car a1)) ,(car a1))
                  letargs)
    (t (error
          "Unknown pandoric get: ~a"
          sym))))

(defun pandoriclet-set (letargs)
  `(case sym
    ,@(mapcar #`((,(car a1))
                  (setq ,(car a1) val))
              letargs)
    (t (error
          "Unknown pandoric set: ~a"
          sym val))))

(declaim (inline get-pandoric))
(defun get-pandoric (box sym)
  (funcall box :pandoric-get sym))

(defsetf get-pandoric (box sym) (val)
  `(progn
    (funcall ,box :pandoric-set ,sym ,val)
    ,val))

(defmacro! with-pandoric (syms o!box &rest body)
  `(symbol-macrolet
    (,@(mapcar #`(,a1 (get-pandoric ,g!box ',a1))
              syms))
    ,@body))

;; this is only here for sbcl, which won't run this code w/o it!
; (eval-when (:execute)
(defun pandoric-hotpatch (box new)
  (with-pandoric (this) box
    (setq this new)))
; )

(defmacro pandoric-recode (vars box new)
  `(with-pandoric (this ,@vars) ,box
    (setq this ,new)))

(defmacro plambda (largs pargs &rest body)
  (let ((pargs (mapcar #'list pargs)))
    `(let (this self)
      (setq
        this (lambda ,largs ,@body)
        self (dlambda
                (:pandoric-get (sym)
                  ,(pandoriclet-get pargs))
                (:pandoric-set (sym val)
                  ,(pandoriclet-set pargs))
                (t (&rest args)
                  (apply this args)))))))

(defmacro defpan (name args &rest body)
  `(defun ,name (self)
    ,(if args
      `(with-pandoric ,args self
          ,@body)
      `(progn ,@body))))

(defvar pandoric-eval-tunnel)

(defmacro pandoric-eval (vars expr)
  `(let ((pandoric-eval-tunnel
          (plambda () ,vars t)))
    (eval `(with-pandoric
            ,',vars pandoric-eval-tunnel
            ,, expr))))

)
