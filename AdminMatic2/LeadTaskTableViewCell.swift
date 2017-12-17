//
//  LeadTaskTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 11/13/17.
//  Copyright © 2017 Nick. All rights reserved.
//



import Foundation
import UIKit
import Nuke

class LeadTaskTableViewCell: UITableViewCell {
    
    var task:Task!
    var thumbView:UIImageView = UIImageView()
    var activityView:UIActivityIndicatorView!
    var taskLbl: UILabel! = UILabel()
    var imageQtyLbl: Label! = Label()
    
   // var statusIcon: UIImageView!
    
    var addTasksLbl:Label = Label()
    
    var layoutVars:LayoutVars = LayoutVars()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
    }
    
    func layoutViews(){
        
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        self.selectionStyle = .none
        
        taskLbl = UILabel()
        taskLbl.text = self.task.task
        taskLbl.font = layoutVars.buttonFont
        taskLbl.numberOfLines = 2
        taskLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(taskLbl)
        
        
        self.thumbView.clipsToBounds = true
        self.thumbView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.thumbView)
        self.setBlankImage()
        
        taskLbl.translatesAutoresizingMaskIntoConstraints = false
        taskLbl.numberOfLines = 0;
        
        contentView.addSubview(taskLbl)
        
        if(self.task.images.count > 1){
            imageQtyLbl.text = "+\(self.task.images.count - 1)"
            imageQtyLbl.layer.opacity = 0.5
        }else{
            imageQtyLbl.text = ""
            imageQtyLbl.layer.opacity = 0.0
        }
        imageQtyLbl.translatesAutoresizingMaskIntoConstraints = false
        imageQtyLbl.backgroundColor = UIColor.white
        
        imageQtyLbl.font = layoutVars.largeFont
        imageQtyLbl.textAlignment = .center
        contentView.addSubview(imageQtyLbl)
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView.center = CGPoint(x: self.thumbView.frame.size.width, y: self.thumbView.frame.size.height)
        thumbView.addSubview(activityView)
        
        if(self.task.images.count > 0){
            self.setImageUrl(_url: self.task.images[0].thumbPath)
        }
        
        
        /*
        statusIcon = UIImageView()
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        contentView.addSubview(statusIcon)
        */
        
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        
        let viewsDictionary = ["thumbs":self.thumbView,"task":taskLbl, "imageQty":imageQtyLbl] as [String:AnyObject]
        
        let sizeVals = ["fullWidth": layoutVars.fullWidth - 90] as [String:Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[task(50)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[thumbs(50)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[imageQty(50)]", options: [], metrics: nil, views: viewsDictionary))
        
        
        
        //contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[status(40)]", options: [], metrics: nil, views: viewsDictionary))
        
        // contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[note(20)]-[imageQty(20)]", options: [], metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[task]-[thumbs(50)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[task]-[imageQty(50)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
    }
    
    
    func layoutAddBtn(){
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        // self.selectedImageView.image = nil
        self.selectionStyle = .none
        self.addTasksLbl.text = "Add Task"
        self.addTasksLbl.textColor = UIColor.white
        self.addTasksLbl.backgroundColor = UIColor(hex: 0x005100, op: 1.0)
        self.addTasksLbl.layer.cornerRadius = 4.0
        self.addTasksLbl.clipsToBounds = true
        self.addTasksLbl.textAlignment = .center
        contentView.addSubview(self.addTasksLbl)
        
        
        let viewsDictionary = ["addBtn":self.addTasksLbl] as [String : Any]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[addBtn]-10-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[addBtn(40)]", options: [], metrics: nil, views: viewsDictionary))
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setImageUrl(_url:String?){
        print("set Task ImageUrl")
        
        print("url = \(String(describing: _url))")
        
        if(_url == nil){
            setBlankImage()
        }else{
            
            let url = URL(string: _url!)
            
            Nuke.loadImage(with: url!, into: self.thumbView){ 
                //print("nuke loadImage")
                self.thumbView.handle(response: $0, isFromMemoryCache: $1)
                self.activityView.stopAnimating()
                
            }
            
            /* DispatchQueue.global().async {
             let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
             DispatchQueue.main.async {
             self.thumbView.image = UIImage(data: data!)
             }
             }
             */
            
        }
    }
    
    func setBlankImage(){
        self.thumbView.image = layoutVars.defaultImage
    }
    
    /*
    
    func setStatus(status: String) {
        switch (status) {
        case "1":
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            break;
        case "2":
            let statusImg = UIImage(named:"inProgressStatus.png")
            statusIcon.image = statusImg
            break;
        case "3":
            let statusImg = UIImage(named:"doneStatus.png")
            statusIcon.image = statusImg
            break;
        case "4":
            let statusImg = UIImage(named:"cancelStatus.png")
            statusIcon.image = statusImg
            break;
        case "5":
            let statusImg = UIImage(named:"waitingStatus.png")
            statusIcon.image = statusImg
            break;
        default:
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            break;
        }
    }
 */
    
    
    
}
