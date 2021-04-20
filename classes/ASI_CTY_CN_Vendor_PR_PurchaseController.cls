/*****************************************************************************************************************
* Name:        ASI_CTY_CN_Vendor_PR_PurchaseController       
* Test Class:  ASI_CTY_CN_Vendor_PR_PurchaseControllerTest
* Description: 
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    -----------------------------------------------------------------------------
* 2020-10-14       wangzhiqiang                  Create Class
*****************************************************************************************************************/
global without sharing class ASI_CTY_CN_Vendor_PR_PurchaseController {

public String username {get; set;}
public String userId {get; set;}
public boolean isEdit {get;set;}
public String periodInfosJson{get;set;}
public Id recordId {get; set;}
public String subBrandsJson {get; set;}
public boolean isNoowner {get;set;}



  global ASI_CTY_CN_Vendor_PR_PurchaseController(ApexPages.StandardController con) {

      recordId = con.getId();
      System.debug(LoggingLevel.INFO, '*** recordId: ' + recordId);
      isEdit = true;
      isNoowner = true;
      username = System.UserInfo.getLastName() +' '+ System.UserInfo.getFirstName();
      userId = System.UserInfo.getUserId();

      // Query purchase order products
      List<ASI_MFM_Purchase_Request_Line__c> lineList = [select (select Id,ASI_CTY_CN_Vendor_ContactName__c,ASI_CTY_CN_Vendor_ReceiptOwner__c,ASI_CTY_CN_Vendor_Receipt_Phone__c,ASI_CTY_CN_Vendor_Delivery_Address__c,ASI_CTY_CN_Vendor_Actual_Quantity__c,ASI_CTY_CN_Vendor_Note__c,ASI_CTY_CN_Vendor_Quantity_Required__c,ASI_CTY_CN_Vendor_Receipt_Owner__c,ASI_CTY_CN_Vendor_Warehouse__c,ASI_CTY_CN_Vendor_Outlet__r.Name,
      ASI_CTY_CN_Vendor_Outlet__c,ASI_CTY_CN_Vendor_Warehouse__r.Name from Address_RequestLine__r),
      Id,ASI_CTY_CN_Vendor_Buyer__c,ASI_CTY_CN_Vendor_Buyer__r.ASI_MFM_Buyer__r.Name,ASI_CTY_CN_Vendor_Bidding_Deadline__c,
      toLabel(ASI_CTY_CN_Vendor_Status__c),ASI_CTY_CN_Vendor_Total_Quantity__c,ASI_CTY_CN_Vendor_Item_Group_Code__c,
      ASI_CTY_CN_Vendor_Item_Group_Code__r.Name,ASI_CTY_CN_Vendor_Category__c,ASI_CTY_CN_Vendor_SubBrand__c,ASI_CTY_CN_Vendor_Sample_Required__c,ASI_CTY_CN_Vendor_IsAllowEdit__c,ASI_CTY_CN_Vendor_IsMerged__c from ASI_MFM_Purchase_Request_Line__c where ASI_MFM_Purchase_Request__c =:recordId];

      ASI_MFM_Purchase_Request__c request = [select ASI_CTY_CN_Vendor_Plan__c,OwnerId from ASI_MFM_Purchase_Request__c WHERE Id =:recordId];
      List<ASI_MFM_Plan_Line_Item__c> planeItems = [SELECT ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.Name  FROM ASI_MFM_Plan_Line_Item__c WHERE ASI_MFM_Plan__c =:request.ASI_CTY_CN_Vendor_Plan__c];
      List<SubBrand> subBrands = new List<SubBrand>();
      for(ASI_MFM_Plan_Line_Item__c plane :planeItems)
      {
        SubBrand sb = new SubBrand();
        sb.Id = plane.ASI_MFM_Sub_brand_Code__c;
        sb.Name = plane.ASI_MFM_Sub_brand_Code__r.Name;
        subBrands.add(sb);
      }
      subBrandsJson = JSON.serialize(subBrands);
      periodInfosJson = JSON.serialize(lineList);
      if(request.OwnerId == UserInfo.getUserId())
      {
        isNoowner = false;
      }
  }
  
 
  @RemoteAction
  global static Response savePurchase(String purchaseHeadJson,String periodInfosJson,String proAddressMapJson,String delProsJson,String delProAddressJson)
  {
    
    ASI_MFM_Purchase_Request__c request = [select Id,ASI_CTY_CN_Vendor_Responsible_by__c,ASI_CTY_CN_Vendor_Plan__c,OwnerId from ASI_MFM_Purchase_Request__c WHERE Id =:purchaseHeadJson];

    List<PeriodInfos> infoList =(List<PeriodInfos>)JSON.deserialize(periodInfosJson, List<PeriodInfos>.class);
    System.debug(LoggingLevel.INFO, '*** infoList: ' + infoList);
    
    List<AddressInfo> addressList =(List<AddressInfo>)JSON.deserialize(proAddressMapJson, List<AddressInfo>.class);
    System.debug(LoggingLevel.INFO, '*** addressList: ' + addressList);

    List<String> delPros = (List<String>)JSON.deserialize(delProsJson, List<String>.class);
    System.debug(LoggingLevel.INFO, '*** delPros: ' + delPros);
    List<String> delProAddrs = (List<String>)JSON.deserialize(delProAddressJson, List<String>.class);
    System.debug(LoggingLevel.INFO, '*** delProAddrs: ' + delProAddrs);

    List<ASI_MFM_Purchase_Request_Line__c> delPurLines = [SELECT Id FROM ASI_MFM_Purchase_Request_Line__c WHERE Id IN:delPros];
    List<ASI_CRM_Address__c> delAddrs1 = [SELECT Id FROM ASI_CRM_Address__c WHERE ASI_CTY_CN_Vendor_PurLine__c IN:delPros];
    List<ASI_CRM_Address__c> delAddrs2 = [SELECT Id FROM ASI_CRM_Address__c WHERE Id IN:delProAddrs];

    List<ASI_CRM_Quotation__c> quList = [SELECT Id FROM ASI_CRM_Quotation__c WHERE ASI_CTY_CN_Purchase_Request_Line__c IN:delPros];
    
    Set<Id> addrIds = new Set<Id>();
    if(delAddrs2.size()>0)
    {
      for(ASI_CRM_Address__c add:delAddrs2)
      {
       addrIds.add(add.Id);
      }
    }
    List<ASI_CRM_Quotation_Line_Item__c> lineItems = [SELECT Id FROM ASI_CRM_Quotation_Line_Item__c WHERE ASI_CTY_CN_Vendor_Address__c IN:addrIds];
    
    // Savepoint sp = null;
    //  try {           
    //         sp = Database.setSavepoint();
           
            if(!lineItems.isEmpty())
            {
              delete lineItems;
            }
            if(!quList.isEmpty())
            {
              delete quList;
            }
            if(!delAddrs2.isEmpty())
            {
              delete delAddrs2;
            }
            if(!delAddrs1.isEmpty())
            {
              delete delAddrs1;
              delete delPurLines;
            }

            // Save purchase line
            List<ASI_MFM_Purchase_Request_Line__c> lineList = new List<ASI_MFM_Purchase_Request_Line__c>();
            for(PeriodInfos inf:infoList)
            {
               ASI_MFM_Purchase_Request_Line__c line = new ASI_MFM_Purchase_Request_Line__c();
               line.ASI_CTY_CN_Vendor_Buyer__c = inf.itembuyId;
               line.ASI_CTY_CN_Vendor_Bidding_Deadline__c = Date.valueOf(inf.deadlineTime);
               if(String.isEmpty(inf.purLineId))
               {
                 line.ASI_CTY_CN_Vendor_Status__c = 'Draft';
               }
               line.ASI_CTY_CN_Vendor_Total_Quantity__c = inf.totalQty;
               line.ASI_CTY_CN_Vendor_Item_Group_Code__c = inf.itemProductId;
               line.ASI_CTY_CN_Vendor_Sample_Required__c = inf.sampleRequired;
               line.ASI_CTY_CN_Vendor_proId__c = inf.proId;
               line.ASI_MFM_Purchase_Request__c = request.Id;
               line.ASI_CTY_CN_Vendor_SubBrand__c = inf.selsubBrand;
               line.Id = inf.purLineId;
               line.ASI_CTY_CN_Vendor_Approval_MKT__c = request.ASI_CTY_CN_Vendor_Responsible_by__c;

               line.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_CN_Vendor_Purchase_Request_Line');
               lineList.add(line);
            }
            Map<String,String> proIdMap = new  Map<String,String>();
            if(lineList.size()>0)
            {
                upsert lineList;
                for(ASI_MFM_Purchase_Request_Line__c l:lineList)
                {
                   proIdMap.put(l.ASI_CTY_CN_Vendor_proId__c, l.Id);
                }
            }

            // Save AddressInfo
            List<ASI_CRM_Address__c> asiAddList = new List<ASI_CRM_Address__c>();

            List<ASI_CRM_Address__c> newAddressList = new List<ASI_CRM_Address__c>();
            for(AddressInfo addr:addressList)
            {
               ASI_CRM_Address__c  address = new ASI_CRM_Address__c();
               address.ASI_CTY_CN_Vendor_PurLine__c = proIdMap.get(addr.proId);
               address.ASI_CTY_CN_Vendor_Note__c = addr.note;
               address.ASI_CTY_CN_Vendor_Quantity_Required__c = addr.quantity;
               address.ASI_CTY_CN_Vendor_Receipt_Owner__c = addr.receiptOwner;
               address.ASI_CTY_CN_Vendor_Receipt_Phone__c = addr.receiptOwnerPhone;
               address.ASI_CTY_CN_Vendor_Delivery_Address__c = addr.address;
               address.ASI_CTY_CN_Vendor_ContactName__c = addr.contactName;
               address.Id = addr.addressId;
               address.ASI_CTY_CN_Vendor_ReceiptOwner__c = addr.receiptOwnerId;
              // address.ASI_CTY_CN_Vendor_Contact__c = '';
               if(!String.isEmpty(addr.qutlet))
               {
                  address.ASI_CTY_CN_Vendor_Outlet__c = addr.qutlet;
               }
               if(!String.isEmpty(addr.warehousecode))
               {
                  address.ASI_CTY_CN_Vendor_Warehouse__c = addr.warehousecode;
               }
               System.debug(LoggingLevel.INFO, '*** addr.addressId: ' + addr.addressId);
               if(addr.addressId == '' || addr.addressId== null)
               {
                newAddressList.add(address);
               }
               address.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Address__cASI_CTY_CN_Purchase_Request_Delivery_Address');
               asiAddList.add(address);
            }

            if(asiAddList.size()>0)
            {
              upsert asiAddList;
            }

            gengerQuotationLine(newAddressList);

            Response res = new Response();
            res.flag = 'success';
            res.objId = Id.valueOf(purchaseHeadJson);
            return res;
    //   }
    //   catch (Exception e){
    //     if(sp!=null)Database.rollback(sp);
    //   }
    // return null;
  }

  public  static void gengerQuotationLine(List<ASI_CRM_Address__c> newAddressList)
  {
    System.debug(LoggingLevel.INFO, '*** newAddressList: ' + newAddressList);
     Set<Id> prlineIds = new Set<Id>();
     for(ASI_CRM_Address__c ress :newAddressList)
     {
        prlineIds.add(ress.ASI_CTY_CN_Vendor_PurLine__c);
     }

     List<ASI_CRM_Quotation__c> quList = [SELECT Id,ASI_CTY_CN_Purchase_Request_Line__c FROM ASI_CRM_Quotation__c WHERE ASI_CTY_CN_Purchase_Request_Line__c IN:prlineIds];
     Map<String,ASI_CRM_Quotation__c> quoMaps = new Map<String,ASI_CRM_Quotation__c>();
     for(ASI_CRM_Quotation__c quo :quList)
     {
       String key = quo.Id + '_' + quo.ASI_CTY_CN_Purchase_Request_Line__c;
       quoMaps.put(key, quo);
     }

     System.debug(LoggingLevel.INFO, '*** quoMaps: ' + quoMaps);

     List<ASI_CRM_Quotation_Line_Item__c> lineItems = new List<ASI_CRM_Quotation_Line_Item__c>();
     for(ASI_CRM_Address__c ress :newAddressList)
     {
        for(String k : quoMaps.keySet())
        {
           Id purId = ress.ASI_CTY_CN_Vendor_PurLine__c;
           System.debug(LoggingLevel.INFO, '*** k: ' + k);
           System.debug(LoggingLevel.INFO, '*** ress.ASI_CTY_CN_Vendor_PurLine__c: ' + ress.ASI_CTY_CN_Vendor_PurLine__c);
           if(K.contains(String.valueOf(purId)))
           {
               ASI_CRM_Quotation__c q = quoMaps.get(k);
               ASI_CRM_Quotation_Line_Item__c lineItem = new ASI_CRM_Quotation_Line_Item__c();
               lineItem.ASI_CTY_CN_Vendor_Quotation__c = q.Id;
               lineItem.ASI_CTY_CN_Vendor_Address__c = ress.Id;
               lineItems.add(lineItem);
           }
        }
     }

     System.debug(LoggingLevel.INFO, '*** lineItems: ' + lineItems);

     if(lineItems.size()>0)
     {
        insert lineItems;
     }

  }

  

  @RemoteAction
  global static List<Map<String,String>> ajaxSearchProduct(String queryStr){
      List<Map<String,String>> Personlist=new List<Map<String,String>>();
      queryStr = '%'+queryStr+'%';
      List<ASI_MFM_Item_Group__c> itemGroup = [select Id,Name,ASI_MFM_Sub_brand__c,ASI_MFM_Category_Level_1__c,ASI_MFM_Category_Level_1__r.Name,ASI_MFM_Category_Level_1__r.ASI_MFM_Buyer__c,ASI_MFM_Category_Level_1__r.ASI_MFM_Buyer__r.Name,ASI_MFM_Category_Level_1__r.ASI_MFM_Buyer__r.ASI_MFM_Buyer__r.Name 
      from ASI_MFM_Item_Group__c where Name like:queryStr AND RecordType.Name='CN POSM Item Group' limit 100];
      for(ASI_MFM_Item_Group__c item :itemGroup)
      {
          Map<String,String> addMap = new Map<String,String>();
          addMap.put('Id', item.Id);
          addMap.put('Name',item.Name);
          addMap.put('cateId',item.ASI_MFM_Category_Level_1__c);
          addMap.put('cateName',item.ASI_MFM_Category_Level_1__r.Name);
          addMap.put('buyerId',item.ASI_MFM_Category_Level_1__r.ASI_MFM_Buyer__c);
          addMap.put('buyerName',item.ASI_MFM_Category_Level_1__r.ASI_MFM_Buyer__r.ASI_MFM_Buyer__r.Name);
          addMap.put('subBrand', item.ASI_MFM_Sub_brand__c);
          Personlist.add(addMap);
      }

      if(itemGroup.size()==0)
      {
          Map<String,String> addMap = new Map<String,String>();
          addMap.put('Id', '');
          addMap.put('Name','No Find Results');
          Personlist.add(addMap);
      }
      return Personlist;
      
  }


   @RemoteAction
   global static List<Map<String,String>> ajaxSearchWarehouse(String queryStr,String queryType){
      List<Map<String,String>> Personlist=new List<Map<String,String>>();
      queryStr = '%'+queryStr+'%';
      if(queryType.equals('WareHouse'))
      {
          List<ASI_FOC_Warehouse__c> itemGroup = [select Id,Name,ASI_FOC_Warehouse_Address__c,ASI_FOC_Phone_Number__c,ASI_FOC_Contact__c from ASI_FOC_Warehouse__c where (Name like:queryStr OR ASI_FOC_Warehouse_Code__c like:queryStr) AND RecordType.Name ='CN Warehouse' AND ASI_MFM_Is_Active__c = true limit 10];
          for(ASI_FOC_Warehouse__c item :itemGroup)
          {
              Map<String,String> addMap = new Map<String,String>();
              addMap.put('Id', item.Id);
              addMap.put('Name',item.Name);
              addMap.put('ASI_FOC_Full_Address__c', item.ASI_FOC_Warehouse_Address__c);
              addMap.put('ASI_FOC_Phone_Number__c', item.ASI_FOC_Phone_Number__c);
              addMap.put('ASI_FOC_Contact__c', item.ASI_FOC_Contact__c);
              Personlist.add(addMap);
          }
          
      }
      else
      {

        List<ASI_CRM_AccountsAdditionalField__c> outList = [select Id,Name,ASI_CRM_CN_CRM_Code__c,ASI_CRM_CN_Contact_Person__c,ASI_CRM_CN_Address__c,ASI_CRM_CN_Phone_Number__c from ASI_CRM_AccountsAdditionalField__c  where RecordType.Name ='Outlet (CN)' 
                                                            AND ASI_CRM_CN_Inactive_Flag__c = false 
                                                            AND ASI_CRM_CN_Competitor_Outlet__c=false
                                                            AND ASI_CRM_CN_Dummy_Outlet_Flag__c=false
                                                            AND (ASI_CRM_CN_JDE_Code__c!='' or ASI_CRM_CN_JDE_Code_Premium__c!='' or ASI_CRM_CN_JDE_Code_RTD__c!='')
                                                            AND (Name like:queryStr OR ASI_CRM_CN_CRM_Code__c like:queryStr) limit 10];
        for(ASI_CRM_AccountsAdditionalField__c out :outList)
        {
            Map<String,String> addMap1 = new Map<String,String>();
            addMap1.put('Id', out.Id);
            addMap1.put('Name',out.Name);
            addMap1.put('ASI_FOC_Full_Address__c', out.ASI_CRM_CN_Address__c);
            addMap1.put('ASI_FOC_Phone_Number__c', out.ASI_CRM_CN_Phone_Number__c);
            addMap1.put('ASI_FOC_Contact__c', out.ASI_CRM_CN_Contact_Person__c);
            Personlist.add(addMap1);
        }
      }
      if(Personlist.size()==0)
      {
        Map<String,String> addMap2 = new Map<String,String>();
        addMap2.put('Id', '');
        addMap2.put('Name','No Find Results');
        Personlist.add(addMap2);
      }
     
      return Personlist;
  }


   @RemoteAction
   global static List<Map<String,String>> ajaxSearchUser(String queryStr){
      List<Map<String,String>> Personlist=new List<Map<String,String>>();
      queryStr = '%'+queryStr+'%';
     
          List<User> users = [select Id,Name,Email from User where IsActive = true AND Name like:queryStr AND License_Type__c <>'Customer Community' limit 10];
          for(User item :users)
          {
              Map<String,String> addMap = new Map<String,String>();
              addMap.put('Id', item.Id);
              addMap.put('Name',item.Name);
              addMap.put('Email',item.Email);
             
              Personlist.add(addMap);
          }
          
      
      if(Personlist.size()==0)
      {
        Map<String,String> addMap2 = new Map<String,String>();
        addMap2.put('Id', '');
        addMap2.put('Name','No Find Results');
        addMap2.put('Email','');
        Personlist.add(addMap2);
      }
     
      return Personlist;
  }

  @RemoteAction
  global static List<AddressInfo> getAddressInfos(String addressJson)
  {
     System.debug(LoggingLevel.INFO, '*** addressJson: ' + addressJson);
     List<AddressInfo>  addList = (List<AddressInfo>)JSON.deserialize(addressJson, List<AddressInfo>.class);
     System.debug(LoggingLevel.INFO, '*** addList: ' + addList);
     List<AddressInfo>  addressList = new  List<AddressInfo>();
     Map<String,AddressInfo> warehousecodeMap = new Map<String,AddressInfo>();
     Map<String,AddressInfo> recOwnerMap = new Map<String,AddressInfo>();
     Map<String,AddressInfo> outletcodeMap = new Map<String,AddressInfo>();
     Set<String>  warehousecodes= new Set<String>();
     Set<String>  outletcodes= new Set<String>();
     User crruser = [select Id,Name from User where Id =: UserInfo.getUserId()];
     for(AddressInfo addr:addList)
     {
        if(!String.isEmpty(addr.warehousecode))
        {
           String key = addr.warehousecode +'_@_'+ addr.receiptOwner;
           warehousecodeMap.put(key,addr);
           warehousecodes.add(addr.warehousecode);
          
        }
        if(!String.isEmpty(addr.qutlet))
        {
           String key1 = addr.qutlet +'_@_'+ addr.receiptOwner;
           outletcodeMap.put(key1,addr);
           outletcodes.add(addr.qutlet);
        }
        recOwnerMap.put(addr.receiptOwner, addr);
     }
     List<ASI_FOC_Warehouse__c> wareList = [SELECT Id,Name,ASI_FOC_Warehouse_Code__c,ASI_FOC_Warehouse_Address__c,ASI_FOC_Phone_Number__c,ASI_FOC_Contact__c FROM ASI_FOC_Warehouse__c  WHERE 
     RecordType.Name ='CN Warehouse' AND ASI_FOC_Warehouse_Code__c IN:warehousecodes];
     Map<String,ASI_FOC_Warehouse__c> exwareCodeMap = new Map<String,ASI_FOC_Warehouse__c>();
     for(ASI_FOC_Warehouse__c war:wareList)
     {
        exwareCodeMap.put(war.ASI_FOC_Warehouse_Code__c,war);
     }

     List<User> userList = [SELECT Id,Name,Email FROM User WHERE Email IN:recOwnerMap.keySet() AND IsActive = true];
     Map<String,User> exuserMap = new Map<String,User>();
     for(User u:userList)
     {
        exuserMap.put(u.Email,u);
     }
     System.debug(LoggingLevel.INFO, '*** exuserMap: ' + exuserMap);
     for(String w:warehousecodeMap.keySet())
     {
        AddressInfo address = warehousecodeMap.get(w);
        Integer num = w.indexOf('_@_');
        w = w.substring(0,num);
        if(exwareCodeMap.containsKey(w))
        {
          ASI_FOC_Warehouse__c wa = (ASI_FOC_Warehouse__c)exwareCodeMap.get(w);
          if(exuserMap.containsKey(address.receiptOwner) || String.isEmpty(address.receiptOwner))
          {

             if(String.isEmpty(address.receiptOwner))
             {
               address.receiptOwner = crruser.Name;
               address.receiptOwnerId = crruser.Id;
             }
             else
             {
                User us = exuserMap.get(address.receiptOwner);
                address.receiptOwner = us.Name;
                address.receiptOwnerId = us.Id;
             }
            
             address.results = true;
             address.address = wa.ASI_FOC_Warehouse_Address__c;
             if(String.isEmpty(address.receiptOwnerPhone))
             {
                address.receiptOwnerPhone = wa.ASI_FOC_Phone_Number__c;
             }
             if(String.isEmpty(address.contactName))
             {
                address.contactName = wa.ASI_FOC_Contact__c;
             }
             address.warehousecode = wa.Name;
             if(null == wa.ASI_FOC_Warehouse_Address__c)
             {
                address.results = false;
                address.reason = 'The address information of warehouse is empty， please add it after maintenance!';
             }
            if(String.isEmpty(address.receiptOwnerPhone))
             {
                address.results = false;
                address.reason = 'Contact number cannot be empty， please add after maintenance!';
             }
          }
          else
          {
               address.results = false;
               address.reason = 'The receive owner does not exist in the system!';
          }
          address.warehouseId = wa.Id;
        }
        else
        {
           address.results = false;
           address.reason = 'Warehouse (code) does not exist in the system!';
        }
        addressList.add(address);
     }
      System.debug(LoggingLevel.INFO, '*** addressList: ' + addressList);
      
     List<ASI_CRM_AccountsAdditionalField__c> outList = [select Id,ASI_CRM_CN_Contact_Person__c,ASI_CRM_CN_Address__c,ASI_CRM_CN_Phone_Number__c,Name,ASI_CRM_CN_CRM_Code__c from ASI_CRM_AccountsAdditionalField__c  where RecordType.Name ='Outlet (CN)'
      AND ASI_CRM_CN_CRM_Code__c IN:outletcodes];
     Map<String,ASI_CRM_AccountsAdditionalField__c> exoutCodeMap = new Map<String,ASI_CRM_AccountsAdditionalField__c>();
     for(ASI_CRM_AccountsAdditionalField__c out:outList)
     {
        exoutCodeMap.put(out.ASI_CRM_CN_CRM_Code__c,out);
     }

     for(String o:outletcodeMap.keySet())
     {
        AddressInfo address1 = outletcodeMap.get(o);
        Integer num = o.indexOf('_@_');
        o = o.substring(0,num);
        if(exoutCodeMap.containsKey(o))
        {   
          if(exuserMap.containsKey(address1.receiptOwner) || String.isEmpty(address1.receiptOwner))
          {
            ASI_CRM_AccountsAdditionalField__c acc = exoutCodeMap.get(o);
            address1.results = true;
            address1.qoutletId = acc.Id;
            address1.qutlet = acc.Name;
            address1.address = acc.ASI_CRM_CN_Address__c;
             if(String.isEmpty(address1.receiptOwner))
            {
              address1.receiptOwner = crruser.Name;
              address1.receiptOwnerId = crruser.Id;
            }
            else
            {
               User us1 = exuserMap.get(address1.receiptOwner);
               address1.receiptOwner = us1.Name;
               address1.receiptOwnerId = us1.Id;
            }
            //address1.receiptOwner = acc.ASI_CRM_CN_Contact_Person__c;
            if(String.isEmpty(address1.receiptOwnerPhone))
            {
              address1.receiptOwnerPhone = acc.ASI_CRM_CN_Phone_Number__c;
            }
            if(String.isEmpty(address1.contactName))
            {
                address1.contactName = acc.ASI_CRM_CN_Contact_Person__c;
            }
            if(null == acc.ASI_CRM_CN_Address__c)
            {
              address1.results = false;
              address1.reason = 'The address information of outlet is empty. Please maintain it and add it again!';
            }
            if(String.isEmpty(address1.receiptOwnerPhone))
            {
              address1.results = false;
              address1.reason = 'Contact number cannot be empty，please add after maintenance!';
            }
          }
          else
          {
               address1.results = false;
               address1.reason = 'The receive owner does not exist in the system!';
          }
        }
        else
        {
           address1.results = false;
           address1.reason = 'Outlet (code) does not exist in the system!';
        }
        addressList.add(address1);
     }

     System.debug(LoggingLevel.INFO, '*** addressList: ' + addressList);

     return sortList(addressList);
  }

  public static List<AddressInfo> sortList(List<AddressInfo> dateList)
  {
    Map<Integer,AddressInfo> addMap = new Map<Integer,AddressInfo>();
    List<AddressInfo>  sortList = new  List<AddressInfo>();
    List<Integer> lineNOs = new List<Integer>();
    for(AddressInfo ar:dateList)
    {
      addMap.put(ar.lineNo, ar);
      lineNOs.add(ar.lineNo);
    }
    lineNOs.sort();
    for(Integer i:lineNOs)
    {
      sortList.add(addMap.get(i));
    }
    System.debug(LoggingLevel.INFO, '*** lineNOs: ' + lineNOs);
    return sortList;

  }
  

  global class PurchaseHead
  {
    public String enqulryName;
    public String subChannel;
    public String bu;
    public String planId;
    public String poCategory;
  }

  global class SubBrand
  {
    public String Name;
    public String Id;
  }

  global class PeriodInfos
  {
    public String deadlineTime;
    public String itemProductId;
    public String itembuyName;
    public String itemProductName;
    public String itembuyId;
    public boolean sampleRequired;
    public String status;
    public Decimal totalQty;
    public String proId;
    public String exproId;
    public boolean isEdit;
    public String  purLineId;
    public String selsubBrand;

  }

  global class AddressInfo
  {
    public String address;
    public String note;
    public String proId;
    public Decimal quantity;
    public String receiptOwner;
    public String receiptOwnerId;
    public String addressId;
    public String warehousecode;
    public String warehouseId;
    public String qutlet;
    public String receiptOwnerPhone;
    public Integer lineNo;
    public boolean results;
    public String  reason;
    public boolean isEdit;
    public String qoutletId;
    public String contactName;
  }

  global class Response
  {
    public String flag;
    public String objId;

  }
}