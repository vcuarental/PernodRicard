/*
====================================================================
Usage: Use it to convert the lookup field to the pickList

Step1: First need to initialize the class objectPickListHelper and pass the object parameter you would like to retrieve
Example: objectPickListHelper helper1 = new objectPickListHelper('Account');

Step2: Get the retrived list by helper1.pickList; 
====================================================================
*/
public class ASI_eForm_ObjectPickListHelper {

    public List<SelectOption> pickList{get;set;}
    public Map<String,List<SelectOption>> dependentMap {get;set;}
    public Map<String,ParentDependency> parentDependencyMap {get;set;}
    public List<sObject> existingSObjList{get;set;}
    public String sObjInputTypeStr { get; set;}
    public String sObjInputFieldStr { get; set; }
    public String dependentFieldStr { get; set; }
    public String languageLocale { get; set; }
    public String allowedLanguage { get; set; }
    
    public ASI_eForm_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr){
        this(sObjInputTypeStr,sObjInputFieldStr,null,null,null);
    }
    
    public ASI_eForm_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr, String dependentFieldStr, 
    String languageLocale, String allowedLanguage){
        this.sObjInputTypeStr = sObjInputTypeStr;
        this.sObjInputFieldStr = sObjInputFieldStr;
        this.dependentFieldStr = dependentFieldStr;
        this.languageLocale = languageLocale;
        this.allowedLanguage = allowedLanguage; 
        init(); 
        
        System.debug('XXXXX ' + this.sObjInputTypeStr + ' ' +this.sObjInputFieldStr+ ' ' +this.dependentFieldStr + ' ' +
        this.languageLocale + ' ' + this.allowedLanguage);
    }
    
    private void init(){    
    
        Schema.sObjectType sobjType = Schema.getGlobalDescribe().get(sObjInputTypeStr);
        Map<String, Schema.SObjectField> sObjFieldMap = sObjType.getDescribe().fields.getMap();
        Schema.DescribeFieldResult describeFieldResult = sObjFieldMap.get(sObjInputFieldStr).getDescribe();    
    
         System.debug('XXXXX describeFieldResult  ' + describeFieldResult );

    
    
        if(!describeFieldResult.isNamePointing()){
        
            List<Schema.sObjectType> sObjTypeList = describeFieldResult.getReferenceTo();
            
           System.debug('XXXXX sObjTypeList ' + sObjTypeList );
            
            
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
              parentDependencyMap = new Map<String,ParentDependency>();
            }
            
            String customFilter = '';
            if (retObject == 'ASI_eForm_Permission_Type__c')
                customFilter = ' WHERE Name != \'[Data Migration]\' ';
            
            String queryStr = 'SELECT ' + 
            fields + 
            ' FROM ' + 
            retObject + customFilter + 
            ' order by Name';     
            
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
                 
                 ChildDependency childDependency = new ChildDependency();
                 childDependency.id =  String.valueof(idValue); 
                 childDependency.name = String.valueof(nameValue);
                                     
                 if (dependentMap.containsKey(dependentValue))
                 {
                     dependentMap.get(dependentValue).add(selectionOption);                                      
                     parentDependencyMap.get(dependentValue).childDependencies.add(childDependency); 
                     
                 } else {
                    
                    List<SelectOption> innerPickList = new List<SelectOption>();
                    innerPickList.add(selectionOption);
                    dependentMap.put(dependentValue,innerPickList);
                    
                    List<ChildDependency> childDependencies = new List<ChildDependency>();
                    childDependencies.add(childDependency);
                    
                    ParentDependency parentDependency = new ParentDependency();
                    parentDependency.parentName = dependentValue;
                    parentDependency.childDependencies =  childDependencies;
                    
                    parentDependencyMap.put(dependentValue,parentDependency);
                    
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
    
    public class ParentDependency
    {
        public String parentName {get;set;}
        public List<ChildDependency> childDependencies {get;set;}    
    }
    
    public class ChildDependency
    {
        public String id {get;set;}
        public String name {get;set;}            
    }

}