({
    init: function(cmp, event, helper)
	{

    },

    searchCustomer: function(cmp, event, helper)
    {
        var searchStr = event.getSource().get('v.value');
        var checkName = cmp.get('v.checkName');

        if (checkName != searchStr)
        {
            cmp.set('v.customerID', null);
        }

        if (searchStr != undefined && searchStr != null && searchStr != '' && searchStr.length >= 2)
        {
            helper.searchCustomer(cmp, event, helper, searchStr);
        }
        else
        {
            cmp.set('v.customerList', []);
        }
    },

    selectCustomer: function(cmp, event, helper)
    {
        var customerID = event.target.dataset.id;
        var customerName = event.target.dataset.name;
        cmp.set('v.customerID', customerID);
        cmp.set('v.customerName', customerName);
        cmp.set('v.checkName', customerName);
        cmp.set('v.customerList', []);
    },

    submitAdhoc: function(cmp, event, helper)
    {
        cmp.set('v.isSubmitted', true);
        helper.submitAdhoc(cmp, event, helper);
    }
})