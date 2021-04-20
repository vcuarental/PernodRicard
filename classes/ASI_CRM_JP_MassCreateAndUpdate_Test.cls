@isTest
public class ASI_CRM_JP_MassCreateAndUpdate_Test {
    
    static testMethod void ASI_CRM_JP_MassCreateAndUpdateController_TEST() {
        
        list<RecordType> rts = Global_RecordTypeCache.getRtList('Contact');
        if(rts.size()<=0) return;
        
        
        list<string> rtNames = new list<string>();
        list<ASI_CRM_MassCreateAndUpdateSetting__c> settings = new list<ASI_CRM_MassCreateAndUpdateSetting__c>();
        for(RecordType rt: rts) {
            rtNames.add(rt.DeveloperName);
            settings.add(new ASI_CRM_MassCreateAndUpdateSetting__c(
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
        
        ASI_CRM_JP_MassCreateAndUpdateController.RecordTypeElement rte = new ASI_CRM_JP_MassCreateAndUpdateController.RecordTypeElement(
            Schema.getGlobalDescribe().get('Contact'), rts[0], contacts, new List<ASI_CRM_JP_MassCreateAndUpdateController.DisplayCol>(), fieldNameToValueMap, false, false, false);
        rte.cloneNewSObject(contacts[0]);
        rte.cloneNewSObject(contacts[0], true);
        rte.cloneNewSObject(contacts[0], 0);
        rte.createNewSObject();
        rte.createNewSObject(true);
        rte.createNewSObject(new Contact());
        rte.createNewSObject(0, new Contact());
        rte.myDisplayRecordList = rte.myDisplayRecordList;
        
        
        ASI_CRM_JP_MassCreateAndUpdateController.DisplayField df;
        df = new ASI_CRM_JP_MassCreateAndUpdateController.DisplayField('', '');
        df = new ASI_CRM_JP_MassCreateAndUpdateController.DisplayField('', '',true);
        
        ASI_CRM_JP_MassCreateAndUpdateController.DisplayCol dc = new ASI_CRM_JP_MassCreateAndUpdateController.DisplayCol('','');
        dc.addDisplayField(df);           
        
        ASI_CRM_JP_MassCreateAndUpdateController.PageBlockActionBtn btn = new ASI_CRM_JP_MassCreateAndUpdateController.PageBlockActionBtn('','');
        
        /*Schema.sObjectType sobjType = Schema.getGlobalDescribe().get('Contact');
        Map<String, Schema.SObjectField> sObjFieldMap = sObjType.getDescribe().fields.getMap();
        string s='';
        for(string key :sObjFieldMap.keySet())
            s+= key + ', ';
        throw new ASI_CRM_CN_Function.CRMException(s);*/
        
        ASI_CRM_JP_MassCreateAndUpdateController con = new ASI_CRM_JP_MassCreateAndUpdateController();
//        ApexPages.currentPage().getParameters().put(con.PARAM_RTID, rts[0].DeveloperName);
        ApexPages.currentPage().getParameters().put(con.PARAM_RTID, 'ASI_CRM_JP_Contact');
        con.sObjTypeStr = 'Contact';
        con.isFastModeBool = true;
        con.isUseFirstRowForNew = true;
        con.successLink = '';
        con.includeRecordTypes = strRtNames;
        con.defaultFieldValuesStr = 'LastName,TEST';
        con.displayFieldsStr = 'Name&Title';
        con.lookupToPicklist = 'AccountId';
        con.fieldToURLParamStr = 'fieldToURLParamStr';
        con.init();
        con.getcheckPicklistSet();
        con.clearAll();
        con.addNewRow();
        con.cloneRow();
        con.enableForEdit();
        con.removeNew();
        con.deleteOld();
        //con.deleteRow('','');
        con.addMoreBlankRows();
        con.commitAllQuickSave();
        con.strListToStr(rtNames,'Test');
        con.strToStrList('inputStr');
        con.assignDisplayFieldProperty(df, 'key', 'value');
        //ASI_CRM_JP_MassCreateAndUpdateController.recordTypeElementListJsonString = 'Test';
        //ASI_CRM_JP_MassCreateAndUpdateController.dummyVar = False;
        con.commitAll();
        con.triggerPageBlockAction();
        con.addNewRowByInfo('', null);
        con.refresh();
        
        //ASI_CRM_MassCreateAndUpdateController.RecordTypeElement e = new ASI_CRM_MassCreateAndUpdateController.RecordTypeElement();
        
        
        test.stopTest();
    }
}