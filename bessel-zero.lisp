(defun bess-zeros (&key (a 0) (n 10) (d 1) (e 1d-6))
  "Compute the first n zeros of a bessel function. d determines the
type of the bessel function: 1.. J_a, 2.. Y_a, 3.. J_a', 4.. Y_a'; a
is the order, e is the measure of relative accuracy.
Reference: 1979 Temme An Algorithm with ALGOL 60 Program for the
Computation of the Zeros of Ordinary Bessel Functions and those of
their Derivatives"
  (declare (type (integer 0 100000) a n)
	   (type (integer 1 4) d)
	   (type (double-float 0d0) e))
  (let* ((z (make-array n :element-type 'double-float))
	 (p 0d0) (p0 0d0) (p1 0d0) (q1 0d0) (qq1 0d0) (pp 0d0) (pp1 0d0) (x 0d0))
    (declare (type double-float p p0 p1 q1 qq1 pp pp1 x))
    (flet ((fi (y)
	     (declare (type (double-float 0d0) y))
	     (let ((c1 1.570796d0))
	       (when (= y 0) (return-from fi 0d0))
	       (when (< 100000 y) (return-from fi c1))
	       (if (< y 1)
		   (setf p (expt (* 3d0 y) (/ 3d0))
			 pp (* p p)
			 p (* p (+ 1 (* 1/1575 pp (+ -210 (* pp (- 27 (* 2 pp))))))))
		   (setf p (/ (+ y c1))
			 pp (* p p)
			 p (- c1 (* 1/3465 p (+ 1 (* pp (+ 2310 (* pp (+ 3003 (* pp (+ 4818 (* pp (+ 8591 (* pp 16328))))))))))))))
	       (setf pp (expt (+ y p) 2))
	       (let ((r (/ (- p (atan (+ y p))) pp)))
		 (- p (* (+ 1 pp) r (+ 1 (/ r (+ y p))))))))
	   (bessr (d a x)
	     (declare (type (integer 1 4) d)
		      (type fixnum a)
		      (type double-float x))
	     (ecase d
	       (1 (/ (jn a x) (jn (+ a 1) x)))
	       (2 (/ (yn a x) (yn (+ a 1) x)))
	       (3 (- (/ a x) (/ (jn (+ a 1) x) (jn a x))))
	       (4 (- (/ a x) (/ (yn (+ a 1) x) (yn a x)))))))
      (let* ((aa (* a a)) (mu (* 4d0 aa)) (mu2 (* mu mu)) (mu3 (* mu mu2)) (mu4 (* mu2 mu2)))
	(if (< d 3)
	   (setf p (- (* 7 mu) 31)
		 p0 (- mu 1)
		 p1 (if (= (+ 1 p) p) 0d0 (* 4/15 (/ p) (+ (* 253 mu2) (* -3722 mu) 17869) p0))
		 q1 (if (= (+ 1 p) p) 0d0 (* 1.6d0 (/ p) (+ (* 83 mu2) (* -982 mu) 3779))))
	   (setf p (+ (* 7 mu2) (* 82 mu) -9)
		 p0 (+ mu 3)
		 p1 (if (= (+ 1 p) p) 0d0 (* (/ p) (/ 60) (+ (* 4048 mu4) (* 131264 mu3) (* -221984 mu2) (* -417600 mu) 1012176)))
		 q1 (if (= (+ 1 p) p) 0d0 (* 1.6d0 (/ p) (+ (* 83 mu3) (* 2074 mu2) (* -3039 mu) 3537)))))
       (let* ((vt (if (or (= 1 d) (= 4 d)) .25d0 .75d0))
	      (tt (* 4 vt)))
	 (if (< d 3)
	     (setf pp1 (coerce 5/48 'double-float)   qq1 (coerce -5/36 'double-float))
	     (setf pp1 (coerce -7/48 'double-float)  qq1 (coerce 35/288 'double-float)))
	 
	 (let ((bb (if (<= 3 a) (expt (* 1d0 a) (/ -2d0 3)) 1d0))
	       (a1 (+ (* 3 a) -8))
	       (y (* .375 pi))
	       (xx 0d0) (j 0) (b 0d0)  (c 0d0) (u 0d0) (v 0d0) (w 0d0) (a2 0d0) (q 0d0) (ro 0d0) (x4 0d0))
	   (declare (type double-float bb b c q ro)
		    (type fixnum j))
	   
	   (loop for s from 1 upto n do
		(if (and (= a 0) (= s 1) (= d 3))
		    (setf x 0d0 j 0)
		    (progn
		      (if (<= a1 s)
			  (setf b (* pi (+ s (* .5 a) (- vt)))
				c (/ .015625d0 (* b b))
				x (+ b (* -.125 (/ (- p0 (* p1 c))
						   (* b (- 1 (* q1 c)))))))
			  (progn 
			    (if (= s 1)
				(setf x (ecase d 
					  (1 -2.33811d0)
					  (2 -1.17371d0)
					  (3 -1.01879d0)
					  (4 -2.29444d0)))
				(setf x (* y (+ (* 4 s) (- tt)))
				      v (/ (* x x))
				      x (* (- (expt x (/ 2d0 3))) (+ 1 (* v (+ pp1 (* qq1 v)))))))
			    (setf u (* x bb)
				  v (let ((minu (- u)))
				      (declare (type (double-float 0d0) minu))
				      (fi (* 2/3 (expt minu 1.5d0))))
				  w (/ (cos v))
				  xx (+ 1 (- (* w w)))
				  c (let ((ux (/ u xx)))
				      (declare (type (double-float 0d0) ux))
				      (sqrt ux))
				  x (* w (+ a (* (/ c (* 48 a u))
						 (if (< d 3)
						     (+ (/ -5 u) (- (* c (+ (/ -10 xx) 6))))
						     (+ (/ 7 u) (* c (+ (/ -14 xx) 18))))))))))
		      (setf j 0)
		      (tagbody l1
			 (setf xx (* x x)
			       x4 (* xx xx)
			       a2 (- aa xx)
			       ro (bessr d a x)
			       j (+ j 1))
			 (if (< d 3)
			     (setf u ro
				   w (* 6 x (+ (* 2 a) 1))
				   p (/ (+ 1 (* -4 a2)) 
					w)
				   q (/ (+ (* 4 (- xx mu))
					   -2 (* -12 a)) w))
			     (setf u (- (* xx ro (/ a2)))
				   v (* 2 x a2 (/ (* 3 (+ aa xx))))
				   w (* 64 a2 a2 a2)
				   q (* 2 v (+ 1 mu2 (* 32 mu xx) (* 48 x4))
					(/ w))
				   p (* v (+ 1 (/ (+ (- mu2) (* 40 mu xx) (* 48 x4)) 
						  w)))))
			 (setf w (* u (/ (+ 1 (* p ro))
					 (+ 1 (* q ro))))
			       x (+ x w))
			 (when (and (< e (abs (/ w x)) ) (< j 5))
			   (go l1)))
		      (setf (aref z (- s 1)) x))))
	   (return-from bess-zeros2 z)))))))


#+nil
(bess-zeros :d 2 :a 0)
#+nil
(loop for a below 12 collect
     (list 
      (loop for x across (bess-zeros :d 1 :a a :n 10) collect
	   (< (jn a x) 1d-6))
      (loop for x across (bess-zeros :d 2 :a a :n 10) collect
	   (< (yn a x) 1d-6))))

#+nil
(time
 (progn (dotimes (i 10)
	  (bess-zeros :d 2 :a i :n 10000))
	nil))



#+nil
(let ((vold 0d0)) ;; some simple code to find zeros
  (remove-if #'null
	     (loop for x from 1 below 100d4 collect
		  (let* ((arg (* x 1d-4))
			 (v (yn 2 arg)))
		    (prog1 
			(when (< (* vold v) 0)
			  (read-from-string (format nil "~2,3f" arg)))
		      (setf vold v))))))


;; J okay
;; 1	2.4048	3.8317	5.1356	6.3802	7.5883	8.7715
;; 2	5.5201	7.0156	8.4172	9.7610	11.0647	12.3386
;; 3	8.6537	10.1735	11.6198	13.0152	14.3725	15.7002
;; 4	11.7915	13.3237	14.7960	16.2235	17.6160	18.9801
;; 5	14.9309	16.4706	17.9598	19.4094	20.8269	22.2178

;; J3
;; (6.38 9.761 13.015 16.224 19.41 22.583 25.748 28.908 32.065 35.219 38.37
;;       41.521 44.67 47.818 50.965 54.112 57.258 60.403 63.549 66.693 69.838 72.982
;;       76.126 79.27 82.414 85.557 88.701 91.844 94.987 98.13)

;; Y0
;; (0.894 3.958 7.086 10.222 13.361 16.501 19.641 22.782 25.923 29.064 32.205
;;        35.346 38.488 41.629 44.771 47.912 51.053 54.195 57.336 60.478 63.619
;;        66.761 69.902 73.044 76.185 79.327 82.468 85.61 88.752 91.893 95.035 98.176)

;; Y1
;; (2.197 5.43 8.596 11.749 14.898 18.044 21.188 24.332 27.475 30.618 33.761
;;     36.904 40.046 43.188 46.33 49.473 52.615 55.757 58.899 62.041 65.182 68.324
;;     71.466 74.608 77.75 80.891 84.033 87.175 90.317 93.458 96.6 99.742)

#+nil (bess-zeros :d 2 :a 2 :n 32 :e 1d-12)
;; Y2
;; (3.384 6.794 10.024 13.21 16.379 19.539 22.694 25.846 28.995 32.143 35.29
;;     38.436 41.581 44.726 47.87 51.014 54.158 57.301 60.445 63.588 66.731 69.874
;;     73.016 76.159 79.302 82.444 85.587 88.729 91.871 95.014 98.156)

#+nil (bess-zeros :d 2 :a 3 :n 32 :e 1d-12)
;; Y3
;; (4.527 8.098 11.397 14.623 17.819 20.997 24.166 27.329 30.487 33.642 36.795
;;        39.946 43.095 46.244 49.392 52.538 55.685 58.831 61.976 65.121 68.266 71.41
;;        74.554 77.698 80.842 83.986 87.129 90.272 93.416 96.559 99.702 )

;; J' a=0 is okay, a=1 is wrong
;; 1	3.8317	1.8412	3.0542	4.2012	5.3175	6.4156
;; 2	7.0156	5.3314	6.7061	8.0152	9.2824	10.5199
;; 3	10.1735	8.5363	9.9695	11.3459	12.6819	13.9872
;; 4	13.3237	11.7060	13.1704	14.5858	15.9641	17.3128
;; 5	16.4706	14.8636	16.3475	17.7887	19.1960	20.5755
