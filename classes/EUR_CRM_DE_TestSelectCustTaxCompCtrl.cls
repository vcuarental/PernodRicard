@isTest
public class EUR_CRM_DE_TestSelectCustTaxCompCtrl{
    
    @isTest
    public static void testComponent(){
        EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager){
            
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSet();
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test34434','DE_OFF_ALT_2nd_PL_Carton' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
           
        
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SECONDARY_PLACEMENT_CARTON ,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02); 
            insert objPromo;
            
            Test.startTest();           
            // START TEST ---       
            EUR_CRM_SelectCustTaxComponentController con = new EUR_CRM_SelectCustTaxComponentController();
            con.objPromoIdStr=objPromo.id;
            con.init();
            
            con.getChainOptions();
            con.chainValue = 'testchain1';
            con.getLevel1Options();
            
            con.level1Value= 'chain1level1';
            con.getLevel2Options();
            
            con.level2Value= 'chain1level2';
            con.getLevel3Options();
            
            con.level3Value= 'chain1level3';
            con.getLevel4Options();
            
            con.level4Value= 'chain1level4';
            con.getLevel5Options();
            
            con.level5Value= 'chain1level5';            
            con.getLevel6Options();         
               
            con.level6Value= 'chain1level6';
            con.getLevel7Options();            
            
            con.level7Value= 'chain1level7';
            con.getLevel8Options();            
            
            con.level8Value= 'chain1level8';
            
            con.filter();
            List<EUR_CRM_Customer_Taxonomy__c> l = con.customerTaxonomyList;
           // system.assert(l.size() > 0);
            con.getMgmtTypeOptions();
            con.save();
            con = new EUR_CRM_SelectCustTaxComponentController();
            con.objPromoIdStr=objPromo.id;
            con.init();

            con.getTaxList();
            con.first();
            con.last();
            con.previous();
            con.next();
            con.getPages();
            con.getRecordSize();
            con.getPageSize(); 
            Boolean a  = con.hasNext; 
            a = con.hasPrevious; 
            Integer x = con.pageNumber; 
            // STOP TEST ---    
            con.setMgmtTypeOptions();  
             List<EUR_CRM_Account__c> euAccountList =  con.euAccountList;
            a = con.initDummyVar;
            Test.stopTest(); 
        }
    }

}