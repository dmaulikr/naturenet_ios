//
//  ProjectsViewController.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 3/20/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import UIKit
import Firebase

class ProjectsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    let newObsAndDIView_projects = NewObsAndDIViewController()
    let cgVC_projects = CameraAndGalleryViewController()
    let diAndCVC_projects = DesignIdeasAndChallengesViewController()
    var projectKeys: NSMutableArray = []
    var projectDescriptionKeys: NSMutableArray = []
    var projectStatusKeys: NSMutableArray = []
    var projectIconKeys: NSMutableArray = []
    var projectIds: NSMutableArray = []
    var isfromObservationVC: Bool = false


    @IBOutlet weak var noProjectsIndicationLabel: UILabel!

    @IBOutlet weak var projectsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 290
            let barButtonItem = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .Plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            navigationItem.leftBarButtonItem = barButtonItem
        }

        self.navigationItem.title="Projects"
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]

        if (isfromObservationVC == true)
        {
            let barButtonItem = UIBarButtonItem(image: UIImage(named: "double_down.png"), style: .Plain, target: self, action: #selector(ProjectsViewController.dismissVC))
            navigationItem.leftBarButtonItem = barButtonItem
        }

        self.projectsTableView.delegate=self
        self.projectsTableView.dataSource=self

        //Registering custom cell
        self.projectsTableView.separatorColor = UIColor.grayColor()
        self.projectsTableView.tableFooterView = UIView(frame: CGRectZero)
        self.projectsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

        if (isfromObservationVC == false)
        {
            newObsAndDIView_projects.view.frame = CGRectMake(0 ,UIScreen.mainScreen().bounds.size.height-newObsAndDIView_projects.view.frame.size.height-8, UIScreen.mainScreen().bounds.size.width, newObsAndDIView_projects.view.frame.size.height)
            newObsAndDIView_projects.view.translatesAutoresizingMaskIntoConstraints = true
            newObsAndDIView_projects.view.center = CGPoint(x: view.bounds.midX, y: UIScreen.mainScreen().bounds.size.height - newObsAndDIView_projects.view.frame.size.height/2 - 8)
            newObsAndDIView_projects.view.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.None, UIViewAutoresizing.FlexibleBottomMargin]

            self.view.addSubview(newObsAndDIView_projects.view)
            newObsAndDIView_projects.camButton.addTarget(self, action: #selector(ProjectsViewController.openNewObsView_projects), forControlEvents: .TouchUpInside)
            newObsAndDIView_projects.designIdeaButton.addTarget(self, action: #selector(ProjectsViewController.openNewDesignView_projects), forControlEvents: .TouchUpInside)
        }
        
        getProjectsDetails()
    }
    
    func getProjectsDetails()
    {
        let activitiesRootRef = FIRDatabase.database().referenceWithPath("activities")
        
        activitiesRootRef.observeEventType(.Value, withBlock: { snapshot in
            print(activitiesRootRef)
            print(snapshot.value)
            
            self.projectKeys.removeAllObjects()
            self.projectDescriptionKeys.removeAllObjects()
            self.projectIconKeys.removeAllObjects()
            self.projectStatusKeys.removeAllObjects()
            self.projectIds.removeAllObjects()
            
            if !(snapshot.value is NSNull)
            {
                let valuesArray = snapshot.value!.allValues as NSArray
                var sortedSnapshot = valuesArray.sort({ $0.objectForKey("latest_contribution") as? Int ?? 0 > $1.objectForKey("latest_contribution") as? Int ?? 0})
                
                print(sortedSnapshot)
                
                for j in 0 ..< sortedSnapshot.count
                {
                    let activityDictionary = sortedSnapshot[j] as! NSDictionary
                    
                    if(activityDictionary.objectForKey("name") != nil)
                    {
                        self.projectKeys.addObject(activityDictionary.objectForKey("name")!)
                    }
                    else
                    {
                        self.projectKeys.addObject("")
                    }
                    
                    if (activityDictionary.objectForKey("description") != nil)
                    {
                        self.projectDescriptionKeys.addObject(activityDictionary.objectForKey("description")!)
                    }
                    else
                    {
                        self.projectDescriptionKeys.addObject("")
                    }
                    
                    if(activityDictionary.objectForKey("icon_url") != nil)
                    {
                        let iconUrlString = activityDictionary.objectForKey("icon_url") as! String
                        let newiconUrlString = iconUrlString.stringByReplacingOccurrencesOfString("upload", withString: "upload/t_ios-thumbnail", options: NSStringCompareOptions.LiteralSearch, range: nil)
                        self.projectIconKeys.addObject(newiconUrlString)
                    }
                    else
                    {
                        self.projectIconKeys.addObject("")
                    }
                    
                    if(activityDictionary.objectForKey("status") != nil)
                    {
                        self.projectStatusKeys.addObject(activityDictionary.objectForKey("status")!)
                    }
                    else
                    {
                        self.projectStatusKeys.addObject("")
                    }

                    if(activityDictionary.objectForKey("id") != nil)
                    {
                        self.projectIds.addObject(activityDictionary.objectForKey("id")!)
                    }
                    else
                    {
                        self.projectIds.addObject("")
                    }
                }
                
                self.projectsTableView.reloadData()
            }
        }, withCancelBlock: { error in
            print(error.description)
            let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        })

    }
    
    func dismissVC()
    {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {})
    }

    func openNewObsView_projects()
    {
        self.addChildViewController(cgVC_projects)
        cgVC_projects.view.frame = CGRectMake(0, self.view.frame.size.height - cgVC_projects.view.frame.size.height+68, cgVC_projects.view.frame.size.width, cgVC_projects.view.frame.size.height)
        cgVC_projects.closeButton.addTarget(self, action: #selector(ProjectsViewController.closeCamAndGalleryView), forControlEvents: .TouchUpInside)
        self.view.addSubview(cgVC_projects.view)
        
        UIView.animateWithDuration(0.3, animations: {
            self.cgVC_projects.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height - self.cgVC_projects.view.frame.size.height+68, UIScreen.mainScreen().bounds.size.width, self.cgVC_projects.view.frame.size.height)
            self.cgVC_projects.view.translatesAutoresizingMaskIntoConstraints = true
            self.cgVC_projects.view.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.None, UIViewAutoresizing.FlexibleBottomMargin]
        }) { (isComplete) in
            self.cgVC_projects.didMoveToParentViewController(self)
        }
    }

    func openNewDesignView_projects()
    {
        self.addChildViewController(diAndCVC_projects)
        diAndCVC_projects.view.frame = CGRectMake(0, self.view.frame.size.height - diAndCVC_projects.view.frame.size.height+68, diAndCVC_projects.view.frame.size.width, diAndCVC_projects.view.frame.size.height)
        diAndCVC_projects.closeButton.addTarget(self, action: #selector(ProjectsViewController.closeDiAndChallengesView), forControlEvents: .TouchUpInside)

        self.view.addSubview(diAndCVC_projects.view)
        UIView.animateWithDuration(0.3, animations: {
            self.diAndCVC_projects.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height - self.diAndCVC_projects.view.frame.size.height+68, UIScreen.mainScreen().bounds.size.width, self.diAndCVC_projects.view.frame.size.height)
            self.diAndCVC_projects.view.translatesAutoresizingMaskIntoConstraints = true
            self.diAndCVC_projects.view.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.None, UIViewAutoresizing.FlexibleBottomMargin]
        }) { (isComplete) in
            self.diAndCVC_projects.didMoveToParentViewController(self)
        }
    }

    func closeCamAndGalleryView()
    {
        cgVC_projects.view.removeFromSuperview()
        cgVC_projects.removeFromParentViewController()
    }

    func closeDiAndChallengesView()
    {
        diAndCVC_projects.view.removeFromSuperview()
        diAndCVC_projects.removeFromParentViewController()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projectKeys.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel?.text = projectKeys[indexPath.row] as? String
        let cellImageView = UIImageView()
        cellImageView.contentMode = UIViewContentMode.ScaleAspectFit
        cellImageView.frame = CGRectMake(10, 2, 40, 40)

        if let projectIconUrl  = NSURL(string: projectIconKeys[indexPath.row] as! String)
        {
            cellImageView.kf_setImageWithURL(projectIconUrl, placeholderImage: UIImage(named: "project.png"))
        }

        cellImageView.clipsToBounds = true
        cell.contentView.addSubview(cellImageView)
        cell.textLabel?.textAlignment = NSTextAlignment.Center

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if (isfromObservationVC == false)
        {
            let projectDetailVC = ProjectDetailViewController()
            projectDetailVC.projectTitle = projectKeys[indexPath.row] as! String
            projectDetailVC.projectDescription = projectDescriptionKeys[indexPath.row] as! String
            projectDetailVC.projectStatus = projectStatusKeys[indexPath.row] as! String
            projectDetailVC.projectIcon = projectIconKeys[indexPath.row] as! String
            projectDetailVC.projectIdFromProjectVC = projectIds[indexPath.row] as! String
            self.navigationController?.pushViewController(projectDetailVC, animated: true)
        }
        else
        {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setValue(projectKeys[indexPath.row] as! String, forKey: "ProjectName")
            userDefaults.setValue(projectIds[indexPath.row] as! String, forKey: "ActivityID")
            self.dismissVC()
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 50
    }

    func imageWithImage(image:UIImage,scaledToSize newSize:CGSize)->UIImage{
        UIGraphicsBeginImageContext( newSize )
        image.drawInRect(CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage.imageWithRenderingMode(.AlwaysTemplate)
    }
}
