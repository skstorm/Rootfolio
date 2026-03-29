package com.titlegym.anime_title_academy

import android.content.ContentValues
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.titlegym.anime_title_academy/gallery_saver"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveImageToGallery" -> {
                    val sourcePath = call.argument<String>("sourcePath")
                    val fileName = call.argument<String>("fileName")
                    if (sourcePath.isNullOrBlank() || fileName.isNullOrBlank()) {
                        result.error("invalid_args", "sourcePath/fileName is required", null)
                        return@setMethodCallHandler
                    }

                    saveImageToGallery(sourcePath, fileName, result)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun saveImageToGallery(
        sourcePath: String,
        fileName: String,
        result: MethodChannel.Result,
    ) {
        runCatching {
            val sourceFile = File(sourcePath)
            require(sourceFile.exists()) { "Source image does not exist." }

            val mimeType = when (sourceFile.extension.lowercase()) {
                "jpg", "jpeg" -> "image/jpeg"
                "webp" -> "image/webp"
                else -> "image/png"
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val values = ContentValues().apply {
                    put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
                    put(MediaStore.Images.Media.MIME_TYPE, mimeType)
                    put(
                        MediaStore.Images.Media.RELATIVE_PATH,
                        "${Environment.DIRECTORY_PICTURES}/AnimeTitleAcademy",
                    )
                    put(MediaStore.Images.Media.IS_PENDING, 1)
                }

                val resolver = applicationContext.contentResolver
                val uri = resolver.insert(
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                    values,
                ) ?: error("Failed to create MediaStore record.")

                resolver.openOutputStream(uri)?.use { output ->
                    FileInputStream(sourceFile).use { input ->
                        input.copyTo(output)
                    }
                } ?: error("Failed to open gallery output stream.")

                values.clear()
                values.put(MediaStore.Images.Media.IS_PENDING, 0)
                resolver.update(uri, values, null, null)
                uri.toString()
            } else {
                val picturesDir = Environment.getExternalStoragePublicDirectory(
                    Environment.DIRECTORY_PICTURES,
                )
                val appDir = File(picturesDir, "AnimeTitleAcademy")
                if (!appDir.exists()) {
                    appDir.mkdirs()
                }

                val destination = File(appDir, fileName)
                FileInputStream(sourceFile).use { input ->
                    destination.outputStream().use { output ->
                        input.copyTo(output)
                    }
                }
                MediaScannerConnection.scanFile(
                    this,
                    arrayOf(destination.absolutePath),
                    arrayOf(mimeType),
                    null,
                )
                destination.absolutePath
            }
        }.onSuccess { savedLocation ->
            result.success(savedLocation)
        }.onFailure { throwable ->
            result.error(
                "save_failed",
                throwable.message ?: "Failed to save image to gallery.",
                null,
            )
        }
    }
}
