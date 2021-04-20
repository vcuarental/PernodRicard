/*********************************************************************************
 * Name:ASI_BRD_Generic_AccountMatrixController
 * Description: Controller for Page ASI_BRD_Generic_AccountMatrixPage
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 9/9/2015         Laputa: Hank            Created
*********************************************************************************/
public with sharing class ASI_BRD_Generic_AccountMatrixController{
    public Account acc{get;set;}
    public ASI_BRD_Generic_AccountMatrixController(ApexPages.StandardController controller) {
        acc = (Account)controller.getRecord();
        Map<String, Schema.SObjectField> accFieldMap = Schema.SObjectType.Account.fields.getMap();
        String theQuery = 'Select ';
        for(String fields  : accFieldMap.keySet()){
            theQuery += fields + ' ,';
        } 
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery += 'From Account where ID = ' + '\'' + acc.Id + '\' ';
        acc = (Account)Database.query(theQuery); 
    }
    public void save(){
        if(acc != null){
            update acc;
            Map<String, Schema.SObjectField> accFieldMap = Schema.SObjectType.Account.fields.getMap();
            String theQuery = 'Select ';
            for(String fields  : accFieldMap.keySet()){
                theQuery += fields + ' ,';
            } 
            thequery = theQuery.subString(0,theQuery.length()-1);
            thequery += 'From Account where ID = ' + '\'' + acc.Id + '\' ';
            acc = (Account)Database.query(theQuery); 
        }
    }
}