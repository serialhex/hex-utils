(in-package :hex-utils)

;; anaphora!!
#|
In natural language, an anaphor is an expression which refers back in the con-
versation. The most common anaphor in English is probably "it," as in "Get the
wrench and put it on the table."
|#

(defmacro aif (test-form then-form &optional else-form)
  `(let ((it ,test-form))
    (if it ,then-form ,else-form)))
; anaphoric if
; (aif (big-long-calculation)
;      (foo it))

(defmacro awhen (test-form &body body)
  `(aif ,test-form
        (progn ,@body)))
; (awhen (big-long-calculation)
;   (foo it)
;   (bar it))

(defmacro awhile (expr &body body)
  `(do ((it ,expr ,expr))
       ((not it))
       ,@body))
; (awhile (poll *fridge*)
;   (eat it))

(defmacro aand (&rest args)
  (cond ((null args) t)
        ((null (cdr args)) (car args))
        (t `(aif ,(car args) (aand ,@(cdr args))))))
; (aand (owner x) (address it) (town it))
; returns the town (if there is one) of the address (I.T.I.1) of the owner (I.T.I.1) of x

(defmacro acond (&rest clauses)
  (if (null clauses)
      nil
      (let ((cl1 (car clauses))
            (sym (gensym)))
        `(let ((,sym ,(car cl1)))
          (if ,sym
              (let ((it ,sym)) ,@(cdr cl1))
              (acond ,@(cdr clauses)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MOAR Anaphors!
;; figure 14.2 pg 193
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; also defined in "Let Over Lambda"
(defmacro alambda (parms &body body)
  `(labels ((self ,parms ,@body))
    #'self))
; (defun count-instances (obj lists)
;   (mapcar (alambda (list)
;             (if list
;                 (+ (if (eq (car list) obj) 1 0)
;                    (self (cdr list)))
;                 0))
;     lists))

(defmacro ablock (tag &rest args)
  `(block ,tag
    ,(funcall (alambda (args)
                (case (length args)
                  (0 nil)
                  (1 (car args))
                  (t `(let ((it ,(car args)))
                        ,(self (cdr args))))))
              args)))

(defmacro alet (letargs &rest body)
  `(let ((this) ,@letargs)
     (setq this ,@(last body))
     ,@(butlast body)
     (lambda (&rest params)
       (apply this params))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MULTIPLE VALUE ANAPHORS!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro aif2 (test &optional then else)
  (let ((win (gensym)))
    `(multiple-value-bind (it ,win) ,test
        (if (or it ,win) ,then ,else))))

(defmacro awhen2 (test &body body)
  `(aif2 ,test
         (progn ,@body)))

(defmacro awhile2 (test &body body)
  (let ((flag (gensym)))
    `(let ((,flag t))
      (while ,flag
        (aif2 ,test
              (progn ,@body)
              (setq ,flag nil))))))

(defmacro acond2 (&rest clauses)
  (if (null clauses)
      nil
      (let ((cl1 (car clauses))
            (val (gensym))
            (win (gensym)))
        `(multiple-value-bind (,val ,win) ,(car cl1)
          (if (or ,val ,win)
              (let ((it ,val)) ,@(cdr cl1))
              (acond2 ,@(cdr clauses)))))))


(defmacro do-file (filename &body body)
  (let ((str (gensym)))
    `(with-open-file (,str ,filename)
      (awhile2 (read2 ,str)
        ,@body))))
; (defun our-load (filename)
;   (do-file filename (eval it)))

;; read anaphora... see "Let over Lambda" sec 6.2 for details
(defun |#`-reader| (stream sub-char numarg)
  (declare (ignore sub-char))
  (unless numarg (setq numarg 1))
  `(lambda ,(loop for i from 1 to numarg
                  collect (symb 'a i))
      ,(funcall
          (get-macro-character #\`) stream nil)))

(set-dispatch-macro-character
  #\# #\` #'|#`-reader|)
