public with sharing class EUR_CRM_ForcePRSegDimensionsHandler extends EUR_CRM_TriggerAbstract {

    private static Set<String> euAccountValidRecordTypeSet = EUR_CRM_RecordtypeHelper.ForcePRSegDimensionsHandler_validRecordTypes;

    public static Set<String> TargetRecordSet {
        get{
            Set<String> TRt = new Set<String>();
            TRt.addAll(euAccountValidRecordTypeSet);
            
            return TRt;
        }private set;
    }



    public EUR_CRM_ForcePRSegDimensionsHandler(){
        super('EUR_CRM_ForcePRSegDimensionsHandler');
    }

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        System.Debug('EUR_CRM_ForcePRSegDimensionsHandler');
        Set<EUR_CRM_Account__c> euAccountsToProcess = new Set<EUR_CRM_Account__c>(); 
        Set<Id> euAccountIdsToProcess = new Set<Id>();
        Set<EUR_CRM_Account__c> euAccountsToClear = new Set<EUR_CRM_Account__c>();
        Set<Id> euAccountsCustomerTaxonomy = new Set<Id>();
        Set<String> euAccountCountryCodes = new Set<String>();

        // Cast the old objMap for comparison
        Map<Id, EUR_CRM_Account__c> oldEuAccountMap = (Map<Id, EUR_CRM_Account__c>)oldMap;

        // Retrieve account recordtypes
        List<Recordtype> accountRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        Map<Id, Recordtype> accountRecordTypesMap = new Map<Id, Recordtype>();
        // Create recordtype Map  
        for(Recordtype rt : accountRecordTypes){
            accountRecordTypesMap.put(rt.Id, rt);
        }      
        // Recordtype boundry
        for(EUR_CRM_Account__c acc : (List<EUR_CRM_Account__c>) sObjList){
            if(euAccountValidRecordTypeSet.contains(accountRecordTypesMap.get(acc.RecordtypeId).DeveloperName)){
                // Check if a force value is populated
                if(acc.EUR_CRM_Is_PRS_Dimensions_Forced__c == true || (acc.EUR_CRM_Is_PRS_Dimensions_Forced__c != oldEuAccountMap.get(acc.Id).EUR_CRM_Is_PRS_Dimensions_Forced__c))
                {
                    euAccountsToProcess.add(acc);
                    euAccountIdsToProcess.add(acc.Id);
                    euAccountCountryCodes.add(acc.EUR_CRM_Country_Code__c);
                    // Check if force by customer taxonomy
                    if(acc.EUR_CRM_Force_GOT_OT_by_CT__c == true){
                        euAccountsCustomerTaxonomy.add(acc.EUR_JB_Customer_Taxonomy__c);
                    }
                }
            } else {
                continue;
            }
        }
        
        System.debug(euAccountsToProcess);
        System.debug(euAccountsToClear);

        if(euAccountsToProcess.size()>0){
            System.debug('FORCE PRS DIMENSIONS');
            // Initialize the Maps
            Map<Id, EUR_CRM_Customer_Taxonomy__c> customerTaxonomyMap;
            Map<Id, EUR_CRM_PRS_Segmentation__c> prSegmentationsMap = new Map<Id, EUR_CRM_PRS_Segmentation__c>();
            Map<String, EUR_CRM_PRS_Seg_Aspect__c> bbpMap = new Map<String, EUR_CRM_PRS_Seg_Aspect__c>();
            Map<String, EUR_CRM_PRS_Seg_Aspect__c> bpMap = new Map<String, EUR_CRM_PRS_Seg_Aspect__c>();
            Map<String, EUR_CRM_PRS_Seg_Aspect__c> ilMap = new Map<String, EUR_CRM_PRS_Seg_Aspect__c>();
            Map<String, EUR_CRM_PRS_Seg_Aspect__c> vpMap = new Map<String, EUR_CRM_PRS_Seg_Aspect__c>();
            Map<String, EUR_CRM_PRS_Group_Outlet_Type__c> groupOutletTypeMap = new Map<String, EUR_CRM_PRS_Group_Outlet_Type__c>();
            Map<String, EUR_CRM_PRS_Outlet_Type__c> outletTypeMap = new Map<String, EUR_CRM_PRS_Outlet_Type__c>();
            System.debug(euAccountsCustomerTaxonomy);
            // Retrieve all customer to be force
            if(euAccountsCustomerTaxonomy.size()>0){
                // TODO : Add required fields
                customerTaxonomyMap = new Map<Id, EUR_CRM_Customer_Taxonomy__c>([SELECT Id, EUR_CRM_PRS_Group_Outlet_Type__c, EUR_CRM_PRS_Outlet_Type__c
                                                                                FROM EUR_CRM_Customer_Taxonomy__c
                                                                                WHERE Id IN : euAccountsCustomerTaxonomy]);
            }
            System.debug(customerTaxonomyMap);
            for(EUR_CRM_PRS_Segmentation__c segmentation : [SELECT Id, EUR_CRM_Account__c,
                                                                  EUR_CRM_Brand_Building_Potential__c,
                                                                  EUR_CRM_Business_Potential__c,
                                                                  EUR_CRM_PRS_Group_Outlet_Type__c,
                                                                  EUR_CRM_PRS_Outlet_Type__c,
                                                                  EUR_CRM_Image_Level__c,
                                                                  EUR_CRM_Volume_Potential__c
                                                           FROM EUR_CRM_PRS_Segmentation__c
                                                           WHERE EUR_CRM_Account__c IN : euAccountIdsToProcess])
            {
                prSegmentationsMap.put(segmentation.EUR_CRM_Account__c, segmentation);
            }

            System.debug(euAccountCountryCodes);
            
            for(EUR_CRM_PRS_Seg_Aspect__c bbp : EUR_CRM_PRSegmentationClass.returnBrandBuildingPotentialByCountry(euAccountCountryCodes)){
                bbpMap.put(createKey(bbp.EUR_CRM_Country_Code__c, bbp.EUR_CRM_Segmentation_BBP_Aspect_Name__c), bbp);
            }
            for(EUR_CRM_PRS_Seg_Aspect__c bp : EUR_CRM_PRSegmentationClass.returnBusinessPotentialsByCountry(euAccountCountryCodes)){
                bpMap.put(createKey(bp.EUR_CRM_Country_Code__c, bp.EUR_CRM_Segmentation_BP_Aspect_Name__c), bp);
            }
            for(EUR_CRM_PRS_Seg_Aspect__c il : EUR_CRM_PRSegmentationClass.returnImageLevelsByCountry(euAccountCountryCodes)){
                ilMap.put(createKey(il.EUR_CRM_Country_Code__c, il.EUR_CRM_Segmentation_IL_Aspect_Name__c), il);
            }
            for(EUR_CRM_PRS_Seg_Aspect__c vp : EUR_CRM_PRSegmentationClass.returnVolumePotentialsByCountry(euAccountCountryCodes)){
                vpMap.put(createKey(vp.EUR_CRM_Country_Code__c, vp.EUR_CRM_Segmentation_VP_Aspect_Name__c), vp);
            }
            for(EUR_CRM_PRS_Group_Outlet_Type__c got : EUR_CRM_PRSegmentationClass.returnGroupOutletTypeByCountry(euAccountCountryCodes)){
                groupOutletTypeMap.put(createKey(got.EUR_CRM_Country_Code__c, got.EUR_CRM_Group_Outlet_Type_Name__c), got);
            }
            for(EUR_CRM_PRS_Outlet_Type__c ot : EUR_CRM_PRSegmentationClass.returnOutletTypeByCountry(euAccountCountryCodes)){
                outletTypeMap.put(createKey(ot.EUR_CRM_Country_Code__c, ot.EUR_CRM_PRS_Outlet_Type_Name__c), ot);
            }

            System.debug(bpMap);

            // Process the EU Accounts
            for(EUR_CRM_Account__c acc : euAccountsToProcess){
                System.debug(acc.EUR_CRM_Force_GOT_OT_by_CT__c);
                System.debug(oldEuAccountMap.get(acc.Id).EUR_CRM_Force_GOT_OT_by_CT__c);
                //
                // If force by customer taxonomy
                //
                if(acc.EUR_CRM_Force_GOT_OT_by_CT__c != oldEuAccountMap.get(acc.Id).EUR_CRM_Force_GOT_OT_by_CT__c){
                    // A value is assgined
                    System.debug('force by CT');
                    system.debug(acc.EUR_CRM_Force_GOT_OT_by_CT__c);
                    if(acc.EUR_CRM_Force_GOT_OT_by_CT__c == true){
                        System.debug(acc.EUR_JB_Customer_Taxonomy__c);
                        // Assign from customer taxonomy data
                        acc.EUR_CRM_PRS_Group_Outlet_Type__c = customerTaxonomyMap.get(acc.EUR_JB_Customer_Taxonomy__c).EUR_CRM_PRS_Group_Outlet_Type__c;
                        acc.EUR_CRM_PRS_Outlet_Type__c = customerTaxonomyMap.get(acc.EUR_JB_Customer_Taxonomy__c).EUR_CRM_PRS_Outlet_Type__c;
                        acc.EUR_CRM_Force_Group_Outlet_Type__c = null;
                        acc.EUR_CRM_Force_Outlet_Type__c = null;
                    }
                    // clear old GOT and OT values
                    else {
                        System.debug('ENETERED ELSE');
                        acc.EUR_CRM_PRS_Group_Outlet_Type__c = prSegmentationsMap.get(acc.Id).EUR_CRM_PRS_Group_Outlet_Type__c;
                        acc.EUR_CRM_PRS_Outlet_Type__c = prSegmentationsMap.get(acc.Id).EUR_CRM_PRS_Outlet_Type__c;     
                    }
                }

                //
                // If force PRS GOT
                //
                if(acc.EUR_CRM_Force_Group_Outlet_Type__c != oldEuAccountMap.get(acc.Id).EUR_CRM_Force_Group_Outlet_Type__c){
                    if(acc.EUR_CRM_Force_Group_Outlet_Type__c != null){
                        acc.EUR_CRM_PRS_Group_Outlet_Type__c = groupOutletTypeMap.get(createKey(acc.EUR_CRM_Country_Code__c, acc.EUR_CRM_Force_Group_Outlet_Type__c)).Id;
                        acc.EUR_CRM_Force_GOT_OT_by_CT__c = false;
                    }
                    else{
                        if(acc.EUR_CRM_Force_GOT_OT_by_CT__c == false){
                            acc.EUR_CRM_PRS_Group_Outlet_Type__c = prSegmentationsMap.get(acc.Id).EUR_CRM_PRS_Group_Outlet_Type__c;
                            acc.EUR_CRM_PRS_Outlet_Type__c = prSegmentationsMap.get(acc.Id).EUR_CRM_PRS_Outlet_Type__c;
                        }
                    }
                }

                //
                // If force PRS OT
                //
                if(acc.EUR_CRM_Force_Outlet_Type__c != oldEuAccountMap.get(acc.Id).EUR_CRM_Force_Outlet_Type__c){
                    if(acc.EUR_CRM_Force_Outlet_Type__c != null){
                        System.debug(outletTypeMap);
                        System.debug(createKey(acc.EUR_CRM_Country_Code__c, acc.EUR_CRM_Force_Outlet_Type__c));
                        acc.EUR_CRM_PRS_Outlet_Type__c = outletTypeMap.get(createKey(acc.EUR_CRM_Country_Code__c, acc.EUR_CRM_Force_Outlet_Type__c)).Id;
                    }
                }

                //
                //  If force BBP
                //
                if(acc.EUR_CRM_Force_Brand_Building_Potential__c != oldEuAccountMap.get(acc.Id).EUR_CRM_Force_Brand_Building_Potential__c){
                    System.Debug('Is_BBP_Force:' + acc.EUR_CRM_Force_Brand_Building_Potential__c );
                    if(acc.EUR_CRM_Force_Brand_Building_Potential__c != null){
                        acc.EUR_CRM_Brand_Building_Potential__c = bbpMap.get(createKey(acc.EUR_CRM_Country_Code__c, acc.EUR_CRM_Force_Brand_Building_Potential__c)).Id;
                    }
                    else{
                        acc.EUR_CRM_Brand_Building_Potential__c = prSegmentationsMap.get(acc.Id).EUR_CRM_Brand_Building_Potential__c;    
                    }
                }
                
                //
                //  If force BP
                //
                if(acc.EUR_CRM_Force_Business_potential__c != oldEuAccountMap.get(acc.Id).EUR_CRM_Force_Business_potential__c){
                    System.Debug('Is_BP_Force:' + acc.EUR_CRM_Force_Business_potential__c);
                    if(acc.EUR_CRM_Force_Business_potential__c != null){
                        acc.EUR_CRM_Business_Potential__c = bpMap.get(createKey(acc.EUR_CRM_Country_Code__c, acc.EUR_CRM_Force_Business_potential__c)).Id;
                    }
                    else{
                        acc.EUR_CRM_Business_Potential__c = prSegmentationsMap.get(acc.Id).EUR_CRM_Business_Potential__c;    
                    }
                }

                //
                //  If force IM
                //
                if(acc.EUR_CRM_Force_PRS_Image_Level__c != oldEuAccountMap.get(acc.Id).EUR_CRM_Force_PRS_Image_Level__c){
                    System.Debug('Is_IM_Force:' + acc.EUR_CRM_Force_PRS_Image_Level__c );
                    if(acc.EUR_CRM_Force_PRS_Image_Level__c != null){
                        acc.EUR_CRM_PRS_Image_Level__c = ilMap.get(createKey(acc.EUR_CRM_Country_Code__c, acc.EUR_CRM_Force_PRS_Image_Level__c)).Id;
                    }
                    else{
                        acc.EUR_CRM_PRS_Image_Level__c = prSegmentationsMap.get(acc.Id).EUR_CRM_Image_Level__c;    
                    }
                } 

                //
                //  If force VP
                //
                if(acc.EUR_CRM_Force_PRS_Volume_Potential__c != oldEuAccountMap.get(acc.Id).EUR_CRM_Force_PRS_Volume_Potential__c){
                    System.Debug('Is_VP_Force:' + acc.EUR_CRM_Force_PRS_Volume_Potential__c );
                    if(acc.EUR_CRM_Force_PRS_Volume_Potential__c != null){
                        acc.EUR_CRM_PRS_Volume_Potential__c = vpMap.get(createKey(acc.EUR_CRM_Country_Code__c, acc.EUR_CRM_Force_PRS_Volume_Potential__c)).Id;
                    }
                    else{
                        acc.EUR_CRM_PRS_Volume_Potential__c = prSegmentationsMap.get(acc.Id).EUR_CRM_Volume_Potential__c;    
                    }
                }

                //
                //  Assign the Priority Level Matrix
                //
                assignPriorityMatrix(acc); 
            }            
        }
    }


    /*************************************************************************************
    *   Assigns he Priority Matric according to the final values of BBP and BP
    *   Retrieves the criteria from the helper function
    *************************************************************************************/
    private void assignPriorityMatrix(EUR_CRM_Account__c euAccount){
        List<EUR_CRM_PRS_Priority_Level_Criteria__c> priorityLevelMatricesList = EUR_CRM_PRSegmentationClass.returnPriorityLevelMatrices(euAccount.EUR_CRM_Country_Code__c);
        Map<String, EUR_CRM_PRS_Priority_Level_Criteria__c> priorityLevelMatricesMap = new Map<String, EUR_CRM_PRS_Priority_Level_Criteria__c>(); // Key is BBP+BP Ids
        // Populate the map
        String key;
        for(EUR_CRM_PRS_Priority_Level_Criteria__c matrix : priorityLevelMatricesList){
            key = createKey(matrix.EUR_CRM_Brand_Building_Potential__c, matrix.EUR_CRM_Business_Potential__c);
            priorityLevelMatricesMap.put(key, matrix);
        }
        // Popuate the correct field in the euAccount
        key = createKey(euAccount.EUR_CRM_Brand_Building_Potential__c, euAccount.EUR_CRM_Business_Potential__c);
        if(priorityLevelMatricesMap.get(key) != null){
            euAccount.EUR_CRM_PRS_Priority_Level_Criteria__c = priorityLevelMatricesMap.get(key).Id;
        }
    }

    /*
    *   function: createKey
    *   Helper function to create map key
    *   return: Map Key[String]
    */
    private String createKey(String a, String b){
        a = (a!=null) ? a.toLowerCase() : a;
        b = (b!=null) ? b.toLowerCase() : b;  
        return a+b;
    }
}