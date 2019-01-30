//
//  InvoiceViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/27/19.
//  Copyright © 2019 Nick. All rights reserved.
//

//  Edited for safeView


import Foundation
import UIKit
import Alamofire
import SwiftyJSON



/*
protocol EditContractDelegate{
    func updateContract(_contract:Contract)
    func updateContract(_contractItem:ContractItem)
    func updateContract(_contract:Contract, _status:String)
    //func updateContractLead(_lead:Lead)
    func suggestStatusChange(_emailCount:Int)
}


*/

//class InvoiceViewController: UIViewController{
class InvoiceViewController: UIViewController, UITextFieldDelegate,  UITableViewDelegate, UITableViewDataSource, StackDelegate{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    var json:JSON!
    var invoice:Invoice!
    //var delegate:ContractListDelegate!
    
   // var editLeadDelegate:EditLeadDelegate!
   // var sortEditsMade:Bool = false
    
    var stackController:StackController!
    
    var optionsButton:UIBarButtonItem!
    //var editsMade:Bool = false
    var statusIcon:UIImageView = UIImageView()
   // var statusTxtField:PaddedTextField!
    //var statusPicker: Picker!
    var statusArray = ["Un-Paid","Paid"]
    var statusValue: String!
    //var statusValueToUpdate: String!
    var customerBtn: Button!
    var infoView: UIView! = UIView()
    
    var titleLbl:GreyLabel!
    var titleValue:GreyLabel!
    
    var chargeTypeLbl:GreyLabel!
    var chargeType:GreyLabel!
    
    var chargeTypeArray = ["NC - No Charge", "FL - Flat Priced", "T & M - Time & Material"]
    
    
    var salesRepLbl:GreyLabel!
    var salesRep:GreyLabel!
    
    //var notesLbl:GreyLabel!
    //var notesView:UITextView!
    var itemsLbl:GreyLabel!
    var items: JSON!
    var itemsArray:[InvoiceItem] = []
    //var itemIDArray:[String] = []
    //var signatureArray:[Signature] = []
    //var itemRowToEdit:Int?
    
    //var customerSignature:Signature!
    var itemsTableView: TableView!
    
    //var signBtn:Button = Button(titleText: "Sign")
    //var signatureImageContainerView:UIView!
    //var signatureImage:UIImage!
    //var signatureImageView:UIImageView!
    
    //var tapBtn:UIButton!
    
    var subLbl:GreyLabel!
    var subValueLbl:GreyLabel!
    var taxLbl:GreyLabel!
    var taxValueLbl:GreyLabel!
    
    var totalLbl:GreyLabel!
    
    
    //var leadTasksWaiting:String?
    
    //var employeeSignature:Bool = false
    
    
    //var contractItemViewController:ContractItemViewController?
    
    //var lead:Lead?
    
    init(_invoice:Invoice){
        super.init(nibName:nil,bundle:nil)
        
        self.invoice = _invoice
        //print("contract init - total = \(contract.total)")
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload")
        view.backgroundColor = layoutVars.backgroundColor
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(InvoiceViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        showLoadingScreen()
    }
    
    
    func showLoadingScreen(){
        title = "Loading..."
        getInvoice()
    }
    
    
    //sends request for lead tasks
    func getInvoice() {
        //print(" GetContract  Contract Id \(self.contract.ID)")
        
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        //reset task array
        self.itemsArray = []
        let parameters:[String:String]
        parameters = ["invoiceID": self.invoice.ID]
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/invoice.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("invoice response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    print("JSON: \(json)")
                    //self.json = JSON(json)
                    
                    self.json = JSON(json)["invoice"]
                    
                    self.parseJSON()
                }
                print(" dismissIndicator")
                self.indicator.dismissIndicator()
        }
    }
    
    
    func parseJSON(){
        
        //primary info
        
        /*
        self.contract.subTotal =  self.json["contract"]["subTotal"].stringValue
        self.contract.taxTotal =  self.json["contract"]["taxTotal"].stringValue
        self.contract.total =  self.json["contract"]["total"].stringValue
        self.contract.terms = self.json["contract"]["termsDescription"].stringValue
        
        */
        self.invoice = Invoice(_ID: self.json["ID"].stringValue, _date: self.json["invoiceDate"].stringValue, _customer: self.json["customer"].stringValue, _customerName: self.json["custName"].stringValue, _totalPrice: self.layoutVars.numberAsCurrency(_number: self.json["total"].stringValue) , _paid: self.json["paid"].stringValue)
        
        self.invoice.title = self.json["title"].stringValue
        self.invoice.chargeType = self.json["chargeType"].stringValue
        self.invoice.repName = self.json["repName"].stringValue
        self.invoice.subTotal = self.layoutVars.numberAsCurrency(_number:self.json["subTotal"].stringValue)
        self.invoice.taxTotal = self.layoutVars.numberAsCurrency(_number:self.json["taxTotal"].stringValue)
        
        //items
        let itemCount = self.json["items"].count
        for i in 0 ..< itemCount {
            
            
          
            
            
            let item = InvoiceItem(_ID: self.json["items"][i]["ID"].stringValue, _chargeType: self.json["items"][i]["charge"].stringValue, _invoiceID: self.invoice.ID, _servicedDate: self.json["items"][i]["servicedDate"].stringValue, _itemID: self.json["items"][i]["itemID"].stringValue, _name: self.json["items"][i]["item"].stringValue, _price: self.json["items"][i]["price"].stringValue, _qty: self.json["items"][i]["act"].stringValue, _totalImages: "0", _total: self.json["items"][i]["total"].stringValue, _type: self.json["items"][i]["type"].stringValue, _taxCode: self.json["items"][i]["taxCode"].stringValue, _hideUnits: self.json["items"][i]["hideUnits"].stringValue, _custDescription: self.json["items"][i]["custDesc"].stringValue)
             
            
            
            
           
            
            self.itemsArray.append(item)
            
            
        }
        
        /*
        self.itemIDArray = []
        for item in itemsArray{
            let ID = item.ID!
            self.itemIDArray.append(ID)
        }
        */
    
        self.layoutViews()
    }
    
    
    func layoutViews(){
        print("layout views")
        title =  "Invoice #" + self.invoice.ID
        
        optionsButton = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(InvoiceViewController.displayInvoiceOptions))
        navigationItem.rightBarButtonItem = optionsButton
        
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        if(self.infoView != nil){
            self.infoView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        
        stackController = StackController()
        stackController.delegate = self
        stackController.getStack(_type:3,_ID:self.invoice.ID)
        safeContainer.addSubview(stackController)
        
        
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        safeContainer.addSubview(statusIcon)
        setStatus(status: invoice.paid)
        
       
        self.customerBtn = Button(titleText: "\(self.invoice.customerName!)")
        self.customerBtn.contentHorizontalAlignment = .left
        let custIcon:UIImageView = UIImageView()
        custIcon.backgroundColor = UIColor.clear
        custIcon.contentMode = .scaleAspectFill
        custIcon.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        let custImg = UIImage(named:"custIcon.png")
        custIcon.image = custImg
        self.customerBtn.addSubview(custIcon)
        self.customerBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 10)
        self.customerBtn.addTarget(self, action: #selector(self.showCustInfo), for: UIControl.Event.touchUpInside)
        
        safeContainer.addSubview(customerBtn)
        
        // Info Window
        self.infoView.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.backgroundColor = UIColor(hex:0xFFFFFc, op: 0.8)
        self.infoView.layer.borderWidth = 1
        self.infoView.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        self.infoView.layer.cornerRadius = 4.0
        safeContainer.addSubview(infoView)
        
        //date
        self.titleLbl = GreyLabel()
        self.titleLbl.text = "Title:"
        self.titleLbl.textAlignment = .left
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(titleLbl)
        
        self.titleValue = GreyLabel()
        if self.invoice.title != nil{
            self.titleValue.text = self.invoice.title!
        }
        self.titleValue.font = layoutVars.labelBoldFont
        self.titleValue.textAlignment = .left
        self.titleValue.text = self.invoice.title!
        self.titleValue.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(titleValue)
        
        //charge type
        self.chargeTypeLbl = GreyLabel()
        self.chargeTypeLbl.text = "Charge Type:"
        self.chargeTypeLbl.textAlignment = .left
        self.chargeTypeLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(chargeTypeLbl)
        
        self.chargeType = GreyLabel()
        if self.invoice.chargeType != ""{
            self.chargeType.text = self.chargeTypeArray[Int(self.invoice.chargeType!)! - 1]

        }
        self.chargeType.font = layoutVars.labelBoldFont
        self.chargeType.textAlignment = .left
        self.chargeType.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(chargeType)
        
        //sales rep
        self.salesRepLbl = GreyLabel()
        self.salesRepLbl.text = "Sales Rep:"
        self.salesRepLbl.textAlignment = .left
        self.salesRepLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(salesRepLbl)
        
        self.salesRep = GreyLabel()
        if self.invoice.repName != nil{
            self.salesRep.text = self.invoice.repName
        }
        self.salesRep.font = layoutVars.labelBoldFont
        self.salesRep.textAlignment = .left
        self.salesRep.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(salesRep)
        
        
        
        
        //items
        self.itemsLbl = GreyLabel()
        self.itemsLbl.text = "Items:"
        self.itemsLbl.textAlignment = .left
        self.itemsLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(itemsLbl)
        
        self.itemsTableView  =   TableView()
        self.itemsTableView.autoresizesSubviews = true
        self.itemsTableView.delegate  =  self
        self.itemsTableView.dataSource  =  self
        self.itemsTableView.layer.cornerRadius = 4
        self.itemsTableView.rowHeight = 90
        self.itemsTableView.register(InvoiceItemTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.itemsTableView.rowHeight = UITableView.automaticDimension
        self.itemsTableView.estimatedRowHeight = 60
        
        
        safeContainer.addSubview(self.itemsTableView)
        
        
        //subTotal
        self.subLbl = GreyLabel()
        self.subLbl.text =  "Subtotal:"
        self.subLbl.textAlignment = .right
        self.subLbl.font = layoutVars.extraSmallFont
        self.subLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(subLbl)
        
        self.subValueLbl = GreyLabel()
        self.subValueLbl.text =  self.invoice.subTotal!
        self.subValueLbl.textAlignment = .right
        self.subValueLbl.font = layoutVars.extraSmallFont
        self.subValueLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(subValueLbl)
        
        //taxTotal
        self.taxLbl = GreyLabel()
        self.taxLbl.text =  "Sales Tax:"
        self.taxLbl.textAlignment = .right
        self.taxLbl.font = layoutVars.extraSmallFont
        self.taxLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(taxLbl)
        
        self.taxValueLbl = GreyLabel()
        self.taxValueLbl.text =  self.invoice.taxTotal!
        self.taxValueLbl.textAlignment = .right
        self.taxValueLbl.font = layoutVars.extraSmallFont
        self.taxValueLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(taxValueLbl)
        
        
        
        //total
        self.totalLbl = GreyLabel()
        self.totalLbl.text =  self.invoice.totalPrice!
        self.totalLbl.textAlignment = .right
        self.totalLbl.font = layoutVars.largeFont
        self.totalLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(totalLbl)
        
        
        
       
       
        
       
        /////////  Auto Layout   //////////////////////////////////////
        
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30, "nameWidth": layoutVars.fullWidth - 150, "halfWidth": layoutVars.halfWidth] as [String:Any]
        
        //main views
        let viewsDictionary = [
            "stackController":self.stackController,
            "statusIcon":self.statusIcon,
            "customerBtn":self.customerBtn,
            "info":self.infoView,
            "itemsLbl":self.itemsLbl,
            "table":self.itemsTableView,
            "subLbl":self.subLbl,
            "subValueLbl":self.subValueLbl,
            "taxLbl":self.taxLbl,
            "taxValueLbl":self.taxValueLbl,
            "totalLbl":self.totalLbl
        
            ] as [String:AnyObject]
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackController]|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[statusIcon(40)]-[customerBtn]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[info]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[itemsLbl]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[table]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[subLbl]-[subValueLbl]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[taxLbl]-[taxValueLbl]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[totalLbl(200)]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
       
            
        
        
       // safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackController(40)]-[customerBtn(40)]-[info(90)]-[itemsLbl(22)][table]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackController(40)]-[statusIcon(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackController(40)]-[customerBtn(40)]-[info(85)]-[itemsLbl(22)][table]-[subLbl(15)]-4-[taxLbl(15)]-4-[totalLbl(35)]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
         safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackController(40)]-[customerBtn(40)]-[info(85)]-[itemsLbl(22)][table]-[subValueLbl(15)]-4-[taxValueLbl(15)]-4-[totalLbl(35)]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
       
       
        
        
        //auto layout group
        let infoDictionary = [
            "titleLbl":self.titleLbl,
            "title":self.titleValue,
            "chargeTypeLbl":self.chargeTypeLbl,
            "chargeType":self.chargeType,
            "salesRepLbl":self.salesRepLbl,
            "salesRep":self.salesRep
            ] as [String:AnyObject]
        
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLbl]-[title]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[chargeTypeLbl]-[chargeType]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[salesRepLbl]-[salesRep]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        
        
       // self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[notesLbl]-|", options: NSLayoutConstraint.FormatOptions.alignAllTop, metrics: metricsDictionary, views: infoDictionary))
        //self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[notes]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLbl(22)][chargeTypeLbl(22)][salesRepLbl(22)]", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[title(22)][chargeType(22)][salesRep(22)]", options: [], metrics: metricsDictionary, views: infoDictionary))
        
        
    }
    
    
    /*
    func newContractMessage(){
        //simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Add Items", _message: "You should add items to this contract.")
        
        
        let alertController = UIAlertController(title: "Add Items?", message: "This contract has no items.  Add items now?", preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "Not Now", style: UIAlertAction.Style.destructive) {
            (result : UIAlertAction) -> Void in
            print("No")
            return
        }
        
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            print("Yes")
            
            self.addItem()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        
    }
    */
    
    @objc func showCustInfo() {
        ////print("SHOW CUST INFO")
        let customerViewController = CustomerViewController(_customerID: self.invoice.customer!,_customerName: self.invoice.customerName)
        
        navigationController?.pushViewController(customerViewController, animated: false )
    }
    
    func removeViews(){
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
  
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var count:Int!
        
        count = self.itemsArray.count
        
        
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:InvoiceItemTableViewCell = itemsTableView.dequeueReusableCell(withIdentifier: "cell") as! InvoiceItemTableViewCell
        
        
        cell.invoiceItem = self.itemsArray[indexPath.row]
        cell.layoutViews()
        
        
        
        return cell;
    }
    
   
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    @objc func displayInvoiceOptions(){
        print("display Options")
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
            
            let actionSheet = UIAlertController(title: "Invoice Options", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            actionSheet.view.backgroundColor = UIColor.white
            actionSheet.view.layer.cornerRadius = 5;
            
            actionSheet.addAction(UIAlertAction(title: "Send Invoice", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                print("send invoice")
                self.sendInvoice()
            }))
            
            
            
            
           
            
            
            
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (alert:UIAlertAction!) -> Void in
            }))
            
            
            
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                //self.present(actionSheet, animated: true, completion: nil)
                layoutVars.getTopController().present(actionSheet, animated: true, completion: nil)
                break
            // It's an iPhone
            case .pad:
                let nav = UINavigationController(rootViewController: actionSheet)
                nav.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = nav.popoverPresentationController as UIPopoverPresentationController?
                actionSheet.preferredContentSize = CGSize(width: 500.0, height: 600.0)
                popover?.sourceView = self.view
                popover?.sourceRect = CGRect(x: 100.0, y: 100.0, width: 0, height: 0)
                
                //self.present(nav, animated: true, completion: nil)
                layoutVars.getTopController().present(nav, animated: true, completion: nil)
                break
            // It's an iPad
            case .unspecified:
                break
            default:
                //self.present(actionSheet, animated: true, completion: nil)
                layoutVars.getTopController().present(actionSheet, animated: true, completion: nil)
                break
                
                // Uh, oh! What could it be?
            }
        }
        
        
    }
    
    
    
    
   
    
    
    @objc func sendInvoice(){
        
        let emailViewController:EmailViewController = EmailViewController(_customerID: self.invoice.customer!, _customerName: self.invoice.customerName, _type: "1", _docID: self.invoice.ID)
        //emailViewController.contractDelegate = self
        navigationController?.pushViewController(emailViewController, animated: false )
        
    }
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This is called to remove the first responder for the text field.
    func resign() {
        self.resignFirstResponder()
    }
    
    // This triggers the textFieldDidEndEditing method that has the textField within it.
    //  This then triggers the resign() method to remove the keyboard.
    //  We use this in the "done" button action.
    func endEditingNow(){
        self.view.endEditing(true)
    }
    
    // What to do when a user finishes editting
    private func textFieldDidEndEditing(textField: UITextField) {
        resign()
    }
    
    
    func setStatus(status: String) {
        print("set status \(status)")
        switch (status) {
        case "0":
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            break;
        case "1":
            let statusImg = UIImage(named:"doneStatus.png")
            statusIcon.image = statusImg
            break;
        
        default:
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            break;
        }
    }
    
    
    
    
    
    
    
    
   
    
    
    
    //Stack Delegates
    func displayAlert(_title: String) {
        self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: _title, _message: "")
    }
    
    
    func newLeadView(_lead:Lead){
        
        let leadViewController:LeadViewController = LeadViewController(_lead: _lead)
        //leadViewController
        self.navigationController?.pushViewController(leadViewController, animated: false )
        
    }
    
    
    func newContractView(_contract:Contract){
        
        let contractViewController:ContractViewController = ContractViewController(_contract: _contract)
        //contractViewController.editLeadDelegate = self
        self.navigationController?.pushViewController(contractViewController, animated: false )
        
    }
    
    func newWorkOrderView(_workOrder:WorkOrder){
        
        //self.navigationController?.pushViewController(_view, animated: false )
        let workOrderViewController:WorkOrderViewController = WorkOrderViewController(_workOrderID: _workOrder.ID)
        //workOrderViewController.editLeadDelegate = self
        self.navigationController?.pushViewController(workOrderViewController, animated: false )
        
        
    }
    
    func newInvoiceView(_invoice:Invoice){
        
        //self.navigationController?.pushViewController(_view, animated: false )
        
    }
    
    
    func setLeadTasksWaiting(_leadTasksWaiting:String){
       // self.leadTasksWaiting = _leadTasksWaiting
        
    }
    
    //following 3 functions not used in this view
    func suggestNewContractFromLead(){
        print("suggestNewContractFromLead")
    }
    func suggestNewWorkOrderFromLead(){
        print("suggestNewWorkOrderFromLead")
    }
    func suggestNewWorkOrderFromContract(){
        print("suggestNewWorkOrderFromContract")
    }
    
    
    
    
    @objc func goBack(){
        
        _ = navigationController?.popViewController(animated: false)
        
    }
    
    
    
    
    
}