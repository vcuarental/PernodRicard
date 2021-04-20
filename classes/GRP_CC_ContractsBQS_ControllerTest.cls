/**
* @description 
* this class is used to test GRP_CC_ContractsBQS_Controller class to assure the proper working 
* and a required code coverage 
*/
@isTest
private class GRP_CC_ContractsBQS_ControllerTest {
	
    /**
	* @description 
	* this method is used to test a getBrandQualitySizeToAssosiate method
	*/
    static testmethod void TestMethod_getBrandQualitySizeToAssosiate() {
        test.startTest();
        
        String contract_id = TestMethod_init_data();
        CORE_BrandQualitySize__c[] bqs_not_included = GRP_CC_ContractsBQS_Controller.getBrandQualitySizeToAssosiate(contract_id);
        
        System.assertEquals(2, bqs_not_included.size());
        
        Set<String> bqs_names = new Set<String>();
        bqs_names.add('Malibu Coco 0.75L');
        bqs_names.add('Malibu Coco 1L');
        for (Integer i=0; i<bqs_not_included.size(); i++){
            System.assertEquals(true, bqs_names.contains(bqs_not_included.get(i).Name));
        }
        
        test.stopTest();
    }
    
    /**
	* @description 
	* this method is used to test a getBrandQualitySizeAssosiated method
	*/
    static testmethod void TestMethod_getBrandQualitySizeAssosiated() {
        test.startTest();
        
        String contract_id = TestMethod_init_data();
        CORE_BrandQualitySize__c[] bqs_included = GRP_CC_ContractsBQS_Controller.getBrandQualitySizeAssosiated(contract_id);
        
        System.assertEquals(2, bqs_included.size());
        
        Set<String> bqs_names = new Set<String>();
        bqs_names.add('Malibu Coco 0.5L');
        bqs_names.add('ABSOLUT Elyx 1L');
        for (Integer i=0; i<bqs_included.size(); i++){
            System.assertEquals(true, bqs_names.contains(bqs_included.get(i).Name));
        }
        
        test.stopTest();
    }
    
    /**
	* @description 
	* this method is used to test a insertBrandQualitySizeToContract method (Contracts creation)
	*/
    static testmethod void TestMethod_insertBrandQualitySizeToContract() {
        test.startTest();    
        
        String contract_id = TestMethod_init_data();
        
        CORE_BrandQualitySize__c[] bqs = [Select Id, Name 
                                          from CORE_BrandQualitySize__c 
                                          where Name in 
                                          		('Malibu Coco 0.75L','Malibu Coco 1L')
                                         ];
        String bqs_ids='';
        for (Integer i=0; i<bqs.size(); i++){
            bqs_ids=bqs_ids+bqs.get(i).id+';';
        }
        
        GRP_CC_ContractsBQS_Controller.insertBrandQualitySizeToContract(contract_id, bqs_ids);
        
        CORE_BrandQualitySize__c[] bqs_after_insert = [Select Id, Name 
                                          from CORE_BrandQualitySize__c 
                                          where id in 
                                          		(select GRP_CC_BrandQualitySize__c 
                                                 from GRP_CC_Contract_BQS_Link__c 
                                                 where GRP_CC_Contract__c=:contract_id)
                                         ];
        
        System.assertEquals(4, bqs_after_insert.size());
        
        Set<String> bqs_names = new Set<String>();
        bqs_names.add('Malibu Coco 0.5L');
        bqs_names.add('Malibu Coco 0.75L');
        bqs_names.add('Malibu Coco 1L');
        bqs_names.add('ABSOLUT Elyx 1L');
        for (Integer i=0; i<bqs_after_insert.size(); i++){
            System.assertEquals(true, bqs_names.contains(bqs_after_insert.get(i).Name));
        }
        
        test.stopTest();
    }
    
    /**
	* @description 
	* this method is used to test a deleteBrandQualitySizeFromContract method (Contracts removing)
	*/
    static testmethod void TestMethod_deleteBrandQualitySizeFromContract() {
        test.startTest();    
        
        String contract_id = TestMethod_init_data();
        
        CORE_BrandQualitySize__c[] bqs = [Select Id, Name 
                                          from CORE_BrandQualitySize__c 
                                          where Name in 
                                          		('Malibu Coco 0.5L')
                                         ];
        String bqs_ids='';
        for (Integer i=0; i<bqs.size(); i++){
            bqs_ids=bqs_ids+bqs.get(i).id+';';
        }
        
        GRP_CC_ContractsBQS_Controller.deleteBrandQualitySizeFromContract(contract_id, bqs_ids);
        
        CORE_BrandQualitySize__c[] bqs_after_delete = [Select Id, Name 
                                          from CORE_BrandQualitySize__c 
                                          where id in 
                                          		(select GRP_CC_BrandQualitySize__c 
                                                 from GRP_CC_Contract_BQS_Link__c 
                                                 where GRP_CC_Contract__c=:contract_id)
                                         ];
        
        System.assertEquals(1, bqs_after_delete.size());
        
        Set<String> bqs_names = new Set<String>();
        bqs_names.add('ABSOLUT Elyx 1L');
        for (Integer i=0; i<bqs_after_delete.size(); i++){
            System.assertEquals(true, bqs_names.contains(bqs_after_delete.get(i).Name));
        }
        
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
        
        GRP_CC_ContractBQ__c contract_bq1 = new GRP_CC_ContractBQ__c(GRP_CC_Contract__c=contract.id, GRP_CC_BrandQuality__c=brand_quality1.id);
        insert contract_bq1;
        
        GRP_CC_ContractBQ__c contract_bq2 = new GRP_CC_ContractBQ__c(GRP_CC_Contract__c=contract.id, GRP_CC_BrandQuality__c=brand_quality2.id);
        insert contract_bq2;
        
        GRP_CC_Contract_BQS_Link__c contract_bqs1 = new GRP_CC_Contract_BQS_Link__c(GRP_CC_Contract__c=contract.id, GRP_CC_BrandQualitySize__c=brand_quality_size1.id);
        insert contract_bqs1;
        
        GRP_CC_Contract_BQS_Link__c contract_bqs2 = new GRP_CC_Contract_BQS_Link__c(GRP_CC_Contract__c=contract.id, GRP_CC_BrandQualitySize__c=brand_quality_size4.id);
        insert contract_bqs2;
        
        return contract.id;
    }
    
    
    
    
}