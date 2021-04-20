public class EUR_CRM_OnTradePromoMgmtPageController{
    
    public List<SelectOption> outletTypeOptions {get; set;} 
    public List<SelectOption> imageTypeOptions {get; set;} 
    public List<SelectOption> variationTypeOptions {get; set;}
    public Boolean isDraft {get;set;}
    
    
    public String  outletTypeValue {get; set;} 
    public String  imageTypeValue {get; set;} 
    public String  imageTypeValue2 {get; set;} 
    public String  variationTypeValue {get; set;}
    
    private EUR_CRM_ObjPromo__c objective;
    private Map<String,List<Id>> variationMap;
    
    public List<EUR_CRM_ObjPromo_Target__c> targets { set;}
    
    public EUR_CRM_OnTradePromoMgmtPageController(ApexPages.StandardController stdController) {           
 
        objective = (EUR_CRM_ObjPromo__c) stdController.getRecord();
        system.debug('@@ objective: ' + objective);
        variationMap = new Map<String,List<Id>>();
        outletTypeOptions = getOutletTypeOptions();
        imageTypeOptions = getImageTypeOptions();
        if(objective.EUR_CRM_PROS_Group_Outlet__c!= null)
            outletTypeValue = objective.EUR_CRM_PROS_Group_Outlet__c;
        if(objective.EUR_CRM_PROS_Image_Level__c != null)
            imageTypeValue = objective.EUR_CRM_PROS_Image_Level__c;
        retrieveVariationTypeOptions();
        if(objective.EUR_CRM_ObjPromo_OnTrade_Variation__c != null)
            variationTypeValue = objective.EUR_CRM_ObjPromo_OnTrade_Variation__c;
        isDraft = objective.EUR_CRM_Status__c == 'Draft';
    } 
    private List<SelectOption> getOutletTypeOptions(){    
        system.debug('++ getOutletTypeOptions');
        List<SelectOption> typeOptions= new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =
        EUR_CRM_ObjPromo__c.EUR_CRM_PROS_Group_Outlet__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        outletTypeValue = ple.get(0).getValue();
        for( Schema.PicklistEntry f : ple){
            typeOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        return typeOptions;
    }
    private List<SelectOption> getImageTypeOptions (){
        system.debug('++ getImageTypeOptions ');
        List<SelectOption> typeOptions= new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =
        EUR_CRM_ObjPromo__c.EUR_CRM_PROS_Image_Level__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        imageTypeValue = ple.get(0).getValue();
        
        for( Schema.PicklistEntry f : ple){
            typeOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return typeOptions ;
    }
    public PageReference retrieveVariationTypeOptions(){
        List<SelectOption> typeOptions = new List<SelectOption>();
        Boolean flag = true;
       // variationTypeValue = '';  
        List<EUR_CRM_ObjPromo_PROS_To_Var_Mapping__c> varList =[select EUR_CRM_ObjPromo_OnTrade_Variation__c from EUR_CRM_ObjPromo_PROS_To_Var_Mapping__c where EUR_CRM_ObjPromo_PROS_Segment__c in (select id from EUR_CRM_ObjPromo_PROS_Segment__c  where EUR_CRM_Outlet_Image__c=:imageTypeValue and 
        EUR_CRM_Outlet_Type__c =:outletTypeValue)];
        
        Set<id> varIds = new Set<Id>();
        
        for(EUR_CRM_ObjPromo_PROS_To_Var_Mapping__c vm : varList){
            varIds.add(vm.EUR_CRM_ObjPromo_OnTrade_Variation__c);
        }
        for(EUR_CRM_ObjPromo_OnTrade_Variation__c v : [select name, id from EUR_CRM_ObjPromo_OnTrade_Variation__c where id in:VarIds]){
            if(flag){
                flag = false;
                variationTypeValue = v.id;
            }
            typeOptions.add(new SelectOption((String) v.id, v.name));
            system.debug(' ++ ' + v.name + ' ' + v.id);
        }
        variationTypeOptions  = typeOptions;
        return null;
    }
    
    public List<EUR_CRM_ObjPromo_OnTrade_Var_Detail__c > getTargets(){
        system.debug('targets init: ' + variationTypeValue );
        List<EUR_CRM_ObjPromo_Target__c> targets = new List<EUR_CRM_ObjPromo_Target__c>();
        List<EUR_CRM_ObjPromo_OnTrade_Var_Detail__c > vars = new List<EUR_CRM_ObjPromo_OnTrade_Var_Detail__c>();
        if(variationTypeValue != null && variationTypeValue != '')
        for(EUR_CRM_ObjPromo_OnTrade_Var_Detail__c detail : [select id,EUR_CRM_Quality__r.name,EUR_CRM_Quality__c,EUR_CRM_Description__c from EUR_CRM_ObjPromo_OnTrade_Var_Detail__c where EUR_CRM_ObjPromo_OnTrade_Variation__c =: ((ID)variationTypeValue)]){
            EUR_CRM_ObjPromo_Target__c target = new EUR_CRM_ObjPromo_Target__c(
                EUR_CRM_BQ__c = detail.EUR_CRM_Quality__c,
                EUR_CRM_BQ__r = detail.EUR_CRM_Quality__r,
                EUR_CRM_ObjPromo__c = objective.id
            );
            targets.add(target);
            vars.add(detail);
            system.debug('##' + target.EUR_CRM_BQ__r);
        }
        return vars;
    }
    public PageReference save(){
        system.debug('@@ save invoked');
        objective.EUR_CRM_ObjPromo_OnTrade_Variation__c = ((ID)variationTypeValue);
        objective.EUR_CRM_PROS_Group_Outlet__c = outletTypeValue ;
        objective.EUR_CRM_PROS_Image_Level__c = imageTypeValue ; 
        system.debug('@@ objective: ' + objective);
        try{
        update objective; 
        }catch(DMLException e){
            system.debug('@@ error' + e);
        }return cancel();
    } 
    public PageReference cancel(){            
        PageReference pageRef = new PageReference('/' + objective.Id); 
        pageRef.setRedirect(true); 
        return pageRef;    
    } 
}