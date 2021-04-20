public class ASI_MFM_TR_PO_PDF_PageController {
    
    public id POID {set;get;}
    private final ASI_MFM_PO__c Po;
    public ASI_MFM_Plan__c plan{get;set;}
    
    public Boolean isATR{get;set;}
    public List<ASI_MFM_PO_Line_Item__c> lineItem{get;set;}
        
    public ASI_MFM_PO__c poCurrent{get;set;}
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public string ApprovalStatus {set;get;}

    public ASI_MFM_TR_PO_PDF_PageController(){
      
    }
    
     public boolean init(){
        //try{
        //this.Po = (ASI_MFM_PO__c)stdController.getRecord();
        
        lineItem = new List<ASI_MFM_PO_Line_Item__c>();
        
        poCurrent = [select Name,ASI_MFM_Status__c, ASI_MFM_Supplier_Name__c,ASI_MFM_Supplier_Name__r.Name,ASI_MFM_Supplier_Address_Line_1__c,ASI_MFM_Supplier_Address_Line_2__c,ASI_MFM_Supplier_Address_Line_3__c,ASI_MFM_Supplier_Address_Line_4__c,
        ASI_MFM_Supplier_Phone_Number__c, ASI_MFM_Supplier_Fax_Number__c,ASI_MFM_TR_Supplier_Quotation_Ref_No__c,
        ASI_MFM_Plan__c, ASI_MFM_Plan__r.ASI_MFM_Plan_Type__c,ASI_MFM_Plan__r.Name,
        ASI_MFM_PO_Raised_Date__c,ASI_MFM_Currency__c,ASI_MFM_Exchange_Rate__c, ASI_MFM_PO_Amount__c,ASI_MFM_Payment_Date__c,ASI_MFM_Payment_Terms__c,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_Total_Quantity__c,
        ASI_MFM_Delivery_Address_Line_1__c,ASI_MFM_Delivery_Address_Line_2__c,ASI_MFM_Delivery_Address_Line_3__c,ASI_MFM_Delivery_Address_Line_4__c,
        ASI_MFM_Remarks__c,owner.name, ASI_MFM_Plan__r.ASI_MFM_Plan_Description__c, ASI_MFM_Responsible_By__r.Name 
        from ASI_MFM_PO__c where id =:POID];
        System.debug('POId ' + POID);
        
        if(poCurrent.ASI_MFM_Plan__c != null){
            plan = [select id,Name,ASI_MFM_Plan_Description__c,ASI_MFM_TR_Rec_Type__c,
            owner.name from ASI_MFM_Plan__c where id =: poCurrent.ASI_MFM_Plan__c ]; 
            if (plan.ASI_MFM_TR_Rec_Type__c == 'ATR')
                isATR = true;
            else
                isATR = false;
        }
        else{
            plan = new ASI_MFM_Plan__c();
            plan.Name = '';
            plan.ASI_MFM_Plan_Description__c = '';
            isATR = true;
        }
        
        System.debug('planId' + plan.id);
        System.debug('planName' + plan.Name);
        System.debug('planDescription' + plan.ASI_MFM_Plan_Description__c);
        List<ASI_MFM_PO_Line_Item__c> lineItemList = [select ASI_MFM_List_Item_Description__c,ASI_MFM_UOM__c,ASI_MFM_Unit_Price__c,ASI_MFM_Quantity__c,
        ASI_MFM_Amount__c,ASI_MFM_SKU_Code__r.Name, ASI_MFM_SKU_Code__r.ASI_MFM_SKU_Code__c ,ASI_MFM_Base_Currency_Amount__c, ASI_MFM_A_C_Code__c, ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c, ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c,  ASI_MFM_AP_Code_Only__c,ASI_MFM_AP_Description__c,
        ASI_MFM_BU_Code__c,ASI_MFM_BU_Code__r.Name,ASI_MFM_Customer_Name__c,ASI_MFM_Customer_Name__r.name,ASI_MFM_Customer_Code__c,
        ASI_MFM_Pay_Acc__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_Brand_Code_Only__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Description__c,ASI_MFM_G_L_Date__c
        from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c =: poCurrent.Id order by ASI_MFM_Print_Sequence__c,name];
        
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
            lineItem.add(poli);
        }
        
        //2015-01-28 Added by Stella Sing Approval Status
        try{
            string TempUserId;
            string strStatus;
            datetime strDate;
            for (ProcessInstance temp : [SELECT Id, Status, LastModifiedDate, (SELECT Id, StepStatus, ActorId, Comments FROM StepsAndWorkitems WHERE StepStatus != 'Started' ORDER BY CreatedDate DESC LIMIT 1)
                                FROM ProcessInstance WHERE TargetOBjectId = :POID LIMIT 1]){
                TempUserId = temp.StepsAndWorkitems[0].ActorId;
                strStatus = temp.Status;
                strDate = temp.LastModifiedDate;
            }
            
            User approver = [SELECT Name FROM User WHERE Id = : TempUserId];
            if (approver != null)
                ApprovalStatus = strStatus + ' by ' + approver.Name + ' on ' + string.valueof(strDate.year()) + '-' + ConvertDateTime(strDate, 'Month') + '-' + ConvertDateTime(strDate, 'Day') + ' ' + ConvertDateTime(strDate, 'Hour') + ':' + ConvertDateTime(strDate, 'Min') + ':' + ConvertDateTime(strDate, 'Sec');
            else
                ApprovalStatus = '';
        }catch(exception e){
            ApprovalStatus = '';
        }
        
        return true;
        //catch(exception e){e.getMessage();}
    }
    public string ConvertDateTime(datetime strDate, string strType){
        //strType: Month, Day, Hour, Min, Sec
        if (strDate != null){
            if (strType == 'Month'){
                if (strDate.Month() < 10)
                    return '0' + strDate.Month();
                else
                    return string.valueof(strDate.Month());
            }else if (strType == 'Day'){
                if (strDate.Day() < 10)
                    return '0' + strDate.Day();
                else
                    return string.valueof(strDate.Day());
            }else if (strType == 'Hour'){
                if (strDate.Hour() < 10)
                    return '0' + strDate.Hour();
                else
                    return string.valueof(strDate.Hour());
            }else if (strType == 'Min'){
                if (strDate.Minute() < 10)
                    return '0' + strDate.Minute();
                else
                    return string.valueof(strDate.Minute());
            }else if (strType == 'Sec'){
                if (strDate.Second() < 10)
                    return '0' + strDate.Second();
                else
                    return string.valueof(strDate.second());
            }else{
                return null;
            }
        }else{
            return null;
        }
    }
    

    
}