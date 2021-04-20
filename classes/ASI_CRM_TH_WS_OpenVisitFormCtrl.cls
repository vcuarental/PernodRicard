/*********************************************************************************
 * Name: ASI_CRM_TH_WS_OpenVisitFormCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 08/04/2016       Introv: Twinkle LI         
*********************************************************************************/
global without sharing class ASI_CRM_TH_WS_OpenVisitFormCtrl {   
    public String strVPID { get; set; }
    public Account objAccount { get; private set; }
    //public ASI_CRM_AccountsAdditionalField__c objAccountAddt { get; private set; }
    public ASI_HK_CRM_Visitation_Plan_Detail__c objVisitPlanDetail { get; private set; }
    public List<SalesMovnt> lstSalesMovnt { get; private set; }
    public List<List<SelectOption>> lstSalesMovOpts { get;set; }
    public List<List<SelectOption>> lstPromoOpts { get;set; }
    public Boolean isQuickSave {get;set;}
    public String encodedAccountName{get;set;}
    public Id idVisitPlanDetail {get;set;}
    Public Id idAcc {get;set;}
    public boolean allowEdit {get;set;}
    public String accountRegion {get;set;}    
    public String CurrentPage { get; set; } // Page 1 = 0 , Page 2 = 1, Page 3 = 2, Page 4 = 3
    
    public List<SelectOption> lstFileCountList {get; set;}   
    public List<Attachment> lstAttachmentGeneral { get; set; }
    
    //Added by Twinkle @ 20160414
    public List<SalesMovnt> lstSalesMovnt_Competitor { get; set; }
    Public List<String> selectedObjectives { get; set; }
    Public List<String> selectedWho { get; set; }
    Public List<String> selectedActivities { get; set; }
    Public List<String> selectedPromoMaterials { get; set; }
    Public List<String> selectedProductDisplay { get; set; }
    Public List<String> selectedSpecialDisplay { get; set; }
    Public List<String> selectedBarSupply { get; set; }
    Public List<String> selectedSignage { get; set; }
    
    Public Boolean booleanPresencePrt { get; set; }
    Public Boolean booleanPresenceCompetitor { get; set; }
    
    //For error Message display
    public String strErrorMessageReason { get; set; }
    public String strErrorMessageObjectives { get; set; }
    public String strErrorMessageWho { get; set; }
    
    /** Option list for Sales Movement Yes and No */
    public List<SelectOption> getSalesMovntOpt() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('N', 'No'));
        options.add(new SelectOption('Y', 'Yes'));
        return options;
    }
    
    /** Option list for Promotion Status Yes and No */
    public List<SelectOption> getPromoOpt() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('N', 'No'));
        options.add(new SelectOption('Y', 'Yes'));
        return options;
    }
    
    public String strCxlReason {
        get { return objVisitPlanDetail.ASI_HK_CRM_Cancellation_Reason__c; }
        set { objVisitPlanDetail.ASI_HK_CRM_Cancellation_Reason__c = value; }
    }
    public DateTime VisitDateF {
        get { return objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c; }
        set { objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c = value; }
    }
    public DateTime VisitDateT {
        get { return objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_To__c; }
        set { objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_To__c = value; }
    }
    
    //get multi-picklist values    
    public List<SelectOption> getObjectiveList() {    
        List<SelectOption> options = new List<SelectOption>();
        
        /*Schema.DescribeFieldResult fieldResult = ASI_HK_CRM_Visitation_Plan_Detail__c.ASI_CRM_TH_WS_Objectives__c.getDescribe();
        List<Schema.PicklistEntry> statuslist = fieldResult.getPicklistValues();
            
        for(Schema.PicklistEntry f : statuslist){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }*/
        
        ASI_CRM_TH_Picklist_Setting__c listPicklistValues  = [SELECT ASI_CRM_Value__c FROM ASI_CRM_TH_Picklist_Setting__c 
                                                              WHERE ASI_CRM_Object__c = 'ASI_HK_CRM_Visitation_Plan_Detail__c' 
                                                              AND ASI_CRM_Record_Type__c = 'ASI_TH_CRM_Visitation_Plan_Detail' 
                                                              AND ASI_CRM_Field__c = 'ASI_TH_CRM_Objectives__c' 
                                                              AND Name = 'VPD Objectives (WS)' LIMIT 1];
        
        String[] tmpString = listPicklistValues.ASI_CRM_Value__c.split(';');
        integer index = 0;
        For(String s : tmpString){
            s = s.replace('[', '').replace(']', '');
            options.add(new SelectOption(s, s));
            index++;
        }
        return options;
    } 
    
    public List<SelectOption> getWhoList() {
        List<SelectOption> options = new List<SelectOption>();
        
        /*Schema.DescribeFieldResult fieldResult = ASI_HK_CRM_Visitation_Plan_Detail__c.ASI_CRM_TH_WS_Who__c.getDescribe();
        List<Schema.PicklistEntry> statuslist = fieldResult.getPicklistValues();
            
        for(Schema.PicklistEntry f : statuslist){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }*/
        
        ASI_CRM_TH_Picklist_Setting__c listPicklistValues  = [SELECT ASI_CRM_Value__c FROM ASI_CRM_TH_Picklist_Setting__c 
                                                              WHERE ASI_CRM_Object__c = 'ASI_HK_CRM_Visitation_Plan_Detail__c' 
                                                              AND ASI_CRM_Record_Type__c = 'ASI_TH_CRM_Visitation_Plan_Detail' 
                                                              AND ASI_CRM_Field__c = 'ASI_TH_CRM_Who__c' 
                                                              AND Name = 'VPD Who (WS)' LIMIT 1];
        
        String[] tmpString = listPicklistValues.ASI_CRM_Value__c.split(';');
        integer index = 0;
        For(String s : tmpString){
            s = s.replace('[', '').replace(']', '');
            options.add(new SelectOption(s, s));
            index++;
        }
        return options;
    } 
    
    global class SalesMovnt implements Comparable{
        public String idRec { get; private set; }
        public Id idSubBrand { get; private set; }
        public String strSubBrand { get; private set; }
        public String strPriority { get; private set; }
        public Decimal decPrioritySorting { get; private set; }
        public Decimal decListPrice { get; set; }
        public String strProductGroup3 { get; private set; }
        public Decimal decCurrentStock { get; set; }
        
        //public String strSalesMovntOpt { get; set; }
        public String strSalesMovntPresence { get; set; }
        public String strSalesMovntVisibility { get; set; }
        
        global Integer compareTo(Object compareTo) {                     
            SalesMovnt compareToSalesMovnt = (SalesMovnt)compareTo;
            if (decPrioritySorting  == compareToSalesMovnt.decPrioritySorting ) return 0;
            if (decPrioritySorting > compareToSalesMovnt.decPrioritySorting ) return 1;
            return -1;        
        }
        
        public String strErrorMessagePrecense { get; set; }
        public String strErrorMessageVisibility { get; set; }
        public String strErrorMessageCurrentStock { get; set; }
        public String strErrorMessageSellingPrice { get; set; }
    }        
   
    public PageReference errorMessage(){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot edit the plan, as  it is 7 days before the plannd date.'));
        return null;
    }
    
    public ASI_CRM_TH_WS_OpenVisitFormCtrl(ApexPages.StandardController stdController) {
        allowEdit = true;
        
        if(booleanPresencePrt == null)
            booleanPresencePrt = false;
        if(booleanPresenceCompetitor == null)
            booleanPresenceCompetitor = false;
        
        currentPage = ApexPages.currentPage().getParameters().get('page');
        if(CurrentPage == null || CurrentPage =='')
            CurrentPage = '0';
        
        idVisitPlanDetail = ApexPages.currentPage().getParameters().get('vpid');
        idAcc = ApexPages.currentPage().getParameters().get('accid');
        isQuickSave = true;
        
        // Initial options
        lstFileCountList = new List<SelectOption>() ;  
        for (Integer i = 1; i <= 5; i++)
            lstFileCountList.add(new SelectOption('' + i , '' + i));
        
        // Initial one row of photo to upload
        lstAttachmentGeneral = new List<Attachment>();
        lstAttachmentGeneral.add(new Attachment());
        
        // Sample URL parameter vpid=a75M00000008PvY&accid=001M000000W2Ugg
        // https://pernod-ricard--asisb5conf--c.cs7.visual.force.com/apex/ASI_CRM_TW_SalesCallPlanPage?vpid=a75M00000008PvY&accid=001M000000W2Ugg
        //DEV
        //if (idVisitPlanDetail == null) idVisitPlanDetail = 'a75M00000008PvY';
        //if (idAcc == null) idAcc = '001M000000W2Ugg'; //DEV
        //if (idAcc == null) idAcc = '001M000000XzQc4IAF'; //DEV
        
        if (idVisitPlanDetail == null) throw new ASI_CRM_TW_Function.CRM_TW_Exception('Invalid Visitation Plan Detail Id (empty)');
        if (idAcc == null) throw new ASI_CRM_TW_Function.CRM_TW_Exception('Invalid Account Id (empty)');

        strVPID = idVisitPlanDetail;
        
        // Obtain Account (Outlet) fields
        List<Account> lstAccounts = [
            SELECT Id, Name, ASI_KOR_Customer_Code__c, ASI_TH_CRM_Region__c, ASI_HK_CRM_Address__c, Phone, 
                Owner.Name,
                (SELECT Id, Name, Title, Birthdate, MobilePhone, Email FROM Contacts WHERE ASI_HK_CRM_Main_Contact__c = true)
            FROM Account 
            WHERE Id = :idAcc
            LIMIT 1];
        
        if (lstAccounts == null || lstAccounts.size() <= 0)
            throw new ASI_CRM_TW_Function.CRM_TW_Exception('Invalid Account Id (' + idAcc + ')');
        else
        {
            objAccount = lstAccounts[0];
            accountRegion = objAccount.ASI_TH_CRM_Region__c;
            encodedAccountName = EncodingUtil.urlEncode(objAccount.Name, 'UTF-8');
        }
        
        // Visitation Plan Detail
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> lstVPD = [
            SELECT Id, Name,
                ASI_TH_CRM_Visit_Date_Time_From__c, ASI_TH_CRM_Visit_Date_Time_To__c, ASI_HK_CRM_Visit_Date__c,
                ASI_HK_CRM_Visit_Objective__c, ASI_TH_CRM_Activity_Remarks__c,
                ASI_HK_CRM_Cancellation_Reason__c, ASI_HK_CRM_Visitation_Plan__r.Name, ASI_CRM_Date_Difference_Actual_Planned__c,
                ASI_TH_CRM_Objectives__c, ASI_TH_CRM_Who__c, ASI_TH_CRM_Customer__c, ASI_TH_CRM_Consumer__c,
                ASI_TH_CRM_Evaluate_Comment__c, ASI_TH_CRM_Identity_Comment__c, ASI_TH_CRM_Agree_Comment__c, ASI_TH_CRM_Summary_Comment__c,
                ASI_CRM_Visit_Description__c, ASI_CRM_Outlet_Competitor_Activities__c, ASI_TH_CRM_Promotion_Material__c, ASI_TH_CRM_PromotionMaterial_Others__c,
                ASI_CRM_TW_Product_Display__c, ASI_TH_CRM_Special_Display__c, ASI_TH_CRM_BarSupply__c, ASI_TH_CRM_Signage__c, ASI_CRM_Competitor_Market__c,
                ASI_TH_CRM_PRT_Activity__c, ASI_TH_CRM_Competitor_Activity__c
            FROM ASI_HK_CRM_Visitation_Plan_Detail__c
            WHERE Id = :idVisitPlanDetail
        ];

        if (lstVPD == null || lstVPD.size() <= 0)
            throw new ASI_CRM_TW_Function.CRM_TW_Exception('Visitation Plan Detail Not Found (Visitation Plan Id: ' + idVisitPlanDetail + ')');
        else
            objVisitPlanDetail = lstVPD[0];
        system.debug('objVisitPlanDetail: '+objVisitPlanDetail);
        
        //get multi-picklist fields' values
        selectedObjectives = new List<String>();
        selectedWho = new List<String>();
        selectedActivities = new List<String>();
        selectedPromoMaterials = new List<String>();
        selectedProductDisplay = new List<String>();
        selectedSpecialDisplay = new List<String>();
        selectedBarSupply = new List<String>();
        selectedSignage = new List<String>();
        
        selectedObjectives = getMultiSelectValues(objVisitPlanDetail.ASI_TH_CRM_Objectives__c);
        selectedWho = getMultiSelectValues(objVisitPlanDetail.ASI_TH_CRM_Who__c);
        selectedActivities = getMultiSelectValues(objVisitPlanDetail.ASI_CRM_Outlet_Competitor_Activities__c);
        selectedPromoMaterials = getMultiSelectValues(objVisitPlanDetail.ASI_TH_CRM_Promotion_Material__c);
        selectedProductDisplay = getMultiSelectValues(objVisitPlanDetail.ASI_CRM_TW_Product_Display__c);
        selectedSpecialDisplay = getMultiSelectValues(objVisitPlanDetail.ASI_TH_CRM_Special_Display__c);
        selectedBarSupply = getMultiSelectValues(objVisitPlanDetail.ASI_TH_CRM_BarSupply__c);
        selectedSignage = getMultiSelectValues(objVisitPlanDetail.ASI_TH_CRM_Signage__c);
        
        if(objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c == null)
            objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c = System.Now();      
      
        // Page 2 - Sales Movement Record
        lstSalesMovnt = buildSalesMovnt(idAcc, 'PRT');
        if (lstSalesMovnt != null && lstSalesMovnt.size() > 1)
            lstSalesMovnt.Sort();
        system.debug('lstSalesMovnt: '+lstSalesMovnt);
            
        // Page 3 - Competitor Sales Movement Record
        lstSalesMovnt_Competitor = buildSalesMovnt(idAcc, 'Competitor');
        if (lstSalesMovnt_Competitor != null && lstSalesMovnt_Competitor.size() > 1)
            lstSalesMovnt_Competitor.Sort();
        system.debug('lstSalesMovnt_Competitor: '+lstSalesMovnt_Competitor);
    }
    
    public void presencePrtProduct(){
        booleanPresencePrt = true;
    }
    
    public void presenceCompetitorProduct(){
        booleanPresenceCompetitor = true;
    }
    
    //Adding by Twinkle @20160418 - Get multi-picklist fields' values
    public List<String> getMultiSelectValues(String values){
        List<String> selectedValues = new List<String>();
        if(!String.IsEmpty(values)){
            String[] tmpString = values.split(';');
            integer index = 0;
            For(String s : tmpString){
                s = s.replace('[', '').replace(']', '');
                //if(index != 0 && s.length() >= 1 && s[0])
                    //s = s.substring(1,s.length());
                        
                selectedValues.add(s);
                index++;
            }
        }
        system.debug('selectedValues: '+selectedValues);
        return selectedValues;
    }
    
    //Adding by Twinkle @20160418 - Get multi-picklist fields' values
    public String putMultiSelectValues(List<String> values){
        String strObjectives = '';
        if(values.size() > 0){
            //strObjectives = '[';
            for(String s: values){
                strObjectives += s+'; ';
            }
            if(!String.IsEmpty(strObjectives)){
                strObjectives = strObjectives.substring(0,strObjectives.length()-2);
                //strObjectives += ']';
            }
        }
        
        system.debug('strObjectives: '+strObjectives);
        return strObjectives;
    }
    
    /** To save record with draft flag = true, and ignore any validation rules */
    public PageReference quickSave() {
        Boolean saveSuccess = implSaveChanges();
        PageReference redirectPage = null;

        if (saveSuccess) {
            if(isQuickSave)
            {
                lstSalesMovnt = buildSalesMovnt(idAcc, 'PRT');
                if (lstSalesMovnt != null && lstSalesMovnt.size() > 1)
                    lstSalesMovnt.Sort();
                    
                lstSalesMovnt_Competitor = buildSalesMovnt(idAcc, 'Competitor');
                if (lstSalesMovnt_Competitor != null && lstSalesMovnt_Competitor.size() > 1)
                    lstSalesMovnt_Competitor.Sort();
                
                redirectPage = Page.ASI_CRM_TH_WS_OpenVisitFormPage;
                redirectPage.getParameters().put('vpid', objVisitPlanDetail.id);
                redirectPage.getParameters().put('accid', objAccount.id);
                redirectPage.getParameters().put('page', currentPage);
                redirectPage.setRedirect(true);
                
                return redirectPage;
            }
            else
            {
                redirectPage = new PageReference('/'+objVisitPlanDetail.id);
                redirectPage.setRedirect(true);
            }
        }
        return redirectPage;
    }
    
    /** To save record with draft flag = false, need passing all validation rules */
    public PageReference Save() {
        Boolean blnValidation =  true;     
        isQuickSave = false;
        
        return quickSave(); 
    }
    
    public Boolean implSaveChanges() {
        Boolean blnHeaderValidation = true;
        Boolean blnValidation =  true; // Initial set to true
        currentPage = null;
        
        strErrorMessageReason = '';
        strErrorMessageObjectives = '';
        strErrorMessageWho = '';
        
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> lstTemp = [
            SELECT Id, ASI_HK_CRM_Visit_Date__c, ASI_TH_CRM_Objectives__c, ASI_TH_CRM_Who__c FROM ASI_HK_CRM_Visitation_Plan_Detail__c WHERE Id = :objVisitPlanDetail.Id
        ];
        ASI_HK_CRM_Visitation_Plan_Detail__c objVD = new ASI_HK_CRM_Visitation_Plan_Detail__c();
        if (lstTemp != null && lstTemp.size() > 0)
            objVD = lstTemp[0];
        
        //Modified by William Yang 2014-06-17
        if(objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_To__c == null)
            objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_To__c = System.Now();
            
        // Update Visitation Plan Detail
        objVD.ASI_TH_CRM_Visit_Date_Time_From__c = VisitDateF;
        objVD.ASI_TH_CRM_Visit_Date_Time_To__c = VisitDateT;
        objVD.ASI_HK_CRM_Cancellation_Reason__c = strCxlReason;
        objVD.ASI_CRM_Visit_Description__c = objVisitPlanDetail.ASI_CRM_Visit_Description__c;
        objVD.ASI_TH_CRM_PromotionMaterial_Others__c = objVisitPlanDetail.ASI_TH_CRM_PromotionMaterial_Others__c;
        objVD.ASI_TH_CRM_Customer__c = objVisitPlanDetail.ASI_TH_CRM_Customer__c;
        objVD.ASI_TH_CRM_Consumer__c = objVisitPlanDetail.ASI_TH_CRM_Consumer__c;
        objVD.ASI_TH_CRM_Evaluate_Comment__c = objVisitPlanDetail.ASI_TH_CRM_Evaluate_Comment__c;
        objVD.ASI_TH_CRM_Identity_Comment__c = objVisitPlanDetail.ASI_TH_CRM_Identity_Comment__c;
        objVD.ASI_TH_CRM_Agree_Comment__c = objVisitPlanDetail.ASI_TH_CRM_Agree_Comment__c;
        objVD.ASI_TH_CRM_Summary_Comment__c = objVisitPlanDetail.ASI_TH_CRM_Summary_Comment__c;
        objVD.ASI_TH_CRM_PRT_Activity__c = objVisitPlanDetail.ASI_TH_CRM_PRT_Activity__c;
        objVD.ASI_TH_CRM_Competitor_Activity__c = objVisitPlanDetail.ASI_TH_CRM_Competitor_Activity__c;
        objVD.ASI_CRM_Competitor_Market__c = objVisitPlanDetail.ASI_CRM_Competitor_Market__c;
        
        objVD.ASI_TH_CRM_Objectives__c = putMultiSelectValues(selectedObjectives);
        objVD.ASI_TH_CRM_Who__c = putMultiSelectValues(selectedWho);
        objVD.ASI_TH_CRM_Promotion_Material__c = putMultiSelectValues(selectedPromoMaterials);
        objVD.ASI_CRM_TW_Product_Display__c = putMultiSelectValues(selectedProductDisplay);
        objVD.ASI_TH_CRM_Special_Display__c = putMultiSelectValues(selectedSpecialDisplay);
        objVD.ASI_TH_CRM_BarSupply__c = putMultiSelectValues(selectedBarSupply);
        objVD.ASI_TH_CRM_Signage__c = putMultiSelectValues(selectedSignage);
        
        if (VisitDateF.date() > VisitDateT.date()) {
            blnHeaderValidation = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Visit Date (To) should be after Visit Date (From).'));
            //return false;
        }
        if (VisitDateF != null && objVD.ASI_HK_CRM_Visit_Date__c != null && objVD.ASI_HK_CRM_Visit_Date__c != VisitDateF.date() && !(VisitDateF.day() == objVD.ASI_HK_CRM_Visit_Date__c.day()+1 && VisitDateF.hour() < 3)) {
            if (strCxlReason == null || strCxlReason.length() <= 0) {
                blnHeaderValidation = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Visit date differ from planned, please enter reason.'));
                strErrorMessageReason = 'Please specify.';
                //return false;
            }
        }
        
        if (objVD.ASI_TH_CRM_Objectives__c == null || objVD.ASI_TH_CRM_Objectives__c.length() <1) {
            blnHeaderValidation = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Objective is required.'));
            strErrorMessageObjectives = 'Please specify.';
            //return false;
        }
        if (objVD.ASI_TH_CRM_Who__c == null || objVD.ASI_TH_CRM_Who__c.length() <1) {
            blnHeaderValidation = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Who is required.'));
            strErrorMessageWho = 'Please specify.';
            //return false;
        }
        
        if (blnHeaderValidation == true){
            objVD.ASI_HK_CRM_Status__c = 'Achieved';
            update objVD;
        }
        else{
            return false;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Visit date (From) differ from planned visit date, please enter "Reason". '));
        }
               
        Boolean blnIsError = false;
        
        List<ASI_CRM_Sales_Movement__c> lstUpsertSalesMovnt = new List<ASI_CRM_Sales_Movement__c>();
        //Sales Movement from Page 1
        for (SalesMovnt salesMovnt : lstSalesMovnt){  
            salesMovnt.strErrorMessagePrecense = '';
            salesMovnt.strErrorMessageVisibility = '';
            salesMovnt.strErrorMessageCurrentStock = '';
            salesMovnt.strErrorMessageSellingPrice = '';         
            
            if(booleanPresencePrt){
                if(String.IsEmpty(salesMovnt.strSalesMovntPresence)){
                    salesMovnt.strErrorMessagePrecense = 'Please specify.';
                    CurrentPage = '1';
                    blnIsError = true;
                }
                else if(salesMovnt.strSalesMovntPresence == 'Y'){
                    if(salesMovnt.decCurrentStock == null || salesMovnt.decCurrentStock == 0){
                        salesMovnt.strErrorMessageCurrentStock = 'Please specify and it cannot be 0.';
                        CurrentPage = '1';
                        blnIsError = true;
                    }
                    if(salesMovnt.decListPrice == null || salesMovnt.decListPrice == 0){
                        salesMovnt.strErrorMessageSellingPrice = 'Please specify and it cannot be 0.';
                        CurrentPage = '1';
                        blnIsError = true;
                    }
                }
                else{
                    if(salesMovnt.strSalesMovntVisibility == 'Y'){
                        salesMovnt.strErrorMessageVisibility = 'It cannot be Yes as Precense is No.';
                        CurrentPage = '1';
                        blnIsError = true;
                    }
                    if(salesMovnt.decCurrentStock != 0){
                        salesMovnt.strErrorMessageCurrentStock = 'It must be 0 as Precense is No.';
                        CurrentPage = '1';
                        blnIsError = true;
                    }
                }
                ASI_CRM_Sales_Movement__c sm = new ASI_CRM_Sales_Movement__c ();            
                sm.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Sales_Movement__cASI_CRM_TH_SalesMovement');    
                sm.id = salesMovnt.idRec;
                sm.ASI_CRM_VisitationPlanDetail__c = objVisitPlanDetail.id;
                sm.ASI_CRM_Account__c = objAccount.id;            
                sm.ASI_CRM_Sub_brand__c = salesMovnt.idSubBrand;
                sm.ASI_CRM_Date__c = VisitDateF.date();
                sm.ASI_CRM_Selling_Price__c = salesMovnt.decListPrice;
                sm.ASI_CRM_Current_Stock__c = salesMovnt.decCurrentStock;
                
                if(salesMovnt.strSalesMovntPresence == 'Y')
                    sm.ASI_CRM_Presence__c = true;
                else if(salesMovnt.strSalesMovntPresence == 'N')
                    sm.ASI_CRM_Presence__c = false;
                if(salesMovnt.strSalesMovntVisibility == 'Y')
                    sm.ASI_CRM_Visibility__c = true;
                else if(salesMovnt.strSalesMovntVisibility == 'N')
                    sm.ASI_CRM_Visibility__c = false;         
                
                lstUpsertSalesMovnt.add(sm);
            }
        }
        
        //Competitor Sales Movement from Page 2
        for (SalesMovnt salesMovnt : lstSalesMovnt_Competitor){  
            salesMovnt.strErrorMessagePrecense = '';
            salesMovnt.strErrorMessageVisibility = '';
            salesMovnt.strErrorMessageCurrentStock = '';
            salesMovnt.strErrorMessageSellingPrice = '';  
            
            if(booleanPresenceCompetitor){
                if(String.IsEmpty(salesMovnt.strSalesMovntPresence)){      
                    salesMovnt.strErrorMessagePrecense = 'Please specify.';
                    if(CurrentPage == null)
                        CurrentPage = '2';
                    blnIsError = true;
                }
                else if(salesMovnt.strSalesMovntPresence == 'Y'){
                    if(salesMovnt.decCurrentStock == null || salesMovnt.decCurrentStock == 0){
                        salesMovnt.strErrorMessageCurrentStock = 'Please specify and it cannot be 0.';
                        if(CurrentPage == null)
                            CurrentPage = '2';
                        blnIsError = true;
                    }
                    if(salesMovnt.decListPrice == null || salesMovnt.decListPrice == 0){
                        salesMovnt.strErrorMessageSellingPrice = 'Please specify and it cannot be 0.';
                        if(CurrentPage == null)
                            CurrentPage = '2';
                        blnIsError = true;
                    }
                }
                else{
                    if(salesMovnt.strSalesMovntVisibility == 'Y'){
                        salesMovnt.strErrorMessageVisibility = 'It cannot be Yes as Precense is No.';
                        if(CurrentPage == null)
                            CurrentPage = '2';
                        blnIsError = true;
                    }
                    if(salesMovnt.decCurrentStock != 0){
                        salesMovnt.strErrorMessageCurrentStock = 'It must be 0 as Precense is No.';
                        if(CurrentPage == null)
                            CurrentPage = '2';
                        blnIsError = true;
                    }
                }
                ASI_CRM_Sales_Movement__c sm = new ASI_CRM_Sales_Movement__c ();                                    
            
                sm.id = salesMovnt.idRec;
                sm.ASI_CRM_VisitationPlanDetail__c = objVisitPlanDetail.id;
                sm.ASI_CRM_Account__c = objAccount.id;            
                sm.ASI_CRM_Sub_brand__c = salesMovnt.idSubBrand;
                sm.ASI_CRM_Date__c = VisitDateF.date();
                sm.ASI_CRM_Selling_Price__c = salesMovnt.decListPrice;
                sm.ASI_CRM_Current_Stock__c = salesMovnt.decCurrentStock;
                
                if(salesMovnt.strSalesMovntPresence == 'Y')
                    sm.ASI_CRM_Presence__c = true;
                else if(salesMovnt.strSalesMovntPresence == 'N')
                    sm.ASI_CRM_Presence__c = false;
                if(salesMovnt.strSalesMovntVisibility == 'Y')
                    sm.ASI_CRM_Visibility__c = true;
                else if(salesMovnt.strSalesMovntVisibility == 'N')
                    sm.ASI_CRM_Visibility__c = false;         
                
                lstUpsertSalesMovnt.add(sm);
            }
        }
        
        if (blnIsError == true){ 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Please follow the error message(s) belows to correct the data.'));
            return false;
        }
        else
        {
            if(lstUpsertSalesMovnt != null && lstUpsertSalesMovnt.size() > 0){
                upsert lstUpsertSalesMovnt;
            }
            return true;
        }
    }
    
    /*** For PRT/Competitor Sales Movement Page 2 & Page 3 */
    private List<SalesMovnt> buildSalesMovnt(id idAcc, String type) {
        Map<Id, SalesMovnt> mapRes = new Map<Id, SalesMovnt>();
        Map<Id, ASI_CRM_Sales_Movement__c> mapLastRes = new Map<Id, ASI_CRM_Sales_Movement__c>();
        Map<Id, Decimal> mapActualOfftake = new Map<Id, Decimal>();
        
        String strVisitYear = String.ValueOf(VisitDateF.year());
        String strVisitMonth = String.ValueOf(VisitDateF.month());
        String strLastVisitYear = '';//String.ValueOf(VisitDateF.addMonths(-1).year());
        String strLastVisitMonth = '';//String.ValueOf(VisitDateF.addMonths(-1).month());
        
        List<ASI_MFM_Sub_brand__c> listSubBrand = new List<ASI_MFM_Sub_brand__c>();
        if(type == 'Competitor')
            listSubBrand = [SELECT id, Name, ASI_CRM_Product_Group_3__c FROM ASI_MFM_Sub_brand__c 
                            WHERE recordType.developerName = 'ASI_TH_CRM_Sub_brand' AND ASI_CRM_WS_Visit__c = true 
                            AND ASI_TH_CRM_Active__c = true
                            AND ASI_TH_CRM_Product_Group_1__c LIKE '%Competitor%'];
        else if(type == 'PRT')
            listSubBrand = [SELECT id, Name, ASI_CRM_Product_Group_3__c FROM ASI_MFM_Sub_brand__c 
                            WHERE recordType.developerName = 'ASI_TH_CRM_Sub_brand' AND ASI_CRM_WS_Visit__c = true
                            AND ASI_TH_CRM_Active__c = true 
                            AND (NOT ASI_TH_CRM_Product_Group_1__c LIKE '%Competitor%')];
            
        Set<id> setSubBrandId = new Set<id>();
        for (ASI_MFM_Sub_brand__c sb : listSubBrand) {
            setSubBrandId.add(sb.id);
        }
        
        // Get saved Sales Movement Detail Record
        List<ASI_CRM_Sales_Movement__c> lstSalesMovntRec = [
            SELECT Id, ASI_CRM_Account__c,
                ASI_CRM_Actual_RSP__c, ASI_CRM_Date__c, 
                ASI_CRM_Distribution__c, ASI_CRM_Draft_Flag__c,
                ASI_CRM_Facing__c, ASI_CRM_Selling_Price__c,
                ASI_CRM_Sub_brand__c, ASI_CRM_VisitationPlanDetail__c,
                ASI_CRM_Sub_brand__r.Name,
                ASI_CRM_Presence__c, ASI_CRM_Visibility__c,
                ASI_CRM_Sub_brand__r.ASI_CRM_Product_Group_3__c,
                ASI_CRM_Current_Stock__c, ASI_CRM_Month__c, ASI_CRM_Year__c
            FROM ASI_CRM_Sales_Movement__c
            WHERE ASI_CRM_Account__c = :idAcc
            /*AND ASI_CRM_Year__c = :strVisitYear
            AND ASI_CRM_Month__c = :strVisitMonth*/
            ORDER BY ASI_CRM_Date__c DESC 
        ];
        system.debug('lstSalesMovntRec: '+lstSalesMovntRec);
        
        for (ASI_CRM_Sales_Movement__c objSalesMovntRec : lstSalesMovntRec) {
            if(strLastVisitYear == '' && strLastVisitMonth == ''){
                strLastVisitYear = objSalesMovntRec.ASI_CRM_Year__c;
                strLastVisitMonth = objSalesMovntRec.ASI_CRM_Month__c;
            }
            if(objSalesMovntRec.ASI_CRM_Year__c == strLastVisitYear && objSalesMovntRec.ASI_CRM_Month__c == strLastVisitMonth){
                if(objSalesMovntRec.ASI_CRM_Year__c == strVisitYear && objSalesMovntRec.ASI_CRM_Month__c == strVisitMonth){
                    SalesMovnt sm = new SalesMovnt();
                    sm.idRec = objSalesMovntRec.Id;
                    sm.idSubBrand = objSalesMovntRec.ASI_CRM_Sub_brand__c;
                    sm.strSubBrand = objSalesMovntRec.ASI_CRM_Sub_brand__r.Name;
                    sm.strPriority = ''; 
                    sm.decListPrice = objSalesMovntRec.ASI_CRM_Selling_Price__c;
                    sm.strSalesMovntPresence = (objSalesMovntRec.ASI_CRM_Presence__c) ? 'Y' : 'N';
                    sm.strSalesMovntVisibility = (objSalesMovntRec.ASI_CRM_Visibility__c) ? 'Y' : 'N';
                    sm.strProductGroup3 = objSalesMovntRec.ASI_CRM_Sub_brand__r.ASI_CRM_Product_Group_3__c;
                    if(type == 'Competitor' && sm.strProductGroup3 == null)
                        sm.strProductGroup3 = objSalesMovntRec.ASI_CRM_Sub_brand__r.Name;
                    sm.decCurrentStock = objSalesMovntRec.ASI_CRM_Current_Stock__c;
                    
                    if(setSubBrandId.contains(objSalesMovntRec.ASI_CRM_Sub_brand__c))
                        mapRes.put(objSalesMovntRec.ASI_CRM_Sub_brand__c, sm);
                }
                else{
                    if(setSubBrandId.contains(objSalesMovntRec.ASI_CRM_Sub_brand__c))
                        mapLastRes.put(objSalesMovntRec.ASI_CRM_Sub_brand__c, objSalesMovntRec);
                }
            }
            else
                break;
        }
        system.debug('1.mapRes: '+mapRes);
        system.debug('1.mapLastRes: '+mapLastRes);
        
        // Get Last Month Sales Movement Detail Record
        /*lstSalesMovntRec = [
            SELECT Id, ASI_CRM_Account__c,
                ASI_CRM_Actual_RSP__c, ASI_CRM_Date__c, 
                ASI_CRM_Distribution__c, ASI_CRM_Draft_Flag__c,
                ASI_CRM_Facing__c, ASI_CRM_Selling_Price__c,
                ASI_CRM_Sub_brand__c, ASI_CRM_VisitationPlanDetail__c,
                ASI_CRM_Sub_brand__r.Name,
                ASI_CRM_Presence__c, ASI_CRM_Visibility__c,
                ASI_CRM_Sub_brand__r.ASI_CRM_Product_Group_3__c,
                ASI_CRM_Current_Stock__c
            FROM ASI_CRM_Sales_Movement__c
            WHERE ASI_CRM_Account__c = :idAcc
            AND ASI_CRM_Year__c = :strLastVisitYear 
            AND ASI_CRM_Month__c = :strLastVisitMonth 
            ORDER BY ASI_CRM_Sub_brand__r.ASI_CRM_Product_Group_3__c
        ];
        system.debug('lstSalesMovntRec: '+lstSalesMovntRec);
        
        for (ASI_CRM_Sales_Movement__c objSalesMovntRec : lstSalesMovntRec) {            
            mapLastMonthRes.put(objSalesMovntRec.ASI_CRM_Sub_brand__c, objSalesMovntRec );
        }*/
        
        for (ASI_MFM_Sub_brand__c sb : listSubBrand) {
            SalesMovnt sm = new SalesMovnt();
            Boolean blnExists = false;
            if (mapRes.containsKey(sb.id))
                blnExists = true;
            
            if (blnExists) {
                sm = mapRes.get(sb.id);                                                
            } else {
                if (mapLastRes.containsKey(sb.id)){
                    ASI_CRM_Sales_Movement__c lastMonthSalesMovnt = (ASI_CRM_Sales_Movement__c)mapLastRes.get(sb.id);                    
                    sm.decListPrice = lastMonthSalesMovnt.ASI_CRM_Selling_Price__c;
                    sm.strSalesMovntPresence = (lastMonthSalesMovnt.ASI_CRM_Presence__c) ? 'Y' : 'N';
                    sm.strSalesMovntVisibility = (lastMonthSalesMovnt.ASI_CRM_Visibility__c) ? 'Y' : 'N';
                    sm.decCurrentStock = lastMonthSalesMovnt.ASI_CRM_Current_Stock__c;                          
                }
            }             
            
            sm.idSubBrand = sb.id;
            sm.strSubBrand = sb.Name;
            sm.strProductGroup3 = sb.ASI_CRM_Product_Group_3__c;
            if(type == 'Competitor' && sm.strProductGroup3 == null)
                sm.strProductGroup3 = sb.Name;
            
            if(setSubBrandId.contains(sb.id))
                mapRes.put(sb.id, sm);
        }      
        system.debug('2.mapRes: '+mapRes);  
        
        return mapRes.values();
    }

    @RemoteAction
    public static String insertAttachment(String strParentID, String attachmentBody, String attachmentName, String pType, String attachmentId) {   
        if(attachmentBody != null) {
            Attachment att = getAttachment(attachmentId);
            String newBody = '';
            if(att.Body != null) {
                newBody = EncodingUtil.base64Encode(att.Body);
            }
            newBody += attachmentBody;
            att.Body = EncodingUtil.base64Decode(newBody);
            if(attachmentId == null) {
                att.Name = attachmentName;
                att.parentId = strParentID;
            }
            upsert att;
            return att.Id;
        } else {
            return 'Attachment Body was null';
        }
    }
    
    public static String fileSeq(Integer i) {
        String strTemp = String.valueOf(i);
        
        if (strTemp == null) return '';
        if (strTemp.length() == 1) return '0000' + String.valueOf(i);
        if (strTemp.length() == 2) return '000' + String.valueOf(i);
        if (strTemp.length() == 3) return '00' + String.valueOf(i);
        if (strTemp.length() == 4) return '0' + String.valueOf(i);
        return strTemp;
    }
    
    private static Attachment getAttachment(String attId) {
        list<Attachment> attachments = [SELECT Id, Body
                                        FROM Attachment 
                                        WHERE Id =: attId];
        if(attachments.isEmpty()) {
            Attachment a = new Attachment();
            return a;
        } else {
            return attachments[0];
        }
    }
}