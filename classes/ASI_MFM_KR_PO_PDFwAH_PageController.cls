public  with sharing  class ASI_MFM_KR_PO_PDFwAH_PageController {
    public ASI_MFM_KR_PO_PDFwAH_PageController(ApexPages.StandardController controller) {
        this.poCurrent = (ASI_MFM_PO__c)controller.getRecord();
        this.UserDetails = (User)controller.getRecord();
    }
    public id POID {set;get;}
    public string BusNumber {set;get;}
    public ASI_MFM_PO__c poCurrent{get;set;}
    public User UserDetails{get;set;}
    public ASI_MFM_Plan__c plan{get;set;}
    public List<ASI_MFM_PO_Line_Item__c> lineItem{get;set;}
    public Decimal VatRate {get;set;}{VatRate=0;}
    public string SupplierEmail {get;set;}{SupplierEmail='';}
    
    public String ShipToAddress{get;set;}
    
    public Contact SupplierContact {get;set;} {SupplierContact = NEW Contact(); }
    private final String object_ApiName = 'ASI_MFM_PO__c';
    
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    //Approval History
    public Class approvalDetail
    {
        public ProcessInstanceHistory history{get;set;}
        public String title{get;set;}
        public String status{get;set;}
    }//end class
    
    public ASI_MFM_KR_PO_PDFwAH_PageController(){
        
    }
    
    public boolean init(){        
        lineItem = new List<ASI_MFM_PO_Line_Item__c>();
 
        poCurrent = [select Name,Owner.Name, ASI_MFM_Base_Currency_Amount__c,ASI_MFM_Remarks__c, ASI_MFM_Supplier_Name__c,ASI_MFM_Plan__c,ASI_MFM_GL_Date__c ,ASI_MFM_TR_Supplier_Email__c,
                     ASI_MFM_PO_Start_Date__c,ASI_MFM_Supplier_Name__r.ASI_LUX_Email_Business__c,ASI_MFM_PO_End_Date__c,ASI_MFM_Plan__r.name,ASI_MFM_Objectives__c,ASI_MFM_Mechanics__c,ASI_MFM_Other_Remark__c,
                     ASI_MFM_PO_Raised_Date__c, ASI_MFM_Responsible_By__r.Name, ASI_MFM_PO_Date_Range__r.Name, ASI_MFM_Sys_Local_Currency__c,
                     ASI_MFM_PO_Date_Range__r.ASI_MFM_Fiscal_Period__c,ASI_MFM_Tax_Rate__c,ASI_MFM_VAT__c,ASI_MFM_Plan__r.ASI_MFM_Base_Plan_Amount__c,
                     ASI_MFM_Supplier_Name__r.Name,ASI_MFM_Currency__c,ASI_MFM_PO_Amount__c,ASI_MFM_Subledger__c,ASI_MFM_Previous_Approved_By__r.Name,
                     ASI_MFM_Previous_Approved_At__c,ASI_MFM_Previous_Approved_Amount__c,RecordType.DeveloperName,ASI_MFM_Plan_Balance_in_PO_Currency__c,
                     ASI_MFM_Payment_Date__c,ASI_MFM_Status__c,ASI_MFM_Supplier_Address_Line_1__c,ASI_MFM_Supplier_Address_Line_2__c ,ASI_MFM_Supplier_Address_Line_3__c,
                     ASI_MFM_Supplier_Address_Line_4__c,ASI_MFM_Market__c,ASI_MFM_Sys_Plan_Name__c,ASI_MFM_Base_Plan_Balance__c,ASI_MFM_Company__c,
                     ASI_MFM_SG_Customer__c,ASI_MFM_Reference_1__c,ASI_MFM_Reference_2__c,ASI_MFM_SG_Delivery_To__c,ASI_MFM_Sys_Plan_Amount__c,CreatedBy.name,
                     ASI_MFM_Plan_Balance__c,CreatedDate,ASI_MFM_SG_Customer__r.name,ASI_MFM_Payment_Term__c, 	ASI_MFM_Plan_Amount_in_PO_Currency__c, CreatedBy.MobilePhone, 
                     ASI_MFM_Supplier_Name__r.phone, CreatedBy.fax, ASI_MFM_Supplier_Name__r.fax, CreatedBy.email, ASI_MFM_Supplier_Name__r.PersonEmail, ASI_MFM_Supplier_Name__r.ASI_KOR_Wholesaler_Bank_Account_Num__c,
                     ASI_MFM_Purchase_Request__r.CreatedBy.email, ASI_MFM_Ship_to_Address__c, ASI_MFM_Supplier_Name__r.ASI_KOR_Venue_Business_License_Number__c, /* ASI_MFM_Supplier_Name__r.ShippingAddress,*/ 
                     ASI_MFM_Purchase_Request__r.owner.name, ASI_MFM_Purchase_Request__r.owner.phone, ASI_MFM_Purchase_Request__r.owner.email, ASI_MFM_Warehouse__r.name, 
                     ASI_MFM_Warehouse__r.ASI_HK_CRM_Address__c,ASI_MFM_Marketing_Comment__c, ASI_MFM_Warehouse__r.phone, ASI_MFM_Warehouse__r.fax, ASI_MFM_Warehouse__r.PersonEmail,ASI_MFM_Company_Code__c,
                     ASI_MFM_Supplier_Name__r.ASI_KOR_Wholesaler_Bank__c, ASI_MFM_Warehouse__r.ASI_MFM_Address_Line_1__c, ASI_MFM_Warehouse__r.ASI_MFM_Address_Line_2__c,  ASI_MFM_Warehouse__r.ASI_MFM_Address_Line_3__c,
                     ASI_MFM_Warehouse__r.ASI_MFM_Address_Line_4__c from ASI_MFM_PO__c where id =: POID];
        
        if(poCurrent.ASI_MFM_VAT__c!=null){
            VatRate=poCurrent.ASI_MFM_VAT__c;
        }else{
            VatRate=0;
        }
        
        if(poCurrent.ASI_MFM_Supplier_Name__c!=null){
            List<Contact> ContactList= [select id,Phone,Fax,MobilePhone,Email,MailingCity,MailingState,MailingCountry,MailingPostalCode,MailingStreet,FirstName, LastName from Contact where AccountId =: poCurrent.ASI_MFM_Supplier_Name__c];
            if(ContactList.size()>0){
                SupplierContact = NEW Contact(); 
                SupplierContact=ContactList[0];
            }
            
            
        }
        
        //Added by Kammy at 17 Mar 2016
        
        
        if(poCurrent.ASI_MFM_Supplier_Name__r.ASI_KOR_Venue_Business_License_Number__c != null){
            
            BusNumber = poCurrent.ASI_MFM_Supplier_Name__r.ASI_KOR_Venue_Business_License_Number__c.remove('-');
            
            
            if(BusNumber.length() == 10){  //3-2-5
                BusNumber = BusNumber.substring(0,3)+ '-' + BusNumber.substring(3,5) + '-' + BusNumber.substring(5,10);
            }
            else{  
                BusNumber = poCurrent.ASI_MFM_Supplier_Name__r.ASI_KOR_Venue_Business_License_Number__c;
            }
           
            
        }
        
       if(poCurrent.ASI_MFM_Ship_to_Address__c != null){
            ShipToAddress=poCurrent.ASI_MFM_Ship_to_Address__c;
        }
        else{
            if(poCurrent.ASI_MFM_Warehouse__r.ASI_MFM_Address_Line_1__c  != null){
                ShipToAddress = poCurrent.ASI_MFM_Warehouse__r.ASI_MFM_Address_Line_1__c;
            }
            
            if(poCurrent.ASI_MFM_Warehouse__r.ASI_MFM_Address_Line_2__c != null){
                ShipToAddress += poCurrent.ASI_MFM_Warehouse__r.ASI_MFM_Address_Line_2__c ;
            }
            
            if(poCurrent.ASI_MFM_Warehouse__r.ASI_MFM_Address_Line_3__c !=null){
                ShipToAddress += poCurrent.ASI_MFM_Warehouse__r.ASI_MFM_Address_Line_3__c;
            }
            
            if(poCurrent.ASI_MFM_Warehouse__r.ASI_MFM_Address_Line_4__c !=null){
                ShipToAddress += poCurrent.ASI_MFM_Warehouse__r.ASI_MFM_Address_Line_4__c ;
            }
        } 
        //Ended 
          
        if(poCurrent.ASI_MFM_Plan__c != null){
            plan = [select id,Name,ASI_MFM_Plan_Description__c,ASI_MFM_Fiscal_year__c,
                    owner.name from ASI_MFM_Plan__c where id =: poCurrent.ASI_MFM_Plan__c ]; 
        }
        else{
            plan = new ASI_MFM_Plan__c();
            plan.Name = '';
            plan.ASI_MFM_Plan_Description__c = '';
        }
        
        UserDetails = [select CompanyName,phone, Street, City, PostalCode,email, Country, fax from User where Name =: poCurrent.Owner.Name];
           
        
        List<ASI_MFM_PO_Line_Item__c> lineItemList = [select Name,ASI_MFM_Tax_Code__r.name,ASI_MFM_SKU_Code__c,ASI_MFM_SKU_Code__r.name, ASI_MFM_Tax_Code__r.ASI_MFM_VAT_Rate__c,ASI_MFM_Delivery_Date__c,ASI_MFM_Print_Sequence__c,ASI_MFM_PO_Remark__c,ASI_MFM_KR_Quantity__c, ASI_MFM_List_Item_Description__c,ASI_MFM_UOM__c,ASI_MFM_Unit_Price__c,ASI_MFM_Quantity__c,
                                                      ASI_MFM_Amount__c,ASI_MFM_AP_Code__r.Name,ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_TH_Unit__c, 
                                                      ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c,ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c,ASI_MFM_A_C_Code__r.Name, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.Name, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c , ASI_MFM_Sub_brand_Code__r.Name,
                                                      ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c, ASI_MFM_BU_Code__r.ASI_MFM_L1__c, ASI_MFM_G_L_Date__c
                                                      from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c =: POID AND ASI_MFM_Amount__c > 0 order by ASI_MFM_Print_Sequence__c,name];
        Integer lineNum = 1;
        for(ASI_MFM_PO_Line_Item__c poli : lineItemList){
            if(poli.ASI_MFM_Quantity__c == null){
                poli.ASI_MFM_Quantity__c = 0;
            }
            if(poli.ASI_MFM_Unit_Price__c == null){
                poli.ASI_MFM_Unit_Price__c = 0;
            }
            if(poli.ASI_MFM_Amount__c == null){
                poli.ASI_MFM_Amount__c = 0;
            }
            poli.ASI_MFM_Print_Sequence__c = lineNum ;
            lineNum ++ ;
            lineItem.add(poli);
        }
        
        
        return true;
    }
    
    public List<approvalDetail> getapprovalDetails()
    {
        List<approvalDetail> details = new List<approvalDetail>();
        if (details.size() == 0 && POID != null)
        {
            List<ProcessInstance> pList = [SELECT Id, 
                                           (SELECT Id,
                                            CreatedDate,
                                            StepStatus,
                                            Comments,
                                            ActorId,
                                            Actor.Name,
                                            OriginalActorId,
                                            OriginalActor.Name
                                            FROM StepsAndWorkitems
                                            ORDER BY CreatedDate DESC,
                                            StepStatus DESC)
                                           FROM ProcessInstance
                                           WHERE TargetObjectId = :POID
                                           ORDER BY CreatedDate DESC
                                           Limit 1];
            Set<Id> actoerIdSet = new Set<Id>();
            for (ProcessInstance p:pList)
            {
                for (ProcessInstanceHistory his:p.StepsAndWorkitems)
                {
                    actoerIdSet.add(his.OriginalActorId);
                }//end for
            }//end for
            Map<Id, User> userMap = new Map<Id, User>([Select Id, title From User Where Id In :actoerIdSet]);
            for (ProcessInstance p:pList)
            {
                Boolean byPassPending = false;
                if(p.StepsAndWorkitems.size() != 0 
                   &&(p.StepsAndWorkitems[0].StepStatus == 'Approved'
                      ||p.StepsAndWorkitems[0].StepStatus == 'Rejected'))
                {
                    byPassPending = true;
                }//end if
                for (ProcessInstanceHistory his:p.StepsAndWorkitems)
                {
                    if(his.StepStatus != 'Reassigned'
                       && his.StepStatus != 'NoResponse'
                       &&!(byPassPending && his.StepStatus == 'Pending'))
                    {
                        approvalDetail detail = new approvalDetail();
                        if(his.StepStatus == 'Removed')
                            detail.status = 'Recalled';
                        else if(his.StepStatus == 'Started')
                            detail.status = 'Submitted';
                        else
                            detail.status = his.StepStatus;
                            
                        detail.title = userMap.get(his.OriginalActorId).title;
                        detail.history = his;
                        details.add(detail);
                    }//end if
                }//end for
            }//end for
        }//end if
        return details;
    }//end method: getapprovalDetails
    
}