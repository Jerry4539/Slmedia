//
//  SLTopStateView.swift
//  rpc
//
//  Created by => Jerry4539 on 2021/3/2.
//  Copyright © 2021 by Jerry4539 . All rights reserved.
//
import UIKit

class SLTopStateView: UIView {

    @IBOutlet weak var fullOrShrinkBtn: UIButton!
    
    static func initWithXib() -> SLTopStateView{
        let view = Bundle.init(identifier: SLMedia_identifier)!.loadNibNamed("SLTopStateView", owner: nil, options: nil)?.last as! SLTopStateView
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.fullOrShrinkBtn.setImage(SLImageLoad.load(name: "sl-fullscreen"), for: .normal)
    }
}
