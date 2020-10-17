//
//  NCViewer.swift
//  Nextcloud
//
//  Created by Marino Faggiana on 16/10/2020.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//
//  Author Marino Faggiana <marino.faggiana@nextcloud.com>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

class NCViewer: NSObject {
    @objc static let shared: NCViewer = {
        let instance = NCViewer()
        return instance
    }()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var viewerQuickLook: NCViewerQuickLook?
    
    func view(viewController: UIViewController, metadata: tableMetadata) {

        // VIDEO AUDIO
        if metadata.typeFile == k_metadataTypeFile_audio || metadata.typeFile == k_metadataTypeFile_video {
            
            if let navigationController = getPushNavigationController(viewController: viewController, serverUrl: metadata.serverUrl) {
                let viewController:NCViewerVideo = UIStoryboard(name: "NCViewerVideo", bundle: nil).instantiateInitialViewController() as! NCViewerVideo
            
                viewController.metadata = metadata

                navigationController.pushViewController(viewController, animated: true)
            }
            return
        }
        
        // DOCUMENTS
        if metadata.typeFile == k_metadataTypeFile_document {
                
            // PDF
            if metadata.contentType == "application/pdf" {
                    
                if let navigationController = getPushNavigationController(viewController: viewController, serverUrl: metadata.serverUrl) {
                    let viewController:NCViewerPDF = UIStoryboard(name: "NCViewerPDF", bundle: nil).instantiateInitialViewController() as! NCViewerPDF
                
                    viewController.metadata = metadata
                
                    navigationController.pushViewController(viewController, animated: true)
                }
                return
            }
        }
        
        // OTHER
        let fileNamePath = NSTemporaryDirectory() + metadata.fileNameView

        CCUtility.copyFile(atPath: CCUtility.getDirectoryProviderStorageOcId(metadata.ocId, fileNameView: metadata.fileNameView), toPath: fileNamePath)

        viewerQuickLook = NCViewerQuickLook.init()
        viewerQuickLook?.quickLook(url: URL(fileURLWithPath: fileNamePath))
    }
    
    private func getPushNavigationController(viewController: UIViewController, serverUrl: String) -> UINavigationController? {
        
        if viewController is NCFiles || viewController is NCFavorite || viewController is NCOffline || viewController is NCRecent || viewController is NCFileViewInFolder {
            if serverUrl == appDelegate.activeServerUrl {
                return viewController.navigationController
            }
        }
        return nil
    }
}