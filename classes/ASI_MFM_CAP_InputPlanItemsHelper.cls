/***************************************************************************************************************************
 * Name:        ASI_MFM_CAP_InputPlanItemsController
 * Description: Controller Class for ASI_MFM_CAP_InputPlanItemsPage
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-09-21       Laputa			        Created
 ****************************************************************************************************************************/

global with sharing class ASI_MFM_CAP_InputPlanItemsHelper {
	
	//TODO: polish variable name
    global static List<sObject> findList(string obj, string statement, string qry, integer limitRecord)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType queryObjectType = gd.get(obj);
        if (queryObjectType == null)
        {
            return null;
        }
        
        // create the filter text
        String filter = qry;
        
        //begin building the dynamic soql query
        String soql;
        if(!String.isBlank(filter))
            soql = 'select '+statement+' from ' + obj + filter +' order by Name limit ' + limitRecord;
        else
            soql = 'select '+statement+' from ' + obj +' order by Name limit ' + limitRecord;
        
        List<sObject> sobjs = new List<sObject>();
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        try{
            sobjs = Database.query(soql);
            return sobjs; 
        } catch (QueryException e){ 
        	return null; 
        }
        return sobjs;
    }    
    
}