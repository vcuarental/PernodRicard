public class ASI_TnE_KR_ProxyDriving_PDFController
{
	private ASI_TnE_Proxy_Driving_Request__c Header;
    private List<ASI_TnE_Proxy_Driving_Detail__c> Details{get;set;}
    public Boolean isSalesman{get;set;}
    public String currentHeaderID {get; set;}
    
    public ASI_TnE_KR_ProxyDriving_PDFController() {}
    
    public ASI_TnE_Proxy_Driving_Request__c getHeader()
    {
        if(Header == null && currentHeaderID != null)
        {
            Header=[select
                    Name,
                    ASI_TnE_Requestor_Record__r.Name,
                    ASI_TnE_Requester_Name__c,
                    ASI_TnE_Requester_Company__c,
                    ASI_TnE_Requester_Department__c,
                    ASI_TnE_Requester_Title__c,
                    ASI_TnE_Currency__c,
                    ASI_TnE_Total_Amount__c,
                    ASI_TnE_KR_PD_Status__c,
                    ASI_TnE_Sync_to_JDE_Date__c,
                    ASI_TnE_Proxy_Agency_Code__c,
                    ASI_TnE_Requestor_Record__r.ASI_eForm_Employee_Is_Salesman__c,
                    Owner.Name
                    from ASI_TnE_Proxy_Driving_Request__c
                    where ID = :currentHeaderID
                   ];
            isSalesman = Header.ASI_TnE_Requestor_Record__r.ASI_eForm_Employee_Is_Salesman__c;
        }
        return Header;
    }
    public List<ASI_TnE_Proxy_Driving_Detail__c> getDetails()
    {
        if (Details == null)
        {
            Details = [SELECT
                       ASI_TnE_Proxy_Driving_Request__c,
                       Name,
                       //ASI_TnE_PD_Proxy_Agency_Code__c,
                       ASI_TnE_Date__c,
                       ASI_TnE_Phone_No__c,
                       ASI_TnE_Departure_Place__c,
                       ASI_TnE_Departure_Time__c,
                       ASI_TnE_First_Dest__c,
                       ASI_TnE_Destination_Place__c,
                       ASI_TnE_Destination_Time__c,
                       ASI_TnE_Amount__c,
                       ASI_TnE_Usage__c,
                       ASI_TnE_Name_of_Customer_WS__r.Name
                       from ASI_TnE_Proxy_Driving_Detail__c
                       where ASI_TnE_Proxy_Driving_Request__c = :currentHeaderID
                      ];
        }
        return Details;
    }
    public ASI_TnE_KR_ProxyDriving_PDFController (ApexPages.StandardController stdController){}
}