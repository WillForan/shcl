(in-package :shcl-test.utility)
(in-suite utility)

(defparameter *value* 0)
(define-once-global test-global (incf *value*))

(def-test once-global (:compile-at :definition-time)
  (is (equal 1 test-global))
  (is (equal 1 test-global))
  (is (equal 1 *value*)))

(define-condition test-condition ()
  ())

(defun signals-test ()
  (signal 'test-condition))

(def-test hooks (:compile-at :definition-time)
  (define-hook test-hook 'signals-test)
  (is (signals 'test-condition (run-hook 'test-hook)))
  (define-hook test-hook)
  (add-hook 'test-hook 'test-condition)
  (is (signals 'test-condition (run-hook 'test-hook)))
  (remove-hook 'test-hook 'signals-test)
  (run-hook 'test-hook))

(def-test when-let-tests (:compile-at :definition-time)
  (is (not (when-let ((a (+ 1 2))
                      (b (format nil "asdf"))
                      (c (not 'not))
                      (d (error "This form shouldn't be evaluated")))
             (is nil))))
  (is (when-let ((a t)
                 (b t)
                 (c t))
        (is (eq a t))
        (is (eq b t))
        (is (eq c t))
        (and a b c))))

(def-test try-tests (:compile-at :definition-time)
  (is (eq 'foobar
          (try (progn (throw 'baz 123))
            (bap () 'xyz)
            (baz (value) (is (eq value 123)) 'foobar)))))