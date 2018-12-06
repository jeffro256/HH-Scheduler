//
//  ClassEditorViewController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 10/1/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import UIKit

public class ClassEditorViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UITextFieldDelegate {
    var classID: PersonalSchedule.ClassID = -1
    var startName: String?
    var startColorIndex: Int!
    var adding = false

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var colorCollection: UICollectionView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var colorPickerHeight: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIBarButtonItem!

    public override func viewDidLoad() {
        super.viewDidLoad()

        nameField.text = startName

        if adding {
            deleteButton.isHidden = true;
            deleteButton.isEnabled = false;
            nameField.becomeFirstResponder()
            self.navigationItem.title = "Add Class"
        }
        else {
            self.navigationItem.title = "Edit Class"
        }

        doneButton.isEnabled = !(nameField.text?.isEmpty ?? true)

        startColorIndex = startColorIndex ?? 0

        let rows: CGFloat = 3     // Only float value to make calcs easier
        let coloums: CGFloat = 4  // Only float value to make calcs easier
        let colorItemSizeRatio: CGFloat = 0.7
        let colorPickerInset = CGFloat(30)
        let colorItemSize = (self.view.frame.width - colorPickerInset * 2) / coloums * colorItemSizeRatio
        let innerSpace = (self.view.frame.width - colorPickerInset * 2) / coloums * (1 - colorItemSizeRatio)
        let h = colorItemSize * rows + innerSpace + colorPickerInset * 2

        colorPickerHeight.constant = h
        if let layout = colorCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: colorItemSize, height: colorItemSize)
            layout.minimumLineSpacing = innerSpace
            layout.minimumInteritemSpacing = innerSpace
            layout.sectionInset = UIEdgeInsets(top: colorPickerInset, left: colorPickerInset, bottom: colorPickerInset, right: colorPickerInset)
        }

        colorCollection.reloadData()
        DispatchQueue.main.async {
            let selPath = IndexPath(row: self.startColorIndex, section: 0)
            self.colorCollection.selectItem(at: selPath, animated: false, scrollPosition: .centeredVertically)
            self.colorCollection.cellForItem(at: selPath)?.backgroundColor = color_pallette[self.startColorIndex]
        }

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return color_pallette.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell

        cell.backgroundColor = UIColor.clear
        cell.layer.cornerRadius = 12
        cell.layer.masksToBounds = true
        cell.sandwichCircle.layer.cornerRadius = 10
        cell.sandwichCircle.layer.masksToBounds = true
        cell.innerCircle.backgroundColor = color_pallette[indexPath.item]
        cell.innerCircle.layer.cornerRadius = 8
        cell.innerCircle.layer.masksToBounds = true

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let selectedIndex = collectionView.indexPathsForSelectedItems?.first {
            collectionView.cellForItem(at: selectedIndex)?.backgroundColor = UIColor.clear
        }
        return true
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ColorCell

        cell.backgroundColor = color_pallette[indexPath.item]
    }

    @IBAction func textfieldChanged(_ sender: Any) {
        doneButton.isEnabled = !(nameField.text?.isEmpty ?? true)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)

        return false
    }

    @objc public func dismissKeyboard() {
        self.view.endEditing(true)
    }

    public func getData() -> (String, UIColor) {
        let name = nameField.text!.strip()
        let color = colorCollection.cellForItem(at: colorCollection.indexPathsForSelectedItems!.first!)!.backgroundColor!
        return (name, color)
    }
}

class ColorCell: UICollectionViewCell {
    @IBOutlet weak var sandwichCircle: UIView!
    @IBOutlet weak var innerCircle: UIView!
}
