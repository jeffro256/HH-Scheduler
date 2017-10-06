//
//  ClassEditorViewController.swift
//  HH Scheduler
//
//  Created by Jeffrey Ryan on 10/1/17.
//  Copyright © 2017 Jeffrey Ryan. All rights reserved.
//

import UIKit

public class ClassEditorViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var classID: PersonalSchedule.ClassID = -1
    var startName: String?
    var startColorIndex: Int!
    var shouldFocusText: Bool!

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var colorCollection: UICollectionView!

    @IBOutlet weak var colorPickerHeight: NSLayoutConstraint!

    public override func viewDidLoad() {
        super.viewDidLoad()

        nameField.text = startName
        if shouldFocusText { nameField.becomeFirstResponder() }

        startColorIndex = startColorIndex ?? 0

        let colorItemSizeRatio: CGFloat = 0.75
        let colorPickerInset = CGFloat(20)
        let colorItemSize = (self.view.frame.width - colorPickerInset * 2) / 4 * colorItemSizeRatio
        let innerSpace = (self.view.frame.width - colorPickerInset * 2) / 4 * (1 - colorItemSizeRatio)
        let h = colorItemSize * 2 + innerSpace + colorPickerInset * 2

        colorPickerHeight.constant = h
        if let layout = colorCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: colorItemSize, height: colorItemSize)
            layout.minimumLineSpacing = innerSpace
            layout.minimumInteritemSpacing = innerSpace
            layout.sectionInset = UIEdgeInsets(top: colorPickerInset, left: colorPickerInset, bottom: colorPickerInset, right: colorPickerInset)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return color_pallette.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)

        cell.backgroundColor = color_pallette[indexPath.item]
        cell.layer.cornerRadius = cell.frame.width / 2
        cell.layer.masksToBounds = true

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let selectedIndex = collectionView.indexPathsForSelectedItems?.first {
            collectionView.cellForItem(at: selectedIndex)?.layer.borderWidth = 0
        }
        return true
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)!

        cell.layer.borderColor = UIColor.blue.cgColor
        cell.layer.borderWidth = 2
    }

    public override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "Done" {
            return !(nameField.text?.isEmpty ?? true) && (colorCollection.indexPathsForSelectedItems?.count ?? 0) > 0
        }
        else {
            return true
        }
    }

    public func getData() -> (String, UIColor) {
        let name = nameField.text!
        let color = colorCollection.cellForItem(at: colorCollection.indexPathsForSelectedItems!.first!)!.backgroundColor!
        return (name, color)
    }
}
