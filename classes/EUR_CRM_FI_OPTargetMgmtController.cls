/*
    Contrller Class for Finland Objective & Promotion Target Management Page
*/
public class EUR_CRM_FI_OPTargetMgmtController  extends EUR_CRM_AbstractSelectionItem{
    public EUR_CRM_AbstractSelectionItem sCon {get;set;} 
    public EUR_CRM_ObjPromo__c objPromo {get;set;}
    public static final String ON_TRADE = 'On';
    public static final String OFF_TRADE = 'Off';
    public static final String PROS = 'PROS';
    public static final String CUSTOMER_TAXONOMY = 'Customer Taxonomy';
    public static final String BQ = 'BQ';
    public static final String BQS= 'BQS';
    public static final String SKU = 'SKU'; 
    public static final String TYPE_1 = 'Type 1';
    public static final String TYPE_2 = 'Type 2'; 
    public static final String OBJECTIVE_VOLUME_TARGET = 'EUR_CRM_Objective_Volume_Target'; 
    public static final String OBJECTIVE_PRODUCT = 'EUR_CRM_Objective_Product'; 
     
    //op paramenters
    public String channel {get;set;} // on or off trade
    public String selectionType {get;set;} // pros or customer taxonomy
    public String productLevel {get;set;} //bq bqs or sku
    public String opType {get;set;} // type or type 2?
     
    public String productObject;  //object api name of the product
    ApexPages.StandardController std;
    /*
    */
    //4 types of targets
    private transient Set<String> targetRecordTypes = new Set<String>{
        'EUR_CRM_Objective_Volume_Target',
        'EUR_CRM_SR_Volume_Target',
        'EUR_CRM_Objective_Commitment_Target',
        'EUR_CRM_SR_Commitment_Target',
        'EUR_CRM_Objective_Product'
    };
    public List<EUR_CRM_ObjPromo_Target__c> objectiveVolumeTargets {get;set;} // deprecated
    public List<EUR_CRM_ObjPromo_Target__c> objectiveProductVolumeTargets {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> srVolumeTargets {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> objectiveCommitmentTarget {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> srCommitmentTargets {get;set;}     
    
    public String productRecordType {get;set;}
    public String oPProductAPI {get;set;}
    public String productAPIName {get;set;}
    public String itemLabel {get;set;}
    public List<User> salesReps {get;set;}
    public transient List<EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c> prosSegments {get;set;}
    Map<String,Id> rtMap = new Map<String,Id>();
    private List<EUR_CRM_ObjPromo_Target__c> toDeleteTargets; 
    public Boolean isDraft {get;set;}
    public EUR_CRM_FI_OPTargetMgmtController(ApexPages.StandardController stdController) {  
        sCon = this;
        std = stdController;

        if(!Test.isRunningTest())
            std.addFields(new List<String>{'RecordType.Developername','EUR_CRM_Status__c','EUR_CRM_CustomerTaxonomy_Chain__c'});
        
        itemMap = new Map<Id,SObject>();
        this.objPromo= (EUR_CRM_ObjPromo__c)stdController.getRecord(); 
        selectionType = objPromo.EUR_CRM_Account_Selection_Type__c;
        productLevel = objPromo.EUR_CRM_Product_Hierarchy_Level__c;
        opType = objPromo.EUR_CRM_O_P_Type__c; 
        channel = objPromo.RecordType.developername == 'EUR_FI_On_Trade_O_P' ? ON_TRADE : OFF_TRADE ;
        rtMap = new Map<String,Id>();
        for(RecordType rt : [select id, developername from RecordType where developername in :targetRecordTypes and sobjecttype = 'EUR_CRM_ObjPromo_Target__c']){
            rtMap.put(rt.developername,rt.id);
        }
        initProductLevel(); 
        initSalesReps();
        initTargets();
        isDraft = objPromo.EUR_CRM_Status__c == 'Draft'; 
      
    }
    public Integer accountSize {get; set;}
    public EUR_CRM_ObjPromo_Target__c getObjCommitmentTarget() {
        return objectiveCommitmentTarget == null ? null : objectiveCommitmentTarget.size() == 0 ? null : objectiveCommitmentTarget.get(0);
    }

    void initSalesReps(){
        List<EUR_CRM_Account__c> euAccounts =  EUR_CRM_FI_UtilClass.retrieveOPAccounts(objPromo, null, 'Name', 'ASC' );
        accountSize = euAccounts == null ? 0 : euAccounts.size();
        salesReps = EUR_CRM_FI_UtilClass.retrieveOwners(euAccounts); 
       
        if(getSalesRepsSize() == 0){
            if(selectionType == 'Customer Taxonomy')
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,  Label.EUR_CRM_CustomerTaxonomyHasNoAccounts));    
            if(selectionType == 'PROS')         
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,  Label.EUR_CRM_PROSSegmentHasNoAccounts));    
       
        }
    }

    public Integer getSalesRepsSize(){
        return salesReps == null ? 0 : salesReps.size();
    }
    void initTargets(){
        objectiveProductVolumeTargets = new List<EUR_CRM_ObjPromo_Target__c>(); 
        objectiveCommitmentTarget = new List<EUR_CRM_ObjPromo_Target__c>();
        srCommitmentTargets = new List<EUR_CRM_ObjPromo_Target__c>();
        toDeleteTargets = new List<EUR_CRM_ObjPromo_Target__c>();
        List<EUR_CRM_ObjPromo_Target__c> targets = [select id,
        EUR_CRM_BQS__c,
        EUR_CRM_BQS__r.name,
        EUR_CRM_BQ__c,
        EUR_CRM_BQ__r.name,
        EUR_CRM_SKU__c,
        recordtype.developername,
        EUR_CRM_Visit_Targets__c,
        EUR_CRM_Is_Quota__c,
        EUR_CRM_Target_Owner__c ,
        EUR_CRM_Unit_of_Measure__c,
        EUR_CRM_Grouping_Type__c,
        EUR_CRM_SKU__r.name,EUR_CRM_Qty_Sell_in_Amount_Bottle__c   from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c =: objPromo.Id
        ];
        itemMap = new Map<Id,SObject>();
        
        for(EUR_CRM_ObjPromo_Target__c target : targets ){
             existingIds.add(target.EUR_CRM_BQS__c);
             existingIds.add(target.EUR_CRM_BQ__c);
             existingIds.add(target.EUR_CRM_SKU__c);
             if(target.recordtype.developername == 'EUR_CRM_Objective_Volume_Target' || target.recordtype.developername == OBJECTIVE_PRODUCT)
                objectiveProductVolumeTargets.add(target);
             if(target.recordtype.developername == 'EUR_CRM_Objective_Commitment_Target')
                objectiveCommitmentTarget.add(target);
             if(target.recordtype.developername == 'EUR_CRM_SR_Commitment_Target')
                srCommitmentTargets.add(target);
        }
        existingIds.remove(null);
         if(objectiveCommitmentTarget.size() == 0){
            EUR_CRM_ObjPromo_Target__c target = new EUR_CRM_ObjPromo_Target__c(); 
            target.EUR_CRM_ObjPromo__c = objPromo.Id; 
            target.recordtypeid = rtMap.get('EUR_CRM_Objective_Commitment_Target');  
            objectiveCommitmentTarget.add(target);
        }
        if(productLevel == 'BQ')
            itemMap = new Map<Id,EUR_CRM_Quality__c>([select id, name from EUR_CRM_Quality__c where id in: existingIds]);
        if(productLevel == 'BQS')
            itemMap = new Map<Id,EUR_CRM_SIZE__c>([select id, name from EUR_CRM_SIZE__c where id in: existingIds]);
        if(productLevel == 'SKU')
            itemMap = new Map<Id,EUR_CRM_SKU__c>([select id, name from EUR_CRM_SKU__c where id in: existingIds]);
            
    } 
    public List<EUR_CRM_ObjPromo_Target__c> getSalesRepCommitmentTargets(){
        Boolean isQuota = false;
        Id parentOp = null;
        if(objectiveCommitmentTarget != null || objectiveCommitmentTarget.size() > 0){
            isQuota = objectiveCommitmentTarget.get(0).EUR_CRM_Is_Quota__c;
            parentOp = objectiveCommitmentTarget.get(0).id;
        }
        if(parentOp == null) 
            return null; 
        if(srCommitmentTargets == null || srCommitmentTargets.size() == 0){
            Id recordtypeid = rtMap.get('EUR_CRM_SR_Commitment_Target');  
            for(User u : salesReps){ 
                EUR_CRM_ObjPromo_Target__c target = new EUR_CRM_ObjPromo_Target__c(); 
                target.EUR_CRM_ObjPromo__c = objPromo.Id; 
                target.recordtypeid =recordtypeid;
                target.EUR_CRM_Target_Owner__c = u.id;
               // target.EUR_CRM_Is_Quota__c = isQuota;
                 target.EUR_CRM_O_P_Target__c = parentOp;
                srCommitmentTargets.add(target);                  
            }
        } else{
            for(EUR_CRM_ObjPromo_Target__c op: srCommitmentTargets){
                op.EUR_CRM_Is_Quota__c = isQuota;
            }
        }
        return srCommitmentTargets;         
    }
    public PageReference quickSaveOPAttribute(){ 
        std.save();
        //update objPromo;
        this.objPromo= (EUR_CRM_ObjPromo__c)std.getRecord(); 
        Boolean resetStep3 = (productLevel != null && productLevel != objPromo.EUR_CRM_Product_Hierarchy_Level__c) || (opType != null && opType != objPromo.EUR_CRM_O_P_Type__c) ;
        Boolean resetStep2 = selectionType != null && selectionType != objPromo.EUR_CRM_Account_Selection_Type__c;
        selectionType = objPromo.EUR_CRM_Account_Selection_Type__c;
        productLevel = objPromo.EUR_CRM_Product_Hierarchy_Level__c;
        opType = objPromo.EUR_CRM_O_P_Type__c;

        if(resetStep2)
            resetOPSelectionValues();
        if(resetStep2 || resetStep3)
            deleteAllTargets();

        initProductLevel();
        
        PageReference pr = new PageReference('/apex/EUR_CRM_FI_OPTargetMgmtPage?id=' + objPromo.id);
        pr.setRedirect(true); 
        return pr;
    } 
    public PageReference saveOPAttribute(){ 
        quickSaveOPAttribute();
        return cancel();
    } 
    public PageReference saveOPAttributeContinue(){
        quickSaveOPAttribute();
        PageReference pr = new PageReference('/apex/EUR_CRM_FI_OPTargetMgmtPage?id=' + objPromo.id);
        pr.setRedirect(true);
        pr.getParameters().put('f','step2');
        return pr; 
    }

    public PageReference cancel(){
        PageReference pr = new PageReference('/' + objPromo.id);
        pr.setRedirect(true);
        return pr;
    }
    
    public void resetOPSelectionValues(){
        //taxonomy
        objPromo.EUR_CRM_CustomerTaxonomy_Chain__c = null;
        objPromo.EUR_CRM_Customer_Taxonomy_Sub_Chain__c = null;
        objPromo.EUR_CRM_Customer_Taxonomy_Chain_Region__c = null; 
        //pros
        objPromo.EUR_CRM_PROS_Image_Level__c = null;
        objPromo.EUR_CRM_PROS_Group_Outlet__c = null;
        
        update objPromo;

        //delete pros mappings
        List<EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c> dProsMap = [select id from EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c where EUR_CRM_ObjPromo__c =: objPromo.id];
            if(dProsMap!= null && dProsMap.size() >0)
                delete dProsMap;
        //delete cust mappings
        List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c> dCustMap = [select id from EUR_CRM_OP_Customer_Taxonomy_Mapping__c where EUR_CRM_ObjPromo__c =: objPromo.id];
            if(dCustMap!= null && dCustMap.size() >0)
                delete dCustMap;
    }
    
    public void deleteAllTargets(){
        delete [select id from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c =:  objPromo.Id];
    }
    public override void add(){ 
        EUR_CRM_ObjPromo_Target__c target = new EUR_CRM_ObjPromo_Target__c();
        String productID = ApexPages.CurrentPage().getParameters().get('p1');
        target.EUR_CRM_ObjPromo__c = objPromo.Id;
        target.put(oPProductAPI+'__c', (ID) productID );
        target.putSobject(oPProductAPI+'__r', itemMap.get((ID) productID));
        objectiveProductVolumeTargets.add(target);
        if(objPromo.EUR_CRM_O_P_Type__c == TYPE_1)
            target.recordtypeid = rtMap.get(OBJECTIVE_PRODUCT);
        else
            target.recordtypeid = rtMap.get(OBJECTIVE_VOLUME_TARGET);
        existingIds.add((ID) productID );
    }
    public void removeProduct(){
        Integer i = Integer.valueOf(ApexPages.CurrentPage().getParameters().get('rowIndex'));
        EUR_CRM_ObjPromo_Target__c  target = objectiveProductVolumeTargets.remove(i-1);
        if(target.id != null)
            toDeleteTargets.add(target); 
        existingIDs.remove((ID)target.get(oPProductAPI+'__c'));
    }
    
    public void quickSave(){
         quickSave(true);
    }
    public void quickSave(Boolean flag){
        try{
            EUR_CRM_OPTargetHelperClass.deleteTargets(toDeleteTargets);
            List<EUR_CRM_ObjPromo_Target__c> toUpsert = new List<EUR_CRM_ObjPromo_Target__c>();
            toUpsert.addAll(objectiveProductVolumeTargets);
            validateCommitmentTarget(objectiveCommitmentTarget);
            //if(objectiveCommitmentTarget != null && objectiveCommitmentTarget.size() > 0 && objectiveCommitmentTarget.get(0).EUR_CRM_Visit_Targets__c != null)
            if(validateCommitmentTarget(objectiveCommitmentTarget)){
                toUpsert.addAll(objectiveCommitmentTarget);
                
                if(srCommitmentTargets!= null && srCommitmentTargets.size() > 0 && flag){
                   deleteSRCommitmentTargets();  
                    srCommitmentTargets = new List<EUR_CRM_ObjPromo_Target__c>();
                }
            }
            if(toUpsert != null && toUpsert.size() >0)
                upsert toUpsert;
        }catch(DMLException e){
            system.debug(e); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError + e )); 
        }
    }
    
    public void deleteSRCommitmentTargets(){
        List<EUR_CRM_ObjPromo_Target__c> toDelete = new List<EUR_CRM_ObjPromo_Target__c>();
        for(EUR_CRM_ObjPromo_Target__c t : srCommitmentTargets){
            if(t.id != null)
                toDelete.add(t);
        }
        delete toDelete;
    }
    Boolean validateCommitmentTarget(List<EUR_CRM_ObjPromo_Target__c> objectiveCommitmentTarget){
        Boolean isValid = false;
        if(objectiveCommitmentTarget != null && objectiveCommitmentTarget.size() > 0 && objectiveCommitmentTarget.get(0).EUR_CRM_Visit_Targets__c != null){
            isValid = true;
            EUR_CRM_ObjPromo_Target__c target = objectiveCommitmentTarget.get(0);  
            if(target.EUR_CRM_Visit_Targets__c > accountSize){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_CommitmentTargetExceedsAccountSize )); 
                isValid = false;
            }
        } 
        return isValid;
    } 
    Boolean validateSRCommitmentTarget(List<EUR_CRM_ObjPromo_Target__c> srCommitmentTargets){
        Boolean isValid = false;
        if(srCommitmentTargets != null && srCommitmentTargets.size() > 0  ){
            isValid = true;
            if(validateCommitmentTarget(objectiveCommitmentTarget)){
                EUR_CRM_ObjPromo_Target__c target = objectiveCommitmentTarget.get(0);
                //if(target.EUR_CRM_Is_Quota__c){
                    Decimal total = 0;
                    for(EUR_CRM_ObjPromo_Target__c t : srCommitmentTargets){
                        total += t.EUR_CRM_Visit_Targets__c == null ? 0 :t.EUR_CRM_Visit_Targets__c; 
                    }
                    
                    if(total > target.EUR_CRM_Visit_Targets__c){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SalesRepCommitmentTargetExceedsObjectiveTarget )); 
                        isValid=false;
                    }else if(total < target.EUR_CRM_Visit_Targets__c){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SalesRepCommitmentTargetLessThanObjectiveTarget )); 
                        isValid=false;
                    }
               // }
            }else{   
                isValid=false;
            }
        } 
        return isValid;
    } 
    Boolean validateSRVolumeTarget(){
        Boolean isValid = false;
       
        if( objPromo.EUR_CRM_O_P_Type__c == TYPE_2 && sRTargetWraps != null && sRTargetWraps.size() > 0  ){ 
            for(EUR_CRM_OPTargetHelperClass.TargetWrap targetWrap: sRTargetWraps){
                if(targetWrap.target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c != targetWrap.getSubTargetBottleTotal()){
                    isValid = false;
                           
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_PleaseCheckVolumeTarget )); 
                
                    break;
                }
            }
            isValid = true;
        } 
        return isValid;
    } 
    public void quickSaveSRTargets(){
        try{
            List<EUR_CRM_ObjPromo_Target__c> toUpsert = new List<EUR_CRM_ObjPromo_Target__c>();

            if(validateSRVolumeTarget() && srVolumeTargets!=null && srVolumeTargets.size() > 0)
                toUpsert.addAll(srVolumeTargets);
            if(validateSRCommitmentTarget(srCommitmentTargets))
                toUpsert.addAll(srCommitmentTargets);
            if(toUpsert != null && toUpsert.size() >0)
                upsert toUpsert;    
        }catch(DMLException e){
            system.debug(e); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError));
 
        }
    }
    public PageReference save(){
        quickSave(false);
        quickSaveSRTargets();
        if(ApexPages.hasMessages())
            return null;
        return cancel();
   }
   List<EUR_CRM_OPTargetHelperClass.TargetWrap> sRTargetWraps;
   public List<EUR_CRM_OPTargetHelperClass.TargetWrap> getSRTargetWraps(){ 
        try{
              srVolumeTargets = new List<EUR_CRM_ObjPromo_Target__c >();
              Id parentRecordTypeId = rtMap.get('EUR_CRM_Objective_Volume_Target');
              Id subTargetRecordTypeId = rtMap.get('EUR_CRM_SR_Volume_Target');
              String targetField =  oPProductAPI;
              Id rManager = null; //no managers
              List<String> additionalFields = new List<String>{'EUR_CRM_Promotion_Type__c ','EUR_CRM_Grouping_Type__c ','EUR_CRM_Unit_of_Measure__c ','EUR_CRM_Qty_Sell_in_Amount_Bottle__c ','EUR_CRM_BQ__c ', 'EUR_CRM_BQ__r.name ','EUR_CRM_BQS__c ', 'EUR_CRM_BQS__r.name ','EUR_CRM_SKU__c ', 'EUR_CRM_SKU__r.name '};
               sRTargetWraps =  EUR_CRM_OPTargetHelperClass.retrieveTargets(objPromo.Id,srVolumeTargets ,parentRecordTypeId,subTargetRecordTypeId,targetField,salesReps
              ,rManager ,additionalFields);
          }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + e));
            return null;
          }  
    return sRTargetWraps;
    
   } 
   public void initProductLevel(){ 
         
        if(objPromo.EUR_CRM_Product_Hierarchy_Level__c == 'BQ'){
            productRecordType = 'EUR_FI_QUALITY';
            oPProductAPI = 'EUR_CRM_BQ';
            productAPIName = 'EUR_CRM_Quality__c';
            itemLabel = SObjectType.EUR_CRM_Quality__c.fields.Name.Label;
        }
        else if(objPromo.EUR_CRM_Product_Hierarchy_Level__c == 'BQS'){ 
            productRecordType = 'EUR_FI_SIZE';
            oPProductAPI = 'EUR_CRM_BQS';
            productAPIName = 'EUR_CRM_Size__c';
            itemLabel = SObjectType.EUR_CRM_Size__c.fields.Name.Label;
        }
        else if(objPromo.EUR_CRM_Product_Hierarchy_Level__c == 'SKU'){ 
            productRecordType = 'EUR_FI_SKU';
            oPProductAPI = 'EUR_CRM_SKU';
            productAPIName = 'EUR_CRM_SKU__c';
            itemLabel = SObjectType.EUR_CRM_SKU__c.fields.Name.Label;
        }
        else{ 
            productRecordType = 'EUR_FI_QUALITY';
            oPProductAPI = 'EUR_CRM_BQ';
            productAPIName = 'EUR_CRM_Quality__c';
            itemLabel = 'Product';
        }
    }
    public String getActiveTab(){
        String f = ApexPages.currentPage().getParameters().get('f');
        system.debug('### f: ' + f);        
        return String.IsEmpty(f) ? 'step1' : f;
    }
    public Boolean getDisableStep3(){
        Boolean flag = true;
        if(objPromo.EUR_CRM_Account_Selection_Type__c != null){        
            if(objPromo.EUR_CRM_Account_Selection_Type__c == 'PROS'){
               flag = !(prosSegments != null && prosSegments.size() > 0);
            }else{
               flag = String.IsEmpty(objPromo.EUR_CRM_CustomerTaxonomy_Chain__c);
            }        
        }
         system.debug('getDisableStep3 ' + flag);
         system.debug('EUR_CRM_Product_Hierarchy_Level__c ' +  objPromo.EUR_CRM_Product_Hierarchy_Level__c);
         system.debug('salesReps ' + salesReps );
         system.debug('EUR_CRM_O_P_Type__c ' +  objPromo.EUR_CRM_O_P_Type__c );
         system.debug('getDisableStep3 ' +  objPromo.EUR_CRM_Product_Hierarchy_Level__c);
        return   objPromo.EUR_CRM_O_P_Type__c == null || objPromo.EUR_CRM_Product_Hierarchy_Level__c == null || salesReps == null || salesReps.size() == 0;
    } 
    public Boolean getDisableStep2(){
        return String.IsEmpty(selectionType);
    }
 
}