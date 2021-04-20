/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_ContractClass Class.
  @Author:      IPC
  @History:     NOV.21.2014 - Created
*/
@isTest (SeeAllData=false)
private with sharing class EUR_CRM_GB_Contract_Attachment_Test{
    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;
    private static EUR_CRM_Contract_Line_Item__c contractItemP;
    private static EUR_CRM_Contract_Line_Item__c contractItemP2;
    private static EUR_CRM_Contract_Line_Item__c contractItemC;
    private static EUR_CRM_Contract_Line_Item__c contractItemC2;
    private static EUR_CRM_Contract_Mechanic__c contractMechC;
    private static EUR_CRM_Contract_Mechanic__c contractMechP;
    private static EUR_CRM_Mechanic_Type__c mechTypeC;
    private static EUR_CRM_Mechanic_Type__c mechTypeP;
    private static EUR_CRM_Mechanic__c mechanicC;
    private static EUR_CRM_Mechanic__c mechanicP;
    private static EUR_CRM_Wine_Spirits__c wineSpirits;
    private static EUR_CRM_Category__c category;
    private static EUR_CRM_Brand__c brand;
    private static EUR_CRM_Quality__c brandQuality;
    private static EUR_CRM_Cocktail_Menu__c cocktailMenu;
    private static EUR_CRM_Stock_Deal_Mechanic__c stockDealMech;
    private static Contact c;
    private static String contractRecordTypeName_GB = 'GB Contract';
    
    private static void dataInsert1(){
        accountEU = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Indirect')[0];
        insert accountEU;
        
        Id contactRecordTypeId = [select id from recordtype where sobjecttype='Contact' and developername='EUR_GB_Contact'].id;
        
         c = new Contact();
        // = 'test';
        c.recordtypeid = contactRecordTypeId;
        c.eur_crm_account__c = accountEU.id;
        c.LastName = 'test';
        c.FirstName = 'test';
        insert c;
        
        contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, contractRecordTypeName_GB, accountEU.Id, date.today(), date.today().addDays(20))[0];
        contract.EUR_CRM_Contract_Type__c = 'Standard Contract';
        contract.EUR_CRM_Marketing_Package_Lump_Sum__c = null;
        contract.eur_crm_contact__c = c.id;
        insert contract;
    }
    
    private static Attachment createAttachment(String name, Id parentId){
        Attachment attachment = new Attachment();
        attachment.Name = String.valueOf(name);
        attachment.ParentId = parentId;
        attachment.Body = Blob.valueOf('TEST');
        
        insert attachment;
        System.assertNotEquals(attachment, null);
        
        return attachment;
    }
    
    //Insert Attachment - True
    static testMethod void testContractAttachmentInsertAttachment1(){
        dataInsert1();
        
        test.startTest();

        String contractCopyPrefix = [SELECT EUR_CRM_Contract_Copy_File_Name__c FROM EUR_CRM_Contract__c WHERE Id=:contract.Id].EUR_CRM_Contract_Copy_File_Name__c;
        Boolean contractUploadState = false;
        
        //Insert Attachment - True
        Attachment attachment1 = createAttachment(contractCopyPrefix+'_TEST', contract.Id);
        contractUploadState = [SELECT EUR_CRM_Contract_Uploaded__c FROM EUR_CRM_Contract__c WHERE Id=:contract.Id].EUR_CRM_Contract_Uploaded__c;
        System.assertEquals(contractUploadState, true);
        
        //Delete Attachment - False
        delete attachment1;
        contractUploadState = [SELECT EUR_CRM_Contract_Uploaded__c FROM EUR_CRM_Contract__c WHERE Id=:contract.Id].EUR_CRM_Contract_Uploaded__c;
        System.assertEquals(contractUploadState, false);
         
         

        test.stopTest();
    } 


    //Insert Attachment - Name not Contract Attachment prefix - False
    static testMethod void testContractAttachmentInsertAttachment2(){
        dataInsert1();
        
        test.startTest();

        String contractCopyPrefix = [SELECT EUR_CRM_Contract_Copy_File_Name__c FROM EUR_CRM_Contract__c WHERE Id=:contract.Id].EUR_CRM_Contract_Copy_File_Name__c;
        Boolean contractUploadState = false;
         
        
        //Insert Attachment - Name not Contract Attachment prefix - False
        Attachment attachment2 = createAttachment('TEST', contract.Id);
        contractUploadState = [SELECT EUR_CRM_Contract_Uploaded__c FROM EUR_CRM_Contract__c WHERE Id=:contract.Id].EUR_CRM_Contract_Uploaded__c;
        System.assertEquals(contractUploadState, false);
        
        //Delete Attachment - Name not Contract Attachment prefix - False
        delete attachment2;
        contractUploadState = [SELECT EUR_CRM_Contract_Uploaded__c FROM EUR_CRM_Contract__c WHERE Id=:contract.Id].EUR_CRM_Contract_Uploaded__c;
        System.assertEquals(contractUploadState, false);
         

        test.stopTest();
    } 

        //Insert Attachment - Name not Contract Attachment prefix - False
    static testMethod void testContractAttachmentInsertAttachment3(){
        dataInsert1();
        
        test.startTest();

        String contractCopyPrefix = [SELECT EUR_CRM_Contract_Copy_File_Name__c FROM EUR_CRM_Contract__c WHERE Id=:contract.Id].EUR_CRM_Contract_Copy_File_Name__c;
        Boolean contractUploadState = false;
        
        //Insert Attachment - Name not Contract Attachment prefix - False
        Attachment attachment3 = createAttachment('TEST', contract.Id);
        contractUploadState = [SELECT EUR_CRM_Contract_Uploaded__c FROM EUR_CRM_Contract__c WHERE Id=:contract.Id].EUR_CRM_Contract_Uploaded__c;
        System.assertEquals(contractUploadState, false);
        
        //Delete Attachment - Name not Contract Attachment prefix - True
        delete attachment3;
        contractUploadState = [SELECT EUR_CRM_Contract_Uploaded__c FROM EUR_CRM_Contract__c WHERE Id=:contract.Id].EUR_CRM_Contract_Uploaded__c;
        System.assertEquals(contractUploadState, false);

 
        
         

        test.stopTest();
    } 


        //Insert Attachment - True
    static testMethod void testContractAttachmentInsertAttachment4(){
        dataInsert1();
        
        test.startTest();

        String contractCopyPrefix = [SELECT EUR_CRM_Contract_Copy_File_Name__c FROM EUR_CRM_Contract__c WHERE Id=:contract.Id].EUR_CRM_Contract_Copy_File_Name__c;
        Boolean contractUploadState = false;
         
        
        //Insert Attachment - True
        Attachment attachment4 = createAttachment(contractCopyPrefix + 'TEST', contract.Id);
        contractUploadState = [SELECT EUR_CRM_Contract_Uploaded__c FROM EUR_CRM_Contract__c WHERE Id=:contract.Id].EUR_CRM_Contract_Uploaded__c;
        System.assertEquals(contractUploadState, true);
        
        
        
        //Insert Attachment - Name not Contract Attachment prefix - False
        attachment4.Name = 'TEST';
        update attachment4;
        contractUploadState = [SELECT EUR_CRM_Contract_Uploaded__c FROM EUR_CRM_Contract__c WHERE Id=:contract.Id].EUR_CRM_Contract_Uploaded__c;
        System.assertEquals(contractUploadState, false);
        
        //Update Attachment - True
        attachment4.Name = contractCopyPrefix+'_TEST';
        update attachment4;
        contractUploadState = [SELECT EUR_CRM_Contract_Uploaded__c FROM EUR_CRM_Contract__c WHERE Id=:contract.Id].EUR_CRM_Contract_Uploaded__c;
        System.assertEquals(contractUploadState, true);

        test.stopTest();
    } 
}