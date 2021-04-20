({
    init : function(component, event, helper) {
        var action = component.get('c.getHomeImageList');

        action.setCallback(this, function(response){
            var state = response.getState();
            var showImage = [];
            if(state === 'SUCCESS'){
                var rows = response.getReturnValue();
                for (var i in rows) {
                    var imageObj = rows[i];
                    if (rows[i].Attachments) {
                        imageObj['AttFile'] = "/ASICTYWholesalerCN/servlet/servlet.FileDownload?file=" + rows[i].Attachments[0].Id;
                        showImage.push(imageObj);
                    }
                }
                component.set('v.imageList', showImage);
            }else{
                console.log('error getHomeImageList');
            }
        });

        
        $A.enqueueAction(action);
    },

    clickImage : function(component, event, helper) {
        var urlval = event.getSource().get("v.id");
        if (urlval) {
            window.open(urlval, '_blank');
        }
        
    }
})