/*
====================================================================
Usage: Use it to convert the lookup field to the pickList

Step1: First need to initialize the class objectPickListHelper and pass the object parameter you would like to retrieve
Example: objectPickListHelper helper1 = new objectPickListHelper('Account');

Step2: Get the retrived list by helper1.pickList; 
====================================================================
*/

public class ASI_CRM_JP_ObjectPickListHelper{
    public List<SelectOption> pickList{get;set;}
    public Map<String,List<SelectOption>> dependentMap {get;set;}
    public List<sObject> existingSObjList{get;set;}
    public String sObjInputTypeStr { get; set;}
    public String sObjInputFieldStr { get; set; }
    public String dependentFieldStr { get; set; }
    public String languageLocale { get; set; }
    public String allowedLanguage { get; set; }
    public String sObjId {get;set;}
    
    public ASI_CRM_JP_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr){
        this(sObjInputTypeStr,sObjInputFieldStr,null,null,null,null);
    }
    
    public ASI_CRM_JP_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr, String sObjId){
        this(sObjInputTypeStr,sObjInputFieldStr,null,null,null,sObjId);
    }
    
    public ASI_CRM_JP_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr, String dependentFieldStr, 
    String languageLocale, String allowedLanguage,String sObjId){
        this.sObjInputTypeStr = sObjInputTypeStr;
        this.sObjInputFieldStr = sObjInputFieldStr;
        this.dependentFieldStr = dependentFieldStr;
        this.languageLocale = languageLocale;
        this.allowedLanguage = allowedLanguage;
        this.sObjId = sObjId; 
        init(); 
    }
        
    private void init(){    
        System.debug('flag XXXX dependentFieldStr ' + dependentFieldStr);
        System.debug('Flag XXX languageLocale ' + languageLocale);      
        Schema.sObjectType sobjType = Schema.getGlobalDescribe().get(sObjInputTypeStr);
        Map<String, Schema.SObjectField> sObjFieldMap = sObjType.getDescribe().fields.getMap();
        Schema.DescribeFieldResult describeFieldResult = sObjFieldMap.get(sObjInputFieldStr).getDescribe();    
    
        if(!describeFieldResult.isNamePointing()){
        
            List<Schema.sObjectType> sObjTypeList = describeFieldResult.getReferenceTo();
            String retObject = sObjTypeList[0].getDescribe().getName();
            
            String fields = ' id, ';
            
            
            
            if (languageLocale == 'en_US')
            {
             fields += ' Name_en_US__c '; 
            } else
            {
             fields += ' Name ';             
            }
            
            String queryStr = '';
            
            if(retObject == 'ASI_MFM_SKU_Code__c') {
                Set<Id> allIdSet = new Set<Id>();
                String qStr = 'Select ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Item_Group__r.ASI_CRM_Alternative_SKU__c, ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Item_Group__r.ASI_CRM_Representative_SKU__c from ASI_CRM_Payment_Invoice_Line_Item__c Where ' + sObjId;
                List<ASI_CRM_Payment_Invoice_Line_Item__c> itemList = Database.query(qStr);
                
                for(ASI_CRM_Payment_Invoice_Line_Item__c item:itemList){
                    if(item.ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Item_Group__r.ASI_CRM_Alternative_SKU__c != null){
                        allIdSet.add(item.ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Item_Group__r.ASI_CRM_Alternative_SKU__c);
                    }
                    if(item.ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Item_Group__r.ASI_CRM_Representative_SKU__c != null){
                        allIdSet.add(item.ASI_CRM_Purchase_Contract_Line_Item__r.ASI_CRM_Item_Group__r.ASI_CRM_Representative_SKU__c);
                    }
                }
                queryStr = 'SELECT ' + 
                fields + 
                ' FROM ' + 
                retObject + 
                ' WHERE recordtype.developername = \'ASI_CRM_JP_SKU\' order by Name';   
            }
            else  {
                queryStr = 'SELECT ' + 
                fields + 
                ' FROM ' + 
                retObject + 
                ' order by Name';     
            }
            
            pickList = new List<selectOption>();
            existingSObjList = Database.query(queryStr);
            pickList.add(new SelectOption('',''));
                    
            String nameField = 'Name';
            if (allowedLanguage != null && allowedLanguage.contains(languageLocale))
            {
             nameField = 'Name_'+languageLocale+'__c';
            } 

            for(sObject sobj: existingSObjList ) {          
                        
             
             Object nameValue= sobj.get(nameField);
             Object idValue = sobj.get('Id');
                             
             SelectOption selectionOption = new SelectOption(String.valueof(idValue),String.valueof(nameValue));
             
             pickList.add(selectionOption);
                         
            }
        }
    }    
    

}