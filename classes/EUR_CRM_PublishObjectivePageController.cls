public class EUR_CRM_PublishObjectivePageController{

    public List<euAccountsWrapper> euAccounts {get;set;} 
    public transient List<EUR_CRM_Account__c> euAccountList {get;set;}
    public Boolean isTasting {get;set;} 
    public Boolean isTradeFair {get;set;} 
    public Boolean isPROS {get;set;} 
    public Boolean isLeaflet {get;set;} 
    public Boolean isSalesDrive {get;set;} 
    public Boolean isDistributionDrive {get;set;} 
    public Boolean isWSPromoWithLeadTime {get;set;} 
    public Boolean isWSPromoWithoutLeadTime {get;set;} 
    public Boolean isWSObjective {get;set;} 
    public Set<String> requireTargetVolCheck  = new Set<String>{'EUR_DE_Off_Trade_Sales_Drive' , 
                                                                'EUR_DE_WS_Objective' 
                                                                };

    private EUR_CRM_ObjPromo__c objective;
    private final String ON_TRADE_PROS_TMKT_PROMO = 'EUR_DE_OnTrade_PROS_TMKT_Promo'; 
    private final String OFF_TRADE_TASTING = 'EUR_DE_Off_Trade_Tasting_Campaign';
    private final String OFF_TRADE_TRADE_FAIR = 'EUR_DE_Off_Trade_Trade_Fair';
    private final String OFF_TRADE_LEAFLET = 'EUR_DE_Off_Trade_Leaflet_Campaign';
    private final String OFF_SALES_DRIVE = 'EUR_DE_Off_Trade_Sales_Drive';
    private final String OFF_DISTRIBUTION_DRIVE = 'EUR_DE_Off_Trade_Distribution_Drive';

    private final String WS_PROMO_WITH_LEAD_TIME = 'EUR_DE_WS_Promotion_with_Lead_Time';
    private final String WS_PROMO_WITHOUT_LEAD_TIME = 'EUR_DE_WS_Promotion_without_Lead_Time';
    private final String WS_OBJECTIVE = 'EUR_DE_WS_Objective';

    private final String ACTIVE = 'Active'; 
    private final String DEACTIVATED = 'Deactivated';
    private final String INPREPARE = 'In Preparation';
    private final String PUBLISHED = 'Published';

    public Boolean pageError {get;set;}
    private Id opAcccountRT;
    private  Set<ID> opAccountsSet;
    private Set<String> deCTaxAccountRecordTypes = new Set<String>{'EUR_DE_OFF_STD','EUR_DE_ON_Wholesaler'};
    private   Set<Id> taxonomySet = new Set<Id>();
    public Boolean publishDisabled {get;set;}
     
    public EUR_CRM_PublishObjectivePageController(ApexPages.StandardController stdController) {

        Set<Id> OwnerIdWithTargetVolSet = New Set<Id>();

        String d = ApexPages.currentPage().getParameters().get('d');
        if(d!=null && d=='1'){
        
            objective =  [select   RecordType.developername, EUR_CRM_Status__c, 
            EUR_CRM_PROS_Image_Level__c, EUR_CRM_ObjPromo_OnTrade_Variation__c ,
            EUR_CRM_Region__c, EUR_CRM_PROS_Group_Outlet__c ,EUR_CRM_Active_Start_Date__c,
            EUR_CRM_Territory__c, EUR_CRM_Type__c from EUR_CRM_ObjPromo__c where id =: stdController.getId()];
            
            cancel();
        }else{
            publishDisabled = false;
            
            objective =  [select   RecordType.developername, EUR_CRM_Status__c, 
            EUR_CRM_PROS_Image_Level__c, EUR_CRM_ObjPromo_OnTrade_Variation__c,
            EUR_CRM_Region__c, EUR_CRM_PROS_Group_Outlet__c ,EUR_CRM_Active_Start_Date__c,
            EUR_CRM_Territory__c, EUR_CRM_Type__c from EUR_CRM_ObjPromo__c where id =: stdController.getId()];
            euAccounts = new List<euAccountsWrapper>();
            pageError=false;
            
            String rtDevName = objective.RecordType.developername;
            
            isLeaflet = rtDevName == OFF_TRADE_LEAFLET;
            isTasting = rtDevName == OFF_TRADE_TASTING;
            isTradeFair = rtDevName == OFF_TRADE_TRADE_FAIR;
            isPROS = rtDevName == ON_TRADE_PROS_TMKT_PROMO;  
            isDistributionDrive = rtDevName == OFF_DISTRIBUTION_DRIVE;


            isWSPromoWithLeadTime = rtDevName == WS_PROMO_WITH_LEAD_TIME;
            isWSPromoWithoutLeadTime = rtDevName == WS_PROMO_WITHOUT_LEAD_TIME;  
            isWSObjective = rtDevName == WS_OBJECTIVE;


            isSalesDrive  = rtDevName == OFF_SALES_DRIVE || rtDevName == 'EUR_DE_Off_Trade_Sales_Drive_SKU_Bottles'||rtDevName == 'EUR_DE_Off_Trade_Sales_Drive_SKU_Displays';
            opAccountsSet = new Set<Id>();
            List<EUR_CRM_ObjPromo_Target__c> targets = null;       
            for(EUR_CRM_ObjPromo_Account_Mapping__c opA :[select EUR_CRM_Account__c from EUR_CRM_ObjPromo_Account_Mapping__c where EUR_CRM_ObjPromo__c =:objective.id]){
                opAccountsSet.add(opA.EUR_CRM_Account__c);
            }
        
            if(isPROS  ){
                
                if(objective.EUR_CRM_PROS_Group_Outlet__c  == null){
                    pageError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Missing Group Outlet Type'));
                }
                
                if(objective.EUR_CRM_PROS_Image_Level__c == null){
                    pageError= true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Missing Image level'));
                }
                if(objective.EUR_CRM_ObjPromo_OnTrade_Variation__c == null){
                    pageError= true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Missing On Trade Variation'));
                }
               
                
                if(!pageError ){
                    //system.debug('++ region: ' + objective.EUR_CRM_Region__c);
                    system.debug('++ imagelevel: ' + objective.EUR_CRM_PROS_Image_Level__c);
                    system.debug('++ groupoutlet: ' + objective.EUR_CRM_PROS_Group_Outlet__c);
                    system.debug('++ territory: ' + objective.EUR_CRM_Territory__c);
                    
                    Set<Id> accSet= new Set<Id>();
                    Set<String> images = new Set<String>();
                    /* @@
                    for(String image : (objective.EUR_CRM_PROS_Image_Level__c).split(';')){
                        if(image != null && image != '') 
                            images.add(image);
                    }
                    */
                    for(EUR_CRM_Pros_Segmentation__c pros : [select EUR_CRM_Account__c from  EUR_CRM_Pros_Segmentation__c where          
                    EUR_CRM_Account__r.EUR_CRM_Image_Level_Name__c =: objective.EUR_CRM_PROS_Image_Level__c and            
                    EUR_CRM_Group_Outlet_Type__r.eur_crm_group_outlet_name__c  =: objective.EUR_CRM_PROS_Group_Outlet__c]){
                        accSet.add(pros.EUR_CRM_Account__c);
                    }
                    
                    String query = 'select id from EUR_CRM_Territory__c where recordtype.developername = \'EUR_DE_Territory\' ';
                    
                    if(objective.EUR_CRM_Region__c != 'All Regions' && objective.EUR_CRM_Region__c != 'Alle Regionen'){
                        String regionName =  objective.EUR_CRM_Region__c;
                        query += ' and EUR_CRM_Region__r.name =:regionName';
                    }
                    String territoryName = objective.EUR_CRM_Territory__c;
                    if(territoryName  != null && territoryName  != 'All Territories' && territoryName !='Alle Gabiete'){
                        query += ' and name =:territoryName';
                    }
                    
                    Set<Id> territorySet = new Set<Id>();
                    for(EUR_CRM_Territory__c terr: (List<EUR_CRM_Territory__c >)Database.query(query)){
                        territorySet.add(terr.id);
                    } 
                    euAccountList = new List<EUR_CRM_Account__c>();



                    if(!requireTargetVolCheck.contains(rtDevName)){
                        //Select all account
                        for(EUR_CRM_Account__c euA :[select id, name,OwnerId,Owner.name from eur_crm_account__c 
                                                    where  id in:accSet and EUR_CRM_Territory__c in: territorySet
                                                    AND (EUR_CRM_Status_of_Customer__c != 'Inactive' AND EUR_CRM_Status_of_Customer__c != 'Deleted') limit 10000]){
                            //euAccounts.add(new euAccountsWrapper(euA, false));
                             euAccountList.add(euA);
                        } 
                    }else{
                        //Select Account With Non Zero Target Only

                        OwnerIdWithTargetVolSet = retrieveUserIdWithNoZeroTarget(objective.id);

                        for(EUR_CRM_Account__c euA :[select id, name,OwnerId,Owner.name from eur_crm_account__c 
                                                    where  id in:accSet and EUR_CRM_Territory__c in: territorySet
                                                    AND (EUR_CRM_Status_of_Customer__c != 'Inactive' AND EUR_CRM_Status_of_Customer__c != 'Deleted') AND OwnerId in : ownerIdWithTargetVolSet limit 10000]){
                            //euAccounts.add(new euAccountsWrapper(euA, false));
                             euAccountList.add(euA);
                        } 
                    }



               // euAccounts = retrieveEuAccountsWrapperList();
                }
            }else{  
                taxonomySet= new Set<Id>();
                for(EUR_CRM_OP_Customer_Taxonomy_Mapping__c taxMap : [select id,EUR_CRM_Customer_Taxonomy__c from EUR_CRM_OP_Customer_Taxonomy_Mapping__c where EUR_CRM_ObjPromo__c =: objective.id]){
                    taxonomySet.add(taxMap.EUR_CRM_Customer_Taxonomy__c);
                }
                if(taxonomySet.size() == 0){
                    publishDisabled = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.EUR_CRM_Select_Customer_Taxonomy_First)); 
                    
                }else{



                    String query = 'Select Id, name,Ownerid,Owner.name From EUR_CRM_Account__c where ';
                    query += ' recordtype.developername in : deCTaxAccountRecordTypes';
                    query += ' AND EUR_CRM_Status_of_Customer__c != \'Inactive\' AND EUR_CRM_Status_of_Customer__c != \'Deleted\'';
                    if(isTasting){
                        query +=' AND EUR_CRM_Outlet_suitable_for_tastings__c = \'Yes\''; 
                    }else if(isTradeFair){
                        query +=' AND EUR_CRM_Is_Trade_Fair_Location__c = true';                                    
                    }
                    if(!isTradeFair)
                        query +=' AND EUR_JB_Customer_Taxonomy__c in : taxonomySet';

                    if(requireTargetVolCheck.contains(rtDevName)){
                        ownerIdWithTargetVolSet = retrieveUserIdWithNoZeroTarget(objective.id);
                        query +=' AND OwnerId in : OwnerIdWithTargetVolSet';
                    }

                    query +=' limit 10000';

                    System.Debug('Query:' + query);
                    System.Debug('CTax:' + taxonomySet);
                    System.Debug('AccRT:' + deCTaxAccountRecordTypes);

                    List<EUR_CRM_Account__c> tempAccounts = (List<EUR_CRM_Account__c>) Database.query(query);                    
                    if(isTasting || isTradeFair){
                        for(EUR_CRM_Account__c euA :tempAccounts){
                                if(opAccountsSet.contains(euA.Id)){
                                    euAccounts.add(new euAccountsWrapper(euA, true));
                                }else{
                                    euAccounts.add(new euAccountsWrapper(euA, false));
                                }
                            }
                    }else{
                        euAccountList = new List<EUR_CRM_Account__c>();
                        for(EUR_CRM_Account__c euA :tempAccounts){
                            euAccountList.add(euA);
                        }
                       // euAccounts = retrieveEuAccountsWrapperList();
                    }
                    targets = [select id, EUR_CRM_BQS__r.name, EUR_CRM_Qty_Sell_in_Amount_Bottle__c from EUR_CRM_ObjPromo_Target__c  where   EUR_CRM_ObjPromo__c =: objective.id];
                    
                    if(targets == null || targets.size() == 0 ){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,  Label.EUR_CRM_No_Product_Selected + 'Is HEEREEEE'));
                        publishDisabled = true;
                    }

                }
        }
        if(euAccountList != null && euAccountList.size() > 9999){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,  Label.EUR_CRM_OP_Publish_Page_Limit));
                        
        }
        if(!isTasting && !isLeaflet && !isPROS && !isTradeFair&& !isDistributionDrive && !isWSPromoWithLeadTime && !isWSPromoWithoutLeadTime)
            verifyMissingTargets(objective.id, isSalesDrive,  EUR_CRM_OPTargetHelperClass.retrieveCustomerTaxonomySet(objective.id));
        if(isTradeFair){
            if(targets != null){
                for(EUR_CRM_ObjPromo_Target__c target : targets){
                    if(target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == null || target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == 0){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.EUR_CRM_Missing_Target_for_Product + target.EUR_CRM_BQS__r.name));
                    //publishDisabled = true;
                    }
                }
            }
            List<EUR_CRM_ObjPromo_Trade_Fair_Participant__c> participants = [select id from EUR_CRM_ObjPromo_Trade_Fair_Participant__c where EUR_CRM_Objectives_Promotions__c =: objective.id];
            if(participants == null || participants.size() == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.EUR_CRM_Missing_Participants)); publishDisabled = true;
                    }
                
        }
        initCon();
        system.debug('++ ID: ' + objective.id);
        system.debug('++ RT: ' + objective.RecordType.developername);
    }
    }
    
    public PageReference publish(){
        EUR_CRM_ObjPromo__c obj = [SELECT id, EUR_CRM_Status__c, EUR_CRM_Active_Start_Date__c,EUR_CRM_Override_CTax_PrepStartDate__c, EUR_CRM_Preparation_Start_Date__c FROM EUR_CRM_ObjPromo__c WHERE id = :objective.id];
        Savepoint sp = Database.setSavepoint();
            try{  
            RecordType opamrt = [select id from recordtype where sobjecttype='EUR_CRM_ObjPromo_Account_Mapping__c' and developername='EUR_CRM_DE_O_P_Account_Mapping'];
          
            List<EUR_CRM_ObjPromo_Account_Mapping__c> toDeleteOPAccounts = [select id from EUR_CRM_ObjPromo_Account_Mapping__c where EUR_CRM_ObjPromo__c =:objective.id];

            Boolean oPAccStatus = True;
            if(isWSPromoWithLeadTime && obj.EUR_CRM_Active_Start_Date__c > Date.Today()){
                oPAccStatus = False;
            }

            System.Debug('@@@isWSPromoWithLeadTime:' + isWSPromoWithLeadTime);
            System.Debug('@@@EUR_CRM_Active_Start_Date__c:' + obj.EUR_CRM_Active_Start_Date__c );
            System.Debug('@@@oPAccStatus:' + oPAccStatus);
            
            if(toDeleteOPAccounts!= null && toDeleteOPAccounts.size() > 0){
                 delete toDeleteOPAccounts;
             }
             
            List<EUR_CRM_ObjPromo_Account_Mapping__c> toInsertOPAccounts = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
             
           // euAccounts = retrieveEuAccountsWrapperList();
            
            for(euAccountsWrapper euAcc: retrieveEuAccountsWrapperList()){
                system.debug('+publishing account: '+ euAcc.euAccount.Id + ' === ' + objective.RecordType.developername + ' === ' + euAcc.isSelected);                
                if((isTasting || isTradeFair) && (euAcc.isSelected || selectedAccounts.contains(euAcc.euAccount.id))){
                    EUR_CRM_ObjPromo_Account_Mapping__c opAccount = new EUR_CRM_ObjPromo_Account_Mapping__c(EUR_CRM_Account__c = euAcc.euAccount.Id,EUR_CRM_ObjPromo__c = objective.id, EUR_CRM_Is_Active__c = oPAccStatus);
                    
                    if(opamrt!=null)
                        opAccount.recordtypeid = opamrt.id;
                    toInsertOPAccounts.add(opAccount);
                }else if(!isTasting && !isTradeFair){
                    EUR_CRM_ObjPromo_Account_Mapping__c opAccount = new EUR_CRM_ObjPromo_Account_Mapping__c(EUR_CRM_Account__c = euAcc.euAccount.Id,EUR_CRM_ObjPromo__c = objective.id, EUR_CRM_Is_Active__c =oPAccStatus);
                  
                    if(opamrt!=null)
                        opAccount.recordtypeid = opamrt.id;
                    toInsertOPAccounts.add(opAccount);
                }
            } 
            if(toInsertOPAccounts.size() < 10000)
                insert toInsertOPAccounts;
            else{ 
                Integer MAX_BATCHES = 5;
                Integer runningBatchJobs = [select count() from AsyncApexJob where JobType = 'BatchApex'
                  and status in ('Queued','Processing','Preparing') ];

                if(runningBatchJobs >= MAX_BATCHES) {
                  ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.WARNING, Label.EUR_CRM_No_Resources_Available
                  ));
                } else { 
                  ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.INFO, Label.EUR_CRM_OP_Publish_Batch_Error
                  ));
                    //create the postDMLS 
                    Database.executeBatch(new EUR_CRM_BatchDML_Utility(toInsertOPAccounts, 'EUR_CRM_ObjPromo_Account_Mapping__c', EUR_CRM_BatchDML_Utility.Operation.INSERT_RECORDS,true, null));
                    
                  publishDisabled = true;
                }
                //EUR_CRM_ObjPromo__c obj = new EUR_CRM_ObjPromo__c(id =objective.id,EUR_CRM_Status__c = ACTIVE ); 
                //update obj; 
                //return null;

            }
            
            //EUR_CRM_ObjPromo__c obj = new EUR_CRM_ObjPromo__c(id =objective.id,EUR_CRM_Status__c = ACTIVE ); 
            
            if(obj.EUR_CRM_Active_Start_Date__c == Date.today())
            {
                obj.EUR_CRM_Status__c = ACTIVE;
            }else if(obj.EUR_CRM_Active_Start_Date__c > Date.today()){
                If(isWSPromoWithLeadTime && obj.EUR_CRM_Preparation_Start_Date__c <= Date.today()){
                    obj.EUR_CRM_Status__c = INPREPARE;
                }else{
                    obj.EUR_CRM_Status__c = PUBLISHED;
                }
                
            }
            

            System.Debug('@@obj.EUR_CRM_Override_CTax_PrepStartDate__c:' + obj.EUR_CRM_Override_CTax_PrepStartDate__c);
            if(isLeaflet && obj.EUR_CRM_Override_CTax_PrepStartDate__c == false)
            {
                obj.EUR_CRM_Preparation_Start_Date__c = retrievePreparationDate();
            }
            update obj; 
        }catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + e) );
            return null;
        }
        
        PageReference pr = new PageReference('/' + objective.id);
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference unPublish(){
    
        List<EUR_CRM_ObjPromo_Account_Mapping__c> toDeleteOPAccounts = [select id,EUR_CRM_Account__c from EUR_CRM_ObjPromo_Account_Mapping__c where EUR_CRM_ObjPromo__c =:objective.id];
        Savepoint sp = Database.setSavepoint();
            try{ 
            if(toDeleteOPAccounts!= null && toDeleteOPAccounts.size() > 0) 
                delete toDeleteOPAccounts;
                objective.EUR_CRM_Status__c = DEACTIVATED;
                update objective;
         }catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '' + e) );
        }
        PageReference pr = new PageReference('/' + objective.id);
        pr.setRedirect(true);
        
        return pr;
    }
    
    public PageReference cancel(){
        PageReference pr = new PageReference('/' + objective.id);
        pr.setRedirect(true);
        return pr;
    }
    
    /*
      @Description: Wrapper Class for OFF Trade Tasting
      @History:     JUL.11.2014 - Created
    */
    public class euAccountsWrapper {
        public Boolean isSelected {get;set;}
        public EUR_CRM_Account__c euAccount {get;set;}

        public euAccountsWrapper(EUR_CRM_Account__c euAccount, Boolean isSelected){
            this.euAccount = euAccount;
            this.isSelected = isSelected;
        }
    }
    public List<euAccountsWrapper> retrieveEuAccountsWrapperList(){
        List<euAccountsWrapper> euAccountsTemp = new List<euAccountsWrapper>();
        if(isPROS){

            Set<Id> accSet= new Set<Id>();
            Set<String> images = new Set<String>();
            /* @@
            for(String image : (objective.EUR_CRM_PROS_Image_Level__c).split(';')){
                if(image != null && image != '') 
                    images.add(image);
            }
            */
            for(EUR_CRM_Pros_Segmentation__c pros : [select EUR_CRM_Account__c from  EUR_CRM_Pros_Segmentation__c where          
            EUR_CRM_Account__r.EUR_CRM_Image_Level_Name__c =: objective.EUR_CRM_PROS_Image_Level__c and            
            EUR_CRM_Group_Outlet_Type__r.eur_crm_group_outlet_name__c  =: objective.EUR_CRM_PROS_Group_Outlet__c]){
                accSet.add(pros.EUR_CRM_Account__c);
            }
            
            String query = 'select id from EUR_CRM_Territory__c where recordtype.developername = \'EUR_DE_Territory\' ';
            
            if(objective.EUR_CRM_Region__c != 'All Regions' && objective.EUR_CRM_Region__c != 'Alle Regionen'){
                String regionName =  objective.EUR_CRM_Region__c;
                query += ' and EUR_CRM_Region__r.name =:regionName';
            }
            String territoryName = objective.EUR_CRM_Territory__c;
            if(territoryName  != null && territoryName  != 'All Territories' && territoryName !='Alle Gabiete'){
                query += ' and name =:territoryName';
            }
            
            Set<Id> territorySet = new Set<Id>();
            for(EUR_CRM_Territory__c terr: (List<EUR_CRM_Territory__c >)Database.query(query)){
                territorySet.add(terr.id);
            } 
            for(EUR_CRM_Account__c euA :[select id, name,Ownerid from eur_crm_account__c 
                                        where  id in:accSet and EUR_CRM_Territory__c in: territorySet
                                        AND (EUR_CRM_Status_of_Customer__c != 'Inactive' AND EUR_CRM_Status_of_Customer__c != 'Deleted')]){
                euAccounts.add(new euAccountsWrapper(euA, false));
                euAccountsTemp.add(new euAccountsWrapper(euA, false));
            }  
         }else{
                    String query = 'Select Id, name,Ownerid From EUR_CRM_Account__c where ';
                    query += ' recordtype.developername in : deCTaxAccountRecordTypes';
                    query += ' AND EUR_CRM_Status_of_Customer__c != \'Inactive\' AND EUR_CRM_Status_of_Customer__c != \'Deleted\'';
                    if(isTasting){
                        query +=' AND EUR_CRM_Outlet_suitable_for_tastings__c = \'Yes\''; 
                    }else if(isTradeFair){
                        query +=' AND EUR_CRM_Is_Trade_Fair_Location__c = true';                                    
                    }
                    if(!isTradeFair)
                        query +=' AND EUR_JB_Customer_Taxonomy__c in : taxonomySet'; 
                    List<EUR_CRM_Account__c> tempAccounts = (List<EUR_CRM_Account__c>) Database.query(query);                    
                        for(EUR_CRM_Account__c euA :tempAccounts){
                            if(opAccountsSet.contains(euA.Id)){
                                euAccountsTemp.add(new euAccountsWrapper(euA, true));
                            }else{
                                euAccountsTemp.add(new euAccountsWrapper(euA, false));
                            }
                        }
         }

         return euAccountsTemp;
    }
    public Date retrievePreparationDate(){
        Decimal weeks = 0;
        for(EUR_CRM_Customer_Taxonomy__c custTax : [select id,EUR_CRM_Leaflet_Campaign_Lead_Time_Weeks__c from EUR_CRM_Customer_Taxonomy__c where id in(select EUR_CRM_Customer_Taxonomy__c from 
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c where EUR_CRM_ObjPromo__c =: objective.id)]){
            if(custTax.EUR_CRM_Leaflet_Campaign_Lead_Time_Weeks__c != null && custTax.EUR_CRM_Leaflet_Campaign_Lead_Time_Weeks__c > weeks){
                weeks = custTax.EUR_CRM_Leaflet_Campaign_Lead_Time_Weeks__c;
            }
        }
        
        if(objective.EUR_CRM_Active_Start_Date__c == null) 
            return null;
        Date d = objective.EUR_CRM_Active_Start_Date__c;
        return d.addDays((Integer) (weeks * (-7)));
    }
    
    
// -- VALIDATE Objectives/
/*
    List of targets
    bqs
        product target only
    targets
        product + user + target
*/
    public Boolean isReady{get;set;}
    public List<String> validationMessages;

    public class ProductUser{
        public User targetOwner {get;set;}
        public EUR_CRM_SKU__c sku  {get;set;}
        public EUR_CRM_Size__c bqs{get;set;}       
    }

    public Set<Id> retrieveUserIdWithNoZeroTarget(Id opId){
        Set<Id> UserIds = New Set<Id>();

        for(EUR_CRM_ObjPromo_Target__c target :[select EUR_CRM_Target_Owner__c

                                                from EUR_CRM_ObjPromo_Target__c 
                                                where recordtype.developername = 'EUR_DE_SR_Volume_Target' 
                                                AND (EUR_CRM_Qty_Sell_in_Amount_Bottle__c > 0 OR EUR_CRM_Qty_Sell_in_Amount_Carton__c > 0 OR EUR_CRM_Qty_Sell_in_Amount_Display__c > 0 OR
                                                       EUR_CRM_Quantity__c > 0 OR EUR_CRM_Target_No_of_Display__c > 0 OR EUR_CRM_Target_No_of_Display_per_Brand__c > 0 OR EUR_CRM_Target_Quantity_Listing__c > 0 OR EUR_CRM_Target_Quantity_People__c > 0 OR
                                                       EUR_CRM_Target_Quantity_Promo_Kits__c > 0 OR EUR_CRM_Target_Quantity_Spyders__c > 0)
                                                and EUR_CRM_ObjPromo__c =: opId]){
        
            UserIds.add(target.EUR_CRM_Target_Owner__c);
        }

        return UserIds;
    }


    public void verifyMissingTargets(Id opId, Boolean isSalesDrive, Set<Id> taxonomyIds){

        Map<String,ProductUser> comboMap = new Map<String, ProductUser>();
        List<User> userList = new List<User>();
        List<EUR_CRM_Account__c> euAccounts = EUR_CRM_OPTargetHelperClass.retrieveAccountsByTaxonomy(taxonomyIds);
        List<User> regionalManagers = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersRegionalLevel(euAccounts);
       // List<User> salesAgency = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSalesAgencyLevel(taxonomyIds);       
        validationMessages = new List<String>();
        userList.addAll(regionalManagers);
        if(isSalesDrive)
         userList.addAll(EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSalesAgencyLevel(taxonomyIds));
        
        for(User regionManager: regionalManagers){
            List<User> targetOwners = EUR_CRM_OPTargetHelperClass.retrieveTargetOwnersSRLevel(euAccounts,  regionManager.id);
            userList.addAll(targetOwners);      
        }
        // get the targets
        
        for(EUR_CRM_ObjPromo_Target__c target :[select EUR_CRM_SKU__r.name,  EUR_CRM_SKU__c, EUR_CRM_BQS__c, EUR_CRM_BQS__r.name from EUR_CRM_ObjPromo_Target__c 
            where recordtype.developername = 'EUR_DE_Objective_Volume_Target'
                and EUR_CRM_ObjPromo__c =: opId]){
            for(User u : userList){
                String product = isSalesDrive ? target.EUR_CRM_SKU__c : target.EUR_CRM_BQS__c;
                String key = product + u.id;
                ProductUser pu = new ProductUser();
                pu.targetOwner = u; 
                if(isSalesDrive)
                    pu.sku = target.EUR_CRM_SKU__r;
                else
                    pu.bqs = target.EUR_CRM_BQS__r;
                comboMap.put(key,pu);
            }
        }
        
        Map<String, EUR_CRM_ObjPromo_Target__c> existingTargets = new MAp<String, EUR_CRM_ObjPromo_Target__c>();

        System.Debug('@@@opId:'+opId);
        System.Debug('@@@EUR_DE_Objective_Volume_Target:'+ [select EUR_CRM_Qty_Sell_in_Amount_Bottle__c, EUR_CRM_SKU__r.name,  EUR_CRM_Target_Owner__c, EUR_CRM_SKU__c, EUR_CRM_BQS__c, EUR_CRM_BQS__r.name from EUR_CRM_ObjPromo_Target__c 
                where recordtype.developername != 'EUR_DE_Objective_Volume_Target'
                and EUR_CRM_ObjPromo__c =: opId]);
        
        //get existing targets
        for(EUR_CRM_ObjPromo_Target__c target : [select EUR_CRM_Qty_Sell_in_Amount_Bottle__c, EUR_CRM_SKU__r.name,  EUR_CRM_Target_Owner__c, EUR_CRM_SKU__c, EUR_CRM_BQS__c, EUR_CRM_BQS__r.name from EUR_CRM_ObjPromo_Target__c 
                where recordtype.developername != 'EUR_DE_Objective_Volume_Target'
                and EUR_CRM_ObjPromo__c =: opId]){
            String product = isSalesDrive ? target.EUR_CRM_SKU__c : target.EUR_CRM_BQS__c;
            String key = product + target.EUR_CRM_Target_Owner__c;
            existingTargets.put(key, target);
        }

        //Missinglist
       /*
        if(comboMap.size() == 0){
            //validationMessages.add('No Products Selected!');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,  'No Product(s) Selected.'));
            return;
        }
        */
        //verify

        for(String key : comboMap.keySet()){
            EUR_CRM_ObjPromo_Target__c target = existingTargets.get(key);
            if(target == null || target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == null || target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == 0 || target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c < 0){
                isReady = false;
                ProductUser pu = comboMap.get(key);
                String message = Label.EUR_CRM_Missing_Target_for_User+ pu.targetOwner.name + ' ';
                message += Label.EUR_CRM_For_Product;
                message += isSalesDrive  ?     pu.sku.name :  pu.bqs.name;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, message));
                publishDisabled = false;
            }
        }  
    }
    Set<Id> selectedAccounts = new Set<Id>();
    
    private List<EUR_CRM_Account__c> retrieveAccounts(){
        System.Debug('retrieveAccounts');
        System.Debug('euAccounts:' + euAccounts);
        System.Debug('euAccountList:' + euAccountList);
        //System.Debug('accounts' + accounts);


        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        if(isTasting || isTradeFair){
            for(euAccountsWrapper aWrap : euAccounts){
                accounts.add(aWrap.euAccount);
                if(aWrap.isSelected)
                    selectedAccounts.add(aWrap.euAccount.id);
            }
        }else{
            return euAccountList;
        }
        return accounts;
    }     
    public ApexPages.StandardSetController con { 
        get {
            if(con == null) { 
               con = new ApexPages.StandardSetController(retrieveAccounts());               
               con.setPageSize(50);
            }
            return con;
        }
        set; 
    }  
    public void initCon(){
        con = new ApexPages.StandardSetController(retrieveAccounts()); 
        con.setPageSize(50); 
    }
    public List<euAccountsWrapper> getWrapAccounts(){

        List<euAccountsWrapper> rows = new List<euAccountsWrapper>();

        for(sObject r : this.con.getRecords()){
            EUR_CRM_Account__c  a = (EUR_CRM_Account__c)r;

            euAccountsWrapper row = new euAccountsWrapper(a,false);
            if(this.selectedAccounts.contains(a.Id)){
                row.IsSelected=true;
            }
            else{
                row.IsSelected=false;
            }
            rows.add(row);
        }

        return rows;

    }
    public void doNext(){

        if(this.con.getHasNext())
            this.con.next();

    }

    public void doPrevious(){

        if(this.con.getHasPrevious())
            this.con.previous();

    } 
    public void first() {
         con.first();
     }

     // returns the last page of records
     public void last() {
         con.last();
     }
    public Boolean getHasPrevious(){

        return this.con.getHasPrevious();

    }

    /*
    *   return whether next page exists
    */
    public Boolean getHasNext(){

        return this.con.getHasNext();

    }
    public Integer getPageNumber(){

        return this.con.getPageNumber();

    }


    public Integer getTotalPages(){

        Decimal totalSize = this.con.getResultSize();
        Decimal pageSize = this.con.getPageSize();

        Decimal pages = totalSize/pageSize;

        return (Integer)pages.round(System.RoundingMode.CEILING);
    }// returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }
     public Integer getPageSize(){
     return con.getPageSize() != null ? con.getPageSize() : 0;
     }
     public Integer getRecordSize(){
      return con.getResultSize() != null ? con.getResultSize() : 0;
     }
     public String contextItem{get;set;}
    public void doSelectItem(){
    
        this.selectedAccounts.add(this.contextItem);
    
    }
    
    public void doDeselectItem(){
    
        this.selectedAccounts.remove(this.contextItem);
    
    }
    
    public Boolean getHasSelectedAccounts(){
        return selectedAccounts.size() > 0;
    }
    
    public void selectAll(){
        for(euAccountsWrapper  aWrap : getWrapAccounts()){
            selectedAccounts.add(aWrap.euAccount.id);
        }
    }
    public void deSelectAll(){
        for(euAccountsWrapper  aWrap : getWrapAccounts()){
            selectedAccounts.remove(aWrap.euAccount.id);
        }
    }

}