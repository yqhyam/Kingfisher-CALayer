//
//  Kingfisher+CALayer.swift
//  KingfisherCALayer
//
//  Created by YaM on 2023/10/17.
//

import UIKit
import Kingfisher

public typealias KFCrossPlatformLayer = CALayer

extension KFCrossPlatformLayer: KingfisherCompatible {}

extension KingfisherWrapper where Base: KFCrossPlatformLayer {
    
    @discardableResult
    public func setLayerImage(
        with source: URL?,
        placeholder: UIImage? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> DownloadTask?
    {
        let mutatingSelf = self
        guard let source = source else {
            if let placeholder = placeholder {
                mutatingSelf.base.contents = placeholder.cgImage
            }
            completionHandler?(.failure(KingfisherError.imageSettingError(reason: .emptySource)))
            return nil
        }
        
        let task = KingfisherManager.shared.retrieveImage(with: source) { receivedSize, totalSize in
            progressBlock?(receivedSize, totalSize)
        } completionHandler: { result in
            DispatchQueue.main.async {
                switch result{
                case .success(let res):
                    mutatingSelf.base.contents = res.image.cgImage
                    break
                case .failure:
                    if let placeholder = placeholder {
                        mutatingSelf.base.contents = placeholder.cgImage
                    }
                    break
                }
                completionHandler?(result)
            }
        }
        return task
    }
}
