/*
====================================================================
Usage: Use it to convert the lookup field to the pickList

Step1: First need to initialize the class objectPickListHelper and pass the object parameter you would like to retrieve
Example: objectPickListHelper helper1 = new objectPickListHelper('Account');

Step2: Get the retrived list by helper1.pickList; 
====================================================================
*/
public class ASI_CRM_CN_ObjectPickListHelper {

    public List<SelectOption> pickList{get;set;}
    public Map<String,List<SelectOption>> dependentMap {get;set;}
    public Map<String,ExpenseCategoryClassification> dependentExpenseCategoryClassificationMap {get;set;}
    public List<sObject> existingSObjList{get;set;}
    public String sObjInputTypeStr { get; set;}
    public String sObjInputFieldStr { get; set; }
    public String dependentFieldStr { get; set; }
    public String languageLocale { get; set; }
    public String allowedLanguage { get; set; }
    
    //Custom Add Stella Sing (Introv)
    public string recLimit {get;set;}
    public string whereClause {get;set;}
    public string sObjInputRelatedFieldStr { get; set; }
    
    /* Origin
    public ASI_CRM_CN_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr){
        this(sObjInputTypeStr,sObjInputFieldStr,null,null,null);
    } // check
    public ASI_CRM_CN_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr){
        this(sObjInputTypeStr,sObjInputFieldStr,null,null,null,'999',null,null);
    }*/
    /*check
    public ASI_CRM_CN_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr, String dependentFieldStr, 
    String languageLocale, String allowedLanguage, String recLimit, String whereClause, String sObjInputRelatedFieldStr){
    */
    public ASI_CRM_CN_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr, String dependentFieldStr, 
    String languageLocale, String allowedLanguage){
        this.sObjInputTypeStr = sObjInputTypeStr;
        this.sObjInputFieldStr = sObjInputFieldStr;
        this.dependentFieldStr = dependentFieldStr;
        this.languageLocale = languageLocale;
        this.allowedLanguage = allowedLanguage; 
        this.recLimit = recLimit;
        this.whereClause = whereClause;
        this.sObjInputRelatedFieldStr= sObjInputRelatedFieldStr;
        init(); 
    }
     /* add filter and record limit to picklist values
        Stella Sing(Introv) 2014-03-19
    
    public ASI_CRM_CN_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr, String recLimit, String whereClause){
        this.sObjInputTypeStr= sObjInputTypeStr;
        this.sObjInputFieldStr= sObjInputFieldStr;
        this.recLimit = recLimit;
        this.whereClause = whereClause;
        System.debug('flk1' + sObjInputTypeStr);
        System.debug('flk2' + sObjInputFieldStr);
        init(); 
    }
    public ASI_CRM_CN_ObjectPickListHelper(String sObjInputTypeStr, String whereClause, String recLimit, String sObjInputRelatedFieldStr, boolean isSubItem){
        this.sObjInputTypeStr= sObjInputTypeStr;
        this.sObjInputRelatedFieldStr= sObjInputRelatedFieldStr;
        this.recLimit = recLimit;
        this.whereClause = whereClause;
        System.debug('flk1' + sObjInputTypeStr);
        System.debug('flk2' + sObjInputFieldStr);
        System.debug('flk2.1' + sObjInputRelatedFieldStr);
        initForSubItem(); 
    }
    
     private void initForSubItem(){    
        System.debug('flk3' + sObjInputTypeStr);
        System.debug('flk4' + sObjInputFieldStr);
        String queryStr = '';
        
        queryStr = 'SELECT '+ sObjInputRelatedFieldStr+'.id, '+ sObjInputRelatedFieldStr+'.Name FROM '+ sObjInputTypeStr;
        if(whereClause != '' && whereClause != null){
            queryStr += ' where ' + whereClause +' ';
        }
        queryStr += ' order by Name';
        if(recLimit != '' && recLimit != null){
            queryStr += ' limit ' + recLimit +' ';
        }
        
        System.debug('flk7 ' + queryStr);    
        pickList = new List<selectOption>();
        existingSObjList = Database.query(queryStr);
        pickList.add(new SelectOption('',''));
                
        for(sObject sobj: existingSObjList ){
            sObject relatedObj = sobj.getSObject(sObjInputRelatedFieldStr);
            if (relatedObj != null)
            {
                Object nameValue= relatedObj.get('Name');
                Object idValue = relatedObj.get('Id');
                System.debug('abc2' + nameValue );
                System.debug('abc' + sobj.getSObjectType());
                pickList.add(new SelectOption(String.valueof(idValue),String.valueof(nameValue)));
            }
        }
    } */ 
    //Customize End
    
    private void init(){    
    
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
            
            if (dependentFieldStr!= null && !''.equals(dependentFieldStr))
            {
              fields += ',' + dependentFieldStr;
              dependentMap = new Map<String,List<SelectOption>>();
              dependentExpenseCategoryClassificationMap = new Map<String,ExpenseCategoryClassification>();
            }
            
            /*Custom Add Stella Sing 2014-03-19 
            recLimit, String whereClause, String sObjInputRelatedFieldStr
            */
            //if (recLimit!= null)
            //{
              //retObject += ' LIMIT ' + recLimit;
              recLimit = ' LIMIT 999';
            //}
            //Custom edit end
            
            String queryStr = 'SELECT ' + 
            fields + 
            ' FROM ' + 
            retObject + recLimit; //  + 
            //' order by Name';     
            
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
             
             if (dependentFieldStr != null && !''.equals(dependentFieldStr))
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
             }            
            }
           
            if (dependentFieldStr!= null && !''.equals(dependentFieldStr))
            { 
             dependentMap.put('',pickList);  
            } 
            
            System.debug('Flag XXX dependentMap ' + dependentMap );
        }
    }    
    
    public class ExpenseCategoryClassification
    {
        public String categoryName {get;set;}
        public List<ExpenseClassification> expenseClassifications {get;set;}    
    }
    
    public class ExpenseClassification
    {
        public String id {get;set;}
        public String name {get;set;}            
    }

}