({
    init: function(cmp, event, helper)
	{
        var pageReference = cmp.get('v.pageReference');
        cmp.set('v.recordId', pageReference.state.c__id);
        var visitID = cmp.get('v.recordId');
        helper.init(cmp, event, helper, visitID);
    },

    searchSKU: function(cmp, event, helper)
    {
        var searchStr = event.getSource().get('v.value');
        var index = event.getSource().get('v.id');
        var rspDetails = cmp.get('v.rspDetails');

        if (searchStr != undefined && searchStr != null && searchStr != '' && searchStr.length >= 2)
        {
            helper.searchSKU(cmp, event, helper, searchStr, index);
        }
        else
        {
            delete rspDetails[index].skuList;
            cmp.set('v.rspDetails', rspDetails);
        }
    },

    selectSKU: function(cmp, event, helper)
    {
        var index = event.target.dataset.itemid;
        var skuID = event.target.dataset.id;
        var skuName = event.target.dataset.name;
        var rspDetails = cmp.get('v.rspDetails');

        rspDetails[index].ASI_CRM_SKU__c = skuID;
        rspDetails[index].ASI_CRM_SKU__r.Name = skuName;
        delete rspDetails[index].skuList;
        cmp.set('v.rspDetails', rspDetails);
    },

    addItem: function(cmp, event, helper)
    {
        var rspDetails = cmp.get('v.rspDetails');

        rspDetails.push({

            ASI_CRM_RSPHeader__c: null,
            ASI_CRM_CN_Input_Date_Time__c: null,
            ASI_CRM_Price_to_Consumer__c: null,
            ASI_CRM_SKU__c: null,
        });
        cmp.set('v.rspDetails', rspDetails);
    },

    deleteItem: function(cmp, event, helper)
    {
        var index = event.target.dataset.id;
        var rspDetails = cmp.get('v.rspDetails');
        var deleteRspDetails = cmp.get('v.deleteRspDetails');
        var rspDetail = rspDetails[index];

        if (rspDetail.hasOwnProperty('Id'))
        {
            deleteRspDetails.push(rspDetail);
        }

        rspDetails.splice(index, 1);
        cmp.set('v.rspDetails', rspDetails);
        cmp.set('v.deleteRspDetails', deleteRspDetails);
    },

    submitRSP: function(cmp, event, helper)
    {
        helper.submitRSP(cmp, event, helper);
    }
})