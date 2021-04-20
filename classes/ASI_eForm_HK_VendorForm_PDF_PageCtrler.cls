public class ASI_eForm_HK_VendorForm_PDF_PageCtrler {
    
    Private Static Final Id VENDOR_FORM_LINE_KEY_BANK_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Line_Item__cASI_eForm_HK_Vendor_Form_Line_Item_Key_Bank');
    Private Static Final Id VENDOR_FORM_LINE_KEY_BANK_RO_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Line_Item__cASI_eForm_HK_Vendor_Form_Line_Item_Key_Bank_RO');
    Private Static Final Id NEW_VENDOR_FORM_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_HK_Vendor_Form_New');
    Private Static Final Id NEW_VENDOR_FORM_READONLY_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_HK_Vendor_Form_New_RO');
    Private Static Final Id REVISE_VENDOR_FORM_STEP_ONE_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_HK_Vendor_Form_Revise_Step_1');
    Private Static Final Id REVISE_VENDOR_FORM_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_HK_Vendor_Form_Revise');
    Private Static Final Id ARCHIVED_VENDOR_FORM_RT = Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form__cASI_eForm_HK_Vendor_Form_Archived');
    
    Private Static Final Map<String, Schema.SObjectField> VENDOR_FORM_FIELD_MAP = Schema.SObjectType.ASI_eForm_Vendor_Form__c.fields.getMap();
    Private Static Final Map<String, Schema.SObjectField> VENDOR_FORM_LINE_FIELD_MAP = Schema.SObjectType.ASI_eForm_Vendor_Form_Line_Item__c.fields.getMap();
    
    Private Static Final Set<String> SET_OF_PICKLIST_TO_DISPLAY_LABEL = new Set<String>{'ASI_eForm_Search_Type__c'};
    
    public id formID {set;get;}
    public ASI_eForm_Vendor_Form__c vendorformCurrent{get;set;}
    
    public ASI_eForm_Vendor_Form__c vendorForm {get;set;}
    public list<ASI_eForm_Vendor_Form_Line_Item__c> vendorFormLineList{get;set;}
    
    public ASI_eForm_Vendor_Form__c archivedVendorForm {get;set;}
    public list<ASI_eForm_Vendor_Form_Line_Item__c> archivedVendorFormLineList{get;set;}
    
    Public Map<String, Boolean> mapChanges {Get; Set;}
    Public Map<String, String> picklistLabelMap {Get; Set;}
    
    Public String logoURL {Get; Private Set;}
    Public String keyBankRT{Get; Private Set;}
    Public String keyBankRORT{Get; Private Set;}
    Public String archivedRT{Get; Private Set;}
    
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    //Approval History
    public Class approvalDetail
    {
        public ProcessInstanceHistory history{get;set;}
        public String title{get;set;}
        public String status{get;set;}
        public dateTime approvalDateTime{get;set;}
    }//end class
    
    public ASI_eForm_HK_VendorForm_PDF_PageCtrler(){}
    
    public ASI_eForm_HK_VendorForm_PDF_PageCtrler(ApexPages.StandardController controller) {
		this.vendorformCurrent = (ASI_eForm_Vendor_Form__c)controller.getRecord();
    }  
    
    public boolean init(){
        
        List<Document> logo = new List<Document>([SELECT id, Name FROM Document WHERE DeveloperName LIKE 'ASI_Pernod_Ricard_Logo' LIMIT 1]);
        Id strOrgId = UserInfo.getOrganizationId();
        
        logoURL = logo.size() > 0 ? 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/servlet/servlet.ImageServer?id=' + logo[0].id + '&oid=' + strOrgId : '';
        
        picklistLabelMap = new Map<String, String>();
        
        for(Schema.SObjectField p : VENDOR_FORM_FIELD_MAP.values()){
            
            if(p.getDescribe().getType() == Schema.DisplayType.Picklist && SET_OF_PICKLIST_TO_DISPLAY_LABEL.contains(p.getDescribe().getName())){
                
                for(Schema.PicklistEntry pv : p.getDescribe().getPicklistValues()){
                    picklistLabelMap.put(pv.getValue().toUpperCase(), pv.getLabel().toUpperCase());
                }
            }
        }
        
        keyBankRT = VENDOR_FORM_LINE_KEY_BANK_RT;
        keyBankRORT = VENDOR_FORM_LINE_KEY_BANK_RO_RT;
        archivedRT = ARCHIVED_VENDOR_FORM_RT;
        
        String addonFields = ', Owner.Name';
        
        List<ASI_eForm_Vendor_Form__c> tmpvendorList = new List<ASI_eForm_Vendor_Form__c>();
        tmpvendorList = queryLastVendorForm(null, null, null, ' where Id = \'\'' + formId + '\'\'', addonFields);
        
        if(tmpvendorList.size() > 0){
            
            vendorForm = tmpvendorList[0];
            
            vendorFormLineList = vendorForm.Vendor_Form_Line_Items__r;
        }     
        
        List<ASI_eForm_Vendor_Form__c> tmp = new List<ASI_eForm_Vendor_Form__c>();
        
        if(vendorForm.recordTypeId == ARCHIVED_VENDOR_FORM_RT)
            tmp = queryLastVendorForm(null, null, null, ' where Id = \'\'' + vendorForm.ASI_eForm_Related_Vendor_From__c + '\'\'', addonFields);
        else
            tmp = queryLastVendorForm(null, null, null, ' WHERE ASI_eForm_Related_Vendor_From__c = \'\'' + vendorForm.Id + '\'\' AND ASI_eForm_Clone_From_Orginal__c = TRUE LIMIT 1', addonFields);
        
        if(tmp.size() > 0){
            
            archivedVendorForm = tmp[0];
            archivedVendorFormLineList = tmp[0].Vendor_Form_Line_Items__r;
        }else{
            archivedVendorForm = Null;
            archivedVendorFormLineList = new List<ASI_eForm_Vendor_Form_Line_Item__c>();
        }
        
        if(archivedVendorForm != Null ){
            
            Map<Id, ASI_eForm_Vendor_Form_Line_Item__c> lineMap = new Map<Id, ASI_eForm_Vendor_Form_Line_Item__c>();
            
            for(ASI_eForm_Vendor_Form_Line_Item__c obj : archivedVendorFormLineList){
                
                lineMap.put(obj.ASI_eForm_Related_Vendor_From_Line__c, obj);
            }
            
            checkFieldModification(vendorForm, new Map<Id, ASI_eForm_Vendor_Form__c>{vendorForm.id => vendorForm}, archivedVendorForm, lineMap);
            
            if(!String.isBlank(archivedVendorForm.ASI_eForm_Search_Type__c) && !picklistLabelMap.containsKey(archivedVendorForm.ASI_eForm_Search_Type__c.toUpperCase())){
                
                picklistLabelMap.put(archivedVendorForm.ASI_eForm_Search_Type__c.toUpperCase(), archivedVendorForm.ASI_eForm_Search_Type__c.toUpperCase());
            }
        }
        
        if(!String.isBlank(vendorForm.ASI_eForm_Search_Type__c) && !picklistLabelMap.containsKey(vendorForm.ASI_eForm_Search_Type__c.toUpperCase())){
            
            picklistLabelMap.put(vendorForm.ASI_eForm_Search_Type__c.toUpperCase(), vendorForm.ASI_eForm_Search_Type__c.toUpperCase());
        }
        
        getapprovalDetails();
		return true; 
    }
    
    public List<approvalDetail> getapprovalDetails()
    {
        List<approvalDetail> details = new List<approvalDetail>();
        if (details.size() == 0 && formID != null)
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
                                           WHERE TargetObjectId = :formID
                                           ORDER BY CreatedDate DESC
                                           Limit 1];
            Set<Id> actoerIdSet = new Set<Id>();
            for (ProcessInstance p:pList){
                for (ProcessInstanceHistory his:p.StepsAndWorkitems){
                    actoerIdSet.add(his.ActorId);
                }//end for
            }//end for
            Map<Id, User> userMap = new Map<Id, User>([Select Id, title From User Where Id In :actoerIdSet]);
            for (ProcessInstance p:pList)
            {
                Boolean byPassPending = false;
                if(p.StepsAndWorkitems.size() != 0 &&(p.StepsAndWorkitems[0].StepStatus == 'Approved' || p.StepsAndWorkitems[0].StepStatus == 'Rejected')){
                    byPassPending = true;
                }//end if
                for (ProcessInstanceHistory his:p.StepsAndWorkitems){
                    if(his.StepStatus != 'Reassigned' && his.StepStatus != 'NoResponse' && !(byPassPending && his.StepStatus == 'Pending')){
                        approvalDetail detail = new approvalDetail();
                        if(his.StepStatus == 'Removed')
                            detail.status = 'Recalled';
                        else if(his.StepStatus == 'Started')
                            detail.status = 'Submitted';
                        else
                            detail.status = his.StepStatus;
                            
                        detail.title = userMap.get(his.ActorId).title;
                        detail.history = his;
                        detail.approvalDateTime = his.CreatedDate.addSeconds(integer.valueOf(UserInfo.getTimeZone().getOffset(his.CreatedDate)/1000));
                        details.add(detail);
                    }//end if
                }//end for
            }//end for
        }//end if
        return details;
    }//end method: getapprovalDetails
    
    Private List<ASI_eForm_Vendor_Form__c> queryLastVendorForm(Set<String> setOne, Set<String> setTwo, List<ASI_eForm_Vendor_Form__c> triggerNew, String whereClause, String additionalFields){
        
        Map<String, Schema.SObjectField> vendorForm_FIELD_MAP = Schema.SObjectType.ASI_eForm_Vendor_Form__c.fields.getMap();
        Map<String, Schema.SObjectField> vendorFormLine_FIELD_MAP = Schema.SObjectType.ASI_eForm_Vendor_Form_Line_Item__c.fields.getMap();
        List<String> paraList = new List<String>{'setOne', 'setTwo', 'triggerNew'};
	        
        String queryStr = 'SELECT ';
        
        queryStr += String.join(new List<String>(vendorForm_FIELD_MAP.keySet()), ', ');
        
        queryStr += additionalFields;
        
        queryStr += ', (SELECT ';
        
        queryStr += String.join(new List<String>(vendorFormLine_FIELD_MAP.keySet()), ', ');
        
        queryStr += ' FROM Vendor_Form_Line_Items__r ORDER BY RecordType.DeveloperName) FROM ASI_eForm_Vendor_Form__c ' + String.format(whereClause, paraList);
        //system.assertEquals(queryStr, '');
        Return database.query(queryStr);
    }
    
    Private Void checkFieldModification(ASI_eForm_Vendor_Form__c vendorForm, Map<Id, ASI_eForm_Vendor_Form__c> vendorFormMap, ASI_eForm_Vendor_Form__c snapshotVersion, Map<Id, ASI_eForm_Vendor_Form_Line_Item__c> snapshotVersionLineMap){
        
        mapChanges = new Map<String, Boolean>();
        
        for(String field : VENDOR_FORM_FIELD_MAP.keySet()){
            
            if(vendorForm.get(field) != snapshotVersion.get(field)){
                
                mapChanges.put(field.toUpperCase(), True);
            }else{
                
                mapChanges.put(field.toUpperCase(), False);
            }
        }
        
        for(String field : VENDOR_FORM_LINE_FIELD_MAP.keySet()){
            
            for(ASI_eForm_Vendor_Form_Line_Item__c vfl : vendorFormMap.get(vendorForm.id).Vendor_Form_Line_Items__r){
                
                mapChanges.put(vfl.id, False);
                
                if(snapshotVersionLineMap.containsKey(vfl.id)){
                    
                    if(vfl.get(field) != snapshotVersionLineMap.get(vfl.id).get(field)){
                        
                        mapChanges.put('' + vfl.id + field.toUpperCase(), True);
                        
                    }else{
                        
                        mapChanges.put('' + vfl.id + field.toUpperCase(), False);
                    }
                    
                }else{
                    mapChanges.put(vfl.id, True);
                }
            }
        }
    }
}