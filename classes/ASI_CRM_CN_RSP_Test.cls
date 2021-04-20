@isTest
public class ASI_CRM_CN_RSP_Test {

    static testMethod void ASI_CRM_CN_AddRSPController_TEST() {

        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        Id rtRsp = Global_RecordTypeCache.getRtId('ASI_TH_CRM_RSP__cASI_CRM_CN_RSP');
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(RecordTypeId=rtOutlet, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
        ASI_MFM_Item_Group__c ig = new ASI_MFM_Item_Group__c(Name='TEST', ASI_CRM_CN_Consumer_Website__c=true);
        insert ig;
        
        list<ASI_TH_CRM_RSP__c> rsps = new list<ASI_TH_CRM_RSP__c>();
        for(ASI_CRM_AccountsAdditionalField__c a2 : a2s)
			rsps.add(new ASI_TH_CRM_RSP__c(ASI_CRM_CN_Customer__c=a2.Id, RecordTypeId=rtRsp, ASI_CRM_CN_Input_Date_Time__c=system.today().addDays(-1)));
		insert rsps;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_CRM_AccountsAdditionalField__c a2 : a2s)
            scons.add(new ApexPages.StandardController(a2));
        
        test.startTest();
       
        {
            ASI_CRM_CN_AddRSPController.Row r = new ASI_CRM_CN_AddRSPController.Row();
            r.RSP = r.RSP;
            r.ItemGroupName = r.ItemGroupName;
            r.Index = r.Index;
        }
        
        for(ApexPages.StandardController scon: scons)
        {
            ASI_CRM_CN_AddRSPController con = new ASI_CRM_CN_AddRSPController(scon);
            con.delRowIndex = con.delRowIndex;
            con.SearchText = con.SearchText;
            con.SearchResults = con.SearchResults;
            con.MoreResults = con.MoreResults;
            con.SelectedItemGroupId = con.SelectedItemGroupId;
            con.Msg = con.Msg;
            con.rt = con.rt;
            con.init();
            con.addRow();

            con.SearchText = ig.Name;
            con.search();
            con.SelectedItemGroupId = ig.Id;
            con.selectItemGroup();
            con.submit();
            
            con.addRow();
            con.delRowIndex = '0';
            con.delRow();

            con.back();
        }
        
        test.stopTest();
        
    }
    
}