//
//  SpeedTestManager.swift
//  VigilSecVPN
//
//  Created by hyunho lee on 10/2/23.
//

import UIKit
import Foundation

/// A generic manager for calculating speed test
class SpeedTestManager {

    /// Keep track of in-progress tests
    static var isSpeedTestInProgress: Bool = false

    /// Calculate the upload speed
    static func checkUploadSpeed(completion: @escaping (_ speed: String?) -> Void) {
        var speedResults: [Double] = [Double]()

        /// Check upload speed on multiple upload sessions with different data size
        func checkSpeed(forData data: Data, completion: @escaping (_ speed: Double?) -> Void) {
            let startTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
            let urlString: String = "https://api.imgbb.com/1/upload?key=\(AppConfig.imgBBAPIKey)&expiration=60"
            let documentDirectory: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

            guard let documentsURL = documentDirectory, let url = URL(string: urlString) else {
                completion(nil)
                return
            }

            let fileData: Data = data
            let fileURL: URL = documentsURL.appendingPathComponent("\(UUID().uuidString)-image.jpg")
            var postData: Data = Data()
            let boundary: String = "Boundary-\(UUID().uuidString)"

            try? fileData.write(to: fileURL, options: .atomic)
            postData.append("--\(boundary)\r\n".data(using: .utf8)!)
            postData.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileURL.path)\"\r\n".data(using: .utf8)!)
            postData.append("Content-Type: \"content-type header\"\r\n\r\n".data(using: .utf8)!)
            postData.append(fileData)
            postData.append("\r\n".data(using: .utf8)!)
            postData.append("--\(boundary)--\r\n".data(using: .utf8)!)

            var request = URLRequest(url: url)
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = postData

            var uploadTask: URLSessionDataTask?
            let session: URLSession = URLSession(configuration: .ephemeral)
            uploadTask = session.dataTask(with: request, completionHandler: { data, _, _ in
                guard data != nil, let bytesSent = uploadTask?.countOfBytesSent else {
                    completion(nil)
                    return
                }
                let totalUploadTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent() - startTime
                completion(Double(bytesSent) / totalUploadTime)
            })
            uploadTask?.resume()
        }

        /// Speed data upload samples
        var samples: [Data] = [
            Data(count: 100 * 1024),        /// 100 kb
            Data(count: 500 * 1024),        /// 500 kb
            Data(count: 1 * (1024 * 1024))  /// 1 mb
        ]

        /// Get upload speed for sample
        func checkSampleSpeedTest() {
            if let sample = samples.first {
                checkSpeed(forData: sample) { speed in
                    if let result = speed {
                        speedResults.append(result)
                    }
                    samples.removeFirst()
                    checkSampleSpeedTest()
                }
            } else {
                SpeedTestManager.isSpeedTestInProgress = false
                completion((speedResults.reduce(0.0, +) / Double(speedResults.count)).speed)
            }
        }

        /// Start sample testing
        guard !isSpeedTestInProgress else { return }
        SpeedTestManager.isSpeedTestInProgress = true
        checkSampleSpeedTest()
    }

    /// Calculate the download speed
    static func checkDownloadSpeed(completion: @escaping (_ speed: String?) -> Void) {
        guard !isSpeedTestInProgress else { return }
        SpeedTestManager.isSpeedTestInProgress = true
        let fileURL: URL = URL(string: "https://i.ibb.co/YkNybW7/download-speed.jpg")!
        var downloadTask: URLSessionDataTask?
        let startTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
        let session: URLSession = URLSession(configuration: .ephemeral)
        downloadTask = session.dataTask(with: URLRequest(url: fileURL), completionHandler: { data, response, _ in
            guard data != nil, let contentSize = response?.expectedContentLength else {
                completion(nil)
                return
            }
            let totalUploadTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent() - startTime
            SpeedTestManager.isSpeedTestInProgress = false
            completion((Double(contentSize) / totalUploadTime).speed)
        })
        downloadTask?.resume()
    }
}
