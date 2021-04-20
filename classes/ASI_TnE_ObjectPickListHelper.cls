/*
====================================================================
Usage: Use it to convert the lookup field to the pickList

Step1: First need to initialize the class objectPickListHelper and pass the object parameter you would like to retrieve
Example: objectPickListHelper helper1 = new objectPickListHelper('Account');

Step2: Get the retrived list by helper1.pickList; 
====================================================================
*/
public class ASI_TnE_ObjectPickListHelper{

    public Map<String,String> chosedMap{get;set;} 
    public List<selectOption> pickList{get;set;}
    public List<sObject> existingSObjList{get;set;}
    public String sObjInputTypeStr { get; set;}
    public String sObjInputFieldStr { get; set; }
    
    public ASI_TnE_ObjectPickListHelper(String sObjInputTypeStr, String sObjInputFieldStr){
        this.sObjInputTypeStr= sObjInputTypeStr;
        this.sObjInputFieldStr= sObjInputFieldStr;
        System.debug('flk1' + sObjInputTypeStr);
        System.debug('flk2' + sObjInputFieldStr);
        init(); 
    }
    
    private void init(){    
        System.debug('flk3' + sObjInputTypeStr);
        System.debug('flk4' + sObjInputFieldStr);
        Schema.sObjectType sobjType = Schema.getGlobalDescribe().get(sObjInputTypeStr);
        Map<String, Schema.SObjectField> sObjFieldMap = sObjType.getDescribe().fields.getMap();
        Schema.DescribeFieldResult F = sObjFieldMap.get(sObjInputFieldStr).getDescribe();    
    
        if(!F.isNamePointing()){
            List<Schema.sobjectType> sobjTypeList = F.getReferenceTo();
            String retObject = sobjTypeList[0].getDescribe().getName();
            
            String queryStr = 'SELECT id, Name FROM ' + retObject + ' order by Name';   
            System.debug('flk6' + retObject);
            System.debug('flk7' + queryStr);    
            pickList = new List<selectOption>();
            existingSObjList = Database.query(queryStr);
            pickList.add(new SelectOption('',''));
                    
            for(sObject sobj: existingSObjList ){
                Object nameValue= sobj.get('Name');
                Object idValue = sobj.get('Id');
                System.debug('abc2' + nameValue );
                System.debug('abc' + sobj.getSObjectType());
                //System.debug('abc' + sobj.getSObjectField('Name'));
                pickList.add(new SelectOption(String.valueof(idValue),String.valueof(nameValue)));
            }
        }
    }    

}