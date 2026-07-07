package com.achadosapp.achados_br

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.achadosapp/gallery"
        private const val PICK_IMAGES_REQUEST = 1001
    }

    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickImages" -> {
                        pendingResult = result
                        openGallery()
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun openGallery() {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // Android 13+ usa o novo media picker
            Intent(MediaStore.ACTION_PICK_IMAGES).apply {
                putExtra(MediaStore.EXTRA_PICK_IMAGES_MAX, 5)
                type = "image/*"
            }
        } else {
            // Android < 13 usa ACTION_GET_CONTENT com múltipla seleção
            Intent(Intent.ACTION_GET_CONTENT).apply {
                type = "image/*"
                putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
                addCategory(Intent.CATEGORY_OPENABLE)
            }
        }
        startActivityForResult(intent, PICK_IMAGES_REQUEST)
    }

    @Suppress("OVERRIDE_DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode != PICK_IMAGES_REQUEST) return

        val result = pendingResult ?: return
        pendingResult = null

        if (resultCode != Activity.RESULT_OK || data == null) {
            result.success(emptyList<String>())
            return
        }

        val paths = mutableListOf<String>()

        // Múltiplas imagens via ClipData
        val clipData = data.clipData
        if (clipData != null) {
            for (i in 0 until clipData.itemCount) {
                val uri = clipData.getItemAt(i).uri
                resolveFilePath(uri)?.let { paths.add(it) }
            }
        } else {
            // Imagem única via data.data
            data.data?.let { uri ->
                resolveFilePath(uri)?.let { paths.add(it) }
            }
        }

        result.success(paths)
    }

    /**
     * Copia o URI para um arquivo temporário no cache do app e retorna o caminho absoluto.
     * Isso é necessário pois URIs de content:// não são diretamente acessíveis como File.
     */
    private fun resolveFilePath(uri: Uri): String? {
        return try {
            val inputStream = contentResolver.openInputStream(uri) ?: return null
            val mimeType = contentResolver.getType(uri) ?: "image/jpeg"
            val ext = when {
                mimeType.contains("png") -> "png"
                mimeType.contains("webp") -> "webp"
                mimeType.contains("gif") -> "gif"
                else -> "jpg"
            }
            val tempFile = java.io.File(cacheDir, "picked_${System.nanoTime()}.$ext")
            tempFile.outputStream().use { out -> inputStream.copyTo(out) }
            inputStream.close()
            tempFile.absolutePath
        } catch (e: Exception) {
            null
        }
    }
}
