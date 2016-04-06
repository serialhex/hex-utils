(in-package :hex-utils)

;; so i can maybe put more than one fn in this file!?!??!
(eval-when (:compile-toplevel :load-toplevel :execute)

; a read macro for speed or safety, your choice
(set-dispatch-macro-character #\# #\f
  (lambda (stream sub-char numarg)
    (declare (ignore stream sub-char))
    (setq numarg (or numarg 3))
    (unless (<= numarg 3)
      (error "Bad value for #f: ~a" numarg))
    `(declare (optimize (speed ,numarg)
                        (safety ,(- 3 numarg))))))

)

(defmacro fast-progn (&rest body)
  `(locally #f ,@body))

(defmacro safe-progn (&rest body)
  `(locally #0f ,@body))


;; lambda list processing is slow, this will make it faster!
(defun fast-keywords-strip (args)
  (if args
    (cond
      ((eq (car args) '&key)
        (fast-keywords-strip (cdr args)))
      ((consp (car args))
        (cons (caar args)
              #1=(fast-keywords-strip
                    (cdr args))))
      (t
        (cons (car args) #1#)))))

(defmacro! defun-with-fast-keywords
           (name args &rest body)
  `(progn
    (defun ,name ,args ,@body)
    (defun ,g!fast-fun
           ,(fast-keywords-strip args)
           ,@body)
    (compile ',g!fast-fun)
    (define-compiler-macro ,name (&rest ,g!rest)
      (destructuring-bind ,args ,g!rest
        (list ',g!fast-fun
              ,@(fast-keywords-strip args))))))

#|
;; fast formatting
(defun fformat (&rest all)
  (apply #'format all))

(compile 'fformat)

(define-compiler-macro fformat
                       (&whole form
                        stream fmt &rest args)
  (if (constantp fmt)
    (if stream
      `(funcall (formatter ,fmt)
        ,stream ,@args)
      (let ((g!stream (gensym "stream")))
        `(with-output-to-string (,g!stream)
          (funcall (formatter ,fmt)
            ,g!stream ,@args))))
    form))
|#

;; a disassembler, for inspecting & making moar fasterer!!
(defmacro dis (args &rest body)
  `(disassemble
    (compile nil
      (lambda ,(mapcar (lambda (a)
                        (if (consp a)
                          (cadr a)
                          a))
                       args)
        (declare
          ,@(mapcar
              #`(type ,(car a1) ,(cadr a1))
              (remove-if-not #'consp args)))
        ,@body))))

(defmacro! with-fast-stack
           ((sym &key (type 'fixnum) (size 1000) (safe-zone 100))
            &rest body)
  `(let ((,g!index ,safe-zone)
         (,g!mem (make-array ,(+ size (* 2 safe-zone))
                             :element-type ',type)))
    (declare (type (simple-array ,type) ,g!mem)
             (type fixnum ,g!index))
    (macrolet
      ((,(symb 'fast-push- sym) (val)
            `(locally #f
                (setf (aref ,',g!mem ,',g!index) ,val)
                (incf ,',g!index)))
       (,(symb 'fast-pop- sym) ()
            `(locally #f
                (decf ,',g!index)
                (aref ,',g!mem ,',g!index)))
       (,(symb 'check-stack- sym) ()
            `(progn
              (if (<= ,',g!index ,,safe-zone)
                (error "Stack underflow: ~a" ',',sym))
              (if (<= ,,(- size safe-zone)
                      ,',g!index)
                (error "Stack overflow: ~a" ',',sym)))))
      ,@body)))
