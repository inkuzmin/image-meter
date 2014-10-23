;;;; image-meter.asd

(defpackage #:image-meter-asd
  (:use :cl :asdf))

(in-package :image-meter-asd)

(defsystem #:image-meter
  :name "image-meter"
  :serial t
  :author "Ivan Kuzmin <inkuzmin@ya.ru>"
  :license "MIT"
  :depends-on ("cl-who" "hunchentoot" "parenscript" "cl-fad")
  :components ((:file "package")
               (:file "image-meter")))

