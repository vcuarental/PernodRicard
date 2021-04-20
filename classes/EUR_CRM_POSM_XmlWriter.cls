/* 
*    Description    :    Apex class with methods to generate XML data for POSM Order
*                        and related POSM Order Item records
*
*/
public without sharing class EUR_CRM_POSM_XmlWriter {

    private static final String STR_POSMORDER = 'POSMOrder';
    private static final String STR_RECORDTYPE = 'RecordType';
    private static final String STR_ID = 'POSMOrderID';
    private static final String STR_POSMORDERITEM = 'POSMOrderItem';
    private static final String STR_LINEITEMID = 'LineItemId';
    private static final String STR_SELLERID = 'SellerID';
    private static final String STR_PRSA = 'Pernod Ricard South Africa';
    private static final String STR_ACTIONCODE = 'ActionCode';
    private static final String STR_CREATION = 'Creation';
    
    public String generateXmlForPOSMOrder(Id posmOrderId){
        
        if(!String.isBlank(posmOrderId)){
            // Query string to be dynamically generated
            String query = 'SELECT ';
            // Retrieve the Recordtype of the currenty process POSM and POSM Item
            EUR_CRM_POSM_Order__c posm = [SELECT Id, RecordType.DeveloperName, RecordTypeId,
                                                (SELECT Id, RecordType.DeveloperName
                                                FROM POSM_Order_Items__r) 
                                        FROM EUR_CRM_POSM_Order__c 
                                        WHERE Id = :posmOrderId];
            // Rreturn null if Id is an invalid posm Id
            if(posm == null){
                return NULL;
            }
            // Else
            // set the records' recordtype names
            String posmfieldSetName = posm.RecordType.DeveloperName;
            String posmItemfieldSetName = (posm.POSM_Order_Items__r.size() > 0) ? posm.POSM_Order_Items__r[0].RecordType.DeveloperName : ''; // all posm LI must have same recordtype, so pick any
            // Initialize the fieldSet maps for the objects
            Map<String, Schema.FieldSet> posmFsMap = Schema.SObjectType.EUR_CRM_POSM_Order__c.fieldSets.getMap();
            Map<String, Schema.FieldSet> posmItemFsMap = Schema.SObjectType.EUR_CRM_POSM_Order_Item__c.fieldSets.getMap();

            // Return null no field set is found for the POSM recordtype
            if (!posmFsMap.containsKey(posmfieldSetName)) {
                return NULL;
            }
            // Else retrieve it
            List<Schema.FieldSetMember> POSMFields = Schema.SObjectType.EUR_CRM_POSM_Order__c.fieldSets.getMap().get(posmfieldSetName).getFields();
            // Build Query for POSM from the retrieved fields
            for(Integer i = 0; i < POSMFields.size(); i++){
                query += POSMFields[i].getFieldPath();
                if(i < POSMFields.size()-1){
                    query += ', ';
                }
            }
            // Retrieve and build query for POSM line Item if they exist
            // and a field set for that record type exists as well
            List<Schema.FieldSetMember> POSMItemFields;
            if(posmItemFsMap.containsKey(posmItemfieldSetName)){
                POSMItemFields = Schema.SObjectType.EUR_CRM_POSM_Order_Item__c.fieldSets.getMap().get(posmItemfieldSetName).getFields();
                query += ', (SELECT ';
                for(Integer i = 0; i < POSMItemFields.size(); i++){
                    query += POSMItemFields[i].getFieldPath();
                    if(i < POSMItemFields.size()-1){
                        query += ', ';
                    }
                }
                query += ' FROM POSM_Order_Items__r)';
            }
            // End the query
            query += ' FROM EUR_CRM_POSM_Order__c WHERE Id =: posmOrderId';
            // Run the query
            List<EUR_CRM_POSM_Order__c> posmOrderList = Database.query(query);

            if(!posmOrderList.isEmpty()){
                // Initialize the xml file
                XmlStreamWriter xmlWriteObj = new XmlStreamWriter();                
                xmlWriteObj.writeStartDocument('utf-8', '1.0'); 

                // Write the POSM Order details
                for (EUR_CRM_POSM_Order__c objPOSM : posmOrderList) {
                    
                    xmlWriteObj.writeStartElement(null, STR_POSMORDER, null);
                    
                    //Seller Id
                    xmlWriteObj.writeAttribute(null, null,
                                               STR_SELLERID, STR_PRSA);                    
                    
                    //ActionCode
                    xmlWriteObj.writeAttribute(null, null,
                                               STR_ACTIONCODE, STR_CREATION);

                    //Record Type Developer Name
                    xmlWriteObj.writeAttribute(null, null,
                                               STR_RECORDTYPE, 
                                               EUR_CRM_POSM_Order__c.SObjectType.getDescribe().getRecordTypeInfosById().get(posm.RecordTypeId).getName());

                    //Write Fields from field set
                    for(Schema.FieldSetMember field : POSMFields){
                        // Order Id from the Name field
                        if(field.getFieldPath() == 'Name'){                                
                            xmlWriteObj.writeAttribute(null, null,
                                                        STR_ID,
                                                        objPOSM.Name != NULL ? objPOSM.Name : '');
                        }
                        else {
                            xmlWriteObj.writeAttribute(null, null, 
                                                       field.getFieldPath(),
                                                       String.valueOf(objPOSM.get(field.getFieldPath())) != NULL ? String.valueOf(objPOSM.get(field.getFieldPath())) : '');
                        }
                    }

                    // Write the POSM Order Items details if they exist
                    if(objPOSM.POSM_Order_Items__r != null){
                        for (EUR_CRM_POSM_Order_Item__c posmLineItem : objPOSM.POSM_Order_Items__r) {
                            
                            xmlWriteObj.writeStartElement(null, STR_POSMORDERITEM, null);
                            
                            //ActionCode
                            xmlWriteObj.writeAttribute(null, null,
                                                       STR_ACTIONCODE, STR_CREATION);                           
                            
                            //Write Fields from field Set
                            for(Schema.FieldSetMember field : POSMItemFields){
                                //LineItemId from the name field
                                if(field.getFieldPath() == 'Name'){                                
                                    xmlWriteObj.writeAttribute(null, null, 
                                                               STR_LINEITEMID, 
                                                               posmLineItem.Name != NULL ? posmLineItem.Name : '');
                                }
                                else {
                                    xmlWriteObj.writeAttribute(null, null, 
                                                               field.getFieldPath(),
                                                               String.valueOf(posmLineItem.get(field.getFieldPath())) != NULL ? String.valueOf(posmLineItem.get(field.getFieldPath())) : '');
                                }
                            }

                            xmlWriteObj.writeEndElement(); // End element For each POSM Order Item
                        }
                    }

                    xmlWriteObj.writeEndElement(); // End element for each POSM Order                    
                }
                // Return the created xml file
                System.debug('xmlWriteObj.getXmlString(): ' + xmlWriteObj.getXmlString());
                return xmlWriteObj.getXmlString();
            }
        }
        // Return NULL if reached the end without creating an xml, or Id is empty 
        return NULL;
    }
}