;;;; image-meter.lisp

(in-package #:image-meter)

;;; "image-meter" goes here. Hacks and glory await!

(setf *js-string-delimiter* #\")
(SETF (READTABLE-CASE *READTABLE*) :INVERT)

;(defvar *acceptor* (make-instance 'easy-acceptor :port 8888))

(start  (make-instance 'easy-acceptor :port 8888))

;(start *acceptor*)

;(stop *acceptor*)

(define-easy-handler (tutorial2 :uri "/test") ()
  (with-html-output-to-string (s)
    (:html
     (:head
      (:title "Измеритель расстояний"))
     (:body
      (:canvas :id "drop" :style "background-image: url(http://dump.bitcheese.net/images/yzamyge/drop.png); background-size: cover;")
      (:h2 "Измеритель расстояний")
      (:div :id "info")
      (:input :id "scale" :type "text" :placeholder "мкм")
      (:button :id "set-scale" "Установить масштаб")
      (:button :id "add-scale" "Добавить линейку")
      (:a :id "save-image" :href "#" :target "_blank" "Сохранить изображение")
      (:script :type "text/javascript" :src "/script.js")))))

(define-easy-handler (drop-js :uri "/script.js") ()
  (setf (content-type*) "text/javascript")
  (ps
    (let ((drop-node (chain document (get-element-by-id "drop")))
          (info-node (chain document (get-element-by-id "info")))
          (scale-node (chain document (get-element-by-id "scale")))
          (set-scale-button (chain document (get-element-by-id "set-scale")))
          (save-image-link (chain document (get-element-by-id "save-image")))
          (add-scale-button (chain document (get-element-by-id "add-scale")))
          (image (new (-image)))
          (scale 0)
          (current-line-length 0))
      (progn
        (chain drop-node (add-event-listener "dragenter" drag-enter false))
        (chain drop-node (add-event-listener "dragexit" drag-exit false))
        (chain drop-node (add-event-listener "dragover" drag-over false))
        (chain drop-node (add-event-listener "drop" drop false))

        (chain set-scale-button (add-event-listener "click" (lambda ()
                                                              (setf scale (/ (@ scale-node value) current-line-length))
                                                              (setf (@ info-node inner-h-t-m-l) (+ "Масштаб: " scale)))))
        
        (chain save-image-link (add-event-listener "click" (lambda ()
                                                             (setf (@ save-image-link href) (chain drop-node (to-data-U-R-L "image/png"))))))
        
        (chain add-scale-button (add-event-listener "click" (lambda ()
                                                              (clear-context)
                                                              
                                                              (draw-line 15 (- (@ drop-node height) 15)
                                                                         (+ (/ (@ scale-node value) scale) 15)
                                                                         (- (@ drop-node height) 15) 3 "#ffffff")
                                                              (draw-line 15 (- (@ drop-node height) 18)
                                                                         (+ (/ (@ scale-node value) scale) 15)
                                                                         (- (@ drop-node height) 18) 3 "#000000"))))
                                                              

        (defun calc (axis position)
          (if (equal axis :x)
              (- position (chain drop-node (get-bounding-client-rect) left))
              (- position (chain drop-node (get-bounding-client-rect) top))))

        (let ((context (chain drop-node (get-context "2d")))
              (drawing false)
              (orig '(0 0))
              (end '(0 0)))
          (progn
           ; (chain context (save))
            (defun draw-dot (x y)
              (chain context (begin-path))
              (chain context (arc x y 3 0 (* 2 (@ -Math PI)) false))
              (setf (@ context fill-style) "rgba(255, 0, 0, 0.8)") 
              (chain context (fill)))
            (defun clear-context ()
              (chain context (clear-rect 0 0 2000 2000))
              
              (chain context (draw-image image  0 0 (@ image width) (@ image height))))
             

            (defun draw-line (x0 y0 x1 y1 &optional width color)
              (chain context (begin-path)) 
              (if width
                  (setf (@ context line-width) width))
              (if color
                  (setf (@ context stroke-style) color))
              
              (chain context (move-to x0 y0))
              (chain context (line-to x1 y1))
              (chain context (stroke)))

            (defun line-length (x0 y0 x1 y1)
              (sqrt (+ (* (- y1 y0) (- y1 y0)) (* (- x1 x0) (- x1 x0)))))

            (defun click-handler (event)
              (if drawing
                  (progn
                    (setf drawing false)
                    (setf end (list
                               (calc :x (@ event client-x))
                               (calc :y (@ event client-y))))
                    (draw-dot (elt end 0) (elt end 1))
                    (draw-line (elt orig 0) (elt orig 1) (elt end 0) (elt end 1))
                    (setf current-line-length (line-length (elt orig 0) (elt orig 1) (elt end 0) (elt end 1)))
                    (setf (@ info-node inner-h-t-m-l) (+ "Длина: " (* scale current-line-length) "мкм / " current-line-length "px")))
                  (progn
                    (setf drawing true)
                    (setf orig (list
                                (calc :x (@ event client-x))
                                (calc :y (@ event client-y))))
              ;      (chain context (save))
                    (chain context (clear-rect 0 0 2000 2000))
                    
                    (chain context (draw-image image  0 0 (@ image width) (@ image height)))
                    (chain context (move-to (elt orig 0) (elt orig 1)))
                    (draw-dot (elt orig 0) (elt orig 1)))))


            
            (chain drop-node (add-event-listener "click" click-handler false))))
                 
        (defun load-to-canvas (event)
          (let ((data (@ event target result))
                (context (chain drop-node (get-context "2d"))))
            
            (progn
              (chain image (add-event-listener "load" (lambda ()
                                                        (setf (@ drop-node width) (@ image width))
                                                        (setf (@ drop-node height) (@ image height))
                                                        (setf (@ drop-node style width) (@ image width))
                                                        (setf (@ drop-node style height) (@ image height))
                                                        (chain context (draw-image this 0 0 (@ image width) (@ image height)))
                                                        (chain context (save)))))
              (setf (@ image src) data))))
        
        
        
        (defun handle-file (file)
          (let ((reader (new (-file-reader))))
            (progn
              (chain reader (add-event-listener "load" load-to-canvas))
              (chain reader (read-as-data-U-R-L file)))))
        
        
        (defun handle-files (files)
          (dolist (file files)
            (handle-file file)))
        
        (defun drag-enter (event)
          (chain event (stop-propagation))
          (chain event (prevent-default)))
        (defun drag-exit (event)
          (chain event (stop-propagation))
          (chain event (prevent-default)))
        (defun drag-over (event)
          (chain event (stop-propagation))
          (chain event (prevent-default)))
        (defun drop (event)
          (chain event (stop-propagation))
          (chain event (prevent-default))
          
          (let ((files (@ event data-transfer files)))
            (let ((total-files (length  files)))
              
              (if (> total-files 0)
                  (handle-files files)))))))))
    

(start *acceptor*)
