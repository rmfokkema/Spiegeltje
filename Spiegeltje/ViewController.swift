	  //
	  //  ViewController.swift
	  //  Spiegeltje
	  //
	  //  Created by René Fokkema on 22/02/2022.
	  //

import UIKit
import AVFoundation
// import Photos
import CoreGraphics

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {

	  private let maxZoomFactor: CGFloat = 20.0
	  private var zoomFactor: CGFloat = 1.0
	  private var frontCamSession = AVCaptureSession()
	  private let frontSessionQueue = DispatchQueue(label: "front queue")
	  @objc dynamic var frontVideoInput: AVCaptureDeviceInput!

	  @IBOutlet private weak var previewView: PreviewView!
	  @IBOutlet private weak var snapView: UIView!
	  @IBOutlet private weak var authorizeCameraLabel: UILabel!

	  private let photoOutput = AVCapturePhotoOutput()

	  private enum SessionSetupResult {
			 case success
			 case notAuthorized
			 case configurationFailed
	  }
	  private var setupResult: SessionSetupResult = .success

	  var hideStatusBar = true
	  var autoHideHomeIndicator = true
	  override var prefersStatusBarHidden: Bool { return hideStatusBar }
	  override var prefersHomeIndicatorAutoHidden: Bool { return autoHideHomeIndicator }
	  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .slide }

	  override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }

	  private var viewIsFlipped: Bool = false

	  var blurView: UIVisualEffectView!
	  private var holdToCapturePhoto: UILongPressGestureRecognizer!

	  override func viewDidLoad() {
			 super.viewDidLoad()

			 snapView.alpha = 0.0

			 let blur = UIBlurEffect(style: .systemUltraThinMaterial)
			 blurView = UIVisualEffectView(effect: blur)
			 blurView.frame = view.bounds
			 blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			 blurView.alpha = 0.0
			 view.addSubview(blurView)

					AVCaptureDevice.requestAccess(for: .video) { granted in
						  if granted {
								 DispatchQueue.main.async {
										self.authorizeCameraLabel.isHidden = true
								 }
								 self.frontSessionQueue.async {
										self.configureSession()
								 }
						  }
					}

			 photoOutput.isHighResolutionCaptureEnabled = true

			 holdToCapturePhoto = UILongPressGestureRecognizer(target: self, action: #selector(capturePhoto))

			 setNeedsStatusBarAppearanceUpdate()
			 setNeedsUpdateOfHomeIndicatorAutoHidden()

			 let tapToFlip = UITapGestureRecognizer(target: self, action: #selector(flipView))
			 tapToFlip.numberOfTapsRequired = 2
			 view.addGestureRecognizer(tapToFlip)
	  }

	  func checkSelfieSetting() {
			 if UserDefaults.standard.bool(forKey: "selfie_preference") {
					view.addGestureRecognizer(holdToCapturePhoto)
			 } else {
					view.removeGestureRecognizer(holdToCapturePhoto)
			 }
	  }

	  @objc private func flipView() {
			 view.transform = viewIsFlipped ? CGAffineTransform(scaleX: 1, y: 1) : CGAffineTransform(scaleX: -1, y: 1)

			 /* let session = self.frontCamSession
			 session.connections.first?.isVideoMirrored = viewIsFlipped ? true : false */

			 viewIsFlipped = viewIsFlipped ? false : true
	  }

	  @objc private func capturePhoto(_ sender: UILongPressGestureRecognizer!) {
			 if sender.state == .began {

					UIImpactFeedbackGenerator(style: .light).impactOccurred()
					
					photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)

					snapView.alpha = 0.9
					UIView.animate(withDuration: 0.3, animations: {
						  self.snapView.alpha = 0.0
					})
			 }
	  }

	  internal func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
			 guard error == nil else { print("Error capturing photo: \(error!)"); return }

			 let image = photo.cgImageRepresentation()!
			 let uiImage = UIImage(cgImage: image, scale: 1.0, orientation: (viewIsFlipped ? .right : .leftMirrored))
			 UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)

			 /* PHPhotoLibrary.requestAuthorization { status in
					guard status == .authorized else { return }

					PHPhotoLibrary.shared().performChanges({
						  let creationRequest = PHAssetCreationRequest.forAsset()
						  creationRequest.addResource(with: .photo, data: photo.fileDataRepresentation()!, options: nil)
					}, completionHandler: nil)
			 } */
	  }


	  private func configureSession() {

			 let session = self.frontCamSession
			 session.beginConfiguration()
			 session.sessionPreset = .high

			 do {
					guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
						  setupResult = .configurationFailed
						  session.commitConfiguration()
						  return
					}

					let deviceInput = try AVCaptureDeviceInput(device: videoDevice)
					if session.canAddInput(deviceInput) {
						  session.addInput(deviceInput)
					}
					if session.canAddOutput(photoOutput) {
						  session.addOutput(photoOutput)
					} else { print("Couldn't add photoOutput!") }
			 } catch {
					setupResult = .configurationFailed
					session.commitConfiguration()
					return
			 }

			 session.connections.first?.automaticallyAdjustsVideoMirroring = false

			 session.commitConfiguration()
	  }

	  override func viewWillAppear(_ animated: Bool) {
			 super.viewWillAppear(animated)
			 if self.setupResult != .success { return }

			 previewView.session = frontCamSession
			 previewView.videoPreviewLayer.videoGravity = .resizeAspectFill

			 frontSessionQueue.async {
					self.frontCamSession.startRunning()
			 }
	  }

	  public func blur(_ blur: Bool) {
			 if blur {
					self.blurView.alpha = 1
			 } else {
					UIView.animate(withDuration: 0.4, animations: {
						  self.blurView.alpha =	0
					})
			 }
	  }
}
