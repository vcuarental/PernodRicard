public with sharing class ASI_MFM_SC_ObjectPickListHelper {

    public List<SelectOption> pickList{get;set;}
    public Map<String,List<SelectOption>> dependentMap {get;set;}
    //public Map<String,ExpenseCategoryClassification> dependentExpenseCategoryClassificationMap {get;set;}
    public List<sObject> existingSObjList{get;set;}
    public String sObjInputTypeStr { get; set;}
    public String sObjInputFieldStr { get; set; }
    public String dependentFieldStr { get; set; }
    public String languageLocale { get; set; }
    public String allowedLanguage { get; set; }
    public String headerPlanID {get;set;}
    public String recordTypeIncluded {get;set;}
    
    public ASI_MFM_SC_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr){
        this(sObjInputTypeStr,sObjInputFieldStr,null,null,null);
    }
    
    public ASI_MFM_SC_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr, String dependentFieldStr, 
    String languageLocale, String allowedLanguage){
        this(sObjInputTypeStr,sObjInputFieldStr,null,null,null,null);
    }
    
    public ASI_MFM_SC_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr, String dependentFieldStr, 
    String languageLocale, String allowedLanguage, String PARAMheaderPlanID){
        this.sObjInputTypeStr = sObjInputTypeStr;
        this.sObjInputFieldStr = sObjInputFieldStr;
        this.dependentFieldStr = dependentFieldStr;
        this.languageLocale = languageLocale;
        this.allowedLanguage = allowedLanguage; 
        this.headerPlanID = PARAMheaderPlanID;
        this.recordTypeIncluded = NULL;
        init(); 
    }
    
    /*DC - 8-Dec-2015 - Created overloaded constructor to provide scope for record type.*/
    public ASI_MFM_SC_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr, String dependentFieldStr, 
    String languageLocale, String allowedLanguage, String PARAMheaderPlanID, String recordTypeIncluded){
        this.sObjInputTypeStr = sObjInputTypeStr;
        this.sObjInputFieldStr = sObjInputFieldStr;
        this.dependentFieldStr = dependentFieldStr;
        this.languageLocale = languageLocale;
        this.allowedLanguage = allowedLanguage; 
        this.headerPlanID = PARAMheaderPlanID;
        this.recordTypeIncluded = recordTypeIncluded;
        init(); 
    }
    
    private void init(){
        // System.debug('------ CRT NAME ------- : ' + ApexPages.currentPage().getParameters().get('crtName'));
        Schema.sObjectType sobjType = Schema.getGlobalDescribe().get(sObjInputTypeStr);
        Map<String, Schema.SObjectField> sObjFieldMap = sObjType.getDescribe().fields.getMap();
        Schema.DescribeFieldResult describeFieldResult = sObjFieldMap.get(sObjInputFieldStr).getDescribe();    
    
        if(!describeFieldResult.isNamePointing()){
        
            List<Schema.sObjectType> sObjTypeList = describeFieldResult.getReferenceTo();
            String retObject = sObjTypeList[0].getDescribe().getName();
            
            String fields = ' id, ';
            
            if (allowedLanguage != null && allowedLanguage.contains(languageLocale))
            {
             fields += ' Name_'+languageLocale+'__c '; 
            } else
            {
             fields += ' Name ';             
            }
                        
            List<ASI_MFM_PO__c> headerPOList;
            List<ASI_MFM_Payment__c> headerPaymentList;
            
            String rtCAPID = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_SC_A_C_Code');
            String rtCAPAPID = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_SC_AP_Code');
            String rtCAPBUID = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_SC_BU');
            
            if(!String.isBlank(recordTypeIncluded)) {
                // @DC - 26-Feb-2016 - Seperated record type checking condition for bug fix in CAP project.
                if(recordTypeIncluded.containsIgnoreCase('PO')) {
                    Id poId = ApexPages.currentPage().getParameters().get('Id');
                    headerPOList = [SELECT ASI_MFM_PO_Type__c, asi_mfm_plan__c
                                      FROM ASI_MFM_PO__c
                                     WHERE Id = :poId];
                } else if(recordTypeIncluded.containsIgnoreCase('Payment')) {
                    Id paymentId = ApexPages.currentPage().getParameters().get('Id');
                    headerPaymentList = [SELECT ASI_MFM_Payment_Type__c, asi_mfm_po__r.asi_mfm_plan__c
                                           FROM ASI_MFM_Payment__c
                                          WHERE Id = :paymentId];
                }
            } 
            Boolean isOpex = false;
            Id planid=null;
            /*Check if the header PO or Payment are of OPEX type, if yes, set isOpex to true.*/
            if(headerPOList != NULL && !headerPOList.isEmpty()) {
                if(headerPOList[0].ASI_MFM_PO_Type__c == 'OPEX') {
                    isOpex = true;
                }
                planid=headerPOList[0].ASI_MFM_Plan__c;
            } else if(headerPaymentList != NULL && !headerPaymentList.isEmpty()) {
                if(headerPaymentList[0].ASI_MFM_Payment_Type__c == 'OPEX') {
                    isOpex = true;
                }
                planid=headerPaymentList[0].ASI_MFM_PO__r.ASI_MFM_Plan__c;
            }
            
            String companySet='\'t\'';
            if(recordTypeIncluded.containsIgnoreCase('PO') || recordTypeIncluded.containsIgnoreCase('Payment')){
                List<asi_mfm_plan_line_item__c> pls=[select asi_mfm_pr_company__c from asi_mfm_plan_line_item__c where asi_mfm_plan__c = :planid];
                
                for(asi_mfm_plan_line_item__c pl :pls){
                   if(pl.asi_mfm_pr_company__c!=null && !pl.asi_mfm_pr_company__c.equals('') && !companySet.containsIgnoreCase(pl.asi_mfm_pr_company__c))
                       companySet+=',\''+pl.asi_mfm_pr_company__c+'\''; 
                }
                
            }
            
System.debug('t='+companySet);
            String ApCodeQuery = 
            'SELECT ' + 
            fields +',asi_mfm_sc_Need_Subleger__c'+  
            ' FROM ' + 
            retObject + 
            ' WHERE recordtypeid = \'' + rtCAPAPID + '\'' +
            ' AND ASI_MFM_Inactive__c = false' +
            ' order by Name LIMIT 200';

            // Filter out the AP Code picklist depending on Plan type. Capex/Opex
            
            String queryStr = retObject == 'ASI_MFM_A_C_Code__c' ? 
            ('SELECT ' + 
            fields + 
            ' FROM ' + 
            retObject + 
            ' WHERE recordtypeid = \'' + rtCAPID + '\'' +
            ' order by Name LIMIT 200'
            )
            :
            (
            retObject == 'ASI_MFM_AP_Code__c' ?
            (
            ApCodeQuery
            )
            :
            (
            retObject == 'ASI_MFM_BU__c' ?
            ('SELECT ASI_MFM_L1_Description__c,' + 
            fields +
            ' FROM ' + 
            retObject + 
            ' WHERE recordtypeid = \'' + rtCAPBUID + '\'' +
            ' AND ASI_MFM_Inactive__c = ' + false + '' +
            (companySet.equalsIgnoreCase('\'t\'')?'':' and ASI_MFM_L1_Description__c in( '+companySet+')')+
            ' order by Name LIMIT 200'
            )
            :
            ('SELECT ' + 
            fields + 
            ' FROM ' + 
            retObject + 
            ' order by Name LIMIT 200')));       
                        
            pickList = new List<selectOption>();
            System.debug('---- queryStr ---- : ' + queryStr);
            existingSObjList = Database.query(queryStr);
            pickList.add(new SelectOption('',''));
                    
            String nameField = 'Name';
            if (allowedLanguage != null && allowedLanguage.contains(languageLocale))
            {
             nameField = 'Name_'+languageLocale+'__c';
            } 
            
            // @DC - 4 Dec 2015 - fetch recordIds with read access.
            Set<Id> recordIds = new Set<Id>();
            for(sObject sobj: existingSObjList) {
                recordIds.add((Id)sobj.get('Id'));
            }

            // @DC - 4 Dec 2015 - fetch access for the retrieved records
            Map<Id, UserRecordAccess> id_AccessMap = new Map<Id, UserRecordAccess>([
                SELECT RecordID,
                       HasReadAccess
                  FROM UserRecordAccess
                 WHERE UserId = :UserInfo.getUserId()
                   AND RecordId IN :recordIds]);
            

            for(sObject sobj: existingSObjList ) {                                  
             
             Object nameValue= sobj.get(nameField);
             Object idValue = sobj.get('Id');
             Object needSubL='';
             Object L1='';
             if(retObject == 'ASI_MFM_AP_Code__c')
                needSubL=sobj.get('asi_mfm_sc_Need_Subleger__c');
                
             if(id_AccessMap.containsKey((Id)idValue)) {
                 if(id_AccessMap.get((Id)idValue).HasReadAccess) {
                     SelectOption selectionOption = new SelectOption(String.valueof(idValue),String.valueof(nameValue));
                     pickList.add(selectionOption);
                 }
             }
         
            }                      
            System.debug('Flag XXX dependentMap ' + dependentMap );
        }
    }    
    }