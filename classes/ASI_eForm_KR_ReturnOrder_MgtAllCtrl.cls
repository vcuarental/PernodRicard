public class ASI_eForm_KR_ReturnOrder_MgtAllCtrl {
    public ASI_eForm_Return_Order_Request__c ReturnOrderRequest { get; set; } {ReturnOrderRequest = new ASI_eForm_Return_Order_Request__c();} 
    public  String DetailLineJSON {set;get;}{DetailLineJSON=null;}
    public  String VenueJSON {set;get;}{VenueJSON=null;}
    public string RecordTypeID {get;set;}
    public boolean ROEdit {set;get;} {ROEdit=true;}
    public Boolean IsR42 {set;get;} {IsR42 = False;}
    public String ComplaintCategoryPickListJSON {set;get;}{ComplaintCategoryPickListJSON=null;}
    public String ChannelReturnOptionJSON {set;get;}
    public String ChannelReplaceOptionJSON {set;get;}

    //By SharSolutions
    public class MyPickListInfo{
        public String validFor;
    }
    
    
    public ASI_eForm_KR_ReturnOrder_MgtAllCtrl(apexpages.standardController sc) {
        String RecordId = ApexPages.currentPage().getParameters().get('id');
        this.ReturnOrderRequest=[select Id,RecordType.DeveloperName,ASI_eForm_Reason__c from ASI_eForm_Return_Order_Request__c where Id = : RecordId ];
    }
    
    public pageReference init(){
        RecordTypeID=Global_RecordTypeCache.getRtId('ASI_eForm_Donation_Request_Line_Items__cASI_eForm_KR_Donation_Request_Line');
        if(this.ReturnOrderRequest !=null && this.ReturnOrderRequest.Id !=null){
            List<ASI_eForm_Return_Order_Request_Line_Item__c> ReturnOrderRequestLineList = [
                select Id,
                    ASI_eForm_Complaint_Category__c,
                    ASI_eForm_Complaint_Details__c,
                    ASI_eForm_Lot_Number__c,
                    ASI_eForm_Venue__c,
                    ASI_eForm_Venue__r.Name,
                    ASI_eForm_Production_Date__c,
                    ASI_eForm_Production_Time__c,
                    ASI_eForm_Unit_Price_Replace__c,
                    ASI_eForm_Unit_Price_Return__c,
                    ASI_eForm_Remarks__c,
                    ASI_eForm_Amount_Replace__c,
                    ASI_eForm_Amount_Return__c,
                    ASI_eForm_Item_Group_Replace__r.Name,
                    ASI_eForm_UOM_Replace__c,
                    ASI_eForm_UOM_Return__c,
                    ASI_eForm_Item_Group_Replace__r.ASI_KOR_Name_Kor__c,
                    ASI_eForm_Item_Group_Return__r.ASI_KOR_Name_Kor__c,
                    ASI_eForm_Item_Group_Return__r.Name,
                    ASI_eForm_Item_Group_Replace__c,
                    ASI_eForm_Item_Group_Return__c,
                    ASI_eForm_Quantity_Replace__c,
                    ASI_eForm_Quantity_Return__c,
                    ASI_eForm_Channel_Replace__c,
                    ASI_eForm_Channel_Return__c
                from ASI_eForm_Return_Order_Request_Line_Item__c
                where ASI_eForm_Return_Order_Request__c = :ReturnOrderRequest.Id
            ];
            DetailLineJSON=JSON.serialize(ReturnOrderRequestLineList);
        }
        
        Map<String, List<String>> ComplaintCategoryPickList = getFieldDependencies('ASI_eForm_Return_Order_Request_Line_Item__c','ASI_eForm_Complaint_Category__c','ASI_eForm_Complaint_Details__c');
        ComplaintCategoryPickListJSON=JSON.serialize(ComplaintCategoryPickList);
        ChannelReturnOptionJSON = JSON.serialize(getPickListValue('ASI_eForm_Return_Order_Request_Line_Item__c', 'ASI_eForm_Channel_Return__c'));
        ChannelReplaceOptionJSON = JSON.serialize(getPickListValue('ASI_eForm_Return_Order_Request_Line_Item__c', 'ASI_eForm_Channel_Replace__c'));
        if(ReturnOrderRequest.ASI_eForm_Reason__c.contains('R42')){
            IsR42=true;
        }
        return null;
    }
    
    
    public PageReference BackHeader() {
        return  new PageReference('/' + ReturnOrderRequest.Id); 
    }
    
    public static Map<String, List<String>> getFieldDependencies(String objectName, String controllingField, String dependentField)
    {
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
        
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
        
        for(Schema.PicklistEntry currControllingValue : controllingValues)
        {
            System.debug('ControllingField: Label:' + currControllingValue.getLabel());
            controllingInfo.put(currControllingValue.getLabel(), new List<String>());
        }
        
        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            String jsonString = JSON.serialize(currDependentValue);
            
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
            
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            
            System.debug('DependentField: Label:' + currDependentValue.getLabel() + ' ValidForInHex:' + hexString + ' JsonString:' + jsonString);
            
            Integer baseCount = 0;
            
            for(Integer curr : hexString.getChars())
            {
                Integer val = 0;
                
                if(curr >= 65){
                    val = curr - 65 + 10;
                }else{
                    val = curr - 48;
                }
                
                if((val & 8) == 8){
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 0].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                }
                
                if((val & 4) == 4){
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 1].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());                    
                }
                
                if((val & 2) == 2){
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 2].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                    
                }
                
                if((val & 1) == 1){
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 3].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());                    
                }
                
                baseCount += 4;
            }            
        } 
        
        System.debug('ControllingInfo: ' + controllingInfo);
        
        return controllingInfo;
    }
    

    
    @RemoteAction
    public static string UpdateLineItem(string LinelistJson,List<string> deletelist){
		system.debug(LinelistJson);
        List<ASI_eForm_Return_Order_Request_Line_Item__c> Linelist = (List < ASI_eForm_Return_Order_Request_Line_Item__c > ) fromJsonString(LinelistJson, List < ASI_eForm_Return_Order_Request_Line_Item__c > .class);
		
		string Mesg ='Save Success !';
        set<string> DeletelineIdSet =new set<string>();
        for(string pid:deletelist){
            DeletelineIdSet.add(pid);
        }
        system.debug('Linelist');
        system.debug(Linelist);
        List<ASI_eForm_Return_Order_Request_Line_Item__c> DeleteLines=[select Id,Name from ASI_eForm_Return_Order_Request_Line_Item__c where id in : DeletelineIdSet];
        if(DeleteLines.size()>0){
            delete DeleteLines;
        }
        upsert Linelist;
        return Mesg;
    }
    
    @RemoteAction
    public static List<sObject> findList(string obj,string statement, string qry)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) return null;
        String filter = qry;
        String soql='';
        if(filter != '' || filter != null)
            soql = 'select '+statement+' from ' + obj + filter +' order by Name';
        else
            soql = 'select '+statement+' from ' + obj +' order by Name';
        
        List<sObject> sobjs = new List<sObject>();
        List<String> results = new List<String>();
        sobjs = Database.query(soql);
        return sobjs;
    }
	
	private static Object fromJsonString(String jsonString, System.Type apexType) {
        if (String.isBlank(jsonString)) {
            return null;
        }
        return System.JSON.deserialize(jsonString, apexType);
    }

    /**
     * Return list of objects with label and value
     *
     * @param objectName
     * @param fieldName
     *
     * @return [{label: 'label1', value:'value1'}]
     */
    public List<Map<String,String>> getPickListValue(String objectName, String fieldName){
        List<Map<String,String>> options = new List<Map<String,String>>();

        List<Schema.PicklistEntry> ple = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues();
        for( Schema.PicklistEntry entry : ple){
            options.add( new Map<String,String>{
                    'label' => entry.getLabel(),
                    'value' => entry.getValue()
                });
        }
        return options;
    }
}