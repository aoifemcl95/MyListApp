//
//  TableViewCell.swift
//  MyListApp
//
//  Created by Aoife McLaughlin on 05/04/2018.
//  Copyright © 2018 Aoife McLaughlin. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate {
    func toDoItemsDeleted(todoItem: ToDoItem)
}


class TableViewCell: UITableViewCell {

let gradientLayer = CAGradientLayer()
    let notification = UINotificationFeedbackGenerator()
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    var completeOnDragRelease = false
    let label: StrikeThroughText
    var itemCompleteLayer = CALayer()
    var delegate: TableViewCellDelegate?
    var toDoItem: ToDoItem?{
         //add didSet observer to ensure the strikethrough label stays in sync with the toDoITem
        didSet{
            label.text = toDoItem!.text
            label.strikeThrough = toDoItem!.completed
            itemCompleteLayer.isHidden = !label.strikeThrough
        }
    }
   
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        label = StrikeThroughText(frame: CGRect.null)
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.clear
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(label)
        selectionStyle = .none
        
        gradientLayer.frame = bounds
        let color1 = UIColor(white: 1.0, alpha: 0.2).cgColor as CGColor
        let color2 = UIColor(white: 1.0, alpha: 0.1).cgColor as CGColor
        let color3 = UIColor.clear.cgColor as CGColor
        let color4 = UIColor(white: 0.0, alpha: 0.1).cgColor as CGColor
        gradientLayer.colors = [color1, color2, color3, color4]
        gradientLayer.locations = [0.0, 0.1, 0.95, 1.0]
        layer.insertSublayer(gradientLayer, at: 0)
        
        //adding a layer to make background green when an item has been completed
        itemCompleteLayer = CALayer(layer: layer)
        itemCompleteLayer.backgroundColor = UIColor(displayP3Red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0).cgColor
        itemCompleteLayer.isHidden = true
        layer.insertSublayer(itemCompleteLayer, at: 0)
        
//        var recognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
// updated in swift 3
        var recognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(recognizer:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }
    
    let kLabelLeftMargin: CGFloat = 15.0
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        itemCompleteLayer.frame = bounds
        label.frame = CGRect(x: kLabelLeftMargin, y: 0, width: bounds.size.width, height: bounds.size.height)
    }
    
    //horizontal pan gesture methods
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            originalCenter = center
        }
        if recognizer.state == .changed {
            let translation = recognizer.translation(in: self)
            center = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y)
            deleteOnDragRelease = frame.origin.x < -frame.size.width/2.0
            completeOnDragRelease = frame.origin.x > frame.size.width/2.0
        }
        if recognizer.state == .ended {
            let originalFrame = CGRect(x: 0, y:frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            if deleteOnDragRelease {
                if delegate != nil && toDoItem != nil {
                    delegate!.toDoItemsDeleted(todoItem: toDoItem!)
                }
            }
                else if completeOnDragRelease {
                    if toDoItem != nil {
                        toDoItem!.completed = true
                    }
                    label.strikeThrough = true
                    itemCompleteLayer.isHidden = false
                     UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
                notification.notificationOccurred(.success)
                } else {
                     UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
                }
            
               
            
            // this will invoke the delegate method if the user has dragged the item far enough 

            }
        }
    
    
    //allows you to cancel the recognition of a gesture before it has begun
    //if it is a vertical pan you cancel the gesture recognizer
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer{
            let translation = panGestureRecognizer.translation(in: superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
            
        }
        return false
    }
}
