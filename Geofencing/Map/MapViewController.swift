//
//  MapViewController.swift
//  Geofencing
//
//  Created by Sijo on 04/01/18.
//  Copyright © 2018 Sijo. All rights reserved.
//

import CoreLocation
import UserNotifications
import HCKalmanFilter
import MapKit
import UIKit

class MapViewController: UIViewController {
    
    var resetKalmanFilter: Bool = false
    var hcKalmanFilter: HCKalmanAlgorithm?
    
    private static let shared = MapViewController()
    
    private var logs = [String]()
    private let logCellId = "logCell"
    
    private var mapViewAnchors = [NSLayoutConstraint]()
    
    private var initialLocation: CLLocation!
    
    // Initialize Core Location manager instance
    
    private let manager: CLLocationManager = {
        
        let locm = CLLocationManager()
        locm.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locm.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locm.allowsBackgroundLocationUpdates = true
        locm.showsBackgroundLocationIndicator = true
        
        return locm
    }()
    
    
    // Initialize MapView
    
    private let mapView = MKMapView()
    
    private let headerView: UIView = {
        
        let hVw = UIView()
        hVw.backgroundColor = 0x007AFF.color
        return hVw
    }()
    
    private let setView: UIView = {
        
        let sVw = UIView()
        sVw.backgroundColor = .black
        return sVw
    }()
    
    private let headerLabel: UILabel = {
        
        let hLbl = UILabel()
        hLbl.textColor = .white
        hLbl.font = UIFont(name: "Helvetica Neue", size: 18)
        hLbl.text = "Geofencing"
        hLbl.numberOfLines = 0
        hLbl.textAlignment = .center
        return hLbl
    }()
    
    private let reqLabel: UILabel = {
        
        let rLbl = UILabel()
        rLbl.textColor = .white
        rLbl.font = UIFont(name: "Helvetica Neue", size: 18)
        rLbl.text = "Request current location"
        rLbl.numberOfLines = 0
        return rLbl
    }()
    
    private let sigChangeLabel: UILabel = {
        
        let sLbl = UILabel()
        sLbl.textColor = .white
        sLbl.font = UIFont(name: "Helvetica Neue", size: 18)
        sLbl.text = "Start Significant Monitoring"
        sLbl.numberOfLines = 0
        return sLbl
    }()
    
    private let mapLabel: UILabel = {
        
        let mLbl = UILabel()
        mLbl.textColor = .white
        mLbl.font = UIFont(name: "Helvetica Neue", size: 18)
        mLbl.text = "Show Map"
        mLbl.numberOfLines = 0
        return mLbl
    }()
    
    private let requestBtn: UIButton = {
       
        let rBtn = UIButton()
        rBtn.backgroundColor = .white
        rBtn.setTitleColor(.blue, for: .normal)
        rBtn.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 40)
        rBtn.setTitle("", for: .normal)
        rBtn.addTarget(self, action: #selector(onRequestCurrentLocBtnClick(_:)), for: .touchUpInside)
        return rBtn
    }()
    
    private let sigSwitch: UISwitch = {
        let sigSw = UISwitch()
        sigSw.tintColor = .white
        sigSw.onTintColor = .blue
        sigSw.isOn = false
        sigSw.addTarget(self, action: #selector(onSigSwitchValueChange(_:)), for: .valueChanged)
        return sigSw
    }()
    
    private let mapSwitch: UISwitch = {
        let mapSw = UISwitch()
        mapSw.tintColor = .white
        mapSw.onTintColor = .blue
        mapSw.isOn = false
        mapSw.addTarget(self, action: #selector(onMapSwitchValueChange(_:)), for: .valueChanged)
        return mapSw
    }()

    lazy var logField: UITableView = {
        
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.backgroundColor = .black
        tableView.separatorColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = true
        tableView.allowsSelection = false
        return UITableView()
    }()
    
    private let mapSizeBtn: UIButton = {
        
        let mapSzBtn = UIButton()
        mapSzBtn.backgroundColor = .clear
        mapSzBtn.setBackgroundImage(#imageLiteral(resourceName: "fullscreen"), for: .normal)
        mapSzBtn.isHidden = true
        mapSzBtn.addTarget(self, action: #selector(onMapSizeBtnClick(_:)), for: .touchUpInside)
        return mapSzBtn
    }()
    
    private let resetBtn: UIButton = {
        
        let rBtn = UIButton()
        rBtn.backgroundColor = .white
        rBtn.setTitleColor(.blue, for: .normal)
        rBtn.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 20)
        rBtn.setTitle("Reset", for: .normal)
        rBtn.addTarget(self, action: #selector(onResetBtnClick(_:)), for: .touchUpInside)
        return rBtn
    }()
    
    fileprivate func addSubViews() {
        view.addSubview(headerView)
        headerView.addSubview(headerLabel)
        view.addSubview(mapView)
        view.addSubview(setView)
        setView.addSubview(reqLabel)
        setView.addSubview(sigChangeLabel)
        setView.addSubview(mapLabel)
        setView.addSubview(requestBtn)
        setView.addSubview(sigSwitch)
        setView.addSubview(mapSwitch)
        setView.addSubview(resetBtn)
        view.addSubview(logField)
        view.addSubview(mapSizeBtn)
    }
    
    fileprivate func setLayout() {
        
        _ = headerView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 64)
        
        _ = headerLabel.anchorWithZeroConstant(top: headerView.topAnchor, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor)
        
        _ = setView.anchor(headerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 180)
        
        _ = reqLabel.anchor(setView.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 16, leftConstant: 30, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 0)
        
        _ = sigChangeLabel.anchor(reqLabel.bottomAnchor, left: reqLabel.leftAnchor, bottom: nil, right: reqLabel.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 0)
        
        _ = mapLabel.anchor(sigChangeLabel.bottomAnchor, left: reqLabel.leftAnchor, bottom: setView.bottomAnchor, right: reqLabel.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 16, rightConstant: 0, widthConstant: 200, heightConstant: 0)
        
        _ = requestBtn.anchor(setView.topAnchor, left: nil, bottom: nil, right: setView.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 30)
        
        _ = sigSwitch.anchor(sigChangeLabel.topAnchor, left: nil, bottom: nil, right: requestBtn.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 30)
        
        _ = mapSwitch.anchor(mapLabel.topAnchor , left: nil, bottom: nil, right: requestBtn.rightAnchor, topConstant: 25, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 30)
        
        _ = resetBtn.anchor(nil, left: mapLabel.leftAnchor, bottom: setView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 25)
        
        
        _ = logField.anchor(setView.bottomAnchor, left: setView.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: setView.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        // Add layout to mapView
        self.initialMapViewConstarins()
        
        _ = mapSizeBtn.anchor(nil, left: nil, bottom: mapView.bottomAnchor, right: mapView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 8, rightConstant: 8, widthConstant: 50, heightConstant: 50)
    }
    
    fileprivate func addCornerRadius() {
        setView.layer.cornerRadius = 5.0
        setView.layer.masksToBounds = true
        mapView.layer.cornerRadius = 5.0
        mapView.layer.masksToBounds = true
        requestBtn.layer.cornerRadius = 5.0
        requestBtn.layer.masksToBounds = true
        resetBtn.layer.cornerRadius = 5.0
        resetBtn.layer.masksToBounds = true
        mapSwitch.layer.cornerRadius = 5.0
        mapSwitch.layer.masksToBounds = true
        logField.layer.cornerRadius = 5.0
        logField.layer.masksToBounds = true
        mapSizeBtn.layer.cornerRadius = 5.0
        mapSizeBtn.layer.masksToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // We make the navigation bar hidden
        self.navigationController?.navigationBar.isHidden = true
        
        // Add mapview to Main view
        addSubViews()
        
        // Set view layout
        setLayout()
        
        // Add round corners
        addCornerRadius()
        
        // Setting Core Location delegate
        manager.delegate = self
        
        // Request permission to access user location always.
        manager.requestAlwaysAuthorization()
        
        // Show user location
        mapView.showsUserLocation = true
        
        // Hidden map view
        mapView.isHidden = true
        
        logField.register(LogViewCell.self, forCellReuseIdentifier: logCellId)
        logField.delegate = self
        logField.dataSource = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in print(granted)}
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        manager.requestLocation()
    }
    
    // Which override the system status bar hidden property to true
    override var prefersStatusBarHidden: Bool {
        
        return true
    }
    
    fileprivate func getLocalAddressIfNeeded(_ location: CLLocation) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { (data, error) in
            
            guard let placeMarks = data else { return }
            let loc: CLPlacemark = placeMarks[0]
            self.mapView.centerCoordinate = location.coordinate
            print(" locality : \(String(describing: loc.locality)), loc.subLocality : \(String(describing: loc.subLocality))")
        }
    }
    
    func notifyUserWith(_ subtitle: String) {
        
        if UIApplication.shared.applicationState != .background {
            // the alert view
            let alert = UIAlertController(title: "", message: subtitle, preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            
            // change to desired number of seconds (in this case 5 seconds)
            let when = DispatchTime.now() + 5
            DispatchQueue.main.asyncAfter(deadline: when){
                // your code with delay
                alert.dismiss(animated: true, completion: nil)
            }
        } else {
            
            let content = UNMutableNotificationContent()
            content.title = "Geofencing"
            content.subtitle = subtitle
            content.sound = .default()
            let request = UNNotificationRequest(identifier: "notifIde", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    @objc func onRequestCurrentLocBtnClick(_ sender: UIButton) {
        requestBtn.setTitle("•", for: .normal)
        manager.requestLocation()
    }
    
    @objc func onSigSwitchValueChange(_ sender: UISwitch) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways && sender.isOn {
            sigChangeLabel.text = "Stop Significant Monitoring"
            manager.startUpdatingLocation()
            sigSwitch.setOn(false, animated: true)
        } else {
            sigSwitch.setOn(true, animated: true)
            sigChangeLabel.text = "Start Significant Monitoring"
            manager.stopUpdatingLocation()
        }
    }
    
    @objc func onMapSwitchValueChange(_ sender: UISwitch) {
        showMapWithAnimation()
    }
    
    func showMapWithAnimation() {
        
        UIView.animate(withDuration: 2.0, animations: {
            
            if self.mapView.isHidden {
                self.logField.alpha = 0
                self.mapView.alpha = 1
            } else {
                self.mapView.alpha = 0
                self.logField.alpha = 1
            }
            
        }) { (completed) in
            
            if self.mapView.isHidden {
                self.mapSwitch.setOn(true, animated: true)
                self.mapView.isHidden = false
                self.mapSizeBtn.isHidden = false
                self.logField.isHidden = true
            } else {
                self.mapSwitch.setOn(false, animated: true)
                self.logField.isHidden = false
                self.mapView.isHidden = true
                self.mapSizeBtn.isHidden = true
            }
        }
    }
    
    fileprivate func initialMapViewConstarins() {
        self.mapViewAnchors = self.mapView.anchorWithZeroConstant(top: self.logField.topAnchor, left: self.logField.leftAnchor, bottom: self.logField.bottomAnchor, right: self.logField.rightAnchor)
    }
    
    @objc func onMapSizeBtnClick(_ sender: UIButton) {
        
        UIView.animate(withDuration: 2.0, animations: {
            
            NSLayoutConstraint.deactivate(self.mapViewAnchors)
            
            if self.mapViewAnchors.count == 0 || self.setView.isHidden {
                self.initialMapViewConstarins()
                self.mapView.layer.cornerRadius = 5.0
                self.mapSizeBtn.setBackgroundImage(#imageLiteral(resourceName: "fullscreen"), for: .normal)
            } else {
                self.mapViewAnchors = self.mapView.anchorWithZeroConstant(top: self.view.safeAreaLayoutGuide.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor)
            }
            
            self.view.layoutIfNeeded()
            
        }) { (completed) in
            
            if self.setView.isHidden {
                self.setView.isHidden = false
            } else {
                self.setView.isHidden = true
                self.mapView.layer.cornerRadius = 0.0
                self.mapSizeBtn.setBackgroundImage(#imageLiteral(resourceName: "exit"), for: .normal)
            }
        }
    }
    
    @objc func onResetBtnClick(_ sender: UIButton) {
        
        hcKalmanFilter = nil
        resetKalmanFilter = true
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
            
        default :
            print("Location access denied by user.")
            
        }
    }
    
    fileprivate func logExcSteps(_ log: String) {
        
        if logField.isHidden {
            logField.isHidden = false
        }
        
        print(log)
        
        logs.insert(log, at: 0)
        
        self.logField.beginUpdates()
        self.logField.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        self.logField.endUpdates()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        /* My Coordinate : 10.029009, 76.337729 */
        requestBtn.setTitle("", for: .normal)
        mapView.userTrackingMode = .follow
        
        manager.stopUpdatingLocation()
        
        guard let currentLocation = locations.first else { return }
        
        if self.hcKalmanFilter == nil {
            self.hcKalmanFilter = HCKalmanAlgorithm(initialLocation: currentLocation)
            initialLocation = currentLocation
        } else {
            
            if let hcKalmanFilter = self.hcKalmanFilter {
                if resetKalmanFilter == true {
                    hcKalmanFilter.resetKalman(newStartLocation: currentLocation)
                    resetKalmanFilter = false
                } else {
                    
                    let kalmanLocation = hcKalmanFilter.processState(currentLocation: currentLocation)
                    
                    let distanceBetween: CLLocationDistance =
                        currentLocation.distance(from: initialLocation)
                    
                    let distanceDiff = String(format: "%.2f", distanceBetween)
                    
                    logExcSteps("Altitude: \(kalmanLocation.altitude)\nLocation Distance: \(distanceDiff)")
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function,"Location update failure with error : \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        notifyUserWith("Inside Gadgeon Smart Systems.")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        notifyUserWith("Outside Gadgeon Smart Systems.")
    }
}

extension MapViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension MapViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: logCellId, for: indexPath)
        cell.textLabel?.text = logs[indexPath.row]
        return cell
    }
}

private class LogViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .black
        self.selectionStyle = .none
        self.textLabel?.numberOfLines = 0
        self.textLabel?.textColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
