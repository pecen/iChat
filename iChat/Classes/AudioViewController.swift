//
//  AudioViewController.swift
//  iChat
//
//  Created by Peter Centellini on 2019-10-02.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import Foundation
import IQAudioRecorderController

class AudioViewController {
    var delegate: IQAudioRecorderViewControllerDelegate
    
    init(_delegate: IQAudioRecorderViewControllerDelegate) {
        delegate = _delegate
    }
    
    func presentAudioRecorder(target: UIViewController) {
        let controller = IQAudioRecorderViewController()
        
        controller.delegate = delegate
        controller.title = "Record"
        controller.maximumRecordDuration = kAUDIOMAXDURATION
        controller.allowCropping = true
        
        target.presentBlurredAudioRecorderViewControllerAnimated(controller)
    }
}
