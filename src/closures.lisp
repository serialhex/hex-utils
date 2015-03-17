(in-package :hex-utils)

(defmacro! dlambda (&rest ds)
  `(lambda (&rest ,g!args)
    (case (car ,g!args)
      ,@(mapcar
          (lambda (d)
            `(,(if (eq t (car d))
                   t
                   (list (car d)))
              (apply (lambda ,@(cdr d))
                      ,(if (eq t (car d))
                           g!args
                           `(cdr ,g!args)))))
          ds))))

(defmacro alet-fsm (&rest states)
  `(macrolet ((state (s)
                `(setq this #',s)))
      (labels (,@states) #',(caar states))))

(defmacro alet-hotpatch (letargs &rest body)
  `(let ((this) ,@letargs)
      (setq this ,@(last body))
      ,@(butlast body)
      (dlambda
        (:hotpatch (closure)
          (setq this closure))
        (t (&rest args)
          (apply this args)))))

(defmacro! let-hotpatch (letargs &rest body)
  `(let ((,g!this) ,@letargs)
      (setq ,g!this ,@(last body))
      ,@(butlast body)
      (dlambda
        (:hotpatch (closure)
          (setq ,g!this closure))
        (t (&rest args)
          (apply ,g!this args)))))
