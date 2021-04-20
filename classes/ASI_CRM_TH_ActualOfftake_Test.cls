/*Created by Kevani Chow @introv 28/04/2016
*
* Testclass for ASI_CRM_TH_ActualOfftake_Ctrl
*/


@isTest
public class ASI_CRM_TH_ActualOfftake_Test{
    public static testMethod void ASI_CRM_TH_ActualOfftake_Test() {
        user u = [SELECT id FROM user WHERE profile.Name like 'System Administrator%' and isactive = true LIMIT 1];
    
    Id recordTypeid = Global_RecordTypeCache.getRtId('AccountASI_TH_CRM_Outlet');    
    Account outlet = new Account(Name='Test Outlet', RecordTypeid = recordTypeid, ownerid = u.id);                       
    insert outlet;
    
    recordTypeid = Global_RecordTypeCache.getRtId('AccountASI_TH_CRM_Wholesaler');    
    Account ws = new Account(Name='Test WS', RecordTypeid = recordTypeid, ownerid = u.id);                       
    insert ws;

    recordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_TH_ActualOfftakeHeader'); 
    ASI_CRM_ActualOfftakeHeader__c header = new ASI_CRM_ActualOfftakeHeader__c(RecordTypeid=recordTypeid, ownerid=u.id, ASI_CRM_Outlet__c=outlet.id, ASI_CRM_Wholesaler__c =ws.id, ASI_CRM_OfftakeDate__c =date.today(), ASI_CRM_Book_ID__c='1', ASI_CRM_Document_ID__c='1');
    insert header;
    ASI_CRM_ActualOfftakeHeader__c header2 = new ASI_CRM_ActualOfftakeHeader__c(RecordTypeid=recordTypeid, ownerid=u.id, ASI_CRM_Outlet__c=outlet.id, ASI_CRM_Wholesaler__c =ws.id, ASI_CRM_OfftakeDate__c =date.today(),  ASI_CRM_Book_ID__c='2', ASI_CRM_Document_ID__c='2');
    insert header2;
    
    recordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_TH_CRM_Sub_brand');
    ASI_MFM_Sub_brand__c subbrand = new ASI_MFM_Sub_brand__c(RecordTypeid=recordTypeid, ownerid=u.id, Name='subbrand', ASI_CRM_Form_1_Input__c=true);
    insert subbrand;
    ASI_MFM_Sub_brand__c subbrand2 = new ASI_MFM_Sub_brand__c(RecordTypeid=recordTypeid, ownerid=u.id, Name='subbrand2', ASI_CRM_Form_1_Input__c=true);
    insert subbrand2;
    
    recordTypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_TH_ActualOfftakeTemp');
    ASI_TH_CRM_Actual_Offtake__c offtake = new ASI_TH_CRM_Actual_Offtake__c(RecordTypeid=recordTypeid,ownerid=u.id, ASI_CRM_ActualOfftakeHeader__c=header.id, ASI_CRM_WS_Copy__c=0, ASI_CRM_Outlet_Copy__c=1, ASI_TH_CRM_Sub_brand__c=subbrand.id, ASI_TH_CRM_Outlet__c=outlet.id, ASI_TH_CRM_From_Wholesaler__c = ws.id);
    insert offtake;
    
    ASI_TH_CRM_Actual_Offtake__c offtake2 = new ASI_TH_CRM_Actual_Offtake__c(RecordTypeid=recordTypeid,ownerid=u.id, ASI_CRM_ActualOfftakeHeader__c=header2.id, ASI_CRM_WS_Copy__c=2, ASI_CRM_Outlet_Copy__c=2, ASI_TH_CRM_Sub_brand__c=subbrand2.id, ASI_TH_CRM_Outlet__c=outlet.id, ASI_TH_CRM_From_Wholesaler__c = ws.id);
    insert offtake2;
    
    header2.ASI_CRM_Verified__c=true;
    update header2;
    
     System.runAs(u) {
         PageReference pageRef = Page.ASI_CRM_TH_ActualOfftake_OutletCopy_Page;
         Test.setCurrentPage(pageRef);
         
         ApexPages.StandardController stdController = new ApexPages.StandardController(header);
         ASI_CRM_TH_ActualOfftake_Ctrl controller = new ASI_CRM_TH_ActualOfftake_Ctrl(stdController);
         
         controller.ActualOfftakeHeader.ASI_CRM_Book_ID__c='1';
         controller.ActualOfftakeHeader.ASI_CRM_Document_ID__c='1';
         controller.ActualOfftakeHeader.ASI_CRM_Outlet__c=outlet.id;
         controller.ActualOfftakeHeader.ASI_CRM_Wholesaler__c =ws.id;
         controller.ActualOfftakeHeader.ASI_CRM_OfftakeDate__c =date.today();
         controller.search();
         //controller.SubBrandList[0].wscopyno=2;
         controller.saveAction();
         
         pageRef = Page.ASI_CRM_TH_ActualOfftake_WSCopy_Page;
         Test.setCurrentPage(pageRef);
         controller = new ASI_CRM_TH_ActualOfftake_Ctrl(stdController);
      }
    }
}