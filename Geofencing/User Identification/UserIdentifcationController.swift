//
//  UserIdentifcationController.swift
//  Geofencing
//
//  Created by Sijo on 03/01/18.
//  Copyright © 2018 Sijo. All rights reserved.
//

import UIKit

class UserIdentifcationController: UIViewController {
    
    @IBOutlet weak var empIDTextField: UITextField!
    
    @IBOutlet weak var floorTextField: UITextField!
    
    @IBOutlet weak var deptTextField: UITextField!
    
    @IBOutlet weak var listView: UITableView!
    
    @IBOutlet weak var listViewTopConstarint: NSLayoutConstraint!
    
    @IBOutlet weak var listViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var userIdNavItem: UINavigationItem!
    private func saveEmployeeDetails(){
        
        _ = CoreDataHandler.saveObject(empID: "G0001", dept: "IC-BU", floor: "Top Floor")
        _ = CoreDataHandler.saveObject(empID: "G0002", dept: "AN-BU", floor: "Top Floor")
        _ = CoreDataHandler.saveObject(empID: "G0003", dept: "HM-BU", floor: "Second Floor")
        _ = CoreDataHandler.saveObject(empID: "G0004", dept: "WC-BU", floor: "Second Floor")
        _ = CoreDataHandler.saveObject(empID: "G0005", dept: "ICore", floor: "Ground Floor")
    }
    
    private let cellID = "listViewcell"
    
    private let rowHeight = 44
    
    private var selectedIndex = 0
    
    var rightNavBtn = UIBarButtonItem()
    
    private var employee: [Employee]? = nil
    
    private var sections = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false
        
        empIDTextField.autocapitalizationType = .allCharacters
        empIDTextField.singleLine()
        floorTextField.singleLine()
        deptTextField.singleLine()
        
        
        listView.layer.cornerRadius = 6.5
        
        employee = CoreDataHandler.fetchObject()
        
        if employee?.count == 0 {
            
            saveEmployeeDetails()
        }
            employee = CoreDataHandler.fetchObject()
        
        
        rightNavBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveAndStartTracking))
        rightNavBtn.isEnabled = false
        userIdNavItem.rightBarButtonItem = rightNavBtn
    }
    
    private func getDepartmentsAndFloors(){
        
        employee = CoreDataHandler.fetchObject()
        
        var empIDs = ["Select"]
        var floors = ["Select"]
        var depts = ["Select"]
        
        for attrbte in employee! {
            
            empIDs.append(attrbte.empIDs!)
            floors.append(attrbte.floors!)
            depts.append(attrbte.depts!)
        }
        
        sections = [Section(empIDs: empIDs, area: floors, selected: "Select"),
                    Section(empIDs: empIDs, area: depts, selected: "Select")]
        
        animateWhenLayoutUpdating(sections[0].area.count * rowHeight, section: 0)
    }
    
    private func deleteEntry() {
        
        if CoreDataHandler.deleteObject(employee: employee![1]) {
            employee = CoreDataHandler.fetchObject()
        }

        if CoreDataHandler.cleanDelete() {
            employee = CoreDataHandler.fetchObject()
        }
    }
    
    @objc func saveAndStartTracking() {
        
        if floorTextField.text?.isEmpty == false && floorTextField.text != "Select" && deptTextField.text?.isEmpty == false && deptTextField.text != "Select" {
            
            let rootViewController = UIApplication.shared.keyWindow?.rootViewController
            guard let mainNavigationController = rootViewController as? NavigationHandler else { return }
            
            mainNavigationController.viewControllers = [MapViewController()]
            
            UserDefaults.standard.setIsloggedIn(value: true)
            UserDefaults.standard.setEmployeeID(value: empIDTextField.text!)
            
            dismiss(animated: true, completion: nil)
        } else {
            print("Provided ones are not valid.")
        }
    }
}

extension UserIdentifcationController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField != empIDTextField {
            
            if empIDTextField.isFirstResponder {
                empIDTextField.resignFirstResponder()
            }
            
            selectedIndex = textField.tag
            
            if sections.count > 0 {
                animateWhenLayoutUpdating(sections[selectedIndex].area.count * rowHeight, section: selectedIndex)
            }
            
            return false
        }
        
        animateWhenLayoutUpdating(0, section: 0)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text!.count < 4 {
            return false
        }
        
        employee = CoreDataHandler.isValid(textField.text!)
        
        rightNavBtn.isEnabled = false
        
        guard let isContains = employee?.count else { return false }
        if isContains != 0 {
            rightNavBtn.isEnabled = true
            textField.resignFirstResponder()
            getDepartmentsAndFloors()
        }
        
        return true
    }
    
    
    func animateWhenLayoutUpdating(_ listViewHeight: Int, section: Int) {
        
        listViewHeightConstraint.constant = CGFloat(listViewHeight)
        
        if selectedIndex == 0 {
            listViewTopConstarint.constant = 112
        } else {
          listViewTopConstarint.constant = 157
        }
        
        UIView .animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view .layoutIfNeeded()
            
        }, completion: { (success) in
            
            self.listView.reloadData()
        })
    }
}

// MARK : - TableViewDelegates
extension UserIdentifcationController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        sections[selectedIndex].selected = (tableView.cellForRow(at: indexPath)?.textLabel?.text)!
        
        if selectedIndex == 0 {
            floorTextField.text = sections[selectedIndex].selected
        } else {
            deptTextField.text = sections[selectedIndex].selected
        }
        
        animateWhenLayoutUpdating(0, section: selectedIndex)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(rowHeight)
    }
}

// MARK : - TableViewDataSource
extension UserIdentifcationController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if sections.count > 0 {
            return sections[selectedIndex].area.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        cell.textLabel?.text = sections[selectedIndex].area[indexPath.row]
        
        return cell
    }
}

