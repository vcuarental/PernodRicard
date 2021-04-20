/*
====================================================================
Usage: Use it to convert the lookup field to the pickList

Step1: First need to initialize the class objectPickListHelper and pass the object parameter you would like to retrieve
Example: objectPickListHelper helper1 = new objectPickListHelper('Account');

Step2: Get the retrived list by helper1.pickList; 
====================================================================
*/
public class ASI_TnE_KR_ObjectPickListHelper {

    public List<SelectOption> pickList{get;set;}
    public Map<String,List<SelectOption>> dependentMap {get;set;}
    public Map<String,ExpenseCategoryClassification> dependentExpenseCategoryClassificationMap {get;set;}
    public List<sObject> existingSObjList{get;set;}
    public String sObjInputTypeStr { get; set;}
    public String sObjInputFieldStr { get; set; }
    public String dependentFieldStr { get; set; }
    public String languageLocale { get; set; }
    public String allowedLanguage { get; set; }
    
    public ASI_TnE_KR_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr){
        this(sObjInputTypeStr,sObjInputFieldStr,null,null,null);
    }
    
    public ASI_TnE_KR_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr, String dependentFieldStr, 
    String languageLocale, String allowedLanguage){
        this.sObjInputTypeStr = sObjInputTypeStr;
        this.sObjInputFieldStr = sObjInputFieldStr;
        this.dependentFieldStr = dependentFieldStr;
        this.languageLocale = languageLocale;
        this.allowedLanguage = allowedLanguage;
        system.debug('checkac :' + this.dependentFieldStr);
        init(); 
    }

    private void init(){
    
        Schema.sObjectType sobjType = Schema.getGlobalDescribe().get(sObjInputTypeStr);
        Map<String, Schema.SObjectField> sObjFieldMap = sObjType.getDescribe().fields.getMap();
        Schema.DescribeFieldResult describeFieldResult = sObjFieldMap.get(sObjInputFieldStr).getDescribe();
        
        system.debug('checkdescribeFieldResult : '+describeFieldResult);
        
        if(!describeFieldResult.isNamePointing()){
        
            List<Schema.sObjectType> sObjTypeList = describeFieldResult.getReferenceTo();
            String retObject = sObjTypeList[0].getDescribe().getName();
             system.debug('checkretObject : '+retObject + ' sObjTypeList : '+sObjTypeList);
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
            
            String queryStr = retObject == 'ASI_JP_TnE_Expense_Category__c' ? ('SELECT ' + 
            fields +
            ' FROM ' + 
            retObject + 
            ' WHERE RecordType.DeveloperName Like \'ASI_TnE_KR%\' order by  ASI_JP_TnE_Expense_Category_Order__c')
            :
            ('SELECT ' + 
            fields +
            ' FROM ' + 
            retObject +
            ' WHERE RecordType.DeveloperName Like \'ASI_TnE_KR%\' order by Name');         
            
            pickList = new List<selectOption>();
            existingSObjList = Database.query(queryStr);
            pickList.add(new SelectOption('',''));     
            
            String nameField = 'Name';
            if (allowedLanguage != null && allowedLanguage.contains(languageLocale))
            {
             nameField = 'Name_'+languageLocale+'__c';
            } 
            
            System.debug('CLK234 ' + existingSObjList + ' queryStr ' + queryStr );
                              
            for(sObject sobj: existingSObjList ) {                                  
             
             Object nameValue= sobj.get(nameField);
             Object idValue = sobj.get('Id');
                
             //String nameString = nameValue == null ? '' : String.valueof(nameValue);
             
             SelectOption selectionOption;
                
             if(nameValue != null)
             	selectionOption = new SelectOption(String.valueof(idValue),String.valueof(nameValue));
                
             pickList.add(selectionOption);
                 
                
                system.debug('checkpicklis123 :' + pickList);
             if (dependentFieldStr != null && !''.equals(dependentFieldStr))
             {
                 String dependentValue= (String) sobj.get(dependentFieldStr);
                 
                 ExpenseClassification expenseClassification = new ExpenseClassification();
                 expenseClassification.id =  String.valueof(idValue); 
                 expenseClassification.name = String.valueof(nameValue);
                                     
                 if (dependentMap.containsKey(dependentValue))
                 {
                     dependentMap.get(dependentValue).add(selectionOption);   
                     system.debug('check101' + dependentMap.get(dependentValue));
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
        }//end if
    }//end method:init
    
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