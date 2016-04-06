(in-package :hex-utils)

;; tlists & cons pools
;; can be nicely  used as a queue!
(declaim (inline make-tlist tlist-left
                 tlist-right tlist-empty-p))

(defun make-tlist () (cons nil nil))
(defun tlist-left (tl) (caar tl))
(defun tlist-right (tl) (cadr tl))
(defun tlist-empty-p (tl) (null (car tl)))

(declaim (inline tlist-add-left
                 tlist-add-right))

(defun tlist-add-left (tl it)
  (let ((x (cons it (car tl))))
    (if (tlist-empty-p tl)
      (setf (cdr tl) x))
    (setf (car tl) x)))

(defun tlist-add-right (tl it)
  (let ((x (cons it nil)))
    (if (tlist-empty-p tl)
      (setf (car tl) x)
      (setf (cddr tl) x))
    (setf (cdr tl) x)))

(declaim (inline tlist-rem-left))

(defun tlist-rem-left (tl)
  (if (tlist-empty-p tl)
    (error "Remove from empty tlist")
    (let ((x (car tl)))
      (setf (car tl) (cadr tl))
      (if (tlist-empty-p tl)
        (setf (cdr tl) nil)) ;; for gc
      (car x))))

(declaim (inline tlist-update))

(defun tlist-update (tl)
  (setf (cdr tl) (last (car tl))))

;;; some cons stuff
(defvar number-of-conses 0)

(declaim (inline counting-cons))

(defun counting-cons (a b)
  (incf number-of-conses)
  (cons a b))

(defmacro! with-conses-counted (&rest body)
  `(let ((,g!orig number-of-conses))
    ,@body
    (- number-of-conses ,g!orig)))

(defmacro counting-push (obj stack)
  `(setq ,stack (counting-cons ,obj ,stack)))

;;; cons pools

(defmacro with-cons-pool (&rest body)
  `(let ((cons-pool)
         (cons-pool-count 0)
         (cons-pool-limit 100))
    (declare (ignoreable cons-pool
                         cons-pool-count
                         cons-pool-limit))
    ,@body))

(defmacro! cons-pool-cons (o!car o!cdr)
  `(if (= cons-pool-count 0)
    (counting-cons ,g!car ,g!cdr)
    (let ((,g!cell cons-pool))
      (decf cons-pool-count)
      (setf cons-pool (cdr cons-pool))
      (setf (car ,g!cell) ,g!car
            (cdr ,g!cell) ,g!cdr)
      ,g!cell)))

(defmacro! cons-pool-free (o!cell)
  `(when (<= cons-pool-count
             (- cons-pool-limit 1))
    (incf cons-pool-count)
    (setf (car ,g!cell) nil)
    (push ,g!cell cons-pool)))

(defmacro make-cons-pool-stack ()
  `(let (stack)
    (dlambda
      (:push (elem)
        (setf stack
              (cons-pool-cons elem stack)))
      (:pop ()
        (if (null stack)
          (error "Tried to pop an empty stack"))
        (let ((cell stack)
              (elem (car stack)))
          (setf stack (cdr stack))
          (cons-pool-free cell)
          elem)))))

(with-cons-pool
  (defun make-shared-cons-pool-stack ()
    (make-cons-pool-stack)))

(defmacro with-dynamic-cons-pools (&rest body)
  `(locally (declare (special cons-pool
                              cons-pool-count
                              cons-pool-limit))
    ,@body))

(defmacro fill-cons-pool ()
  `(let (tp)
    (loop for i from cons-pool-count
                to cons-pool-limit
          do (push
                (cons-pool-cons nil nil)
                tp))
    (loop while tp
          do (cons-pool-free (pop tp)))))
