public class EUR_CRM_AssignGroupOutletTypeController {
   
    public String parentValue {get;set;}
    public String childValue {get;set;}
    public List<SelectOption> parentOptions {get; set;} 
    private Map<String,List<EUR_CRM_Outlet_Type__c>> childOptionMap;  
    private EUR_CRM_PROS_Segmentation__c prosSegmentation;
    public Boolean saveDisabled {get;set;}
    
    public EUR_CRM_AssignGroupOutletTypeController(ApexPages.StandardController controller){
        saveDisabled = false;
        parentOptions = new List<SelectOption>();
        childOptionMap = new Map<String,List<EUR_CRM_Outlet_Type__c>>();
        if(controller.getId() != null && controller.getId() != ''){
            prosSegmentation = [select id,name,eur_crm_country_code__c from EUR_CRM_PROS_Segmentation__c  where id =: controller.getId()];
            List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypes = [select id, EUR_CRM_Group_Outlet_Name__c  from EUR_CRM_Group_Outlet_Type__c  where EUR_CRM_Country_Code__c =:prosSegmentation.eur_crm_country_code__c];
        
            if(groupOutletTypes !=null && groupOutletTypes.size() >0){
                    Set<Id> groupOutletTypeIds = new Set<Id>();
                    parentValue = groupOutletTypes.get(0).id;
                    for (EUR_CRM_Group_Outlet_Type__c record : groupOutletTypes ){
                        parentOptions.add(new SelectOption(record.id,record.EUR_CRM_Group_Outlet_Name__c));
                        groupOutletTypeIds.add(record.id);
                    }
                    for(EUR_CRM_Outlet_Type__c record : [select id, eur_crm_name__c,EUR_CRM_Group_Outlet_Type__c  from EUR_CRM_Outlet_Type__c where EUR_CRM_Group_Outlet_Type__c in:groupOutletTypeIds ]){
                        if(childOptionMap.get(record.EUR_CRM_Group_Outlet_Type__c) == null){
                            childOptionMap.put(record.EUR_CRM_Group_Outlet_Type__c, new List<EUR_CRM_Outlet_Type__c>()); 
                        }
                        childOptionMap.get(record.EUR_CRM_Group_Outlet_Type__c).add(record);
                    }
            }else{
                saveDisabled = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No Group Outlet Types Exists'));
            }
        }
        else{
            saveDisabled = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No Pros Segmentation ID Exists'));
        }
       
    }
    public PageReference handleSave(){ 
        prosSegmentation.EUR_CRM_Group_Outlet_Type__c = parentValue;
        prosSegmentation.EUR_CRM_Outlet_Type__c = childValue;
        try{
            update prosSegmentation;
        }catch(DMLException e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to save'));
             return null;            
        }
        return new pageReference('/'+prosSegmentation.Id);
    }
    
    public PageReference handleExit(){
        
        return prosSegmentation != null? new pageReference('/'+prosSegmentation.Id) : new pageReference('/');
    }
    
    public List<SelectOption> getChildOptions() {
    
       List<SelectOption> options = new List<SelectOption>();
       // return childOptionMap.get(parentValue);
       for(EUR_CRM_Outlet_Type__c record: childOptionMap.get(parentValue) )
           options.add(new SelectOption(record.id,record.EUR_CRM_Name__c));
       if(childOptionMap.get(parentValue) != null && childOptionMap.get(parentValue).get(0) != null)
           childValue = childOptionMap.get(parentValue).get(0).id;       
       return options;
    }
 
}