@isTest
public class ASI_CRM_CN_MassCreateAndUpdate_Test {
    
    class PageController implements ASI_CRM_CN_MassCreateAndUpdateAbstract {
        
        public void setComponentController(ASI_CRM_CN_ComponentInterface cController) {}
        public void setComponentController(String key, ASI_CRM_CN_ComponentInterface cController) {}
        public ASI_CRM_CN_ComponentInterface getComponentController() { return null; }
        public ASI_CRM_CN_ComponentInterface getComponentController(String key) { return null; }
        
        public List<ASI_CRM_CN_MassCreateAndUpdateController.PageBlockActionBtn> mcau_initPageBlockActionButtonList() {
            return null;
        }     
        public PageReference mcau_triggerPageBlockAction(ASI_CRM_CN_MassCreateAndUpdateController controller, String actionKey) {
            return null;
        }        
        public void mcau_triggerActionForSObject(ASI_CRM_CN_MassCreateAndUpdateController controller, String actionKey, sObject sObj) {
        }
    }
    
    static testMethod void ASI_CRM_CN_MassCreateAndUpdateController_TEST() {
        
        list<RecordType> rts = Global_RecordTypeCache.getRtList('Contact');
        if(rts.size()<=0) return;
        
        
        list<string> rtNames = new list<string>();
        list<ASI_TnE_MassCreateAndUpdateSetting__c> settings = new list<ASI_TnE_MassCreateAndUpdateSetting__c>();
        for(RecordType rt: rts) {
            rtNames.add(rt.DeveloperName);
            settings.add(new ASI_TnE_MassCreateAndUpdateSetting__c(
                Name='Contact:' + rt.DeveloperName
            ));
        }
        string strRtNames = string.join(rtNames, ',');
        insert settings;
        
        list<Contact> contacts = new list<Contact>();
        contacts.add(new Contact(LastName='TEST'));
        
        Map<String, String> fieldNameToValueMap = new Map<String, String>();
        fieldNameToValueMap.put('LastName', 'TEST');
        Map<String, String> defaultFieldValues = new Map<String, String>();
        defaultFieldValues.put('LastName', 'TEST');
        
        test.startTest();
        
        ASI_CRM_CN_MassCreateAndUpdateController.RecordTypeElement rte = new ASI_CRM_CN_MassCreateAndUpdateController.RecordTypeElement(
            Schema.getGlobalDescribe().get('Contact'), rts[0], contacts, new List<ASI_CRM_CN_MassCreateAndUpdateController.DisplayCol>(), fieldNameToValueMap, false, false, false, defaultFieldValues, new Map<String,String>());
        rte.cloneNewSObject(contacts[0]);
        rte.cloneNewSObject(contacts[0], true);
        rte.cloneNewSObject(contacts[0], 0);
        rte.createNewSObject();
        rte.createNewSObject(true);
        rte.createNewSObject(new Contact());
        rte.createNewSObject(0, new Contact());
        rte.myDisplayRecordList = rte.myDisplayRecordList;
        
        
        ASI_CRM_CN_MassCreateAndUpdateController.DisplayField df;
        df = new ASI_CRM_CN_MassCreateAndUpdateController.DisplayField('', '');
        df = new ASI_CRM_CN_MassCreateAndUpdateController.DisplayField('', '',true);
        df = new ASI_CRM_CN_MassCreateAndUpdateController.DisplayField('', '',true,'');
        
        ASI_CRM_CN_MassCreateAndUpdateController.DisplayCol dc = new ASI_CRM_CN_MassCreateAndUpdateController.DisplayCol('','');
        dc.addDisplayField(df);           
        
        ASI_CRM_CN_MassCreateAndUpdateController.PageBlockActionBtn btn = new ASI_CRM_CN_MassCreateAndUpdateController.PageBlockActionBtn('','');
        
        ASI_CRM_CN_MassCreateAndUpdateController con = new ASI_CRM_CN_MassCreateAndUpdateController();
        ApexPages.currentPage().getParameters().put(con.PARAM_RTID, rts[0].DeveloperName);
        con.pageController = new PageController();
        con.sObjTypeStr = 'Contact';
        con.isFastModeBool = true;
        con.isUseFirstRowForNew = true;
        con.successLink = '';
        con.includeRecordTypes = strRtNames;
        con.defaultFieldValuesStr = 'LastName,TEST';
        con.displayFieldsStr = 'LastName&AccountId';
        con.lookupToPicklist = 'AccountId,AccountId.AccountNumber=>AccountId';
        con.lookupDateFields = 'Birthdate';
        con.fieldToURLParamStr = 'fieldToURLParamStr';
        con.init();
        con.getcheckPicklistSet();
        con.dummyMethod();
       // con.initPickList(new string[]{'LeadSource'});
        con.initDateFields(new string[]{'Birthdate'});
        con.clearAll();
        con.addNewRow();
        con.cloneRow();
        con.enableForEdit();
        con.removeNew();
        con.deleteOld();
        //con.deleteRow('','');
        con.addMoreBlankRows();

        con.commitAll();
        con.triggerPageBlockAction();
        con.addNewRowByInfo('', null);
        con.refresh();
        
        //ASI_CRM_CN_MassCreateAndUpdateController.RecordTypeElement e = new ASI_CRM_CN_MassCreateAndUpdateController.RecordTypeElement();
        
        
        test.stopTest();
        
    }
}