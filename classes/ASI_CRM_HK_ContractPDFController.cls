public class ASI_CRM_HK_ContractPDFController {
    public Id PAFID {set;get;}
    public String CusID {set;get;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public ASI_HK_CRM_Pre_Approval_Form__c PAF {get;set;}
    public Account OutletInfo {get;set;}
    public String OutletInfoPN {get;set;}
    public String OutletInfoN {get;set;}
    public string CurrentDate {get; set;}
    public string ApproverName {get; set;}
    public string ApproverPost {get; set;}
    public string SignatureName {get; set;}
    public string SignaturePost {get; set;}
    public string msg {get; set;}
    public string PDFName {get; set;}
    public Boolean IsPA {get; set;}
    public Boolean IsShPro {get; set;}
    public List<ProcessInstanceHistory> appHistorySObjList{get;set;}
    public Contact CustomerInfo {get;set;} //contact person
    public List<ASI_HK_CRM_Pre_Approval_Form_Item__c> MechanicItems {get;set;} // Mechanic line items
    //public List<ASI_HK_CRM_Pre_Approval_Form_Item__c> ItemsList {get;set;} //Item List //20160301, edited by Leo
    public Map<String,ASI_HK_CRM_Pre_Approval_Form_Item__c> ItemsMap {get;set;} //Item List //20160301, edited by Leo
    public List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> CusList {get;set;} //PAF Customer PA/DA List
    public List<promoListObj> promoList {get;set;}
    public ASI_CRM_HK_ContractPDFController() {}
    public Date printDate {get;set;} //20160205, added by Leo
    public List<printObj> priList {get;set;} //20160301, added by Leo
    public String reportName {get{return 'Customer\' staff training sponsorship';} set;} //20160309, added by Leo
    
    public class promoListObj {
        public String DAName {get;Set;}
        public String DAAddress {get;Set;}
    }
    
    //20160301, added by Leo
    public class printObj {
        public String itemName {get;set;}
        public ASI_HK_CRM_Pre_Approval_Form_Item__c pafItem {get;set;}
    }
    //20160301, added by Leo
    public ASI_CRM_HK_ContractPDFController(ApexPages.StandardController controller) {
        List<string> fields = new List<string>();
        fields.add('Name');
        fields.add('ASI_CRM_HK_Is_Channel_PAF__c');
        fields.add('ASI_HK_CRM_PAF_Customer__c');
        fields.add('ASI_HK_CRM_PAF_Customer__r.Name');
        fields.add('ASI_CRM_Short_Term_Promotion__c');
        fields.add('ASI_HK_CRM_PAF_Customer__r.id');
        if(!Test.isRunningTest()){
            controller.addFields(fields);
        }
        this.PAF = (ASI_HK_CRM_Pre_Approval_Form__c)controller.getRecord();
        CusID = ApexPages.currentPage().getParameters().get('cid');
    }
    
    public boolean init() {
        printDate = Date.Today().addDays(7); //20160205, added by Leo
        Datetime Current = Datetime.now();
        CurrentDate = Current.format('dd MMMM,  yyyy');
        CustomerInfo = new Contact();
        promoList = new List<promoListObj>();
        PAF = [SELECT id, Name
               , ASI_HK_CRM_PAF_Start_Date__c
               , ASI_HK_CRM_PAF_End_Date__c
               , Owner.Name
               , Owner.email
               , Owner.Phone
               , ASI_HK_CRM_PAF_Customer__r.id
               , ASI_HK_CRM_PAF_Customer__r.ParentId
               , ASI_HK_CRM_PAF_Customer__r.Parent.Name
               , ASI_HK_CRM_PAF_Customer__r.Parent.ASI_HK_CRM_Address__c
               , ASI_CRM_Short_Term_Promotion__c
               , ASI_HK_CRM_PAF_Customer__r.Name
               , ASI_HK_CRM_Contract_Details__c
               , ASI_HK_CRM_Other_Comments__c
               FROM ASI_HK_CRM_Pre_Approval_Form__c 
               WHERE id = :PAFID];
        // Get Signature Person
        ASI_CRM_HK_PAF_Signature__c Signature = [Select Name, ASI_CRM_HK_Signature_PersonId__c 
                                                 From ASI_CRM_HK_PAF_Signature__c
                                                 where Name = 'Signature person' limit 1];
        id Signature_PersonId = Signature.ASI_CRM_HK_Signature_PersonId__c;
        User Signature_detail = [Select Name, Title 
                                 From User
                                 Where id =: Signature_PersonId];
        SignatureName = Signature_detail.Name;
        SignaturePost = Signature_detail.Title;
        
        if(CusID == ''){
            CusID = PAF.ASI_HK_CRM_PAF_Customer__c;
        }
        if (CusID != '') {
            OutletInfo = [SELECT id, Name, ParentId, Parent.Name, Parent.ASI_HK_CRM_Address__c, 
                          ASI_HK_CRM_Address__c, ASI_HK_CRM_Credit_Limit__c, ASI_HK_CRM_Payment_Term_Description__c 
                          FROM Account WHERE id = :CusID];
            
            if(OutletInfo.ParentId != null && OutletInfo.Parent.Name.contains('('))
            {
                Integer index1 = String.valueOf(OutletInfo.Parent.Name).lastIndexOf('(');
                OutletInfoPN = String.valueOf(OutletInfo.Parent.Name).subString(0,index1);
            } else{
                OutletInfoPN = OutletInfo.Parent.Name;
            }
            
            if(OutletInfo.Name != null && OutletInfo.Name.contains('(')) {
                Integer index1 = String.valueOf(OutletInfo.Name).lastIndexOf('(');
                OutletInfoN = String.valueOf(OutletInfo.Name).subString(0,index1);
            }//end if
            else
                OutletInfoN = OutletInfo.Name;
            //20160226, added by Leo
            if (OutletInfo.ParentId != null) IsPA = False; Else IsPA = True;
            try{
                CustomerInfo = [SELECT id, Name, Title, Salutation From Contact Where AccountId = :CusID and ASI_HK_CRM_Main_Contact__c = true];
            }catch (Exception e){
                system.debug('No CustomerInfo');
            }
        }
        // Get the Customer PA/DA List
        try{
            promoListObj tmp;// = new promoListObj();
            if (this.PAF.ASI_CRM_Short_Term_Promotion__c){
                IsShPro = True;
                Cuslist = [select id, name,ASI_CRM_PA_DA__c, ASI_CRM_HK_Customer__c, ASI_CRM_HK_Customer__r.Name, ASI_CRM_HK_Customer__r.ASI_HK_CRM_Local_Channel__c, ASI_CRM_HK_Customer__r.ASI_HK_CRM_Credit_Limit__c 
                           , ASI_CRM_HK_Customer__r.ASI_HK_CRM_Address__c, ASI_CRM_HK_Customer__r.parentId
                           from ASI_CRM_HK_Pre_Approval_Form_Customer__c 
                           where (ASI_CRM_HK_Pre_Approval_Form__c=:PAFID
                                  AND (ASI_CRM_HK_Customer__c =: CusID Or ASI_CRM_HK_Customer__r.parentId =: CusID)
                                  AND ASI_CRM_HK_Download_Flag__c = True)
                           Order by ASI_CRM_PA_DA__c DESC];
                for (ASI_CRM_HK_Pre_Approval_Form_Customer__c c: CusList){
                    if (c.ASI_CRM_HK_Customer__c != CusID){ //
                        tmp = new promoListObj();
                        tmp.DAName = c.ASI_CRM_HK_Customer__r.Name;
                        tmp.DAAddress = c.ASI_CRM_HK_Customer__r.ASI_HK_CRM_Address__c;
                        promoList.add(tmp);
                    }
                }
            }else{
                system.debug(this.PAF.ASI_HK_CRM_PAF_Customer__c);
                IsShPro = False;
                List<Account> accList = [Select id, Name, ASI_HK_CRM_Address__c
                                         from Account
                                         where ParentId =: this.PAF.ASI_HK_CRM_PAF_Customer__c ];
                if (accList.size() > 0){
                    for (Account a: accList){
                        tmp = new promoListObj();
                        tmp.DAName = a.Name;
                        tmp.DAAddress = a.ASI_HK_CRM_Address__c;
                        promoList.add(tmp);
                    }
                }
            }
        }catch (Exception e){
            System.debug('Error'+ e);
        }
        
        //Get the Mechanic line item
        MechanicItems = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>(); 
        MechanicItems = [
            SELECT Id, Name, ASI_HK_CRM_Pre_Approval_Form_Lookup__c, ASI_HK_CRM_SKU_Lookup__c
            , ASI_HK_CRM_SKU_Lookup__r.Name
            , ASI_HK_CRM_SKU_Lookup__r.ASI_FOC_Packing_Description__c
            , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__r.ASI_HK_CRM_Benchmark__c
            , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Description__c
            , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.ASI_CRM_ITEM_GROUP_Contract_Desc__c //20160414, added by Leo
            , ASI_HK_CRM_Mechanic__c, ASI_HK_CRM_Mechanic__r.Name, ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c
            , ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_PAF_Report_Section__c
            , ASI_HK_CRM_Target_Volume_Qty__c, ASI_HK_CRM_Price__c, ASI_HK_CRM_Pouring__c
            , ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c, ASI_HK_CRM_FOC_Free_Bottle_Option_1__c
            , ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c, ASI_HK_CRM_FOC_Free_Bottle_Option_2__c
            , ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c, ASI_HK_CRM_FOC_Free_Bottle_Option_3__c
            , ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c, ASI_HK_CRM_FOC_Free_Bottle_Option_4__c
            , ASI_HK_CRM_FOC_Bulk_Buy_Bottle_Option_1__c, ASI_HK_CRM_FOC_Bulk_Free_Bottle_Option_1__c
            , ASI_HK_CRM_FOC_Bulk_Buy_Bottle_Option_2__c, ASI_HK_CRM_FOC_Bulk_Free_Bottle_Option_2__c
            , ASI_HK_CRM_FOC_Bulk_Buy_Bottle_Option_3__c, ASI_HK_CRM_FOC_Bulk_Free_Bottle_Option_3__c
            , ASI_HK_CRM_FOC_Bulk_Buy_Bottle_Option_4__c, ASI_HK_CRM_FOC_Bulk_Free_Bottle_Option_4__c
            , ASI_HK_CRM_Rebate_Disc_Percent__c, ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c, ASI_HK_CRM_Fixed_Amount__c
            , ASI_HK_CRM_Investment_Value__c
            , ASI_HK_CRM_Conditions_for_Payment__c
            , ASI_CRM_HK_Pricing_Item__c
            , ASI_CRM_HK_All_Product__c //20160408, added by Leo
            , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__r.Name // Added Sub-Brand 20180420'
            FROM ASI_HK_CRM_Pre_Approval_Form_Item__c
            WHERE ASI_HK_CRM_Pre_Approval_Form_Lookup__c = :PAFID
            ORDER BY ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__r.Name asc, ASI_CRM_HK_Pricing_Item__c // 20180420
            //ORDER BY ASI_CRM_HK_Pricing_Item__c //ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Mechanics_subString__c //20160408, edited by Leo, change sequence
        ];
        System.Debug('MechanicItems:'+MechanicItems);
        List<ASI_HK_CRM_Pre_Approval_Form_Item__c> MechanicItems2 
            = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>(); 
        MechanicItems2 = [
            SELECT Id, Name, ASI_HK_CRM_Pre_Approval_Form_Lookup__c, ASI_HK_CRM_SKU_Lookup__c
            , ASI_HK_CRM_SKU_Lookup__r.Name
            , ASI_HK_CRM_SKU_Lookup__r.ASI_FOC_Packing_Description__c
            , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__r.ASI_HK_CRM_Benchmark__c
            , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Description__c
            , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.ASI_CRM_ITEM_GROUP_Contract_Desc__c //20160414, added by Leo
            , ASI_HK_CRM_Mechanic__c, ASI_HK_CRM_Mechanic__r.Name, ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c
            , ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_PAF_Report_Section__c
            , ASI_HK_CRM_Target_Volume_Qty__c, ASI_HK_CRM_Price__c, ASI_HK_CRM_Pouring__c
            , ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c, ASI_HK_CRM_FOC_Free_Bottle_Option_1__c
            , ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c, ASI_HK_CRM_FOC_Free_Bottle_Option_2__c
            , ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c, ASI_HK_CRM_FOC_Free_Bottle_Option_3__c
            , ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c, ASI_HK_CRM_FOC_Free_Bottle_Option_4__c
            , ASI_HK_CRM_FOC_Bulk_Buy_Bottle_Option_1__c, ASI_HK_CRM_FOC_Bulk_Free_Bottle_Option_1__c
            , ASI_HK_CRM_FOC_Bulk_Buy_Bottle_Option_2__c, ASI_HK_CRM_FOC_Bulk_Free_Bottle_Option_2__c
            , ASI_HK_CRM_FOC_Bulk_Buy_Bottle_Option_3__c, ASI_HK_CRM_FOC_Bulk_Free_Bottle_Option_3__c
            , ASI_HK_CRM_FOC_Bulk_Buy_Bottle_Option_4__c, ASI_HK_CRM_FOC_Bulk_Free_Bottle_Option_4__c
            , ASI_HK_CRM_Rebate_Disc_Percent__c, ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c, ASI_HK_CRM_Fixed_Amount__c
            , ASI_HK_CRM_Investment_Value__c
            , ASI_HK_CRM_Conditions_for_Payment__c
            , ASI_CRM_HK_Pricing_Item__c
            , ASI_CRM_HK_All_Product__c //20160408, added by Leo
            , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__r.Name // Added Sub-Brand 20180420
            FROM ASI_HK_CRM_Pre_Approval_Form_Item__c
            WHERE ASI_HK_CRM_Pre_Approval_Form_Lookup__c = :PAFID
            ORDER BY ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__r.Name asc, ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_Mechanics_subString__c // 20180420
        ];
        // Generate items full list
        ItemsMap = new Map<String,ASI_HK_CRM_Pre_Approval_Form_Item__c>(); //20160301, edited by Leo
        priList = new List<printObj>(); //20160301, edited by Leo
        string prev = '';
        for (ASI_HK_CRM_Pre_Approval_Form_Item__c tmp : MechanicItems2){
            printObj tmpPriObj = new printObj();
            tmpPriObj.pafItem = tmp;
            if(tmp.ASI_HK_CRM_Mechanic__c != null)
            {
                Integer index1 = tmp.ASI_HK_CRM_Mechanic__r.Name.indexOf('-');
                Integer index2 = tmp.ASI_HK_CRM_Mechanic__r.Name.length();
                if(tmp.ASI_HK_CRM_Mechanic__r.Name.contains('('))
                    index2 = tmp.ASI_HK_CRM_Mechanic__r.Name.indexOf('(');
                tmpPriObj.itemName = tmp.ASI_HK_CRM_Mechanic__r.Name.subString(index1+1, index2);
            }else{
                tmpPriObj.itemName = '';
            }
            
            
            priList.add(tmpPriObj);
            
            if (prev != tmp.ASI_CRM_HK_Pricing_Item__c){
                ItemsMap.put(tmp.ASI_CRM_HK_Pricing_Item__c,tmp); //20160301, edited by Leo
                prev = tmp.ASI_CRM_HK_Pricing_Item__c;
            }
            //20160301, added by Leo
        }
        for (ASI_HK_CRM_Pre_Approval_Form_Item__c tmp : MechanicItems){
            if(prev == tmp.ASI_CRM_HK_Pricing_Item__c 
               && tmp.ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_PAF_Report_Section__c != null
               && tmp.ASI_HK_CRM_Mechanic__r.ASI_CRM_HK_PAF_Report_Section__c.equals('On-Invoice Discount')
               && (tmp.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c != null
                   ||tmp.ASI_HK_CRM_Rebate_Disc_Percent__c != null))
            {
                ItemsMap.put(tmp.ASI_CRM_HK_Pricing_Item__c,tmp);
                prev = tmp.ASI_CRM_HK_Pricing_Item__c;
            }//end if
            //20160301, added by Leo
        }
        
        //Get the approver
        string queryStr = 'Select Name, Id, (Select Id,ProcessInstanceId, StepStatus, Comments, CreatedDate, OriginalActor.Id , OriginalActor.Name, OriginalActor.Title , Actor.Id, Actor.Name, Actor.Title From ProcessSteps WHERE StepStatus = \'Approved\' order by CreatedDate ASC) From ASI_HK_CRM_Pre_Approval_Form__c ';
        queryStr += ' where id =\'' + PAFID + '\'';  
        List<sObject> parentSObjList = Database.query(queryStr);        
        for(sObject sobj: parentSObjList  ){
            appHistorySObjList = sobj.getSObjects('ProcessSteps');
            if (appHistorySObjList  != null) {
                for(ProcessInstanceHistory ps: appHistorySObjList ) {
                    ApproverName = ps.Actor.Name;
                    ApproverPost = ps.Actor.Title;  
                }
            }
        }
        
        return true;
    }
}