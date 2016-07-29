//: Playground - noun: a place where people can play

// This exercise refers to codes of Rick Wargo.
// He/She did the well done project.
// When reviewing other classmates' exercise, I saw this project first time.
// And this is also my first time study ios code, so I am not good at programming swift and object-c.
// I am vey glad and surprise that how wonderful work he/she did.
// I learn much from his/her work, hope everyone can, too.

import UIKit

let image = UIImage(named: "sample")!

// Process the image!

let imageFilterProcess = ImageFilterProcessor(image: image)

let grayscaleImage = imageFilterProcess.doFilter("Grayscale", factor: 1.5)

let contrastImage = imageFilterProcess.doFilter("Contrast", factor: 2)

let blurryImage = imageFilterProcess.doFilter("Blurry", factor: 1.5)

let motionBlurryImage = imageFilterProcess.doFilter("MotionBlurry", factor: 1.5)

let hmirrorImage = imageFilterProcess.doFilter("HMirror")

let vmirrorImage = imageFilterProcess.doFilter("VMirror")

let listFilterImage = imageFilterProcess.doFilterList([("HMirror", 1.0), ("Contrast", 2.0),("Grayscale", 1.0)])
