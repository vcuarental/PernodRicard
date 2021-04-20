public with sharing class EUR_CRM_GenericTable {
	
	//Tbale properties
	public String tableName {get;set;}{tableName='';}
	public Boolean hasSearch {get;set;}{hasSearch=true;}
	public Boolean hasQuickSearch{get;set;}{hasQuickSearch=true;}
	public Boolean hasPagination{get;set;}{hasPagination=true;}
	public Boolean hasFilter{get;set;}{hasFilter=true;}
	public Integer defaultDisplayLength{get;set;} {defaultDisplayLength = 50;}
	public List<Integer> displayLengthOptions{get;set;} {displayLengthOptions = new List<Integer>{10,25,50,100,200};}
	
	public List<Map<String, String>> tableDataMap {get;set;}{tableDataMap= new List<Map<String, String>>();}//JSON
	public List<sObject> tableData {get;set;}{tableData= new List<sObject>();}
	public List<String> sObjectColumns{get;set;}{sObjectColumns = new List<String>();}
	
	public List<EUR_CRM_GenericColumn>columnDetails{get;set;}{columnDetails= new List<EUR_CRM_GenericColumn>();}
	public List<String>columnNames{get{
		List<String> names = new List<String>();
		for(EUR_CRM_GenericColumn col: columnDetails){
			names.add(col.columnKey);
		}
		
		return names;
	}}
	
	public Boolean hasAddAction{get;set;}{hasAddAction = false;}
	public Boolean hasDeleteAction{get;set;}{hasDeleteAction = false;}
	
	public class EUR_CRM_GenericColumn{
		public String columnKey {get;set;}
		public String columnName {get;set;}
		public List<String> sortingOptions {get;set;}{sortingOptions = new List<String>();} //Ascending (asc) or Descending (desc)
		public List<String> classNames {get;set;} {classNames = new List<String>();}
		public Boolean isEditable{get;set;}{isEditable = false;}
	} 
	
	
}