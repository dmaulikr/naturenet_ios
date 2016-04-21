//
//  SignInSignUpViewController.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 3/23/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class SignInSignUpViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate{
    
    var pageTitle :String!

    @IBOutlet var signInView: UIView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet var joinView: UIView!
    @IBOutlet weak var profileIconImageView: UIImageView!
    @IBOutlet weak var joinUsername: UITextField!
    @IBOutlet weak var joinPassword: UITextField!
    @IBOutlet weak var joinName: UITextField!
    @IBOutlet weak var joinEmail: UITextField!
    @IBOutlet weak var joinAffliation: UITextField!
   
    
   
    @IBAction func forgotPasswordButtonClicked(sender: UIButton) {
    }
    var tapGesture:UITapGestureRecognizer!
    
    var joinScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.view.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "double_down.png"), style: .Plain, target: self, action: #selector(self.dismissVC))
        navigationItem.leftBarButtonItem = barButtonItem
        //}
        
        self.navigationItem.title=pageTitle
        
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        //self.view.backgroundColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        //self.view.tintColor = UIColor.whiteColor()
        
        textFieldBorder(username)
        textFieldBorder(password)
        
        username.delegate = self
        password.delegate = self
                
        if(pageTitle == "Sign In")
        {
            signInView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-64, self.view.frame.size.width, self.view.frame.size.height)
            self.view.addSubview(signInView)
        }
        else if(pageTitle == "Join NatureNet")
        {
            addJoinScrollView()
        }
        

    }
    func addJoinScrollView()
    {
        if(joinScrollView == nil)
        {
            joinScrollView = UIScrollView()
        }
        joinScrollView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)
        joinScrollView.backgroundColor = UIColor.clearColor()
        joinScrollView.autoresizesSubviews = true
        joinScrollView.contentSize=CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+80)
        self.view.addSubview(joinScrollView)
        
        joinView.frame = CGRectMake(joinScrollView.frame.origin.x, joinScrollView.frame.origin.y, joinScrollView.frame.size.width, self.view.frame.size.height)
        joinScrollView.addSubview(joinView)
        
        textFieldBorder(joinUsername)
        textFieldBorder(joinPassword)
        textFieldBorder(joinName)
        textFieldBorder(joinEmail)
        textFieldBorder(joinAffliation)
        
        joinUsername.delegate = self
        joinPassword.delegate = self
        joinName.delegate = self
        joinEmail.delegate = self
        joinAffliation.delegate = self
        
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        joinScrollView.userInteractionEnabled = true
    }
    
    @IBAction func joinButtonClickedFronSignInView(sender: UIButton) {
    
        signInView.removeFromSuperview()
        addJoinScrollView()
        self.navigationItem.title="Join NatureNet"
    
    }
    func dismissKeyboard()
    {
        joinUsername.resignFirstResponder()
        joinPassword.resignFirstResponder()
        joinName.resignFirstResponder()
        joinEmail.resignFirstResponder()
        joinAffliation.resignFirstResponder()
        
        setViewToMoveUp(false,tempTF: nil)
    }
    func keyboardWillShow(notification: NSNotification) {
        if(joinScrollView != nil)
        {
            joinScrollView.addGestureRecognizer(tapGesture)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if(joinScrollView != nil)
        {
            joinScrollView.removeGestureRecognizer(tapGesture)
        }
    }
    func textFieldBorder(textField: UITextField!)
    {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0).CGColor

        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:  textField.frame.size.width, height: textField.frame.size.height)
        
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        if(joinScrollView != nil)
        {
            setViewToMoveUp(false,tempTF: textField)
        }
        return true;
    }
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool // return NO to disallow editing.
    {
        if(joinScrollView != nil)
        {
            if(textField == joinEmail || textField == joinAffliation || textField == joinName )
            {
                setViewToMoveUp(true,tempTF: textField)
            }
        }
        return true
    }
    func setViewToMoveUp(moveUp: Bool, tempTF: UITextField!)
    {
        
        if(joinScrollView != nil && tempTF != nil)
        {
            //UIView.beginAnimations(nil, context: nil)
            //UIView.setAnimationDuration(0.3)
            UIView.animateWithDuration(0.3, animations: {
                
                var tfRect: CGRect!
                tfRect=tempTF.frame
                
                if(moveUp)
                {
                    self.joinScrollView.setContentOffset(CGPointMake(0, tfRect.origin.y-tfRect.size.height*8), animated:true)
                }
                else
                {
                    self.joinScrollView.setContentOffset(CGPointMake(0, 0), animated:true)
                }

                
                }, completion: { finished in
                    
            })
            
        }
    }
    override func viewWillAppear(animated: Bool) {
        
        if(joinScrollView != nil)
        {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInSignUpViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInSignUpViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        }
        
        
    }
    override func viewWillDisappear(animated: Bool) {
        
        if(joinScrollView != nil)
        {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        }
        
    }
    
    func dismissVC(){
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {})
    }

//    // placeholder position
//    func textRectForBounds(bounds: CGRect) -> CGRect
//    {
//        return CGRectInset(bounds, 12, 0)
//    }
//    
//    // text position
//    func editingRectForBounds(bounds: CGRect) -> CGRect
//    {
//        return CGRectInset(bounds, 12, 0)
//    }
//    func placeholderRectForBounds(bounds: CGRect) -> CGRect
//    {
//        return CGRectInset(bounds, 12, 0)
//    }
    func connectTOFirebase()
    {
        
    }
    
    @IBAction func signInButtonClicked(sender: UIButton) {
        
        if(username.text != "" || password.text != "")
        {
        
            let ref = Firebase(url: FIREBASE_URL)
            ref.authUser(username.text, password: password.text,
                         withCompletionBlock: { error, authData in
                            if error != nil {
                                // There was an error logging in to this account
                                print("\(error)")
                                let alert = UIAlertController(title: "Alert", message:error.userInfo.description ,preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                                self.presentViewController(alert, animated: true, completion: nil)
                                
                            } else {
                                // We are now logged in
                                print("We are now logged in")
                                print(authData.providerData)
                                print(authData.uid)
                               
                                let endpoint = NSURL(string: USERS_URL+"\(authData.uid).json")
                                
                                //let endpoint = NSURL(string:"https://naturenet-testing.firebaseio.com/observations.json?orderBy='$key'&limitToFirst=4")
                                //var data = NSData(contentsOfURL: endpoint!)
                                print(endpoint)
                                
                                var userData:NSData? = nil
                                do {
                                    userData = try NSData(contentsOfURL: endpoint!, options: NSDataReadingOptions())
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
                                    //let userPublicData = json.objectForKey("public")! as! nsar
                                        //print(userPublicData)
//                                        for (key, value) in json {
//                                            print("\(key) -> \(value)")
//                                        }
                                        //print(json["public"]!["affliation"])
                                        
                                        //let userPublicData = json["public"] as! NSArray
                                        if(json != ""){
                                            
                                            let userAffiliation = json.objectForKey("affiliation")
                                            let userDisplayName = json.objectForKey("display_name")
                                            
                                            let userDefaults = NSUserDefaults.standardUserDefaults()
                                            userDefaults.setValue(userAffiliation, forKey: "userAffiliation")
                                            userDefaults.setValue(userDisplayName, forKey: "userDisplayName")
                                            userDefaults.setValue("true", forKey: "isSignedIn")
                                            userDefaults.setValue(authData.uid, forKey: "userID")
                                            userDefaults.setValue(self.username.text, forKey: "email")
                                            userDefaults.setValue(self.password.text, forKey: "password")
                                            
                                            self.dismissVC()
                                            
                                        }
                                        
                                    
                                        
                                        
                                    }catch let error as NSError {
                                        print("json error: \(error.localizedDescription)")
                                        let alert = UIAlertController(title: "Alert", message:error.localizedDescription ,preferredStyle: UIAlertControllerStyle.Alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                                        self.presentViewController(alert, animated: true, completion: nil)
                                    }

                                }
                                
                                
//                                Alamofire.request(.GET, "https://naturenet-testing.firebaseio.com/users/\(authData.uid).json")
//                                    .responseJSON { response in
//                                        print(response.request)  // original URL request
//                                        print(response.response) // URL response
//                                        print(response.data)     // server data
//                                        print(response.result)   // result of response serialization
//                                        
//                                        if let JSON = response.result.value {
//                                            print("JSON: \(JSON)")
//                                        }
//                                }
                                
                                
                            }
            })
        }
        else
        {
            let alert = UIAlertController(title: "Alert", message: "Please Enter All the Details", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func joinButtonClicked(sender: UIButton) {
        
        if(joinUsername.text != "" || joinPassword.text != "" || joinName.text != "" || joinEmail.text != "" || joinAffliation.text != "" )
        {
                        
            let myRootRef = Firebase(url:FIREBASE_URL)
            // Write data to Firebase
           
            myRootRef.createUser(joinEmail.text, password: joinPassword.text,
                                 withValueCompletionBlock: { error, result in
                                    if error != nil {
                                        // There was an error creating the account
                                        let alert = UIAlertController(title: "Alert", message:error.userInfo.description ,preferredStyle: UIAlertControllerStyle.Alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                                        self.presentViewController(alert, animated: true, completion: nil)
                                        print(error.userInfo.description)
                                        
                                    } else {
                                        let uid = result["uid"] as? String
                                        print("Successfully created user account with uid: \(uid)")
//                                        let alert = UIAlertController(title: "Alert", message:"Successfully created user account with uid: \(uid)" ,preferredStyle: UIAlertControllerStyle.Alert)
//                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//                                        self.presentViewController(alert, animated: true, completion: nil)
                                        let ref = Firebase(url: FIREBASE_URL+"users/")
                                        ref.authUser(self.joinEmail.text, password: self.joinPassword.text,
                                            withCompletionBlock: { error, authData in
                                                if error != nil {
                                                    
                                                }
                                                else
                                                {
                                                    print("Successfully logged in by user with uid: \(uid)")
                                                    let usersRef = ref.childByAppendingPath(uid)
                                                    //let usersPubReftoid = usersRef.childByAppendingPath("public")
                                                    let usersPub = ["id": uid as! AnyObject,"display_name": self.joinName.text as! AnyObject,"affiliation": self.joinAffliation.text as! AnyObject, "created_at": FirebaseServerValue.timestamp(),"updated_at": FirebaseServerValue.timestamp()]
                                                    usersRef.setValue(usersPub)
                                                    
                                                    //let usersPrivateReftoid = usersRef.childByAppendingPath("private")
                                                    //let usersPrivate = ["email": self.joinEmail.text as! AnyObject]
                                                    //usersRef.setValue(usersPub)
                                                    
                                                    let refPrivate = Firebase(url: FIREBASE_URL+"users-private/")
                                                    
                                                    
                                                                let usersPrivateRef = refPrivate.childByAppendingPath(uid)
                                                                
                                                                let usersConsentPrivate = ["required": true as AnyObject]
                                                                //let usersPubReftoid = usersRef.childByAppendingPath("public")
                                                                let usersPrivate = ["id": uid as! AnyObject,"consent": usersConsentPrivate as AnyObject, "created_at": FirebaseServerValue.timestamp(),"updated_at": FirebaseServerValue.timestamp()]
                                                                usersPrivateRef.setValue(usersPrivate)
                                                                
                                                                //let userConsent = usersPrivateRef.childByAppendingPath("consent")
                                                                //let usersConsentPrivate = ["required": true as AnyObject]
                                                                //userConsent.setValue(usersConsentPrivate)
                                                                
                                                                //let usersPrivateReftoid = usersRef.childByAppendingPath("private")
                                                                //let usersPrivate = ["email": self.joinEmail.text as! AnyObject]
                                                                //usersRef.setValue(usersPub)
                                                    
                                                                
                                                                //self.dismissVC()
                                                                
                                                    
                                                

                                                    
                                                    let userDefaults = NSUserDefaults.standardUserDefaults()
                                                    userDefaults.setValue(self.joinAffliation.text, forKey: "userAffiliation")
                                                    userDefaults.setValue(self.joinName.text, forKey: "userDisplayName")
                                                    userDefaults.setValue("true", forKey: "isSignedIn")
                                                    userDefaults.setValue(uid, forKey: "userID")
                                                    userDefaults.setValue(self.joinEmail.text, forKey: "email")
                                                    userDefaults.setValue(self.joinPassword.text, forKey: "password")
                                                    
                                                    self.dismissVC()

                                                }
                                        
                                            })
                                    }
            })
            
        }
        
        else
        {
            let alert = UIAlertController(title: "Alert", message: "Please Enter All the Details", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            print("Please Enter All the Details")

        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

//    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
//    switch action.style{
//    case .Default:
//    print("default")
//    
//    case .Cancel:
//    print("cancel")
//    
//    case .Destructive:
//    print("destructive")
//    }
//    }))
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
