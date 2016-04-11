//
//  MapViewController.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 3/17/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase


class MapViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate{
    
    @IBOutlet var mapAnnotationClickView: UIView!
    @IBOutlet weak var exploreView: UIView!
    @IBOutlet weak var mapAnnotationClickSubView: UIView!
    let locationManager = CLLocationManager()
    @IBOutlet var mapTypeView: UIView!
    
    @IBOutlet weak var observationImageView: UIImageView!
    @IBOutlet weak var observerDisplayName: UILabel!
    @IBOutlet weak var observerAffiliation: UILabel!
    @IBOutlet weak var observerAvatarImageView: UIImageView!
    @IBOutlet weak var observationTextLabel: UILabel!
    var count = 0
    var observationImagesArray : NSMutableArray = []
    var observationTextArray : NSMutableArray = []
    var observerIds : NSMutableArray = []
    
    var observerAvatarUrlString : String = ""
    var observervationUrlString : String = ""
    
    let mapView = MKMapView(frame: UIScreen.mainScreen().bounds)
    var tempAnnotationView : MKAnnotationView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.bringSubviewToFront(exploreView);
        // Do any additional setup after loading the view.
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 290
           
            let barButtonItem = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .Plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            
            navigationItem.leftBarButtonItem = barButtonItem
            
        }
        
        let rightbarButtonItem = UIBarButtonItem(image: UIImage(named: "more.png"), style: .Plain, target: self, action: #selector(MapViewController.mapTypes))
        navigationItem.rightBarButtonItem = rightbarButtonItem
        
        
        self.navigationItem.title="NatureNet"
        
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        exploreView.backgroundColor=UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        exploreView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MapViewController.tappedView)))
        exploreView.userInteractionEnabled = true

        mapView.frame = CGRectMake(0 , 0, self.view.frame.width, self.view.frame.height-self.exploreView.frame.height)
        mapView.delegate = self
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MapViewController.mapViewTapped)))
        mapView.userInteractionEnabled = true
        //mapView.showsUserLocation = true
        mapView.mapType = .Satellite
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //mapViewCoordinate()
        
        
        self.view.addSubview(mapView)
        
        mapAnnotationClickView.frame = CGRectMake(0,self.view.frame.size.height-mapAnnotationClickView.frame.size.height, mapAnnotationClickView.frame.size.width, mapAnnotationClickView.frame.size.height)
        mapAnnotationClickSubView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MapViewController.mapAnnotationClickSubViewtapped)))
        mapAnnotationClickSubView.userInteractionEnabled = true
        
                
        //declare this property where it won't go out of scope relative to your listener
        var reachability: Reachability?
        
        //declare this inside of viewWillAppear
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.reachabilityChanged(_:)),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability?.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
    }
    
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            //                if reachability.isReachableViaWiFi() {
            //                    print("Reachable via WiFi")
            //                } else {
            //                    print("Reachable via Cellular")
            //                }
            dispatch_async(dispatch_get_main_queue(), {
                // code here
                self.getObservations()
            })
            
        } else {
            print("Network not reachable")
            let alert = UIAlertController(title: "Alert", message:"Please Check your Internet Connection" ,preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func getObservations()
    {
        
        let observationUrl = NSURL(string: OBSERVATIONS_URL)
        
        var userData:NSData? = nil
        do {
            userData = try NSData(contentsOfURL: observationUrl!, options: NSDataReadingOptions())
            //print(userData)
        }
        catch {
            print("Handle \(error) here")
        }
        
        if let data = userData {
            // Convert data to JSON here
            do{
                let json: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! NSDictionary
                
                print(json)
                
                for i in 0 ..< json.count
                {
                    //print(i)
                    let observationData = json.allValues[i] as! NSDictionary
                    let latAndLongs = observationData.objectForKey("l") as! NSArray
                    print(observationData)
                    let observationImageAndText = observationData.objectForKey("data") as! NSDictionary
                    print(latAndLongs[0])
                    print(latAndLongs[1])
                    print(observationImageAndText["image"])
                    observationImagesArray.addObject(observationImageAndText["image"]!)
                    
                    print(observationImageAndText["text"])
                    observationTextArray.addObject(observationImageAndText["text"]!)
                    
                    let observerId = observationData.objectForKey("observer") as! String
                    //print(observerId)
                    observerIds.addObject(observerId)
                    
                    let annotationLatAndLong = CLLocation(latitude: latAndLongs[0].doubleValue, longitude: latAndLongs[1].doubleValue)
                    
                    mapViewCoordinate(annotationLatAndLong, tagForAnnotation: i)
                }

                //print(observationImagesArray)

            }
            catch let error as NSError {
                print("json error: \(error.localizedDescription)")
                let alert = UIAlertController(title: "Alert", message:error.localizedDescription ,preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }

            
        }

    }
    func mapTypes()
    {
        mapTypeView.frame = CGRectMake(self.view.frame.size.width - mapTypeView.frame.size.width-mapTypeView.frame.size.width/12,64, mapTypeView.frame.size.width, mapTypeView.frame.size.height)
        //mapTypeView.layer.cornerRadius = 8.0
        //mapTypeView.clipsToBounds = true
        if(count%2 == 0)
        {
            self.view.addSubview(mapTypeView)
        }
        else
        {
            mapTypeView.removeFromSuperview()
        }
        count += 1
        
    }
    @IBAction func mapTypeStandard(sender: UIButton) {
        
        mapView.mapType = .Standard
        
    }
    @IBAction func mapTypeSatellite(sender: UIButton) {
        
        mapView.mapType = .Satellite
        
    }
    func mapViewTapped()
    {
        if let mapTypeViewWithTag = self.view.viewWithTag(9) {
            mapTypeViewWithTag.removeFromSuperview()
            count += 1
        }
        if let exploreViewWithTag = self.view.viewWithTag(8) {
            exploreViewWithTag.removeFromSuperview()
            
        }
    }
    func mapViewCoordinate(annotationLocation: CLLocation, tagForAnnotation : Int)
    {
        let initialLocation = CLLocation(latitude: annotationLocation.coordinate.latitude, longitude: annotationLocation.coordinate.longitude)
        
        let regionRadius: CLLocationDistance = 10000
        func centerMapOnLocation(location: CLLocation) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                regionRadius * 4.0, regionRadius * 4.0)
            mapView.setRegion(coordinateRegion, animated: true)
        }
        
        centerMapOnLocation(initialLocation)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(initialLocation.coordinate.latitude, initialLocation.coordinate.longitude)
        annotation.title = String(tagForAnnotation)
        //annotation.subtitle = "This is the location !!!"
        mapView.addAnnotation(annotation)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tappedView(){
        
        let eVC = ExploreViewController() //change this to your class name
        eVC.exploreObservationsImagesArray = observationImagesArray
        eVC.observerIdsfromMapView = observerIds
        eVC.observationTextArray = observationTextArray
        let exploreNavVC = UINavigationController()
        exploreNavVC.viewControllers = [eVC]
        self.presentViewController(exploreNavVC, animated: true, completion: nil)
        
    }
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "MyPin"
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        //let detailButton: UIButton = UIButton(type: UIButtonType.DetailDisclosure)
        
        // Reuse the annotation if possible
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        let str :String? = annotation.title!
        let tag: Int? = Int(str!)
    
        
        if annotationView == nil
        {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "MyPin")
            annotationView!.canShowCallout = false
            //annotationView!.image = UIImage(named: "marker.png")
            annotationView!.contentMode = UIViewContentMode.ScaleAspectFit
            annotationView?.tag = tag!
            //annotationView!.rightCalloutAccessoryView = detailButton
            
            let annotationImageView = UIImageView(image: UIImage(named:"marker.png"))
            
            var annotationImageRect = annotationImageView.frame as CGRect
            annotationImageRect.size.height = 44
            annotationImageRect.size.width = 44
            
            annotationImageView.frame = annotationImageRect
            annotationView?.frame = annotationImageRect
            
            annotationView?.addSubview(annotationImageView)
            
        }
        else
        {
            annotationView!.annotation = annotation
        }
        
        
        return annotationView
    }
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        if let annotation = view.annotation as? MKPointAnnotation {
//            mapView.removeAnnotation(annotation)
//        }
    }
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView)
    {
        print("annotation")
        //view.hidden=true
//        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
//            view.frame = CGRectMake(view.frame.origin.x,view.frame.origin.y, view.frame.width * 1.5, self.view.frame.height * 0.1)
        self.view.addSubview(self.mapAnnotationClickView)
//            }, completion: nil)
//        self.mapViewCoordinate()
        //print(view.tag)
        
        observationTextLabel.text = (observationTextArray[view.tag] as! String)
        
        if let url  = NSURL(string: observationImagesArray[view.tag] as! String),
            data = NSData(contentsOfURL: url)
        {
            observationImageView.image = UIImage(data: data)
            observervationUrlString = observationImagesArray[view.tag] as! String
        }
        
        
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                //                if reachability.isReachableViaWiFi() {
                //                    print("Reachable via WiFi")
                //                } else {
                //                    print("Reachable via Cellular")
                //                }
                
           
        let url = NSURL(string: USERS_URL+"\(self.observerIds[view.tag]).json")
        var userData:NSData? = nil
        do {
            userData = try NSData(contentsOfURL: url!, options: NSDataReadingOptions())
            print(userData)
        }
        catch {
            print("Handle \(error) here")
        }
        
        if let data = userData {
            // Convert data to JSON here
            do{
                let json: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! NSDictionary
                print(json)
                if let observerData = json["public"] as? NSDictionary {
                    
                    //print(observerData.objectForKey("affiliation"))
                    //print(observerData.objectForKey("display_name"))
                    //print(observerData)
                    if((observerData.objectForKey("affiliation")) != nil)
                    {
                        let observerAffiliationString = observerData.objectForKey("affiliation") as! String
                        self.observerAffiliation.text = observerAffiliationString
                        //observerAffiliationsArray.addObject(observerAffiliationString)
                        print(observerAffiliationString)
                    }
                    else
                    {
                        self.observerAffiliation.text = ""
                    }
                    
                    if((observerData.objectForKey("display_name")) != nil)
                    {
                        let observerDisplayNameString = observerData.objectForKey("display_name") as! String
                        self.observerDisplayName.text = observerDisplayNameString
                        //observerNamesArray.addObject(observerDisplayNameString)
                    }
                    else
                    {
                        self.observerDisplayName.text = ""
                    }
                    
                    //print(observerAffiliation)
                    //print(observerDisplayName)
                    if((observerData.objectForKey("avatar")) != nil)
                    {
                        let observerAvatar = observerData.objectForKey("avatar")
                        if let observerAvatarUrl  = NSURL(string: observerAvatar as! String),
                            observerAvatarData = NSData(contentsOfURL: observerAvatarUrl)
                        {
                            self.observerAvatarImageView.image = UIImage(data: observerAvatarData)
                            //observerAvatarsArray.addObject(observerAvatar!)
                            self.observerAvatarUrlString = observerAvatar as! String
                        }
                    }
                    else
                    {
                        self.observerAvatarImageView.image = UIImage(named:"user.png")
                        //observerAvatarsArray.addObject(NSBundle.mainBundle().URLForResource("user", withExtension: "png")!)
                        
                    }
                    
                }
                
            }catch let error as NSError {
                print("json error: \(error.localizedDescription)")
                let alert = UIAlertController(title: "Alert", message:error.localizedDescription ,preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        }
                
            }
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                
                let alert = UIAlertController(title: "Alert", message:"Please Check your Internet Connection" ,preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func mapAnnotationClickSubViewtapped(){
        
        let detailedObservationVC = DetailedObservationViewController()
        detailedObservationVC.observerImageUrl = observerAvatarUrlString
        detailedObservationVC.observerDisplayName = observerDisplayName.text!
        detailedObservationVC.observerAffiliation = observerAffiliation.text!
        detailedObservationVC.observationImageUrl = observervationUrlString
        detailedObservationVC.observationText = observationTextLabel.text!
        self.navigationController?.pushViewController(detailedObservationVC, animated: true)
        
    }
}
