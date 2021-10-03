//
//  SLBottomStateView.swift
//  rpc
//
//  Created by => Jerry4539 on 2021/3/2.
//  Copyright © 2021 by Jerry4539 . All rights reserved.
//
import UIKit

class SLBottomStateView: UIView {

    @IBOutlet weak var playOrPauseBtn: UIButton!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var playingProgressSlider: UISlider!
    
    
    static func initWithXib() -> SLBottomStateView{
        let view = Bundle.init(identifier: SLMedia_identifier)!.loadNibNamed("SLBottomStateView", owner: nil, options: nil)?.last as! SLBottomStateView
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.playingProgressSlider.setThumbImage(SLImageLoad.load(name: "sl-point"), for: .normal)
        self.playOrPauseBtn.setImage(SLImageLoad.load(name: "sl-play"), for: .normal)
    }
    
}
