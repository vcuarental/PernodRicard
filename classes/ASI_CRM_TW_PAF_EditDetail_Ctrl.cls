/*Filename:        ASI_CRM_TW_PAF_EditDetail_Ctrl.cls
* Author:          Twinkle LI (Introv Limited)
* Purpose:         Controller Class for managing Contract P&L details 
* Created Date:    2016/10/19
*
* History
* -----------------------------------------------------------------------------
*/
public without sharing class ASI_CRM_TW_PAF_EditDetail_Ctrl{
    //getcurrent user language
    public String userLanguage {set; get;}
    public String KeyLimitedSKUval {set; get;}

    public Boolean nonEditable {set; get;}
    
    //get header info.
    public id preAppFormId {set; get;}
    public List<ASI_HK_CRM_Pre_Approval_Form__c> preAppForm {set; get;}
    
    //get child Outlets info.
    public List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> listQueryPreAppFormCustomer {set; get;}
    
    //get capacity info.
    public Map<String, ASI_HK_CRM_Product_Category__c> mapPC {set; get;}
    public List<ASI_CRM_CalculatedSalesVolume__c> listQueryCapacity {set; get;}
    public Map<Integer, Map<String, ASI_CRM_CalculatedSalesVolume__c>> mapCapacity {set; get;}
    public Integer intMapCapacitySize {set; get;}
    
    //get detail items info.
    public Integer intRowid {set;get;}
    public String PAFItemType {set;get;}
    public List<ASI_HK_CRM_Pre_Approval_Form_Item__c> listQueryPreAppFormItem {set; get;}
    
    public Map<integer, ASI_HK_CRM_Pre_Approval_Form_Item__c> mapPAFItem_Variable {set;get;}
    public Map<integer, ASI_HK_CRM_Pre_Approval_Form_Item__c> mapPAFItem_Conditional {set;get;}
    public Map<integer, ASI_HK_CRM_Pre_Approval_Form_Item__c> mapPAFItem_Fixed {set;get;}
    public Map<integer, ASI_HK_CRM_Pre_Approval_Form_Item__c> mapPAFItem_Variable_Global {set;get;}
    public List<ASI_HK_CRM_Pre_Approval_Form_Item__c> listPAFItem_PGCosts {set;get;}
    
    public Integer intIndexPAFItem_Variable {set;get;}   
    public Integer intIndexPAFItem_Conditional {set;get;} 
    public Integer intIndexPAFItem_Fixed {set;get;} 
    public Integer intIndexPAFItem_Variable_Global{set;get;} 
    
    public List<ASI_HK_CRM_Pre_Approval_Form_Item__c> listDeletedPAFItem_Variable {set;get;}
    public List<ASI_HK_CRM_Pre_Approval_Form_Item__c> listDeletedPAFItem_Conditional {set;get;}
    public List<ASI_HK_CRM_Pre_Approval_Form_Item__c> listDeletedPAFItem_Fixed {set;get;}
    public List<ASI_HK_CRM_Pre_Approval_Form_Item__c> listDeletedPAFItem_Variable_Global {set;get;}
    public List<ASI_CRM_CalculatedSalesVolume__c> listDeletedCapacity {set;get;}
    
    public List<SelectOption> listMachnicPicklist {set;get;}
    public List<SelectOption> listItemGroupPicklist {set;get;}
    
    Set<Id> setItmGroupId = new Set<Id>();
    Map<Id, ASI_MFM_Item_Group__c> mapItmGroup = new Map<Id, ASI_MFM_Item_Group__c>();
    
    public Map<Integer, String> mapCompetitorLable {set;get;}
    
    public List<ASI_CRM_AccountsAdditionalField__c> listSupplier {set;get;}
    public Map<Id, ASI_CRM_AccountsAdditionalField__c> mapSupplier {set;get;}
    //public List<SelectOption> supplierList {set;get;}
    public List<String> selectedSupplier {get;set;}
    public String accountRegion {get;set;}    
    
    public Map<String, Boolean> mapBuckets {set;get;}
    public Integer buckets { get; set; }
        
    public List<SelectOption> SupplierList {
        get{
            listSupplier = [SELECT id, Name, ASI_CRM_Account__c, ASI_CRM_Account__r.ASI_KOR_Legal_Name__c FROM ASI_CRM_AccountsAdditionalField__c 
            WHERE RecordType.DeveloperName In ('ASI_CRM_TW_Outlet', 'ASI_CRM_TW_KeyAccount', 'ASI_CRM_TW_Wholesaler')
            AND ASI_CRM_Is_Supplier__c = true
            AND ASI_CRM_Account__r.ASI_TH_CRM_Region__c = :accountRegion
            ORDER BY Name];
            
            List<SelectOption> supplierOptions = new List<SelectOption>();
            For(ASI_CRM_AccountsAdditionalField__c s : listSupplier){
                /*
                if(s.ASI_CRM_Account__r.ASI_KOR_Legal_Name__c != null)
                    supplierOptions.add(new SelectOption(s.ASI_CRM_Account__c, s.ASI_CRM_Account__r.ASI_KOR_Legal_Name__c));
                else
                */
                    supplierOptions.add(new SelectOption(s.ASI_CRM_Account__c, s.Name));
            }
            
            return supplierOptions;
        }
    } 
    
    //controller
    /*public ASI_CRM_TW_OutletContractDetailEdit_Ctrl(ApexPages.StandardSetController controller) {
        preAppFormId = ApexPages.currentPage().getParameters().get('id');
        userLanguage = UserInfo.getLanguage();
        
        init(); //retrieve records info. for editing  
    }*/
    
    public ASI_CRM_TW_PAF_EditDetail_Ctrl(ApexPages.StandardController controller) {
        preAppFormId = ApexPages.currentPage().getParameters().get('id');
        userLanguage = UserInfo.getLanguage();
        
        init(); //retrieve records info. for editing 
    }
    
    public void init(){
        mapCapacity = new Map<Integer, Map<String, ASI_CRM_CalculatedSalesVolume__c>>();
        mapPAFItem_Variable = new Map<integer, ASI_HK_CRM_Pre_Approval_Form_Item__c>();
        mapPAFItem_Conditional = new Map<integer, ASI_HK_CRM_Pre_Approval_Form_Item__c>();
        mapPAFItem_Fixed = new Map<integer, ASI_HK_CRM_Pre_Approval_Form_Item__c>();
        mapPAFItem_Variable_Global = new Map<integer, ASI_HK_CRM_Pre_Approval_Form_Item__c>();
        mapCompetitorLable = new Map<Integer, String>();
        
        intIndexPAFItem_Variable = 0;
        intIndexPAFItem_Conditional = 0;
        intIndexPAFItem_Fixed = 0;
        intIndexPAFItem_Variable_Global = 0;
        
        listDeletedPAFItem_Variable = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
        listDeletedPAFItem_Conditional = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
        listDeletedPAFItem_Fixed = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
        listDeletedPAFItem_Variable_Global = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
        listDeletedCapacity = new list<ASI_CRM_CalculatedSalesVolume__c>();
        
        listMachnicPicklist = new List<SelectOption>();
        listItemGroupPicklist = new List<SelectOption>();
        listItemGroupPicklist.add(new SelectOption('',''));
       
        nonEditable = false;
        
        selectedSupplier = new List<String>();
        mapBuckets = new Map<String, Boolean>();
        
        system.debug('PAF Id: '+preAppFormId);
        if(preAppFormId != NULL){
            preAppForm = [SELECT id, Name, ASI_HK_CRM_PAF_Status__c, ASI_CRM_Commitment_No__c, ASI_HK_CRM_PAF_Customer__c, 
                          ASI_HK_CRM_PAF_Start_Date__c, ASI_HK_CRM_PAF_End_Date__c, ASI_CRM_Valid_Invoice__c, ASI_CRM_Region__c, 
                          ASI_CRM_Outlet_Type__c, ASI_CRM_Outlet_Grade__c, ASI_CRM_Channel__c, ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c, 
                          ASI_CRM_Sub_Channel__c, ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c, ASI_CRM_Sales_Representative__c,
                          ASI_CRM_Outlet_Image__c, ASI_CRM_Sales_Potential__c, ASI_HK_CRM_PAF_Customer__r.ASI_TH_CRM_Region__c,
                          ASI_CRM_TW_Supplier__c, ASI_CRM_Supplier_Id__c
                          FROM ASI_HK_CRM_Pre_Approval_Form__c
                          WHERE id =: preAppFormId LIMIT 1];
                          
            if(this.preAppForm.size() > 0 && this.preAppForm[0] != NULL){
                accountRegion = preAppForm[0].ASI_HK_CRM_PAF_Customer__r.ASI_TH_CRM_Region__c;
                
                //get list of Supplier
                listSupplier = [SELECT id, Name, ASI_CRM_Account__c, ASI_CRM_Account__r.ASI_KOR_Legal_Name__c FROM ASI_CRM_AccountsAdditionalField__c 
                WHERE RecordType.DeveloperName In ('ASI_CRM_TW_Outlet', 'ASI_CRM_TW_KeyAccount', 'ASI_CRM_TW_Wholesaler')
                AND ASI_CRM_Is_Supplier__c = true
                AND ASI_CRM_Account__r.ASI_TH_CRM_Region__c = :accountRegion
                ORDER BY Name];
                
                mapSupplier = new Map<Id, ASI_CRM_AccountsAdditionalField__c>();
                for(ASI_CRM_AccountsAdditionalField__c sup : listSupplier){
                    mapSupplier.put(sup.ASI_CRM_Account__c, sup);
                }
                system.debug('Map of Suppliers: '+mapSupplier);
                
                //retrieve supplier values
                List<String> tempSelectedSupplier = new List<String>();
                if(!String.IsEmpty(preAppForm[0].ASI_CRM_Supplier_Id__c)){
                    String[] tmpString = preAppForm[0].ASI_CRM_Supplier_Id__c.split('，');
                    For(String s : tmpString){
                        tempSelectedSupplier.add(s);
                    }
                }
                selectedSupplier = tempSelectedSupplier;
                
                
                updateBucketValidity();
                
                if(this.preAppForm[0].ASI_HK_CRM_PAF_Status__c != 'Draft')
                    nonEditable = true;
            
                //get mechanics picklist value
                for(ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mechanic : [SELECT id, Name FROM ASI_HK_CRM_Pre_Approval_Form_Mechanic__c WHERE RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics') ORDER BY Name]){
                    listMachnicPicklist.add(new SelectOption(mechanic.id, mechanic.Name));
                }
                
                //get account Channel & Sub-Channel for retrieve Item Group
                String strCh = preAppForm[0].ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c + ';'+ preAppForm[0].ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c;
                //get item group picklist value
                ASI_CRM_TW_ItemGroup_UtilityCls utilityCls = new ASI_CRM_TW_ItemGroup_UtilityCls();
                //for(ASI_MFM_Item_Group__c itm : [SELECT id, Name FROM ASI_MFM_Item_Group__c WHERE RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_MFM_Item_Group__cASI_MFM_TW_Item_Group') AND ASI_CRM_Active__c = TRUE])                

                for(ASI_MFM_Item_Group__c itm : utilityCls.getItemGroup(strCh)){
                    listItemGroupPicklist.add(new SelectOption(itm.id, itm.Name));
                }
            
                //Outlet/Child
                listQueryPreAppFormCustomer = [SELECT id, Name, ASI_CRM_HK_Customer__c, ASI_CRM_HK_Customer__r.Name, ASI_CRM_JDE_Account_Number__c
                                           FROM ASI_CRM_HK_Pre_Approval_Form_Customer__c
                                           WHERE RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_CRM_HK_Pre_Approval_Form_Customer__cASI_CRM_TW_Pre_Approval_Form_Customer') AND ASI_CRM_HK_Pre_Approval_Form__c =: preAppFormId];
                
                //Capcity
                listQueryCapacity = [SELECT id, Name, ASI_CRM_Competitor__c, ASI_CRM_ProductCategory__c, ASI_CRM_ProductCategory__r.Name, ASI_CRM_ProductCategory__r.ASI_HK_CRM_Category_Code__c, ASI_CRM_Bottle__c
                                FROM ASI_CRM_CalculatedSalesVolume__c
                                WHERE RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_CRM_CalculatedSalesVolume__cASI_CRM_TW_Capacity') AND ASI_CRM_Pre_Approval_Form__c =: preAppFormId AND ASI_CRM_Company__c = 'Competitor' ORDER BY ASI_CRM_ProductCategory__r.ASI_HK_CRM_Sequence__c];
                
                //map existing capacity records by Competitor and Product Category
                Map<String, ASI_CRM_CalculatedSalesVolume__c> mapExistingCapacity = new Map<String, ASI_CRM_CalculatedSalesVolume__c>();
                for(ASI_CRM_CalculatedSalesVolume__c cap : listQueryCapacity){
                    if(cap.ASI_CRM_Competitor__c != NULL && cap.ASI_CRM_ProductCategory__c != NULL)
                        mapExistingCapacity.put(cap.ASI_CRM_Competitor__c+''+cap.ASI_CRM_ProductCategory__c, cap);
                }
                system.debug('mapExistingCapacity: '+mapExistingCapacity);
                
                //map of Product category id and Name
                List<ASI_HK_CRM_Product_Category__c> listPC = [SELECT id, Name, ASI_HK_CRM_Category_Code__c, ASI_HK_CRM_Sequence__c FROM ASI_HK_CRM_Product_Category__c WHERE RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_HK_CRM_Product_Category__cASI_CRM_TW_Product_Category') AND ASI_CRM_For_PAF__c = TRUE ORDER BY ASI_HK_CRM_Sequence__c ASC];
                system.debug(listPC);
                
                //map Product Category by Sequence (display sequence) @20170302, user must enter Sequence for PAF in Product Category
                mapPC = new Map<String, ASI_HK_CRM_Product_Category__c>();
                for(ASI_HK_CRM_Product_Category__c pc : listPC){
                    mapPC.put(String.valueOf(pc.ASI_HK_CRM_Sequence__c), pc);
                }
                //mapPC = new Map<id, ASI_HK_CRM_Product_Category__c>([SELECT id, Name, ASI_HK_CRM_Category_Code__c FROM ASI_HK_CRM_Product_Category__c WHERE RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_HK_CRM_Product_Category__cASI_CRM_TW_Product_Category') AND ASI_CRM_For_PAF__c = TRUE ORDER BY ASI_HK_CRM_Sequence__c]);              
                system.debug('TW Product Categories: '+mapPC);
                
                //get Competitor list
                Schema.DescribeFieldResult fieldResult = ASI_CRM_CalculatedSalesVolume__c.ASI_CRM_Competitor__c.getDescribe();
                List<Schema.PicklistEntry> listCompetitorsPickList = fieldResult.getPicklistValues();
                Integer intSequence = 1;
                
                //pre-defined Capcity Matrix by Product Category and Competitor, map by Product Category Code and then by Competitor
                for(Schema.PicklistEntry competitor : listCompetitorsPickList){
                    Map<String, ASI_CRM_CalculatedSalesVolume__c> mapCSbyPC = new Map<String, ASI_CRM_CalculatedSalesVolume__c>();
                    for(String pcSequence : mapPC.KeySet()){
                        if(mapExistingCapacity.get(competitor.getLabel()+''+mapPC.get(pcSequence).Id) != NULL){
                            mapCSbyPC.put(pcSequence, mapExistingCapacity.get(competitor.getLabel()+''+mapPC.get(pcSequence).Id));
                            system.debug('#mapCSbyPC: '+mapCSbyPC);
                        }
                        else{
                            ASI_CRM_CalculatedSalesVolume__c objCS = new ASI_CRM_CalculatedSalesVolume__c();
                            objCS.recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_CalculatedSalesVolume__cASI_CRM_TW_Capacity');
                            objCS.ASI_CRM_Pre_Approval_Form__c = preAppFormId;
                            objCS.ASI_CRM_Company__c = 'Competitor';
                            objCS.ASI_CRM_ProductCategory__c = mapPC.get(pcSequence).id;
                            objCS.ASI_CRM_Competitor__c = competitor.getLabel();
                            
                            mapCSbyPC.put(pcSequence, objCS);
                       }
                    }
                    mapCapacity.put(intSequence, mapCSbyPC);
                    mapCompetitorLable.put(intSequence, competitor.getLabel());
                    intSequence++;
                }
                system.debug('Capacity: '+mapCapacity);
                system.debug('Competitors: '+mapCompetitorLable);
                intMapCapacitySize = mapCapacity.size();
                
                //Pre-Approval Form Items
                listQueryPreAppFormItem = [SELECT id, Name, RecordTypeId, ASI_HK_CRM_Pre_Approval_Form_Lookup__c, ASI_CRM_Cash_or_FOC__c, ASI_CRM_AD_or_AP__c, 
                                           ASI_CRM_Contracted_Item__c, ASI_CRM_FOC_Item__c, ASI_CRM_Cash_Per_Bottle_w_VAT__c, ASI_CRM_Expenses_Product__c, ASI_CRM_FOC_Volume__c, 
                                           ASI_CRM_Q1_hrs__c, ASI_CRM_Q2_hrs__c, ASI_CRM_Q3_hrs__c, ASI_CRM_Q4_hrs__c, ASI_CRM_Sub_Total_hrs__c, ASI_CRM_Cost_Hr_w_VAT__c, 
                                           ASI_CRM_Total_PG_Cost__c, ASI_CRM_Cash_Amounts_w_VAT__c, ASI_HK_CRM_Target_Volume_Qty__c, ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c, 
                                           ASI_HK_CRM_FOC_Free_Bottle_Option_1__c, ASI_HK_CRM_Mechanic__c, ASI_CRM_Mechanic_Detail__c, ASI_CRM_Contracted_Item__r.ASI_CRM_Sub_Brand_Code__c,
                                           ASI_CRM_Target_Volume_Qty_P1__c, ASI_CRM_Target_Volume_Qty_P2__c, ASI_CRM_Target_Volume_Qty_P3__c, ASI_CRM_Target_Volume_Qty_P4__c,
                                           ASI_CRM_Target_Volume_Qty_P5__c, ASI_CRM_Target_Volume_Qty_P6__c, ASI_CRM_Target_Volume_Qty_P7__c, ASI_CRM_Target_Volume_Qty_P8__c,
                                           ASI_CRM_Target_Volume_Qty_P9__c, ASI_CRM_Target_Volume_Qty_P10__c, ASI_CRM_Target_Volume_Qty_P11__c, ASI_CRM_Target_Volume_Qty_P12__c,
                                           ASI_CRM_FOC_Volume_P1__c, ASI_CRM_FOC_Volume_P2__c, ASI_CRM_FOC_Volume_P3__c, ASI_CRM_FOC_Volume_P4__c, ASI_CRM_FOC_Volume_P5__c,
                                           ASI_CRM_FOC_Volume_P6__c, ASI_CRM_FOC_Volume_P7__c, ASI_CRM_FOC_Volume_P8__c, ASI_CRM_FOC_Volume_P9__c, ASI_CRM_FOC_Volume_P10__c,
                                           ASI_CRM_FOC_Volume_P11__c, ASI_CRM_FOC_Volume_P12__c, ASI_CRM_Cash_Amounts_w_VAT_P1__c, ASI_CRM_Cash_Amounts_w_VAT_P2__c, 
                                           ASI_CRM_Cash_Amounts_w_VAT_P3__c, ASI_CRM_Cash_Amounts_w_VAT_P4__c, ASI_CRM_Cash_Amounts_w_VAT_P5__c, ASI_CRM_Cash_Amounts_w_VAT_P6__c, 
                                           ASI_CRM_Cash_Amounts_w_VAT_P7__c, ASI_CRM_Cash_Amounts_w_VAT_P8__c, ASI_CRM_Cash_Amounts_w_VAT_P9__c, ASI_CRM_Cash_Amounts_w_VAT_P10__c, 
                                           ASI_CRM_Cash_Amounts_w_VAT_P11__c, ASI_CRM_Cash_Amounts_w_VAT_P12__c, ASI_CRM_Reward_Method__c, ASI_CRM_FOC_with_Orders__c,
                                           ASI_CRM_Key_Limited_SKU__c, ASI_CRM_FOC_Free_Bottle__c, ASI_CRM_FOC_Buy_Bottle__c                                           
                                          FROM ASI_HK_CRM_Pre_Approval_Form_Item__c
                                      WHERE (RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment') OR
                                             RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment') OR
                                             RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment') OR
                                             RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment_Global_Promotion') OR
                                             RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_PG_Costs'))
                                            AND ASI_HK_CRM_Pre_Approval_Form_Lookup__c =: preAppFormId ORDER BY id ]; //ASI_CRM_Contracted_Item__r.ASI_CRM_Product_Category_Sequence__c ASC, ASI_CRM_Contracted_Item__r.ASI_MFM_Item_Group_Code__c ASC
                
                for(ASI_HK_CRM_Pre_Approval_Form_Item__c pafItem : listQueryPreAppFormItem){
                    if(pafItem.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment')){
                        mapPAFItem_Variable.put(intIndexPAFItem_Variable++, pafItem);
                    }
                    else if(pafItem.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment')){
                        mapPAFItem_Conditional.put(intIndexPAFItem_Conditional++, pafItem);
                    }
                    else if(pafItem.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment')){
                        mapPAFItem_Fixed.put(intIndexPAFItem_Fixed++, pafItem);
                    }
                    else if(pafItem.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment_Global_Promotion')){
                        mapPAFItem_Variable_Global.put(intIndexPAFItem_Variable_Global++, pafItem);
                    }
                    else if(pafItem.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_PG_Costs')){
                        listPAFItem_PGCosts = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>(); 
                        listPAFItem_PGCosts.add(pafItem);
                    }
                }
                
                if(listPAFItem_PGCosts == NULL || listPAFItem_PGCosts.size() <= 0){
                    listPAFItem_PGCosts = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
                    listPAFItem_PGCosts.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c
                        (ASI_HK_CRM_Pre_Approval_Form_Lookup__c = preAppFormId,
                        ASI_CRM_Cost_Hr_w_VAT__c = 550,
                        RecordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_PG_Costs')));
                }
                
                system.debug('Variable: '+mapPAFItem_Variable);
                system.debug('Conditional: '+mapPAFItem_Conditional);
                system.debug('Fixed: '+mapPAFItem_Fixed);
                system.debug('Variable Global: '+mapPAFItem_Variable_Global);
                system.debug('PGCosts: '+listPAFItem_PGCosts);
            }
        }
    }
    
    
    public void updateBucketValidity(){
        
        //retrieve contract period for mapping buckets
        mapBuckets.put('P1', false);
        mapBuckets.put('P2', false);
        mapBuckets.put('P3', false);
        mapBuckets.put('P4', false);
        mapBuckets.put('P5', false);
        mapBuckets.put('P6', false);
        mapBuckets.put('P7', false);
        mapBuckets.put('P8', false);
        mapBuckets.put('P9', false);
        mapBuckets.put('P10', false);
        mapBuckets.put('P11', false);
        mapBuckets.put('P12', false);
        
        Date dateBuckets = preAppForm[0].ASI_HK_CRM_PAF_Start_Date__c;
        Integer dateBucketInt = preAppForm[0].ASI_HK_CRM_PAF_Start_Date__c.year()*100+ preAppForm[0].ASI_HK_CRM_PAF_Start_Date__c.month();
        Integer endBucketInt = preAppForm[0].ASI_HK_CRM_PAF_End_Date__c.year()*100+ preAppForm[0].ASI_HK_CRM_PAF_End_Date__c.month();
        
        Integer intIndex = 1;
        
        while(dateBucketInt <= endBucketInt){
            mapBuckets.put('P'+intIndex, true);
            dateBuckets = dateBuckets.addMonths(1);
            dateBucketInt = dateBuckets.year()*100+ dateBuckets.month();
            intIndex++;
        }
        
        buckets = 0;
        for (Boolean b : mapBuckets.values()) {
            if (b) {
                buckets++;
            }
        }
        
        system.debug('Map of Buckets: '+mapBuckets);
    }
    
    public void clearTargetVolumeQty(){
        if(intRowid != NULL){
            if(mapPAFItem_Variable.get(intRowid) != NULL){
                ASI_HK_CRM_Pre_Approval_Form_Item__c objPAFItem_Variable = mapPAFItem_Variable.get(intRowid);
                objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P1__c = null;
                objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P2__c = null;
                objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P3__c = null;
                objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P4__c = null;
                objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P5__c = null;
                objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P6__c = null;
                objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P7__c = null;
                objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P8__c = null;
                objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P9__c = null;
                objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P10__c = null;
                objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P11__c = null;
                objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P12__c = null;
            }
        }
    }

    public void clearAllTargetVolumeQty(){
        for(ASI_HK_CRM_Pre_Approval_Form_Item__c objPAFItem_Variable: mapPAFItem_Variable.values())
        {
            objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P1__c = null;
            objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P2__c = null;
            objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P3__c = null;
            objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P4__c = null;
            objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P5__c = null;
            objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P6__c = null;
            objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P7__c = null;
            objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P8__c = null;
            objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P9__c = null;
            objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P10__c = null;
            objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P11__c = null;
            objPAFItem_Variable.ASI_CRM_Target_Volume_Qty_P12__c = null;
        }
    }

    public void addPAFItems(){
        ASI_HK_CRM_Pre_Approval_Form_Item__c objPAFItem = new ASI_HK_CRM_Pre_Approval_Form_Item__c();
        if(PAFItemType == 'variable'){
            objPAFItem = new ASI_HK_CRM_Pre_Approval_Form_Item__c
                (ASI_HK_CRM_Pre_Approval_Form_Lookup__c = preAppFormId, 
                RecordTypeId=Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment'),
                ASI_CRM_AD_or_AP__c = 'A&D');
            mapPAFItem_Variable.put(intIndexPAFItem_Variable++, objPAFItem);
        }
        else if(PAFItemType == 'conditional'){
            objPAFItem = new ASI_HK_CRM_Pre_Approval_Form_Item__c
                (ASI_HK_CRM_Pre_Approval_Form_Lookup__c = preAppFormId, 
                RecordTypeId=Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment'));
            mapPAFItem_Conditional.put(intIndexPAFItem_Conditional++, objPAFItem);
        }
        else if(PAFItemType == 'fixed'){
            objPAFItem = new ASI_HK_CRM_Pre_Approval_Form_Item__c
                (ASI_HK_CRM_Pre_Approval_Form_Lookup__c = preAppFormId, 
                RecordTypeId=Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment'));
            mapPAFItem_Fixed.put(intIndexPAFItem_Fixed++, objPAFItem);
        }
        else if(PAFItemType == 'global_variable'){
            objPAFItem = new ASI_HK_CRM_Pre_Approval_Form_Item__c
                (ASI_HK_CRM_Pre_Approval_Form_Lookup__c = preAppFormId, 
                RecordTypeId=Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment_Global_Promotion'),
                ASI_CRM_AD_or_AP__c = 'A&D');
            mapPAFItem_Variable_Global.put(intIndexPAFItem_Variable_Global++, objPAFItem);
        }
    }
    
    public void clonePAFItems(){
        if(intRowid != NULL){
            if(PAFItemType == 'variable' && mapPAFItem_Variable.get(intRowid) != NULL){
                ASI_HK_CRM_Pre_Approval_Form_Item__c objPAFItem_Variable = mapPAFItem_Variable.get(intRowid);
                ASI_HK_CRM_Pre_Approval_Form_Item__c objPAFItem_Variable_Clone = objPAFItem_Variable.clone(false, true);
                objPAFItem_Variable_Clone.ASI_HK_CRM_Pre_Approval_Form_Lookup__c = objPAFItem_Variable.ASI_HK_CRM_Pre_Approval_Form_Lookup__c;
                mapPAFItem_Variable.put(intIndexPAFItem_Variable++, objPAFItem_Variable_Clone);
            }
            else if(PAFItemType == 'conditional' && mapPAFItem_Conditional.get(intRowid) != NULL){
                ASI_HK_CRM_Pre_Approval_Form_Item__c objPAFItem_Conditional = mapPAFItem_Conditional.get(intRowid);
                ASI_HK_CRM_Pre_Approval_Form_Item__c objPAFItem_Conditional_Clone = objPAFItem_Conditional.clone(false, true);
                objPAFItem_Conditional_Clone.ASI_HK_CRM_Pre_Approval_Form_Lookup__c = objPAFItem_Conditional.ASI_HK_CRM_Pre_Approval_Form_Lookup__c;
                mapPAFItem_Conditional.put(intIndexPAFItem_Conditional++, objPAFItem_Conditional_Clone);
            }
            else if(PAFItemType == 'fixed' && mapPAFItem_Fixed.get(intRowid) != NULL){
                ASI_HK_CRM_Pre_Approval_Form_Item__c objPAFItem_Fixed = mapPAFItem_Fixed.get(intRowid);
                ASI_HK_CRM_Pre_Approval_Form_Item__c objPAFItem_Fixed_Clone = objPAFItem_Fixed.clone(false, true);
                objPAFItem_Fixed_Clone.ASI_HK_CRM_Pre_Approval_Form_Lookup__c = objPAFItem_Fixed.ASI_HK_CRM_Pre_Approval_Form_Lookup__c;
                mapPAFItem_Fixed.put(intIndexPAFItem_Fixed++, objPAFItem_Fixed_Clone);
            }
            else if(PAFItemType == 'global_variable' && mapPAFItem_Variable_Global.get(intRowid) != NULL){
                ASI_HK_CRM_Pre_Approval_Form_Item__c objPAFItem_Variable_Global = mapPAFItem_Variable_Global.get(intRowid);
                ASI_HK_CRM_Pre_Approval_Form_Item__c objPAFItem_Variable_Global_Clone = objPAFItem_Variable_Global.clone(false, true);
                objPAFItem_Variable_Global_Clone.ASI_HK_CRM_Pre_Approval_Form_Lookup__c = objPAFItem_Variable_Global.ASI_HK_CRM_Pre_Approval_Form_Lookup__c;
                mapPAFItem_Variable_Global.put(intIndexPAFItem_Variable_Global++, objPAFItem_Variable_Global_Clone);
            }
        } 
    }
    
    public void deletePAFItems(){
        if(intRowid != NULL){
            if(PAFItemType == 'variable' && mapPAFItem_Variable.get(intRowid) != NULL){
                if(mapPAFItem_Variable.get(intRowid).id != NULL)
                    listDeletedPAFItem_Variable.add(mapPAFItem_Variable.get(intRowid));
                mapPAFItem_Variable.remove(intRowid);
            }
            else if(PAFItemType == 'conditional' && mapPAFItem_Conditional.get(intRowid) != NULL){
                if(mapPAFItem_Conditional.get(intRowid).id != NULL)
                    listDeletedPAFItem_Conditional.add(mapPAFItem_Conditional.get(intRowid));
                mapPAFItem_Conditional.remove(intRowid);
            }
            else if(PAFItemType == 'fixed' && mapPAFItem_Fixed.get(intRowid) != NULL){
                if(mapPAFItem_Fixed.get(intRowid).id != NULL)
                    listDeletedPAFItem_Fixed.add(mapPAFItem_Fixed.get(intRowid));
                mapPAFItem_Fixed.remove(intRowid);
            }
            else if(PAFItemType == 'global_variable' && mapPAFItem_Variable_Global.get(intRowid) != NULL){
                if(mapPAFItem_Variable_Global.get(intRowid).id != NULL)
                    listDeletedPAFItem_Variable_Global.add(mapPAFItem_Variable_Global.get(intRowid));
                mapPAFItem_Variable_Global.remove(intRowid);
            }
        }
    }
    
    public PageReference QuickSave(){
        Boolean saveSuccess = implSaveChanges();
        system.debug('Save Sucess: '+saveSuccess);
        PageReference redirectPage = NULL;
        
        if (saveSuccess) {
            redirectPage = Page.ASI_CRM_TW_PAF_EditDetail_Page;
            redirectPage.setRedirect(true);
            redirectPage.getParameters().put('id', preAppFormId);
        }
        return redirectPage;
    }
    
    public PageReference Save(){
        Boolean saveSuccess = implSaveChanges();
        PageReference redirectPage = NULL;
        
        if (saveSuccess) {
            redirectPage = new PageReference('/' + preAppFormId);
            redirectPage.setRedirect(true);
        }
        return redirectPage;
    }
    
    public Boolean implSaveChanges(){
        Boolean allSuccess = true;
        System.Savepoint sp = database.setSavepoint();
        ApexPages.Message myMsg;
        
        //Update the bucket validity for further checking, if start date/ end date is changed:
        updateBucketValidity();
        
        List<ASI_CRM_CalculatedSalesVolume__c> listToUpsertCapacity = new List<ASI_CRM_CalculatedSalesVolume__c>();
        List<ASI_HK_CRM_Pre_Approval_Form_Item__c> listToUpsertPAFItem = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
        
        for(Integer csKey : mapCapacity.KeySet()){
            for(String csKey2 : mapCapacity.get(csKey).KeySet()){
                if(mapCapacity.get(csKey).get(csKey2).ASI_CRM_Bottle__c != NULL){
                    ASI_CRM_CalculatedSalesVolume__c capacity = mapCapacity.get(csKey).get(csKey2);
                    listToUpsertCapacity.add(capacity);
                }
                else if(mapCapacity.get(csKey).get(csKey2).id != NULL && !listDeletedCapacity.contains(mapCapacity.get(csKey).get(csKey2))){
                    listDeletedCapacity.add(mapCapacity.get(csKey).get(csKey2));
                    mapCapacity.get(csKey).remove(csKey2);
                }
            }
        }
        
        //get item group Sub-Brand for duplication check
        for(Integer pafItemKey : mapPAFItem_Variable.KeySet()){
            ASI_HK_CRM_Pre_Approval_Form_Item__c pafItem = mapPAFItem_Variable.get(pafItemKey);
            if(pafItem.ASI_CRM_Contracted_Item__c != null)    
                setItmGroupId.add(pafItem.ASI_CRM_Contracted_Item__c);

            if(pafItem.ASI_CRM_FOC_Item__c != null)    
                setItmGroupId.add(pafItem.ASI_CRM_FOC_Item__c);
            /*if(pafItem.ASI_CRM_Expenses_Product__c != null)
                setItmGroupId.add(pafItem.ASI_CRM_Expenses_Product__c);*/
        }
        for(Integer pafItemKey : mapPAFItem_Conditional.KeySet()){
            ASI_HK_CRM_Pre_Approval_Form_Item__c pafItem = mapPAFItem_Conditional.get(pafItemKey);
            /*if(pafItem.ASI_CRM_Contracted_Item__c != null)    
                setItmGroupId.add(pafItem.ASI_CRM_Contracted_Item__c);*/
            if(pafItem.ASI_CRM_Expenses_Product__c != null)
                setItmGroupId.add(pafItem.ASI_CRM_Expenses_Product__c);
        }
        for(Integer pafItemKey : mapPAFItem_Fixed.KeySet()){
            ASI_HK_CRM_Pre_Approval_Form_Item__c pafItem = mapPAFItem_Fixed.get(pafItemKey);
            /*if(pafItem.ASI_CRM_Contracted_Item__c != null)    
                setItmGroupId.add(pafItem.ASI_CRM_Contracted_Item__c);*/
            if(pafItem.ASI_CRM_Expenses_Product__c != null)
                setItmGroupId.add(pafItem.ASI_CRM_Expenses_Product__c);
        }
        mapItmGroup = new Map<Id, ASI_MFM_Item_Group__c>([SELECT id, ASI_CRM_Sub_Brand_Code__c, ASI_MFM_Item_Group_Code__c FROM ASI_MFM_Item_Group__c WHERE id IN : setItmGroupId]);
        system.debug('Item Group Map: '+mapItmGroup);
                
        
        Set<String> setDeduplicateFOC_Variable = new Set<String>();
        Set<String> setDeduplicateCash_Variable = new Set<String>();
        Set<String> setDeduplicateFOC_ConditionalOrFixed = new Set<String>();
        Set<String> setDeduplicateCash_ConditionalOrFixed = new Set<String>();
        
        List<ASI_HK_CRM_Pre_Approval_Form_Item__c> listConditonalFixed = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
        
        Integer rowIndex_variable = 1;
        for(Integer pafItemKey : mapPAFItem_Variable.KeySet()){
            ASI_HK_CRM_Pre_Approval_Form_Item__c pafItem = mapPAFItem_Variable.get(pafItemKey);
            
            //Sum-up Target Volume of 12 buckets
            if((!mapBuckets.get('P1') && pafItem.ASI_CRM_Target_Volume_Qty_P1__c != null) ||
               (!mapBuckets.get('P2') && pafItem.ASI_CRM_Target_Volume_Qty_P2__c != null) ||
               (!mapBuckets.get('P3') && pafItem.ASI_CRM_Target_Volume_Qty_P3__c != null) ||
               (!mapBuckets.get('P4') && pafItem.ASI_CRM_Target_Volume_Qty_P4__c != null) ||
               (!mapBuckets.get('P5') && pafItem.ASI_CRM_Target_Volume_Qty_P5__c != null) ||
               (!mapBuckets.get('P6') && pafItem.ASI_CRM_Target_Volume_Qty_P6__c != null) ||
               (!mapBuckets.get('P7') && pafItem.ASI_CRM_Target_Volume_Qty_P7__c != null) ||
               (!mapBuckets.get('P8') && pafItem.ASI_CRM_Target_Volume_Qty_P8__c != null) ||
               (!mapBuckets.get('P9') && pafItem.ASI_CRM_Target_Volume_Qty_P9__c != null) ||
               (!mapBuckets.get('P10') && pafItem.ASI_CRM_Target_Volume_Qty_P10__c != null) ||
               (!mapBuckets.get('P11') && pafItem.ASI_CRM_Target_Volume_Qty_P11__c != null) ||
               (!mapBuckets.get('P12') && pafItem.ASI_CRM_Target_Volume_Qty_P12__c != null)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Variable Investment row '+rowIndex_variable+' : Please do not input bucket values not included in current PAF period.'));
                allSuccess = false;
            }
                
            
            Decimal P1 = pafItem.ASI_CRM_Target_Volume_Qty_P1__c != null ? pafItem.ASI_CRM_Target_Volume_Qty_P1__c : 0;
            Decimal P2 = pafItem.ASI_CRM_Target_Volume_Qty_P2__c != null ? pafItem.ASI_CRM_Target_Volume_Qty_P2__c : 0;
            Decimal P3 = pafItem.ASI_CRM_Target_Volume_Qty_P3__c != null ? pafItem.ASI_CRM_Target_Volume_Qty_P3__c : 0;
            Decimal P4 = pafItem.ASI_CRM_Target_Volume_Qty_P4__c != null ? pafItem.ASI_CRM_Target_Volume_Qty_P4__c : 0;
            Decimal P5 = pafItem.ASI_CRM_Target_Volume_Qty_P5__c != null ? pafItem.ASI_CRM_Target_Volume_Qty_P5__c : 0;
            Decimal P6 = pafItem.ASI_CRM_Target_Volume_Qty_P6__c != null ? pafItem.ASI_CRM_Target_Volume_Qty_P6__c : 0;
            Decimal P7 = pafItem.ASI_CRM_Target_Volume_Qty_P7__c != null ? pafItem.ASI_CRM_Target_Volume_Qty_P7__c : 0;
            Decimal P8 = pafItem.ASI_CRM_Target_Volume_Qty_P8__c != null ? pafItem.ASI_CRM_Target_Volume_Qty_P8__c : 0;
            Decimal P9 = pafItem.ASI_CRM_Target_Volume_Qty_P9__c != null ? pafItem.ASI_CRM_Target_Volume_Qty_P9__c : 0;
            Decimal P10 = pafItem.ASI_CRM_Target_Volume_Qty_P10__c != null ? pafItem.ASI_CRM_Target_Volume_Qty_P10__c : 0;
            Decimal P11 = pafItem.ASI_CRM_Target_Volume_Qty_P11__c != null ? pafItem.ASI_CRM_Target_Volume_Qty_P11__c : 0;
            Decimal P12 = pafItem.ASI_CRM_Target_Volume_Qty_P12__c != null ? pafItem.ASI_CRM_Target_Volume_Qty_P12__c : 0;
            
            Decimal total = P1 + P2 + P3 + P4 + P5 + P6 + P7 + P8 + P9 + P10 + P11 + P12;
            
            if (total == 0 && pafItem.ASI_HK_CRM_Target_Volume_Qty__c > 0) {
                total = pafItem.ASI_HK_CRM_Target_Volume_Qty__c;                
                Integer thisVol = (total / buckets).intValue();

                if (thisVol == 0) {
                    thisVol = 1;
                }
                
                for (Integer i = 1; i <= buckets; i++) {
                    if (total >= thisVol) {
                        pafItem.put('ASI_CRM_Target_Volume_Qty_P' + i + '__c', thisVol);
                        total -= thisVol;
                        
                        if (i == buckets && total > 0) {
                            Decimal curValue = (Decimal)pafItem.get('ASI_CRM_Target_Volume_Qty_P' + i + '__c');
                            pafItem.put('ASI_CRM_Target_Volume_Qty_P' + i + '__c', curValue + total);
                            total = 0;
                        }
                    }
                    else if (total == 0) {
                        break;
                    }
                }
            }
            else if (total != 0) {
                pafItem.ASI_HK_CRM_Target_Volume_Qty__c = total;
            }
            
            //Apply Validations for Cash/FOC line
            if ((pafItem.ASI_CRM_Cash_or_FOC__c == 'FOC' || pafItem.ASI_CRM_Cash_or_FOC__c == 'Cash & FOC') && pafItem.ASI_CRM_FOC_Item__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Variable Investment row ' + rowIndex_variable + ' : Please select FOC Item for \'FOC\' or CASH & FOC line.'));
                allSuccess = false;
            }
            
            if(pafItem.ASI_HK_CRM_Target_Volume_Qty__c == 0 && (pafItem.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c != null || pafItem.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c != null || pafItem.ASI_CRM_Cash_Per_Bottle_w_VAT__c != null)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Variable Investment row '+rowIndex_variable+' : Please do not enter FOC Term or Cash Per Bottle (w/ VAT) if Target Volume is 0.'));
                allSuccess = false;
            }
            
            if(pafItem.ASI_CRM_Cash_or_FOC__c == 'Cash' && pafItem.ASI_HK_CRM_Target_Volume_Qty__c != 0){
                if(pafItem.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c != null || pafItem.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c != null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Variable Investment row '+rowIndex_variable+' : Please do not enter FOC Term for \'Cash\' line.'));
                    allSuccess = false;
                }
                else if(pafItem.ASI_CRM_Cash_Per_Bottle_w_VAT__c == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Variable Investment row '+rowIndex_variable+' : Please enter Cash Per Bottle (w/ VAT) for \'Cash\' line.'));
                    allSuccess = false;
                }
            }
            else if(pafItem.ASI_CRM_Cash_or_FOC__c == 'FOC' && pafItem.ASI_HK_CRM_Target_Volume_Qty__c != 0){
                if(pafItem.ASI_CRM_Cash_Per_Bottle_w_VAT__c != null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Variable Investment row '+rowIndex_variable+' : Please do not enter Cash Per Bottle (w/ VAT) for \'FOC\' line.'));
                    allSuccess = false;
                }
                else if(pafItem.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c == null || pafItem.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Variable Investment row '+rowIndex_variable+' : Please enter FOC Term for \'FOC\' line.'));
                    allSuccess = false;
                }
            }
            else if(pafItem.ASI_CRM_Cash_or_FOC__c == 'Cash & FOC' && pafItem.ASI_HK_CRM_Target_Volume_Qty__c != 0){
                if(pafItem.ASI_CRM_Cash_Per_Bottle_w_VAT__c == null || pafItem.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c == null || pafItem.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Variable Investment row '+rowIndex_variable+' : Please enter both Cash Per Bottle (w/ VAT) and FOC Term for \'Cash & FOC\' line.'));
                    allSuccess = false;
                }
            }
            
            //external key duplication check - avoid plan line item duplicate
            if (allSuccess)
            {
                if (pafItem.ASI_CRM_Cash_or_FOC__c == 'FOC')
                {
                    if (!setDeduplicateFOC_Variable.contains('FOC' + mapItmGroup.get(pafItem.ASI_CRM_Contracted_Item__c).ASI_CRM_Sub_Brand_Code__c + mapItmGroup.get(pafItem.ASI_CRM_Contracted_Item__c).ASI_MFM_Item_Group_Code__c))
                    {
                        setDeduplicateFOC_Variable.add('FOC' + mapItmGroup.get(pafItem.ASI_CRM_Contracted_Item__c).ASI_CRM_Sub_Brand_Code__c + mapItmGroup.get(pafItem.ASI_CRM_Contracted_Item__c).ASI_MFM_Item_Group_Code__c);
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Variable Investment row '+rowIndex_variable+' : Duplicated FOC line, Contracted Items with same Sub-Brand and Item Group obtains.'));
                        allSuccess = false;
                    } 
                }
                else if (pafItem.ASI_CRM_Cash_or_FOC__c == 'Cash & FOC')
                {
                    if (!setDeduplicateFOC_Variable.contains('FOC' + mapItmGroup.get(pafItem.ASI_CRM_Contracted_Item__c).ASI_CRM_Sub_Brand_Code__c + mapItmGroup.get(pafItem.ASI_CRM_Contracted_Item__c).ASI_MFM_Item_Group_Code__c))
                    {
                        setDeduplicateFOC_Variable.add('FOC' + mapItmGroup.get(pafItem.ASI_CRM_Contracted_Item__c).ASI_CRM_Sub_Brand_Code__c + mapItmGroup.get(pafItem.ASI_CRM_Contracted_Item__c).ASI_MFM_Item_Group_Code__c);
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Variable Investment row '+rowIndex_variable+' : Duplicated FOC line, Contracted Items with same Sub-Brand and Item Group obtains.'));
                        allSuccess = false;
                    } 
                }
                else if (pafItem.ASI_CRM_Cash_or_FOC__c == 'Cash')
                {
                    if (!setDeduplicateCash_Variable.contains('Cash' + mapItmGroup.get(pafItem.ASI_CRM_Contracted_Item__c).ASI_CRM_Sub_Brand_Code__c + mapItmGroup.get(pafItem.ASI_CRM_Contracted_Item__c).ASI_MFM_Item_Group_Code__c))
                    {
                        setDeduplicateCash_Variable.add('Cash' + mapItmGroup.get(pafItem.ASI_CRM_Contracted_Item__c).ASI_CRM_Sub_Brand_Code__c + mapItmGroup.get(pafItem.ASI_CRM_Contracted_Item__c).ASI_MFM_Item_Group_Code__c);
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Variable Investment row '+rowIndex_variable+' : Duplicated Cash line, Contracted Items with same Sub-Brand and Item Group obtains.'));
                        allSuccess = false;
                    } 
                }
            }
            
            listToUpsertPAFItem.add(pafItem);
            rowIndex_variable++;
        }
        
        for(Integer pafItemKey : mapPAFItem_Conditional.KeySet()){
            ASI_HK_CRM_Pre_Approval_Form_Item__c pafItem = mapPAFItem_Conditional.get(pafItemKey);
            listConditonalFixed.add(pafItem);
        }
        
        for(Integer pafItemKey : mapPAFItem_Fixed.KeySet()){
            ASI_HK_CRM_Pre_Approval_Form_Item__c pafItem = mapPAFItem_Fixed.get(pafItemKey);
            listConditonalFixed.add(pafItem);  
        }
        
        Integer rowIndex_Conditional = 1;
        Integer rowIndex_Fixed = 1;
        for(ASI_HK_CRM_Pre_Approval_Form_Item__c pafItem : listConditonalFixed){
            Decimal P1_cash = pafItem.ASI_CRM_Cash_Amounts_w_VAT_P1__c != null ? pafItem.ASI_CRM_Cash_Amounts_w_VAT_P1__c : 0;
            Decimal P2_cash = pafItem.ASI_CRM_Cash_Amounts_w_VAT_P2__c != null ? pafItem.ASI_CRM_Cash_Amounts_w_VAT_P2__c : 0;
            Decimal P3_cash = pafItem.ASI_CRM_Cash_Amounts_w_VAT_P3__c != null ? pafItem.ASI_CRM_Cash_Amounts_w_VAT_P3__c : 0;
            Decimal P4_cash = pafItem.ASI_CRM_Cash_Amounts_w_VAT_P4__c != null ? pafItem.ASI_CRM_Cash_Amounts_w_VAT_P4__c : 0;
            Decimal P5_cash = pafItem.ASI_CRM_Cash_Amounts_w_VAT_P5__c != null ? pafItem.ASI_CRM_Cash_Amounts_w_VAT_P5__c : 0;
            Decimal P6_cash = pafItem.ASI_CRM_Cash_Amounts_w_VAT_P6__c != null ? pafItem.ASI_CRM_Cash_Amounts_w_VAT_P6__c : 0;
            Decimal P7_cash = pafItem.ASI_CRM_Cash_Amounts_w_VAT_P7__c != null ? pafItem.ASI_CRM_Cash_Amounts_w_VAT_P7__c : 0;
            Decimal P8_cash = pafItem.ASI_CRM_Cash_Amounts_w_VAT_P8__c != null ? pafItem.ASI_CRM_Cash_Amounts_w_VAT_P8__c : 0;
            Decimal P9_cash = pafItem.ASI_CRM_Cash_Amounts_w_VAT_P9__c != null ? pafItem.ASI_CRM_Cash_Amounts_w_VAT_P9__c : 0;
            Decimal P10_cash = pafItem.ASI_CRM_Cash_Amounts_w_VAT_P10__c != null ? pafItem.ASI_CRM_Cash_Amounts_w_VAT_P10__c : 0;
            Decimal P11_cash = pafItem.ASI_CRM_Cash_Amounts_w_VAT_P11__c != null ? pafItem.ASI_CRM_Cash_Amounts_w_VAT_P11__c : 0;
            Decimal P12_cash = pafItem.ASI_CRM_Cash_Amounts_w_VAT_P12__c != null ? pafItem.ASI_CRM_Cash_Amounts_w_VAT_P12__c : 0;
                
            Decimal P1_foc = pafItem.ASI_CRM_FOC_Volume_P1__c != null ? pafItem.ASI_CRM_FOC_Volume_P1__c : 0;
            Decimal P2_foc = pafItem.ASI_CRM_FOC_Volume_P2__c != null ? pafItem.ASI_CRM_FOC_Volume_P2__c : 0;
            Decimal P3_foc = pafItem.ASI_CRM_FOC_Volume_P3__c != null ? pafItem.ASI_CRM_FOC_Volume_P3__c : 0;
            Decimal P4_foc = pafItem.ASI_CRM_FOC_Volume_P4__c != null ? pafItem.ASI_CRM_FOC_Volume_P4__c : 0;
            Decimal P5_foc = pafItem.ASI_CRM_FOC_Volume_P5__c != null ? pafItem.ASI_CRM_FOC_Volume_P5__c : 0;
            Decimal P6_foc = pafItem.ASI_CRM_FOC_Volume_P6__c != null ? pafItem.ASI_CRM_FOC_Volume_P6__c : 0;
            Decimal P7_foc = pafItem.ASI_CRM_FOC_Volume_P7__c != null ? pafItem.ASI_CRM_FOC_Volume_P7__c : 0;
            Decimal P8_foc = pafItem.ASI_CRM_FOC_Volume_P8__c != null ? pafItem.ASI_CRM_FOC_Volume_P8__c : 0;
            Decimal P9_foc = pafItem.ASI_CRM_FOC_Volume_P9__c != null ? pafItem.ASI_CRM_FOC_Volume_P9__c : 0;
            Decimal P10_foc = pafItem.ASI_CRM_FOC_Volume_P10__c != null ? pafItem.ASI_CRM_FOC_Volume_P10__c : 0;
            Decimal P11_foc = pafItem.ASI_CRM_FOC_Volume_P11__c != null ? pafItem.ASI_CRM_FOC_Volume_P11__c : 0;
            Decimal P12_foc = pafItem.ASI_CRM_FOC_Volume_P12__c != null ? pafItem.ASI_CRM_FOC_Volume_P12__c : 0;
                    
            //Apply Validations for Cash/FOC line
            if(pafItem.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment')){                                       
                //Sum-up Cash Amount from 12 buckets
                if((!mapBuckets.get('P1') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P1__c != null) ||
                   (!mapBuckets.get('P2') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P2__c != null) ||
                   (!mapBuckets.get('P3') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P3__c != null) ||
                   (!mapBuckets.get('P4') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P4__c != null) ||
                   (!mapBuckets.get('P5') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P5__c != null) ||
                   (!mapBuckets.get('P6') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P6__c != null) ||
                   (!mapBuckets.get('P7') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P7__c != null) ||
                   (!mapBuckets.get('P8') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P8__c != null) ||
                   (!mapBuckets.get('P9') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P9__c != null) ||
                   (!mapBuckets.get('P10') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P10__c != null) ||
                   (!mapBuckets.get('P11') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P11__c != null) ||
                   (!mapBuckets.get('P12') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P12__c != null)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Conditional Investment row '+rowIndex_variable+' : Please do not input bucket values of Cash Amount not including in current PAF period.'));
                    allSuccess = false;
                }

                Decimal cashTotal = P1_cash + P2_cash + P3_cash + P4_cash + P5_cash + P6_cash + P7_cash + P8_cash + P9_cash + P10_cash + P11_cash + P12_cash;
            
                if (cashTotal == 0 && pafItem.ASI_CRM_Cash_Amounts_w_VAT__c > 0) {
                    cashTotal = pafItem.ASI_CRM_Cash_Amounts_w_VAT__c;                
                    Integer thisVol = (cashTotal / buckets).intValue();

                    if (thisVol == 0) {
                        thisVol = 1;
                    }
                    
                    for (Integer i = 1; i <= buckets; i++) {
                        if (cashTotal >= thisVol) {
                            pafItem.put('ASI_CRM_Cash_Amounts_w_VAT_P' + i + '__c', thisVol);
                            cashTotal -= thisVol;
                            
                            if (i == buckets && cashTotal > 0) {
                                Decimal curValue = (Decimal)pafItem.get('ASI_CRM_Cash_Amounts_w_VAT_P' + i + '__c');
                                pafItem.put('ASI_CRM_Cash_Amounts_w_VAT_P' + i + '__c', curValue + cashTotal);
                                cashTotal = 0;
                            }
                        }
                        else if (cashTotal == 0) {
                            break;
                        }
                    }
                }
                else if (cashTotal != 0) {
                    pafItem.ASI_CRM_Cash_Amounts_w_VAT__c = cashTotal;
                }
                
                //Sum-up FOC Volumes from 12 buckets
                if((!mapBuckets.get('P1') && pafItem.ASI_CRM_FOC_Volume_P1__c != null) ||
                   (!mapBuckets.get('P2') && pafItem.ASI_CRM_FOC_Volume_P2__c != null) ||
                   (!mapBuckets.get('P3') && pafItem.ASI_CRM_FOC_Volume_P3__c != null) ||
                   (!mapBuckets.get('P4') && pafItem.ASI_CRM_FOC_Volume_P4__c != null) ||
                   (!mapBuckets.get('P5') && pafItem.ASI_CRM_FOC_Volume_P5__c != null) ||
                   (!mapBuckets.get('P6') && pafItem.ASI_CRM_FOC_Volume_P6__c != null) ||
                   (!mapBuckets.get('P7') && pafItem.ASI_CRM_FOC_Volume_P7__c != null) ||
                   (!mapBuckets.get('P8') && pafItem.ASI_CRM_FOC_Volume_P8__c != null) ||
                   (!mapBuckets.get('P9') && pafItem.ASI_CRM_FOC_Volume_P9__c != null) ||
                   (!mapBuckets.get('P10') && pafItem.ASI_CRM_FOC_Volume_P10__c != null) ||
                   (!mapBuckets.get('P11') && pafItem.ASI_CRM_FOC_Volume_P11__c != null) ||
                   (!mapBuckets.get('P12') && pafItem.ASI_CRM_FOC_Volume_P12__c != null)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Conditional Investment row '+rowIndex_variable+' : Please do not input bucket values of FOC Volume not including in current PAF period.'));
                    allSuccess = false;
                }

                Decimal focTotal = P1_foc + P2_foc + P3_foc + P4_foc + P5_foc + P6_foc + P7_foc + P8_foc + P9_foc + P10_foc + P11_foc + P12_foc;
            
                if (focTotal == 0 && pafItem.ASI_CRM_FOC_Volume__c > 0) {
                    focTotal = pafItem.ASI_CRM_FOC_Volume__c;                
                    Integer thisVol = (focTotal / buckets).intValue();

                    if (thisVol == 0) {
                        thisVol = 1;
                    }
                    
                    for (Integer i = 1; i <= buckets; i++) {
                        if (focTotal >= thisVol) {
                            pafItem.put('ASI_CRM_FOC_Volume_P' + i + '__c', thisVol);
                            focTotal -= thisVol;
                            
                            if (i == buckets && focTotal > 0) {
                                Decimal curValue = (Decimal)pafItem.get('ASI_CRM_FOC_Volume_P' + i + '__c');
                                pafItem.put('ASI_CRM_FOC_Volume_P' + i + '__c', curValue + focTotal);
                                focTotal = 0;
                            }
                        }
                        else if (focTotal == 0) {
                            break;
                        }
                    }
                }
                else if (focTotal != 0) {
                    pafItem.ASI_CRM_FOC_Volume__c = focTotal;
                }
                
                if(pafItem.ASI_CRM_Cash_or_FOC__c == 'Cash'){
                    if(pafItem.ASI_CRM_FOC_Volume__c != null && pafItem.ASI_CRM_FOC_Volume__c != 0){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Conditional Investment row '+rowIndex_Conditional+' : Please do not enter FOC Volume for \'Cash\' line.'));
                        allSuccess = false;
                    }
                    //2020-07-23 KL@Introv
                    /*else if(pafItem.ASI_CRM_Cash_Amounts_w_VAT__c == 0){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Conditional Investment row '+rowIndex_Conditional+' : Please enter Cash Amounts (w/ VAT) for \'Cash\' line.'));
                        allSuccess = false;
                    }*/
                }
                else if(pafItem.ASI_CRM_Cash_or_FOC__c == 'FOC'){
                    if(pafItem.ASI_CRM_Cash_Amounts_w_VAT__c != null && pafItem.ASI_CRM_Cash_Amounts_w_VAT__c != 0){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Conditional Investment row '+rowIndex_Conditional+' : Please do not enter Cash Amounts (w/ VAT) for \'FOC\' line.'));
                        allSuccess = false;
                    }
                    //2020-07-23 KL@Introv
                    /*else if(pafItem.ASI_CRM_FOC_Volume__c == 0){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Conditional Investment row '+rowIndex_Conditional+' : Please enter FOC Volume for \'FOC\' line.'));
                        allSuccess = false;
                    }*/
                }
            }
            else if(pafItem.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment')){
                //Sum-up Cash Amount from 12 buckets
                if((!mapBuckets.get('P1') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P1__c != null) ||
                   (!mapBuckets.get('P2') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P2__c != null) ||
                   (!mapBuckets.get('P3') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P3__c != null) ||
                   (!mapBuckets.get('P4') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P4__c != null) ||
                   (!mapBuckets.get('P5') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P5__c != null) ||
                   (!mapBuckets.get('P6') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P6__c != null) ||
                   (!mapBuckets.get('P7') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P7__c != null) ||
                   (!mapBuckets.get('P8') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P8__c != null) ||
                   (!mapBuckets.get('P9') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P9__c != null) ||
                   (!mapBuckets.get('P10') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P10__c != null) ||
                   (!mapBuckets.get('P11') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P11__c != null) ||
                   (!mapBuckets.get('P12') && pafItem.ASI_CRM_Cash_Amounts_w_VAT_P12__c != null)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fixed Investment row '+rowIndex_variable+' : Please do not input bucket values of Cash Amount not including in current PAF period.'));
                    allSuccess = false;
                }
                
                Decimal cashTotal = P1_cash + P2_cash + P3_cash + P4_cash + P5_cash + P6_cash + P7_cash + P8_cash + P9_cash + P10_cash + P11_cash + P12_cash;
            
                if (cashTotal == 0 && pafItem.ASI_CRM_Cash_Amounts_w_VAT__c > 0) {
                    cashTotal = pafItem.ASI_CRM_Cash_Amounts_w_VAT__c;                
                    Integer thisVol = (cashTotal / buckets).intValue();

                    if (thisVol == 0) {
                        thisVol = 1;
                    }
                    
                    for (Integer i = 1; i <= buckets; i++) {
                        if (cashTotal >= thisVol) {
                            pafItem.put('ASI_CRM_Cash_Amounts_w_VAT_P' + i + '__c', thisVol);
                            cashTotal -= thisVol;
                            
                            if (i == buckets && cashTotal > 0) {
                                Decimal curValue = (Decimal)pafItem.get('ASI_CRM_Cash_Amounts_w_VAT_P' + i + '__c');
                                pafItem.put('ASI_CRM_Cash_Amounts_w_VAT_P' + i + '__c', curValue + cashTotal);
                                cashTotal = 0;
                            }
                        }
                        else if (cashTotal == 0) {
                            break;
                        }
                    }
                }
                else if (cashTotal != 0) {
                    pafItem.ASI_CRM_Cash_Amounts_w_VAT__c = cashTotal;
                }
                
                //Sum-up FOC Volumes from 12 buckets
                if((!mapBuckets.get('P1') && pafItem.ASI_CRM_FOC_Volume_P1__c != null) ||
                   (!mapBuckets.get('P2') && pafItem.ASI_CRM_FOC_Volume_P2__c != null) ||
                   (!mapBuckets.get('P3') && pafItem.ASI_CRM_FOC_Volume_P3__c != null) ||
                   (!mapBuckets.get('P4') && pafItem.ASI_CRM_FOC_Volume_P4__c != null) ||
                   (!mapBuckets.get('P5') && pafItem.ASI_CRM_FOC_Volume_P5__c != null) ||
                   (!mapBuckets.get('P6') && pafItem.ASI_CRM_FOC_Volume_P6__c != null) ||
                   (!mapBuckets.get('P7') && pafItem.ASI_CRM_FOC_Volume_P7__c != null) ||
                   (!mapBuckets.get('P8') && pafItem.ASI_CRM_FOC_Volume_P8__c != null) ||
                   (!mapBuckets.get('P9') && pafItem.ASI_CRM_FOC_Volume_P9__c != null) ||
                   (!mapBuckets.get('P10') && pafItem.ASI_CRM_FOC_Volume_P10__c != null) ||
                   (!mapBuckets.get('P11') && pafItem.ASI_CRM_FOC_Volume_P11__c != null) ||
                   (!mapBuckets.get('P12') && pafItem.ASI_CRM_FOC_Volume_P12__c != null)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fixed Investment row '+rowIndex_variable+' : Please do not input bucket values of FOC Volume not including in current PAF period.'));
                    allSuccess = false;
                }
                
                Decimal focTotal = P1_foc + P2_foc + P3_foc + P4_foc + P5_foc + P6_foc + P7_foc + P8_foc + P9_foc + P10_foc + P11_foc + P12_foc;
            
                if (focTotal == 0 && pafItem.ASI_CRM_FOC_Volume__c > 0) {
                    focTotal = pafItem.ASI_CRM_FOC_Volume__c;                
                    Integer thisVol = (focTotal / buckets).intValue();

                    if (thisVol == 0) {
                        thisVol = 1;
                    }
                    
                    for (Integer i = 1; i <= buckets; i++) {
                        if (focTotal >= thisVol) {
                            pafItem.put('ASI_CRM_FOC_Volume_P' + i + '__c', thisVol);
                            focTotal -= thisVol;
                            
                            if (i == buckets && focTotal > 0) {
                                Decimal curValue = (Decimal)pafItem.get('ASI_CRM_FOC_Volume_P' + i + '__c');
                                pafItem.put('ASI_CRM_FOC_Volume_P' + i + '__c', curValue + focTotal);
                                focTotal = 0;
                            }
                        }
                        else if (focTotal == 0) {
                            break;
                        }
                    }
                }
                else if (focTotal != 0) {
                    pafItem.ASI_CRM_FOC_Volume__c = focTotal;
                }
                
                //pafItem Validations for Cash/FOC line
                if(pafItem.ASI_CRM_Cash_or_FOC__c == 'Cash'){
                    if(pafItem.ASI_CRM_FOC_Volume__c != null && pafItem.ASI_CRM_FOC_Volume__c != 0){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fixed Investment row '+rowIndex_Fixed+' : Please do not enter FOC Volume for \'Cash\' line.'));
                        allSuccess = false;
                    }
                    //2020-07-23 KL@Introv
                    /*else if(pafItem.ASI_CRM_Cash_Amounts_w_VAT__c == 0){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fixed Investment row '+rowIndex_Fixed+' : Please enter Cash Amounts (w/ VAT) for \'Cash\' line.'));
                        allSuccess = false;
                    }*/
                }
                else if(pafItem.ASI_CRM_Cash_or_FOC__c == 'FOC'){
                    if(pafItem.ASI_CRM_Cash_Amounts_w_VAT__c != null && pafItem.ASI_CRM_Cash_Amounts_w_VAT__c != 0){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fixed Investment row '+rowIndex_Fixed+' : Please do not enter Cash Amounts (w/ VAT) for \'FOC\' line.'));
                        allSuccess = false;
                    }
                    //2020-07-23 KL@Introv
                    /*else if(pafItem.ASI_CRM_FOC_Volume__c == 0){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fixed Investment row '+rowIndex_Fixed+' : Please enter FOC Volume for \'FOC\' line.'));
                        allSuccess = false;
                    }*/
                }    
            }
            
            //external key duplication check - avoid plan line item duplicate
            if(pafItem.ASI_CRM_Cash_or_FOC__c == 'FOC'){
               if(!setDeduplicateFOC_ConditionalOrFixed.contains('FOC'+mapItmGroup.get(pafItem.ASI_CRM_Expenses_Product__c).ASI_CRM_Sub_Brand_Code__c+pafItem.ASI_CRM_Mechanic_Detail__c + mapItmGroup.get(pafItem.ASI_CRM_Expenses_Product__c).ASI_MFM_Item_Group_Code__c))
                   setDeduplicateFOC_ConditionalOrFixed.add('FOC'+mapItmGroup.get(pafItem.ASI_CRM_Expenses_Product__c).ASI_CRM_Sub_Brand_Code__c+pafItem.ASI_CRM_Mechanic_Detail__c + mapItmGroup.get(pafItem.ASI_CRM_Expenses_Product__c).ASI_MFM_Item_Group_Code__c);
               else{
                   if(pafItem.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment')){
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Conditional Investment row '+rowIndex_Conditional+' : Duplicated FOC line, Expenses Products with same Sub-Brand, Mechanic Detail and Item Group obtains.'));
                       allSuccess = false;
                   }
                   else if(pafItem.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment')){
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fixed Investment row '+rowIndex_Fixed+' : Duplicated FOC line, Expenses Products with same Sub-Brand, Mechanic Detail and Item Group obtains.'));
                       allSuccess = false;
                   }
               } 
            }
            else if(pafItem.ASI_CRM_Cash_or_FOC__c == 'Cash'){
               if(!setDeduplicateCash_ConditionalOrFixed.contains('Cash'+mapItmGroup.get(pafItem.ASI_CRM_Expenses_Product__c).ASI_CRM_Sub_Brand_Code__c+pafItem.ASI_CRM_Mechanic_Detail__c + mapItmGroup.get(pafItem.ASI_CRM_Expenses_Product__c).ASI_MFM_Item_Group_Code__c))
                   setDeduplicateCash_ConditionalOrFixed.add('Cash'+mapItmGroup.get(pafItem.ASI_CRM_Expenses_Product__c).ASI_CRM_Sub_Brand_Code__c+pafItem.ASI_CRM_Mechanic_Detail__c + mapItmGroup.get(pafItem.ASI_CRM_Expenses_Product__c).ASI_MFM_Item_Group_Code__c);
               else{
                   if(pafItem.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment')){
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Conditional Investment row '+rowIndex_Conditional+' : Duplicated Cash line, Expenses Products with same Sub-Brand, Mechanic Detail and Item Group obtains.'));
                       allSuccess = false;
                   }
                   else if(pafItem.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment')){
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Fixed Investment row '+rowIndex_Fixed+' : Duplicated Cash line, Expenses Products with same Sub-Brand, Mechanic Detail and Item Group obtains.'));
                       allSuccess = false;
                   }
               } 
            }
            
            system.debug(preAppForm);
            if(preAppForm[0].ASI_CRM_Valid_Invoice__c && pafItem.ASI_CRM_Cash_Amounts_w_VAT__c != null)
                pafItem.ASI_CRM_Cash_Amounts_w_VAT__c = pafItem.ASI_CRM_Cash_Amounts_w_VAT__c;
                
            listToUpsertPAFItem.add(pafItem);
            
            if(pafItem.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment')){
                rowIndex_Conditional++;
            }
            else if(pafItem.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment')){
                rowIndex_Fixed++;
            }
        }
        
        for(Integer pafItemKey : mapPAFItem_Variable_Global.KeySet()){
            ASI_HK_CRM_Pre_Approval_Form_Item__c pafItem = mapPAFItem_Variable_Global.get(pafItemKey);
            
            //Apply Validations for Cash/FOC line
            if(pafItem.ASI_HK_CRM_Target_Volume_Qty__c == 0 && (pafItem.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c != null || pafItem.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c != null || pafItem.ASI_CRM_Cash_Per_Bottle_w_VAT__c != null)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Global Promotion Setting - Variable Investment row '+rowIndex_variable+' : Please do not enter FOC Term or Cash Per Bottle (w/ VAT) if Target Volume is 0.'));
                allSuccess = false;
            }
            if(pafItem.ASI_CRM_Cash_or_FOC__c == 'Cash'){
                if(pafItem.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c != null || pafItem.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c != null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Global Promotion Setting - Variable Investment: Please do not enter FOC Term for \'Cash\' line.'));
                    allSuccess = false;
                }
                else if(pafItem.ASI_CRM_Cash_Per_Bottle_w_VAT__c == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Global Promotion Setting - Variable Investment: Please enter Cash Per Bottle (w/ VAT) for \'Cash\' line.'));
                    allSuccess = false;
                }
            }
            else if(pafItem.ASI_CRM_Cash_or_FOC__c == 'FOC'){
                if(pafItem.ASI_CRM_Cash_Per_Bottle_w_VAT__c != null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Global Promotion Setting - Variable Investment: Please do not enter Cash Per Bottle (w/ VAT) for \'FOC\' line.'));
                    allSuccess = false;
                }
                else if(pafItem.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c == null || pafItem.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Global Promotion Setting - Variable Investment: Please enter FOC Term for \'FOC\' line.'));
                    allSuccess = false;
                }
            }
            else if(pafItem.ASI_CRM_Cash_or_FOC__c == 'Cash & FOC'&&pafItem.ASI_HK_CRM_Target_Volume_Qty__c != 0){
                if(pafItem.ASI_CRM_Cash_Per_Bottle_w_VAT__c == null || pafItem.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c == null || pafItem.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Global Promotion Setting - Variable Investment: Please enter both Cash Per Bottle (w/ VAT) and FOC Term for \'Cash & FOC\' line.'));
                    allSuccess = false;
                }
            }
                
            listToUpsertPAFItem.add(pafItem);
        }
        
        if(listPAFItem_PGCosts[0].ASI_CRM_Q1_hrs__c != NULL || listPAFItem_PGCosts[0].ASI_CRM_Q2_hrs__c != NULL ||
           listPAFItem_PGCosts[0].ASI_CRM_Q3_hrs__c != NULL || listPAFItem_PGCosts[0].ASI_CRM_Q4_hrs__c != NULL)
            listToUpsertPAFItem.add(listPAFItem_PGCosts[0]);
            
        system.debug(listToUpsertPAFItem);
        
        preAppForm[0].ASI_CRM_TW_Supplier__c = '';
        preAppForm[0].ASI_CRM_Supplier_Id__c = '';
        integer intIndex = 0;
        for(String supplier : selectedSupplier){
            if(intIndex == 0){
                preAppForm[0].ASI_CRM_Supplier_Id__c += supplier;
                if(mapSupplier != null && mapSupplier.get(supplier) != null && mapSupplier.get(supplier).ASI_CRM_Account__r.ASI_KOR_Legal_Name__c != null)
                    preAppForm[0].ASI_CRM_TW_Supplier__c += mapSupplier.get(supplier).ASI_CRM_Account__r.ASI_KOR_Legal_Name__c;
                else
                    preAppForm[0].ASI_CRM_TW_Supplier__c += ' - ';
            }
            else{
                preAppForm[0].ASI_CRM_Supplier_Id__c += '，'+supplier;
                if(mapSupplier != null && mapSupplier.get(supplier) != null && mapSupplier.get(supplier).ASI_CRM_Account__r.ASI_KOR_Legal_Name__c != null)
                    preAppForm[0].ASI_CRM_TW_Supplier__c += '，'+mapSupplier.get(supplier).ASI_CRM_Account__r.ASI_KOR_Legal_Name__c;
                else
                    preAppForm[0].ASI_CRM_TW_Supplier__c += '，'+' - ';
            }
            intIndex++;
        }
        
        if(allSuccess){
            //try {
                if(this.preAppForm != NULL)
                    update preAppForm;
                    
                if(listToUpsertCapacity != NULL)
                    upsert listToUpsertCapacity;

                System.debug('listDeletedCapacity:' + listDeletedCapacity);    
                if(listDeletedCapacity != NULL)
                    delete listDeletedCapacity; 
                if(listDeletedPAFItem_Variable != NULL)
                    delete listDeletedPAFItem_Variable;
                if(listDeletedPAFItem_Conditional != NULL)
                    delete listDeletedPAFItem_Conditional;
                if(listDeletedPAFItem_Fixed != NULL)
                    delete listDeletedPAFItem_Fixed;   
                if(listDeletedPAFItem_Variable_Global != NULL)
                    delete listDeletedPAFItem_Variable_Global;   
                    
                if(listToUpsertPAFItem != NULL)
                    upsert listToUpsertPAFItem;                    
            //} 
            //catch (DmlException dmle) {
            //    allSuccess = false;
            //    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: '+dmle));
            //    system.debug(dmle);
            //    database.rollback(sp);
            //}
        }
        system.debug('Save Sucess2: '+allSuccess);
        
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Saved successfully!'));
        return allSuccess;
    }
            
    
}