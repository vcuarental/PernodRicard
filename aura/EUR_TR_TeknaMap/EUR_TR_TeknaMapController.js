({
    init: function (component, event, helper) {



    },
    handleRecordUpdated: function (component, event, helper) {
        var eventParams = event.getParams();
        component.set('v.locationReaded', false);
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");

        setTimeout(() => {
            try {
                var action = component.get('c.GetLocation');
                action.setParams({
                    Id: component.get('v.recordId'),
                    ObjectName: component.get('v.ObjectName'),
                    FieldName: component.get('v.FieldName'),
                    TitleName: component.get('v.TitleFieldName'),
                    DescriptionFieldName: component.get('v.DescriptionFieldName')
                });
                action.setCallback(this, function (result) {
                    if (result.getState() == 'SUCCESS') {
                        $A.util.addClass(spinner, "slds-hide");
                        component.set('v.locationReaded', true);

                        var data = result.getReturnValue();

                        var lat = (data.latitude) ? data.latitude : '0';
                        var lng = (data.longitude) ? data.longitude : '0';
                        var title = (data.title) ? data.title : 'İlgili Nokta';
                        var description = (data.description) ? data.description : '';

                        component.find('teknamap').set('v.mapMarkers',
                            [
                                {
                                    location: {
                                        Latitude: lat,
                                        Longitude: lng
                                    },
                                    title: title,
                                    description: description
                                }
                            ]
                        );
                        component.find('teknamap').set('v.center',
                            [
                                {
                                    location: {
                                        Latitude: lat,
                                        Longitude: lng
                                    }
                                }
                            ]);
                    }
                });
                $A.enqueueAction(action);
            }
            catch (err) {

            }


        }, 500);

        if (eventParams.changeType === "LOADED") {
            //alert('loaded')
        } else if (eventParams.changeType === "CHANGED") {
            //alert('changed')
        } else if (eventParams.changeType === "REMOVED") {
            //alert('removed')
        } else if (eventParams.changeType === "ERROR") {
            //alert('error')


        }
    }

})