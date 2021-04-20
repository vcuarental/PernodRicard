/**
* @description 
* this class is used to test GRP_CC_ContractsBQ_Controller class to assure the proper working 
* and a required code coverage 
*/
@isTest
private class GRP_CC_ContractsBQ_ControllerTest {
  
    /**
  * @description 
  * this method is used to test a getBrandQualityToAssosiate method
  */
    static testmethod void TestMethod_getBrandQualityToAssosiate() {
        test.startTest();
        
        String contract_id = TestMethod_init_data();
        CORE_BrandQuality__c[] bq_not_included = GRP_CC_ContractsBQ_Controller.getBrandQualityToAssosiate(contract_id);
        
        System.assertEquals(1, bq_not_included.size());
        
        Set<String> bq_names = new Set<String>();
        bq_names.add('ABSOLUT Peppar');
        for (Integer i=0; i<bq_not_included.size(); i++){
            System.assertEquals(true, bq_names.contains(bq_not_included.get(i).Name));
        }
        
        test.stopTest();
    }
    
    /**
  * @description 
  * this method is used to test a getContractsBrandQualityAssosiatedFull method
  */
    static testmethod void TestMethod_getBrandQualitySizeAssosiated_Full() {
        test.startTest();
        
        String contract_id = TestMethod_init_data();
        CORE_BrandQuality__c[] bq_included = GRP_CC_ContractsBQ_Controller.getBrandQualityAssosiated(contract_id);
        
        System.assertEquals(2, bq_included.size());
        
        GRP_CC_ContractBQ__c[] bq_included_full = GRP_CC_ContractsBQ_Controller.getContractsBrandQualityAssosiatedFull(contract_id);
        System.assertEquals(2, bq_included_full.size());
        
        Set<String> bq_names = new Set<String>();
        bq_names.add('Malibu Coco');
        bq_names.add('ABSOLUT Elyx');
        for (Integer i=0; i<bq_included.size(); i++){
            System.assertEquals(true, bq_names.contains(bq_included.get(i).Name));
        }
        
        test.stopTest();
    }
    
    /**
  * @description 
  * this method is used to test a getNegotiatedRebateToBePaidPerPickListValues method
  */
    static testmethod void TestMethod_getNegotiatedRebateToBePaidPerPickListValues(){
        test.startTest();
        
        List<String> picklist_values = GRP_CC_ContractsBQ_Controller.getNegotiatedRebateToBePaidPerPickListValues();
        System.assertEquals(true, picklist_values.size()>0);
        
        test.stopTest();
    }
    
    /**
  * @description 
  * this method is used to test a insertBrandQualityToContract method
  */
    static testmethod void TestMethod_insertBrandQualityToContract(){
        test.startTest();
        
        String contract_id = TestMethod_init_data();
        CORE_BrandQuality__c[] bq = [Select Id, Name 
                                          from CORE_BrandQuality__c 
                                          where Name in 
                                              ('ABSOLUT Peppar')
                                         ];
        GRP_CC_ContractBQ__c[] contractsBQ_before_insert = [Select Id
                                              from GRP_CC_ContractBQ__c 
                                              where GRP_CC_Contract__c=:contract_id and GRP_CC_BrandQuality__c=:bq.get(0).id
                                           ];
        System.assertEquals(true, contractsBQ_before_insert.size()==0);
        GRP_CC_ContractsBQ_Controller.insertBrandQualityToContract(contract_id, bq.get(0).id+';');
        GRP_CC_ContractBQ__c[] contractsBQ_after_insert = [Select Id
                                              from GRP_CC_ContractBQ__c 
                                              where GRP_CC_Contract__c=:contract_id and GRP_CC_BrandQuality__c=:bq.get(0).id
                                           ];
        System.assertEquals(true, contractsBQ_after_insert.size()==1);
        
        test.stopTest();
    }
    
    /**
  * @description 
  * this method is used to test a deleteBrandQualitySizeFromContract method
  */
    static testmethod void TestMethod_deleteBrandQualitySizeFromContract() {
        test.startTest();
        
        String contract_id = TestMethod_init_data();
        
        CORE_BrandQuality__c[] bq = [Select Id, Name 
                                          from CORE_BrandQuality__c 
                                          where Name in 
                                              ('Malibu Coco')
                                         ];
    String bq_ids='';
        for (Integer i=0; i<bq.size(); i++){
            bq_ids=bq_ids+bq.get(i).id+';';
        }
        
        GRP_CC_ContractsBQ_Controller.deleteBrandQualitySizeFromContract(contract_id, bq_ids);
        
        CORE_BrandQuality__c[] bq_after_delete = [Select Id, Name 
                                          from CORE_BrandQuality__c 
                                          where id in 
                                              (select GRP_CC_BrandQuality__c 
                                                 from GRP_CC_ContractBQ__c 
                                                 where GRP_CC_Contract__c=:contract_id)
                                         ];
        
        CORE_BrandQualitySize__c[] bqs_after_delete = [Select Id, Name 
                                          from CORE_BrandQualitySize__c 
                                          where id in 
                                              (select GRP_CC_BrandQualitySize__c 
                                                 from GRP_CC_Contract_BQS_Link__c 
                                                 where GRP_CC_Contract__c=:contract_id)
                                         ];
        
        System.assertEquals(1, bq_after_delete.size());
        System.assertEquals(1, bqs_after_delete.size());
        
        Set<String> bq_names = new Set<String>();
        bq_names.add('ABSOLUT Elyx');
        for (Integer i=0; i<bq_after_delete.size(); i++){
            System.assertEquals(true, bq_names.contains(bq_after_delete.get(i).Name));
        }
        
        test.stopTest();
    }
    
    /**
  * @description 
  * this method is used to test a updateContractBQ method
  */
    static testmethod void TestMethod_updateContractBQ(){
        test.startTest();
        
        String contract_id = TestMethod_init_data();
        CORE_BrandQuality__c[] bq = [Select Id, Name 
                                          from CORE_BrandQuality__c 
                                         where Name in 
                                              ('Malibu Coco')
                                         ];
        GRP_CC_ContractBQ__c[] contractsBQ = [Select Id, GRP_CC_BrandQuality__c, GRP_CC_Negotiated_Rebate_To_Be_Paid_Per__c, GRP_CC_Negotiated_Rebate__c, 
                                           /*GRP_CC_BackBar__c, (CCS-4171) */ GRP_CC_OnMenu__c, GRP_CC_Premium__c, GRP_CC_Pouring__c, GRP_CC_Rooms_Minibar__c, GRP_CC_Optional_Additions__c, GRP_CC_Meetings_Events__c /*, GRP_CC_SuperPremium__c (CCS-4171) */
                                              from GRP_CC_ContractBQ__c 
                                              where GRP_CC_Contract__c=:contract_id and GRP_CC_BrandQuality__c=:bq.get(0).id
                                           ];
        System.assert(true, contractsBQ.size()==1);
        //System.assert(true, contractsBQ.get(0).GRP_CC_BackBar__c==false);
        System.assert(true, contractsBQ.get(0).GRP_CC_OnMenu__c==false);
        System.assert(true, contractsBQ.get(0).GRP_CC_Premium__c==false);
        System.assert(true, contractsBQ.get(0).GRP_CC_Pouring__c==false);
		    //System.assert(true, contractsBQ.get(0).GRP_CC_SuperPremium__c==false);
        String contractsBQvalues = contractsBQ.get(0).id+'#'+contractsBQ.get(0).GRP_CC_Negotiated_Rebate_To_Be_Paid_Per__c+'#6#true#true#true#true#true#true#';  //#5#true#true#true#true#true#
        GRP_CC_ContractsBQ_Controller.updateContractBQ(contractsBQvalues);
        GRP_CC_ContractBQ__c contractsBQ_after_update = [Select Id, GRP_CC_BrandQuality__c, GRP_CC_Negotiated_Rebate_To_Be_Paid_Per__c, GRP_CC_Negotiated_Rebate__c, 
                                           /*GRP_CC_BackBar__c, (CCS-4171) */ GRP_CC_OnMenu__c, GRP_CC_Premium__c, GRP_CC_Pouring__c, GRP_CC_Rooms_Minibar__c, GRP_CC_Optional_Additions__c, GRP_CC_Meetings_Events__c /*, GRP_CC_SuperPremium__c (CCS-4171) */
                                              from GRP_CC_ContractBQ__c 
                                              where id=:contractsBQ.get(0).id
                                           ];
        System.assert(true, contractsBQ_after_update.GRP_CC_Negotiated_Rebate__c==5);
        //System.assert(true, contractsBQ_after_update.GRP_CC_BackBar__c==true);
        System.assert(true, contractsBQ_after_update.GRP_CC_OnMenu__c==true);
        System.assert(true, contractsBQ_after_update.GRP_CC_Premium__c==true);
        System.assert(true, contractsBQ_after_update.GRP_CC_Pouring__c==true);
		    //System.assert(true, contractsBQ_after_update.GRP_CC_SuperPremium__c==true);
        
        test.stopTest();
    }
    
    /**
  * @description 
  * this method is used to test a updateAllContractsBQ method
  */
    static testmethod void TestMethod_updateAllContractsBQ(){
        test.startTest();
        
        String contract_id = TestMethod_init_data();
        CORE_BrandQuality__c[] bq = [Select Id, Name
                                          from CORE_BrandQuality__c 
                                         where Name in 
                                              ('Malibu Coco', 'ABSOLUT Elyx')
                                         ];
        List<String> bq_ids = new list<String>();
        for (Integer i=0; i<bq.size(); i++){
            bq_ids.add(bq.get(i).id);
        }
        GRP_CC_ContractBQ__c[] contractsBQ = [Select Id, GRP_CC_BrandQuality__c, GRP_CC_Negotiated_Rebate_To_Be_Paid_Per__c, GRP_CC_Negotiated_Rebate__c, 
                                           /*GRP_CC_BackBar__c, (CCS-4171) */ GRP_CC_OnMenu__c, GRP_CC_Premium__c, GRP_CC_Pouring__c, GRP_CC_Rooms_Minibar__c, GRP_CC_Optional_Additions__c, GRP_CC_Meetings_Events__c /*, GRP_CC_SuperPremium__c (CCS-4171) */
                                              from GRP_CC_ContractBQ__c 
                                              where GRP_CC_Contract__c=:contract_id and GRP_CC_BrandQuality__c in :bq_ids
                                           ];
        System.assert(true, contractsBQ.size()==2);
        //System.assert(true, contractsBQ.get(0).GRP_CC_BackBar__c==false);
        //System.assert(true, contractsBQ.get(1).GRP_CC_BackBar__c==false);
        
        String contractsBQvalues = contractsBQ.get(0).id+'#'+contractsBQ.get(0).GRP_CC_Negotiated_Rebate_To_Be_Paid_Per__c+'#5#true#true#true#true#true#';
        contractsBQvalues = contractsBQvalues + contractsBQ.get(1).id+'#'+contractsBQ.get(1).GRP_CC_Negotiated_Rebate_To_Be_Paid_Per__c+'#5#true#true#true#true#true#';
        
        GRP_CC_ContractsBQ_Controller.updateAllContractsBQ(contractsBQ.get(0).id+'#'+contractsBQ.get(1).id+'#', contractsBQvalues);
        GRP_CC_ContractBQ__c[] contractsBQ_after_update = [Select Id, GRP_CC_BrandQuality__c, GRP_CC_Negotiated_Rebate_To_Be_Paid_Per__c, GRP_CC_Negotiated_Rebate__c, 
                                           /*GRP_CC_BackBar__c, (CCS-4171) */ GRP_CC_OnMenu__c, GRP_CC_Premium__c, GRP_CC_Pouring__c, GRP_CC_Rooms_Minibar__c, GRP_CC_Optional_Additions__c, GRP_CC_Meetings_Events__c /*, GRP_CC_SuperPremium__c (CCS-4171) */
                                              from GRP_CC_ContractBQ__c 
                                              where id=:contractsBQ.get(0).id or id=:contractsBQ.get(1).id
                                           ];
        
        System.assert(true, contractsBQ_after_update.get(0).GRP_CC_Negotiated_Rebate__c==5);
        //System.assert(true, contractsBQ_after_update.get(0).GRP_CC_BackBar__c==true);
        System.assert(true, contractsBQ_after_update.get(1).GRP_CC_Negotiated_Rebate__c==5);
        //System.assert(true, contractsBQ_after_update.get(1).GRP_CC_BackBar__c==true);
        
        test.stopTest();
    }
    
    
    
    /**
  * @description 
  * this method is used to create a necessary dataset for the tests
  */
    static private String TestMethod_init_data(){
        String brand_name1 = 'Malibu';
        CORE_Brand__c brand1 = new CORE_Brand__c(Name=brand_name1);
        insert brand1;
        String brand_name2 = 'ABSOLUT Vodka';
        CORE_Brand__c brand2 = new CORE_Brand__c(Name=brand_name2);
        insert brand2;
        
        String brand_quality_name1 = 'Malibu Coco';
        CORE_BrandQuality__c brand_quality1 = new CORE_BrandQuality__c(Name=brand_quality_name1, CORE_Category__c='Spirit', CORE_Brand__c=brand1.id);
        insert brand_quality1;
        String brand_quality_name2 = 'ABSOLUT Elyx';
        CORE_BrandQuality__c brand_quality2 = new CORE_BrandQuality__c(Name=brand_quality_name2, CORE_Category__c='Spirit', CORE_Brand__c=brand2.id);
        insert brand_quality2;
        String brand_quality_name3 = 'ABSOLUT Peppar';
        CORE_BrandQuality__c brand_quality3 = new CORE_BrandQuality__c(Name=brand_quality_name3, CORE_Category__c='Spirit', CORE_Brand__c=brand2.id);
        insert brand_quality3;
        
        CORE_Size__c size1 = new CORE_Size__c(Name='0.5L Bottle', CORE_Value__c=0.5);
        insert size1;
        CORE_Size__c size2 = new CORE_Size__c(Name='0.75L Bottle', CORE_Value__c=0.75);
        insert size2;
        CORE_Size__c size3 = new CORE_Size__c(Name='1L Bottle', CORE_Value__c=1);
        insert size3;
        
        CORE_BrandQualitySize__c brand_quality_size1 = new CORE_BrandQualitySize__c(Name='Malibu Coco 0.5L', CORE_Size__c=size1.id, CORE_BrandQuality__c=brand_quality1.id);
        insert brand_quality_size1;
        CORE_BrandQualitySize__c brand_quality_size2 = new CORE_BrandQualitySize__c(Name='Malibu Coco 0.75L', CORE_Size__c=size2.id, CORE_BrandQuality__c=brand_quality1.id);
        insert brand_quality_size2;
        CORE_BrandQualitySize__c brand_quality_size3 = new CORE_BrandQualitySize__c(Name='Malibu Coco 1L', CORE_Size__c=size3.id, CORE_BrandQuality__c=brand_quality1.id);
        insert brand_quality_size3;
        
        CORE_BrandQualitySize__c brand_quality_size4 = new CORE_BrandQualitySize__c(Name='ABSOLUT Elyx 1L', CORE_Size__c=size3.id, CORE_BrandQuality__c=brand_quality2.id);
        insert brand_quality_size4;
        CORE_BrandQualitySize__c brand_quality_size5 = new CORE_BrandQualitySize__c(Name='ABSOLUT Peppar 0.5L', CORE_Size__c=size1.id, CORE_BrandQuality__c=brand_quality3.id);
        insert brand_quality_size5;
        
        GRP_CC_Contract__c contract = new GRP_CC_Contract__c();
        contract.GRP_CC_Start_Date__c = date.today()-10;
        contract.GRP_CC_End_Date__c = date.today()+10;
        contract.GRP_CC_Category__c='Spirit';
        contract.Days_to_1st_Reminder_Chain_Acct_Resp__c = 10;
        contract.Days_to_2nd_Reminder_Chain_Acct_Resp__c = 20;
        contract.GRP_CC_Cycle__c = 1;
        insert contract;
        
        GRP_CC_ContractBQ__c contract_bq1 = new GRP_CC_ContractBQ__c(GRP_CC_Contract__c=contract.id, GRP_CC_BrandQuality__c=brand_quality1.id,/*GRP_CC_BackBar__c=false,*/ GRP_CC_OnMenu__c=false, GRP_CC_Premium__c=false, GRP_CC_Pouring__c=false, GRP_CC_Rooms_Minibar__c=false, GRP_CC_Optional_Additions__c=false, GRP_CC_Meetings_Events__c=false);
        insert contract_bq1;
        
        GRP_CC_ContractBQ__c contract_bq2 = new GRP_CC_ContractBQ__c(GRP_CC_Contract__c=contract.id, GRP_CC_BrandQuality__c=brand_quality2.id,/*GRP_CC_BackBar__c=false,*/ GRP_CC_OnMenu__c=false, GRP_CC_Premium__c=false, GRP_CC_Pouring__c=false, GRP_CC_Rooms_Minibar__c=false, GRP_CC_Optional_Additions__c=false, GRP_CC_Meetings_Events__c=false);
        insert contract_bq2;
        
        GRP_CC_Contract_BQS_Link__c contract_bqs1 = new GRP_CC_Contract_BQS_Link__c(GRP_CC_Contract__c=contract.id, GRP_CC_BrandQualitySize__c=brand_quality_size1.id);
        insert contract_bqs1;
        
        GRP_CC_Contract_BQS_Link__c contract_bqs2 = new GRP_CC_Contract_BQS_Link__c(GRP_CC_Contract__c=contract.id, GRP_CC_BrandQualitySize__c=brand_quality_size4.id);
        insert contract_bqs2;
        
        return contract.id;
    }
}