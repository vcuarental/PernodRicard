/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_MassOwnerTransferController
 * Description:  class for ASI_CRM_VN_MassOwnerTransfer VF page
 * Test class : ASI_CRM_VN_MassOwnerTransferTest
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-12       Jeffrey Cheung          Created
 * 2018-11-27       Andy Zhang              Add new segment type and new image level
 * 2018-12-10		Calvin Chiu				Default outlet type and subtype if segment type is value
 * 2018-12-20		Calvin Chiu				Updated area-province-district to dependent picklist
 * 2020-11-11       PRA  CoE               [COE1.0] Remove the limit size to 500
 ****************************************************************************************************************************/

public without sharing class ASI_CRM_VN_MassOwnerTransferController {
    public final Map<String, Set<String>> AREA_TO_PROVINCE_MAP = new Map<String, Set<String>>{'Southeast'=> new Set<String>{'Vung Tau','Binh Duong','Binh Phuoc','Dong Nai','Tay Ninh'},
    'Mekong Delta'=> new Set<String>{'An Giang','Bac Lieu','Ben Tre','Ca Mau','Can Tho','Dong Thap','Hau Giang','Kien Giang','Long An','Soc Trang','Tien Giang','Vinh Long'},
    'Northern Provinces'=> new Set<String>{'Bac Kan','Bac Giang','Bac Ninh','Cao Bang','Dien Bien','Ha Giang','Ha Nam','Ha Tay','Ha Tinh','Hai Duong','Hai Phong',
            'Hoa Binh','Hung Yen','Lai Chau','Lao Cai','Lang Son','Nam Dinh','Nghe An','Ninh Binh','Phu Tho','Quang Ninh','Son La',
            'Thai Binh','Thai Nguyen','Thanh Hoa','Tra Vinh','Tuyen Quang','Vinh Phuc','Yen Bai'},
    'Nha Trang'=> new Set<String>{'Binh Dinh','Binh Thuan','Khanh Hoa','Ninh Thuan','Phu Yen'},
    'Da Nang'=> new Set<String>{'Da Nang','Quang Binh','Quang Nam','Quang Ngai','Quang Tri','Hue'},
    'Central Highlands'=> new Set<String>{'Dak Lak','Dak Nong','Gia Lai','Kon Tum','Lam Dong'},
    'Hanoi'=> new Set<String>{'Hanoi'},
    'HCMC'=> new Set<String>{'Ho Chi Minh'}
    };

    public final Map<String, Set<String>> PROVINCE_TO_DISTRICT_MAP = new Map<String, Set<String>>{'Ho Chi Minh'=> new Set<String>{'Thủ Đức','Quan 1','Quan 2','Quan 3','Quan 4','Quan 5','Quan 6','Quan 7','Quan 8','Quan 9','Quan 10','Quan 11','Quan 12','Thu Duc',
            'Tan Phu','Tan Binh','Phu Nhuan','Go Vap','Binh Thanh','Binh Tan','Binh Chanh','Can Gio','Cu Chi','Hoc Mon','Nha Be'},
    'Hanoi'=> new Set<String>{'Ba Dinh','Hoan Kiem','Tay Ho','Long Bien','Cau Giay','Dong Da','Hai Ba Trung','Hoang Mai','Thanh Xuan','Ha Dong','Bac Tu Liem','Nam Tu Liem',
            'Son Tay','Ba Vi','Chuong My','Dan Phuong','Dong Anh','Gia Lam','Hoai Duc','Me Linh','My Duc','Phu Xuyen','Phuc Tho','Quoc Oai','Soc Son',
            'Thach That','Thanh Oai','Thanh Tri','Thuong Tin','Ung Hoa'},
    'Da Nang'=> new Set<String>{'Hai Chau','Cam Le','Thanh Khe','Lien Chieu','Ngu Hanh Son','Son Tra','Hoa Vang','Hoang Sa'},
    'Hai Phong'=> new Set<String>{'Duong Kinh','Do Son','Hai An','Kien An','Hong Bang','Ngo Quyen','Le Chan','An Duong','An Lao','Bach Long Vi','Cat Hai','Kien Thuy',
            'Tien Lang','Vinh Bao','Thuy Nguyen'},
    'Can Tho'=> new Set<String>{'Ninh Kieu','Binh Thuy','Cai Rang','O Mon','Thot Not','Phong Dien','Co Do','Thoi Lai','Vinh Thanh'}
    };

    public String selectedOutletType { get; set; }
    public String selectedOutletSubType { get; set; }

    public String selectedPROSImage { get; set; }
    public String selectedOutletOwner { get; set; }
    public String selectedArea { get; set; }
    public String selectedProvince { get; set; }
    public String selectedDistrict { get; set; }
    public List<SelectOption> provinceList {get;set;}
    public List<SelectOption> districtList {get;set;}

    public String filteredOutletsJSON { get; set; }
    public String segmentType {get;set;}
    public String companyCode { get;set;}

    public ASI_CRM_VN_MassOwnerTransferController() {
        companyCode = [Select ASI_Company_Code__c from User where Id = :UserInfo.getUserId()].ASI_Company_Code__c;
        if (companyCode == '780') {
            segmentType = 'Value';
            selectedOutletType = 'RES';
            selectedOutletSubType = 'Casual Dining';
        } else if (companyCode == '778') {
            segmentType = 'Premium';
        }
    }

    public List<SelectOption> getOutletTypes() {
        return getSelectOptions('ASI_CRM_AccountsAdditionalField__c', 'ASI_CRM_VN_OutletType__c');
    }
    public List<SelectOption> getOutletSubtypes() {
        return getSelectOptions('ASI_CRM_AccountsAdditionalField__c', 'ASI_CRM_Outlet_Sub_Type__c');
    }
    public List<SelectOption> getPROSImages() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select --'));
        if (companyCode == '780') {
            options.add(new selectOption('Platinum', 'Platinum'));
            options.add(new selectOption('Gold', 'Gold'));
            options.add(new selectOption('Silver', 'Silver'));
            options.add(new selectOption('Bronze', 'Bronze'));
        } else if (companyCode == '778') {
            options.add(new selectOption('Iconic', 'Iconic'));
            options.add(new selectOption('Leading', 'Leading'));
            options.add(new selectOption('Premium', 'Premium'));
            options.add(new selectOption('Mainstream', 'Mainstream'));
        }
        return options;
    }

    public List<SelectOption> getOutletOwners() {
        Id currentUserId = UserInfo.getUserId();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select --'));
        if (companyCode == '780') {
            List<User> users = [SELECT Id, Name FROM User WHERE Profile.Name = 'ASI VN Standard User' AND ASI_Company_Code__c='780' AND managerId = :currentUserId ORDER BY Name];
            for (User user : users) {
                options.add(new SelectOption(user.Id, user.Name));
            }
            system.debug(users);
        }
        else if(companyCode == '778'){
            List<User> users = [SELECT Id, Name FROM User WHERE Profile.Name = 'ASI VN Standard User' AND ASI_Company_Code__c='778' AND managerId = :currentUserId ORDER BY Name];
            for (User user : users) {
                options.add(new SelectOption(user.Id, user.Name));
            }

        }
        return options;

    }

    public List<SelectOption> getAreas() {
        return getSelectOptions('ASI_CRM_AccountsAdditionalField__c', 'ASI_CRM_Area__c');
    }
    public PageReference getProvinces() {
        provinceList = getSelectOptions('ASI_CRM_AccountsAdditionalField__c', 'ASI_CRM_VN_Province__c', AREA_TO_PROVINCE_MAP.get(selectedArea));
        districtList = new List<SelectOption>{new SelectOption('', '-- Select --')};
        selectedDistrict = null;
        selectedProvince = null;
        return null;
    }
    public PageReference getDistricts() {
        districtList = getSelectOptions('ASI_CRM_AccountsAdditionalField__c', 'ASI_CRM_VN_Quan__c', PROVINCE_TO_DISTRICT_MAP.get(selectedProvince));
        return null;
    }
    public List<SelectOption> getNewOutletOwners() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select --'));

        List<User> users = [SELECT Id, Name FROM User WHERE Profile.Name = 'ASI VN Standard User' AND ASI_Company_Code__c=:companyCode ORDER BY Name];
        for (User user : users) {
            options.add(new SelectOption(user.Id, user.Name));
        }
        return options;
    }


    public List<SelectOption> getSelectOptions(String objectName, String fieldName) {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select --'));
        //        Copy from https://th3silverlining.com/2012/02/01/salesforce-dynamically-determining-the-field-type-of-a-dynamically-determined-sobject/
        Schema.SObjectType t = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = t.getDescribe();
        Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = f.getPicklistValues();

        for (Schema.PicklistEntry picklistEntry : ple) {
            options.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
        }
        options.sort();
        return options;
    }

    // used for dependent picklist
    public List<SelectOption> getSelectOptions(String objectName, String fieldName, Set<String> dependencySet) {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select --'));
        //        Copy from https://th3silverlining.com/2012/02/01/salesforce-dynamically-determining-the-field-type-of-a-dynamically-determined-sobject/
        Schema.SObjectType t = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = t.getDescribe();
        Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = f.getPicklistValues();

        for (Schema.PicklistEntry picklistEntry : ple) {
            if(dependencySet != null && dependencySet.contains(picklistEntry.getValue())){
                options.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
            }
        }
        options.sort();
        return options;
    }

    public void searchOutlet() {
        List<String> recordTypes = NEW List<String>();
        if(companyCode =='780'){
            recordTypes = new List<String>{
                    'ASI_CRM_VN_Value_Off_Trade_Outlet', 'ASI_CRM_VN_Value_Off_Trade_Outlet_Inactive', 'ASI_CRM_VN_Value_On_Trade_Outlet', 'ASI_CRM_VN_Value_On_Trade_Outlet_Inactive'
            };
        }
        else if(companyCode =='778') {
            recordTypes = new List<String>{
                    'ASI_CRM_VN_Outlet', 'ASI_CRM_VN_Outlet_Inactive', 'ASI_CRM_VN_Off_Trade_Outlet', 'ASI_CRM_VN_Inactive_Off_Trade_Outlet'
            };
        }
        Id ownerId = UserInfo.getUserId();
        Set<Id> ownerIdSet = new Set<Id>();
        ownerIdSet.add(ownerId);
        for(User u : [SELECT Id FROM User WHERE ManagerId = :ownerId]) {
            ownerIdSet.add(u.Id);
        }

        String query = 'SELECT ' +
                'Id, Name, ASI_CRM_CustomerCode__c, ASI_CRM_VN_Region__c, ASI_CRM_Area__c, ASI_CRM_VN_Province__c, ASI_CRM_VN_OutletType__c, ASI_CRM_VN_Is_Locked__c, ASI_CRM_VN_Quan__c, RecordType.Name, Owner.Name ' +
                'FROM ASI_CRM_AccountsAdditionalField__c ' +
                'WHERE RecordType.DeveloperName IN :recordTypes ' +
                'AND OwnerId in :ownerIdSet ';

        if (String.isNotEmpty(selectedOutletType)) {
            query += 'AND ASI_CRM_VN_OutletType__c = :selectedOutletType ';
        }
        if (String.isNotEmpty(selectedOutletSubType)) {
            query += 'AND ASI_CRM_Outlet_Sub_Type__c = :selectedOutletSubType ';
        }
        if (String.isNotEmpty(selectedPROSImage)) {
            query += 'AND ASI_CRM_Check_Image__c = :selectedPROSImage ';
        }
        if (String.isNotEmpty(selectedOutletOwner)) {
            query += 'AND OwnerId = :selectedOutletOwner ';
        }
        if (String.isNotEmpty(selectedArea)) {
            query += 'AND ASI_CRM_Area__c = :selectedArea ';
        }
        if (String.isNotEmpty(selectedProvince)) {
            query += 'AND ASI_CRM_VN_Province__c = :selectedProvince ';
        }
        if (String.isNotEmpty(selectedDistrict)) {
            query += 'AND ASI_CRM_VN_Quan__c = :selectedDistrict ';
        }
        // [COE1.0]
        query += ' '; // LIMIT 500 

        List<ASI_CRM_AccountsAdditionalField__c> outlets = Database.query(query);
        this.filteredOutletsJSON = JSON.serialize(outlets);
    }

    public void resetFilter() {
        selectedOutletType = '';
        selectedOutletSubType = '';
        selectedPROSImage = '';
        selectedOutletOwner = '';
        selectedArea = '';
        selectedProvince = '';
        selectedDistrict = '';
    }

    @RemoteAction
    public static String changeOwner(Id newOwnerId, String selectedOutlets) {

        List<ASI_CRM_AccountsAdditionalField__c> selectedOutletsList = (List<ASI_CRM_AccountsAdditionalField__c>) JSON.deserialize(selectedOutlets, List<ASI_CRM_AccountsAdditionalField__c>.class);
        List<ASI_CRM_AccountsAdditionalField__c> childOutletList = new List<ASI_CRM_AccountsAdditionalField__c>();

        Set<Id> selectedOutletIds = ASI_CRM_VN_Util_Pluck.ids(selectedOutletsList);

        //        change outlet owner
        ASI_CRM_VN_OutletHierarchy cls = new ASI_CRM_VN_OutletHierarchy(selectedOutletsList);
        for (ASI_CRM_AccountsAdditionalField__c outlet : selectedOutletsList) {
            outlet.OwnerId = newOwnerId;
            //          update  child outlets
            for (ASI_CRM_AccountsAdditionalField__c childOutlet : cls.getAllOutlet(outlet.Id)) {
                childOutlet.OwnerId = newOwnerId;
                childOutletList.add(childOutlet);
            }

        }


        //        change contract owner
        List<ASI_CRM_VN_Contract__c> contracts = [SELECT Id, Name, OwnerId, ASI_CRM_Contract_Status__c, ASI_CRM_Outlet_WS__r.Name FROM ASI_CRM_VN_Contract__c WHERE ASI_CRM_Outlet_WS__c IN :selectedOutletIds];
        for (ASI_CRM_VN_Contract__c contract : contracts) {
            contract.OwnerId = newOwnerId;
        }

        //        change Gift Box/POSM Request owner
        List<ASI_GiftBox_Request_Header__c> requests = [SELECT Id, Name, OwnerId, ASI_GiftBox_Status__c, ASI_CRM_Customer__r.Name FROM ASI_GiftBox_Request_Header__c WHERE ASI_CRM_Customer__c IN :selectedOutletIds];
        for (ASI_GiftBox_Request_Header__c request : requests) {
            request.OwnerId = newOwnerId;
        }

        List<String> lockedRecordIds = new List<String>();

        for (ASI_CRM_AccountsAdditionalField__c outlet : selectedOutletsList) {
            if (outlet.ASI_CRM_VN_Is_Locked__c &&
                    (outlet.RecordType.Name == 'Outlet (VN) - Inactive' || outlet.RecordType.Name == 'VN Inactive Off-Trade Outlet')) {
                lockedRecordIds.add(outlet.Name);
            }
        }
        for (ASI_CRM_AccountsAdditionalField__c childOutlet : childOutletList) {
            if (childOutlet.ASI_CRM_VN_Is_Locked__c &&
                    (childOutlet.RecordType.Name == 'Outlet (VN) - Inactive' || childOutlet.RecordType.Name == 'VN Inactive Off-Trade Outlet')) {
                lockedRecordIds.add(childOutlet.Name);
            }
        }

        // can transfer if contract is Draft/Approved/Closed
        Set<String> transferableContractStatus = new Set<String>{
                'Draft', 'Approved', 'Closed'
        };
        List<String> lockedContractIds = new List<String>();
        for (ASI_CRM_VN_Contract__c contract : contracts) {
            if (!transferableContractStatus.contains(contract.ASI_CRM_Contract_Status__c)) {
                lockedContractIds.add(contract.Name + '(' + contract.ASI_CRM_Outlet_WS__r.Name +')');
            }
        }

        // can transfer if request is Open/Complete
        Set<String> transferableRequestStatus = new Set<String>{
                'Open', 'Complete'
        };
        List<String> lockedRequestIds = new List<String>();
        for (ASI_GiftBox_Request_Header__c request : requests) {
            if (!transferableRequestStatus.contains(request.ASI_GiftBox_Status__c)) {
                lockedRequestIds.add(request.Name + '(' + request.ASI_CRM_Customer__r.Name +')');
            }
        }


        if (!lockedRecordIds.isEmpty() || !lockedContractIds.isEmpty() || !lockedRequestIds.isEmpty()) {
            DmlException e = new DmlException();
            String msg = 'Transfer failed. <br>';
            if (!lockedRecordIds.isEmpty()) {
                msg += 'The following outlets are locked: ' + String.join(lockedRecordIds, ', ') + '. <br>';
            }
            if (!lockedContractIds.isEmpty()) {
                msg += 'The following contracts are during Approval Process: ' + String.join(lockedContractIds, ', ') + '. <br>';
            }
            if (!lockedRequestIds.isEmpty()) {
                msg += 'The following requests are during Approval Process: ' + String.join(lockedRequestIds, ', ') + '. <br>';
            }
            e.setMessage(msg);
            throw e;
        }

        //        call DML
        update selectedOutletsList;
        update childOutletList;
        update contracts;
        update requests;

        return '';
    }

}