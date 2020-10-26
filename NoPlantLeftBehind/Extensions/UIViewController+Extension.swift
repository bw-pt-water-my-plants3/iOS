//
//  UIViewController+Extension.swift
//  NoPlantLeftBehind
//
//  Created by Kenneth Jones on 10/22/20.
//

import Foundation
import UIKit

extension UIViewController {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
}
