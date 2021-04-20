trigger MMPJ_XRM_Contact_After_Update on Contact (after update) {
	Id mmpjRecordTypeId = [select Id from RecordType where sObjectType='Contact' and DeveloperName='MMPJ_Ext_Vign_Contact' LIMIT 1].id;
	List<Contact> contacts = new List<Contact>();
    
    for(Contact con:trigger.new)
        if(con.RecordTYpeId == mmpjRecordTypeId && con.Email != trigger.oldMap.get(con.Id).Email)
        	contacts.add(con);

	if(contacts.size() > 0)
		MMPJ_XRM_SocieteUpdate.updateEmailForPrimaryContact(contacts);
}