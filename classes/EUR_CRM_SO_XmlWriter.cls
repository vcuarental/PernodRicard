/* 
*    Description    :    Apex class with methods to generate XML data for SalesOrder
*                        and related SalesOrderItem records
*
*/
public without sharing class EUR_CRM_SO_XmlWriter {

    private static final String STR_SALESORDER = 'SalesOrder';
    private static final String STR_RECORDTYPE = 'RecordType';
    private static final String STR_ID = 'SalesOrderID';
    private static final String STR_SALESORDERITEM = 'SalesOrderItem';
    private static final String STR_LINEITEMID = 'LineItemId';
    private static final String STR_SELLERID = 'SellerID';
    private static final String STR_PRSA = 'Pernod Ricard South Africa';
    private static final String STR_ACTIONCODE = 'ActionCode';
    private static final String STR_CREATION = 'Creation';
    
    public String generateXmlForSalesOrder(Id pSalesOrderId){
        
        if(!String.isBlank(pSalesOrderId)){
            // Query string to be dynamically generated
            String query = 'SELECT ';
            // Retrieve the Recordtype of the currenty process SO and SO Item
            EUR_CRM_Sales_Order__c so = [SELECT Id, RecordType.DeveloperName, RecordTypeId, 
                                                (SELECT Id, RecordType.DeveloperName 
                                                FROM Sales_Order_Items__r) 
                                        FROM EUR_CRM_Sales_Order__c 
                                        WHERE Id = :pSalesOrderId];
            // Rreturn null if Id is an invalid SO Id
            if(so == null){
                return NULL;
            }
            // Else
            // set the records' recordtype names
            String sofieldSetName = so.RecordType.DeveloperName;
            String soItemfieldSetName = (so.Sales_Order_Items__r.size() > 0) ? so.Sales_Order_Items__r[0].RecordType.DeveloperName : ''; // all SO LI must have same recordtype, so pick any
            // Initialize the fieldSet maps for the objects
            Map<String, Schema.FieldSet> soFsMap = Schema.SObjectType.EUR_CRM_Sales_Order__c.fieldSets.getMap();
            Map<String, Schema.FieldSet> soItemFsMap = Schema.SObjectType.EUR_CRM_Sales_Order_Items__c.fieldSets.getMap();

            // Return null no field set is found for the SO recordtype
            if (!soFsMap.containsKey(sofieldSetName)) {
                return NULL;
            }
            // Else retrieve it
            List<Schema.FieldSetMember> SOFields = Schema.SObjectType.EUR_CRM_Sales_Order__c.fieldSets.getMap().get(sofieldSetName).getFields();
            // Build Query for SO from the retrieved fields
            for(Integer i = 0; i < SOFields.size(); i++){
                query += SOFields[i].getFieldPath();
                if(i < SOFields.size()-1){
                    query += ', ';
                }
            }
            // Retrieve and build query for SO line Item if they exist
            // and a field set for that record type exists as well
            List<Schema.FieldSetMember> SOItemFields;
            if(soItemFsMap.containsKey(soItemfieldSetName)){
                SOItemFields = Schema.SObjectType.EUR_CRM_Sales_Order_Items__c.fieldSets.getMap().get(soItemfieldSetName).getFields();
                query += ', (SELECT ';
                for(Integer i = 0; i < SOItemFields.size(); i++){
                    query += SOItemFields[i].getFieldPath();
                    if(i < SOItemFields.size()-1){
                        query += ', ';
                    }
                }
                query += ' FROM Sales_Order_Items__r)';
            }
            // End the query
            query += ' FROM EUR_CRM_Sales_Order__c WHERE Id =: pSalesOrderId';
            // Run the query
            List<EUR_CRM_Sales_Order__c> salesOrderList = Database.query(query);

            if(!salesOrderList.isEmpty()){
                // Initialize the xml file
                XmlStreamWriter xmlWriteObj = new XmlStreamWriter();                
                xmlWriteObj.writeStartDocument('utf-8', '1.0'); 

                // Write the Sales Order details
                for (EUR_CRM_Sales_Order__c objSO : salesOrderList) {
                    
                    xmlWriteObj.writeStartElement(null, STR_SALESORDER, null);
                    
                    //Seller Id
                    xmlWriteObj.writeAttribute(null, null,
                                               STR_SELLERID, STR_PRSA);                    
                    
                    //ActionCode
                    xmlWriteObj.writeAttribute(null, null,
                                               STR_ACTIONCODE, STR_CREATION);

                    //Record Type Developer Name
                    xmlWriteObj.writeAttribute(null, null,
                                               STR_RECORDTYPE, 
                                               EUR_CRM_Sales_Order__c.SObjectType.getDescribe().getRecordTypeInfosById().get(so.RecordTypeId).getName());

                    //Write Fields from field set
                    for(Schema.FieldSetMember field : SOFields){
                        // Order Id from the Name field
                        if(field.getFieldPath() == 'Name'){                                
                            xmlWriteObj.writeAttribute(null, null,
                                                        STR_ID,
                                                        objSO.Name != NULL ? objSO.Name : '');
                        }
                        else {
                            xmlWriteObj.writeAttribute(null, null, 
                                                       field.getFieldPath(),
                                                       String.valueOf(objSO.get(field.getFieldPath())) != NULL ? String.valueOf(objSO.get(field.getFieldPath())) : '');
                        }
                    }

                    // Write the Sales Order Items details if they exist
                    if(objSO.Sales_Order_Items__r != null){
                        for (EUR_CRM_Sales_Order_Items__c soLineItem : objSO.Sales_Order_Items__r) {
                            
                            xmlWriteObj.writeStartElement(null, STR_SALESORDERITEM, null);
                            
                            //ActionCode
                            xmlWriteObj.writeAttribute(null, null,
                                                       STR_ACTIONCODE, STR_CREATION);                           
                            
                            //Write Fields from field Set
                            for(Schema.FieldSetMember field : SOItemFields){
                                //LineItemId from the name field
                                if(field.getFieldPath() == 'Name'){                                
                                    xmlWriteObj.writeAttribute(null, null, 
                                                               STR_LINEITEMID, 
                                                               soLineItem.Name != NULL ? soLineItem.Name : '');
                                }
                                else {
                                    xmlWriteObj.writeAttribute(null, null, 
                                                               field.getFieldPath(),
                                                               String.valueOf(soLineItem.get(field.getFieldPath())) != NULL ? String.valueOf(soLineItem.get(field.getFieldPath())) : '');
                                }
                            }

                            xmlWriteObj.writeEndElement(); // End element For each Sales Order Item
                        }
                    }

                    xmlWriteObj.writeEndElement(); // End element for each Sales Order                    
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