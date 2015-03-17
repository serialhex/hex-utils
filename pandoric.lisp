(in-package :hex-utils)

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
