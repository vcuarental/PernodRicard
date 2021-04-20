/*********************************************************************************
 * Name:ASI_TnE_ClaimsDetailValidatePOTest
 * Description: Apex test class for ASI_TnE_ClaimsDetailValidatePO
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 12/14/2015       DC                      Created
*********************************************************************************/

@isTest
public class ASI_TnE_ClaimsDetailValidatePOTest {
     
     
     public static testMethod void executeTriggerActionInsertTest(){
        //Create Running Numbers
        ASI_TnE_TW_TestClassHelper.createRunningNumbers();
        
        //Create Claim Header
        ASI_TnE_ClaimHeader__c oClaimHeader = ASI_TnE_TW_TestClassHelper.createClaimHeader();
        
        ASI_MFM_PO__c  poRecord = ASI_TnE_TW_TestClassHelper.createPO();                     
        
        Test.startTest();
        //Create Claim Detail Test
        ASI_TnE_ClaimDetail__c oClaimDetail = 
                   ASI_TnE_TW_TestClassHelper.createClaimDetail(oClaimHeader.Id, 
                                                                'ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail',
                                                                poRecord.Id);        
        
        try{
        insert oClaimDetail;
        
        oClaimDetail.ASI_TnE_Receipt_Amount__c = 200;
        update oClaimDetail;
        
        }Catch(Exception e){
            system.debug('**Exception Insert**' + e.getMessage());   
            system.assert(e <> null);
            system.assert(e.getMessage().contains('Exceeding the PO#'));
        } 
        
        Test.stopTest();
     }
     
     
     public static testMethod void executeTriggerActionUpdateTest(){
        //Create Running Numbers
        ASI_TnE_TW_TestClassHelper.createRunningNumbers();
        
        //Create Claim Header
        ASI_TnE_ClaimHeader__c oClaimHeader = ASI_TnE_TW_TestClassHelper.createClaimHeader();
        
        ASI_MFM_PO__c  poRecord = ASI_TnE_TW_TestClassHelper.createPO();                     
        
        Test.startTest();
        //Create Claim Detail Test
        ASI_TnE_ClaimDetail__c oClaimDetail = 
                   ASI_TnE_TW_TestClassHelper.createClaimDetail(oClaimHeader.Id, 
                                                                'ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail',
                                                                poRecord.Id);
        
        
        try{
        oClaimDetail.ASI_TnE_MFM_PO__c = null;
        insert oClaimDetail;
        oClaimDetail.ASI_TnE_MFM_PO__c = poRecord.Id;
        oClaimDetail.ASI_TnE_Receipt_Amount__c = 200;
        update oClaimDetail;
        
        }Catch(Exception e){
            system.debug('**Exception Update**' + e.getMessage());
            system.assert(e <> null);
            system.assert(e.getMessage().contains('Exceeding the PO#'));
        } 
        
        Test.stopTest();
     }
     
     /*
    public static testMethod void executeTriggerActionTest(){
        
        //Create Running Numbers
        ASI_TnE_TW_TestClassHelper.createRunningNumbers();
        
        system.debug('*****Soql Used Helper**** ' + System.Limits.getQueries());
        test.startTest();
        //Create Claim Header
        ASI_TnE_ClaimHeader__c oClaimHeader = ASI_TnE_TW_TestClassHelper.createClaimHeader();
        // ASI_TnE_ClaimHeader__c oClaimHeader1 = ASI_TnE_TW_TestClassHelper.createClaimHeader();
        
        system.debug('*****Soql Used Header**** ' + System.Limits.getQueries());
        //Create Claim Detail Test
        
        ASI_TnE_ClaimDetail__c oClaimDetail = ASI_TnE_TW_TestClassHelper.createClaimDetail(oClaimHeader.Id, 'ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail', 2);                        
        system.debug('*****Soql Used oClaimDetail**** ' + System.Limits.getQueries());
        test.stopTest();
    }
    
   
    public static testMethod void executeTriggerActionTest1(){
        
        //Create Running Numbers
        ASI_TnE_TW_TestClassHelper.createRunningNumbers();
        
        //Create Claim Header
        ASI_TnE_ClaimHeader__c oClaimHeader = ASI_TnE_TW_TestClassHelper.createClaimHeader();
        // ASI_TnE_ClaimHeader__c oClaimHeader1 = ASI_TnE_TW_TestClassHelper.createClaimHeader();
        
        //Create Claim Detail Test
        test.startTest();
        ASI_TnE_ClaimDetail__c oClaimDetail = ASI_TnE_TW_TestClassHelper.createClaimDetail(oClaimHeader.Id, 'ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail', 2);                        
        oclaimDetail.ASI_TnE_MFM_PO__c = NULL;
        update oClaimDetail;
        
        test.stopTest();
    }
    */
   
   /*
   DC - 01/28/2016 - Migrated these data creation methods to "ASI_TnE_TW_TestClassHelper" class
   public static ASI_MFM_PO__c createPO(){
       ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(Name = 'test', 
                                                    ASI_MFM_Module__c = 'Plan', 
                                                    Plan_Type__c = 'test', 
                                                    ASI_MFM_Fiscal_year__c = 'FY1516');
       insert px;   
       
       User u = [select userRole.developerName from user where id =: userInfo.getUserId()];  
       
       ASI_MFM_Role_Prefix_Relationship__c pr = 
                            new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = px.id, 
                                                                    ASI_MFM_Role_Name__c = u.userRole.developerName);
       insert pr;
       
       ASI_MFM_Plan__c p = 
                    new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_SG_Plan'), 
                                        Name= 'test', ASI_MFM_End_Date__c = Date.today().addMonths(1), 
                                        ASI_MFM_Plan_Description__c = 'testDescription', 
                                        ASI_MFM_Plan_Name__c = 'test', 
                                        ASI_MFM_Start_Date__c = Date.today().addMonths(1),  
                                        ASI_MFM_Prefix__c = px.id, ASI_MFM_Status__c = 'Final');
       insert p;
       
       Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Supplier'), 
                                 Name = 'Sample Account');           
       insert acc;
       
       ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(Name='test', 
                                                  ASI_MFM_Module__c = 'PO');
       insert pxo;

       ASI_MFM_Role_Prefix_Relationship__c pro = 
                   new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = pxo.id, 
                                                           ASI_MFM_Role_Name__c= u.userRole.developerName);
       insert pro;
    
       ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Status__c = 'Final', 
                                            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_SG_PO'), 
                                            Name = 'test123', ASI_MFM_Plan__c = p.id, 
                                            ASI_MFM_Invoice_Amount_from_JDE__c = 1000, 
                                            ASI_MFM_T_E_Amount__c = 1500, 
                                            ASI_MFM_T_E_Amount_Posted__c = 1200, 
                                            ASI_MFM_Prefix__c= pxo.id, 
                                            ASI_MFM_Supplier_Name__c = acc.id, 
                                            ASI_MFM_PO_End_Date__c = Date.today(),
                                            ASI_MFM_Exchange_Rate__c = 1);
       
       insert po;
       return po;
   }//End createPO method
   
   
   public static ASI_TnE_ClaimDetail__c createClaimDetail(Id pIdClaimHdr, String pRecordType, Id pPO_ID){
   
       ASI_TnE_ClaimDetail__c claimDtl = new ASI_TnE_ClaimDetail__c( ASI_TnE_ClaimHeader__c = pIdClaimHdr, 
                                                                     ASI_TnE_Receipt_Date__c = date.today(),
                                                                     ASI_TnE_Description__c = 'test description',
                                                                     ASI_TnE_Currency__c = 'TWD',
                                                                     ASI_TnE_Receipt_Amount__c = 100,
                                                                     ASI_TnE_FX_Rate__c = 1,
                                                                     ASI_TnE_MFM_PO__c = pPO_ID,
                                                                     recordTypeId = Global_RecordTypeCache.getRtId(pRecordType));

       return claimDtl;     
   }
   */
   
}