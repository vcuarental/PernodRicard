/**
Name: EUR_CRM_BQSTargetManagementController 
Description: Controller class for EUR_CRM_BQSTargetManagementPage
Main Functionalities:
    1. Initialize and display Products (BQS - EUR_CRM_Size__c object)
    2. Searchable BQS
    3. Editable Product Table
        Add & Remove Products
        Add Comments
    4. Main User- TMKT/National 
   
Author/Company:    IP Converge Data Services,Inc.
History:      17.JUN.2014        IPC     Created
              24.FEB.2017        JAY     Updated to accept both BQS / SKU Selection
*/

public class EUR_CRM_BQSTargetManagementController extends EUR_CRM_AbstractSelectionItem{
 
    private EUR_CRM_ObjPromo__c objPromo; 
    

    public List<EUR_CRM_Size__c> bqsList{get;set;}   

    public List<EUR_CRM_SKU__c> skuList{get;set;}

    public String searchString {get;set;} 
    public string productSelectMethod {get;set;}

    public List<EUR_CRM_ObjPromo_Target__c> targets {get;set;}
    private List<EUR_CRM_ObjPromo_Target__c> toDeleteTargets;     
    public EUR_CRM_AbstractSelectionItem sCon {get;set;} 

    public Boolean isDraft {get;set;}
    public Boolean isPublish {get;set;}
    public Boolean isPrepare {get;set;}

    public Boolean isWSCTax {get;set;}

    public final String OBJ_VOL_TARGET = 'EUR_DE_Objective_Volume_Target'; //Level 1 - Top
    Map<String,Id>  rtMap;
    public EUR_CRM_BQSTargetManagementController(ApexPages.StandardController stdController) {
        this.productSelectMethod = 'BQS';
        this.isWSCTax = true;
        this.objPromo= (EUR_CRM_ObjPromo__c)stdController.getRecord();
        this.objPromo.Id = stdController.getRecord().id;   
        searchString = '';  
        this.sCon = this;
        isDraft = false;
        isDraft = objPromo != null && objPromo.EUR_CRM_Status__c == 'Draft';
        isPublish = objPromo != null && objPromo.EUR_CRM_Status__c == 'Published';
        isPrepare = objPromo != null && objPromo.EUR_CRM_Status__c == 'In Preparation';

        init(); 
        rtMap = new Map<String,Id>();
        for(RecordType rt : [select id, developername from RecordType where developername in (:OBJ_VOL_TARGET  ) and sobjecttype = 'EUR_CRM_ObjPromo_Target__c']){
            rtMap.put(rt.developername,rt.id);
        }
    } 
    private void init(){        

        targets = new List<EUR_CRM_ObjPromo_Target__c>();
        toDeleteTargets = new List<EUR_CRM_ObjPromo_Target__c>();
        targets = [select id,
                    EUR_CRM_BQS__c,EUR_CRM_SKU__c,EUR_CRM_SKU__r.name,EUR_CRM_SKU__r.EUR_CRM_Article_no__c,EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c,
                    EUR_CRM_BQS__r.name,EUR_CRM_Comments__c from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c =: objPromo.Id];

        EUR_CRM_ObjPromo__c objRt = [SELECT recordtype.DeveloperName FROM EUR_CRM_ObjPromo__c  where id =: objPromo.Id];
        this.isWSCTax = objRt.recordtype.developername == 'EUR_DE_WS_Promotion_with_Lead_Time'|| objRt.recordtype.developername == 'EUR_DE_WS_Promotion_without_Lead_Time';
        itemMap = new Map<Id,SObject>();

        for(EUR_CRM_ObjPromo_Target__c target : targets){ 
            if(target.EUR_CRM_BQS__c != null)
                existingIds.add(target.EUR_CRM_BQS__c);  
            if(target.EUR_CRM_SKU__c != null)
                existingIds.add(target.EUR_CRM_SKU__c);
        }

        for(EUR_CRM_SIZE__c size : [select id, name from EUR_CRM_SIZE__c where id in: existingIds]){
            itemMap.put(size.id,(sObject)size);
        }
        for(EUR_CRM_SKU__c sku : [select id, name, EUR_CRM_Article_no__c,EUR_CRM_Unit_Type__c,EUR_CRM_Brand_Quality_Size__c, EUR_CRM_Number_of_Bottles__c, EUR_CRM_Bottles_in_Carton__c, EUR_CRM_Bottles_per_Case__c 
                                        from EUR_CRM_SKU__c where id in:existingIds]){
            itemMap.put(sku.id,(sObject)sku);
        }
        //itemMap = new Map<Id,EUR_CRM_SIZE__c>([select id, name from EUR_CRM_SIZE__c where id in: existingIds]);
        //itemMap = new Map<Id,sobject>([select id, name from EUR_CRM_SIZE__c where id in: existingIds]);
        /*itemMap.putAll(new Map<Id,EUR_CRM_SKU__c>([select id, name, EUR_CRM_Article_no__c,EUR_CRM_Unit_Type__c,EUR_CRM_Brand_Quality_Size__c, EUR_CRM_Number_of_Bottles__c, EUR_CRM_Bottles_in_Carton__c, EUR_CRM_Bottles_per_Case__c 
                                        from EUR_CRM_SKU__c where id in:existingIds]));*/
    }
    public void removeBQS(){
        Integer i = Integer.valueOf(ApexPages.CurrentPage().getParameters().get('rowIndex'));
        EUR_CRM_ObjPromo_Target__c  target = targets.remove(i-1);
        if(target.id != null)
            toDeleteTargets.add(target); 

        if(target.EUR_CRM_BQS__c != null)
            existingIDs.remove(target.EUR_CRM_BQS__c);

        if(target.EUR_CRM_SKU__c != null)
            existingIDs.remove(target.EUR_CRM_SKU__c);
    }

    /*public void removeSKU(){
        Integer i = Integer.valueOf(ApexPages.CurrentPage().getParameters().get('rowIndex'));
        EUR_CRM_ObjPromo_Target__c  target = targets.remove(i-1);
        if(target.id != null)
            toDeleteTargets.add(target); 
        existingIDs.remove(target.EUR_CRM_SKU__c);
    }*/

    public PageReference cancel(){            
        PageReference pageRef = new PageReference('/' + objPromo.Id); 
        pageRef.setRedirect(true); 
        return pageRef;    
    }
    public void quickSave(){
        try{
            if(toDeleteTargets.size() > 0)
                delete toDeleteTargets;
            upsert targets;     
        }catch(DMLException e){
            system.debug(e); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError )); 
        }
    }
    public PageReference saveBQS(){
        quickSave();
        return cancel();  
    }  
   public override void add(){   
        EUR_CRM_ObjPromo_Target__c target = new EUR_CRM_ObjPromo_Target__c();
        String addedProduct = ApexPages.CurrentPage().getParameters().get('p1');

        sObject BQSorSKU = itemMap.get(addedProduct);

        if(BQSorSKU.Id.getSObjectType() == EUR_CRM_Size__C.sObjectType){
            target.EUR_CRM_BQS__c = (ID) addedProduct ;
            target.EUR_CRM_ObjPromo__c = objPromo.Id; 
            target.EUR_CRM_BQS__r = (EUR_CRM_Size__c )itemMap.get((ID) addedProduct);
        }

        if(BQSorSKU.Id.getSObjectType() == EUR_CRM_SKU__C.sObjectType){
            target.EUR_CRM_SKU__C = (ID) addedProduct ;
            target.EUR_CRM_ObjPromo__c = objPromo.Id; 
            target.EUR_CRM_SKU__r = (EUR_CRM_SKU__c )itemMap.get((ID) addedProduct);
        }


        targets.add(target);
        target.recordtypeid = rtMap.get(OBJ_VOL_TARGET);
        existingIds.add((ID) addedProduct );
   }
   public void dummy(){
   
   }

   public boolean getIsSelectByBQS(){
        return productSelectMethod == 'BQS';
   }

   public boolean getIsSelectBySKU(){
        return productSelectMethod == 'SKU';
   }
}