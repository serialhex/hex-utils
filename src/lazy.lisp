(in-package :hex-utils)
;; from "Land of Lisp" by Conrad Barski M.D.

(defmacro lazy (&body body)
  (let ((forced (gensym))
        (value (gensym)))
    `(let ((,forced nil)
           (,value nil))
      (lambda ()
        (unless ,forced
          (setf ,value (progn ,@body))
          (setf ,forced t))
        ,value))))

(defun force (lazy-value)
  (funcall lazy-value))

; lazy lists... they need to get a job!

(defmacro lazy-cons (a d)
  `(lazy (cons ,a ,d)))

(defun lazy-car (x)
  (car (force x)))

(defun lazy-cdr (x)
  (cdr (force x)))

; example:
(defparameter *integers*
  (labels ((f (n)
             (lazy-cons n (f (1+ n)))))
    (f 1)))

; termination & checking if null
(defun lazy-nil ()
  (lazy nil))

(defun lazy-null (x)
  (not (force x)))

; make a list lazy,
; meditate on this a bit...
(defun make-lazy (lst)
  (lazy (when lst
          (cons (car lst) (make-lazy (cdr lst))))))

; un-lazy some or all of a list
(defun take (n lst)
  (unless (or (zerop n) (lazy-null lst))
    (cons (lazy-car lst) (take (1- n) (lazy-cdr lst)))))

(defun take-all (lst)
  (unless (lazy-null lst)
    (cons (lazy-car lst) (take-all (lazy-cdr lst)))))

; mapping & searching through lazy lists...
; makin 'em do some work!!!
(defun lazy-mapcar (fun lst)
  (lazy (unless (lazy-null lst)
          (cons (funcall fun (lazy-car lst))
                (lazy-mapcar fun (lazy-cdr lst))))))

(defun lazy-mapcan (fun lst)
  (labels ((f (lst-cur)
           (if (lazy-null lst-cur)
                   (force (lazy-mapcan fun (lazy-cdr lst)))
                 (cons (lazy-car lst-cur) (lazy (f (lazy-cdr lst-cur)))))))
    (lazy (unless (lazy-null lst)
            (f (funcall fun (lazy-car lst)))))))

(defun lazy-find-if (fun lst)
  (unless (lazy-null lst)
    (let ((x (lazy-car lst)))
      (if (funcall fun x)
          x
          (lazy-find-if fun (lazy-cdr lst))))))

(defun lazy-nth (n lst)
  (if (zerop n)
      (lazy-car lst)
      (lazy-nth (1- n) (lazy-cdr lst))))

(defmacro! lazy-setup (lazy-func args &rest body)
"This is for when you need to run the setup for a function, before you run the
real function, but you don't want to run it right now.  You specify the lazy-func
as yout first argument, then you specify the args & body of your actual function.
Nice feature: the lazy function can reference arguments passed in to your
soon-to-be not lazy function!"
  `(progn
    (setq ,g!lazy-fn
      (lambda ,args
        ,lazy-func
        (setq ,g!lazy-fn
              (lambda ,args
                ,@body))
        (funcall ,g!lazy-fn ,@args)))
    (lambda ,args
      (funcall ,g!lazy-fn ,@args))))
