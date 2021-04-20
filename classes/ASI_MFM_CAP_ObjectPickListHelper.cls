/*
====================================================================
Usage: Use it to convert the lookup field to the pickList

Step1: First need to initialize the class objectPickListHelper and pass the object parameter you would like to retrieve
Example: objectPickListHelper helper1 = new objectPickListHelper('Account');

Step2: Get the retrived list by helper1.pickList; 
====================================================================
*/
public with sharing class ASI_MFM_CAP_ObjectPickListHelper {

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
    
    public ASI_MFM_CAP_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr){
        this(sObjInputTypeStr,sObjInputFieldStr,null,null,null);
    }
    
    public ASI_MFM_CAP_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr, String dependentFieldStr, 
    String languageLocale, String allowedLanguage){
        this(sObjInputTypeStr,sObjInputFieldStr,null,null,null,null);
    }
    
    public ASI_MFM_CAP_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr, String dependentFieldStr, 
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
    public ASI_MFM_CAP_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr, String dependentFieldStr, 
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
            
         /*   if (dependentFieldStr!= null && !''.equals(dependentFieldStr))
            {
              fields += ',' + dependentFieldStr;
              dependentMap = new Map<String,List<SelectOption>>();
              dependentExpenseCategoryClassificationMap = new Map<String,ExpenseCategoryClassification>();
            }*/
            
            List<ASI_MFM_PO__c> headerPOList;
            List<ASI_MFM_Payment__c> headerPaymentList;
            
            String rtCAPID = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CAP_A_C_Code');
            String rtCAPAPID = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_CAP_AP_Code');
            String rtCAPBUID = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU');
            
            if(!String.isBlank(recordTypeIncluded)) {
                // @DC - 26-Feb-2016 - Seperated record type checking condition for bug fix in CAP project.
                if(recordTypeIncluded.containsIgnoreCase('CAP_TW')) {
                    rtCAPID = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CAP_A_C_Code');
                    rtCAPAPID = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_CAP_OTH_AP_Code');
                    rtCAPBUID = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_OTH_BU');
                }
                if(recordTypeIncluded.containsIgnoreCase('PO')) {
                    Id poId = ApexPages.currentPage().getParameters().get('Id');
                    headerPOList = [SELECT ASI_MFM_PO_Type__c
                                      FROM ASI_MFM_PO__c
                                     WHERE Id = :poId];
                } else if(recordTypeIncluded.containsIgnoreCase('Payment')) {
                    Id paymentId = ApexPages.currentPage().getParameters().get('Id');
                    headerPaymentList = [SELECT ASI_MFM_Payment_Type__c
                                           FROM ASI_MFM_Payment__c
                                          WHERE Id = :paymentId];
                }
            } 
            Boolean isOpex = false;
            /*Check if the header PO or Payment are of OPEX type, if yes, set isOpex to true.*/
            if(headerPOList != NULL && !headerPOList.isEmpty()) {
                if(headerPOList[0].ASI_MFM_PO_Type__c == 'OPEX') {
                    isOpex = true;
                }
            } else if(headerPaymentList != NULL && !headerPaymentList.isEmpty()) {
                if(headerPaymentList[0].ASI_MFM_Payment_Type__c == 'OPEX') {
                    isOpex = true;
                }
            }
            System.debug('------ headerPaymentList ------ : ' + headerPaymentList);
            System.debug('------ isOpex ------ : ' + isOpex);
            String ApCodeQuery = 
            'SELECT ' + 
            fields + 
            ' FROM ' + 
            retObject + 
            ' WHERE recordtypeid = \'' + rtCAPAPID + '\'' +
            ' AND ASI_MFM_Inactive__c = false' +
            ' AND ASI_MFM_OPEX__c = ' + isOpex + '' +
            ' order by Name LIMIT 200';
            /*
            // @DC - 26-Feb-2016 - Changed resetting of isOpex to avoid the bug when OPEX type of header is there.
            // reset isOpex to false to use for Plan record.
            isOpex = false;
            */
            // Filter out the AP Code picklist depending on Plan type. Capex/Opex
            Try {
                if(headerPlanID != '' && headerPlanID != null)
                {
                    // reset isOpex to false to use for Plan record.
                    isOpex = false;
                    List<ASI_MFM_Plan__c> planList = [
                                                        SELECT ID, Name, ASI_MFM_Plan_Type__c
                                                        FROM ASI_MFM_Plan__c
                                                        WHERE ID = : headerPlanID
                                                     ];
                    for(ASI_MFM_Plan__c plan : planList)
                    {
                        if(plan.ASI_MFM_Plan_Type__c  == 'OPEX')
                            isOpex = true;
                    }
                    ApCodeQuery = 'SELECT ' + 
                                    fields + 
                                    ' FROM ' + 
                                    retObject + 
                                    ' WHERE recordtypeid = \'' + rtCAPAPID + '\'' +
                                    ' AND ASI_MFM_OPEX__c = ' + isOpex + '' +
                                    ' AND ASI_MFM_Inactive__c = ' + false + '' +
                                    ' AND ASI_MFM_Inactive__c = false' +
                                    ' order by Name LIMIT 200';
                }
            }
            catch(exception e) {
            }

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
            ('SELECT ' + 
            fields + 
            ' FROM ' + 
            retObject + 
            ' WHERE recordtypeid = \'' + rtCAPBUID + '\'' +
            ' AND ASI_MFM_OPEX__c = ' + isOpex +
            ' AND ASI_MFM_Inactive__c = ' + false + '' +
            ' order by Name LIMIT 200'
            )
            :
            ('SELECT ' + 
            fields + 
            ' FROM ' + 
            retObject + 
            ' order by Name LIMIT 200')));       
            
            /*if(!String.isBlank(recordTypeIncluded) && recordTypeIncluded.containsIgnoreCase('CAP_TW')) {
                if(retObject == 'ASI_MFM_AP_Code__c' || retObject == 'ASI_MFM_BU__c') {
                    String partialQuery = queryStr.substringBefore(' order by Name');
                    partialQuery = partialQuery + ' AND OwnerId = \'' + UserInfo.getUserId() + '\'' + ' order by Name';
                    queryStr = partialQuery;
                }
            }*/
            
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
             System.debug('------ (Id)idValue ------ : ' + (Id)idValue);
             /*SelectOption selectionOption = new SelectOption(String.valueof(idValue),String.valueof(nameValue));
             pickList.add(selectionOption);*/
             
             // @DC - 4 Dec 2015 - Added code to filter records based on read access
             if(id_AccessMap.containsKey((Id)idValue)) {
                 System.debug('------ (Id)idValue IN IF ------ : ' + (Id)idValue);
                 if(id_AccessMap.get((Id)idValue).HasReadAccess) {
                     SelectOption selectionOption = new SelectOption(String.valueof(idValue),String.valueof(nameValue));
                     pickList.add(selectionOption);
                 }
             }
             
        /*     if (dependentFieldStr != null && !''.equals(dependentFieldStr))
             {
                 String dependentValue= (String) sobj.get(dependentFieldStr);
                 
                 ExpenseClassification expenseClassification = new ExpenseClassification();
                 expenseClassification.id =  String.valueof(idValue); 
                 expenseClassification.name = String.valueof(nameValue);
                                     
                 if (dependentMap.containsKey(dependentValue))
                 {
                     dependentMap.get(dependentValue).add(selectionOption);                                      
                     dependentExpenseCategoryClassificationMap.get(dependentValue).expenseClassifications.add(expenseClassification); 
                     
                 } else {
                    
                    List<SelectOption> innerPickList = new List<SelectOption>();
                    innerPickList.add(selectionOption);
                    dependentMap.put(dependentValue,innerPickList);
                    
                    List<ExpenseClassification> expenseClassifications = new List<ExpenseClassification>();
                    expenseClassifications.add(expenseClassification);
                    
                    ExpenseCategoryClassification expenseCategoryClassification = new ExpenseCategoryClassification();
                    expenseCategoryClassification.categoryName = dependentValue;
                    expenseCategoryClassification.expenseClassifications =  expenseClassifications;
                    
                    dependentExpenseCategoryClassificationMap.put(dependentValue,expenseCategoryClassification);
                    
                 }                
             }    */        
            }
           
            /*if (dependentFieldStr!= null && !''.equals(dependentFieldStr))
            { 
             dependentMap.put('',pickList);  
            } */
            
            System.debug('Flag XXX dependentMap ' + dependentMap );
        }
    }    
    
 /*   public class ExpenseCategoryClassification
    {
        public String categoryName {get;set;}
        public List<ExpenseClassification> expenseClassifications {get;set;}    
    }
    
    public class ExpenseClassification
    {
        public String id {get;set;}
        public String name {get;set;}            
    }*/

}