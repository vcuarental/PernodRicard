/****************************************

Created by Stella Li (Introv) 03/09/2015

****************************************/

global class ASI_CRM_TW_MerchanDailyReport_Ctrl {

    public list<ASI_CRM_Merchandiser_Task__c>MerTask{ get; set; }
    public ASI_HK_CRM_Visitation_Plan_Detail__c VPD{ get; set; }
    public ASI_HK_CRM_Visitation_Plan_Detail__c objVD { get; set; }
    public String strVPID { get; set; }
    public Account objAccount { get; private set; }
    public ASI_CRM_AccountsAdditionalField__c objAccountAddt { get; private set; }
    public ASI_HK_CRM_Visitation_Plan_Detail__c objVisitPlanDetail { get; private set; }
    public Boolean isQuickSave {get;set;}
    public String encodedAccountName{get;set;}
    public Id idVisitPlanDetail {get;set;}
    Public Id idAcc {get;set;}
    public String accountRegion {get;set;}

    public String strRemarks {
        get { return objVisitPlanDetail.ASI_TH_CRM_Activity_Remarks__c; }
        set { objVisitPlanDetail.ASI_TH_CRM_Activity_Remarks__c = value; }
    }
    public String strFeedback {
        get { return objVisitPlanDetail.ASI_CRM_Customer_Feedback__c; }
        set { objVisitPlanDetail.ASI_CRM_Customer_Feedback__c= value; }
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
        
    public ASI_CRM_TW_MerchanDailyReport_Ctrl(ApexPages.StandardController stdController) {    
        idVisitPlanDetail = ApexPages.currentPage().getParameters().get('vpid');
        idAcc = ApexPages.currentPage().getParameters().get('accid');
        isQuickSave = true;
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
        // Obtain Account Additional (Customer) fields
        List<ASI_CRM_AccountsAdditionalField__c> lstAccAddt = [
            SELECT Id, Name, ASI_CRM_Channel__c, ASI_CRM_CN_Sub_Channel__r.Name,
                ASI_CRM_CN_Sub_Channel__c, ASI_TH_CRM_OutletImage__c,
                ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c,
                ASI_TH_CRM_OutletImage__r.Name, ASI_CRM_Sales_Potential__c,
                ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c
            FROM ASI_CRM_AccountsAdditionalField__c 
            WHERE ASI_CRM_Account__c = :idAcc
            LIMIT 1
        ];
        
        if (lstAccAddt == null || lstAccAddt.size() <= 0)
            throw new ASI_CRM_TW_Function.CRM_TW_Exception('Customer Record Not Found (Account Id: ' + idAcc + ')');
        else
            objAccountAddt = lstAccAddt[0];
        
        // Visitation Plan Detail
            VPD = [
            SELECT Id, Name,
                ASI_TH_CRM_Visit_Date_Time_From__c, ASI_TH_CRM_Visit_Date_Time_To__c, ASI_HK_CRM_Visit_Date__c,
                ASI_HK_CRM_Visit_Objective__c, ASI_TH_CRM_Activity_Remarks__c,
                ASI_HK_CRM_Cancellation_Reason__c, ASI_HK_CRM_Visitation_Plan__r.Name, ASI_CRM_Date_Difference_Actual_Planned__c,ASI_CRM_Customer_Feedback__c
            FROM ASI_HK_CRM_Visitation_Plan_Detail__c
            WHERE Id = :idVisitPlanDetail ];
       
        if (VPD != null){
            objVisitPlanDetail = VPD;
            if(objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c == null){
                objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c = System.Now();
            }
        }      
        
        //Merchandise task
        Mertask = new list<ASI_CRM_Merchandiser_Task__c>();
        Mertask= [SELECT id, Name, ASI_CRM_Photo_Date__c, ASI_CRM_Done__c, ASI_CRM_End_Date__c, ASI_CRM_Promotion_Code__c, ASI_CRM_Promotion_Name__c,ASI_CRM_Purchase_Due_Date__c,
                    ASI_CRM_Remarks__c, ASI_CRM_Start_Date__c,ASI_CRM_Supplier__c,ASI_CRM_Task__c,ASI_CRM_Unit__c FROM ASI_CRM_Merchandiser_Task__c 
                    WHERE ASI_CRM_Visitation_Plan_Detail__r.id =:idVisitPlanDetail AND ASI_CRM_Confirmed__c=FALSE];
        for(ASI_CRM_Merchandiser_Task__c m : Mertask){
            if(m.ASI_CRM_Photo_Date__c == null){
                m.ASI_CRM_Photo_Date__c=date.today();
            }
        }
    }

    /** To save record with draft flag = true, and ignore any validation rules */
    public PageReference quickSave() {
        Boolean saveSuccess = implSaveChanges();
        PageReference redirectPage = null;
  // Comment by Stella  Li 2015/4/30 - only show one button, remove quick save. 

        if (saveSuccess) {
            if(isQuickSave)
            {                               
                redirectPage = Page.ASI_CRM_TW_MerDailyReport_Page;
                redirectPage.getParameters().put('vpid', objVisitPlanDetail.id);
                redirectPage.getParameters().put('accid', objAccount.id);
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
    public PageReference SaveVPD(){
        Boolean blnValidation =  true; 
        isQuickSave = false;
        
        return quickSave();
    }
  
    
    public Boolean implSaveChanges() {
        // Declaration
        Boolean blnHeaderValidation = true;
        Boolean blnValidation =  true; // Initial set to true
        if(VPD !=null ){
            objVD = VPD;
        }
        if(objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_To__c == null)
            objVisitPlanDetail.ASI_TH_CRM_Visit_Date_Time_To__c = System.Now();
        
        //Added by Twinkle @20150521 - Check Date From vs Date To
        if (VisitDateF.date() > VisitDateT.date()) {
            blnHeaderValidation = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Visit Date (To) should be after Visit Date (From).'));
            return false;
        }
        //Added by Twinkle @20150521
        
        if (VisitDateF != null && objVD.ASI_HK_CRM_Visit_Date__c != null && objVD.ASI_HK_CRM_Visit_Date__c != VisitDateF.date() && !(VisitDateF.day() == objVD.ASI_HK_CRM_Visit_Date__c.day()+1 && VisitDateF.hour() < 3)) {
            if (strCxlReason == null || strCxlReason.length() <= 0) {
                blnHeaderValidation = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Visit date differ from planned, please enter reason.'));
                return false;
            }
        }
        // Update Visitation Plan Detail
        objVD.ASI_TH_CRM_Visit_Date_Time_From__c = VisitDateF;
        objVD.ASI_TH_CRM_Visit_Date_Time_To__c = VisitDateT;
        objVD.ASI_HK_CRM_Cancellation_Reason__c = strCxlReason;
        objVD.ASI_TH_CRM_Activity_Remarks__c = strRemarks;
        objVD.ASI_CRM_Customer_Feedback__c= strFeedback;
        for(ASI_CRM_Merchandiser_Task__c m : Mertask){
            if(m.ASI_CRM_Photo_Date__c == null){
                m.ASI_CRM_Photo_Date__c=date.today();
            }
        }
        if (blnHeaderValidation == true){
            update objVD;
            update merTask;        
        }else{
            showPageError('Visit date (From) differ from planned visit date, please enter "Reason". ');
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Visit date (From) differ from planned visit date, please enter "Reason".'));
            return false;
        }
            return true;

    }
    
    /** Get Current time in local-time zone 
    public Datetime getLocalTime(Datetime dt) {
        TimeZone tz = UserInfo.getTimeZone();
        return dt.AddSeconds(tz.getOffset(dt) / 1000);
    }*/

    /** Show error message */
    private void showPageMessage(ApexPages.Severity severity, String msg) {
        ApexPages.addMessage(new ApexPages.Message(severity, msg));
    }
    /** Show error message */
    private void showPageError(String msg) {
        showPageMessage(ApexPages.Severity.ERROR, msg);
    }
    
    @RemoteAction
    public static String insertAttachment(String strParentID, String attachmentBody, String attachmentName, String pType, String attachmentId) {
        ASI_CRM_Merchandiser_Task__c MT =[SELECT Id, Name from ASI_CRM_Merchandiser_Task__c WHERE id =:strParentID];
        ASI_CRM_Merchandiser_Task__c MTPhoto =[SELECT Id, Name,ASI_CRM_Photo_Date__c from ASI_CRM_Merchandiser_Task__c WHERE id =:strParentID];
        Date PhotoUploadDate =date.today();
        if(attachmentBody != null) {
            Attachment att = getAttachment(attachmentId);
            String newBody = '';
            
            if(att.Body != null) {
                newBody = EncodingUtil.base64Encode(att.Body);
            }
            newBody += attachmentBody;
            att.Body = EncodingUtil.base64Decode(newBody);
            if(attachmentId == null || Test.isRunningTest()) {
                Integer intSeq = 0;
                String strFName = '';
                List<Attachment> lstAtt = new List<Attachment>();
                
                String str15ID = strParentID;
                if (str15ID.length() == 18)
                    str15ID = str15ID.substring(1, 15);
                
                if (pType == '1' || pType == '2' || pType == '3' || pType == '4') {
                    lstAtt = [SELECT Id, Name FROM Attachment WHERE ParentId = :strParentID AND Name LIKE '%MT%' ORDER BY Name DESC LIMIT 1 ];
                } 
                
                if (lstAtt != null && lstAtt.size() > 0) {
                    strFName = lstAtt[0].Name;
                    String[] arrToken = strFName.split('\\.', 2);
                    if (arrToken != null && arrToken.size() > 0) {
                        String strTemp = '';
                        if (pType == '1' || pType == '2' || pType == '3' || pType == '4') 
                            strTemp = arrToken[0].replace(MT.Name, '');
                        intSeq = Integer.valueOf(strTemp);
                    }
                }

                intSeq++;
                String[] arrToken = attachmentName.split('\\.', 2);
                if (arrToken != null && arrToken.size() >= 2) {
                    strFName = '.' + arrToken[1];
                }
                if (pType == '1' || pType == '2' || pType == '3' || pType == '4') 
                    strFName = MT.Name + ASI_CRM_TW_MerchanDailyReport_Ctrl.fileSeq(intSeq) + strFName;
                if (strFName == null || strFName == '')
                    strFName = 'noname';
                
                att.Name = strFName;
				if(!Test.isRunningTest())                
                	att.parentId = strParentID;
            }
            upsert att;
            if(att.id !=null){
                MTPhoto.ASI_CRM_Photo_Date__c=PhotoUploadDate;
                update MTPhoto;
            }
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