import Foundation
import Networking

typealias MediaUploadable = Networking.UploadableMedia

/// Completion block when a media item is exported.
///
typealias MediaExportCompletion = (MediaUploadable?, Error?) -> Void

/// Exports media to the local file system for remote upload.
///
protocol MediaExporter {

    /// The type of MediaDirectory to use for the export destination URL.
    ///
    /// - Note: This would generally be set to .uploads or .cache, but for unit testing we use .temporary.
    ///
    var mediaDirectoryType: MediaDirectory { get }

    /// Export a media to another format
    ///
    /// - Parameters:
    ///   - onCompletion: a callback to invoke when the export finishes.
    ///
    func export(onCompletion: @escaping MediaExportCompletion)
}

/// Extension providing generic helper implementation particular to a MediaExporter.
///
extension MediaExporter {

    /// A MediaFileManager configured with the exporter's set MediaDirectory type.
    ///
    var mediaFileManager: MediaFileManager {
        return MediaFileManager(directory: mediaDirectoryType)
    }
}

/// Protocol of general options available for an export, typically corresponding to a user setting.
///
protocol MediaExportingOptions {

    /// Strip the geoLocation from exported media, if needed.
    ///
    var stripsGeoLocationIfNeeded: Bool { get }
}
