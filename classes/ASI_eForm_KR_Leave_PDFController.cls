public without sharing class ASI_eForm_KR_Leave_PDFController {
    private ASI_eForm_Leave_Request__c header;
    private List<ASI_eForm_Leave_Request_Line_Item__c> Details{get; set;}
    public String currentHeaderID {get; set;}
    public static String employeeID;
    public ASI_eForm_KR_Leave_PDFController() {}
    public ASI_eForm_Leave_Request__c getHeader()
        {
            if(header == null && currentHeaderID != null){
                header = [select
                          Name,
                          ASI_eForm_Summary_Date_Leave_From__c,
                          ASI_eForm_Summary_Date_To__c,
                          ASI_eForm_Requester_Company__c,
                          ASI_eForm_Requester_Department__c,
                          ASI_eForm_Requester_Record__r.Name,
                          ASI_eForm_Requester_Name__c,
                          ASI_eForm_Requester_Title__c,
                          ASI_eForm_Status__c,
                          ASI_eForm_Total_Days__c
                          from ASI_eForm_Leave_Request__c
                          where ID = :currentHeaderID];
            }
            
            return header;
       }
    public List<ASI_eForm_Leave_Request_Line_Item__c> getDetails(){
        if (Details == null){
            Details = [select
                       Name,
                       ASI_eForm_Date_From__c,
                       ASI_eForm_Leave_Reuest__c,
                       ASI_eForm_Date_To__c,
                       ASI_eForm_Leave_Type__c,
                       ASI_eForm_No_of_Days__c,
                       ASI_eForm_Reason__c,
                       ASI_eForm_Leave_Reuest__r.ASI_eForm_Requester_Record__r.Name
                       from ASI_eForm_Leave_Request_Line_Item__c
                       where  ASI_eForm_Leave_Reuest__c = :currentHeaderId 
            ];
        }
        return Details;
    }
    
    public List<printObj> getPrintObj()
    {
        //list of print object
        Map<String,printObj> printResults = new Map<String,printObj>();
        //the current list of detail object
        List<ASI_eForm_Leave_Request_Line_Item__c> curDetail;
        //get current request detail list
        curDetail = getDetails();
        
        //if cureent request have detail
        if(curDetail.size()>0)
        {
            //record the requester employee id
            employeeID = curDetail[0].ASI_eForm_Leave_Reuest__r.ASI_eForm_Requester_Record__r.Name;
            //a string and int set to storage the Year, handle maybe more than one year in list detail
            Set<String> stringYear = new Set<String>();
            Set<Integer> intYear = new Set<Integer>();
            
            //storage the year into set
            for(ASI_eForm_Leave_Request_Line_Item__c obj : curDetail)
            {
                stringYear.add(String.valueOf(obj.ASI_eForm_Date_From__c.year()));
                intYear.add(obj.ASI_eForm_Date_From__c.year());
            }//end for : loop current detail list
            
            //get requester leave history,which is Annual leave or Special leave, Approved, same year with current leave detail
            List<ASI_eForm_Leave_Request_Line_Item__c> leaveHistory = new List<ASI_eForm_Leave_Request_Line_Item__c>
                ([SELECT
                  ASI_eForm_No_of_Days__c,
                  ASI_eForm_Leave_Type__c,
                  ASI_eForm_Date_From__c
                  FROM ASI_eForm_Leave_Request_Line_Item__c
                  WHERE ASI_eForm_Leave_Reuest__r.ASI_eForm_Requester_Record__r.Name =: employeeID 
                  AND (ASI_eForm_Leave_Type__c like '%Annual Leave%' 
                       OR ASI_eForm_Leave_Type__c like '%Special Leave%')
                  AND ASI_eForm_Leave_Reuest__r.ASI_eForm_Status__c like 'Approved'
                  AND CALENDAR_YEAR(ASI_eForm_Date_From__c) IN: intYear
                  AND ASI_eForm_Leave_Reuest__c !=: currentHeaderID]); //edited on 20160106, exclude the current header's details
            
            //map the history records, used to sum up the no. of days with same year, map<year , no. of days>
            Map<Integer,Decimal> mapHistoryAnnual = new Map<Integer,Decimal>();
            Map<Integer,Decimal> mapHistorySpecial = new Map<Integer,Decimal>();
            
            //calculate approved special leave and annual leave
            //if there is any leave history
            if(leaveHistory.size()>0)
            {
                for(ASI_eForm_Leave_Request_Line_Item__c obj : leaveHistory)
                {
                    if(obj.ASI_eForm_Leave_Type__c.contains('Annual Leave'))
                    {
                        if(!mapHistoryAnnual.containsKey(obj.ASI_eForm_Date_From__c.year()))
                            mapHistoryAnnual.put(obj.ASI_eForm_Date_From__c.year(),obj.ASI_eForm_No_of_Days__c);
                        else
                            mapHistoryAnnual.put(obj.ASI_eForm_Date_From__c.year(),mapHistoryAnnual.get(obj.ASI_eForm_Date_From__c.year())+ obj.ASI_eForm_No_of_Days__c);
                    }//end if : check is annual leave
                    else if(obj.ASI_eForm_Leave_Type__c.contains('Special Leave'))
                    {
                        if(!mapHistorySpecial.containsKey(obj.ASI_eForm_Date_From__c.year()))
                            mapHistorySpecial.put(obj.ASI_eForm_Date_From__c.year(),obj.ASI_eForm_No_of_Days__c);
                        else
                            mapHistorySpecial.put(obj.ASI_eForm_Date_From__c.year(),mapHistorySpecial.get(obj.ASI_eForm_Date_From__c.year())+ obj.ASI_eForm_No_of_Days__c);
                    }//end else if : check is special leave
                }//end for
            }//end if : check there is any leave history
            
            //get requester leave entitlement record, same year with current leave detail
            List<ASI_eForm_KR_Leave_EE__c> leaveEE = new List<ASI_eForm_KR_Leave_EE__c>
                ([SELECT ASI_eForm_Leave_Entitlement__c,
                  ASI_eForm_Total_Special_Leave__c,
                  ASI_eForm_Used_Annual_Leave__c,
                  ASI_eForm_Used_Special_Leave__c,
                  ASI_eform_Year__c
                  FROM ASI_eForm_KR_Leave_EE__c
                  WHERE ASI_eForm_Employee_Record__r.Name =: employeeID
                  AND ASI_eform_Year__c IN : stringYear]);
            
            //map object to link leave and leave entitlement
            Map<String,ASI_eForm_KR_Leave_EE__c> mapLeaveEEYear = new Map<String,ASI_eForm_KR_Leave_EE__c>();
            //if there is leave entitlement record
            if(leaveEE.size()>0)
            {
                //storage the year into map
                for(ASI_eForm_KR_Leave_EE__c obj : leaveEE)
                {
                    obj.ASI_eForm_Leave_Entitlement__c = obj.ASI_eForm_Leave_Entitlement__c != null ? obj.ASI_eForm_Leave_Entitlement__c : 0;
                    obj.ASI_eForm_Total_Special_Leave__c = obj.ASI_eForm_Total_Special_Leave__c != null ? obj.ASI_eForm_Total_Special_Leave__c : 0;
                    obj.ASI_eForm_Used_Annual_Leave__c = obj.ASI_eForm_Used_Annual_Leave__c != null ? obj.ASI_eForm_Used_Annual_Leave__c : 0;
                    obj.ASI_eForm_Used_Special_Leave__c = obj.ASI_eForm_Used_Special_Leave__c != null ? obj.ASI_eForm_Used_Special_Leave__c : 0;
                    mapLeaveEEYear.put(obj.ASI_eform_Year__c,obj);
                }//end for
            }//end if
            
            //map the current records, used to sum up the no. of days with same year, map<year , no. of days>
            Map<Integer,Decimal> mapCurrentAnnual = new Map<Integer,Decimal>();
            Map<Integer,Decimal> mapCurrentSpecial = new Map<Integer,Decimal>();
            
            for(ASI_eForm_Leave_Request_Line_Item__c obj : curDetail)
            {
                printObj priObj = new printObj();
                priObj.Reason = obj.ASI_eForm_Reason__c;
                if(obj.ASI_eForm_Leave_Type__c.contains('Annual Leave'))
                {
                    priObj.leaveType = 'Annual Leave';
                    //for calculate used leave
                    if(mapHistoryAnnual.get(obj.ASI_eForm_Date_From__c.year())!=null
                       &&mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year()))!=null)
                    {
                        priObj.usedDays = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Used_Annual_Leave__c + mapHistoryAnnual.get(obj.ASI_eForm_Date_From__c.year());
                        priObj.leaveEntitlement = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Leave_Entitlement__c;
                        priObj.leaveEEYear = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eform_Year__c;
                    }//end if
                    else if(mapHistoryAnnual.get(obj.ASI_eForm_Date_From__c.year())!=null
                            &&mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year()))==null)
                    {
                        priObj.usedDays = mapHistoryAnnual.get(obj.ASI_eForm_Date_From__c.year());
                        priObj.leaveEntitlement = 0;
                        priObj.leaveEEYear = 'N/A';
                    }//end else if
                    else if(mapHistoryAnnual.get(obj.ASI_eForm_Date_From__c.year())==null
                            &&mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year()))!=null)
                    {
                        priObj.usedDays = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Used_Annual_Leave__c;
                        priObj.leaveEntitlement = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Leave_Entitlement__c;
                        priObj.leaveEEYear = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eform_Year__c;
                    }//end else if
                    else
                    {
                        priObj.usedDays = 0;
                        priObj.leaveEntitlement = 0;
                        priObj.leaveEEYear = 'N/A';
                    }
                    /*if(mapHistoryAnnual.get(obj.ASI_eForm_Date_From__c.year())!=null
                       &&mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year()))!=null
                       &&mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Used_Annual_Leave__c!=null)
                    {
                        priObj.usedDays = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Used_Annual_Leave__c + mapHistoryAnnual.get(obj.ASI_eForm_Date_From__c.year());
                    	priObj.leaveEntitlement = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Leave_Entitlement__c;
                        priObj.leaveEEYear = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eform_Year__c;
                    }
                    else if(mapHistoryAnnual.get(obj.ASI_eForm_Date_From__c.year())==null
                            &&mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year()))!=null
                            &&mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Used_Annual_Leave__c!=null)
                    {
                        priObj.usedDays = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Used_Annual_Leave__c;
                        priObj.leaveEntitlement = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Leave_Entitlement__c;
                        priObj.leaveEEYear = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eform_Year__c;
                    }
                    else if(mapHistoryAnnual.get(obj.ASI_eForm_Date_From__c.year())!=null
                            &&mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year()))==null)
                    {
                        priObj.usedDays = mapHistoryAnnual.get(obj.ASI_eForm_Date_From__c.year());
                        priObj.leaveEntitlement = 0;
                        priObj.leaveEEYear = 'N/A';
                    }
                    else
                    {
                        priObj.usedDays = 0;
                        priObj.leaveEntitlement = 0;
                        priObj.leaveEEYear = 'N/A';
                    }*/
                    //for calculate current annual leave num of days
                    if(!mapCurrentAnnual.containsKey(obj.ASI_eForm_Date_From__c.year()))
                        mapCurrentAnnual.put(obj.ASI_eForm_Date_From__c.year(),obj.ASI_eForm_No_of_Days__c);
                    else
                        mapCurrentAnnual.put(obj.ASI_eForm_Date_From__c.year(),mapCurrentAnnual.get(obj.ASI_eForm_Date_From__c.year())+ obj.ASI_eForm_No_of_Days__c);
                    priObj.noOfDays = mapCurrentAnnual.get(obj.ASI_eForm_Date_From__c.year());
                    priObj.leaveBalance = priObj.leaveEntitlement - priObj.usedDays - priObj.noOfDays;
                }//end if : annual leave
                else if(obj.ASI_eForm_Leave_Type__c.contains('Special Leave') || obj.ASI_eForm_Leave_Type__c.contains('Compensation Leave'))   // [SH] 2018-12-03 ** Add Compensation Leave 
                {
                    priObj.leaveType = obj.ASI_eForm_Leave_Type__c.contains('Special Leave') ? 'Special Leave' : 'Compensation Leave';                    
                    //for calculate used leave                    
                    if(mapHistorySpecial.get(obj.ASI_eForm_Date_From__c.year())!=null
                       &&mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year()))!=null)
                    {
                        priObj.usedDays = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Used_Special_Leave__c + mapHistorySpecial.get(obj.ASI_eForm_Date_From__c.year());
                    	priObj.leaveEntitlement = priObj.leaveType == 'Compensation Leave' ? 0: mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Total_Special_Leave__c;        //[SH] 2018-12-03 ** Add Compensation Leave
                        priObj.leaveEEYear = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eform_Year__c;
                    }//end if
                    else if(mapHistorySpecial.get(obj.ASI_eForm_Date_From__c.year())!=null
                            &&mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year()))==null)
                    {
                        priObj.usedDays = mapHistorySpecial.get(obj.ASI_eForm_Date_From__c.year());
                    	priObj.leaveEntitlement = 0;
                        priObj.leaveEEYear = 'N/A';
                    }//end else if
                    else if(mapHistorySpecial.get(obj.ASI_eForm_Date_From__c.year())==null
                            &&mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year()))!=null)
                    {
                        priObj.usedDays = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Used_Special_Leave__c;
                    	priObj.leaveEntitlement = priObj.leaveType == 'Compensation Leave' ? 0: mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Total_Special_Leave__c;       //[SH] 2018-12-03 ** Add Compensation Leave
                        priObj.leaveEEYear = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eform_Year__c;
                    }//end else if                    
                    else
                    {
                        priObj.usedDays = 0;
                        priObj.leaveEntitlement = 0;
                        priObj.leaveEEYear = 'N/A';
                    }//end else
                    /*if(mapHistorySpecial.get(obj.ASI_eForm_Date_From__c.year())!=null
                       &&mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year()))!=null
                       &&mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Used_Special_Leave__c!=null)
                    {
                        priObj.usedDays = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Used_Special_Leave__c + mapHistorySpecial.get(obj.ASI_eForm_Date_From__c.year());
                    	priObj.leaveEntitlement = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Total_Special_Leave__c;
                        priObj.leaveEEYear = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eform_Year__c;
                    }
                    else if(mapHistorySpecial.get(obj.ASI_eForm_Date_From__c.year())==null
                            &&mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year()))!=null
                            &&mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Used_Special_Leave__c!=null)
                    {
                        priObj.usedDays = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Used_Special_Leave__c;
                    	priObj.leaveEntitlement = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eForm_Total_Special_Leave__c;
                        priObj.leaveEEYear = mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year())).ASI_eform_Year__c;
                    }
                    else if(mapHistorySpecial.get(obj.ASI_eForm_Date_From__c.year())!=null
                            &&mapLeaveEEYear.get(String.valueOf(obj.ASI_eForm_Date_From__c.year()))==null)
                    {
                        priObj.usedDays = mapHistorySpecial.get(obj.ASI_eForm_Date_From__c.year());
                    	priObj.leaveEntitlement = 0;
                        priObj.leaveEEYear = 'N/A';
                    }
                    else
                    {
                        priObj.usedDays = 0;
                        priObj.leaveEntitlement = 0;
                        priObj.leaveEEYear = 'N/A';
                    }*/
                    //for calculate current annual leave num of days
                    if(!mapCurrentSpecial.containsKey(obj.ASI_eForm_Date_From__c.year()))
                        mapCurrentSpecial.put(obj.ASI_eForm_Date_From__c.year(),obj.ASI_eForm_No_of_Days__c);
                    else
                        mapCurrentSpecial.put(obj.ASI_eForm_Date_From__c.year(),mapCurrentSpecial.get(obj.ASI_eForm_Date_From__c.year())+ obj.ASI_eForm_No_of_Days__c);
                    priObj.noOfDays = mapCurrentSpecial.get(obj.ASI_eForm_Date_From__c.year());
                    priObj.leaveBalance = priObj.leaveType == 'Special Leave' ? priObj.leaveEntitlement - priObj.usedDays - priObj.noOfDays: 0;
                }//end else if : special leave
                else
                {
                    priObj.leaveType = obj.ASI_eForm_Leave_Type__c;
                    priObj.noOfDays = obj.ASI_eForm_No_of_Days__c;
                    priObj.leaveEntitlement = null;
                    priObj.usedDays = null;
                    priObj.leaveBalance = null;
                    priObj.leaveEEYear = '';
                }//end else : other leave
                
                //adding print object to print map
                if(!printResults.containsKey(priObj.leaveType+obj.ASI_eForm_Date_From__c.year()))
                    printResults.put(priObj.leaveType+obj.ASI_eForm_Date_From__c.year(),priObj);
                else
                    printResults.put(priObj.leaveType+obj.ASI_eForm_Date_From__c.year(),priObj);
            }//end for
            return printResults.values();
        }//end if : check current detail is null or not
        else
            return null;
    }//end method
    
    public class printObj
    {
        public String leaveType{get;set;}
        public Decimal noOfDays{get;set;}
        public String Reason{get;set;}
        public String leaveEEYear{get;set;}
        public Decimal leaveEntitlement{get;set;}
        public Decimal usedDays{get;set;}
        public Decimal leaveBalance{get;set;}
    }
            public ASI_eForm_KR_Leave_PDFController (ApexPages.StandardController stdController){}
}