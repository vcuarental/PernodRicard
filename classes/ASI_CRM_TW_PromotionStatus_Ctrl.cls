/*Filename:    ASI_CRM_TW_PromotionStatus_Ctrl.cls
* Author:      Twinkle LI (Introv Limited)
* Purpose:     Controller Class for promotion status update for TW CRM
*
* -----------------------------------------------------------------------------
*/
public without sharing class ASI_CRM_TW_PromotionStatus_Ctrl{
    
    public id promoId {set;get;}
    public ASI_HK_CRM_Promotion__c promo {set;get;}
    transient List<ASI_CRM_Promotion_Status__c> listPromoStatus {set;get;}
    public List<ASI_CRM_Promotion_Status__c> listDeletedPromoStatus {set;get;}
    public Map<integer, promoStatus> mapPromoStatus {set;get;}
    public Integer intRowid {set;get;}
    public Integer intIndexPromoStatus {set;get;}
    public Map<string, decimal> mapWSSummary {set;get;}
    public Decimal totalUnit {set;get;}
    public List<SelectOption> listSupplierPicklist {set; get;}
    public String selectView {set;get;}
    public List<SelectOption> listSelectViews {set; get;}
    
    //Added by William Yang(Introv) 20160816
    public String selectRegion {set;get;}
    public List<SelectOption> listRegions {set; get;}
    Set<String> setRegion {set; get;}
    transient List<ASI_CRM_Promotion_Target__c> listPromoTarget {set; get;}
    
    public String userLanguage {set;get;}
    public User userProfile {set;get;}
    public Set<String> setRegionCode {set;get;}
    //transient Map<id, ASI_CRM_AccountsAdditionalField__c> mapSupplierRegion {set; get;}
    //transient Map<id, ASI_CRM_AccountsAdditionalField__c> mapAccountRegion {set; get;}
    
    //Renderring based on Permission Sets
    public Boolean readOnly {set;get;}
    public Boolean grantCheckDone {set;get;}
    
    //Added by Introv @20170405
    public List<PermissionSetAssignment> listCurrentUserPerSet { get; set; }
    
    public Class promoStatus{
        public ASI_CRM_Promotion_Status__c status {get;set;}
        public Boolean boolDetailsNotEditable {get;set;}
        public Boolean boolAccNotEditable {get;set;} 
        public String errorMsg {get;set;} //For duplication checking
        public String errorMsg1 {get;set;} //For supplier checking
        public Boolean boolNew { get; set; }
    }
     
    public ASI_CRM_TW_PromotionStatus_Ctrl(ApexPages.StandardController controller) {
        promoId = ApexPages.currentPage().getParameters().get('id');
        init();  
    }
    
    public void init(){
        userLanguage = UserInfo.getLanguage();
        userProfile = [SELECT ASI_KOR_User_Region_Code__c FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
        setRegionCode = new Set<String>();
        listRegions = new List<SelectOption>(); 
        if(userProfile.ASI_KOR_User_Region_Code__c != null && userProfile.ASI_KOR_User_Region_Code__c != ''){
            String[] tmpString = userProfile.ASI_KOR_User_Region_Code__c.split(';');
            integer index = 0;
            For(String s : tmpString){
                s = s.replace('[', '').replace(']', '');
                setRegionCode.add(s);
                index++;
                //Added by William Yang(Introv) 20160816
                listRegions.add(new SelectOption(s, s));
            }
            system.debug(setRegionCode);
        }
        //Modified by William Yang(Introv) 20160816
        else {      
            listRegions.add(new SelectOption('North', 'North'));
            //listRegions.add(new SelectOption('North 2', 'North 2'));
            listRegions.add(new SelectOption('Central', 'Central'));
            listRegions.add(new SelectOption('South', 'South'));
            listRegions.add(new SelectOption('CVS', 'CVS'));
            listRegions.add(new SelectOption('SUPER', 'SUPER'));
            listRegions.add(new SelectOption('HYPER', 'HYPER'));
        }
        system.debug('listRegions:'+listRegions);
        system.debug('selectRegion:'+ selectRegion);
        selectRegion=listRegions[0].getvalue();
        system.debug('selectRegion:'+ selectRegion);
        //End
        
        intIndexPromoStatus = 0;
        promo = new ASI_HK_CRM_Promotion__c();
        listPromoTarget = new List<ASI_CRM_Promotion_Target__c>();
        setRegion = new Set<String>();
        
        listSelectViews = new List<SelectOption>();          
        listSelectViews.add(new SelectOption('All Outlets', 'All Outlets'));
        listSelectViews.add(new SelectOption('My Outlets', 'My Outlets'));
        
        //Check Current User Permission Sets
        List<PermissionSetAssignment> lstcurrentUserPerSet = new List<PermissionSetAssignment>();
        if(Userinfo.getUserId() != NULL)
            lstcurrentUserPerSet = [SELECT Id, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()];
        
        for (PermissionSetAssignment psa: lstcurrentUserPerSet){
            system.debug('##lstcurrentUserPerSet' + psa.PermissionSet.Name);
            if(psa.PermissionSet.Name.equals('ASI_CRM_TW_Outlet_Sales') || 
               psa.PermissionSet.Name.equals('ASI_CRM_TW_Outlet_Channel_Manager') ||
               psa.PermissionSet.Name.equals('ASI_CRM_TW_System_Admin') ||
               psa.PermissionSet.Name.equals('ASI_CRM_TW_Power_User')||
               psa.PermissionSet.Name.equals('ASI_CRM_TW_Regional_Manager')){
                readOnly = false;
                break;
            }
            else
                readOnly = true;
        }
        grantCheckDone = false;
        for (PermissionSetAssignment psa: lstcurrentUserPerSet){
            system.debug('##lstcurrentUserPerSet' + psa.PermissionSet.Name);
            if(psa.PermissionSet.Name.equals('ASI_CRM_TW_TMKT_Users')){
                grantCheckDone = true;
                break;
            }
            else
                grantCheckDone = false;
        }
        runSearch();
    }
    public void runSearch(){
        listSupplierPicklist = new List<SelectOption>();
        //mapSupplierRegion = new Map<id, ASI_CRM_AccountsAdditionalField__c>();
        //mapAccountRegion = new Map<id, ASI_CRM_AccountsAdditionalField__c>();
        listPromoStatus = new List<ASI_CRM_Promotion_Status__c>();
        mapPromoStatus = new Map<integer, promoStatus>();
        listDeletedPromoStatus = new List<ASI_CRM_Promotion_Status__c>();
        
        if(promoId != NULL){
            listCurrentUserPerSet = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() 
                                 AND PermissionSet.Name in ('ASI_CRM_TW_Outlet_Channel_Manager')];                                 
                                 
            system.debug('selectRegion: ' + selectRegion);
            //Modified by Twinkle @20160427
            List<ASI_CRM_AccountsAdditionalField__c> listCust = new List<ASI_CRM_AccountsAdditionalField__c>();
            listCust = [SELECT id, ASI_CRM_Is_Supplier__c, ASI_CRM_Account__r.id, ASI_CRM_Account__r.Name, ASI_CRM_Account__r.ASI_TH_CRM_Region__c
                        FROM ASI_CRM_AccountsAdditionalField__c 
                        WHERE ASI_CRM_Account__r.ASI_TH_CRM_Region__c = :selectRegion];
            system.debug('listCust: '+listCust);
            
            for(ASI_CRM_AccountsAdditionalField__c cust : listCust){
                if(cust.ASI_CRM_Is_Supplier__c){
                    //mapSupplierRegion.put(cust.ASI_CRM_Account__r.Id, cust);
                    listSupplierPicklist.add(new SelectOption(cust.ASI_CRM_Account__r.Id, cust.ASI_CRM_Account__r.Name));
                }
                //mapAccountRegion.put(cust.ASI_CRM_Account__r.Id, cust);
            }

            promo = [SELECT id, Name, ASI_HK_CRM_Promotion_Name__c, ASI_CRM_Display_Check__c, ASI_CRM_Display_Setup__c, ASI_CRM_POSM__c FROM ASI_HK_CRM_Promotion__c WHERE id =: promoId];
        
            listPromoTarget = [SELECT id, ASI_CRM_Region__c FROM ASI_CRM_Promotion_Target__c
                               WHERE ASI_CRM_Promotion__c =: promoId AND 
                               RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Target__cASI_CRM_TW_PromotionTarget')
                              AND ASI_CRM_CONFIRMED__C = TRUE];
                               
            for(ASI_CRM_Promotion_Target__c target : listPromoTarget){
                setRegion.add(target.ASI_CRM_Region__c);
            }
            
            //Modified by Twinkle @20160427
            if(selectRegion != null && selectRegion != ''){
                listPromoStatus = [SELECT id, ASI_CRM_Account__c, ASI_CRM_Account__r.Name, ASI_CRM_Account__r.OwnerId, ASI_CRM_Account__r.ASI_HK_CRM_JDE_Account_Number__c, 
                                   ASI_CRM_Account__r.ASI_TH_CRM_Region__c, ASI_CRM_Unit__c, ASI_CRM_Supplier__c, ASI_CRM_Supplier__r.Name, 
                                   ASI_CRM_Supplier__r.ASI_TH_CRM_Region__c, ASI_CRM_Promotion__c, ASI_CRM_Source__c, ASI_CRM_Task__c, ASI_CRM_Done__c, ASI_CRM_Remarks__c
                                   FROM ASI_CRM_Promotion_Status__c 
                                   WHERE ASI_CRM_Promotion__c =: promoId AND RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Status__cASI_CRM_TW_PromotionStatus')
                                   AND ASI_CRM_Region__c = :selectRegion
                                   ORDER BY ASI_CRM_Account__r.ASI_HK_CRM_JDE_Account_Number__c ASC, ASI_CRM_Source__c ASC];
            }
            
            for(ASI_CRM_Promotion_Status__c status : listPromoStatus){
                promoStatus classPromoStatus = new promoStatus();
                classPromoStatus.status = status;
                classPromoStatus.boolNew = false;
                
                if (status.ASI_CRM_Account__c != NULL) {
                    if(setRegion.contains(status.ASI_CRM_Account__r.ASI_TH_CRM_Region__c)){
                        classPromoStatus.boolDetailsNotEditable = true;
                        classPromoStatus.boolAccNotEditable = true;
                    }
                    else {
                        classPromoStatus.boolDetailsNotEditable = false;
                        classPromoStatus.boolAccNotEditable = true;
                    }
                }
                mapPromoStatus.put(intIndexPromoStatus++, classPromoStatus);
            } 
        } 
        WSSummaryCal();
    }
    
    public void addPromoStatus(){
        ASI_CRM_Promotion_Status__c objPromoStatus = new ASI_CRM_Promotion_Status__c(ASI_CRM_Promotion__c=this.promo.id, RecordTypeId=Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Status__cASI_CRM_TW_PromotionStatus'), ASI_CRM_Source__c='Report');
        promoStatus classPromoStatus = new promoStatus();
        classPromoStatus.status = objPromoStatus;
        classPromoStatus.status.ASI_CRM_Task__c = 'Display Setup';
        classPromoStatus.boolDetailsNotEditable = false;
        classPromoStatus.boolAccNotEditable = false;
        classPromoStatus.boolNew = true;
                
        mapPromoStatus.put(intIndexPromoStatus++, classPromoStatus);
        system.debug(mapPromoStatus);
    }
    public void clonePromoStatus(){
        if(intRowid != NULL && mapPromoStatus.get(intRowid) != NULL){
            ASI_CRM_Promotion_Status__c objPromoStatus = mapPromoStatus.get(intRowid).status;
            ASI_CRM_Promotion_Status__c objPromoStatus_Clone = objPromoStatus.clone(false, true);
            
            promoStatus classPromoStatus = new promoStatus();
            classPromoStatus.status = objPromoStatus_Clone;
            classPromoStatus.status.ASI_CRM_Promotion__c = this.promo.id;
            classPromoStatus.status.ASI_CRM_Source__c = 'Report';
            classPromoStatus.boolDetailsNotEditable = false;
            classPromoStatus.boolAccNotEditable = false;
            classPromoStatus.status.ASI_CRM_Task__c = 'Display Setup';
            classPromoStatus.boolNew = true;
            //classPromoStatus.errorMsg = (userlanguage=='zh_TW'?'重複店家':'Duplicated Outlet');
            
            /*ASI_CRM_AccountsAdditionalField__c objCustomer = new ASI_CRM_AccountsAdditionalField__c();
        
            if(mapPromoStatus.get(intRowid) != NULL && mapPromoStatus.get(intRowid).status != NULL && mapPromoStatus.get(intRowid).status.ASI_CRM_Supplier__c != NULL)
                objCustomer = [SELECT id, ASI_CRM_Is_Supplier__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c =: mapPromoStatus.get(intRowid).status.ASI_CRM_Supplier__c];
            
            if(objCustomer != NULL && !objCustomer.ASI_CRM_Is_Supplier__c)
                classPromoStatus.errorMsg1 = (userlanguage=='zh_TW'?'非供貨商':'Not Supplier');*/
            
            mapPromoStatus.put(intIndexPromoStatus++, classPromoStatus);
            system.debug(intIndexPromoStatus);
        }
    }
    public void deletePromoStatus(){
        if(intRowid != NULL && mapPromoStatus.get(intRowid) != NULL){
            if(mapPromoStatus.get(intRowid).status != NULL && mapPromoStatus.get(intRowid).status.id != NULL)
                listDeletedPromoStatus.add(mapPromoStatus.get(intRowid).status);
            mapPromoStatus.remove(intRowid);
        }
        system.debug(mapPromoStatus);
    }
    
    public void WSSummaryCal(){
        mapWSSummary = new Map<string, decimal>();
        totalUnit = 0;      
        
        for(Integer promoStatusKey : mapPromoStatus.keySet()){
            if(mapPromoStatus.get(promoStatusKey) != NULL){
                ASI_CRM_Promotion_Status__c promoStatus = mapPromoStatus.get(promoStatusKey).status;
                if(promoStatus.ASI_CRM_Supplier__c != NULL && promoStatus.ASI_CRM_Supplier__r.Name != NULL && promoStatus.ASI_CRM_Unit__c != NULL){
                    if(mapWSSummary.get(promoStatus.ASI_CRM_Supplier__r.Name) != NULL){
                        Decimal num = mapWSSummary.get(promoStatus.ASI_CRM_Supplier__r.Name);
                        num += promoStatus.ASI_CRM_Unit__c;
                        totalUnit += promoStatus.ASI_CRM_Unit__c;
                        mapWSSummary.put(promoStatus.ASI_CRM_Supplier__r.Name, num);
                    }
                    else{
                        totalUnit += promoStatus.ASI_CRM_Unit__c;
                        mapWSSummary.put(promoStatus.ASI_CRM_Supplier__r.Name, promoStatus.ASI_CRM_Unit__c);
                    }
                }
            }
        }
        system.debug('mapWSSummary: '+mapWSSummary);
    }
    
    public void checkOutlet(){    
        Set<Id> listOutlets = new Set<Id>();
        if(intRowid != NULL && mapPromoStatus.get(intRowid) != NULL){
            mapPromoStatus.get(intRowid).errorMsg = ''; 
            
            if(mapPromoStatus.get(intRowid).status != NULL && mapPromoStatus.get(intRowid).status.ASI_CRM_Account__c != NULL){
                for(Integer promoStatusKey : mapPromoStatus.keySet()){
                    if(promoStatusKey != intRowid && mapPromoStatus.get(promoStatusKey) != NULL && mapPromoStatus.get(promoStatusKey).status != NULL && mapPromoStatus.get(promoStatusKey).status.ASI_CRM_Account__c != NULL){
                        listOutlets.add(mapPromoStatus.get(promoStatusKey).status.ASI_CRM_Account__c);
                    }
                }
                
                if(listOutlets.contains(mapPromoStatus.get(intRowid).status.ASI_CRM_Account__c))
                    mapPromoStatus.get(intRowid).errorMsg = (userlanguage=='zh_TW'?'(重複店家)':'(Duplicated Outlet)');
            }
        }
    }
    
    /*public void checkSupplier(){   
        mapPromoStatus.get(intRowid).errorMsg1 = '';        
        ASI_CRM_AccountsAdditionalField__c objCustomer = new ASI_CRM_AccountsAdditionalField__c();
        
        if(mapPromoStatus.get(intRowid) != NULL && mapPromoStatus.get(intRowid).status != NULL && mapPromoStatus.get(intRowid).status.ASI_CRM_Supplier__c != NULL)
            objCustomer = [SELECT id, ASI_CRM_Is_Supplier__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c =: mapPromoStatus.get(intRowid).status.ASI_CRM_Supplier__c];
        
        if(objCustomer != NULL && !objCustomer.ASI_CRM_Is_Supplier__c)
            mapPromoStatus.get(intRowid).errorMsg1 = (userlanguage=='zh_TW'?'非供貨商':'Not a Supplier');
    }*/
    
    public void checkViewSelection(){
        if(selectView == 'My Outlets'){
            for (Integer promoStatusKey : mapPromoStatus.keySet()) {
                ASI_CRM_Promotion_Status__c objPromoStatus = mapPromoStatus.get(promoStatusKey).status;
                
                if (objPromoStatus.ASI_CRM_Account__r.OwnerId != Userinfo.getUserId())
                    mapPromoStatus.remove(promoStatusKey);
            }
            
            WSSummaryCal();
        }    
        else
            runSearch();
    }
    
    public PageReference quickSave(){
        Boolean saveSuccess = implSaveChanges();
        if(saveSuccess)
            WSSummaryCal();
            
        PageReference redirectPage = NULL;
        /*
        if (saveSuccess) {
            redirectPage = Page.ASI_CRM_TW_PromotionStatus_Page;
            redirectPage.setRedirect(true);
            redirectPage.getParameters().put('id', promoId);
        }
        */
        return redirectPage;
    }
    public PageReference saveAction(){
       Boolean saveSuccess = implSaveChanges();
       PageReference redirectPage = NULL;
       if (saveSuccess) {
           redirectPage = new PageReference('/' + promoId);
           redirectPage.setRedirect(true);
       }
       return redirectPage;
    }    
    public Boolean implSaveChanges(){
        Boolean allSuccess = true;
        List<ASI_CRM_Promotion_Status__c> listPromoStatus = new List<ASI_CRM_Promotion_Status__c>();
        Set<Id> listOutlets = new Set<Id>();
        Set<String> setAccountSupplierId = new Set<String>();
        
        System.Savepoint sp = database.setSavepoint();
        
        for(Integer promoStatusKey : mapPromoStatus.keySet()){
            if(mapPromoStatus.get(promoStatusKey) != NULL){ 
                mapPromoStatus.get(promoStatusKey).errormsg = '';
                mapPromoStatus.get(promoStatusKey).errormsg1 = '';
                ASI_CRM_Promotion_Status__c promoStatus = mapPromoStatus.get(promoStatusKey).status;
                listPromoStatus.add(promoStatus); 
                
                system.debug('#allSuccess: '+allSuccess);
                                
                //Added by Introv @20160726
                system.debug('Account: '+promoStatus.ASI_CRM_Account__c);
                system.debug('Supplier: '+promoStatus.ASI_CRM_Supplier__c);
                if(!mapPromoStatus.get(promoStatusKey).boolDetailsNotEditable && setAccountSupplierId != NULL && 
                    promoStatus.ASI_CRM_Account__c != NULL && promoStatus.ASI_CRM_Supplier__c != NULL &&
                    setAccountSupplierId.contains(promoStatus.ASI_CRM_Account__c+'-'+promoStatus.ASI_CRM_Supplier__c)){
                    mapPromoStatus.get(promoStatusKey).errorMsg = (userlanguage=='zh_TW'?'重複店家與供應商':'Duplicated Outlet with same Supplier.');
                    allSuccess = false;
                }
                system.debug('#allSuccess: '+allSuccess);
                //Added by Introv @20160726
                
                if(promoStatus.ASI_CRM_Account__c != NULL){
                    listOutlets.add(promoStatus.ASI_CRM_Account__c);
                    if(promoStatus.ASI_CRM_Supplier__c != NULL)
                        setAccountSupplierId.add(promoStatus.ASI_CRM_Account__c+'-'+promoStatus.ASI_CRM_Supplier__c);
                }
            }
        }
        system.debug('#allSuccess: '+allSuccess);
        
        if(!allSuccess){
            return false;
        }
        
        if (listDeletedPromoStatus.size() > 0) {
            try {
                delete listDeletedPromoStatus;
            } catch (Exception e) {
                allSuccess = false;
                database.rollback(sp);
                system.debug('Error: '+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
        }
        if (allSuccess && listPromoStatus.size() > 0) {
            system.debug('listPromoStatus: '+listPromoStatus);
            try {
                upsert listPromoStatus;
            } catch (Exception e) {
                allSuccess = false;
                database.rollback(sp);
                system.debug('Error: '+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
        }
        
        if (allSuccess) {
            for (Integer promoStatusKey : mapPromoStatus.keySet()) {
                if (mapPromoStatus.get(promoStatusKey) != NULL) {
                    mapPromoStatus.get(promoStatusKey).boolNew = false;
                }
            }
        }
        
        return allSuccess;    
    }
    
    @RemoteAction
    public static String[] findSObjects(string obj, string qry, string rec) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        
        List<String> results = new List<String>();
        String key='%'+String.escapeSingleQuotes(qry)+'%';

        List<ASI_CRM_AccountsAdditionalField__c> listCustomers = new List<ASI_CRM_AccountsAdditionalField__c>();
        map<string, id> map_recordtype =ASI_MFM_Function.getRecordTypeId('ASI_CRM_AccountsAdditionalField__c');
        
        String userLanguage = UserInfo.getLanguage();
        User userProfile = [SELECT ASI_KOR_User_Region_Code__c FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
        Set<String> setRegionCode = new Set<String>();
        if(userProfile.ASI_KOR_User_Region_Code__c != null){
            String[] tmpString = userProfile.ASI_KOR_User_Region_Code__c.split(';');
            For(String s : tmpString){
                s = s.replace('[', '').replace(']', '');
                setRegionCode.add(s);
            }
            system.debug(setRegionCode);
        }
        else {
            setRegionCode.add('Central');
            setRegionCode.add('North');
            //setRegionCode.add('North 2');
            setRegionCode.add('South');
            setRegionCode.add('CVS');
        }

        try {
            listCustomers =[SELECT Name, RecordTypeid,ASI_CRM_Account__r.Name FROM ASI_CRM_AccountsAdditionalField__c
                            WHERE RecordTypeid=:map_recordtype.get('ASI_CRM_TW_Outlet') 
                            AND Name like : key 
                            AND ASI_CRM_Account__r.ASI_HK_CRM_Inactive__c = FALSE
                            AND ASI_CRM_Account__r.ASI_TH_CRM_Region__c IN: setRegionCode
                            ORDER BY NAME];

            for(ASI_CRM_AccountsAdditionalField__c cust : listCustomers){
               results.add(cust.ASI_CRM_Account__r.Name);  
           }
        }
        catch (QueryException e) {
            return null;
        }
        return results;
   }
    
    @RemoteAction
    public static String insertAttachment(String strParentID, String attachmentBody, String attachmentName, String pType, String attachmentId) {
    
        boolean checkEVresult = attachmentName.substring(0,5).contains('EV_');
        
        system.debug('attachmentName' + attachmentName);
        
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
                
                if (pType == '1' || pType == '2' || pType == '3' || pType == '4') {
                    if(checkEVresult)
                        lstAtt = [SELECT Id, Name FROM Attachment WHERE ParentId = :strParentID AND Name LIKE 'EV_PromoStatus%' ORDER BY Name DESC LIMIT 1 ];
                    else
                        lstAtt = [SELECT Id, Name FROM Attachment WHERE ParentId = :strParentID AND Name LIKE 'PromoStatus%' ORDER BY Name DESC LIMIT 1 ];

                }
                                                
                if (lstAtt != null && lstAtt.size() > 0) {
                    strFName = lstAtt[0].Name;
                    String[] arrToken = strFName.split('\\.', 2);
                    if (arrToken != null && arrToken.size() > 0) {
                        String strTemp = '';
                        if (pType == '1' || pType == '2' || pType == '3' || pType == '4'){
                            if(checkEVresult)
                                strTemp = arrToken[0].replace('EV_PromoStatus_', '');
                            else
                                strTemp = arrToken[0].replace('PromoStatus_', '');
                        }
                        intSeq = Integer.valueOf(strTemp);
                        system.debug('value of intseq:' + intSeq);
                    }
                }
              
                intSeq++;
                  
                String[] arrToken = attachmentName.split('\\.', 2);
                if (arrToken != null && arrToken.size() >= 2) {
                    strFName = '.' + arrToken[1];
                }
                 
                if (pType == '1' || pType == '2' || pType == '3' || pType == '4') 
                {
                    if(checkEVresult)
                    {
                        strFName = 'EV_PromoStatus_' + ASI_CRM_TW_PromotionStatus_Ctrl.fileSeq(intSeq) + strFName;
                    }
                    else
                    {
                        strFName = 'PromoStatus_' + ASI_CRM_TW_PromotionStatus_Ctrl.fileSeq(intSeq) + strFName;

                    }
                }
                
                if (strFName == null || strFName == '')
                    strFName = 'noname'; 
                
                    att.Name = strFName;
                	att.parentId = strParentID;                
            }
            upsert att;
            system.debug('Id :'+att.Id);
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