/*********************************************************************************
 * Name: ASI_CRM_TH_Outlet_OpenVisitFormCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 08/04/2016       Introv: Twinkle         Created
*********************************************************************************/
global without sharing class ASI_CRM_TH_Outlet_OpenVisitFormCtrl {
    public String strVPDFromDate { get; set; }
    public String strVPID { get; set; }
    public Account objAccount { get; private set; }
    public ASI_CRM_AccountsAdditionalField__c objAccountAddt { get; private set; }
    public ASI_HK_CRM_Visitation_Plan_Detail__c objVisitPlanDetail { get; private set; }
    public List<SalesMovnt> lstSalesMovnt { get; private set; }
    public List<PromoStatus> lstPromoStatus { get; private set; }
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
    
    //Added by Twinkle 11/07/2014
    public List<ASI_CRM_Promotion_Status__c> lstPromoStatusRec { get; set; }
    public Map<String, PromoStatus> mapRemovePromoStatus = new Map<String, PromoStatus>();
    public String theRow { get; set; }
    public List<Integer> lstaddRows;
    public Integer index = 10000;
    
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
    public String strErrorMessagePromoMtOthers { get; set; }
    public String strErrorMessageBarSupplyOthers { get; set; }
    public String strErrorMessageSignageOthers { get; set; }
    
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
        get { return objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_To__c == null ? objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c.addHours(3) : objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_To__c; }
        set { objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_To__c = value; }
    }
    public String strOutletTypeCode {
        get { return objAccountAddt.ASI_TH_CRM_OutletType__r.ASI_TH_CRM_Code__c; }
        set { objAccountAddt.ASI_TH_CRM_OutletType__r.ASI_TH_CRM_Code__c = value; }
    }
    
    //get multi-picklist values
    public List<SelectOption> getPromoTypeList() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = ASI_HK_CRM_Promotion__c.ASI_CRM_Type__c.getDescribe();
        List<Schema.PicklistEntry> promoTypelist = fieldResult.getPicklistValues();
            
        for(Schema.PicklistEntry f : promoTypelist){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    } 
   
    
    public List<SelectOption> getObjectiveList() {    
        List<SelectOption> options = new List<SelectOption>();
        
        /*Schema.DescribeFieldResult fieldResult = ASI_HK_CRM_Visitation_Plan_Detail__c.ASI_TH_CRM_Objectives__c.getDescribe();
        List<Schema.PicklistEntry> statuslist = fieldResult.getPicklistValues();
            
        for(Schema.PicklistEntry f : statuslist){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }*/
        
        ASI_CRM_TH_Picklist_Setting__c listPicklistValues  = [SELECT ASI_CRM_Value__c FROM ASI_CRM_TH_Picklist_Setting__c 
                                                              WHERE ASI_CRM_Object__c = 'ASI_HK_CRM_Visitation_Plan_Detail__c' 
                                                              AND ASI_CRM_Record_Type__c = 'ASI_TH_CRM_Visitation_Plan_Detail' 
                                                              AND ASI_CRM_Field__c = 'ASI_TH_CRM_Objectives__c' 
                                                              AND Name = 'VPD Objectives (Outlet)' LIMIT 1];
        
        String[] tmpString = listPicklistValues.ASI_CRM_Value__c.split(';');
        integer index = 0;
        For(String s : tmpString){
            s = s.replace('[', '').replace(']', '');
            options.add(new SelectOption(S, S));
            index++;
        }
        return options;
    } 
    
    public List<SelectOption> getWhoList() {
        List<SelectOption> options = new List<SelectOption>();
        
        /*Schema.DescribeFieldResult fieldResult = ASI_HK_CRM_Visitation_Plan_Detail__c.ASI_TH_CRM_Who__c.getDescribe();
        List<Schema.PicklistEntry> statuslist = fieldResult.getPicklistValues();
            
        for(Schema.PicklistEntry f : statuslist){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }*/ 
        
        ASI_CRM_TH_Picklist_Setting__c listPicklistValues  = [SELECT ASI_CRM_Value__c FROM ASI_CRM_TH_Picklist_Setting__c 
                                                              WHERE ASI_CRM_Object__c = 'ASI_HK_CRM_Visitation_Plan_Detail__c' 
                                                              AND ASI_CRM_Record_Type__c = 'ASI_TH_CRM_Visitation_Plan_Detail' 
                                                              AND ASI_CRM_Field__c = 'ASI_TH_CRM_Who__c' 
                                                              AND Name = 'VPD Who (Outlet)' LIMIT 1];
        
        String[] tmpString = listPicklistValues.ASI_CRM_Value__c.split(';');
        integer index = 0;
        For(String s : tmpString){
            s = s.replace('[', '').replace(']', '');
            options.add(new SelectOption(S, S));
            index++;
        }
        return options;
    } 
    
    public List<SelectOption> getActivitiesList() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = ASI_HK_CRM_Visitation_Plan_Detail__c.ASI_CRM_Outlet_Competitor_Activities__c.getDescribe();
        List<Schema.PicklistEntry> statuslist = fieldResult.getPicklistValues();
            
        for(Schema.PicklistEntry f : statuslist){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    } 
    
    public List<SelectOption> getPromoMaterialsList() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = ASI_HK_CRM_Visitation_Plan_Detail__c.ASI_TH_CRM_Promotion_Material__c.getDescribe();
        List<Schema.PicklistEntry> statuslist = fieldResult.getPicklistValues();
            
        for(Schema.PicklistEntry f : statuslist){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    } 
    
    public List<SelectOption> getProductDisplayList() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = ASI_HK_CRM_Visitation_Plan_Detail__c.ASI_CRM_TW_Product_Display__c.getDescribe();
        List<Schema.PicklistEntry> statuslist = fieldResult.getPicklistValues();
            
        for(Schema.PicklistEntry f : statuslist){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    } 
    
    public List<SelectOption> getSpecialDisplayList() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = ASI_HK_CRM_Visitation_Plan_Detail__c.ASI_TH_CRM_Special_Display__c.getDescribe();
        List<Schema.PicklistEntry> statuslist = fieldResult.getPicklistValues();
            
        for(Schema.PicklistEntry f : statuslist){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<SelectOption> getBarSupplyList() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = ASI_HK_CRM_Visitation_Plan_Detail__c.ASI_TH_CRM_BarSupply__c.getDescribe();
        List<Schema.PicklistEntry> statuslist = fieldResult.getPicklistValues();
            
        for(Schema.PicklistEntry f : statuslist){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<SelectOption> getSignageList() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = ASI_HK_CRM_Visitation_Plan_Detail__c.ASI_TH_CRM_Signage__c.getDescribe();
        List<Schema.PicklistEntry> statuslist = fieldResult.getPicklistValues();
            
        for(Schema.PicklistEntry f : statuslist){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    global class SalesMovnt implements Comparable{
        public String idRec { get; private set; }
        public Id idSubBrand { get; private set; }
        public String strSubBrand { get; private set; }
        public String strPriority { get; private set; }
        public Decimal decPrioritySorting { get; private set; }
        public String strQTDPurchase { get; private set; }
        public Decimal decListPrice { get; set; }
        public String strSalesMovntPresence { get; set; }
        public String strSalesMovntVisibility { get; set; }
        public String strProductGroup3 { get; set; }
        
        global Integer compareTo(Object compareTo) {                     
            SalesMovnt compareToSalesMovnt = (SalesMovnt)compareTo;
            if (decPrioritySorting  == compareToSalesMovnt.decPrioritySorting ) return 0;
            if (decPrioritySorting > compareToSalesMovnt.decPrioritySorting ) return 1;
            return -1;        
        }
        
        public String strErrorMessagePrecense { get; set; }
        public String strErrorMessageVisibility { get; set; }
        public String strErrorMessageMenuPrice { get; set; }
    }        
    
    global class PromoStatus implements Comparable{
        public String idRec { get; private set; }
        public Id idPromo { get; private set; }
        public Id idAttachment { get; set; }
        public String strPromo { get; private set; }
        public String strDesc { get; private set; }
        public Datetime dteStart { get; private set; }
        public Datetime dteEnd{ get; private set; }
        public Date dtePurchaseDue { get; private set; }
        public String strPromoOpt { get; set; }
        
        public String promoType { get; set; }
        public Decimal gwpAllocation { get; set; }
        public Decimal volTarget { get; set; }
        public Date joinDate { get; set; }
        public String status { get; set; }
        public Date dtePromoStart { get; set; }
        public Date dtePromoEnd { get; set; }
        
        public Integer intRowIndex {get;set;}
        
        global Integer compareTo(Object compareTo) {                
            PromoStatus compareToPromoStatus = (PromoStatus)compareTo;
            if (dtePurchaseDue > compareToPromoStatus.dtePurchaseDue) return 1;
            else if (dtePurchaseDue < compareToPromoStatus.dtePurchaseDue) return -1;
            else return 0;        
        }
        
        public String strErrorMessageActivityDate { get; set; }
        public String strErrorMessageGWPAllocation { get; set; }
        public String strErrorMessageVolTarget { get; set; }
        
        public Boolean boolEventOrTasting { get; set; }
        public Boolean boolGWP { get; set; }
    }
    
    public PageReference errorMessage(){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot edit the plan, as  it is 7 days before the plannd date.'));
        return null;
    }
    
    public ASI_CRM_TH_Outlet_OpenVisitFormCtrl(ApexPages.StandardController stdController) {
        lstaddRows = new List<Integer>();
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
        else{
            objAccount = lstAccounts[0];
            accountRegion = objAccount.ASI_TH_CRM_Region__c;
            encodedAccountName = EncodingUtil.urlEncode(objAccount.Name, 'UTF-8');
        }
        // Obtain Account Additional (Customer) fields
        List<ASI_CRM_AccountsAdditionalField__c> lstAccAddt = [
            SELECT Id, Name, ASI_CRM_Channel__c, ASI_CRM_CN_Sub_Channel__r.Name,
                ASI_CRM_CN_Sub_Channel__c, ASI_TH_CRM_OutletImage__c,
                ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c,
                ASI_TH_CRM_OutletImage__r.Name, ASI_CRM_Sales_Potential__c,
                ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c,
                ASI_TH_CRM_OutletType__c, ASI_TH_CRM_OutletSubType__c,
                ASI_TH_CRM_OutletSubType__r.Name,
                ASI_TH_CRM_OutletType__r.ASI_TH_CRM_Code__c,
                ASI_CRM_Service_Pack__c
            FROM ASI_CRM_AccountsAdditionalField__c 
            WHERE ASI_CRM_Account__c = :idAcc
            LIMIT 1
        ];
        
        if (lstAccAddt == null || lstAccAddt.size() <= 0)
            throw new ASI_CRM_TW_Function.CRM_TW_Exception('Customer Record Not Found (Account Id: ' + idAcc + ')');
        else
            objAccountAddt = lstAccAddt[0];
        
        // Visitation Plan Detail
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> lstVPD = [
            SELECT Id, Name,
                ASI_TH_CRM_Visit_Date_Time_From__c, ASI_TH_CRM_Visit_Date_Time_To__c, ASI_HK_CRM_Visit_Date__c,
                ASI_HK_CRM_Visit_Objective__c, ASI_TH_CRM_Activity_Remarks__c,
                ASI_HK_CRM_Cancellation_Reason__c, ASI_HK_CRM_Visitation_Plan__r.Name, ASI_CRM_Date_Difference_Actual_Planned__c,
                ASI_TH_CRM_Objectives__c, ASI_TH_CRM_Who__c, ASI_TH_CRM_Customer__c, ASI_TH_CRM_Consumer__c,
                ASI_TH_CRM_Evaluate_Comment__c, ASI_TH_CRM_Identity_Comment__c, ASI_TH_CRM_Agree_Comment__c, ASI_TH_CRM_Summary_Comment__c,
                ASI_CRM_Visit_Description__c, ASI_CRM_Outlet_Competitor_Activities__c, ASI_TH_CRM_Promotion_Material__c, 
                ASI_TH_CRM_PromotionMaterial_Others__c, ASI_TH_CRM_BarSupply_Others__c, ASI_TH_CRM_Signage_Others__c,
                ASI_CRM_TW_Product_Display__c, ASI_TH_CRM_Special_Display__c, ASI_TH_CRM_BarSupply__c, ASI_TH_CRM_Signage__c,
                ASI_HK_CRM_Account__r.ASI_KOR_Customer_Code__c
            FROM ASI_HK_CRM_Visitation_Plan_Detail__c
            WHERE Id = :idVisitPlanDetail
        ];

        if (lstVPD == null || lstVPD.size() <= 0)
            throw new ASI_CRM_TW_Function.CRM_TW_Exception('Visitation Plan Detail Not Found (Visitation Plan Id: ' + idVisitPlanDetail + ')');
        else{
            objVisitPlanDetail = lstVPD[0];
            
            //Added by Twinkle @20160523 - get visit date
            if(lstVPD[0].ASI_TH_CRM_Visit_Date_Time_From__c != null){
                Date visitDate = date.newinstance(lstVPD[0].ASI_TH_CRM_Visit_Date_Time_From__c.year(), lstVPD[0].ASI_TH_CRM_Visit_Date_Time_From__c.month(), lstVPD[0].ASI_TH_CRM_Visit_Date_Time_From__c.day());
                strVPDFromDate = string.valueof(visitDate);
            }
        }
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
        
        //Added by William Yang 2014-06-17
        if(objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c == null)
            objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c = System.Now();
        //End       
       
        // Page 1 - Sales Movement Record
        lstSalesMovnt = buildSalesMovnt(idAcc, idVisitPlanDetail, objAccountAddt.ASI_CRM_Service_Pack__c);
        if (lstSalesMovnt != null && lstSalesMovnt.size() > 1)
            lstSalesMovnt.Sort();
            
        // Page 2 - Competitor Sales Movement Record
        lstSalesMovnt_Competitor = buildSalesMovnt_Competitor(idAcc);
        if (lstSalesMovnt_Competitor != null && lstSalesMovnt_Competitor.size() > 1)
            lstSalesMovnt_Competitor.Sort();
        
        // Page 3 - Promotional Detail Record
        lstPromoStatus = buildPromoStatus(idAcc, idVisitPlanDetail, strOutletTypeCode, (VisitDateF == null ? System.now().date() : VisitDateF.date()));
        if (lstPromoStatus != null && lstPromoStatus.size() > 1)
            lstPromoStatus.Sort();
        system.debug(lstPromoStatus);        
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
    
    //Added by Twinkle 20141128 - Add a row in promo status
    public void AddRow(){
        Map<Integer, PromoStatus> mapCount = new Map<Integer, PromoStatus>();

        Integer rowIndex;
        if(theRow == null)
            rowIndex = 0;
        else
            rowIndex = Integer.valueof(theRow)-1;
        
        lstaddRows.add(rowIndex);   
        for(integer i = 0; i < lstPromoStatus.size(); i++){
            mapCount.put(i, lstPromoStatus[i]);
        }
        
        if(mapCount != null && mapCount.size()>0 && lstaddRows != null && lstaddRows.size() > 0){  
            PromoStatus ps = new PromoStatus();   
            Integer tempRow = lstaddRows[lstaddRows.size()-1];
            
            if(mapCount.get(tempRow) != null){
                ps.intRowIndex = lstPromoStatus.size()+1;
                ps.idRec = '#'+lstaddRows.size();
                ps.idPromo = mapCount.get(tempRow).idPromo;          
                ps.strPromo = mapCount.get(tempRow).strPromo;
                ps.strDesc = mapCount.get(tempRow).strDesc;
                ps.dteStart = mapCount.get(tempRow).dteStart;
                ps.dteEnd = mapCount.get(tempRow).dteEnd;
                ps.dtePurchaseDue = mapCount.get(tempRow).dtePurchaseDue;
                ps.strPromoOpt = 'N';
                ps.promoType = mapCount.get(tempRow).promoType;
                ps.joinDate = mapCount.get(tempRow).joinDate;
                ps.volTarget = mapCount.get(tempRow).volTarget;
                ps.gwpAllocation = mapCount.get(tempRow).gwpAllocation;
                ps.status = mapCount.get(tempRow).status;
                ps.dtePromoStart = mapCount.get(tempRow).dtePromoStart;
                ps.dtePromoEnd = mapCount.get(tempRow).dtePromoEnd;
                
                if(ps.promoType == 'Event' || ps.promoType == 'Tasting'){
                    ps.boolEventOrTasting = true;
                    ps.boolGWP = false;
                }
                else{
                    ps.boolEventOrTasting = false;
                    ps.boolGWP = true;
                }

                lstPromoStatus.add(ps);
                system.debug('Add Row (ps): '+ps);
            }
        }
        
        if (lstPromoStatus != null && lstPromoStatus.size() > 1)
            lstPromoStatus.Sort();       
    }
    
    //Added by Twinkle 20141128 - Remove a row in promo status
    public void RemoveRow(){  
        system.debug('Before remove: '+lstPromoStatus);
        Integer rowIndex;
        if(theRow == null)
            rowIndex = 0;
        else
            rowIndex = Integer.valueof(theRow)-1;
            
        mapRemovePromoStatus.put(lstPromoStatus[rowIndex].idRec, lstPromoStatus[rowIndex]);
        lstPromoStatus.remove(rowIndex);
        system.debug('After removed: '+lstPromoStatus);
    }

    /** To save record with draft flag = true, and ignore any validation rules */
    public PageReference quickSave() {
        Boolean saveSuccess = implSaveChanges();
        PageReference redirectPage = null;

        if (saveSuccess) {
            if(isQuickSave)
            {
                lstSalesMovnt = buildSalesMovnt(idAcc, idVisitPlanDetail, objAccountAddt.ASI_CRM_Service_Pack__c);
                if (lstSalesMovnt != null && lstSalesMovnt.size() > 1)
                    lstSalesMovnt.Sort();
                    
                lstSalesMovnt_Competitor = buildSalesMovnt_Competitor(idAcc);
                if (lstSalesMovnt_Competitor != null && lstSalesMovnt_Competitor.size() > 1)
                    lstSalesMovnt_Competitor.Sort();
                
                lstPromoStatus = buildPromoStatus(idAcc, idVisitPlanDetail, strOutletTypeCode, (VisitDateF == null ? System.now().date() : VisitDateF.date()));
                if (lstPromoStatus != null && lstPromoStatus.size() > 1)
                    lstPromoStatus.Sort();
                lstPromoStatus=null;
                
                redirectPage = Page.ASI_CRM_TH_Outlet_OpenVisitFormPage;
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
        System.debug('Debug Line 606');
        Boolean blnHeaderValidation = true;
        Boolean blnValidation =  true; // Initial set to true
        currentPage = null;
        
        strErrorMessageReason = '';
        strErrorMessageObjectives = '';
        strErrorMessageWho = '';
        strErrorMessagePromoMtOthers = '';
        strErrorMessageBarSupplyOthers = '';
        strErrorMessageSignageOthers = '';
        
        System.debug('Debug Line 617');
        
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> lstTemp = [
            SELECT Id, ASI_HK_CRM_Visit_Date__c, ASI_TH_CRM_Objectives__c, ASI_TH_CRM_Who__c FROM ASI_HK_CRM_Visitation_Plan_Detail__c WHERE Id = :objVisitPlanDetail.Id
        ];
        ASI_HK_CRM_Visitation_Plan_Detail__c objVD = new ASI_HK_CRM_Visitation_Plan_Detail__c();
        if (lstTemp != null && lstTemp.size() > 0)
            objVD = lstTemp[0];
        
        System.debug('Debug Line 627');
        
        if(objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_To__c == null)
            objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_To__c = System.Now();      
        
        // Update Visitation Plan Detail
        objVD.ASI_TH_CRM_Visit_Date_Time_From__c = VisitDateF;
        objVD.ASI_TH_CRM_Visit_Date_Time_To__c = VisitDateT;
        objVD.ASI_HK_CRM_Cancellation_Reason__c = strCxlReason;
        objVD.ASI_CRM_Visit_Description__c = objVisitPlanDetail.ASI_CRM_Visit_Description__c;
        objVD.ASI_TH_CRM_PromotionMaterial_Others__c = objVisitPlanDetail.ASI_TH_CRM_PromotionMaterial_Others__c;
        objVD.ASI_TH_CRM_BarSupply_Others__c = objVisitPlanDetail.ASI_TH_CRM_BarSupply_Others__c;
        objVD.ASI_TH_CRM_Signage_Others__c = objVisitPlanDetail.ASI_TH_CRM_Signage_Others__c;
        objVD.ASI_TH_CRM_Customer__c = objVisitPlanDetail.ASI_TH_CRM_Customer__c;
        objVD.ASI_TH_CRM_Consumer__c = objVisitPlanDetail.ASI_TH_CRM_Consumer__c;
        objVD.ASI_TH_CRM_Evaluate_Comment__c = objVisitPlanDetail.ASI_TH_CRM_Evaluate_Comment__c;
        objVD.ASI_TH_CRM_Identity_Comment__c = objVisitPlanDetail.ASI_TH_CRM_Identity_Comment__c;
        objVD.ASI_TH_CRM_Agree_Comment__c = objVisitPlanDetail.ASI_TH_CRM_Agree_Comment__c;
        objVD.ASI_TH_CRM_Summary_Comment__c = objVisitPlanDetail.ASI_TH_CRM_Summary_Comment__c;         
        
        objVD.ASI_TH_CRM_Objectives__c = putMultiSelectValues(selectedObjectives);
        objVD.ASI_TH_CRM_Who__c = putMultiSelectValues(selectedWho);
        objVD.ASI_CRM_Outlet_Competitor_Activities__c = putMultiSelectValues(selectedActivities);
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
            system.debug('VisitDateF.date():'+VisitDateF.date());
            system.debug('objVD.ASI_HK_CRM_Visit_Date__c:'+objVD.ASI_HK_CRM_Visit_Date__c);
            if (strCxlReason == null || strCxlReason.length() <= 0) {
                blnHeaderValidation = false;
                strErrorMessageReason = 'Please specify.'; 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Visit date differ from planned, please enter reason.'));
                //return false;
            }
        }
        
        if (objVD.ASI_TH_CRM_Objectives__c == null || objVD.ASI_TH_CRM_Objectives__c.length() <1) {
            blnHeaderValidation = false;
            strErrorMessageObjectives = 'Please specify.'; 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Objective is required.'));
            //return false;
        }
        if (objVD.ASI_TH_CRM_Who__c == null || objVD.ASI_TH_CRM_Who__c.length() <1) {
            blnHeaderValidation = false;
            strErrorMessageWho = 'Please specify.'; 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Who is required.'));
            //return false;
        }
        if (objVD.ASI_TH_CRM_Promotion_Material__c.contains('Others') && String.IsEmpty(objVD.ASI_TH_CRM_PromotionMaterial_Others__c)){
            if(currentPage == null)
                currentPage = '2';
            strErrorMessagePromoMtOthers = 'Please specify.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Please specify Promotion Material - Others.'));
            blnHeaderValidation = false;
        }
        if (objVD.ASI_TH_CRM_BarSupply__c.contains('Others') && String.IsEmpty(objVD.ASI_TH_CRM_BarSupply_Others__c)){
            if(currentPage == null)
                currentPage = '3';
            strErrorMessageBarSupplyOthers = 'Please specify';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Please specify Bar Supply - Others.'));
            blnHeaderValidation = false;
        }
        if (objVD.ASI_TH_CRM_Signage__c.contains('Others') && String.IsEmpty(objVD.ASI_TH_CRM_Signage_Others__c)){
            if(currentPage == null)
                currentPage = '3';
            strErrorMessageSignageOthers = 'Please specify.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Please specify Signage - Others.'));
            blnHeaderValidation = false;
        }
        
        if (blnHeaderValidation == true){
            objVD.ASI_HK_CRM_Status__c = 'Achieved';
            
            try{
                update objVD;
                //Added by Twinkle @20160523 - get visit date
                Date visitDate = date.newinstance(objVD.ASI_TH_CRM_Visit_Date_Time_From__c.year(), objVD.ASI_TH_CRM_Visit_Date_Time_From__c.month(), objVD.ASI_TH_CRM_Visit_Date_Time_From__c.day());
                strVPDFromDate = string.valueof(visitDate);
            }
            catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Update failed.'));
                return false;
            }
            
            //Added by Twinkle @20160428 - update customer Last Visit Date
            if(objAccountAddt != null && objVD != null && objVD.ASI_TH_CRM_Visit_Date_Time_To__c != null){
                objAccountAddt.ASI_CRM_Last_Visit_Date__c = objVD.ASI_TH_CRM_Visit_Date_Time_To__c.date();
                update objAccountAddt;
            }
        }
        else{
            return false;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Please follow the error message(s) to correct the data.'));
        }
               
        Boolean blnIsError = false;
        
        List<ASI_CRM_Sales_Movement__c> lstUpsertSalesMovnt = new List<ASI_CRM_Sales_Movement__c>();
        //Sales Movement from Page 1
        for (SalesMovnt salesMovnt : lstSalesMovnt){  
            salesMovnt.strErrorMessagePrecense = '';
            salesMovnt.strErrorMessageVisibility = '';
            salesMovnt.strErrorMessageMenuPrice = '';            
            
            if(booleanPresencePrt){
                if(String.IsEmpty(salesMovnt.strSalesMovntPresence)){
                    CurrentPage = '0';
                    salesMovnt.strErrorMessagePrecense = 'Please specify.';
                    blnIsError = true;
                }
                else if(salesMovnt.strSalesMovntPresence == 'Y'){
                    if(salesMovnt.decListPrice == null || salesMovnt.decListPrice == 0){
                        CurrentPage = '0';
                        salesMovnt.strErrorMessageMenuPrice = 'Please specify and it cannot be 0.';
                        blnIsError = true;
                    }
                }
                else{
                    if(salesMovnt.strSalesMovntVisibility == 'Y'){
                        CurrentPage = '0';
                        salesMovnt.strErrorMessageVisibility = 'It cannot be Yes as Precense is No.';
                        blnIsError = true;
                    }
                    if(salesMovnt.decListPrice != 0){
                        CurrentPage = '0';
                        salesMovnt.strErrorMessageMenuPrice = 'It must be 0 as Precense is No.';
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
                sm.ASI_CRM_Menu_Price__c = salesMovnt.decListPrice;
                
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
            salesMovnt.strErrorMessageMenuPrice = '';            
            
            if(booleanPresenceCompetitor){
                if(String.IsEmpty(salesMovnt.strSalesMovntPresence)){
                    if(CurrentPage == null)
                        CurrentPage = '1';
                    salesMovnt.strErrorMessagePrecense = 'Please specify.';
                    blnIsError = true;
                }
                else if(salesMovnt.strSalesMovntPresence == 'Y'){
                    if(salesMovnt.decListPrice == null || salesMovnt.decListPrice == 0){
                        if(CurrentPage == null)
                            CurrentPage = '1';
                        salesMovnt.strErrorMessageMenuPrice = 'Please specify and it cannot be 0.';
                        blnIsError = true;
                    }
                }
                else{
                    if(salesMovnt.strSalesMovntVisibility == 'Y'){
                        if(CurrentPage == null)
                            CurrentPage = '1';
                        salesMovnt.strErrorMessageVisibility = 'It cannot be Yes as Precense is No.';
                        blnIsError = true;
                    }
                    if(salesMovnt.decListPrice != 0){
                        if(CurrentPage == null)
                            CurrentPage = '1';
                        salesMovnt.strErrorMessageMenuPrice = 'It must be 0 as Precense is No.';
                        blnIsError = true;
                    }
                    
                }
                ASI_CRM_Sales_Movement__c sm = new ASI_CRM_Sales_Movement__c ();                                    
            
                sm.id = salesMovnt.idRec;
                sm.ASI_CRM_VisitationPlanDetail__c = objVisitPlanDetail.id;
                sm.ASI_CRM_Account__c = objAccount.id;            
                sm.ASI_CRM_Sub_brand__c = salesMovnt.idSubBrand;
                sm.ASI_CRM_Date__c = VisitDateF.date();
                sm.ASI_CRM_Menu_Price__c = salesMovnt.decListPrice;
                
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
        
        List<ASI_CRM_Promotion_Status__c> lstUpsertPromoStatus = new List<ASI_CRM_Promotion_Status__c>();
        List<ASI_CRM_Promotion_Status__c> lstRemovePromoStatus = new List<ASI_CRM_Promotion_Status__c>();
        Map<id, ASI_CRM_Promotion_Status__c> mapPromoStatusDulicatedCheck = new Map<id, ASI_CRM_Promotion_Status__c>();
        Set<id> setRemovePromoStatus = new Set<id>();
        
        //Modified by Twinkle 20141128 - For Add/Remove on Page 3
        system.debug('lstPromoStatus: '+lstPromoStatus);
        if(lstPromoStatus != null && lstPromoStatus.size()>0){
            for (PromoStatus promoStatus: lstPromoStatus){                  
                ASI_CRM_Promotion_Status__c ps = new ASI_CRM_Promotion_Status__c();    
                ps.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Status__cASI_CRM_TH_PromotionStatus');        
                
                system.debug('mapRemovePromoStatus: '+mapRemovePromoStatus);
                if(promoStatus.idRec == null || !mapRemovePromoStatus.containsKey(promoStatus.idRec)){
                    system.debug('promoStatus.idRec: '+promoStatus.idRec);
                    if(promoStatus.idRec != null && promoStatus.idRec.contains('#')) 
                        promoStatus.idRec = null;
                        
                    promoStatus.strErrorMessageActivityDate = '';
                    promoStatus.strErrorMessageGWPAllocation = '';
                    promoStatus.strErrorMessageVolTarget = '';
                                                                                
                    ps.id = promoStatus.idRec;
                    ps.ASI_CRM_VisitationPlanDetail__c = objVisitPlanDetail.id;
                    ps.ASI_CRM_Account__c = objAccount.id;            
                    ps.ASI_CRM_Promotion__c = promoStatus.idPromo;
                    //ps.ASI_CRM_Date__c = VisitDateF.date();
                    ps.ASI_CRM_Date__c = promoStatus.joinDate;
                    ps.ASI_CRM_Volume_Target__c = promoStatus.volTarget;
                    ps.ASI_CRM_GWP_Allocation__c = promoStatus.gwpAllocation;
                    ps.ASI_CRM_Status__c = promoStatus.status;
                    
                    //Added by Twinkle Li @20160518
                    if(mapPromoStatusDulicatedCheck != null && mapPromoStatusDulicatedCheck.size() > 0 &&
                        mapPromoStatusDulicatedCheck.containskey(ps.ASI_CRM_Promotion__c) && 
                        ps.ASI_CRM_Date__c != null &&
                        mapPromoStatusDulicatedCheck.get(ps.ASI_CRM_Promotion__c).ASI_CRM_Date__c == ps.ASI_CRM_Date__c){
                            if(CurrentPage == null)
                                CurrentPage = '2';
                            promoStatus.strErrorMessageActivityDate = 'Please select another date for the same promotion.';
                            blnIsError = true;
                    }
                    mapPromoStatusDulicatedCheck.put(ps.ASI_CRM_Promotion__c, ps);
                    
                    if (promoStatus.promotype == 'Tasting' || promoStatus.promotype == 'Event') {
                        if(promoStatus.status == 'Proposed' || promoStatus.status == 'Agreed' || promoStatus.status == 'Done'){
                            if(promoStatus.joinDate == null){
                                if(CurrentPage == null)
                                    CurrentPage = '2';
                                promoStatus.strErrorMessageActivityDate = 'Please specify.';
                                blnIsError = true;
                            }
                            else if(promoStatus.joinDate < promoStatus.dtePromoStart || promoStatus.joinDate > promoStatus.dtePromoEnd){
                                if(CurrentPage == null)
                                    CurrentPage = '2';
                                promoStatus.strErrorMessageActivityDate = 'Please specify a date within Promotion period.';
                                blnIsError = true;
                            }
                            /*if(promoStatus.volTarget == null || promoStatus.volTarget == 0){
                                if(CurrentPage == null)
                                    CurrentPage = '2';
                                promoStatus.strErrorMessageVolTarget = 'Please specify.';
                                blnIsError = true;
                            }*/
                        }
                        /*else if(promoStatus.status == 'Rejected'){
                            if(promoStatus.volTarget != 0){
                                if(CurrentPage == null)
                                    CurrentPage = '2';
                                promoStatus.strErrorMessageVolTarget = 'It must be 0 as it is Rejected.';
                                blnIsError = true;
                            }
                        }*/
                    }
                    else{
                        if(promoStatus.status == 'Proposed' || promoStatus.status == 'Agreed' || promoStatus.status == 'Done'){
                            /*if(promoStatus.volTarget == null || promoStatus.volTarget == 0){ 
                                if(CurrentPage == null)
                                    CurrentPage = '2';
                                promoStatus.strErrorMessageVolTarget = 'Please specify.';
                                blnIsError = true;
                            }*/
                            if(promoStatus.gwpAllocation == null || promoStatus.gwpAllocation == 0){
                                if(CurrentPage == null)
                                    CurrentPage = '2';
                                promoStatus.strErrorMessageGWPAllocation = 'Please specify.';
                                blnIsError = true;
                            }
                        }
                        else if(promoStatus.status == 'Rejected'){
                            /*if(promoStatus.volTarget != 0){
                                if(CurrentPage == null)
                                    CurrentPage = '2';
                                promoStatus.strErrorMessageVolTarget = 'It must be 0 as it is Rejected.';
                                blnIsError = true;
                            }*/
                            if(promoStatus.gwpAllocation != 0){
                                if(CurrentPage == null)
                                    CurrentPage = '2';
                                promoStatus.strErrorMessageGWPAllocation = 'It must be 0 as it is Rejected.';
                                blnIsError = true;
                            }
                        }
                    }
                    
                    lstUpsertPromoStatus.add(ps);
                    system.debug('lstUpsertPromoStatus: '+lstUpsertPromoStatus);
                }
            }
        }
        //Modified by Twinkle 20141128
        
        //Added by Twinkle 20141128 - For Remove on Page 3
        if(mapRemovePromoStatus != null && mapRemovePromoStatus.size() > 0){
            lstRemovePromoStatus = [SELECT Id FROM ASI_CRM_Promotion_Status__c WHERE Id IN: mapRemovePromoStatus.keySet()];
            system.debug('lstRemovePromoStatus: '+lstRemovePromoStatus);
            delete lstRemovePromoStatus;
        }
        system.debug(lstUpsertPromoStatus);
        //Added by Twinkle 20141128
        
        if (blnIsError == true){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Please follow the error message(s) belows to correct the data.'));
            return false;
        }
        else
        {
            try{
                if(lstUpsertSalesMovnt != null && lstUpsertSalesMovnt.size() > 0){
                    upsert lstUpsertSalesMovnt;
                }
                if(lstUpsertPromoStatus != null && lstUpsertPromoStatus.size() >0){
                    upsert lstUpsertPromoStatus;
                }
                return true;
            }
            catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: '+e.getMessage()));
                return false;
            }
        }
    }
    
    /*** For Sales Movement Page 1 */
    private List<SalesMovnt> buildSalesMovnt(Id idAcc, Id idVPID, Id idServicePack) {
        // Declaration
        Map<Id, SalesMovnt> mapRes = new Map<Id, SalesMovnt>();
        Map<Id, ASI_CRM_Sales_Movement__c> mapLastRes = new Map<Id, ASI_CRM_Sales_Movement__c>();
        Map<Id, Decimal> mapActualOfftake = new Map<Id, Decimal>();

        String strVisitYear = String.ValueOf(VisitDateF.year());
        String strVisitMonth = String.ValueOf(VisitDateF.month());
        String strLastVisitYear = '';//String.ValueOf(VisitDateF.addMonths(-1).year());
        String strLastVisitMonth = '';//String.ValueOf(VisitDateF.addMonths(-1).month());
        //End
        
        // Dynamic generate Sales Movement Record
        List<ASI_CRM_ServicePackItem__c> lstSP = [
            SELECT Id, ASI_CRM_Priority__c, ASI_CRM_TW_Priority_Sorting__c,
                ASI_CRM_ServicePack__c, ASI_CRM_ServicePack__r.Name,
                ASI_CRM_Subbrand__c, ASI_CRM_Subbrand__r.Name, ASI_CRM_Subbrand__r.ASI_CRM_Product_Group_3__c
            FROM ASI_CRM_ServicePackItem__c
            WHERE ASI_CRM_ServicePack__c =: idServicePack
            ORDER BY ASI_CRM_Subbrand__r.ASI_CRM_Product_Group_3__c
        ]; 
        system.debug('lstSP:'+lstSP);
        
        Set<id> setSubBrandId = new Set<id>();
        for (ASI_CRM_ServicePackItem__c spi : lstSP) {
            setSubBrandId.add(spi.ASI_CRM_Subbrand__c);
        }
        
        //Modified by Twinkle @Introv - 20160527
        // Get saved Sales Movement Detail Record
        List<ASI_CRM_Sales_Movement__c> lstSalesMovntRec = [
            SELECT Id, ASI_CRM_Account__c,
                ASI_CRM_Actual_RSP__c, ASI_CRM_Date__c, 
                ASI_CRM_Distribution__c, ASI_CRM_Draft_Flag__c,
                ASI_CRM_Facing__c, ASI_CRM_Menu_Price__c,
                ASI_CRM_Sub_brand__c, ASI_CRM_VisitationPlanDetail__c,
                ASI_CRM_Sub_brand__r.Name, ASI_CRM_Sub_brand__r.ASI_CRM_Product_Group_3__c,
                ASI_CRM_Presence__c, ASI_CRM_Visibility__c,
                ASI_CRM_Month__c, ASI_CRM_Year__c
            FROM ASI_CRM_Sales_Movement__c
            WHERE ASI_CRM_Account__c = :idAcc
            //AND ASI_CRM_VisitationPlanDetail__c = :idVPID
            ORDER BY ASI_CRM_Date__c DESC 
        ];
        
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
                    sm.strProductGroup3 = objSalesMovntRec.ASI_CRM_Sub_brand__r.ASI_CRM_Product_Group_3__c;
                    sm.strPriority = ''; //DEV
                    sm.strQTDPurchase = '0'; //DEV
                    sm.decListPrice = objSalesMovntRec.ASI_CRM_Menu_Price__c;
                    sm.strSalesMovntPresence = (objSalesMovntRec.ASI_CRM_Presence__c) ? 'Y' : 'N';
                    sm.strSalesMovntVisibility = (objSalesMovntRec.ASI_CRM_Visibility__c) ? 'Y' : 'N';
    
                    if(setSubBrandId.contains(objSalesMovntRec.ASI_CRM_Sub_brand__c))
                        mapRes.put(objSalesMovntRec.ASI_CRM_Sub_brand__c, sm);
                    system.debug('#sm: '+sm);
                }
                else{
                    if(setSubBrandId.contains(objSalesMovntRec.ASI_CRM_Sub_brand__c))
                        mapLastRes.put(objSalesMovntRec.ASI_CRM_Sub_brand__c, objSalesMovntRec);
                }
            }
            else
                break;
        }
        system.debug('#sales movement mapRes: '+mapRes);
        
        // Get Last Month Sales Movement Detail Record
        /*lstSalesMovntRec = [
            SELECT Id, ASI_CRM_Account__c,
                ASI_CRM_Actual_RSP__c, ASI_CRM_Date__c, 
                ASI_CRM_Distribution__c, ASI_CRM_Draft_Flag__c,
                ASI_CRM_Facing__c, ASI_CRM_Menu_Price__c,
                ASI_CRM_Sub_brand__c, ASI_CRM_VisitationPlanDetail__c,
                ASI_CRM_Sub_brand__r.Name, ASI_CRM_Sub_brand__r.ASI_CRM_Product_Group_3__c,
                ASI_CRM_Presence__c, ASI_CRM_Visibility__c
            FROM ASI_CRM_Sales_Movement__c
            WHERE ASI_CRM_Account__c = :idAcc
            //AND ASI_CRM_VisitationPlanDetail__c = :idVPID
            AND ASI_CRM_Year__c = :strLastVisitYear 
            AND ASI_CRM_Month__c = :strLastVisitMonth 
            ORDER BY ASI_CRM_Sub_brand__r.Name
        ];
        
        for (ASI_CRM_Sales_Movement__c objSalesMovntRec : lstSalesMovntRec) {            
            mapLastMonthRes.put(objSalesMovntRec.ASI_CRM_Sub_brand__c, objSalesMovntRec );
        }*/
        
        //Added by Twinkle LI @ 20160419 - YTD calculation
        date currentDate = Date.today();
        Integer strYearFrom;
        if(currentDate.month() >= 7)
            strYearFrom = currentDate.Year();
        else
            strYearFrom = currentDate.Year()-1;
        Date dateFrom = Date.newInstance(strYearFrom, 7, 1);
        system.debug('dateFrom: '+dateFrom);

        for (ASI_TH_CRM_Actual_Offtake__c objActualOfftakeRec : [SELECT Id, ASI_TH_CRM_Quantity__c, ASI_TH_CRM_Sub_brand__c
                                                            FROM ASI_TH_CRM_Actual_Offtake__c
                                                            WHERE ASI_TH_CRM_Outlet__c = :idAcc
                                                            AND ASI_TH_CRM_Sub_brand__c in :setSubBrandId
                                                            AND ASI_TH_CRM_Offtake_G_L_Date__c >=: dateFrom
                                                            AND ASI_TH_CRM_Offtake_G_L_Date__c <=: currentDate 
                                                            AND recordType.DeveloperName = 'ASI_TH_CRM_Actual_Offtake'
        ]) {      
            Decimal ytdOfftake;
            Decimal Qty = objActualOfftakeRec.ASI_TH_CRM_Quantity__c == null? 0: objActualOfftakeRec.ASI_TH_CRM_Quantity__c;
            if(mapActualOfftake.get(objActualOfftakeRec.ASI_TH_CRM_Sub_brand__c) != null){
                ytdOfftake = mapActualOfftake.get(objActualOfftakeRec.ASI_TH_CRM_Sub_brand__c) + Qty;
            }
            else
                ytdOfftake = objActualOfftakeRec.ASI_TH_CRM_Quantity__c;
            mapActualOfftake.put(objActualOfftakeRec.ASI_TH_CRM_Sub_brand__c, ytdOfftake);
        }
        system.debug('mapActualOfftake: '+mapActualOfftake);                                    
        
        for (ASI_CRM_ServicePackItem__c spi : lstSP) {
            SalesMovnt sm = new SalesMovnt();
            Boolean blnExists = false;
            if (mapRes.containsKey(spi.ASI_CRM_Subbrand__c))
                blnExists = true;
            
            if (blnExists) {
                sm = mapRes.get(spi.ASI_CRM_Subbrand__c);                                                
            } else {
                if (mapLastRes.containsKey(spi.ASI_CRM_Subbrand__c)){
                    ASI_CRM_Sales_Movement__c lastMonthSalesMovnt = (ASI_CRM_Sales_Movement__c)mapLastRes.get(spi.ASI_CRM_Subbrand__c);                    
                    sm.strSalesMovntPresence = (lastMonthSalesMovnt.ASI_CRM_Presence__c) ? 'Y' : 'N';
                    sm.strSalesMovntVisibility = (lastMonthSalesMovnt.ASI_CRM_Visibility__c) ? 'Y' : 'N';
                    sm.decListPrice = lastMonthSalesMovnt.ASI_CRM_Menu_Price__c;                               
                }
            }
            
            if (mapActualOfftake.containsKey(spi.ASI_CRM_Subbrand__c)){
                //ASI_TH_CRM_Actual_Offtake__c lastMonthActualOfftake = (ASI_TH_CRM_Actual_Offtake__c)mapActualOfftake.get(spi.ASI_CRM_Subbrand__c);
                Decimal decQTDPurchase = mapActualOfftake.get(spi.ASI_CRM_Subbrand__c);
                String myNumberAsString = String.valueOf(decQTDPurchase);
                String formattedString = '';
                
                if(decQTDPurchase > 999999999){
                    formattedString += myNumberAsString.substring(0,myNumberAsString.length()-9)+ ',' + myNumberAsString.substring(myNumberAsString.length()-9,myNumberAsString.length()-6) + ',' + myNumberAsString.substring(myNumberAsString.length()-6,myNumberAsString.length()-3) + ',' + myNumberAsString.substring(myNumberAsString.length()-3,myNumberAsString.length());
                } else if(decQTDPurchase > 999999){
                    formattedString += myNumberAsString.substring(0,myNumberAsString.length()-6)+ ',' + myNumberAsString.substring(myNumberAsString.length()-6,myNumberAsString.length()-3) + ',' + myNumberAsString.substring(myNumberAsString.length()-3,myNumberAsString.length());
                } else if(decQTDPurchase > 999){
                    formattedString += myNumberAsString.substring(0,myNumberAsString.length()-3)+ ',' + myNumberAsString.substring(myNumberAsString.length()-3,myNumberAsString.length());
                } else {
                    formattedString += myNumberAsString;
                }
                sm.strQTDPurchase = formattedString;
            }                                    
            
            sm.idSubBrand = spi.ASI_CRM_Subbrand__c;
            sm.strSubBrand = spi.ASI_CRM_Subbrand__r.Name;
            sm.strProductGroup3 = spi.ASI_CRM_Subbrand__r.ASI_CRM_Product_Group_3__c;
            sm.strPriority = spi.ASI_CRM_Priority__c;
            sm.decPrioritySorting = spi.ASI_CRM_TW_Priority_Sorting__c;

            if(setSubBrandId.contains(spi.ASI_CRM_Subbrand__c))
                mapRes.put(spi.ASI_CRM_Subbrand__c, sm);
        }  
        system.debug('#final sale movement: '+mapRes);      
        
        return mapRes.values();
    }
    
    /*** For Competitor Sales Movement Page 2 */
    private List<SalesMovnt> buildSalesMovnt_Competitor(id idAcc) {
        Map<Id, SalesMovnt> mapRes = new Map<Id, SalesMovnt>();
        Map<Id, ASI_CRM_Sales_Movement__c> mapLastRes = new Map<Id, ASI_CRM_Sales_Movement__c>();
        Map<Id, Decimal> mapActualOfftake = new Map<Id, Decimal>();
        
        String strVisitYear = String.ValueOf(VisitDateF.year());
        String strVisitMonth = String.ValueOf(VisitDateF.month());
        String strLastVisitYear = '';//String.ValueOf(VisitDateF.addMonths(-1).year());
        String strLastVisitMonth = '';//String.ValueOf(VisitDateF.addMonths(-1).month());
        
        List<ASI_MFM_Sub_brand__c> listSubBrand = [SELECT id, Name, ASI_CRM_Product_Group_3__c FROM ASI_MFM_Sub_brand__c 
                                                   WHERE recordType.DeveloperName = 'ASI_TH_CRM_Sub_brand'
                                                   AND ASI_TH_CRM_Active__c = true
                                                   AND ASI_CRM_Outlet_Visit__c = true 
                                                   AND ASI_TH_CRM_Product_Group_1__c LIKE '%Competitor%'];
        Set<id> setSubBrandId = new Set<id>();
        for (ASI_MFM_Sub_brand__c sb : listSubBrand) {
            setSubBrandId.add(sb.id);
        }
        
        // Get saved Sales Movement Detail Record
        List<ASI_CRM_Sales_Movement__c> lstSalesMovntRec = [
            SELECT Id, ASI_CRM_Account__c,
                ASI_CRM_Actual_RSP__c, ASI_CRM_Date__c, 
                ASI_CRM_Distribution__c, ASI_CRM_Draft_Flag__c,
                ASI_CRM_Facing__c, ASI_CRM_Menu_Price__c,
                ASI_CRM_Sub_brand__c, ASI_CRM_VisitationPlanDetail__c,
                ASI_CRM_Sub_brand__r.Name, ASI_CRM_Sub_brand__r.ASI_CRM_Product_Group_3__c,
                ASI_CRM_Presence__c, ASI_CRM_Visibility__c,
                ASI_CRM_Month__c, ASI_CRM_Year__c
            FROM ASI_CRM_Sales_Movement__c
            WHERE ASI_CRM_Account__c = :idAcc
            ORDER BY ASI_CRM_Date__c DESC 
        ];
        
        for (ASI_CRM_Sales_Movement__c objSalesMovntRec : lstSalesMovntRec) {
            if(strLastVisitYear == '' && strLastVisitMonth == ''){
                strLastVisitYear = objSalesMovntRec.ASI_CRM_Year__c;
                strLastVisitMonth = objSalesMovntRec.ASI_CRM_Month__c;
            }
            if(objSalesMovntRec.ASI_CRM_Year__c == strLastVisitYear && objSalesMovntRec.ASI_CRM_Month__c == strLastVisitMonth){
                if(objSalesMovntRec.ASI_CRM_Year__c ==  strVisitYear && objSalesMovntRec.ASI_CRM_Month__c == strVisitMonth) {
                    SalesMovnt sm = new SalesMovnt();
                    sm.idRec = objSalesMovntRec.Id;
                    sm.idSubBrand = objSalesMovntRec.ASI_CRM_Sub_brand__c;
                    sm.strSubBrand = objSalesMovntRec.ASI_CRM_Sub_brand__r.Name;
                    sm.strProductGroup3 = objSalesMovntRec.ASI_CRM_Sub_brand__r.ASI_CRM_Product_Group_3__c;
                    if(sm.strProductGroup3 == null)
                        sm.strProductGroup3 = objSalesMovntRec.ASI_CRM_Sub_brand__r.Name;
                    sm.strPriority = ''; 
                    sm.decListPrice = objSalesMovntRec.ASI_CRM_Menu_Price__c;
                    sm.strSalesMovntPresence = (objSalesMovntRec.ASI_CRM_Presence__c) ? 'Y' : 'N';
                    sm.strSalesMovntVisibility = (objSalesMovntRec.ASI_CRM_Visibility__c) ? 'Y' : 'N';
    
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
                ASI_CRM_Facing__c, ASI_CRM_Menu_Price__c,
                ASI_CRM_Sub_brand__c, ASI_CRM_VisitationPlanDetail__c,
                ASI_CRM_Sub_brand__r.Name, ASI_CRM_Sub_brand__r.ASI_CRM_Product_Group_3__c,
                ASI_CRM_Presence__c, ASI_CRM_Visibility__c
            FROM ASI_CRM_Sales_Movement__c
            WHERE ASI_CRM_Account__c = :idAcc
            AND ASI_CRM_Year__c = :strLastVisitYear 
            AND ASI_CRM_Month__c = :strLastVisitMonth 
            ORDER BY ASI_CRM_Sub_brand__r.Name
        ];
        
        for (ASI_CRM_Sales_Movement__c objSalesMovntRec : lstSalesMovntRec) {            
            mapLastMonthRes.put(objSalesMovntRec.ASI_CRM_Sub_brand__c, objSalesMovntRec );
        }*/
        
        //Added by Twinkle LI @ 20160419 - YTD calculation
        date currentDate = Date.today();
        Integer strYearFrom;
        if(currentDate.month() >= 7)
            strYearFrom = currentDate.Year();
        else
            strYearFrom = currentDate.Year()-1;
        Date dateFrom = Date.newInstance(strYearFrom, 7, 1);
        
        system.debug('dateFrom: '+dateFrom);

        for (ASI_TH_CRM_Actual_Offtake__c objActualOfftakeRec : [SELECT Id, ASI_TH_CRM_Quantity__c, ASI_TH_CRM_Sub_brand__c
                                                            FROM ASI_TH_CRM_Actual_Offtake__c
                                                            WHERE ASI_TH_CRM_Outlet__c = :idAcc
                                                            AND ASI_TH_CRM_Sub_brand__c in :setSubBrandId
                                                            AND ASI_TH_CRM_Offtake_G_L_Date__c >=: dateFrom
                                                            AND ASI_TH_CRM_Offtake_G_L_Date__c <=: currentDate 
                                                            AND recordType.DeveloperName = 'ASI_TH_CRM_Actual_Offtake'
        ]) {      
            Decimal ytdOfftake;
            if(mapActualOfftake.get(objActualOfftakeRec.ASI_TH_CRM_Sub_brand__c) != null){
                ytdOfftake = mapActualOfftake.get(objActualOfftakeRec.ASI_TH_CRM_Sub_brand__c) + objActualOfftakeRec.ASI_TH_CRM_Quantity__c;
            }
            else
                ytdOfftake = objActualOfftakeRec.ASI_TH_CRM_Quantity__c;
            mapActualOfftake.put(objActualOfftakeRec.ASI_TH_CRM_Sub_brand__c, ytdOfftake);
        }
        system.debug('mapActualOfftake: '+mapActualOfftake);
        
        for (ASI_MFM_Sub_brand__c sb : listSubBrand) {
            SalesMovnt sm = new SalesMovnt();
            Boolean blnExists = false;
            if (mapRes.containsKey(sb.id))
                blnExists = true;
            
            if (blnExists){ 
                sm = mapRes.get(sb.id);                                                
            } else {
                if (mapLastRes.containsKey(sb.id)){
                    ASI_CRM_Sales_Movement__c lastMonthSalesMovnt = (ASI_CRM_Sales_Movement__c)mapLastRes.get(sb.id);
                    sm.strSalesMovntPresence = (lastMonthSalesMovnt.ASI_CRM_Presence__c) ? 'Y' : 'N';
                    sm.strSalesMovntVisibility = (lastMonthSalesMovnt.ASI_CRM_Visibility__c) ? 'Y' : 'N';
                    sm.decListPrice = lastMonthSalesMovnt.ASI_CRM_Menu_Price__c;                               
                }
            }
            
            if (mapActualOfftake.containsKey(sb.id)){
                //ASI_TH_CRM_Actual_Offtake__c lastMonthActualOfftake = (ASI_TH_CRM_Actual_Offtake__c)mapActualOfftake.get(sb.id);
                Decimal decQTDPurchase = mapActualOfftake.get(sb.id);
                String myNumberAsString = String.valueOf(decQTDPurchase);
                String formattedString = '';
                
                if(decQTDPurchase > 999999999){
                    formattedString += myNumberAsString.substring(0,myNumberAsString.length()-9)+ ',' + myNumberAsString.substring(myNumberAsString.length()-9,myNumberAsString.length()-6) + ',' + myNumberAsString.substring(myNumberAsString.length()-6,myNumberAsString.length()-3) + ',' + myNumberAsString.substring(myNumberAsString.length()-3,myNumberAsString.length());
                } else if(decQTDPurchase > 999999){
                    formattedString += myNumberAsString.substring(0,myNumberAsString.length()-6)+ ',' + myNumberAsString.substring(myNumberAsString.length()-6,myNumberAsString.length()-3) + ',' + myNumberAsString.substring(myNumberAsString.length()-3,myNumberAsString.length());
                } else if(decQTDPurchase > 999){
                    formattedString += myNumberAsString.substring(0,myNumberAsString.length()-3)+ ',' + myNumberAsString.substring(myNumberAsString.length()-3,myNumberAsString.length());
                } else {
                    formattedString += myNumberAsString;
                }
                sm.strQTDPurchase = formattedString;
            }                                    
            
            sm.idSubBrand = sb.id;
            sm.strSubBrand = sb.Name;
            sm.strProductGroup3 = sb.ASI_CRM_Product_Group_3__c;
            if(sm.strProductGroup3 == null)
                sm.strProductGroup3 = sb.Name;
            
            if(setSubBrandId.contains(sb.id))
                mapRes.put(sb.id, sm);
        }      
        system.debug('2.mapRes: '+mapRes);  
        
        return mapRes.values();
    }
    
    /*** For Sales Call Plan Page 3 */
    private List<PromoStatus> buildPromoStatus(Id idAcc, Id idVPID, String strOTC, Date dteDate) {
        // Declaration
        Map<String, PromoStatus> mapRes = new Map<String, PromoStatus>();
        Map<Id, Attachment> mapAttachment = new Map<Id, Attachment>();
        Set<Id> idTempPromo = new Set<Id>();      
        lstPromoStatusRec = new List<ASI_CRM_Promotion_Status__c>();
        Integer rowIndex = 0;
        
        List<String> listOutletType = new List<String>();
        if(!String.IsEmpty(strOTC)){
            String[] tmpString = strOTC.split(';');
            integer index = 0;
            For(String s : tmpString){
                s = s.replace('[', '').replace(']', '');
                s = s.substring(3, s.length());
                listOutletType.add(s);
                index++;
            }
        }
        
        String strOTCtoQuery = '';
        for(string ot : listOutletType){
            strOTCtoQuery += ot+';';
        }
        
        //Added by Twinkle @20160524 - For Promotion Status 
        Map<String, ASI_CRM_Promotion_Target__c> mapPromoTarget = new Map<String, ASI_CRM_Promotion_Target__c>(); //map promotion target by promotion & RSM
        User currentUser = [SELECT id, ManagerId FROM User WHERE id =: UserInfo.getUserId()];
        List<ASI_CRM_Promotion_Target__c> listPromoTarget = [SELECT id, ASI_CRM_Promotion__c, ASI_CRM_RSM__c, ASI_CRM_No_of_Activities__c, ASI_CRM_Volume_Target__c
                                                             FROM ASI_CRM_Promotion_Target__c 
                                                             WHERE ASI_CRM_RSM__c =: currentUser.ManagerId];
        for(ASI_CRM_Promotion_Target__c promoTarget : listPromoTarget){
            mapPromoTarget.put(promoTarget.ASI_CRM_Promotion__c+''+promoTarget.ASI_CRM_RSM__c, promoTarget);
        }
        
        // Get saved Promotional Detail Record
        lstPromoStatusRec = [
            SELECT Id, ASI_CRM_Account__c, ASI_CRM_Date__c, ASI_CRM_Promotion__c,
                ASI_CRM_Offer_Accepted__c, ASI_CRM_Supplier__c, ASI_CRM_Supplier__r.Name,
                ASI_CRM_Unit__c, ASI_CRM_VisitationPlanDetail__c,
                ASI_CRM_VisitationPlanDetail__r.ASI_HK_CRM_Visitation_Plan__r.Name,
                ASI_CRM_VisitationPlanDetail__r.ASI_TH_CRM_Visit_Date_Time_From__c,
                ASI_CRM_VisitationPlanDetail__r.ASI_TH_CRM_Visit_Date_Time_To__c,
                ASI_CRM_Draft_Flag__c, ASI_CRM_Promotion__r.ASI_CRM_Type__c,
                ASI_CRM_GWP_Allocation__c, ASI_CRM_Volume_Target__c, ASI_CRM_Status__c,
                ASI_CRM_Promotion__r.ASI_HK_CRM_Promotion_Start_Date__c, ASI_CRM_Promotion__r.ASI_HK_CRM_Promotion_End_Date__c
            FROM ASI_CRM_Promotion_Status__c
            WHERE ASI_CRM_Account__c = :idAcc
            /*AND ASI_CRM_Promotion__r.ASI_HK_CRM_Promotion_Start_Date__c <= :dteDate*/
            AND ASI_CRM_Promotion__r.ASI_HK_CRM_Promotion_End_Date__c >= :dteDate
        ];
        system.debug('lstPromoStatusRec: '+lstPromoStatusRec);
        
        for (ASI_CRM_Promotion_Status__c objPromoStatusRec : lstPromoStatusRec) {
            PromoStatus ps = new PromoStatus();
            
            ps.intRowIndex = rowIndex++;
            ps.idRec = objPromoStatusRec.Id;
            ps.idPromo = objPromoStatusRec.ASI_CRM_Promotion__c;
            ps.strPromo = objPromoStatusRec.ASI_CRM_VisitationPlanDetail__r.ASI_HK_CRM_Visitation_Plan__r.Name;
            ps.strDesc = objPromoStatusRec.ASI_CRM_VisitationPlanDetail__r.ASI_HK_CRM_Visitation_Plan__r.Name;
            ps.dteStart = objPromoStatusRec.ASI_CRM_VisitationPlanDetail__r.ASI_TH_CRM_Visit_Date_Time_From__c;
            ps.dteEnd = objPromoStatusRec.ASI_CRM_VisitationPlanDetail__r.ASI_TH_CRM_Visit_Date_Time_To__c;
            ps.promoType = objPromoStatusRec.ASI_CRM_Promotion__r.ASI_CRM_Type__c;
            ps.gwpAllocation = objPromoStatusRec.ASI_CRM_GWP_Allocation__c;
            ps.volTarget = objPromoStatusRec.ASI_CRM_Volume_Target__c;
            ps.joinDate = objPromoStatusRec.ASI_CRM_Date__c;
            ps.status = objPromoStatusRec.ASI_CRM_Status__c;
            ps.dtePromoStart = objPromoStatusRec.ASI_CRM_Promotion__r.ASI_HK_CRM_Promotion_Start_Date__c;
            ps.dtePromoEnd = objPromoStatusRec.ASI_CRM_Promotion__r.ASI_HK_CRM_Promotion_End_Date__c;
            
            if(ps.promoType == 'Event' || ps.promoType == 'Tasting'){
                ps.boolEventOrTasting = true;
                ps.boolGWP = false;
            }
            else{
                ps.boolEventOrTasting = false;
                ps.boolGWP = true;
            }
            
            mapRes.put(ps.idRec, ps);
            idTempPromo.add(ps.idPromo);
        }
        system.debug('mapRes: '+mapRes);
        
        // Dynamic generate Promotional Record
        List<ASI_HK_CRM_Promotion__c> lstPromo = [
            SELECT Id, Name,
                ASI_HK_CRM_Promotion_Name__c, ASI_HK_CRM_Promotion_Start_Date__c,
                ASI_HK_CRM_Promotion_End_Date__c, ASI_CRM_PurchaseDueDate__c,
                ASI_CRM_Type__c
            FROM ASI_HK_CRM_Promotion__c
            WHERE /*ASI_HK_CRM_Promotion_Start_Date__c <= :dteDate
            AND*/ ASI_HK_CRM_Promotion_End_Date__c >= :dteDate
            AND ASI_CRM_Outlet_Type__c includes (:strOTCtoQuery)
        ];        
        system.debug('strOTCtoQuery: '+strOTCtoQuery);
        system.debug('lstPromo: '+lstPromo);
        
        //Modified by Twinkle 20141211 - For Add/Remove on Page 3
        boolean checkExistOrNot;
        for (ASI_HK_CRM_Promotion__c p : lstPromo) {
            checkExistOrNot = false;
            PromoStatus ps = new PromoStatus();           
            if(mapRes != null && mapRes.size()>0){
                for (String key : mapRes.keySet()) {
                    PromoStatus records = mapRes.get(key);
                    if(records.idPromo == p.id){
                        checkExistOrNot = true;
                        ps = mapRes.get(records.idRec);     
                        
                        ps.strPromo = p.Name;
                        ps.strDesc = p.ASI_HK_CRM_Promotion_Name__c;
                        ps.dteStart = p.ASI_HK_CRM_Promotion_Start_Date__c;
                        ps.dteEnd = p.ASI_HK_CRM_Promotion_End_Date__c;
                        ps.dtePurchaseDue = p.ASI_CRM_PurchaseDueDate__c;
                        ps.promoType = p.ASI_CRM_Type__c;
                        ps.dtePromoStart = p.ASI_HK_CRM_Promotion_Start_Date__c;
                        ps.dtePromoEnd = p.ASI_HK_CRM_Promotion_End_Date__c;
                        
                        if(ps.promoType == 'Event' || ps.promoType == 'Tasting' ){
                            ps.boolEventOrTasting = true;
                            ps.boolGWP = false;
                        }
                        else{
                            ps.boolEventOrTasting = false;
                            ps.boolGWP = true;
                        }
                    }
                }
            }
            if(checkExistOrNot == false){
                ps.intRowIndex = rowIndex++;
                ps.idRec = '#'+String.valueof(index);
                ps.idPromo = p.Id;
                ps.strPromoOpt = 'N';
                ps.strPromo = p.Name;               
                ps.strDesc = p.ASI_HK_CRM_Promotion_Name__c;
                ps.dteStart = p.ASI_HK_CRM_Promotion_Start_Date__c;
                ps.dteEnd = p.ASI_HK_CRM_Promotion_End_Date__c;
                ps.dtePurchaseDue = p.ASI_CRM_PurchaseDueDate__c;
                ps.promoType = p.ASI_CRM_Type__c;
                ps.dtePromoStart = p.ASI_HK_CRM_Promotion_Start_Date__c;
                ps.dtePromoEnd = p.ASI_HK_CRM_Promotion_End_Date__c;
                
                if(mapPromoTarget != null && mapPromoTarget.get(p.id+''+currentUser.ManagerId) != null &&
                   mapPromoTarget.get(p.id+''+currentUser.ManagerId).ASI_CRM_Volume_Target__c != null &&
                   mapPromoTarget.get(p.id+''+currentUser.ManagerId).ASI_CRM_No_of_Activities__c != null)
                    ps.volTarget = (mapPromoTarget.get(p.id+''+currentUser.ManagerId).ASI_CRM_Volume_Target__c)/(mapPromoTarget.get(p.id+''+currentUser.ManagerId).ASI_CRM_No_of_Activities__c);
                //ps.joinDate = system.today();
                
                if(ps.promoType == 'Event' || ps.promoType == 'Tasting' ){
                    ps.boolEventOrTasting = true;
                    ps.boolGWP = false;
                }
                else{
                    ps.boolEventOrTasting = false;
                    ps.boolGWP = true;
                }
            }

            index++;
            mapRes.put(ps.idRec, ps);
            idTempPromo.add(ps.idPromo);
        }
        system.debug('mapRes: '+mapRes);
        //Modified by Twinkle 20141211
        
        // Dynamic generate Promotional Detail Record
        List<ASI_HK_CRM_Promotion_Detail__c> lstPromoD = [
            SELECT ASI_HK_CRM_Promotion__r.Id, ASI_HK_CRM_Promotion__r.Name,
                ASI_HK_CRM_Promotion__r.ASI_HK_CRM_Promotion_Name__c, ASI_HK_CRM_Promotion__r.ASI_HK_CRM_Promotion_Start_Date__c,
                ASI_HK_CRM_Promotion__r.ASI_HK_CRM_Promotion_End_Date__c, ASI_HK_CRM_Promotion__r.ASI_CRM_PurchaseDueDate__c,
                ASI_HK_CRM_Promotion__r.ASI_CRM_Type__c
            FROM ASI_HK_CRM_Promotion_Detail__c
            WHERE /*ASI_HK_CRM_Promotion__r.ASI_HK_CRM_Promotion_Start_Date__c <= :dteDate
            AND*/ ASI_HK_CRM_Promotion__r.ASI_HK_CRM_Promotion_End_Date__c >= :dteDate
            AND ASI_HK_CRM_Account__c = :idAcc
        ];
        system.debug('lstPromoD: '+lstPromoD);
        
        //Modified by Twinkle 20141211 - For Add/Remove on Page 3
        for (ASI_HK_CRM_Promotion_Detail__c p : lstPromoD) {
            checkExistOrNot = false;
            PromoStatus ps = new PromoStatus();
            if(mapRes != null && mapRes.size()>0){
                for (String key : mapRes.keySet()) {
                    PromoStatus records = mapRes.get(key);
                    if(records.idPromo == p.ASI_HK_CRM_Promotion__r.id){
                        checkExistOrNot = true;
                        ps = mapRes.get(records.idRec);    
                        
                        ps.strPromo = p.ASI_HK_CRM_Promotion__r.Name;
                        ps.strDesc = p.ASI_HK_CRM_Promotion__r.ASI_HK_CRM_Promotion_Name__c;
                        ps.dteStart = p.ASI_HK_CRM_Promotion__r.ASI_HK_CRM_Promotion_Start_Date__c;
                        ps.dteEnd = p.ASI_HK_CRM_Promotion__r.ASI_HK_CRM_Promotion_End_Date__c;
                        ps.dtePurchaseDue = p.ASI_HK_CRM_Promotion__r.ASI_CRM_PurchaseDueDate__c;
                        ps.promoType = p.ASI_HK_CRM_Promotion__r.ASI_CRM_Type__c;
                        ps.dtePromoStart = p.ASI_HK_CRM_Promotion__r.ASI_HK_CRM_Promotion_Start_Date__c;
                        ps.dtePromoEnd = p.ASI_HK_CRM_Promotion__r.ASI_HK_CRM_Promotion_End_Date__c;
                        
                        if(ps.promoType == 'Event' || ps.promoType == 'Tasting' ){
                            ps.boolEventOrTasting = true;
                            ps.boolGWP = false;
                        }
                        else{
                            ps.boolEventOrTasting = false;
                            ps.boolGWP = true;
                        }

                        mapRes.put(ps.idRec, ps);
                    }
                }
            }      
            if(checkExistOrNot == false){
                ps.intRowIndex = rowIndex++;
                ps.idRec = '#'+String.valueof(index);
                ps.idPromo = p.ASI_HK_CRM_Promotion__r.Id;
                ps.strPromo = p.ASI_HK_CRM_Promotion__r.Name;  
                ps.promoType = p.ASI_HK_CRM_Promotion__r.ASI_CRM_Type__c;
                ps.dtePromoStart = p.ASI_HK_CRM_Promotion__r.ASI_HK_CRM_Promotion_Start_Date__c;
                ps.dtePromoEnd = p.ASI_HK_CRM_Promotion__r.ASI_HK_CRM_Promotion_End_Date__c;
                
                if(mapPromoTarget != null && mapPromoTarget.get(p.id+''+currentUser.ManagerId) != null)
                    ps.volTarget = (mapPromoTarget.get(p.id+''+currentUser.ManagerId).ASI_CRM_Volume_Target__c)/(mapPromoTarget.get(p.id+''+currentUser.ManagerId).ASI_CRM_No_of_Activities__c);
                //ps.joinDate = system.today();
                
                if(ps.promoType == 'Event' || ps.promoType == 'Tasting' ){
                    ps.boolEventOrTasting = true;
                    ps.boolGWP = false;
                }
                else{
                    ps.boolEventOrTasting = false;
                    ps.boolGWP = true;
            }
            }

            index++;
            mapRes.put(ps.idRec, ps);
            idTempPromo.add(ps.idPromo);          
        }
        system.debug('mapRes: '+mapRes);

        //Assign Attachment
        //mapAttachment = new Map<Id, Attachment>([SELECT ParentId, id FROM Attachment WHERE ParentId in :idTempPromo AND (NOT Name LIKE 'TH_%') ORDER BY CreatedDate ASC]);
        List<Attachment> listAttachment = [SELECT ParentId, id FROM Attachment WHERE ParentId in :idTempPromo AND (NOT Name LIKE 'TH_%') ORDER BY CreatedDate ASC];
        Map<Id, Attachment> mapByAttachParent = new Map<Id, Attachment>();
        for(Attachment attch : listAttachment){
            mapByAttachParent.put(attch.ParentId, attch);
        }
        
        if(mapByAttachParent != null && mapByAttachParent.size() > 0){
            for (Attachment attachment : mapByAttachParent.values()){
                for (String key : mapRes.keySet()) {
                    PromoStatus records = mapRes.get(key);
                    if(records.idPromo == attachment.ParentId){
                        PromoStatus ps = mapRes.get(records.idRec);                    
                        if (ps != null && ps.idAttachment == null) {
                            ps.idAttachment = attachment.id;                               
                        }
                        mapRes.put(ps.idRec, ps);
                    }
                }
            }
        }
        
        if(mapRes != null && mapRes.size()>0)
            return mapRes.values();
        else 
            return null;
        //Modified by Twinkle 20141211
    }

    @RemoteAction
    public static String insertAttachment(String strParentID, String attachmentBody, String attName, String pType, String attachmentId) {
    
        if(attachmentBody != null) {
            Attachment att = getAttachment(attachmentId);
            String newBody = '';
            if(att.Body != null) {
                newBody = EncodingUtil.base64Encode(att.Body);
            }
            newBody += attachmentBody;
            att.Body = EncodingUtil.base64Decode(newBody);
            if(attachmentId == null) {
                Integer intSeq = 0;
                String strFName = '';
                List<Attachment> lstAtt = new List<Attachment>();
                
                String str15ID = strParentID;
                if (str15ID.length() == 18)
                    str15ID = str15ID.substring(1, 15);
                
                if (pType == null || pType == '' || pType == '1'){
                    pType = '1';
                    lstAtt = [SELECT Id, Name FROM Attachment WHERE ParentId = :strParentID AND Name LIKE: attName+'_PRT_'+'%' ORDER BY Name DESC LIMIT 1 ];
                }
                else if (pType == '2')
                    lstAtt = [SELECT Id, Name FROM Attachment WHERE ParentId = :strParentID AND Name LIKE: attName+'_Competitor_'+'%' ORDER BY Name DESC LIMIT 1 ];
                
                if (lstAtt != null && lstAtt.size() > 0) {
                    strFName = lstAtt[0].Name;
                    String[] arrToken = strFName.split('\\.', 2);
                    if (arrToken != null && arrToken.size() > 0) {
                        String strTemp = '';
                        //if (pType == '1') strTemp = arrToken[0].replace('PRT_', '');
                        //if (pType == '2') strTemp = arrToken[0].replace('Competitor_', '');
                        String[] strArray;
                        strArray = arrToken[0].split('_');
                        strTemp = strArray[3];
                        
                        intSeq = Integer.valueOf(strTemp);
                    }
                }
                intSeq++;
                system.debug('intSeq: '+intSeq);
                
                String[] arrToken = strFName.split('\\.', 2);
                if (arrToken != null && arrToken.size() >= 2) {
                    strFName = '.' + arrToken[1];
                }
                if (pType == '1') strFName = attName+'_PRT_' + ASI_CRM_TH_Outlet_OpenVisitFormCtrl.fileSeq(intSeq);
                if (pType == '2') strFName = attName+'_Competitor_' + ASI_CRM_TH_Outlet_OpenVisitFormCtrl.fileSeq(intSeq);

                if (strFName == null || strFName == '')
                    strFName = 'noname';
                
                att.Name = strFName+'.jpg';
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