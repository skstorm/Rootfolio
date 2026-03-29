import Flutter
import Photos
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private let gallerySaverChannelName = "com.titlegym.anime_title_academy/gallery_saver"

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: gallerySaverChannelName,
        binaryMessenger: controller.binaryMessenger
      )

      channel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "saveImageToGallery" else {
          result(FlutterMethodNotImplemented)
          return
        }

        guard
          let arguments = call.arguments as? [String: Any],
          let sourcePath = arguments["sourcePath"] as? String
        else {
          result(
            FlutterError(
              code: "invalid_args",
              message: "sourcePath is required",
              details: nil
            )
          )
          return
        }

        self?.saveImageToGallery(sourcePath: sourcePath, result: result)
      }
    }
  }

  private func saveImageToGallery(sourcePath: String, result: @escaping FlutterResult) {
    let saveBlock = {
      guard let image = UIImage(contentsOfFile: sourcePath) else {
        result(
          FlutterError(
            code: "image_decode_failed",
            message: "Failed to read image from path.",
            details: nil
          )
        )
        return
      }

      var placeholder: PHObjectPlaceholder?
      PHPhotoLibrary.shared().performChanges({
        let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
        placeholder = request.placeholderForCreatedAsset
      }) { success, error in
        DispatchQueue.main.async {
          if success {
            result(placeholder?.localIdentifier)
          } else {
            result(
              FlutterError(
                code: "save_failed",
                message: error?.localizedDescription ?? "Failed to save image to Photos.",
                details: nil
              )
            )
          }
        }
      }
    }

    if #available(iOS 14, *) {
      let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
      switch status {
      case .authorized, .limited:
        saveBlock()
      case .notDetermined:
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
          DispatchQueue.main.async {
            if newStatus == .authorized || newStatus == .limited {
              saveBlock()
            } else {
              result(
                FlutterError(
                  code: "permission_denied",
                  message: "Photo Library add permission denied.",
                  details: nil
                )
              )
            }
          }
        }
      default:
        result(
          FlutterError(
            code: "permission_denied",
            message: "Photo Library add permission denied.",
            details: nil
          )
        )
      }
    } else {
      let status = PHPhotoLibrary.authorizationStatus()
      switch status {
      case .authorized:
        saveBlock()
      case .notDetermined:
        PHPhotoLibrary.requestAuthorization { newStatus in
          DispatchQueue.main.async {
            if newStatus == .authorized {
              saveBlock()
            } else {
              result(
                FlutterError(
                  code: "permission_denied",
                  message: "Photo Library permission denied.",
                  details: nil
                )
              )
            }
          }
        }
      default:
        result(
          FlutterError(
            code: "permission_denied",
            message: "Photo Library permission denied.",
            details: nil
          )
        )
      }
    }
  }
}
