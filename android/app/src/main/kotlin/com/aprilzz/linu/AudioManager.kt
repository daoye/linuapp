package com.aprilzz.linu

import android.content.Context
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMuxer
import android.media.MediaMetadataRetriever
import android.net.Uri
import java.io.File
import java.nio.ByteBuffer

class AudioManager(private val context: Context) {
    companion object {
        private const val AAC_MIME_TYPE = "audio/mp4a-latm"
        private const val AAC_MIME_TYPE_ALT = "audio/aac"
        private const val TRANSCODE_MAX_LOOPS = 100000
        private const val AAC_BIT_RATE = 128000
        private const val BUFFER_SIZE = 1024 * 1024
    }
    
    fun getCustomAudios(): List<Map<String, Any>> {
        val audios = mutableListOf<Map<String, Any>>()
        val soundsDir = getSoundsDirectory()
        
        val audioExtensions = setOf("mp3", "wav", "m4a", "aac", "ogg", "mp4")
        soundsDir.listFiles()?.forEach { file ->
            if (audioExtensions.contains(file.extension.lowercase()) && 
                !file.name.startsWith("linu.sounds.30s.")) {
                val duration = getAudioDuration(file.absolutePath)
                val modifiedTime = file.lastModified()
                audios.add(mapOf(
                    "path" to file.absolutePath,
                    "name" to file.name,
                    "duration" to duration,
                    "modifiedTime" to modifiedTime.toDouble()
                ))
            }
        }
        
        return audios
    }
    
    fun getAudioDuration(filePath: String): Double {
        val retriever = MediaMetadataRetriever()
        return try {
            if (filePath.startsWith("content://")) {
                val uri = Uri.parse(filePath)
                retriever.setDataSource(context, uri)
            } else {
                retriever.setDataSource(filePath)
            }
            val durationStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
            val durationMs = durationStr?.toLong() ?: 0L
            durationMs / 1000.0
        } catch (e: Exception) {
            0.0
        } finally {
            retriever.release()
        }
    }
    
    fun trimAudio(sourcePath: String, startTime: Double, endTime: Double, outputName: String): String {
        val outputFile = File(getSoundsDirectory(), "$outputName.m4a")
        
        val extractor = MediaExtractor()
        var muxer: MediaMuxer? = null
        var decoder: MediaCodec? = null
        var encoder: MediaCodec? = null
        
        try {
            setupExtractor(extractor, sourcePath)
            val (audioTrackIndex, audioFormat) = findAudioTrack(extractor)
            extractor.selectTrack(audioTrackIndex)
            
            prepareOutputFile(outputFile)
            
            val startTimeUs = (startTime * 1_000_000).toLong()
            val endTimeUs = (endTime * 1_000_000).toLong()
            extractor.seekTo(startTimeUs, MediaExtractor.SEEK_TO_PREVIOUS_SYNC)
            
            val mime = audioFormat.getString(MediaFormat.KEY_MIME) ?: ""
            
            if (isAacFormat(mime)) {
                trimAacAudio(extractor, audioFormat, muxer, outputFile, startTimeUs, endTimeUs)
            } else {
                val codecs = setupTranscodeCodecs(audioFormat, mime, outputFile)
                decoder = codecs.decoder
                encoder = codecs.encoder
                muxer = codecs.muxer
                
                transcodeAudio(
                    extractor = extractor,
                    decoder = decoder,
                    encoder = encoder,
                    muxer = muxer,
                    startTimeUs = startTimeUs,
                    endTimeUs = endTimeUs
                )
            }
            
            stopMuxerSafely(muxer)
            validateOutputFile(outputFile)
            
            return outputFile.absolutePath
        } catch (e: Exception) {
            cleanupOnError(outputFile)
            throw e
        } finally {
            releaseResources(encoder, decoder, muxer, extractor)
        }
    }
    
    private fun getSoundsDirectory(): File {
        val soundsDir = File(context.filesDir, "sounds")
        if (!soundsDir.exists()) {
            soundsDir.mkdirs()
        }
        return soundsDir
    }
    
    private fun setupExtractor(extractor: MediaExtractor, sourcePath: String) {
        if (sourcePath.startsWith("content://")) {
            val uri = Uri.parse(sourcePath)
            extractor.setDataSource(context, uri, null)
        } else {
            extractor.setDataSource(sourcePath)
        }
    }
    
    private fun findAudioTrack(extractor: MediaExtractor): Pair<Int, MediaFormat> {
        for (i in 0 until extractor.trackCount) {
            val format = extractor.getTrackFormat(i)
            val mime = format.getString(MediaFormat.KEY_MIME)
            if (mime?.startsWith("audio/") == true) {
                return Pair(i, format)
            }
        }
        throw Exception("No audio track found")
    }
    
    private fun prepareOutputFile(outputFile: File) {
        if (outputFile.exists()) {
            outputFile.delete()
        }
    }
    
    private fun isAacFormat(mime: String): Boolean {
        return mime == AAC_MIME_TYPE || mime == AAC_MIME_TYPE_ALT
    }
    
    private fun trimAacAudio(
        extractor: MediaExtractor,
        audioFormat: MediaFormat,
        muxer: MediaMuxer?,
        outputFile: File,
        startTimeUs: Long,
        endTimeUs: Long
    ) {
        val muxerInstance = MediaMuxer(outputFile.absolutePath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
        val muxerTrackIndex = muxerInstance.addTrack(audioFormat)
        muxerInstance.start()
        
        try {
            val buffer = ByteBuffer.allocate(BUFFER_SIZE)
            val bufferInfo = android.media.MediaCodec.BufferInfo()
            
            while (true) {
                val sampleSize = extractor.readSampleData(buffer, 0)
                if (sampleSize < 0) break
                
                val presentationTimeUs = extractor.sampleTime
                if (presentationTimeUs > endTimeUs) break
                
                bufferInfo.offset = 0
                bufferInfo.size = sampleSize
                bufferInfo.presentationTimeUs = presentationTimeUs - startTimeUs
                bufferInfo.flags = extractor.sampleFlags
                
                muxerInstance.writeSampleData(muxerTrackIndex, buffer, bufferInfo)
                extractor.advance()
            }
        } finally {
            stopMuxerSafely(muxerInstance)
        }
    }
    
    private data class TranscodeCodecs(
        val decoder: MediaCodec,
        val encoder: MediaCodec,
        val muxer: MediaMuxer
    )
    
    private fun setupTranscodeCodecs(
        audioFormat: MediaFormat,
        mime: String,
        outputFile: File
    ): TranscodeCodecs {
        val sampleRate = audioFormat.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        val channelCount = audioFormat.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
        
        val encoderFormat = MediaFormat.createAudioFormat(
            MediaFormat.MIMETYPE_AUDIO_AAC,
            sampleRate,
            channelCount
        )
        encoderFormat.setInteger(MediaFormat.KEY_AAC_PROFILE, android.media.MediaCodecInfo.CodecProfileLevel.AACObjectLC)
        encoderFormat.setInteger(MediaFormat.KEY_BIT_RATE, AAC_BIT_RATE)
        encoderFormat.setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, 16384)
        
        val encoder = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_AUDIO_AAC)
        encoder.configure(encoderFormat, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
        encoder.start()
        
        val decoder = MediaCodec.createDecoderByType(mime)
        decoder.configure(audioFormat, null, null, 0)
        decoder.start()
        
        val muxer = MediaMuxer(outputFile.absolutePath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
        
        return TranscodeCodecs(decoder, encoder, muxer)
    }
    
    private fun transcodeAudio(
        extractor: MediaExtractor,
        decoder: MediaCodec,
        encoder: MediaCodec,
        muxer: MediaMuxer,
        startTimeUs: Long,
        endTimeUs: Long
    ) {
        val state = TranscodeState()
        
        while (!state.encoderOutputEOS && state.loopCount < TRANSCODE_MAX_LOOPS) {
            state.loopCount++
            
            feedDecoderInput(extractor, decoder, state, endTimeUs)
            processDecoderOutput(decoder, encoder, state, startTimeUs)
            sendEosToEncoderIfNeeded(decoder, encoder, state)
            processEncoderOutput(encoder, muxer, state)
        }
        
        validateTranscodeState(state)
    }
    
    private class TranscodeState {
        var muxerTrackIndex = -1
        var muxerStarted = false
        var decoderInputEOS = false
        var decoderOutputEOS = false
        var encoderInputEOS = false
        var encoderOutputEOS = false
        var loopCount = 0
    }
    
    private fun feedDecoderInput(
        extractor: MediaExtractor,
        decoder: MediaCodec,
        state: TranscodeState,
        endTimeUs: Long
    ) {
        if (state.decoderInputEOS) return
        
        val inputIndex = decoder.dequeueInputBuffer(10000)
        if (inputIndex < 0) return
        
        val inputBuffer = decoder.getInputBuffer(inputIndex) ?: return
        val sampleSize = extractor.readSampleData(inputBuffer, 0)
        
        if (sampleSize < 0) {
            decoder.queueInputBuffer(inputIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
            state.decoderInputEOS = true
        } else {
            val presentationTimeUs = extractor.sampleTime
            if (presentationTimeUs >= endTimeUs) {
                decoder.queueInputBuffer(inputIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                state.decoderInputEOS = true
            } else {
                decoder.queueInputBuffer(
                    inputIndex,
                    0,
                    sampleSize,
                    presentationTimeUs,
                    extractor.sampleFlags
                )
                extractor.advance()
            }
        }
    }
    
    private fun processDecoderOutput(
        decoder: MediaCodec,
        encoder: MediaCodec,
        state: TranscodeState,
        startTimeUs: Long
    ) {
        val bufferInfo = android.media.MediaCodec.BufferInfo()
        var outputIndex = decoder.dequeueOutputBuffer(bufferInfo, 0)
        
        while (outputIndex >= 0) {
            val isEOS = (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0
            if (isEOS) {
                state.decoderOutputEOS = true
            }
            
            if (!state.decoderOutputEOS && bufferInfo.size > 0) {
                feedEncoderInput(decoder, encoder, outputIndex, bufferInfo, state, startTimeUs)
            }
            
            decoder.releaseOutputBuffer(outputIndex, false)
            outputIndex = decoder.dequeueOutputBuffer(bufferInfo, 0)
        }
    }
    
    private fun feedEncoderInput(
        decoder: MediaCodec,
        encoder: MediaCodec,
        decoderOutputIndex: Int,
        bufferInfo: android.media.MediaCodec.BufferInfo,
        state: TranscodeState,
        startTimeUs: Long
    ) {
        val outputBuffer = decoder.getOutputBuffer(decoderOutputIndex) ?: return
        val encoderInputIndex = encoder.dequeueInputBuffer(0)
        
        if (encoderInputIndex < 0) return
        
        val encoderInputBuffer = encoder.getInputBuffer(encoderInputIndex) ?: return
        encoderInputBuffer.clear()
        
        val remaining = outputBuffer.remaining()
        val encoderCapacity = encoderInputBuffer.remaining()
        
        if (remaining > 0 && remaining <= encoderCapacity) {
            encoderInputBuffer.put(outputBuffer)
            val adjustedTime = bufferInfo.presentationTimeUs - startTimeUs
            encoder.queueInputBuffer(
                encoderInputIndex,
                0,
                bufferInfo.size,
                adjustedTime,
                bufferInfo.flags
            )
        }
    }
    
    private fun sendEosToEncoderIfNeeded(
        decoder: MediaCodec,
        encoder: MediaCodec,
        state: TranscodeState
    ) {
        if (!state.decoderOutputEOS || state.encoderInputEOS) return
        
        val encoderInputIndex = encoder.dequeueInputBuffer(0)
        if (encoderInputIndex >= 0) {
            encoder.queueInputBuffer(
                encoderInputIndex,
                0,
                0,
                0,
                MediaCodec.BUFFER_FLAG_END_OF_STREAM
            )
            state.encoderInputEOS = true
        }
    }
    
    private fun processEncoderOutput(
        encoder: MediaCodec,
        muxer: MediaMuxer,
        state: TranscodeState
    ) {
        val bufferInfo = android.media.MediaCodec.BufferInfo()
        var outputIndex = encoder.dequeueOutputBuffer(bufferInfo, 0)
        
        if (outputIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
            if (!state.muxerStarted) {
                val newFormat = encoder.outputFormat
                state.muxerTrackIndex = muxer.addTrack(newFormat)
                muxer.start()
                state.muxerStarted = true
            }
            outputIndex = encoder.dequeueOutputBuffer(bufferInfo, 0)
        }
        
        while (outputIndex >= 0) {
            val isEOS = (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0
            if (isEOS) {
                state.encoderOutputEOS = true
            }
            
            if (!state.encoderOutputEOS && bufferInfo.size > 0 && state.muxerStarted) {
                val outputBuffer = encoder.getOutputBuffer(outputIndex)
                if (outputBuffer != null) {
                    outputBuffer.position(bufferInfo.offset)
                    outputBuffer.limit(bufferInfo.offset + bufferInfo.size)
                    muxer.writeSampleData(state.muxerTrackIndex, outputBuffer, bufferInfo)
                }
            }
            
            encoder.releaseOutputBuffer(outputIndex, false)
            outputIndex = encoder.dequeueOutputBuffer(bufferInfo, 0)
        }
    }
    
    private fun validateTranscodeState(state: TranscodeState) {
        if (state.loopCount >= TRANSCODE_MAX_LOOPS) {
            throw Exception("Transcode timeout: exceeded $TRANSCODE_MAX_LOOPS loops")
        }
        if (!state.muxerStarted) {
            throw Exception("Muxer was never started - encoder output format not received")
        }
    }
    
    private fun stopMuxerSafely(muxer: MediaMuxer?) {
        try {
            muxer?.stop()
        } catch (e: Exception) {
            // 忽略已停止的错误
        }
    }
    
    private fun validateOutputFile(outputFile: File) {
        if (!outputFile.exists() || outputFile.length() == 0L) {
            throw Exception("Output file is empty or not created")
        }
    }
    
    private fun cleanupOnError(outputFile: File) {
        if (outputFile.exists()) {
            outputFile.delete()
        }
    }
    
    private fun releaseResources(
        encoder: MediaCodec?,
        decoder: MediaCodec?,
        muxer: MediaMuxer?,
        extractor: MediaExtractor
    ) {
        releaseCodec(encoder, "encoder")
        releaseCodec(decoder, "decoder")
        releaseMuxer(muxer)
        releaseExtractor(extractor)
    }
    
    private fun releaseCodec(codec: MediaCodec?, name: String) {
        codec?.let {
            try {
                it.stop()
            } catch (e: Exception) {
                // 忽略错误
            }
            try {
                it.release()
            } catch (e: Exception) {
                // 忽略错误
            }
        }
    }
    
    private fun releaseMuxer(muxer: MediaMuxer?) {
        muxer?.let {
            try {
                it.release()
            } catch (e: Exception) {
                // 忽略错误
            }
        }
    }
    
    private fun releaseExtractor(extractor: MediaExtractor) {
        try {
            extractor.release()
        } catch (e: Exception) {
            // 忽略错误
        }
    }
    
}
