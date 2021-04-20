@isTest
public class ASI_CRM_CN_ChanngelStrategy_Test {
    
    static testMethod void ASI_CRM_CN_Channel_Strategy_TriggerClass_TEST() {
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST');
        insert area;
        
        list<ASI_CRM_Fix_Approval_Route__c> fars = new list<ASI_CRM_Fix_Approval_Route__c>();
        fars.add(new ASI_CRM_Fix_Approval_Route__c(
            ASI_CRM_CN_Type__c = 'Channel Strategy',
            ASI_CRM_CN_Region_Area_Channel__c = area.Name));
        insert fars;
        
        map<string, ASI_CRM_Fix_Approval_Route__c> mfars = new map<string, ASI_CRM_Fix_Approval_Route__c>();
        for(ASI_CRM_Fix_Approval_Route__c far :fars)
            mfars.put(far.ASI_CRM_CN_Region_Area_Channel__c, far);
            
        ASI_CRM_CN_Channel_Strategy__c cs = new ASI_CRM_CN_Channel_Strategy__c(ASI_CRM_CN_Area__c=area.Id);
        insert cs;
        
        cs = [SELECT Id, ASI_CRM_CN_Area__c, ASI_CRM_CN_Area_Eng_Name__c FROM ASI_CRM_CN_Channel_Strategy__c WHERE Id=:cs.Id];
        
        list<ASI_CRM_CN_Channel_Strategy__c> css = new list<ASI_CRM_CN_Channel_Strategy__c>();
        css.add(cs);
        
        test.startTest();
        
        ASI_CRM_CN_Channel_Strategy_TriggerClass.routineBeforeInsert(css);
        ASI_CRM_CN_Channel_Strategy_TriggerClass.setApprovers(css[0], mfars);
        ASI_CRM_CN_Channel_Strategy_TriggerClass.setApproverToNull(css[0]);
        
        test.stopTest();
    }

    static testMethod void ASI_CRM_CN_ChannelStratgy_Controller_TEST() {
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Area__cASI_CRM_CN_Area'));
        insert area;
        
        list<ASI_CRM_Fix_Approval_Route__c> fars = new list<ASI_CRM_Fix_Approval_Route__c>();
        fars.add(new ASI_CRM_Fix_Approval_Route__c(
            ASI_CRM_CN_Type__c = 'Channel Strategy',
            ASI_CRM_CN_Region_Area_Channel__c = 'TEST'));
        insert fars;
        
        map<string, ASI_CRM_Fix_Approval_Route__c> mfars = new map<string, ASI_CRM_Fix_Approval_Route__c>();
        for(ASI_CRM_Fix_Approval_Route__c far :fars)
            mfars.put(far.ASI_CRM_CN_Region_Area_Channel__c, far);
        
        list<ASI_CRM_CN_Channel_Strategy__c> css = new list<ASI_CRM_CN_Channel_Strategy__c>();
        css.add(new ASI_CRM_CN_Channel_Strategy__c(ASI_CRM_CN_Area__c=area.Id));
        insert css;
        css.add(new ASI_CRM_CN_Channel_Strategy__c(ASI_CRM_CN_Area__c=area.Id, ASI_CRM_CN_National__c=css[0].Id));
        insert css[1];
        
        list<ASI_CRM_CN_Channel_Strategy_Line_Item__c> allcsi = new list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        map<Id, list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>> mcsis = new map<Id, list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>>();
        for(ASI_CRM_CN_Channel_Strategy__c cs :css) {
            list<ASI_CRM_CN_Channel_Strategy_Line_Item__c> csis = new list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
            mcsis.put(cs.Id, csis);
            for(integer i=0; i<6; i++) {
                ASI_CRM_CN_Channel_Strategy_Line_Item__c csi = new ASI_CRM_CN_Channel_Strategy_Line_Item__c(Name='TEST', ASI_CRM_CN_Channel_Strategy__c=cs.Id);
                csis.add(csi);
                allcsi.add(csi);
            }
        }
        insert allcsi;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_CRM_CN_Channel_Strategy__c cs: css)
            scons.add(new ApexPages.StandardController(cs));
        
        
        test.startTest();
        
        for(ApexPages.StandardController scon :scons) {
            ApexPages.currentPage().getParameters().put('Id', scon.getId());
            ASI_CRM_CN_ChannelStratgy_Controller con = new ASI_CRM_CN_ChannelStratgy_Controller(scon);
            list<ASI_CRM_CN_Channel_Strategy_Line_Item__c> csis = mcsis.get(scon.getId());
            con.chooseLocale();
            con.AddNew1();
            con.AddNew2();
            con.AddNew3();
            con.objCSItem1.add(csis[1]);
            con.rowid = csis[1].Name;
            con.Remove1();
            con.objCSItem2.add(csis[2]);
            con.rowid = csis[2].Name;
            con.Remove2();
            con.objCSItem3.add(csis[3]);
            con.rowid = csis[3].Name;
            con.Remove3();
            con.AddNew(csis, 'TEST');
            csis.add(csis[4]);
            con.rowid = csis[4].Name;
            list<ASI_CRM_CN_Channel_Strategy_Line_Item__c> csis1 = new list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
            con.removeRow(csis1);
            con.Save();
            con.Editpage();
            con.getAreaStrategy();
            con.Copy();
            list<ASI_CRM_CN_Channel_Strategy__c> css1 = new list<ASI_CRM_CN_Channel_Strategy__c>();
            css1.add(new ASI_CRM_CN_Channel_Strategy__c(ASI_CRM_CN_Area__c=area.Id));

            csis1 = new list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
            csis1.add(new ASI_CRM_CN_Channel_Strategy_Line_Item__c(Name='TEST', ASI_CRM_CN_Channel_Strategy__c=scon.getId()));
            con.clearupUpdateList(csis1, 'Insert');
            con.clearupUpdateList(csis1, 'Update');
            con.clearupUpdateList(csis1, 'Delete');
            
            con.clearupUpdateListMaster(css1, 'Insert');
            con.clearupUpdateListMaster(css1, 'Update');
            con.clearupUpdateListMaster(css1, 'Delete');
            //con.Submit();
        }
        
        ASI_CRM_CN_ChannelStratgy_Controller.findSObjects('Account',' NOT ISNULL(Id)','');
        
        test.stopTest();
        
    }
}