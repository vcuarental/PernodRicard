/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/


@isTest
public class LAT_ReferenceProductTest {
	
    //MIGRATED 21/11/2016
    /*Test of a correct none duplicated product reference with SKU reference
	@isTest static void testUniqueProductValidSKU() {
        Utils.setMigrationDoneTest(false); 
        Product2 p = theProduct();
        List<LAT_ReferenceProduct__c> rfL = theReferenceProductList(1,p.id);
        LAT_ReferenceProduct.UniqueProduct(rfL,theOldReference(p.id,rfL.get(0)),False);
	}
    //MIGRATED 21/11/2016
    @isTest static void testUniqueProductValidSKUB() {
        Utils.setMigrationDoneTest(true); 
        LAT_Product__c p = theLATProduct();
        List<LAT_ReferenceProduct__c> rfL = theReferenceLATProductList(1,p.id);
        LAT_ReferenceProduct.UniqueProduct(rfL,theOldReference(p.id,rfL.get(0)),False);
    }


    //Test of a correct none duplicated product reference with keyBrand reference
    @isTest static void testUniqueProductValidKeyBrand() {
        Utils.setMigrationDoneTest(false); 
         LAT_KeyBrand__c kb= theKeyBrand();
        Product2 p = theProduct();
         List<LAT_ReferenceProduct__c> rfL = theReferenceProductList(2,kb.id);
        LAT_ReferenceProduct.UniqueProduct(rfL,theOldReference(p.id,rfL.get(0)),False);
    }
    //MIGRATED 21/11/2016
    @isTest static void testUniqueProductValidKeyBrandB() {
        Utils.setMigrationDoneTest(true); 
         LAT_KeyBrand__c kb= theKeyBrand();
        LAT_Product__c p = theLATProduct();
         List<LAT_ReferenceProduct__c> rfL = theReferenceLATProductList(2,kb.id);
        LAT_ReferenceProduct.UniqueProduct(rfL,theOldReference(p.id,rfL.get(0)),False);
    }


    //Test of a correct none duplicated product reference with scheReference
    @isTest static void testUniqueProductValidSche() {
        Utils.setMigrationDoneTest(false); 
        Product2 p = theProduct();
        LAT_ScheduleC__c sch = theSchedule();
         List<LAT_ReferenceProduct__c> rfL=theReferenceProductList(3,sch.id);
        LAT_ReferenceProduct.UniqueProduct(rfL,theOldReference(p.id,rfL.get(0)),False);
    }
    //MIGRATED 21/11/2016
    @isTest static void testUniqueProductValidScheB() {
        Utils.setMigrationDoneTest(true); 
        LAT_Product__c p = theLATProduct();
        LAT_ScheduleC__c sch = theSchedule();
         List<LAT_ReferenceProduct__c> rfL=theReferenceLATProductList(3,sch.id);
        LAT_ReferenceProduct.UniqueProduct(rfL,theOldReference(p.id,rfL.get(0)),False);
    }

     //Test of a duplicated reference product of schedule.
    @isTest static void testDuplicatedReferenceProductSch() {
        Utils.setMigrationDoneTest(false); 
        Product2 p = theProduct();
        LAT_ScheduleC__c sch = theSchedule();
        List<LAT_ReferenceProduct__c> prodL = theReferenceProductList(3,sch.id);
        prodl.addall(theReferenceProductList(3,sch.id));
        LAT_ReferenceProduct.UniqueProduct(prodL,theOldReference(p.id,prodL.get(0)),False);
    }
    //MIGRATED 21/11/2016
    @isTest static void testDuplicatedReferenceProductSchB() {
        Utils.setMigrationDoneTest(true); 
        LAT_Product__c p = theLATProduct();
        LAT_ScheduleC__c sch = theSchedule();
        List<LAT_ReferenceProduct__c> prodL = theReferenceLATProductList(3,sch.id);
        prodl.addall(theReferenceLATProductList(3,sch.id));
        LAT_ReferenceProduct.UniqueProduct(prodL,theOldReference(p.id,prodL.get(0)),False);
    }


    //Test of a duplicated reference product of SKU.
    @isTest static void testDuplicatedReferenceProductSKU() {
        Utils.setMigrationDoneTest(false); 
       Product2 p = theProduct();
       List<LAT_ReferenceProduct__c> prodL = theReferenceProductList(1,p.id);
       prodl.addall(theReferenceProductList(1,p.id));
       LAT_ReferenceProduct.UniqueProduct(prodL,theOldReference(p.id,prodL.get(0)),False);
    }
    //MIGRATED 21/11/2016
    @isTest static void testDuplicatedReferenceProductSKUB() {
        Utils.setMigrationDoneTest(true); 
       LAT_Product__c p = theLATProduct();
       List<LAT_ReferenceProduct__c> prodL = theReferenceLATProductList(1,p.id);
       prodl.addall(theReferenceLATProductList(1,p.id));
       LAT_ReferenceProduct.UniqueProduct(prodL,theOldReference(p.id,prodL.get(0)),False);
    }

    //Test of a duplicated reference product of KeyBrand.
    @isTest static void testDuplicatedReferenceProductKeyBrand() {
        Utils.setMigrationDoneTest(false); 
        Product2 p = theProduct();
        LAT_KeyBrand__c kb= theKeyBrand();
        List<LAT_ReferenceProduct__c> prodL = theReferenceProductList(2,kb.id);
        prodl.addall(theReferenceProductList(2,kb.id));
        LAT_ReferenceProduct.UniqueProduct(prodL,theOldReference(p.id,prodL.get(0)),False);
    }
    //MIGRATED 21/11/2016
    @isTest static void testDuplicatedReferenceProductKeyBrandB() {
        Utils.setMigrationDoneTest(true); 
        LAT_Product__c p = theLATProduct();
        LAT_KeyBrand__c kb= theKeyBrand();
        List<LAT_ReferenceProduct__c> prodL = theReferenceLATProductList(2,kb.id);
        prodl.addall(theReferenceLATProductList(2,kb.id));
        LAT_ReferenceProduct.UniqueProduct(prodL,theOldReference(p.id,prodL.get(0)),False);
    }


    // Test of a incorrect reference product. The reference keyBrand, Schedule or SKU empty
	@isTest static void testUniqueProductEmpty() {
        Utils.setMigrationDoneTest(false); 
        Product2 p = theProduct();
        List<LAT_ReferenceProduct__c> rfL =theReferenceProductList(9,p.id);
        LAT_ReferenceProduct.UniqueProduct(rfL,theOldReference(p.id,rfL.get(0)),False);
	}
    //MIGRATED 21/11/2016
    @isTest static void testUniqueProductEmptyB() {
        Utils.setMigrationDoneTest(true); 
        LAT_Product__c p = theLATProduct();
        List<LAT_ReferenceProduct__c> rfL =theReferenceLATProductList(9,p.id);
        LAT_ReferenceProduct.UniqueProduct(rfL,theOldReference(p.id,rfL.get(0)),False);
    }
   
    // Test of a incorrect reference product. The reference keyBrand and SKU have both a value
	@isTest static void testUniqueProductError1() {
        Utils.setMigrationDoneTest(false); 
        Product2 p = theProduct();
        List<LAT_ReferenceProduct__c> rfL =theReferenceProductList(4,p.id);
        LAT_ReferenceProduct.UniqueProduct(rfL,theOldReference(p.id,rfL.get(0)),False);
	}
    //MIGRATED 21/11/2016
    @isTest static void testUniqueProductError1B() {
        Utils.setMigrationDoneTest(true); 
        LAT_Product__c p = theLATProduct();
        List<LAT_ReferenceProduct__c> rfL =theReferenceLATProductList(4,p.id);
        LAT_ReferenceProduct.UniqueProduct(rfL,theOldReference(p.id,rfL.get(0)),False);
    }

// Test of a incorrect reference product. The reference SKU and Schedule have both a value
	@isTest static void testUniqueProductError2() {
        Utils.setMigrationDoneTest(false); 
        Product2 p = theProduct();
        List<LAT_ReferenceProduct__c> rfL = theReferenceProductList(6,p.id);
        LAT_ReferenceProduct.UniqueProduct(rfL,theOldReference(p.id,rfL.get(0)),False);
	}
    //MIGRATED 21/11/2016
    @isTest static void testUniqueProductError2B() {
        Utils.setMigrationDoneTest(true); 
        LAT_Product__c p = theLATProduct();
        List<LAT_ReferenceProduct__c> rfL = theReferenceLATProductList(6,p.id);
        LAT_ReferenceProduct.UniqueProduct(rfL,theOldReference(p.id,rfL.get(0)),False);
    }
// Test of a incorrect reference product. The reference keyBrand and Schedule have both a value
	@isTest static void testUniqueProductError3() {
        Utils.setMigrationDoneTest(false); 
        Product2 p = theProduct();
        List<LAT_ReferenceProduct__c> rfL=theReferenceProductList(5,p.id);
        LAT_ReferenceProduct.UniqueProduct(rfL,theOldReference(p.id,rfL.get(0)),False);
    }
    //MIGRATED 21/11/2016
    @isTest static void testUniqueProductError3B() {
        Utils.setMigrationDoneTest(true); 
        LAT_Product__c p = theLATProduct();
        List<LAT_ReferenceProduct__c> rfL=theReferenceLATProductList(5,p.id);
        LAT_ReferenceProduct.UniqueProduct(rfL,theOldReference(p.id,rfL.get(0)),False);
    }*/
//KeyBrand creator
    public static LAT_KeyBrand__c theKeyBrand(){
        LAT_KeyBrand__c kb = new LAT_KeyBrand__c();
        kb.ExternalId__c = 'AAA';
        kb.Key__c = 'BBB';
        kb.Active__c = true;
        insert kb;
        return kb;
    }
//Schedule creator
    public static LAT_ScheduleC__c theSchedule(){
        LAT_ScheduleC__c sche = new LAT_ScheduleC__c();
        sche.ExternalId__c = 'AAA';
        sche.Key__c = 'BBB';
        sche.Active__c = true;
        sche.KeyBrand__c = theKeyBrand().id;
        insert sche;
        return sche;
    } 
    public static Product2 theProduct(){
        Product2 p  = lat_cota_test.getProduct();
        p.LAT_IsRefactorProduct__c = 'Y';
        p.isActive = true;
        p.RecordTypeId = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );

        insert p;
        return p;
    }  
    //MIGRATED 21/11/2016
    public static LAT_Product__c theLATProduct(){
        LAT_Product__c p  = lat_cota_test.LAT_getProduct();
        p.LAT_IsRefactorProduct__c = 'Y';
        p.LAT_isActive__c = true;
        p.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );

        insert p;
        return p;
    } 
    
    //Reference product list creator, (integer = type of ref, Id = id of ref)
    public static List<LAT_ReferenceProduct__c> theReferenceProductList(Integer typeRef,Id prodId){
        LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c( Name = 'Testing' );
        insert rpg;
        
        LAT_ReferenceProduct__c rp = new LAT_ReferenceProduct__c();
        if(typeRef == 1){
            rp.SKURef__c =prodId;
        }else if(typeRef == 2){
            rp.KeyBrandRef__c = prodId;
        }else if(typeRef == 3){
            rp.SchCRef__c = prodId;
        }else if(typeRef == 4){
            rp.KeyBrandRef__c = theKeyBrand().id;
            rp.SKURef__c =prodId;
        }else if(typeRef == 5){
            LAT_ScheduleC__c sche =theSchedule();
            rp.SchCRef__c =  sche.id;
            rp.KeyBrandRef__c = sche.KeyBrand__c;
        }else if(typeRef == 6){
            rp.SchCRef__c = theSchedule().id;
            rp.SKURef__c =prodId;
        }

        rp.Type__c='sku';
        rp.ReferenceGrouping__c = rpg.id;
        rp.isActive__c = true;

        if (typeRef == 1 || typeRef == 2 || typeRef == 3) {
            try {
                insert rp;
            } catch (Exception e){
                
            }
        }

        List<LAT_ReferenceProduct__c> rpL = new List<LAT_ReferenceProduct__c>();
        rpL.add(rp);
        return rpL;
    }
    //MIGRATED 21/11/2016
     public static List<LAT_ReferenceProduct__c> theReferenceLATProductList(Integer typeRef,Id prodId){
        LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c( Name = 'Testing' );
        insert rpg;
        
        LAT_ReferenceProduct__c rp = new LAT_ReferenceProduct__c();
        if(typeRef == 1){
            rp.LAT_Product__c =prodId;
        }else if(typeRef == 2){
            rp.KeyBrandRef__c = prodId;
        }else if(typeRef == 3){
            rp.SchCRef__c = prodId;
        }else if(typeRef == 4){
            rp.KeyBrandRef__c = theKeyBrand().id;
            rp.LAT_Product__c =prodId;
        }else if(typeRef == 5){
            LAT_ScheduleC__c sche =theSchedule();
            rp.SchCRef__c =  sche.id;
            rp.KeyBrandRef__c = sche.KeyBrand__c;
        }else if(typeRef == 6){
            rp.SchCRef__c = theSchedule().id;
            rp.LAT_Product__c =prodId;
        }

        rp.Type__c='sku';
        rp.ReferenceGrouping__c = rpg.id;
        rp.isActive__c = true;

        if (typeRef == 1 || typeRef == 2 || typeRef == 3) {
            try {
                insert rp;
            } catch (Exception e){
                
            }
        }

        List<LAT_ReferenceProduct__c> rpL = new List<LAT_ReferenceProduct__c>();
        rpL.add(rp);
        return rpL;
    }

    public static Map<id,LAT_ReferenceProduct__c> theOldReference(Id prodId,LAT_ReferenceProduct__c rf){
        Map<id,LAT_ReferenceProduct__c> m = new  Map<id,LAT_ReferenceProduct__c>();
        m.put(prodID,rf);
        return m;
    }
}