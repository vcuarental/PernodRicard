/*
Developed by StellaLi
Used for IPAD Integration
*/
@RestResource(UrlMapping='/ASI_CRM_CN_Upsert_Customer/*')
global without sharing class ASI_CRM_CN_Upsert_Customer{
    global Class Customer{
    global list <CustomerStructure> Customerlist{set;get;}    
    }
 @HttpPost
    global static string UpsertCustomer(String jsonString ){ 
    /*SAMPLE JSON FORMAT
    Insert :
   {"jsonString":"{\"Customerlist\":[{\"RecordID\":\"\",\"Sub_Channel\":\"a8ZM00000008OMh\",\"Local_Update_Time\":\"2014/11/30 14:20\",\"Business_License_Expire_Date\":\"2018/11/28\",\"Warehouse_Email\":\"a@b.com\",\"Effective_From\":\"2014/11/30\",\"Effective_To\":\"2014/12/11\",\"Inactive_Flag\":true,\"Dummy_Outlet_Flag\":null,\"IHBR_Outlet\":false,\"Require_Visit\":true,\"Cap_Collection\":true,\"Same_as_above_CAP\":true,\"PRC_Direct_Sales_Flag\":true,\"Group_Price_PR_Direct\":true,\"Same_as_above_PR_Direct\":true,\"VAT_Invoice_Application\":true,\"Business_License_uploading_Y\":true,\"Same_as_above_Brand_T1\":true,\"Scan_Device_Application\":true,\"Parent_Outlet\":\"\",\"Chi_Name\":\"t1q1\",\"Eng_Name\":\"t4q4\",\"Legal_Name\":\"tq33\",\"City\":\"a9AM00000008OaE\",\"KA_Account\":\"METRO\",\"Phone_Number\":\"47124712\",\"Fax_Number\":\"12341234\",\"Position\":\"Consultant\",\"Tel\":\"48324832\",\"Address\":\"California\",\"Image\":\"Iconic\",\"CR12_Btl_per_month\":\"73\",\"Energy\":\"High\",\"Address_CAP\":\"Cali\",\"Tel_Cap\":\"1234564\",\"Frequency_CAP\":\"45\",\"Bank\":\"HS\",\"Bank_Account\":\"HS123\",\"Tax_Registration_Number\":\"123452\",\"Phone_Number_PR_Direct\":\"6666666\",\"Estimated_Annual_Order_Amount_in_CNY\":\"4567\",\"Proposed_Credit_Term_Days\":\"21\",\"Group_Name_PR_Direct\":\"AVC\",\"Address_PR_Direct\":\"Cali2\",\"ON_CO_P\":\"5\",\"Chinese_Rest_P\":\"5\",\"TOT_P\":\"5\",\"Bulkpurchase_P\":\"5\",\"LY_Operating_Income_RMB\":\"12345\",\"ON_NCO_P\":\"5\",\"Hotel_P\":\"5\",\"MOT_P\":\"5\",\"T3_P\":\"5\",\"Credit_Terms_days\":\"31\",\"IS_P\":\"10\",\"Beer_P\":\"10\",\"Other_Spirits_P\":\"10\",\"Wine_P\":\"10\",\"Baijiu_P\":\"10\",\"Others_P\":\"10\",\"Brand_T1_Group\":\"Local Wine\",\"Discount_Brand_T1_P\":\"0.8\",\"Phone_Number_Brand_T1\":\"12222220\",\"Address_Brand_T1\":\"cali2\",\"Warehouse_Tel\":\"2345677\",\"T1_WS\":\"\",\"PG_Head\":\"\",\"Warehouse_Address1\":\"cali4\",\"Warehouse_Address2\":\"cali5\",\"Contact_Person\":\"\",\"Contact_Person_CAP\":\"\",\"RecordType\":\"012M00000000V1w\"}]}"}
    Update :
   {"jsonString":"{\"Customerlist\":[{\"RecordID\":\"a8bM00000008Qw7\",\"Sub_Channel\":\"a8ZM00000008OMh\",\"Local_Update_Time\":\"2014/11/30 14:20\",\"Business_License_Expire_Date\":\"2018/11/28\",\"Warehouse_Email\":\"a@b.com\",\"Effective_From\":\"2014/11/30\",\"Effective_To\":\"2014/12/11\",\"Inactive_Flag\":true,\"Dummy_Outlet_Flag\":null,\"IHBR_Outlet\":false,\"Require_Visit\":true,\"Cap_Collection\":true,\"Same_as_above_CAP\":true,\"PRC_Direct_Sales_Flag\":true,\"Group_Price_PR_Direct\":true,\"Same_as_above_PR_Direct\":true,\"VAT_Invoice_Application\":true,\"Business_License_uploading_Y\":true,\"Same_as_above_Brand_T1\":true,\"Scan_Device_Application\":true,\"Parent_Outlet\":\"\",\"Chi_Name\":\"t11\",\"Eng_Name\":\"t44\",\"Legal_Name\":\"t33\",\"City\":\"a9AM00000008OaE\",\"KA_Account\":\"METRO\",\"Phone_Number\":\"47124712\",\"Fax_Number\":\"12341234\",\"Position\":\"Consultant\",\"Tel\":\"48324832\",\"Address\":\"California\",\"Image\":\"Iconic\",\"CR12_Btl_per_month\":\"73\",\"Energy\":\"High\",\"Address_CAP\":\"Cali\",\"Tel_Cap\":\"1234564\",\"Frequency_CAP\":\"45\",\"Bank\":\"HS\",\"Bank_Account\":\"HS123\",\"Tax_Registration_Number\":\"123452\",\"Phone_Number_PR_Direct\":\"6666666\",\"Estimated_Annual_Order_Amount_in_CNY\":\"4567\",\"Proposed_Credit_Term_Days\":\"21\",\"Group_Name_PR_Direct\":\"AVC\",\"Address_PR_Direct\":\"Cali2\",\"ON_CO_P\":\"5\",\"Chinese_Rest_P\":\"5\",\"TOT_P\":\"5\",\"Bulkpurchase_P\":\"5\",\"LY_Operating_Income_RMB\":\"12345\",\"ON_NCO_P\":\"5\",\"Hotel_P\":\"5\",\"MOT_P\":\"5\",\"T3_P\":\"5\",\"Credit_Terms_days\":\"31\",\"IS_P\":\"10\",\"Beer_P\":\"10\",\"Other_Spirits_P\":\"10\",\"Wine_P\":\"10\",\"Baijiu_P\":\"10\",\"Others_P\":\"10\",\"Brand_T1_Group\":\"Local Wine\",\"Discount_Brand_T1_P\":\"0.8\",\"Phone_Number_Brand_T1\":\"12222220\",\"Address_Brand_T1\":\"cali2\",\"Warehouse_Tel\":\"2345677\",\"T1_WS\":\"\",\"PG_Head\":\"\",\"Warehouse_Address1\":\"cali4\",\"Warehouse_Address2\":\"cali5\"}]}"}
	Outlet insert:
	{"jsonString":"{\"Customerlist\":[{\"RecordID\":\"\",\"Sub_Channel\":\"a8ZM00000008OMh\",\"Local_Update_Time\":\"2014/11/30 14:20\",\"Business_License_Expire_Date\":\"2018/11/28\",\"Warehouse_Email\":\"a@b.com\",\"Effective_From\":\"2014/11/30\",\"Effective_To\":\"2014/12/11\",\"Inactive_Flag\":true,\"Dummy_Outlet_Flag\":null,\"IHBR_Outlet\":false,\"Require_Visit\":true,\"Cap_Collection\":true,\"Same_as_above_CAP\":true,\"PRC_Direct_Sales_Flag\":true,\"Group_Price_PR_Direct\":true,\"Same_as_above_PR_Direct\":true,\"VAT_Invoice_Application\":true,\"Business_License_uploading_Y\":true,\"Same_as_above_Brand_T1\":true,\"Scan_Device_Application\":true,\"Parent_Outlet\":\"\",\"Chi_Name\":\"t1q102\",\"Eng_Name\":\"t4q402\",\"Legal_Name\":\"tq3302\",\"City\":\"a9AM00000008OaE\",\"KA_Account\":\"METRO\",\"Phone_Number\":\"47124712\",\"Fax_Number\":\"12341234\",\"Position\":\"Consultant\",\"Tel\":\"48324832\",\"Address\":\"California\",\"Image\":\"Iconic\",\"CR12_Btl_per_month\":\"73\",\"Energy\":\"High Energy\",\"Address_CAP\":\"Cali\",\"Tel_Cap\":\"1234564\",\"Frequency_CAP\":\"45\",\"Bank\":\"HS\",\"Bank_Account\":\"HS123\",\"Tax_Registration_Number\":\"123452\",\"Phone_Number_PR_Direct\":\"6666666\",\"Estimated_Annual_Order_Amount_in_CNY\":\"4567\",\"Proposed_Credit_Term_Days\":\"21\",\"Group_Name_PR_Direct\":\"AVC\",\"Address_PR_Direct\":\"Cali2\",\"ON_CO_P\":\"5\",\"Chinese_Rest_P\":\"5\",\"TOT_P\":\"5\",\"Bulkpurchase_P\":\"5\",\"LY_Operating_Income_RMB\":\"12345\",\"ON_NCO_P\":\"5\",\"Hotel_P\":\"5\",\"MOT_P\":\"5\",\"T3_P\":\"5\",\"Credit_Terms_days\":\"31\",\"IS_P\":\"10\",\"Beer_P\":\"10\",\"Other_Spirits_P\":\"10\",\"Wine_P\":\"10\",\"Baijiu_P\":\"10\",\"Others_P\":\"10\",\"Brand_T1_Group\":\"Local Wine\",\"Discount_Brand_T1_P\":\"0.8\",\"Phone_Number_Brand_T1\":\"12222220\",\"Address_Brand_T1\":\"cali2\",\"Warehouse_Tel\":\"2345677\",\"T1_WS\":\"\",\"PG_Head\":\"\",\"Warehouse_Address1\":\"cali4\",\"Warehouse_Address2\":\"cali5\",\"Contact_Person\":\"\",\"Contact_Person_CAP\":\"\",\"RecordType\":\"012M00000000VhJ\",\"website\":\"test website\",\"district\":\"test district\",\"postCode\":\"1\",\"latitude\":31.2304,\"longitude\":121.4737,\"newChannel\":\"\",\"prosChannel\":\"\",\"outletCapacity\":\"<50\",\"vipCorner\":true,\"sizeSQM\":\"1\",\"rating\":\"1\",\"prcVolumn\":\"1\",\"isVolumn\":\"1\",\"occupancyRate\":\"1\",\"dedicatedService\":true,\"popularity\":\"1\",\"careerBartender\":true,\"cocktailPrice\":\"1\",\"outlettype\":\"Pub\",\"backbar\":true,\"beerPrice\":\"1\",\"numRoom\":\"1\",\"hostesses\":true,\"tipsPrice\":\"1\",\"rtdVolumn\":\"1\",\"supermarket\":true,\"roomPrice\":\"1\",\"x12BtBeerPrice\":\"1\",\"typeRestaurant\":\"Chinese Round Table\",\"spendPerHead\":\"1\",\"typeCuisine\":\"Cantonese\",\"brand\":\"International\",\"guestRoomPrice\":\"1\",\"outletChannelType\":\"Nightclub\",\"numOfStars\":\"5\"}],\"kaAccountChain\":\"\",\"sofaTablePrice\":\"1\",\"vipPrivateRoom\":true,\"channelStrategy\":\"test channel strategy\"}"}
	Outlet Update:
	{"jsonString":"{\"Customerlist\":[{\"RecordID\":\"a8bM00000008tWH\",\"Sub_Channel\":\"a8ZM00000008OMh\",\"Local_Update_Time\":\"2014/11/30 14:20\",\"Business_License_Expire_Date\":\"2018/11/28\",\"Warehouse_Email\":\"a@b.com\",\"Effective_From\":\"2014/11/30\",\"Effective_To\":\"2014/12/11\",\"Inactive_Flag\":true,\"Dummy_Outlet_Flag\":null,\"IHBR_Outlet\":false,\"Require_Visit\":true,\"Cap_Collection\":true,\"Same_as_above_CAP\":true,\"PRC_Direct_Sales_Flag\":true,\"Group_Price_PR_Direct\":true,\"Same_as_above_PR_Direct\":true,\"VAT_Invoice_Application\":true,\"Business_License_uploading_Y\":true,\"Same_as_above_Brand_T1\":true,\"Scan_Device_Application\":true,\"Parent_Outlet\":\"\",\"Chi_Name\":\"t1q102\",\"Eng_Name\":\"t4q402\",\"Legal_Name\":\"tq3302\",\"City\":\"a9AM00000008OaE\",\"KA_Account\":\"METRO\",\"Phone_Number\":\"47124712\",\"Fax_Number\":\"12341234\",\"Position\":\"Consultant\",\"Tel\":\"48324832\",\"Address\":\"California\",\"Image\":\"Iconic\",\"CR12_Btl_per_month\":\"73\",\"Energy\":\"High Energy\",\"Address_CAP\":\"Cali\",\"Tel_Cap\":\"1234564\",\"Frequency_CAP\":\"45\",\"Bank\":\"HS\",\"Bank_Account\":\"HS123\",\"Tax_Registration_Number\":\"123452\",\"Phone_Number_PR_Direct\":\"6666666\",\"Estimated_Annual_Order_Amount_in_CNY\":\"4567\",\"Proposed_Credit_Term_Days\":\"21\",\"Group_Name_PR_Direct\":\"AVC\",\"Address_PR_Direct\":\"Cali2\",\"ON_CO_P\":\"5\",\"Chinese_Rest_P\":\"5\",\"TOT_P\":\"5\",\"Bulkpurchase_P\":\"5\",\"LY_Operating_Income_RMB\":\"12345\",\"ON_NCO_P\":\"5\",\"Hotel_P\":\"5\",\"MOT_P\":\"5\",\"T3_P\":\"5\",\"Credit_Terms_days\":\"31\",\"IS_P\":\"10\",\"Beer_P\":\"10\",\"Other_Spirits_P\":\"10\",\"Wine_P\":\"10\",\"Baijiu_P\":\"10\",\"Others_P\":\"10\",\"Brand_T1_Group\":\"Local Wine\",\"Discount_Brand_T1_P\":\"0.8\",\"Phone_Number_Brand_T1\":\"12222220\",\"Address_Brand_T1\":\"cali2\",\"Warehouse_Tel\":\"2345677\",\"T1_WS\":\"\",\"PG_Head\":\"\",\"Warehouse_Address1\":\"cali4\",\"Warehouse_Address2\":\"cali5\",\"Contact_Person\":\"\",\"Contact_Person_CAP\":\"\",\"RecordType\":\"012M00000000VhJ\",\"website\":\"test website\",\"district\":\"test district\",\"postCode\":\"1\",\"latitude\":31.2304,\"longitude\":121.4737,\"newChannel\":\"\",\"prosChannel\":\"\",\"outletCapacity\":\"<50\",\"vipCorner\":false,\"sizeSQM\":\"1\",\"rating\":\"1\",\"prcVolumn\":\"1\",\"isVolumn\":\"1\",\"occupancyRate\":\"1\",\"dedicatedService\":false,\"popularity\":\"1\",\"careerBartender\":false,\"cocktailPrice\":\"1\",\"outlettype\":\"Pub\",\"backbar\":false,\"beerPrice\":\"1\",\"numRoom\":\"1\",\"hostesses\":false,\"tipsPrice\":\"1\",\"rtdVolumn\":\"1\",\"supermarket\":false,\"roomPrice\":\"1\",\"x12BtBeerPrice\":\"1\",\"typeRestaurant\":\"Chinese Round Table\",\"spendPerHead\":\"1\",\"typeCuisine\":\"Cantonese\",\"brand\":\"International\",\"guestRoomPrice\":\"1\",\"outletChannelType\":\"Nightclub\",\"numOfStars\":\"1\"}],\"kaAccountChain\":\"\",\"sofaTablePrice\":\"1\",\"vipPrivateRoom\":true,\"channelStrategy\":\"test channel strategy\"}"}
    */
    Customer Customer1 = (Customer)JSON.deserialize(jsonString,Customer.class);     
     List <ASI_CRM_AccountsAdditionalField__c> a = New List<ASI_CRM_AccountsAdditionalField__c>();
        for(CustomerStructure c1: Customer1.Customerlist) { 
            ASI_CRM_AccountsAdditionalField__c b = New ASI_CRM_AccountsAdditionalField__c();
            
            if( c1.RecordID != null && c1.RecordID !='')
            {
                b.id = c1.RecordID;
            }
            b.RecordTypeID=c1.RecordType;
            if(c1.Local_Update_Time!= null && c1.Local_Update_Time!= ''){
                   
                    integer YYYY = integer.valueof(c1.Local_Update_Time.left(4));
                    integer MM = integer.valueof(c1.Local_Update_Time.mid(5,2));
                    integer DD = integer.valueof(c1.Local_Update_Time.mid(8,2));
                    integer HH = integer.valueof(c1.Local_Update_Time.mid(11,2));
                    integer Min = integer.valueof(c1.Local_Update_Time.right(2));
                    b.ASI_CRM_Local_Update_Time__c = Datetime.newInstance(YYYY,MM,DD,HH,Min,0);}
            else{
                     b.ASI_CRM_Local_Update_Time__c = Datetime.now();
                  }   
            b.ASI_CRM_CN_Chi_Name__c=c1.Chi_Name;
            b.ASI_CRM_CN_Eng_Name__c=c1.Eng_Name;
            b.ASI_CRM_CN_Legal_Name__c=c1.Legal_Name;
 
            if (c1.City== ''){                        
                 b.ASI_CRM_CN_CCity__c=null;
              }else{
               b.ASI_CRM_CN_CCity__c=c1.City;
              }
           
             if (c1.Inactive_Flag== null){                        
                 b.ASI_CRM_CN_Inactive_Flag__c=false;
              }else{
                 b.ASI_CRM_CN_Inactive_Flag__c=c1.Inactive_Flag;
              }
              
             if (c1.Parent_Outlet== ''){                        
                 b.ASI_CRM_CN_Parent_Outlet__c=null;
              }else{
                 b.ASI_CRM_CN_Parent_Outlet__c=c1.Parent_Outlet;
              }
              
            if (c1.Dummy_Outlet_Flag== null){                        
                 b.ASI_CRM_CN_Dummy_Outlet_Flag__c=false;
              }else{
                 b.ASI_CRM_CN_Dummy_Outlet_Flag__c=c1.Dummy_Outlet_Flag;
              }
         
            b.ASI_CRM_CN_KA_Account__c=c1.KA_Account;
           
            if (c1.IHBR_Outlet== null){                        
                 b.ASI_CRM_CN_Is_IHBR_Outlet__c=false;
             }else{
                 b.ASI_CRM_CN_Is_IHBR_Outlet__c=c1.IHBR_Outlet;
              }
            
             if (c1.Require_Visit== null){                        
                 b.ASI_CRM_CN_Require_Visit__c=false;
             }else{
                 b.ASI_CRM_CN_Require_Visit__c=c1.Require_Visit;
              }
            b.ASI_CRM_CN_Phone_Number__c=c1.Phone_Number;
            b.ASI_CRM_CN_Fax_Number__c=c1.Fax_Number;
            b.ASI_CRM_CN_Email__c=c1.Email;
            b.ASI_CRM_CN_Contact_Person__c=c1.Contact_Person;
            b.ASI_CRM_CN_Position__c=c1.Position;
            b.ASI_CRM_CN_Tel__c=c1.Tel;
            b.ASI_CRM_CN_Address__c=c1.Address;
            
            if (c1.Sub_Channel== null ||c1.Sub_Channel== ''){                        
                   b.ASI_CRM_CN_Sub_Channel__c=null;
            }else{
                b.ASI_CRM_CN_Sub_Channel__c=c1.Sub_Channel;
            }
              
           
            if (c1.Image== null ||c1.Image== ''){                        
                b.ASI_CRM_CN_Image__c=null;
            }else{
                b.ASI_CRM_CN_Image__c=c1.Image;
            }
           
            b.ASI_CRM_CN_CR12_Btl_per_month__c=c1.CR12_Btl_per_month;
            b.ASI_CRM_CN_Energy__c=c1.Energy;
       
             if (c1.PG_Head== ''){                        
                 b.ASI_CRM_CN_PG_Head__c=null;
              }else{
                 b.ASI_CRM_CN_PG_Head__c=c1.PG_Head;
              }

            if (c1.Cap_Collection== null){                        
                 b.ASI_CRM_CN_Cap_collection__c=false;
             }else{
                 b.ASI_CRM_CN_Cap_collection__c=c1.Cap_Collection;
              }

            b.ASI_CRM_CN_Address_CAP__c=c1.Address_CAP;
            b.ASI_CRM_CN_Contact_Person_CAP__c=c1.Contact_Person_CAP;
            if (c1.Same_as_above_CAP== null){                        
                 b.ASI_CRM_CN_Same_as_above_CAP__c=false;
             }else{
                 b.ASI_CRM_CN_Same_as_above_CAP__c=c1.Same_as_above_CAP;
              }

            b.ASI_CRM_CN_Tel_CAP__c=c1.Tel_Cap;
            b.ASI_CRM_CN_Frequency_CAP__c=c1.Frequency_CAP;
            if (c1.PRC_Direct_Sales_Flag== null){                        
                 b.ASI_CRM_CN_PRC_Direct_Sales_Flag__c=false;
             }else{
                 b.ASI_CRM_CN_PRC_Direct_Sales_Flag__c=c1.PRC_Direct_Sales_Flag;
              }

            //b.ASI_CRM_CN_PRC_Direct_Sales_Flag__c=true;
            b.ASI_CRM_CN_Bank__c=c1.Bank;
            b.ASI_CRM_CN_Bank_account__c=c1.Bank_Account;
            b.ASI_CRM_CN_Tax_registration_number__c=c1.Tax_Registration_Number;           
            if(c1.Business_License_Expire_Date!= null && c1.Business_License_Expire_Date!= ''){
                   
                    integer YYYY= integer.valueof(c1.Business_License_Expire_Date.left(4));
                    integer MM= integer.valueof(c1.Business_License_Expire_Date.mid(5,2));
                    integer DD= integer.valueof(c1.Business_License_Expire_Date.right(2));
                   
                    b.ASI_CRM_CN_Business_License_Expire_date__c= date.newinstance(YYYY,MM,DD);}
            else{
                    b.ASI_CRM_CN_Business_License_Expire_date__c= null;
                 }
                 
            if (c1.Group_Price_PR_Direct== null){                        
                 b.ASI_CRM_CN_Group_Price_PR_Direct__c=false;
             }else{
                 b.ASI_CRM_CN_Group_Price_PR_Direct__c=c1.Group_Price_PR_Direct;
              }
              
             if (c1.Same_as_above_PR_Direct== null){                        
                 b.ASI_CRM_CN_Same_as_above_PR_Direct__c=false;
             }else{
                 b.ASI_CRM_CN_Same_as_above_PR_Direct__c=c1.Same_as_above_PR_Direct;
              }
              
            b.ASI_CRM_CN_Phone_Number_PR_Direct__c=c1.Phone_Number_PR_Direct;
            if (c1.VAT_Invoice_Application== null){                        
                 b.ASI_CRM_CN_VAT_Invoice_application__c=false;
             }else{
                 b.ASI_CRM_CN_VAT_Invoice_application__c=c1.VAT_Invoice_Application;
              }
            //20160608
            if (c1.VAT_Special_Invoice== null){                        
                 b.ASI_CRM_VAT_Special_Invoice__c=false;
             }else{
                 b.ASI_CRM_VAT_Special_Invoice__c=c1.VAT_Special_Invoice;
              }
            //20160608
           
            if (c1.Business_License_uploading_Y== null){                        
                 b.ASI_CRM_CN_BusinessLicenseUploading__c=false;
             }else{
                 b.ASI_CRM_CN_BusinessLicenseUploading__c=c1.Business_License_uploading_Y;
              }
            b.ASI_CRM_CN_Group_Name_PR_Direct__c=c1.Group_Name_PR_Direct;
            b.ASI_CRM_CN_Address_PR_Direct__c=c1.Address_PR_Direct;

            if (c1.T1_WS== ''){                        
                 b.ASI_CRM_CN_T1_WS1__c=null;
              }else{
                 b.ASI_CRM_CN_T1_WS1__c=c1.T1_WS;
              }
            b.ASI_CRM_CN_ON_CO__c=c1.ON_CO_P;
            b.ASI_CRM_CN_ON_NCO__c=c1.ON_NCO_P;
            b.ASI_CRM_CN_Chinese_Rest__c=c1.Chinese_Rest_P;
            b.ASI_CRM_CN_TOT__c=c1.TOT_P;
            b.ASI_CRM_CN_Bulkpurchase__c=c1.Bulkpurchase_P;
            b.ASI_CRM_CN_LY_Operating_Income_RMB__c=c1.LY_Operating_Income_RMB;       
            b.ASI_CRM_CN_Hotel__c=c1.Hotel_P;
            b.ASI_CRM_CN_MOT__c=c1.MOT_P;
            b.ASI_CRM_CN_T3__c=c1.T3_P;
            b.ASI_CRM_CN_Credit_Terms_days__c=c1.Credit_Terms_days;
            b.ASI_CRM_CN_IS__c=c1.IS_P;
            b.ASI_CRM_CN_Beer__c=c1.Beer_P;
            b.ASI_CRM_CN_Other_spirits__c=c1.Other_Spirits_P;
            b.ASI_CRM_CN_Wine__c=c1.Wine_P;
            b.ASI_CRM_CN_Baijiu__c=c1.Baijiu_P;
            b.ASI_CRM_CN_Others__c=c1.Others_P;
            b.ASI_CRM_CN_Brand__c=c1.Brand_T1_Group;
            if(c1.Effective_From!= null && c1.Effective_From!= ''){
                   
                    integer YYYY= integer.valueof(c1.Effective_From.left(4));
                    integer MM= integer.valueof(c1.Effective_From.mid(5,2));
                    integer DD= integer.valueof(c1.Effective_From.right(2));
                   
                    b.ASI_CRM_CN_Effective_From__c= date.newinstance(YYYY,MM,DD);}
            else{
                    b.ASI_CRM_CN_Effective_From__c= null;
                 }

            if(c1.Effective_To!= null && c1.Effective_To!= ''){
                   
                    integer YYYY= integer.valueof(c1.Effective_To.left(4));
                    integer MM= integer.valueof(c1.Effective_To.mid(5,2));
                    integer DD= integer.valueof(c1.Effective_To.right(2));
                   
                    b.ASI_CRM_CN_Effective_To__c= date.newinstance(YYYY,MM,DD);}
            else{
                    b.ASI_CRM_CN_Effective_To__c= null;
                 }
            b.ASI_CRM_CN_Estimated_annual_order_amount__c=c1.Estimated_Annual_Order_Amount_in_CNY;
            //b.ASI_CRM_CN_Proposed_Credit_term_days__c=c1.Proposed_Credit_Term_Days1;
            b.ASI_CRM_CN_Proposed_Credit_term_days__c=c1.Proposed_Credit_Term_Days;
            b.ASI_CRM_CN_Discount_Brand_T1__c=c1.Discount_Brand_T1_P;
           
            if (c1.Same_as_above_Brand_T1== null){                        
                 b.ASI_CRM_CN_Same_as_above_Brand_T1__c=false;
             }else{
                 b.ASI_CRM_CN_Same_as_above_Brand_T1__c=c1.Same_as_above_Brand_T1;
              }
            b.ASI_CRM_CN_Phone_Number_Brand_T1__c=c1.Phone_Number_Brand_T1;
            b.ASI_CRM_CN_Address_Brand_T1__c=c1.Address_Brand_T1;
          
            if (c1.Scan_Device_Application== null){                        
                 b.ASI_CRM_CN_Scan_Device_Application__c=false;
             }else{
                 b.ASI_CRM_CN_Scan_Device_Application__c=c1.Scan_Device_Application;
              }
            b.ASI_CRM_CN_Warehouse_Contact_person__c=c1.Warehouse_Contact_Person;
            b.ASI_CRM_CN_Warehouse_Tel__c=c1.Warehouse_Tel;
            b.ASI_CRM_CN_Covered_City__c=c1.Covered_City;
            b.ASI_CRM_CN_Warehouse_Address1__c=c1.Warehouse_Address1;
            b.ASI_CRM_CN_Warehouse_Address2__c=c1.Warehouse_Address2;
            b.ASI_CRM_CN_Warehouse_Email__c=c1.Warehouse_Email;
            
            //Leo@Elufa
            b.ASI_CRM_CN_Website__c = c1.website;
            b.ASI_CRM_CN_District__c = c1.district;
            b.ASI_CRM_CN_Post_Code__c = c1.postCode;
            if(c1.latitude != null && c1.longitude !=null)
            {
                b.ASI_CRM_CN_GPS_info__Latitude__s = c1.latitude;
                b.ASI_CRM_CN_GPS_info__Longitude__s = c1.longitude;
            }
            if(c1.newChannel!=null && c1.newChannel!='')
            	b.ASI_CRM_CN_NewChannel__c = c1.newChannel;
            else
                b.ASI_CRM_CN_NewChannel__c = null;
            if(c1.prosChannel!=null && c1.prosChannel!='')
            	b.ASI_CRM_CN_PROS_Segmentation__c = c1.prosChannel;
            else
                b.ASI_CRM_CN_PROS_Segmentation__c = null;
            b.ASI_CRM_SG_Outlet_Capacity__c = c1.outletCapacity;
            if(c1.vipCorner!=null)
            	b.ASI_CRM_CN_VIP_Corner__c = c1.vipCorner;
            b.ASI_CRM_CN_Size_sqm__c = c1.sizeSQM;
            b.ASI_CRM_CN_Rating__c = c1.rating;
            b.ASI_CRM_CN_PRC_Volume__c = c1.prcVolumn;
            b.ASI_CRM_CN_IS_Volume__c = c1.isVolumn;
            b.ASI_CRM_CN_Occupancy_Rate__c = c1.occupancyRate;
            if(c1.dedicatedService!=null)
            	b.ASI_CRM_CN_Dedicated_Service__c = c1.dedicatedService;
            b.ASI_CRM_CN_Popularity__c = c1.popularity;
            if(c1.careerBartender!=null)
            	b.ASI_CRM_CN_Career_Bartender__c = c1.careerBartender;
            b.ASI_CRM_CN_Cocktail_Price__c = c1.cocktailPrice;
            b.ASI_CRM_CN_OutletType__c = c1.outlettype;
            if(c1.backbar!=null)
            	b.ASI_CRM_CN_Back_Bar__c = c1.backbar;
            b.ASI_CRM_CN_Beer_Price__c = c1.beerPrice;
            b.ASI_CRM_CN_No_of_Room__c = c1.numRoom;
            if(c1.hostesses!=null)
            	b.ASI_CRM_CN_Hostesses__c = c1.hostesses;
            b.ASI_CRM_CN_Service_Tips_Price__c = c1.tipsPrice;
            b.ASI_CRM_CN_RTD_Volume__c = c1.rtdVolumn;
            if(c1.supermarket!=null)
            	b.ASI_CRM_CN_Supermarket__c = c1.supermarket;
            b.ASI_CRM_CN_Room_Price__c = c1.roomPrice;
            b.ASI_CRM_CN_12_Btl_Beer_Pack_Price__c = c1.x12BtBeerPrice;
            b.ASI_CRM_CN_Type_of_Restaurant__c = c1.typeRestaurant;
            b.ASI_CRM_CN_Spending_per_head__c = c1.spendPerHead;
            b.ASI_CRM_CN_Type_of_Cuisine__c = c1.typeCuisine;
            b.ASI_CRM_CN_Brand2__c = c1.brand;
            b.ASI_CRM_CN_Guest_room_price__c = c1.guestRoomPrice;
            b.ASI_CRM_CN_Outlet_Channel_type__c = c1.outletChannelType;
            b.ASI_CRM_CN_Number_of_Stars__c = c1.numOfStars;
            if(c1.kaAccountChain!=null && c1.kaAccountChain!='')
            	b.ASI_CRM_CN_KA_Account_Chain__c = c1.kaAccountChain;
            else
                b.ASI_CRM_CN_KA_Account_Chain__c = null;
            b.ASI_CRM_CN_Sofa_Table_Price__c = c1.sofaTablePrice;
            if(c1.vipPrivateRoom!=null)
            	b.ASI_CRM_CN_VIP_Private_Room__c = c1.vipPrivateRoom;
            b.ASI_CRM_CN_Channel_Strategy2__c = c1.channelStrategy;
            b.ASI_CRM_CN_Commercial_Team__c = c1.commercialTeam;
            b.ASI_CRM_CN_New_Image__c = c1.newImage;
            //Leo@Elufa
            
            a.add(b);
            
      }  
    upsert a;  
            
    return 'Success';
    }
        
    global with sharing class CustomerStructure{
        global string RecordType{set;get;} 
        global string RecordID{set;get;} 
        global string Local_Update_Time{set;get;} 
        global string Chi_Name{set;get;} 
        global string Eng_Name{set;get;} 
        global string Legal_Name{set;get;} 
        global string City{set;get;} 
        global Boolean Inactive_Flag{set;get;} 
        global string Parent_Outlet{set;get;} 
        global Boolean Dummy_Outlet_Flag{set;get;} 
        global string KA_Account{set;get;} 
        global Boolean IHBR_Outlet{set;get;} 
        global Boolean Require_Visit{set;get;} 
        global string Phone_Number{set;get;} 
        global string Fax_Number{set;get;} 
        global string Email{set;get;} 
        global string Contact_Person{set;get;} 
        global string Position{set;get;} 
        global string Tel{set;get;} 
        global string Address{set;get;} 
        global string Sub_Channel{set;get;} 
        global string Image{set;get;} 
        global Decimal CR12_Btl_per_month{set;get;} 
        global string Energy{set;get;} 
        global string PG_Head{set;get;} 
        global Boolean Cap_Collection{set;get;} 
        global string Address_CAP{set;get;} 
        global string Contact_Person_CAP{set;get;} 
        global Boolean Same_as_above_CAP{set;get;} 
        global string Tel_Cap{set;get;}
        global Decimal Frequency_CAP{set;get;} 
        global Boolean PRC_Direct_Sales_Flag{set;get;}
        global string Bank{set;get;} 
        global string Bank_Account{set;get;}
        global string Tax_Registration_Number{set;get;}
        global string Business_License_Expire_Date{set;get;} 
        global Boolean Group_Price_PR_Direct{set;get;}
        global Boolean Same_as_above_PR_Direct{set;get;}
        global string Phone_Number_PR_Direct{set;get;} 
        global Boolean VAT_Invoice_Application{set;get;}
        global Boolean VAT_Special_Invoice{set;get;} //20160608
        global Decimal Estimated_Annual_Order_Amount_in_CNY{set;get;}
        global Decimal Proposed_Credit_Term_Days{set;get;} 
        global Boolean Business_License_uploading_Y{set;get;} 
        global string Group_Name_PR_Direct{set;get;}
        global string Address_PR_Direct{set;get;} 
        global string T1_WS{set;get;} 
        global Decimal ON_CO_P{set;get;}
        global Decimal Chinese_Rest_P{set;get;} 
        global Decimal TOT_P{set;get;}
        global Decimal Bulkpurchase_P{set;get;}
        global Decimal LY_Operating_Income_RMB{set;get;} 
        global Decimal ON_NCO_P{set;get;}
        global Decimal Hotel_P{set;get;}
        global Decimal MOT_P{set;get;} 
        global Decimal T3_P{set;get;}
        global Decimal Credit_Terms_days{set;get;} 
        global Decimal IS_P{set;get;} 
        global Decimal Beer_P{set;get;} 
        global Decimal Other_Spirits_P{set;get;} 
        global Decimal Wine_P{set;get;} 
        global Decimal Baijiu_P{set;get;} 
        global Decimal Others_P{set;get;} 
        global string Brand_T1_Group{set;get;} 
        global string Effective_From{set;get;} 
        global string Effective_To{set;get;} 
        //global Decimal Proposed_Credit_Term_Days1{set;get;} 
        global Decimal Discount_Brand_T1_P{set;get;}
        global Boolean Same_as_above_Brand_T1{set;get;} 
        global string Phone_Number_Brand_T1{set;get;}   
        global string Address_Brand_T1{set;get;} 
        global Boolean Scan_Device_Application{set;get;} 
        global string Warehouse_Contact_Person{set;get;} 
        global string Warehouse_Tel{set;get;} 
        global string Covered_City{set;get;}
        global string Warehouse_Address1{set;get;} 
        global string Warehouse_Address2{set;get;} 
        global string Warehouse_Email{set;get;}
        //Leo@Elufa
        global string website{set;get;}
        global string district{set;get;}
        global Decimal postCode{set;get;}
        global Double latitude{set;get;}
        global Double longitude{set;get;}
        global string newChannel{set;get;}
        global string prosChannel{set;get;}
        global string outletCapacity{set;get;}
        global Boolean vipCorner{set;get;}
        global String sizeSQM{set;get;}
        global Decimal rating{set;get;}
        global Decimal prcVolumn{set;get;}
        global String isVolumn{set;get;}
        global String occupancyRate{set;get;}
        global Boolean dedicatedService{set;get;}
        global Decimal popularity{set;get;}
        global Boolean careerBartender{set;get;}
        global Decimal cocktailPrice{set;get;}
        global string outlettype{set;get;}
        global Boolean backbar{set;get;}
        global Decimal beerPrice{set;get;}
        global Decimal numRoom{set;get;}
        global Boolean hostesses{set;get;}
        global Decimal tipsPrice{set;get;}
        global String rtdVolumn{set;get;}
        global Boolean supermarket{set;get;}
        global Decimal roomPrice{set;get;}
        global Decimal x12BtBeerPrice{set;get;}
        global string typeRestaurant{set;get;}
        global Decimal spendPerHead{set;get;}
        global String typeCuisine{set;get;}
        global string brand{set;get;}
        global Decimal guestRoomPrice{set;get;}
        global String outletChannelType{set;get;}
        global String numOfStars{set;get;}
        global String kaAccountChain {set;get;}
        global Decimal sofaTablePrice {set;get;}
        global Boolean vipPrivateRoom {set;get;}
        global String channelStrategy {set;get;}
        global String commercialTeam {set;get;}
        global String newImage {set;get;}
        //Leo@Elufa
        
        public void replaceNull() {
            
            if(Parent_Outlet==null) Parent_Outlet= '';   
            if(PG_Head==null) PG_Head= ''; 
            if(T1_WS==null) T1_WS= ''; 
            if(City==null) City= ''; 
            if(Image==null) Image= ''; 
            if(Sub_Channel==null) Sub_Channel= ''; 
            if(Dummy_Outlet_Flag==null) Dummy_Outlet_Flag=null;
            if(Inactive_Flag==null) Inactive_Flag=null;
            if(IHBR_Outlet==null) IHBR_Outlet=null;
            if(Require_Visit==null) Require_Visit=null;
            if(Cap_Collection==null) Cap_Collection=null;
            if(Same_as_above_CAP==null) Same_as_above_CAP=null;
            if(PRC_Direct_Sales_Flag==null) PRC_Direct_Sales_Flag=null;
            if(Group_Price_PR_Direct==null) Group_Price_PR_Direct=null;
            if(Same_as_above_PR_Direct==null) Same_as_above_PR_Direct=null;
            if(VAT_Invoice_Application==null) VAT_Invoice_Application=null;
            if(Business_License_uploading_Y==null) Business_License_uploading_Y=null;
            if(Same_as_above_Brand_T1==null) Same_as_above_Brand_T1=null;
            if(Scan_Device_Application==null) Scan_Device_Application=null;
        }  
    }

 }