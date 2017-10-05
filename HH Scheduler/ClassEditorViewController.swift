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
    var startColor: UIColor?
    var shouldFocusText: Bool!

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var colorCollection: UICollectionView!

    @IBOutlet weak var colorPickerHeight: NSLayoutConstraint!

    public override func viewDidLoad() {
        super.viewDidLoad()

        nameField.text = startName
        if shouldFocusText { nameField.becomeFirstResponder() }

        /*
        if let color = startColor {
            let palleteIndex = color_pallette.index(of: color)!

            colorCollection.selectItem(at: IndexPath(row: palleteIndex, section: 0), animated: false, scrollPosition: .centeredVertically)
        }
         */
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        colorCollection.collectionViewLayout.invalidateLayout()
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

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let l = collectionView.frame.width / 5 - 20
        return CGSize(width: l, height: l)
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
