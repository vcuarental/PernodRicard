/*********************************************************************************
 * Name:ASI_MFM_CAP_SG_TestClassHelper
 * Description: For generating test data for OPEX SG
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 09/16/2015       Laputa: Conrad          Created
*********************************************************************************/
@isTest
public class ASI_MFM_CAP_SG_TestClassHelper {
    
    public static Account accSupplier {get;set;}
    public static ASI_MFM_A_C_Code__c acCode {get;set;}
    
//Supplier    
    public static Account createAccSupplier ()
    {
        Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CAP_SG_Supplier'), Name='Name3');
        insert acc;
        accSupplier = acc;
        return acc;
    }
    
//A/C Code    
    public static ASI_MFM_A_C_Code__c createAcCode ()
    {
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CAP_SG_A_C_Code'), 
                                                            Name='1350 Inventory in Transit',
                                                            ASI_MFM_A_C_Code__c='1350',
                                                            ASI_MFM_A_C_Description__c='Inventory in Transit'
                                                            
                                                        );
        insert ac;
        acCode = ac;
        return ac;
    }    
    
//AP Code   
    public static ASI_MFM_AP_Code__c createapCode ()
    {
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_CAP_SG_AP_Code'), 
                                                        Name='1350 Inventory in Transit',
                                                        ASI_MFM_AP_Code__c ='1350',
                                                        ASI_MFM_AP_Description__c='Inventory in Transit',
                                                        ASI_MFM_A_C_Code__c = acCode == null ? createAcCode().id : acCode.id
                                                        );
        insert ap;
        return ap;
    }
    
    //Create User
    public static User createUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com',
            userroleID = r.id,
            asi_mfm_country__c = 'SG');
        insert u1;
        return u1;
    }
    
//PO Prefix 
    public static ASI_MFM_Prefix__c createPrefixPO (user u)
    {
        
        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest1',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_SG_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1415'
        );
        System.runAs(u) {
            insert prefixCap;
        }
        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : u.userRoleID ];
        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        System.runAs(u) {
            insert rel;
        }
        return prefixCap;
        
    }

//Payment Prefix    
    public static ASI_MFM_Prefix__c createPrefixPayment (user u)
    {

        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest1',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_SG_Prefix'),
            ASI_MFM_Module__c = 'Payment',
            ASI_MFM_Fiscal_year__c = 'FY1415'
        );
        System.runAs(u) {
            insert prefixCap;
        }
        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        System.runAs(u) {
            insert rel;
        }
        return prefixCap;
    }
    
    
//PO Prefix 
    public static ASI_MFM_Prefix__c createPrefixPO ()
    {
        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest1',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_SG_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1415'
        );
        insert prefixCap;
        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;
        return prefixCap;
    }

//Payment Prefix    
    public static ASI_MFM_Prefix__c createPrefixPayment ()
    {
        ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c
        (
            Name = 'CAPTest1',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_SG_Prefix'),
            ASI_MFM_Module__c = 'Payment',
            ASI_MFM_Fiscal_year__c = 'FY1415'
        );
        insert prefixCap;
        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixCap.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;
        return prefixCap;
    }
    
    public class createPayment {
    
        public ASI_MFM_Payment__c payment {get;set;}
        
        public createPayment(ASI_MFM_Prefix__c prefix) {
            
            payment = new ASI_MFM_Payment__c
            (
                ASI_MFM_Currency__c = 'SGD',
                ASI_MFM_Prefix__c= prefix.id,
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_SG_Payment'),
                ASI_MFM_Status__c = 'Draft',
                ASI_MFM_Invoice_Date__c = date.today(),
                ASI_MFM_Invoice_Number__c = '123Tesyt',
                ASI_MFM_Supplier_Name__c = accSupplier == null ? createAccSupplier().id : accSupplier.id
            );
            insert payment;
            
        }
    }
    
    public class createPO {
    
        public ASI_MFM_PO__c po {get;set;}
        
        public createPO(ASI_MFM_Prefix__c prefix) {
            
            po = new ASI_MFM_PO__c 
            (
                Name = 'Test PO',
                ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_SG_PO'),
                ASI_MFM_Prefix__c = prefix.id
            );
            insert po;
            
        }
    }
    
    public class createPOLine {
    
        public ASI_MFM_PO_Line_Item__c poLine {get;set;}
        
        public createPOLine(ASI_MFM_PO__c po) {
            
            poLine = new ASI_MFM_PO_Line_Item__c 
            (
                ASI_MFM_G_L_Date__c = date.today(),
                ASI_MFM_PO__c = po.id,
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CAP_SG_PO_Line_Item')
            );
            insert poLine;
            
        }
    }
    
}