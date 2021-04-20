trigger MMPJ_Ext_Vign_ContactBeforeInsert on Contact (before insert) {
    Id mmpjRecordTypeId = [select Id from RecordType where sObjectType='Contact' and DeveloperName='MMPJ_Ext_Vign_Contact' LIMIT 1].id;

    for(Contact con:trigger.new)
    {
        if(con.RecordTYpeId == mmpjRecordTypeId && con.MMPJ_Ext_Vign_Contact_Segmentation__c == 'Cognac')
            con.AccountId = System.label.MMPJ_Ext_Vign_Account_Cognac;
        else if(con.RecordTYpeId == mmpjRecordTypeId && con.MMPJ_Ext_Vign_Contact_Segmentation__c == 'Champagne')
            con.AccountId = System.label.MMPJ_Ext_Vign_Account_Champagne;
    }

}