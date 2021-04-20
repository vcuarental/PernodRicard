({
    searchHelper : function(component,event,getInputkeyWord) {

        var action = component.get("c.fetchCampaigns");
        action.setParams({
            'searchKeyWord': getInputkeyWord
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                
                if (storeResponse && storeResponse.length == 0) {
                    component.set("v.Message", 'Aucun résultat ...');
                } else {
                    component.set("v.Message", 'Resultat de la recherche ...');
                }
                component.set("v.searchResVisible", true);

                if(storeResponse && storeResponse.length > 0)
                {

                    for (let i = 0; i < storeResponse.length; i++) {
                        let row = storeResponse[i];
                        row.OwnerName = row.Owner.Name;
                    }
                    component.set("v.listOfSearchRecords", storeResponse);
                }


            } else {
                console.log('error fetching contacts');
            }
        });
        $A.enqueueAction(action);

    },

    sortData : function(component,fieldName,sortDirection){
        var data = component.get("v.listOfSearchRecords");
        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;

        // to handel text type fields
        data.sort(function(a,b){
            var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
            var b = key(b) ? key(b).toLowerCase() : '';
            return reverse * ((a>b) - (b>a));
        });

        //set sorted data to accountData attribute
        component.set("v.listOfSearchRecords",data);
    },

    navigateToComponent : function (campaignId) {
        const newEvent = $A.get("e.force:navigateToComponent");
        newEvent.setParams({
            componentDef: "c:MMPJ_XRM_LC05_CheckInCampaignMembers",
            componentAttributes: {
                recordId : campaignId
            }
        });
        newEvent.fire();
    },

    detectMobile: function() {
        if ( navigator.userAgent.match(/Android/i)
            || navigator.userAgent.match(/webOS/i)
            || navigator.userAgent.match(/iPhone/i)
            || navigator.userAgent.match(/iPad/i)
            || navigator.userAgent.match(/iPod/i)
            || navigator.userAgent.match(/BlackBerry/i)
            || navigator.userAgent.match(/Windows Phone/i)
        ) {
            return !(
                window.innerWidth >= 500
                && window.innerWidth <= 800
            )
        } else {
            return window.innerWidth <= 800 && window.innerHeight <= 600
        }
    }

})