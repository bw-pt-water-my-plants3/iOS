//
//  UIImage+Extension.swift
//  NoPlantLeftBehind
//
//  Created by Kenneth Jones on 10/15/20.
//

import Foundation
import UIKit

extension UIImage {
    var toData: Data? {
        return pngData()
    }
}
