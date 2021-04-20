public class EUR_CRM_DE_InvoiceTrackerExt extends EUR_CRM_DE_Contract_Class {
    public Boolean isFocusBrand {get;set;}
    public Boolean isPouring{get;set;}
    public Boolean isPouringRefund{get;set;}
    public Boolean isWKZFixAmount{get;set;}
    public Boolean isDrinksMenu{get;set;}
    public Boolean isEvent {get;set;}
    public Boolean isVisilibility{get;set;}
    public Boolean isPOSMaterial{get;set;}
    public Boolean isPOSWKZ{get;set;}
    public Boolean isNapkins{get;set;}
    public Boolean isTraining{get;set;}
    public Boolean isOthers {get;set;}  
    EUR_CRM_Contract__c contractObj;
    
    public String POS_WKZ = 'POS WKZ';
    public String POS_MATERIAL= 'POS Material';
    public String EVENTS{
              get { return 'Events'; } 
       }
    public String OTHERS = 'Others';
    public String TRAINING = 'Training';
    public String DRINKS_MENU = 'Drinks Menu';
    public String POURING_REFUND = 'Pouring Refund';
    public String WKZ_FIX_AMOUNT = 'WKZ Fix Amount';
    public String VISIBILITY_BRANDING = 'Visibility/ Branding';
    public String NAPKINS = 'Napkins'; 
    
    public List<String> mechanicList{get;set;} 
    private Map<String,EUR_CRM_Mechanic_Type__c> mechanicTypeMap;
    private Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> contractActivitiesMap;
    private Map<String,EUR_CRM_CIR_Contract_Activity_Line_Item__c> cirContractActivityMap;
    private List<EUR_CRM_CIR_Contract_Activity_Line_Item__c> cirContractActivityList;
    
    private Boolean createCIRs = false;
    
    Map<String, Map <String, EUR_CRM_Contract_Product_Item__c>> contractProductItemsMap;  
    public Map<Id, List<EUR_CRM_Contract_Product_Item__c>> contractProductItemsList {get;set;}  
    
    public EUR_CRM_Contract_Activity_Item__c pouringRefundActivity {get;set;}
    public List<EUR_CRM_CIR_Contract_Activity_Line_Item__c> pouringRefundActivityList {get;set;}
    
    public EUR_CRM_Contract_Activity_Item__c wkzFixAmountActivity {get;set;}
    public EUR_CRM_CIR_Contract_Activity_Line_Item__c wkzFixAmountCIRActivity {get;set;}
    
    public EUR_CRM_Contract_Activity_Item__c drinksMenuActivity{get;set;}
    public EUR_CRM_CIR_Contract_Activity_Line_Item__c drinksMenuCIRActivity {get;set;}
    
    public EUR_CRM_Contract_Activity_Item__c posMaterialActivity {get;set;}
    public EUR_CRM_CIR_Contract_Activity_Line_Item__c posMaterialCIRActivity {get;set;}
    
    public EUR_CRM_Contract_Activity_Item__c posWKZActivity {get;set;}
    public EUR_CRM_CIR_Contract_Activity_Line_Item__c posWKZCIRActivity {get;set;}
    
    public EUR_CRM_Contract_Activity_Item__c napkinsActivity {get;set;}
    public EUR_CRM_CIR_Contract_Activity_Line_Item__c napkinsCIRActivity {get;set;}
    
    public EUR_CRM_Contract_Activity_Item__c othersActivity {get;set;}
    public EUR_CRM_CIR_Contract_Activity_Line_Item__c othersCIRActivity {get;set;}
    
    public EUR_CRM_Contract_Activity_Item__c visibilityBrandingActivity {get;set;}
    public EUR_CRM_CIR_Contract_Activity_Line_Item__c visibilityBrandingCIRActivity {get;set;}
    
    
    public String cirActivityId {get;set;}
    public String productId {get;set;}
    public String pouringRefundId {get;set;}
    public String rowIndex{get;set;}
    
    public Map<Id,List<EUR_CRM_CIR_Invoice_Entry__c>> cirActInvoiceMap {get;set;}
    private Map<Id,EUR_CRM_CIR_Invoice_Entry__c> toDeleteInvoice;
    public Integer ZERO = 0;
    
    public List<EUR_CRM_Contract_Activity_Item__c> activityList {get;set;} 
    
    public List<ContractActivityCIRWrapper> contractActivityCIRWrapperList {get;set;}
    
    public EUR_CRM_DE_InvoiceTrackerExt(ApexPages.StandardController standardController){
    mechanicList = new List<String>{WKZ_FIX_AMOUNT, DRINKS_MENU,VISIBILITY_BRANDING ,POS_MATERIAL, POS_WKZ,NAPKINS,OTHERS   } ;
        contractObj = (EUR_CRM_Contract__c) standardController.getRecord();
        contractObj  = initContract(contractObj.id);
        mechanicTypeMap = new Map<String,EUR_CRM_Mechanic_Type__c>();
        //init
        Map <Id, EUR_CRM_Mechanic_Type__c>  mTypes = retrieveMechanicTypes(contractObj);
        for(Id key : mTypes.keySet()){
            EUR_CRM_Mechanic_Type__c mType = mTypes.get(key);    
            mechanicTypeMap.put(mType.EUR_CRM_Mechanic_Type_Name_English__c,mType);
        }
        cirContractActivityList = new List<EUR_CRM_CIR_Contract_Activity_Line_Item__c>();
        contractActivitiesMap =  retrieveContractActivityItems(contractObj);
        cirContractActivityMap = retrieveCirContractActivityMap();
        cirActInvoiceMap = retrieveCirActInvoiceMap();
        contractProductItemsMap =  retrieveContractProductItems(contractObj);
        contractProductItemsList = retrieveContractProductItemsList();
        system.debug('@@: ' + contractActivitiesMap );
        
        initPouringRefund();
        initEventsTrainingMap();
        contractActivityCIRWrapperList = new List<ContractActivityCIRWrapper>();
        for(String m :mechanicList  ){
            initContractActivity(m);
        } 
        populateActivityList();
        if(cirContractActivityList.size() > 0 )
            createCIRs  = true;
    }
    public void populateContractActivityCIRWrapperList(){
        
    }
    public void populateActivityList(){
        activityList = new List<EUR_CRM_Contract_Activity_Item__c>();
        if(wkzFixAmountActivity != null)
            activityList.add(wkzFixAmountActivity);
        if(drinksMenuActivity != null)
            activityList.add(drinksMenuActivity);
        if(visibilityBrandingActivity  != null)
            activityList.add(visibilityBrandingActivity );
        if(posMaterialActivity  != null)
            activityList.add(posMaterialActivity );
        if(posWKZActivity  != null)
            activityList.add(posWKZActivity );
        if(napkinsActivity  != null)
            activityList.add(napkinsActivity );
        if(othersActivity   != null)
            activityList.add(othersActivity  );
    }
    public void createCIRSHeaders(){
        if(createCIRs){
            insert cirContractActivityList;
            for(EUR_CRM_CIR_Contract_Activity_Line_Item__c cirActItem : cirContractActivityList){
                cirActInvoiceMap.put(cirActItem.id, new List<EUR_CRM_CIR_Invoice_Entry__c>());
            }
        }
    }
    
    public void addNewInvoice(){
        EUR_CRM_CIR_Invoice_Entry__c newInvoice = new EUR_CRM_CIR_Invoice_Entry__c(EUR_CRM_CIR_Contract_Activity_Line_Item__c = cirActivityId ); 
        cirActInvoiceMap.get(cirActivityId).add(newInvoice);
    }
    public void removeInvoice(){
        Integer i = Integer.valueOf(ApexPages.CurrentPage().getParameters().get('rowIndex')); 
        EUR_CRM_CIR_Invoice_Entry__c invoice = cirActInvoiceMap.get(cirActivityId).remove(i-1);
        if(invoice.id != null){
            toDeleteInvoice = toDeleteInvoice == null ? new Map<Id,EUR_CRM_CIR_Invoice_Entry__c>() : toDeleteInvoice;
            if(!toDeleteInvoice.containsKey(invoice.id))
                toDeleteInvoice.put(invoice.id,invoice );
        }
    }
    
    public Boolean initPouringRefund(){ 
        Id mechanicTypeId = mechanicTypeMap.get(POURING_REFUND) != null ?  mechanicTypeMap.get(POURING_REFUND).id : null;
        
        if(contractActivitiesMap.get(mechanicTypeId) == null || contractActivitiesMap.get(mechanicTypeId).size() == 0)
            return false;
        
        Map<String, EUR_CRM_Contract_Activity_Item__c> cAct = contractActivitiesMap.get(mechanicTypeId);
        
        pouringRefundActivity = cAct.values().get(0);
        system.debug('@@ Pouring Refund Products');
        String key = mechanicTypeId +'-' +pouringRefundActivity.name;
        Map <String, EUR_CRM_Contract_Product_Item__c> pouringRefundProducts = contractProductItemsMap.get(key);
        pouringRefundActivityList = new List<EUR_CRM_CIR_Contract_Activity_Line_Item__c>();
        for(String k : pouringRefundProducts.keySet()){
            EUR_CRM_Contract_Product_Item__c contractProduct = pouringRefundProducts.get(k);
            String cirKey = pouringRefundActivity.id + ''+ contractProduct.EUR_CRM_Brand_Quality__c;
            EUR_CRM_CIR_Contract_Activity_Line_Item__c cirContract = cirContractActivityMap.get(cirKey);
            if(cirContract == null){
                cirContract = new EUR_CRM_CIR_Contract_Activity_Line_Item__c(EUR_CRM_Contract_Activity_Item__c = pouringRefundActivity.id, 
                EUR_CRM_Brand_Quality__c = contractProduct.EUR_CRM_Brand_Quality__c,
                EUR_CRM_Brand_Quality__r= contractProduct.EUR_CRM_Brand_Quality__r,
                EUR_CRM_Contract_Product_Item__c =  contractProduct.id,
                EUR_CRM_Contract_Product_Item__r = contractProduct);
                cirContractActivityList.add(cirContract);
                cirContractActivityMap.put(key,cirContract);
            }
            pouringRefundActivityList.add(cirContract); 
            system.debug('@@ products: ' + k + ' ** ' + contractProduct);
        }
        system.debug('@@ to insert cirs: ' + cirContractActivityList);
        return true;
    }
    /*
    public Boolean initContractActivity(String mechanicType ){ 
        system.debug('@@ initContractActivity');
        Id mechanicTypeId = mechanicTypeMap.get(mechanicType) != null ?  mechanicTypeMap.get(mechanicType).id : null;
        
        if(contractActivitiesMap.get(mechanicTypeId) == null || contractActivitiesMap.get(mechanicTypeId).size() == 0)
            return false;
        
        Map<String, EUR_CRM_Contract_Activity_Item__c> cAct = contractActivitiesMap.get(mechanicTypeId);
        
        wkzFixAmountActivity = cAct.values().get(0);
        system.debug('@@ contractActivity' + wkzFixAmountActivity);
        String key = mechanicTypeId +'-' +wkzFixAmountActivity.name;
        String cirKey = wkzFixAmountActivity.id;
        EUR_CRM_CIR_Contract_Activity_Line_Item__c cirContract = cirContractActivityMap.get(cirKey);
        if(cirContract == null){
            wkzFixAmountCIRActivity = new EUR_CRM_CIR_Contract_Activity_Line_Item__c(EUR_CRM_Contract_Activity_Item__c = wkzFixAmountActivity.id);          
            cirContractActivityList.add(wkzFixAmountCIRActivity );
        }
        else
            wkzFixAmountCIRActivity = cirContract;
        cirContractActivityMap.put(key,wkzFixAmountCIRActivity );       
        system.debug('@@ to insert cirs: ' + cirContractActivityList);
        return true;
    }
    */
    public Boolean initContractActivity(String mechanicType ){ 
        system.debug('@@ initContractActivity');
        Id mechanicTypeId = mechanicTypeMap.get(mechanicType) != null ?  mechanicTypeMap.get(mechanicType).id : null;
        
        if(contractActivitiesMap.get(mechanicTypeId) == null || contractActivitiesMap.get(mechanicTypeId).size() == 0)
            return false;
        
        Map<String, EUR_CRM_Contract_Activity_Item__c> cAct = contractActivitiesMap.get(mechanicTypeId);
        
        EUR_CRM_Contract_Activity_Item__c activity =  cAct.values().get(0);
            
        system.debug('@@ contractActivity' + activity );
        String key = mechanicTypeId +'-' +activity.name;
        String cirKey = activity.id;
        EUR_CRM_CIR_Contract_Activity_Line_Item__c cirContract = cirContractActivityMap.get(cirKey);
        if(cirContract == null){
            cirContract = new EUR_CRM_CIR_Contract_Activity_Line_Item__c(EUR_CRM_Contract_Activity_Item__c = activity.id);          
            cirContractActivityList.add(cirContract);
        }
        if(mechanicType == POS_WKZ){            
            posWKZActivity  = activity;
            posWKZCIRActivity  = cirContract; 
        }else if(mechanicType == POS_MATERIAL){
            posMaterialActivity  = activity;
            posMaterialCIRActivity  = cirContract;
        }else if(mechanicType == OTHERS  ){
            othersActivity  = activity;
            othersCIRActivity  = cirContract;
        }else if(mechanicType == DRINKS_MENU ){
            drinksMenuActivity = activity;
            drinksMenuCIRActivity  = cirContract;
        }else if(mechanicType == NAPKINS ){
            napkinsActivity  = activity;
            napkinsCIRActivity  = cirContract;
        }else if(mechanicType == WKZ_FIX_AMOUNT  ){
            wkzFixAmountActivity   = activity;
            wkzFixAmountCIRActivity = cirContract;
        }else if(mechanicType == VISIBILITY_BRANDING   ){
            visibilityBrandingActivity  = activity;
            visibilityBrandingCIRActivity  = cirContract;
        }
            ContractActivityCIRWrapper cirWrapper = new ContractActivityCIRWrapper();   
            cirWrapper.mechanicName = mechanicType;
            cirWrapper.cirContractActivity =    cirContract;
            cirWrapper.contractActivity =   activity;
            contractActivityCIRWrapperList.add(cirWrapper);
        cirContractActivityMap.put(key,cirContract);       
        system.debug('@@ to insert cirs: ' + cirContractActivityList);
        return true;
    }
    public Map<String,EUR_CRM_CIR_Contract_Activity_Line_Item__c> retrieveCirContractActivityMap(){
        Map<String,EUR_CRM_CIR_Contract_Activity_Line_Item__c> cMap = new Map<String,EUR_CRM_CIR_Contract_Activity_Line_Item__c>();
        Set<Id> cActIds = new Set<Id>();
        
        for(Id key : contractActivitiesMap.keySet()){
            for(String s : contractActivitiesMap.get(key).keySet()){
                cActIds.add(contractActivitiesMap.get(key).get(s).id); 
            }
        }
        system.debug('@@ retrieving cirs' + cActIds );
        for(EUR_CRM_CIR_Contract_Activity_Line_Item__c cirAct : [select id,EUR_CRM_Status__c,EUR_CRM_Contract_Activity_Item__c, EUR_CRM_Brand_Quality__c, EUR_CRM_Brand_Quality__r.name,EUR_CRM_Contract_Product_Item__r.EUR_CRM_Amount_Spent__c from EUR_CRM_CIR_Contract_Activity_Line_Item__c where EUR_CRM_Contract_Activity_Item__c in:cActIds]){
            String key = cirAct.EUR_CRM_Contract_Activity_Item__c;
            if(cirAct.EUR_CRM_Brand_Quality__c != null)
                key += cirAct.EUR_CRM_Brand_Quality__c;
            cMap.put(key,cirAct);
        }
        system.debug('@@ retrieving cirs maps' + cMap);
        return cMap;
    }
    public Map<Id,List<EUR_CRM_CIR_Invoice_Entry__c>> retrieveCirActInvoiceMap(){
        Map<Id,List<EUR_CRM_CIR_Invoice_Entry__c>> cMap = new Map<Id,List<EUR_CRM_CIR_Invoice_Entry__c>>();
        
        Set<Id> cirActItemIds = new Set<Id>();
        for(EUR_CRM_CIR_Contract_Activity_Line_Item__c cirActItem : cirContractActivityMap.values()){
            cirActItemIds.add(cirActItem.id);
        }
        system.debug('@@ retrieving cirs invoice' + cirActItemIds );
        for(Id cirId : cirActItemIds){
            cMap.put(cirId, new List<EUR_CRM_CIR_Invoice_Entry__c>());
        }
        for(EUR_CRM_CIR_Invoice_Entry__c  cirInvoice: [select id,Name,EUR_CRM_Amount__c, EUR_CRM_CIR_Contract_Activity_Line_Item__c
                from EUR_CRM_CIR_Invoice_Entry__c where EUR_CRM_CIR_Contract_Activity_Line_Item__c in:cirActItemIds]){
                cMap.get(cirInvoice.EUR_CRM_CIR_Contract_Activity_Line_Item__c).add(cirInvoice); 
        }
        system.debug('@@ retrieving cirs invoice maps' + cMap);
        return cMap;
    }
    public Map<Id, List<EUR_CRM_Contract_Product_Item__c>> retrieveContractProductItemsList(){
        Map<Id, List<EUR_CRM_Contract_Product_Item__c>> cMap = new Map<Id, List<EUR_CRM_Contract_Product_Item__c>>();
        
         for (EUR_CRM_Contract_Product_Item__c contractProductItem: [SELECT Id, Name,
                                                                EUR_CRM_Brand__c,
                                                                EUR_CRM_Brand__r.Name,
                                                                EUR_CRM_Brand_Quality__c,
                                                                EUR_CRM_Brand_Quality__r.Name,
                                                                EUR_CRM_Contract_Activity_Item__c,
                                                                EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c,
                                                                EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__c,
                                                                EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.Name,
                                                                EUR_CRM_Contract_Activity_Item__r.Name,
                                                                EUR_CRM_Description__c, EUR_CRM_Quantity__c,
                                                                EUR_CRM_Amount__c, EUR_CRM_Amount_Spent__c,
                                                                EUR_CRM_Unit__c, EUR_CRM_Name_Reference__c,
                                                                EUR_CRM_Exclusive__c
                                                                FROM EUR_CRM_Contract_Product_Item__c
                                                                WHERE EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c=:contractObj.Id])
        {
            List<EUR_CRM_Contract_Product_Item__c> productItemList = cMap.get(contractProductItem.EUR_CRM_Contract_Activity_Item__c);
            if(productItemList == null){
                productItemList = new List<EUR_CRM_Contract_Product_Item__c>();
                cMap.put(contractProductItem.EUR_CRM_Contract_Activity_Item__c, productItemList);
            }
            productItemList.add(contractProductItem);
        }
        for(EUR_CRM_Contract_Activity_Item__c actItem: [select id from EUR_CRM_Contract_Activity_Item__c where EUR_CRM_Contract__c=:contractObj.Id]){
            if(cMap.get(actItem.id) == null)
                cMap.put(actItem.id,new List<EUR_CRM_Contract_Product_Item__c>());
        }
        system.debug('@@ retrieving cirs invoice maps' + cMap);
        return cMap;
    }
    public void quickSave(){
     Savepoint sp = Database.setSavepoint();

        try{
            if(toDeleteInvoice != null && toDeleteInvoice.size() > 0)
                delete toDeleteInvoice.values();
            List<EUR_CRM_CIR_Invoice_Entry__c> toUpserts = new List<EUR_CRM_CIR_Invoice_Entry__c>();
            for(List<EUR_CRM_CIR_Invoice_Entry__c> temp :cirActInvoiceMap.values() ){
                toUpserts.addAll(temp);
            }
            List<EUR_CRM_CIR_Contract_Activity_Line_Item__c> activityList = new List<EUR_CRM_CIR_Contract_Activity_Line_Item__c>();
            for(ContractActivityCIRWrapper wrapper : contractActivityCIRWrapperList){
                activityList.add(wrapper.cirContractActivity);
            }
            if(activityList != null && activityList.size() >0)
                upsert activityList;
            if(pouringRefundActivityList != null && pouringRefundActivityList.size() >0)
                upsert pouringRefundActivityList;
            if(toUpserts != null && toUpserts.size() >0)
                upsert toUpserts;
            
            if(eventsTrainingMap != null && eventsTrainingMap.size() > 0){
                List<EUR_CRM_CIR_Contract_Activity_Line_Item__c> eventTrainingList = new List<EUR_CRM_CIR_Contract_Activity_Line_Item__c>();
               
                for(List<ContractActivityCIRWrapper> wrapperList : eventsTrainingMap.values()){
                    if(wrapperList != null)
                    for(ContractActivityCIRWrapper wrapper : wrapperList){
                        if(wrapper != null && wrapper.cirContractActivity!=null)
                        eventTrainingList.add(wrapper.cirContractActivity);
                    }
                }
                if(eventTrainingList != null && eventTrainingList.size() >0)
                    upsert eventTrainingList;
            }
        }catch(DMLException e){
            system.debug(e); 
            Database.rollback(sp);

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError )); 
        }
    }
    public EUR_CRM_Contract__c initContract(Id contractId){
            if ( contractId != null){
            List<EUR_CRM_Contract__c> contractList = [SELECT Id, Name, 
                                                EUR_CRM_Account__c,
                                                EUR_CRM_Contact__c,
                                                EUR_CRM_Country_Code__c,
                                                EUR_CRM_Contract_Type__c,
                                                EUR_CRM_End_Date__c,
                                                EUR_CRM_Nominated_Supplier__c,
                                                EUR_CRM_Payment_Method__c,
                                                EUR_CRM_Start_Date__c,
                                                EUR_CRM_Status__c,
                                                EUR_CRM_Active__c,
                                                EUR_CRM_Contract_Approved_Date__c,
                                                EUR_CRM_Total_Contract_Line_Items__c,
                                                EUR_CRM_Contract_Sub_Type__c,
                                                EUR_CRM_DE_Actual_Contract_Total__c,
                                                EUR_CRM_DE_Deductible_Contract_Total__c,
                                                EUR_CRM_Flagship_Brand__c,
                                                EUR_CRM_Total_Pro_Rated_Amount__c,
                                                EUR_CRM_Budget_Balance_Reference__c,
                                                EUR_CRM_Budget__c,
                                                EUR_CRM_Agrees_with_TC__c,
                                                EUR_CRM_Contract_Uploaded__c
                                                FROM EUR_CRM_Contract__c
                                                WHERE Id =: contractId];
        if (contractList.size()>0){
            EUR_CRM_Contract__c contract = contractList.get(0);
                            return contract;
        }
    }
    return null;
    }
    
    public Integer retValue(){
        return 1;
    }
    public Map<String, List<ContractActivityCIRWrapper>> eventsTrainingMap {get; set;}
    
    public void initEventsTrainingMap(){
            system.debug('@@ initEventsTrainingMaps');
        eventsTrainingMap = new Map<String, List<ContractActivityCIRWrapper>>();
        List<String> mechanicTypes  = new List<String>{'Events', 'Training'};
        for(String mechanicType : mechanicTypes){
            Id mechanicTypeId = mechanicTypeMap.get(mechanicType) != null ?  mechanicTypeMap.get(mechanicType).id : null;
            system.debug('@@ initEventsTrainingMaps mechanicTypeId ' + mechanicTypeId );
            eventsTrainingMap.put(mechanicType, new List<ContractActivityCIRWrapper>());
            if(contractActivitiesMap.get(mechanicTypeId) == null || contractActivitiesMap.get(mechanicTypeId).size() == 0)
                continue;
            
            Map<String, EUR_CRM_Contract_Activity_Item__c> cAct = contractActivitiesMap.get(mechanicTypeId);
            
            for(EUR_CRM_Contract_Activity_Item__c activity :  cAct.values()){                               
                system.debug('@@ initEventsTrainingMaps contractActivity' + activity );
                String key = mechanicTypeId +'-' +activity.name;
                String cirKey = activity.id;
                EUR_CRM_CIR_Contract_Activity_Line_Item__c cirContract = cirContractActivityMap.get(cirKey);
                if(cirContract == null){
                    cirContract = new EUR_CRM_CIR_Contract_Activity_Line_Item__c(EUR_CRM_Contract_Activity_Item__c = activity.id);          
                    cirContractActivityList.add(cirContract);
                }
                /*
                if(mechanicType == POS_WKZ){            
                    posWKZActivity  = activity;
                    posWKZCIRActivity  = cirContract; 
                }else if(mechanicType == POS_MATERIAL){
                    posMaterialActivity  = activity;
                    posMaterialCIRActivity  = cirContract;
                */
                ContractActivityCIRWrapper cirWrapper = new ContractActivityCIRWrapper();   
                cirWrapper.mechanicName = mechanicType;
                cirWrapper.cirContractActivity =    cirContract;
                cirWrapper.contractActivity =   activity;
                //contractActivityCIRWrapperList.add(cirWrapper);
                cirContractActivityMap.put(key,cirContract);
                eventsTrainingMap.get(mechanicType).add(cirWrapper);
                system.debug('@@initEventsTrainingMaps to insert cirs: ' + cirContractActivityList);
            }           
        }
//return true;
    }
    
    public class ContractActivityCIRWrapper{
        public  String mechanicName {get;set;}
        public  EUR_CRM_CIR_Contract_Activity_Line_Item__c cirContractActivity {get;set;}   
        public  EUR_CRM_Contract_Activity_Item__c contractActivity {get;set;}          
        public  List<EUR_CRM_Contract_Product_Item__c> contractProductItems {get;set;}      
    }
     
    public PageReference cancel(){            
        PageReference pageRef = new PageReference('/' + contractObj.Id); 
        pageRef.setRedirect(true); 
        return pageRef;    
    }
    public PageReference save(){            
        quickSave();
        return cancel();    
    }
}